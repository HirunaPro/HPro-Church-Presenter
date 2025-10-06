#!/usr/bin/env python3
"""
Optimized Azure-compatible version of the Church Presentation Web App Server
Features:
- Aggressive caching for static assets
- Gzip compression
- Better performance for Azure Container Instances
"""

import asyncio
import http.server
import socketserver
import threading
import json
import socket
import os
import gzip
import io
from pathlib import Path
from email.utils import formatdate
import websockets

# Configuration - Azure compatible
HTTP_PORT = int(os.environ.get('HTTP_PORT', os.environ.get('PORT', 8000)))
WEBSOCKET_PORT = int(os.environ.get('WEBSOCKET_PORT', 8765))

# Store connected WebSocket clients
connected_clients = set()


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


class OptimizedHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Optimized HTTP request handler with caching, compression, and CORS support"""
    
    def end_headers(self):
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        
        # Add caching headers based on file type
        path = self.path.lower()
        
        # HTML files - minimal cache (5 minutes) to allow updates
        if path.endswith('.html') or path == '/':
            self.send_header('Cache-Control', 'public, max-age=300')
        
        # Static assets - aggressive caching (1 year)
        elif path.endswith(('.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico', '.woff', '.woff2', '.ttf', '.eot')):
            self.send_header('Cache-Control', 'public, max-age=31536000, immutable')
        
        # JSON song files - moderate caching (1 hour)
        elif path.endswith('.json'):
            self.send_header('Cache-Control', 'public, max-age=3600')
        
        # Default - minimal cache
        else:
            self.send_header('Cache-Control', 'public, max-age=300')
        
        super().end_headers()
    
    def do_GET(self):
        """Handle GET requests with compression support"""
        # Check if client accepts gzip
        accept_encoding = self.headers.get('Accept-Encoding', '')
        can_gzip = 'gzip' in accept_encoding.lower()
        
        # Get the file path
        path = self.translate_path(self.path)
        
        # Check if file exists and should be compressed
        if os.path.isfile(path) and can_gzip:
            # Only compress text-based files
            if path.endswith(('.html', '.css', '.js', '.json', '.svg', '.xml', '.txt')):
                return self.send_compressed_file(path)
        
        # Fall back to default behavior
        return super().do_GET()
    
    def send_compressed_file(self, filepath):
        """Send file with gzip compression"""
        try:
            with open(filepath, 'rb') as f:
                content = f.read()
            
            # Compress content
            buf = io.BytesIO()
            with gzip.GzipFile(fileobj=buf, mode='wb', compresslevel=6) as gz:
                gz.write(content)
            compressed_content = buf.getvalue()
            
            # Send response
            self.send_response(200)
            self.send_header('Content-Type', self.guess_type(filepath))
            self.send_header('Content-Encoding', 'gzip')
            self.send_header('Content-Length', len(compressed_content))
            self.send_header('Last-Modified', formatdate(timeval=os.path.getmtime(filepath), localtime=False, usegmt=True))
            self.end_headers()
            self.wfile.write(compressed_content)
            
        except Exception as e:
            print(f"[HTTP] Error sending compressed file {filepath}: {e}")
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
            songs_dir = Path('songs')
            songs_dir.mkdir(exist_ok=True)
            
            for song in songs:
                # Generate filename from title
                filename = self.generate_filename(song['title'])
                filepath = songs_dir / filename
                
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
            # Read the request body
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            old_filename = data.get('oldFilename')
            song = data.get('song')
            
            if not old_filename or not song:
                raise ValueError("Missing required fields")
            
            # URL decode the filename (in case it contains Unicode characters)
            from urllib.parse import unquote
            old_filename = unquote(old_filename)
            
            songs_dir = Path('songs')
            old_filepath = songs_dir / old_filename
            
            # Check if old file exists
            if not old_filepath.exists():
                raise FileNotFoundError(f"Song file {old_filename} not found")
            
            # Generate new filename from new title
            new_filename = self.generate_filename(song['title'])
            new_filepath = songs_dir / new_filename
            
            # If title changed, delete old file
            if old_filename != new_filename:
                old_filepath.unlink()
                print(f"[HTTP] Deleted old song file: {old_filename}")
            
            # Save updated song
            with open(new_filepath, 'w', encoding='utf-8') as f:
                json.dump(song, f, indent=2, ensure_ascii=False)
            
            print(f"[HTTP] Updated song: {new_filename}")
            
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
            print(f"[HTTP] Error updating song: {e}")
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
            
            songs_dir = Path('songs')
            filepath = songs_dir / filename
            
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
        # Custom logging - only log errors
        if '200' not in format % args and '304' not in format % args:
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
                print(f"[WebSocket] Received: {data.get('type', 'unknown')}")
                
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
                print(f"[WebSocket] Invalid JSON received")
                
    except websockets.exceptions.ConnectionClosed:
        pass
    finally:
        # Unregister the client
        connected_clients.discard(websocket)
        print(f"[WebSocket] Client disconnected. Total clients: {len(connected_clients)}")


def start_http_server():
    """Start the HTTP server"""
    handler = OptimizedHTTPRequestHandler
    
    # Create server with address reuse enabled
    class ReuseAddrTCPServer(socketserver.ThreadingTCPServer):
        allow_reuse_address = True
        
        def server_bind(self):
            # Set socket options before binding
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            if hasattr(socket, 'SO_REUSEPORT'):
                try:
                    self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
                except (OSError, AttributeError):
                    pass
            super().server_bind()
    
    # Try to start server with retries
    max_retries = 3
    retry_delay = 2
    
    for attempt in range(max_retries):
        try:
            httpd = ReuseAddrTCPServer(("", HTTP_PORT), handler)
            httpd.request_queue_size = 10  # Increase queue size
            
            local_ip = get_local_ip()
            print(f"\n{'='*60}")
            print(f"HTTP Server running on:")
            print(f"  - http://localhost:{HTTP_PORT}")
            print(f"  - http://{local_ip}:{HTTP_PORT}")
            print(f"Performance optimizations enabled:")
            print(f"  ✅ Gzip compression")
            print(f"  ✅ Aggressive caching")
            print(f"  ✅ Threading support")
            print(f"{'='*60}\n")
            
            httpd.serve_forever()
            break
            
        except OSError as e:
            if e.errno == 98:  # Address already in use
                if attempt < max_retries - 1:
                    print(f"[HTTP] Port {HTTP_PORT} in use, waiting {retry_delay}s... (attempt {attempt + 1}/{max_retries})")
                    import time
                    time.sleep(retry_delay)
                else:
                    print(f"[HTTP] ERROR: Port {HTTP_PORT} still in use after {max_retries} attempts")
                    print(f"[HTTP] Another process may be using this port.")
                    raise
            else:
                raise


async def start_websocket_server():
    """Start the WebSocket server"""
    local_ip = get_local_ip()
    print(f"\n{'='*60}")
    print(f"WebSocket Server running on:")
    print(f"  - ws://localhost:{WEBSOCKET_PORT}")
    print(f"  - ws://{local_ip}:{WEBSOCKET_PORT}")
    print(f"{'='*60}\n")
    
    # Configure WebSocket server with optimizations
    async with websockets.serve(
        websocket_handler, 
        "", 
        WEBSOCKET_PORT,
        max_size=10 * 1024 * 1024,  # 10MB max message size
        max_queue=32,  # Max queued messages
        compression=None  # Disable compression for better latency
    ):
        await asyncio.Future()  # Run forever


def main():
    """Main entry point"""
    local_ip = get_local_ip()
    
    print("\n" + "="*60)
    print("  Church Presentation Web App Server")
    print("  Optimized for Azure Container Instances")
    if os.environ.get('WEBSITE_SITE_NAME'):
        print("  Running on Azure App Service")
        print(f"  Site: {os.environ.get('WEBSITE_SITE_NAME')}")
    print("="*60)
    print(f"\nStarting optimized servers...")
    print(f"HTTP Port: {HTTP_PORT}")
    print(f"WebSocket Port: {WEBSOCKET_PORT}")
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
