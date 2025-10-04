#!/bin/bash
# Azure App Service startup script
# This script is executed when the app starts on Azure

echo "Starting Church Presentation App on Azure..."
echo "Installing Python dependencies..."
pip install -r requirements.txt

echo "Starting Python server..."
python server.py
