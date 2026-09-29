#!/usr/bin/env python3
"""
Church Presentation Web App Server
Runs the HTTP server and the WebSocket relay concurrently.

Environment:
  HTTP_PORT / PORT   HTTP port (default 8000)
  WEBSOCKET_PORT     WebSocket port (default 8765)
  OPERATOR_KEY       Optional shared secret for write APIs and WS broadcasting
"""

import asyncio
import gzip
import hashlib
import hmac
import http.server
import json
import os
import socket
import tempfile
import threading
import unicodedata
from email.utils import formatdate
from http.server import ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlsplit, parse_qs

import shutil
import sys

from websockets.asyncio.server import serve as ws_serve
from websockets.exceptions import ConnectionClosed

HTTP_PORT = int(os.environ.get('HTTP_PORT', os.environ.get('PORT', 8000)))
WEBSOCKET_PORT = int(os.environ.get('WEBSOCKET_PORT', 8765))
OPERATOR_KEY = os.environ.get('OPERATOR_KEY', '')

FROZEN = getattr(sys, 'frozen', False)
if FROZEN:
    # PyInstaller: bundle data as 'static' and 'songs' inside the archive.
    # Songs must be writable, so they live next to the executable.
    _BUNDLE = Path(getattr(sys, '_MEIPASS', Path(sys.executable).parent))
    _DEFAULT_STATIC = _BUNDLE / 'static'
    _DEFAULT_SONGS = Path(sys.executable).resolve().parent / 'songs'
else:
    _BASE = Path(__file__).resolve().parent.parent
    _DEFAULT_STATIC = _BASE / 'static'
    _DEFAULT_SONGS = _BASE / 'songs'
STATIC_DIR = Path(os.environ.get('STATIC_DIR', _DEFAULT_STATIC))
SONGS_DIR = Path(os.environ.get('SONGS_DIR', _DEFAULT_SONGS))


def seed_songs():
    """When frozen, copy bundled songs into the writable songs dir on first run."""
    if not FROZEN or 'SONGS_DIR' in os.environ:
        return
    bundled = _BUNDLE / 'songs'
    if SONGS_DIR.exists() or not bundled.is_dir():
        SONGS_DIR.mkdir(parents=True, exist_ok=True)
        return
    shutil.copytree(bundled, SONGS_DIR)

MAX_BODY = 5 * 1024 * 1024
GZIP_EXTS = ('.html', '.css', '.js', '.json', '.svg', '.xml', '.txt')

connected_clients = set()
operator_clients = set()


def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "localhost"


def nfc(s):
    return unicodedata.normalize('NFC', s)


def safe_song_path(name):
    """Return a resolved path inside SONGS_DIR for a song filename, or None if invalid.

    Matches NFC/NFD variants of existing filenames (macOS stores NFD).
    """
    if not isinstance(name, str) or not name:
        return None
    name = unquote(name)
    if '\x00' in name or '/' in name or '\\' in name or '..' in name:
        return None
    if not name.lower().endswith('.json') or name.startswith('.'):
        return None
    root = SONGS_DIR.resolve()
    candidate = (root / name).resolve()
    if candidate.parent != root:
        return None
    if not candidate.exists():
        target = nfc(name)
        try:
            for f in root.iterdir():
                if nfc(f.name) == target:
                    return f.resolve() if f.resolve().parent == root else None
        except OSError:
            pass
        # Not existing: use the NFC name so new files are consistently named
        candidate = (root / target).resolve()
        if candidate.parent != root:
            return None
    return candidate


def generate_filename(title):
    """Generate a filename from song title (NFC, Unicode letters kept)."""
    title = nfc(str(title or '')).lower()
    slug = ''.join(c if (c.isalnum() or c in ' -' or unicodedata.category(c).startswith('M')) else '' for c in title)
    slug = slug.replace(' ', '-')
    while '--' in slug:
        slug = slug.replace('--', '-')
    slug = slug.strip('-')
    if not slug:
        digest = hashlib.sha1(str(title).encode('utf-8')).hexdigest()[:8]
        slug = f"song-{digest}"
    return f"{slug}.json"


def write_json_atomic(path, obj):
    fd, tmp = tempfile.mkstemp(dir=str(path.parent), suffix='.tmp')
    try:
        with os.fdopen(fd, 'w', encoding='utf-8') as f:
            json.dump(obj, f, indent=2, ensure_ascii=False)
        os.replace(tmp, path)
    except BaseException:
        try:
            os.unlink(tmp)
        except OSError:
            pass
        raise


class HttpError(Exception):
    def __init__(self, code, message):
        self.code = code
        self.message = message


class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(STATIC_DIR), **kwargs)

    def end_headers(self):
        path = urlsplit(self.path).path.lower()
        if path.startswith('/api/') or path.startswith('/songs/') or path.endswith('.html') or path == '/':
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        elif path.endswith(('.js', '.css')):
            self.send_header('Cache-Control', 'no-cache')
        super().end_headers()

    # ---- helpers ----
    def _send_json(self, code, obj, extra_headers=None):
        body = json.dumps(obj).encode('utf-8')
        self._send_bytes(code, body, 'application/json', extra_headers)

    def _send_bytes(self, code, body, ctype, extra_headers=None):
        if 'gzip' in self.headers.get('Accept-Encoding', '').lower() and len(body) > 256:
            z = gzip.compress(body, compresslevel=6)
            if len(z) < len(body):
                body = z
                extra_headers = dict(extra_headers or {}, **{'Content-Encoding': 'gzip'})
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Vary', 'Accept-Encoding')
        for k, v in (extra_headers or {}).items():
            self.send_header(k, v)
        self.end_headers()
        if self.command != 'HEAD':
            self.wfile.write(body)

    def _authorized(self):
        if not OPERATOR_KEY:
            return True
        supplied = self.headers.get('X-Operator-Key', '')
        return hmac.compare_digest(supplied.encode('utf-8'), OPERATOR_KEY.encode('utf-8'))

    def _read_json_body(self):
        raw = self.headers.get('Content-Length')
        try:
            length = int(raw)
            if length < 0:
                raise ValueError
        except (TypeError, ValueError):
            raise HttpError(400, "Missing or invalid Content-Length")
        if length > MAX_BODY:
            raise HttpError(413, "Request body too large")
        try:
            data = json.loads(self.rfile.read(length).decode('utf-8'))
        except (ValueError, UnicodeDecodeError):
            raise HttpError(400, "Invalid JSON")
        if not isinstance(data, dict):
            raise HttpError(400, "JSON object expected")
        return data

    # ---- GET ----
    def do_GET(self):
        path = urlsplit(self.path).path
        if path == '/api/config':
            return self._send_json(200, {'wsPort': WEBSOCKET_PORT, 'authRequired': bool(OPERATOR_KEY)})
        if path.startswith('/songs/'):
            name = path[7:]
            if name == '':
                return self.list_songs_directory()
            return self.serve_song_file(name)
        return self.serve_static()

    def serve_static(self):
        can_gzip = 'gzip' in self.headers.get('Accept-Encoding', '').lower()
        fs_path = self.translate_path(self.path)
        if can_gzip and os.path.isfile(fs_path) and fs_path.endswith(GZIP_EXTS):
            try:
                with open(fs_path, 'rb') as f:
                    content = f.read()
                z = gzip.compress(content, compresslevel=6)
                self.send_response(200)
                self.send_header('Content-Type', self.guess_type(fs_path))
                self.send_header('Content-Encoding', 'gzip')
                self.send_header('Vary', 'Accept-Encoding')
                self.send_header('Content-Length', str(len(z)))
                self.send_header('Last-Modified', formatdate(os.path.getmtime(fs_path), usegmt=True))
                self.end_headers()
                self.wfile.write(z)
                return
            except OSError:
                pass
        return super().do_GET()

    def list_songs_directory(self):
        try:
            names = sorted(nfc(p.name) for p in SONGS_DIR.glob('*.json')) if SONGS_DIR.exists() else []
            self._send_json(200, names)
        except Exception as e:
            print(f"[HTTP] Error listing songs: {e}")
            self.send_error(500, "Internal Server Error")

    def serve_song_file(self, name):
        p = safe_song_path(name)
        if p is None:
            return self._send_json(400, {'success': False, 'message': 'invalid filename'})
        try:
            if not p.is_file():
                return self.send_error(404, "Song not found")
            self._send_bytes(200, p.read_bytes(), 'application/json')
        except Exception as e:
            print(f"[HTTP] Error serving song file: {e}")
            self.send_error(500, "Internal Server Error")

    # ---- POST ----
    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header('Content-Length', '0')
        self.end_headers()

    def do_POST(self):
        path = urlsplit(self.path).path
        handlers = {
            '/api/save-songs': self.handle_save_songs,
            '/api/update-song': self.handle_update_song,
            '/api/delete-song': self.handle_delete_song,
        }
        if path.startswith('/api/') and not self._authorized():
            return self._send_json(401, {'success': False, 'message': 'unauthorized'})
        handler = handlers.get(path)
        if handler is None:
            return self.send_error(404, "Endpoint not found")
        try:
            handler(self._read_json_body())
        except HttpError as e:
            self._send_json(e.code, {'success': False, 'message': e.message})
        except Exception as e:
            print(f"[HTTP] Error in {path}: {e}")
            self._send_json(500, {'success': False, 'message': str(e)})

    def handle_save_songs(self, data):
        songs = data.get('songs', [])
        if not isinstance(songs, list):
            raise HttpError(400, "songs must be a list")
        saved = skipped = 0
        SONGS_DIR.mkdir(parents=True, exist_ok=True)
        for song in songs:
            if not isinstance(song, dict) or not song.get('title'):
                raise HttpError(400, "Each song needs a title")
            p = safe_song_path(generate_filename(song['title']))
            if p is None:
                raise HttpError(400, "invalid filename")
            if p.exists():
                skipped += 1
                continue
            write_json_atomic(p, song)
            saved += 1
        print(f"[HTTP] save-songs: saved={saved} skipped={skipped}")
        self._send_json(200, {'success': True, 'saved': saved, 'skipped': skipped, 'total': len(songs)})

    def handle_update_song(self, data):
        old_name = data.get('oldFilename')
        song = data.get('song')
        if not old_name or not isinstance(song, dict) or not song.get('title'):
            raise HttpError(400, "Missing required fields")
        old_path = safe_song_path(old_name)
        if old_path is None:
            raise HttpError(400, "invalid filename")
        if not old_path.is_file():
            raise HttpError(404, f"Song file {old_name} not found")
        new_name = generate_filename(song['title'])
        new_path = safe_song_path(new_name)
        if new_path is None:
            raise HttpError(400, "invalid filename")
        changed = new_path != old_path
        if changed and new_path.exists():
            raise HttpError(409, f"A song named {new_name} already exists")
        write_json_atomic(new_path, song)
        if changed:
            old_path.unlink()
        print(f"[HTTP] update-song: {old_path.name} -> {new_path.name}")
        self._send_json(200, {'success': True, 'filename': new_path.name})

    def handle_delete_song(self, data):
        name = data.get('filename')
        if not name:
            raise HttpError(400, "Missing filename")
        p = safe_song_path(name)
        if p is None:
            raise HttpError(400, "invalid filename")
        if not p.is_file():
            raise HttpError(404, f"Song file {name} not found")
        p.unlink()
        print(f"[HTTP] Deleted song: {p.name}")
        self._send_json(200, {'success': True, 'message': 'Song deleted successfully'})

    def log_message(self, format, *args):
        print(f"[HTTP] {self.address_string()} - {format % args}")


def _ws_key(websocket):
    req = websocket.request
    path = req.path if req else ''
    return parse_qs(urlsplit(path).query).get('key', [''])[0]


def _ws_is_operator(websocket):
    if not OPERATOR_KEY:
        return True
    return hmac.compare_digest(_ws_key(websocket).encode('utf-8'), OPERATOR_KEY.encode('utf-8'))


async def websocket_handler(websocket):
    can_send = _ws_is_operator(websocket)
    connected_clients.add(websocket)
    print(f"[WebSocket] Client connected ({'operator' if can_send else 'view-only'}). Total: {len(connected_clients)}")
    try:
        async for message in websocket:
            if not can_send:
                continue
            try:
                json.loads(message)
            except (ValueError, TypeError):
                print("[WebSocket] Invalid JSON received, ignoring")
                continue
            dead = set()
            for client in list(connected_clients):
                if client is not websocket:
                    try:
                        await client.send(message)
                    except ConnectionClosed:
                        dead.add(client)
            connected_clients.difference_update(dead)
    except ConnectionClosed:
        pass
    finally:
        connected_clients.discard(websocket)
        print(f"[WebSocket] Client disconnected. Total: {len(connected_clients)}")


def make_http_server(port=None):
    return ThreadingHTTPServer(("", HTTP_PORT if port is None else port), CustomHTTPRequestHandler)


def start_http_server():
    httpd = make_http_server()
    httpd.daemon_threads = True
    local_ip = get_local_ip()
    print(f"HTTP Server: http://localhost:{HTTP_PORT}  http://{local_ip}:{HTTP_PORT}")
    httpd.serve_forever()


async def start_websocket_server():
    local_ip = get_local_ip()
    print(f"WebSocket Server: ws://localhost:{WEBSOCKET_PORT}  ws://{local_ip}:{WEBSOCKET_PORT}")
    async with ws_serve(websocket_handler, "", WEBSOCKET_PORT):
        await asyncio.Future()


def main():
    local_ip = get_local_ip()
    print("\n" + "=" * 60)
    print("  Church Presentation Web App Server")
    print("=" * 60)
    if not OPERATOR_KEY:
        print("\n[WARNING] OPERATOR_KEY is not set: anyone on the network can edit/delete songs "
              "and control the projector. Set OPERATOR_KEY to require a key.")
    print(f"\nAccess the application at: http://{local_ip}:{HTTP_PORT}/index.html")
    print("Press Ctrl+C to stop\n")
    seed_songs()
    threading.Thread(target=start_http_server, daemon=True).start()
    try:
        asyncio.run(start_websocket_server())
    except KeyboardInterrupt:
        print("\nShutting down servers...")


if __name__ == "__main__":
    main()
