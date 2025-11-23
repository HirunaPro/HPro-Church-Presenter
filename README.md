# Church Presentation Web App

A simple, self-hosted web application for displaying song lyrics and simple slides during church worship services. Control content from an operator panel and display it on a projector in real-time using WebSocket communication.

---

## 🚀 Quick Start - Choose Your Deployment Method

This app supports **4 different deployment methods**. Choose one that fits your needs:

### Quick Reference Commands

| Method            | Command                                                          | Cost      | Internet |
| ----------------- | ---------------------------------------------------------------- | --------- | -------- |
| **Local Network** | `start.bat` or `python3 src/server/server.py`                    | $0        | ❌ No     |
| **Docker**        | `cd deployment/docker && docker-compose up`                      | $0        | ❌ No     |
| **Azure Cloud**   | `.\deployment\azure\deploy-azure-container.ps1 -AppName "myapp"` | ~$0.57/mo | ✅ Yes    |
| **Windows EXE**   | `.\deployment\pyinstaller\build-executable.ps1`                  | $0        | ❌ No     |

---

### Detailed Deployment Options

#### 1. 🖥️ Local Network (Recommended for On-Site)
Run on your local computer/network - perfect for on-site church services.

**Best for:** Church services where devices are on same WiFi

**Setup:** 
```bash
# Windows
start.bat

# macOS/Linux
python3 src/server/server.py
```

**Access:**
```
Landing Page:      http://localhost:8000/index.html
Operator Control:  http://localhost:8000/operator.html
Projector Display: http://localhost:8000/projector.html
```

**Cost:** $0 | **Internet:** Not needed | **Setup:** Easy

👉 **[Local Deployment Guide](deployment/local/README.md)**

---

#### 2. 🐳 Docker Container (Recommended for Development)
Run in a containerized environment for consistency and isolation.

**Best for:** Testing and development with container isolation

**Setup:** 
```bash
cd deployment/docker
docker-compose up
```

**Cost:** $0 (Docker is free) | **Internet:** Not needed | **Setup:** Medium

**Why Docker:**
- ✅ **Consistent environment** - Same setup everywhere
- ✅ **Isolation** - Doesn't affect your system
- ✅ **Easy to test** - Before cloud deployment
- ✅ **Development friendly** - Great for testing changes
- ✅ **Multiple instances** - Run several at once

👉 **[Docker Deployment Guide](deployment/docker/README.md)**

---

#### 3. ☁️ Azure Cloud (Recommended for Accessibility)
Deploy to Azure Container Instances for internet access from anywhere.

**Best for:** Remote access from anywhere with WebSocket support

**Full WebSocket Support** - Perfect for this app! Deploy to Azure Container Instances with native WebSocket support.

```powershell
# Windows - One command deploy
.\deployment\azure\deploy-azure-container.ps1 -AppName "mychurch-app"

# Linux/Mac - One command deploy
./deployment\azure\deploy-azure-container.sh --app-name "mychurch-app"
```

**Cost:** ~$0.57/month (3 hrs/week) | **Internet:** Required | **Setup Time:** 5 minutes

**Why Container Instances:**
- ✅ **Full WebSocket Support** - Native ws:// protocol support
- ✅ **Pay-per-second** - Only $0.57/month for weekly use (3hr/week)
- ✅ **No quota issues** - Different quota from App Service
- ✅ **Easy start/stop** - Save money when not in use
- ✅ **5-minute deployment** - Fast and simple

👉 **[Azure Deployment Guide](deployment/azure/README.md)**

---

#### 4. 📦 Windows Executable (PyInstaller)
Create a standalone `.exe` file - no Python installation needed.

**Best for:** Distribution to other PCs

```powershell
cd .\deployment\pyinstaller
.\build-executable.ps1
```

**Creates:** `dist/ChurchApp.exe` | **Size:** ~50MB | **Platforms:** Windows only

**Use Case:**
- Distributing to churches without technical staff
- Running without Python installation
- Portable USB installation

👉 **[PyInstaller Build Guide](deployment/pyinstaller/README.md)**

---

## Deployment Comparison

| Feature               | Local Network    | Docker              | Azure Cloud   | Windows EXE  |
| --------------------- | ---------------- | ------------------- | ------------- | ------------ |
| **Setup Difficulty**  | Easy             | Medium              | Medium        | Medium       |
| **Monthly Cost**      | $0               | $0                  | $0.57-$1.14   | $0           |
| **Internet Required** | No               | No                  | Yes           | No           |
| **Network Range**     | Local WiFi       | Local WiFi          | Global        | Local WiFi   |
| **Python Needed**     | Yes              | No (Docker)         | No            | No           |
| **Startup Time**      | Fast             | Normal              | Normal        | Slow         |
| **Best For**          | On-site services | Development/Testing | Remote access | Distribution |
| **Scaling**           | Manual           | Easy                | Automatic     | No           |
| **Production Ready**  | ⚠️ Limited        | ✅ Good              | ✅ Excellent   | ⚠️ Limited    |

---

## Features

- **Operator Control Panel**: Search and select songs, control font sizes, and manage simple slides
- **Singlish Search**: Search for Sinhala and Tamil songs using English letters (romanized/Singlish)
- **Projector Display**: Clean, full-screen display for congregation viewing
- **Real-time Updates**: WebSocket communication for instant content updates
- **Song Library**: Searchable song database with multi-line verse display (4-6 lines at once)
- **Multi-language Support**: Works seamlessly with Sinhala, Tamil, and English songs
- **Simple Slides**: Pre-defined slides for welcome, sermon, prayer, announcements, and custom text
- **Customizable**: Adjustable font sizes, church name, and logo
- **No Internet Required**: Runs completely offline once set up

---

## System Requirements

- **Python 3.7 or later**
- **Modern web browser** (Chrome, Firefox, Edge, Safari)
- **WiFi network** (for connecting multiple devices)

## Installation

### 1. Install Python

If you don't have Python installed:
- Download from [python.org](https://www.python.org/downloads/)
- During installation, check "Add Python to PATH"

### 2. Install Dependencies

Open a terminal/command prompt in the project directory and run:

```bash
pip install websockets
```

## Running the Application

### Windows

Simply double-click `start.bat` in the project folder, or run:

```bash
start.bat
```

### macOS/Linux

Run the Python server directly:

```bash
python3 src/server/server.py
```

Or use the provided startup script:

```bash
./startup.sh
```

### Windows Standalone Executable (No Python Required)

Build a standalone Windows executable that doesn't require Python installation:

```powershell
cd .\deployment\pyinstaller
.\build-executable.ps1
```

This creates a `dist` folder with the executable. See `deployment/pyinstaller/README.md` for details.

---

## Usage

### 1. Start the Server

Run the startup script. You'll see output showing the local IP address, for example:

```
HTTP Server running on:
  - http://localhost:8000
  - http://192.168.1.100:8000

WebSocket Server running on:
  - ws://localhost:8765
  - ws://192.168.1.100:8765

Access the application at:
  http://192.168.1.100:8000/index.html
```

### 2. Open the Landing Page

On the host computer, open a web browser and navigate to:
- `http://localhost:8000/index.html`

### 3. Open Operator Control

Click "Open Operator Control" or navigate to:
- `operator.html`

This is where you'll control what appears on the projector.

### 4. Open Projector Display

On the computer connected to the projector, open a web browser and navigate to:
- `http://[YOUR-IP]:8000/projector.html`

Replace `[YOUR-IP]` with the IP address shown when you started the server.

Press **F11** for full-screen mode.

## Operator Controls

### Song Selection with Singlish Search
1. Use the search box to filter songs - **supports Singlish, Sinhala, and Tamil input**
2. Type in English letters to search for Sinhala/Tamil songs (e.g., type "yesu" to find "යේසු" or "இயேசு")
3. Click a song to load its verses
4. Click any verse to display it on the projector (displays 4-6 lines at once)

**See [SINGLISH-SEARCH-GUIDE.md](SINGLISH-SEARCH-GUIDE.md) for detailed search examples and tips.**

### Font Size
- **Small**: 36px
- **Medium**: 48px (default)
- **Large**: 64px
- **Extra Large**: 80px

### Simple Slides
- **Welcome**: Displays welcome message
- **Sermon in Progress**: For during sermons
- **Prayer Time**: For prayer sessions
- **Announcements**: For announcements
- **Blank Screen**: Shows a black screen
- **Custom Text**: Enter custom text (e.g., Bible verses) and click "Show Custom Text"

### Connection Status
The connection indicator shows:
- **Green (Connected)**: WebSocket is connected to projector
- **Red (Disconnected)**: Connection lost (will auto-reconnect)

## Adding Songs

Songs are stored as JSON files in the `src/songs/` directory.

### Song File Format (Multi-Line Verses)

The app now supports displaying multiple lines at once (4-6 lines per verse). Create a new `.json` file in the `src/songs/` folder:

```json
{
  "title": "Your Song Title",
  "phrases": [
    [
      "First line of verse 1",
      "Second line of verse 1",
      "Third line of verse 1",
      "Fourth line of verse 1"
    ],
    [
      "First line of verse 2",
      "Second line of verse 2",
      "Third line of verse 2",
      "Fourth line of verse 2"
    ]
  ]
}
```

**Note:** The old single-line format is still supported for backward compatibility:
```json
{
  "title": "Your Song Title",
  "phrases": [
    "Single line 1",
    "Single line 2"
  ]
}
```

**See [MULTI-LINE-SONG-FORMAT.md](docs/MULTI-LINE-SONG-FORMAT.md) for detailed guide and examples.**

### Naming Convention
- Use lowercase letters
- Replace spaces with hyphens
- Example: `amazing-grace.json`

### Example

File: `src/songs/joyful-joyful.json`

```json
{
  "title": "Joyful, Joyful We Adore Thee",
  "phrases": [
    [
      "Joyful, joyful we adore Thee",
      "God of glory, Lord of love",
      "Hearts unfold like flowers before Thee",
      "Opening to the sun above"
    ],
    [
      "All Thy works with joy surround Thee",
      "Earth and heaven reflect Thy rays",
      "Stars and angels sing around Thee",
      "Center of unbroken praise"
    ]
  ]
}
```

After adding a song file, refresh the operator page to load it.

## Customization

### Change Church Name

Edit `src/static/js/operator.js` and find this line:

```javascript
const CHURCH_NAME = "Our Church"; // Configurable
```

Change `"Our Church"` to your church's name.

### Change Church Logo

Replace `src/static/images/church-logo.png` with your own logo image. Recommended size: 150x150 pixels.

### Modify Default Welcome Message

Edit `src/static/js/operator.js` and `src/static/js/projector.js` to change the default welcome message.

### Customize Slide Messages

In `src/static/js/operator.js`, find the slide button event handlers to modify default slide text:

```javascript
case 'welcome':
    content.text = `Welcome to ${CHURCH_NAME}`;
    break;
```

## Troubleshooting

### Connection Issues
- **"Disconnected"** → Check server is running, verify WiFi connection, restart browser
- **Can't access from other PC** → Run firewall config or allow in Windows Defender
- **WebSocket fails** → Check ports 8000 & 8765 not blocked by firewall

### Songs Not Loading
- Check `songs/` directory has `.json` files
- Verify JSON syntax (use JSON validator)
- Refresh browser page
- Check browser console (F12) for errors

### Server Issues
- **"Python not recognized"** → Install Python, check "Add to PATH", restart terminal
- **"Module websockets not found"** → Run: `pip install websockets`
- **"Port already in use"** → Change ports in `server.py` or restart server

### Docker Issues
- **"Docker not running"** → Start Docker Desktop, wait for whale icon
- **"Port already in use"** → Run: `az container restart --name mychurch-app --resource-group [rg-name]`

See `docs/` folder for complete troubleshooting guides.

## Network Setup

### Finding Your IP Address

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" under your active network adapter.

**macOS/Linux:**
```bash
ifconfig
```
or
```bash
ip addr show
```

### Firewall Configuration

If other devices can't connect:

**Windows:**
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Allow Python through both Private and Public networks

**macOS:**
1. System Preferences → Security & Privacy → Firewall
2. Click "Firewall Options"
3. Add Python to allowed applications

## File Structure

```
PresentationApp/
├── src/                          # Source code
│   ├── static/                   # Web interface files
│   │   ├── index.html           # Landing page
│   │   ├── operator.html        # Operator control interface
│   │   ├── projector.html       # Projector display
│   │   ├── css/
│   │   │   └── style.css        # Stylesheet
│   │   ├── js/
│   │   │   ├── operator.js      # Operator control logic
│   │   │   ├── projector.js     # Projector display logic
│   │   │   └── transliteration.js # Singlish search module
│   │   └── images/
│   │       └── church-logo.png  # Church logo
│   ├── server/                   # Server code
│   │   ├── server.py            # Main WebSocket & HTTP server
│   │   └── server-optimized.py  # Optimized for Azure
│   └── songs/                    # Song library (JSON files)
│       ├── amazing-grace.json
│       ├── blessed-assurance.json
│       └── ...
├── deployment/                   # Deployment methods
│   ├── local/                    # Local network deployment
│   │   └── README.md
│   ├── docker/                   # Docker container deployment
│   │   ├── README.md
│   │   ├── Dockerfile            # Docker image definition
│   │   └── docker-compose.yml    # Multi-container setup
│   ├── azure/                    # Azure Cloud deployment
│   │   ├── README.md
│   │   ├── deploy-azure-container.ps1
│   │   ├── deploy-azure-container.sh
│   │   └── ... (other Azure scripts)
│   └── pyinstaller/              # Windows executable build
│       ├── README.md
│       ├── build-executable.ps1
│       └── ... (build files)
├── docs/                         # Documentation
│   ├── PROJECT-STRUCTURE.md      # Detailed file structure
│   ├── QUICK-START.md            # Getting started guide
│   ├── SINGLISH-SEARCH-GUIDE.md  # Search documentation
│   ├── MULTI-LINE-SONG-FORMAT.md # Song format guide
│   └── ... (other documentation)
├── start.bat                     # Windows startup script
├── startup.sh                    # Linux/macOS startup script
├── requirements.txt              # Python dependencies
└── README.md                     # This file
```

## Technical Details

### Ports
- **HTTP Server**: 8000
- **WebSocket Server**: 8765

### WebSocket Message Format

Messages sent from operator to projector:

```json
{
  "type": "song_phrase" | "simple_slide" | "blank",
  "text": "Content to display",
  "fontSize": "small" | "medium" | "large" | "extra-large",
  "songTitle": "Optional song title"
}
```

### Browser Compatibility
- Chrome/Edge: ✅ Full support
- Firefox: ✅ Full support
- Safari: ✅ Full support
- Internet Explorer: ❌ Not supported

## Tips for Best Results

1. **Use a dedicated browser window** for the projector in full-screen mode (F11)
2. **Test before service** - Run through a few songs to ensure everything works
3. **Keep operator and projector on same network** for best performance
4. **Use wired connection** for projector computer if possible
5. **Disable screen saver** on projector computer
6. **Set display to never sleep** on projector computer
7. **Bookmark the URLs** for quick access
8. **Pre-load songs** you'll use during the service

## Support and Customization

This is a simple, self-contained application. All files are included and can be modified to suit your needs.

For custom features or modifications:
- **HTML files** (`src/static/*.html`): Structure and content
- **CSS files** (`src/static/css/`): Styling and appearance  
- **JavaScript files** (`src/static/js/`): Functionality and behavior
- **Python files** (`src/server/`): Server and WebSocket communication

## Documentation & Resources

- 🚀 **[Local Deployment Guide](deployment/local/README.md)** - Run on your network
- 🐳 **[Docker Deployment Guide](deployment/docker/README.md)** - Containerized deployment
- ☁️ **[Azure Deployment Guide](deployment/azure/README.md)** - Deploy to cloud
- 📦 **[PyInstaller Build Guide](deployment/pyinstaller/README.md)** - Create standalone EXE
- 📘 **[Singlish Search Guide](docs/SINGLISH-SEARCH-GUIDE.md)** - Search in multiple languages
- 📋 **[Song Format Guide](docs/MULTI-LINE-SONG-FORMAT.md)** - Create and edit songs
- 📁 **[Project Structure](docs/PROJECT-STRUCTURE.md)** - Detailed file organization

## License

This application is provided as-is for church use. Feel free to modify and distribute.

## Version

Version 1.2 - 23-11-2025 (Restructured deployment methods)