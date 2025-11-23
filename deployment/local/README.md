# Local Deployment Guide

Running the Church Presentation App locally on your network.

## Quick Start

### Windows

1. **Install Python** (if not already installed)
   - Download from [python.org](https://www.python.org/downloads/)
   - During installation, check "Add Python to PATH"

2. **Install Dependencies**
   ```bash
   cd path\to\PresentationApp
   pip install websockets
   ```

3. **Run the Application**
   - **Option A: Using the batch file (easiest)**
     ```bash
     start.bat
     ```
   - **Option B: Using Python directly**
     ```bash
     python src\server\server.py
     ```

### macOS/Linux

1. **Install Python** (if not already installed)
   ```bash
   # macOS with Homebrew
   brew install python3
   
   # Linux (Ubuntu/Debian)
   sudo apt-get install python3 python3-pip
   ```

2. **Install Dependencies**
   ```bash
   cd path/to/PresentationApp
   pip3 install websockets
   ```

3. **Run the Application**
   ```bash
   python3 src/server/server.py
   ```
   
   Or use the provided startup script:
   ```bash
   ./startup.sh
   ```

## Network Access

Once the server starts, you'll see output like:
```
HTTP Server running on:
  - http://localhost:8000
  - http://192.168.1.100:8000

WebSocket Server running on:
  - ws://localhost:8765
  - ws://192.168.1.100:8765
```

### Access Instructions

1. **Host Computer** (where server runs)
   - Open browser → http://localhost:8000/index.html

2. **Operator Computer** (on same network)
   - Open browser → http://192.168.1.100:8000/operator.html (use the IP shown)

3. **Projector Computer** (on same network)
   - Open browser → http://192.168.1.100:8000/projector.html
   - Press F11 for full-screen mode

## Firewall Configuration

### Windows Firewall

If other devices can't connect to the server:

1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Find Python and allow both "Private" and "Public" networks
4. If Python isn't listed, add it manually

### macOS Firewall

1. System Preferences → Security & Privacy → Firewall
2. Click "Firewall Options"
3. Add Python to the allowed applications

### Linux (UFW)

```bash
# Allow ports 8000 and 8765
sudo ufw allow 8000
sudo ufw allow 8765
```

## Port Configuration

The default ports are:
- **HTTP**: 8000 (for web interface)
- **WebSocket**: 8765 (for real-time communication)

To use different ports, modify `src/server/server.py` or set environment variables:

```bash
# Windows
set HTTP_PORT=8080
set WEBSOCKET_PORT=8766
python src\server\server.py

# Linux/macOS
export HTTP_PORT=8080
export WEBSOCKET_PORT=8766
python3 src/server/server.py
```

## Finding Your Network IP

### Windows
```bash
ipconfig
```
Look for "IPv4 Address" (typically starts with 192.168 or 10.0)

### macOS
```bash
ifconfig | grep "inet "
```

### Linux
```bash
ip addr show
```

## Troubleshooting

### "Python not recognized"
- Make sure Python is installed and added to PATH
- Restart terminal/command prompt after installation
- On macOS/Linux, use `python3` instead of `python`

### "Module websockets not found"
```bash
pip install websockets
```

### "Port already in use"
- Another application is using port 8000 or 8765
- Change the port in the server or stop the other application
- Use environment variables to change ports (see above)

### "Disconnected" on projector
- Check both computers are on the same WiFi network
- Verify firewall isn't blocking the connection
- Check the IP address is correct
- Restart the server and refresh the browser

### Slow loading of songs
- Check network connection speed
- Large song libraries take time to load initially
- Songs are cached in the browser after first load

## Performance Tips

1. **Dedicated Network**: For best performance, use a wired connection for the projector computer
2. **Test Before Service**: Run through a few songs during setup
3. **Disable Screen Saver**: On projector computer, disable screen saver and sleep mode
4. **Bookmark URLs**: Bookmark the addresses for quick access next time
5. **Pre-load Songs**: Load the songs you'll use before the service starts

## Song Management

Songs are stored in the `src/songs/` directory as JSON files.

### Adding Songs

1. Create a `.json` file in `src/songs/`
2. Use this format:
   ```json
   {
     "title": "Song Title",
     "phrases": [
       ["Line 1", "Line 2", "Line 3", "Line 4"],
       ["Verse 2 Line 1", "Verse 2 Line 2", "Verse 2 Line 3", "Verse 2 Line 4"]
     ]
   }
   ```
3. Refresh the operator page to load the new song

### Editing Songs

Use the Operator Control panel to edit songs through the web interface.

## Stopping the Server

Press `Ctrl+C` in the terminal running the server.

## Next Steps

- [View Azure Deployment Guide](../azure/README.md) for cloud deployment
- [View PyInstaller Guide](../pyinstaller/README.md) for creating a standalone executable
- [View Main README](../../README.md) for general information
