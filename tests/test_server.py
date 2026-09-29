import json
import sys
import threading
import unicodedata
import urllib.error
import urllib.request
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'src' / 'server'))
import server  # noqa: E402


@pytest.fixture
def songs(tmp_path, monkeypatch):
    d = tmp_path / 'songs'
    d.mkdir()
    monkeypatch.setattr(server, 'SONGS_DIR', d)
    return d


def test_safe_song_path_valid(songs):
    p = server.safe_song_path('a.json')
    assert p == songs.resolve() / 'a.json'
    assert server.safe_song_path('a%20b.json') == songs.resolve() / 'a b.json'


@pytest.mark.parametrize('bad', ['', '../x.json', '..%2Fx.json', 'a/b.json', 'a\\b.json',
                                 'x.txt', 'x', '..', '%2e%2e/x.json', '/etc/passwd', 'a\x00.json', None])
def test_safe_song_path_invalid(songs, bad):
    assert server.safe_song_path(bad) is None


def test_safe_song_path_symlink_escape(songs, tmp_path):
    outside = tmp_path / 'secret.json'
    outside.write_text('{}')
    (songs / 'link.json').symlink_to(outside)
    assert server.safe_song_path('link.json') is None


def test_safe_song_path_nfd_matches_nfc(songs):
    nfd = unicodedata.normalize('NFD', 'ශ්‍රී.json')
    (songs / nfd).write_text('{}')
    p = server.safe_song_path(unicodedata.normalize('NFC', 'ශ්‍රී.json'))
    assert p is not None and p.exists()


def test_generate_filename():
    assert server.generate_filename('Hello  World!') == 'hello-world.json'
    f = server.generate_filename('!!!')
    assert f.startswith('song-') and f.endswith('.json')
    assert server.generate_filename('!!!') == f
    assert server.generate_filename('') .startswith('song-')
    assert server.generate_filename('ආයුබෝවන්').startswith('ආයුබෝවන්')


@pytest.fixture
def http_server(songs, monkeypatch, tmp_path):
    static = tmp_path / 'static'
    static.mkdir()
    (static / 'index.html').write_text('<h1>hi</h1>')
    (static / 'a.js').write_text('1')
    (static / 'a.css').write_text('a{}')
    monkeypatch.setattr(server, 'STATIC_DIR', static)
    monkeypatch.setattr(server, 'OPERATOR_KEY', '')
    httpd = server.make_http_server(0)
    t = threading.Thread(target=httpd.serve_forever, daemon=True)
    t.start()
    yield f'http://127.0.0.1:{httpd.server_address[1]}'
    httpd.shutdown()
    httpd.server_close()


def req(base, path, body=None, headers=None, method=None, raw=None):
    data = raw if raw is not None else (json.dumps(body).encode() if body is not None else None)
    r = urllib.request.Request(base + path, data=data, headers=headers or {}, method=method)
    try:
        with urllib.request.urlopen(r) as resp:
            return resp.status, dict(resp.headers), resp.read()
    except urllib.error.HTTPError as e:
        return e.code, dict(e.headers), e.read()


def test_config_and_cache_headers(http_server):
    s, h, b = req(http_server, '/api/config')
    assert s == 200 and json.loads(b) == {'wsPort': server.WEBSOCKET_PORT, 'authRequired': False}
    assert 'no-cache' in req(http_server, '/index.html')[1]['Cache-Control']
    assert req(http_server, '/a.js')[1]['Cache-Control'] == 'no-cache'
    assert req(http_server, '/a.css')[1]['Cache-Control'] == 'no-cache'
    assert 'Access-Control-Allow-Origin' not in h


def test_song_crud(http_server, songs):
    s, _, b = req(http_server, '/api/save-songs', {'songs': [{'title': 'One', 'phrases': []}]})
    assert s == 200 and json.loads(b)['saved'] == 1
    assert json.loads(req(http_server, '/songs/')[2]) == ['one.json']
    s, h, _ = req(http_server, '/songs/one.json')
    assert s == 200 and 'no-cache' in h['Cache-Control']
    assert req(http_server, '/songs/..%2F..%2Fetc%2Fpasswd')[0] == 400
    assert req(http_server, '/songs/nope.json')[0] == 404

    s, _, b = req(http_server, '/api/update-song', {'oldFilename': 'one.json', 'song': {'title': 'Two'}})
    assert s == 200 and json.loads(b)['filename'] == 'two.json'
    assert not (songs / 'one.json').exists() and (songs / 'two.json').exists()

    req(http_server, '/api/save-songs', {'songs': [{'title': 'Three'}]})
    s, _, _ = req(http_server, '/api/update-song', {'oldFilename': 'two.json', 'song': {'title': 'Three'}})
    assert s == 409 and (songs / 'two.json').exists()

    assert req(http_server, '/api/update-song', {'oldFilename': '../x.json', 'song': {'title': 'x'}})[0] == 400
    assert req(http_server, '/api/delete-song', {'filename': '../x.json'})[0] == 400
    assert req(http_server, '/api/delete-song', {'filename': 'two.json'})[0] == 200
    assert not (songs / 'two.json').exists()


def test_content_length_errors(http_server, monkeypatch):
    assert req(http_server, '/api/delete-song', method='POST')[0] == 400
    monkeypatch.setattr(server, 'MAX_BODY', 10)
    assert req(http_server, '/api/delete-song', {'filename': 'a-long-name.json'})[0] == 413


def test_auth(http_server, songs, monkeypatch):
    monkeypatch.setattr(server, 'OPERATOR_KEY', 'sekret')
    assert json.loads(req(http_server, '/api/config')[2])['authRequired'] is True
    s, _, b = req(http_server, '/api/save-songs', {'songs': []})
    assert s == 401 and json.loads(b) == {'success': False, 'message': 'unauthorized'}
    assert req(http_server, '/api/save-songs', {'songs': []}, {'X-Operator-Key': 'bad'})[0] == 401
    assert req(http_server, '/api/save-songs', {'songs': []}, {'X-Operator-Key': 'sekret'})[0] == 200


def test_websocket_relay_and_auth(songs, monkeypatch):
    import asyncio
    from websockets.asyncio.client import connect
    from websockets.asyncio.server import serve
    monkeypatch.setattr(server, 'OPERATOR_KEY', 'k')

    async def run():
        async with serve(server.websocket_handler, '127.0.0.1', 0) as srv:
            port = srv.sockets[0].getsockname()[1]
            base = f'ws://127.0.0.1:{port}'
            async with connect(base + '/?key=k') as op, connect(base) as viewer, connect(base + '/?key=k') as proj:
                await asyncio.sleep(0.1)
                await viewer.send('{"x":1}')
                with pytest.raises(asyncio.TimeoutError):
                    await asyncio.wait_for(proj.recv(), 0.3)
                await op.send('{"x":2}')
                assert await asyncio.wait_for(proj.recv(), 1) == '{"x":2}'
                assert await asyncio.wait_for(viewer.recv(), 1) == '{"x":2}'

    asyncio.run(run())
