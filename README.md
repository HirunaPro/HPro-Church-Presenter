# Church Presentation Web App

A simple, self-hosted web application for displaying song lyrics and simple slides during church worship services. Control content from an operator panel and display it on a projector in real-time using WebSocket communication.

---

## 🚀 Quick Start (TL;DR)

**First time:**
1. Install Python (with "Add to PATH" checked)
2. Open terminal in project folder
3. Run: `pip install websockets`

**Every time:**
1. Open terminal in project folder
2. Run: `python server.py`
3. Open browser → `http://localhost:8000/index.html`
4. Click "Open Operator Control" and "Open Projector Display"
5. Press F11 on projector for full-screen

**See [QUICK-START.md](QUICK-START.md) for detailed step-by-step guide.**

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
python3 server.py
```

## Deployment Options

### Option 1: Local Network (Recommended for On-Site)

Run on your local computer/network - perfect for on-site church services.

**See instructions below** in the "Usage" section.

### Option 2: Azure Container Instances (Recommended for Cloud) ⭐

**Full WebSocket Support** - Perfect for this app! Deploy to Azure Container Instances with native WebSocket support.

```powershell
# Windows - One command deploy
.\deploy-azure-container.ps1 -AppName "mychurch-app"

# Linux/Mac - One command deploy
./deploy-azure-container.sh --app-name "mychurch-app"
```

**Why Container Instances:**
- ✅ **Full WebSocket Support** - Native ws:// protocol support
- ✅ **Pay-per-second** - Only $0.57/month for weekly use (3hr/week)
- ✅ **No quota issues** - Different quota from App Service
- ✅ **Easy start/stop** - Save money when not in use
- ✅ **5-minute deployment** - Fast and simple

**Documentation:**
- 🚀 **Quick Start:** [docs/AZURE-CONTAINER-QUICKSTART.md](docs/AZURE-CONTAINER-QUICKSTART.md) - Deploy in 5 minutes
- 📘 **Full Guide:** [docs/AZURE-CONTAINER-DEPLOYMENT.md](docs/AZURE-CONTAINER-DEPLOYMENT.md) - Complete reference

**Pricing:**
- 3 hours/week (Sundays): **$0.57/month** ⭐
- 6 hours/week (Sun + Wed): **$1.14/month**
- 24/7: ~$35/month

### Option 3: Azure App Service (Alternative)

Deploy to Azure App Service (requires WebSocket configuration).

```powershell
# Windows - One command deploy
.\deploy-to-azure-v2.ps1 -AppName "mychurch-app"

# Linux/Mac - One command deploy  
./deploy-to-azure-v2.sh --app-name "mychurch-app"
```

**Features:**
- 🆓 **Free tier available** - $0/month (with limitations)
- ⚡ **Fast deployment** - 2-3 minutes
- 🌍 **Access from anywhere** - Internet-based
- 📊 **Cost optimization** - Start/stop scripts included

**Documentation:**
- 📘 **Quick Deploy:** [docs/AZURE-QUICK-DEPLOY.md](docs/AZURE-QUICK-DEPLOY.md)
- 📗 **Full Guide:** [docs/AZURE-DEPLOYMENT-V2.md](docs/AZURE-DEPLOYMENT-V2.md)

**Pricing:**
- Free (F1): $0/month - Limited (may have WebSocket issues)
- Basic (B1): ~$13/month (or $0.43/month with start/stop)
- Standard (S1): ~$69/month (auto-scaling, SSL)

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

Songs are stored as JSON files in the `songs/` directory.

### Song File Format (Multi-Line Verses)

The app now supports displaying multiple lines at once (4-6 lines per verse). Create a new `.json` file in the `songs/` folder:

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

**See [MULTI-LINE-SONG-FORMAT.md](MULTI-LINE-SONG-FORMAT.md) for detailed guide and examples.**

### Naming Convention
- Use lowercase letters
- Replace spaces with hyphens
- Example: `amazing-grace.json`

### Example

File: `songs/joyful-joyful.json`

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

Edit `js/operator.js` and find this line:

```javascript
const CHURCH_NAME = "Our Church"; // Configurable
```

Change `"Our Church"` to your church's name.

### Change Church Logo

Replace `images/church-logo.png` with your own logo image. Recommended size: 150x150 pixels.

### Modify Default Welcome Message

Edit `js/operator.js` and `js/projector.js` to change the default welcome message.

### Customize Slide Messages

In `js/operator.js`, find the slide button event handlers to modify default slide text:

```javascript
case 'welcome':
    content.text = `Welcome to ${CHURCH_NAME}`;
    break;
```

## Troubleshooting

### Connection Issues

**Operator shows "Disconnected"**
- Check that the server is running
- Verify the WebSocket port (8765) is not blocked by firewall
- Refresh the page

**Projector not receiving updates**
- Ensure both devices are on the same WiFi network
- Check the WebSocket connection in browser console (F12)
- Verify the IP address is correct

### Songs Not Loading

- Check that song files are in the `songs/` directory
- Verify JSON syntax is correct (use a JSON validator)
- Check browser console for errors (F12)
- Ensure song files have `.json` extension

### Python/Server Issues

**"Python is not recognized"**
- Install Python from python.org
- Make sure "Add to PATH" was checked during installation
- Restart your terminal/command prompt

**"Module 'websockets' not found"**
- Run: `pip install websockets`
- Or use the included `start.bat` which installs it automatically

**Port already in use**
- Change the port in `server.py`:
  ```python
  HTTP_PORT = 8000  # Change to different port
  WEBSOCKET_PORT = 8765  # Change to different port
  ```

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
├── index.html              # Landing page
├── operator.html           # Operator control interface
├── projector.html          # Projector display
├── server.py               # Python WebSocket server
├── start.bat               # Windows startup script
├── Requirements.md         # Project requirements
├── README.md              # This file
├── SINGLISH-SEARCH-GUIDE.md # Singlish search documentation
├── MULTI-LINE-SONG-FORMAT.md # Song format guide
├── css/
│   └── style.css          # Stylesheet
├── js/
│   ├── operator.js        # Operator control logic
│   ├── projector.js       # Projector display logic
│   └── transliteration.js # Singlish search module
├── images/
│   └── church-logo.png    # Church logo
└── songs/
    ├── amazing-grace.json
    ├── blessed-assurance.json
    ├── how-great-thou-art.json
    ├── ඔබ-දවය-පමල.json    # Sinhala song example
    └── என்-இயேசுவே.json    # Tamil song example
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
- HTML files: Structure and content
- CSS files: Styling and appearance  
- JavaScript files: Functionality and behavior
- Python files: Server and WebSocket communication

## License

This application is provided as-is for church use. Feel free to modify and distribute.

## Version

Version 1.0 - Created October 2025
