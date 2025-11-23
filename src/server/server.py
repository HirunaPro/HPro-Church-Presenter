#!/usr/bin/env python3
"""
Church Presentation Web App Server
Runs both HTTP server and WebSocket server concurrently
"""

import asyncio
import http.server
import socketserver
import threading
import json
import socket
import os
from pathlib import Path
import websockets

# Configuration
HTTP_PORT = 8000
WEBSOCKET_PORT = 8765

# Store connected WebSocket clients
connected_clients = set()

# Change to the static directory for serving files
STATIC_DIR = Path(__file__).parent.parent / 'static'
SONGS_DIR = Path(__file__).parent.parent / 'songs'

# Change working directory to static for HTTP server
os.chdir(STATIC_DIR)


def get_local_ip():
    """Get the local IP address of this machine"""
    try:
        # Create a socket to determine the local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception:
        return "localhost"


class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom HTTP request handler with CORS support"""
    
    def end_headers(self):
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        
        # Disable caching for welcome.html to always show latest content
        if self.path.endswith('welcome.html') or 'welcome.html' in self.path:
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
            self.send_header('Pragma', 'no-cache')
            self.send_header('Expires', '0')
        
        super().end_headers()
    
    def do_GET(self):
        """Handle GET requests, including special routing for songs"""
        # Handle songs directory
        if self.path.startswith('/songs/'):
            song_filename = self.path[7:]  # Remove '/songs/' prefix
            if song_filename == '':
                # List songs directory
                self.list_songs_directory()
                return
            else:
                # Serve specific song file
                self.serve_song_file(song_filename)
                return
        
        # Default behavior for other files
        super().do_GET()
    
    def list_songs_directory(self):
        """List all songs in JSON format"""
        try:
            songs = []
            if SONGS_DIR.exists():
                for song_file in sorted(SONGS_DIR.glob('*.json')):
                    songs.append(song_file.name)
            
            response = json.dumps(songs)
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Content-Length', len(response))
            self.end_headers()
            self.wfile.write(response.encode('utf-8'))
        except Exception as e:
            print(f"[HTTP] Error listing songs: {e}")
            self.send_error(500, "Internal Server Error")
    
    def serve_song_file(self, filename):
        """Serve a specific song file"""
        try:
            from urllib.parse import unquote
            filename = unquote(filename)
            filepath = SONGS_DIR / filename
            
            if not filepath.exists():
                self.send_error(404, "Song not found")
                return
            
            with open(filepath, 'rb') as f:
                content = f.read()
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Content-Length', len(content))
            self.end_headers()
            self.wfile.write(content)
        except Exception as e:
            print(f"[HTTP] Error serving song file: {e}")
            self.send_error(500, "Internal Server Error")
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()
    
    def do_POST(self):
        """Handle POST requests"""
        if self.path == '/api/save-songs':
            self.handle_save_songs()
        elif self.path == '/api/update-song':
            self.handle_update_song()
        elif self.path == '/api/delete-song':
            self.handle_delete_song()
        else:
            self.send_error(404, "Endpoint not found")
    
    def handle_save_songs(self):
        """Handle saving bulk songs"""
        try:
            # Read the request body
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            songs = data.get('songs', [])
            saved_count = 0
            skipped_count = 0
            
            # Create songs directory if it doesn't exist
            SONGS_DIR.mkdir(exist_ok=True)
            
            for song in songs:
                # Generate filename from title
                filename = self.generate_filename(song['title'])
                filepath = SONGS_DIR / filename
                
                # Skip if file already exists
                if filepath.exists():
                    print(f"[HTTP] Song '{song['title']}' already exists, skipping")
                    skipped_count += 1
                    continue
                
                # Save the song
                with open(filepath, 'w', encoding='utf-8') as f:
                    json.dump(song, f, indent=2, ensure_ascii=False)
                
                print(f"[HTTP] Saved song: {filename}")
                saved_count += 1
            
            # Send response
            response = {
                'success': True,
                'saved': saved_count,
                'skipped': skipped_count,
                'total': len(songs)
            }
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode('utf-8'))
            
        except Exception as e:
            print(f"[HTTP] Error saving songs: {e}")
            error_response = {
                'success': False,
                'message': str(e)
            }
            
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(error_response).encode('utf-8'))
    
    def generate_filename(self, title):
        """Generate a filename from song title"""
        # Convert to lowercase
        filename = title.lower()
        # Replace spaces and special characters with hyphens
        filename = ''.join(c if c.isalnum() or c in ' -' else '' for c in filename)
        filename = filename.replace(' ', '-')
        # Remove multiple consecutive hyphens
        while '--' in filename:
            filename = filename.replace('--', '-')
        # Remove leading/trailing hyphens
        filename = filename.strip('-')
        # Add .json extension
        filename = f"{filename}.json"
        return filename
    
    def handle_update_song(self):
        """Handle updating a song"""
        try:
            print("[HTTP] ===== UPDATE SONG REQUEST =====")
            
            # Read the request body
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            print(f"[HTTP] Raw request data keys: {data.keys()}")
            
            old_filename = data.get('oldFilename')
            song = data.get('song')
            
            print(f"[HTTP] Old filename (before decode): {old_filename}")
            print(f"[HTTP] New title: {song.get('title') if song else 'N/A'}")
            print(f"[HTTP] Number of phrases: {len(song.get('phrases', [])) if song else 0}")
            
            if not old_filename or not song:
                raise ValueError("Missing required fields")
            
            # URL decode the filename (in case it contains Unicode characters)
            from urllib.parse import unquote
            old_filename = unquote(old_filename)
            
            print(f"[HTTP] Old filename (after decode): {old_filename}")
            
            old_filepath = SONGS_DIR / old_filename
            
            print(f"[HTTP] Old filepath: {old_filepath}")
            print(f"[HTTP] File exists: {old_filepath.exists()}")
            
            # Check if old file exists
            if not old_filepath.exists():
                print(f"[HTTP] ERROR: File not found!")
                print(f"[HTTP] Looking for: {old_filepath.absolute()}")
                # List files in songs directory
                print(f"[HTTP] Files in songs dir:")
                for f in SONGS_DIR.iterdir():
                    print(f"[HTTP]   - {f.name}")
                raise FileNotFoundError(f"Song file {old_filename} not found")
            
            # Generate new filename from new title
            new_filename = self.generate_filename(song['title'])
            new_filepath = SONGS_DIR / new_filename
            
            print(f"[HTTP] New filename: {new_filename}")
            print(f"[HTTP] Filenames match: {old_filename == new_filename}")
            
            # Save the song content for verification
            print(f"[HTTP] Song content:")
            print(f"[HTTP]   Title: {song['title']}")
            print(f"[HTTP]   Phrases: {len(song['phrases'])} verses")
            for i, phrase in enumerate(song['phrases']):
                print(f"[HTTP]     Verse {i+1}: {len(phrase)} lines")
            
            # If title changed, delete old file
            if old_filename != new_filename:
                print(f"[HTTP] Title changed - deleting old file")
                old_filepath.unlink()
                print(f"[HTTP] Deleted old song file: {old_filename}")
            else:
                print(f"[HTTP] Title unchanged - overwriting same file")
            
            # Save updated song
            print(f"[HTTP] Writing to: {new_filepath.absolute()}")
            with open(new_filepath, 'w', encoding='utf-8') as f:
                json.dump(song, f, indent=2, ensure_ascii=False)
            
            print(f"[HTTP] ✓ File written successfully!")
            
            # Verify the file was written
            if new_filepath.exists():
                file_size = new_filepath.stat().st_size
                print(f"[HTTP] ✓ File exists, size: {file_size} bytes")
            else:
                print(f"[HTTP] ✗ WARNING: File does not exist after write!")
            
            print(f"[HTTP] ===== UPDATE COMPLETE =====")
            
            # Send response
            response = {
                'success': True,
                'filename': new_filename
            }
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode('utf-8'))
            
        except Exception as e:
            print(f"[HTTP] ===== UPDATE FAILED =====")
            print(f"[HTTP] Error: {e}")
            import traceback
            traceback.print_exc()
            
            error_response = {
                'success': False,
                'message': str(e)
            }
            
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(error_response).encode('utf-8'))
    
    def handle_delete_song(self):
        """Handle deleting a song"""
        try:
            # Read the request body
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            filename = data.get('filename')
            
            if not filename:
                raise ValueError("Missing filename")
            
            # URL decode the filename (in case it contains Unicode characters)
            from urllib.parse import unquote
            filename = unquote(filename)
            
            filepath = SONGS_DIR / filename
            
            # Check if file exists
            if not filepath.exists():
                raise FileNotFoundError(f"Song file {filename} not found")
            
            # Delete the file
            filepath.unlink()
            print(f"[HTTP] Deleted song: {filename}")
            
            # Send response
            response = {
                'success': True,
                'message': 'Song deleted successfully'
            }
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode('utf-8'))
            
        except Exception as e:
            print(f"[HTTP] Error deleting song: {e}")
            error_response = {
                'success': False,
                'message': str(e)
            }
            
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(error_response).encode('utf-8'))

    
    def log_message(self, format, *args):
        # Custom logging
        print(f"[HTTP] {self.address_string()} - {format % args}")


async def websocket_handler(websocket):
    """Handle WebSocket connections"""
    # Register the client
    connected_clients.add(websocket)
    print(f"[WebSocket] Client connected. Total clients: {len(connected_clients)}")
    
    try:
        async for message in websocket:
            # Parse the message
            try:
                data = json.loads(message)
                print(f"[WebSocket] Received: {data}")
                
                # Broadcast to all connected clients (mainly projector)
                disconnected = set()
                for client in connected_clients:
                    if client != websocket:  # Don't send back to sender
                        try:
                            await client.send(message)
                        except websockets.exceptions.ConnectionClosed:
                            disconnected.add(client)
                
                # Remove disconnected clients
                connected_clients.difference_update(disconnected)
                
            except json.JSONDecodeError:
                print(f"[WebSocket] Invalid JSON received: {message}")
                
    except websockets.exceptions.ConnectionClosed:
        print("[WebSocket] Connection closed")
    finally:
        # Unregister the client
        connected_clients.discard(websocket)
        print(f"[WebSocket] Client disconnected. Total clients: {len(connected_clients)}")


def start_http_server():
    """Start the HTTP server"""
    handler = CustomHTTPRequestHandler
    with socketserver.TCPServer(("", HTTP_PORT), handler) as httpd:
        local_ip = get_local_ip()
        print(f"\n{'='*60}")
        print(f"HTTP Server running on:")
        print(f"  - http://localhost:{HTTP_PORT}")
        print(f"  - http://{local_ip}:{HTTP_PORT}")
        print(f"{'='*60}\n")
        httpd.serve_forever()


async def start_websocket_server():
    """Start the WebSocket server"""
    local_ip = get_local_ip()
    print(f"\n{'='*60}")
    print(f"WebSocket Server running on:")
    print(f"  - ws://localhost:{WEBSOCKET_PORT}")
    print(f"  - ws://{local_ip}:{WEBSOCKET_PORT}")
    print(f"{'='*60}\n")
    
    async with websockets.serve(websocket_handler, "", WEBSOCKET_PORT):
        await asyncio.Future()  # Run forever


def main():
    """Main entry point"""
    local_ip = get_local_ip()
    
    print("\n" + "="*60)
    print("  Church Presentation Web App Server")
    print("="*60)
    print(f"\nStarting servers...")
    print(f"\nAccess the application at:")
    print(f"  http://{local_ip}:{HTTP_PORT}/index.html")
    print(f"\nPress Ctrl+C to stop the servers\n")
    
    # Start HTTP server in a separate thread
    http_thread = threading.Thread(target=start_http_server, daemon=True)
    http_thread.start()
    
    # Start WebSocket server in the main thread using asyncio
    try:
        asyncio.run(start_websocket_server())
    except KeyboardInterrupt:
        print("\n\nShutting down servers...")
        print("Goodbye!\n")


if __name__ == "__main__":
    main()
