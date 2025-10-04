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
from pathlib import Path
import websockets

# Configuration
HTTP_PORT = 8000
WEBSOCKET_PORT = 8765

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


class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom HTTP request handler with CORS support"""
    
    def end_headers(self):
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()
    
    def log_message(self, format, *args):
        # Custom logging
        print(f"[HTTP] {self.address_string()} - {format % args}")


async def websocket_handler(websocket, path):
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
