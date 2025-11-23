#!/bin/bash
# Church Presentation App startup script
# Local network deployment for macOS/Linux

echo "Starting Church Presentation App..."
echo "Installing Python dependencies..."
pip3 install -r requirements.txt

echo "Starting Python server..."
python3 src/server/server.py
