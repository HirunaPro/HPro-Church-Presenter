# Project Structure Documentation

Complete guide to the Church Presentation App directory structure after reorganization.

## Overview

The project is organized into three main sections:

1. **src/** - Application source code
2. **deployment/** - Deployment method-specific files
3. **docs/** - Documentation
4. **Root files** - Configuration and startup scripts

---

## Directory Structure

```
PresentationApp/
│
├── src/                              # Application source code
│   ├── static/                       # Web interface files
│   │   ├── index.html               # Landing page (entry point)
│   │   ├── operator.html            # Operator control interface
│   │   ├── projector.html           # Projector display view
│   │   ├── welcome.html             # Welcome page template
│   │   ├── css/
│   │   │   └── style.css            # Stylesheet for all pages
│   │   ├── js/
│   │   │   ├── operator.js          # Operator control logic
│   │   │   ├── projector.js         # Projector display logic
│   │   │   └── transliteration.js   # Singlish search module
│   │   └── images/
│   │       └── church-logo.png      # Church logo (customizable)
│   │
│   ├── server/                       # Server-side code
│   │   ├── server.py                # Main WebSocket & HTTP server
│   │   │                            # - Handles file serving
│   │   │                            # - WebSocket communication
│   │   │                            # - Song management API
│   │   └── server-optimized.py      # Optimized version for Azure
│   │                                # - Gzip compression
│   │                                # - Aggressive caching
│   │                                # - Better Azure performance
│   │
│   └── songs/                        # Song library (JSON files)
│       ├── amazing-grace.json       # Song format: multi-line verses
│       ├── blessed-assurance.json
│       ├── how-great-thou-art.json
│       ├── ඔබ-දවය-පමල.json          # Example: Sinhala song
│       └── என்-இயேசுவே.json           # Example: Tamil song
│
├── deployment/                       # Deployment method files
│   ├── local/                        # Local network deployment
│   │   └── README.md                # Local deployment guide
│   │
│   ├── azure/                        # Azure Cloud deployment
│   │   ├── README.md                # Azure deployment guide
│   │   ├── deploy-azure-container.ps1
│   │   ├── deploy-azure-container.sh
│   │   ├── azure-start.ps1
│   │   ├── azure-start.sh
│   │   ├── azure-stop.ps1
│   │   ├── azure-stop.sh
│   │   ├── register-azure-providers.ps1
│   │   ├── register-azure-providers.sh
│   │   ├── server-azure.py          # Azure-specific server config
│   │   ├── web.config               # IIS configuration
│   │   └── ... (other Azure files)
│   │
│   └── pyinstaller/                  # Windows executable build
│       ├── README.md                # PyInstaller build guide
│       ├── build-executable.ps1     # PowerShell build script
│       ├── PYINSTALLER-GUIDE.md     # Detailed build guide
│       ├── QUICK-START-EXECUTABLE.txt
│       └── ... (build artifacts)
│
├── docs/                             # Documentation files
│   ├── PROJECT-STRUCTURE.md         # This file
│   ├── QUICK-START.md               # Getting started guide
│   ├── SINGLISH-SEARCH-GUIDE.md    # Singlish search documentation
│   ├── MULTI-LINE-SONG-FORMAT.md   # Song format specification
│   ├── SONG-EDIT-FEATURE.md        # Song editing guide
│   ├── MOBILE-RESPONSIVE-REDESIGN.md
│   ├── DOCKER-TROUBLESHOOTING.md
│   ├── PERFORMANCE-OPTIMIZATION.md
│   └── ... (other documentation)
│
├── build/                            # PyInstaller build outputs
│   ├── build-executable.ps1         # Build script (copy in deployment/)
│   ├── dist/                        # Compiled executable output
│   │   └── ChurchApp.exe            # Standalone Windows executable
│   ├── build/                       # Build temporary files
│   └── ... (PyInstaller artifacts)
│
├── build-dist/                       # Build distribution
│   ├── Church-Presentation-Server.spec
│   └── build/
│
├── ChurchApp-Standalone/             # Example standalone package
│   └── ChurchApp.exe
│
├── .git/                             # Git repository
├── .gitignore                        # Git ignore rules
├── .dockerignore                     # Docker ignore rules
│
├── Dockerfile                        # Docker container definition
├── docker-compose.yml                # Docker Compose configuration
│
├── start.bat                         # Windows startup script
├── startup.sh                        # Linux/macOS startup script
│
├── requirements.txt                  # Python dependencies
├── runtime.txt                       # Runtime specification
│
├── README.md                         # Main project README
└── [other config files]
```

---

## Key Directories Explained

### src/static/ (Web Interface)

Contains all files served to the web browser:

- **HTML Files**: Interface structure
  - `index.html` - Landing page with access buttons
  - `operator.html` - Operator control panel
  - `projector.html` - Full-screen projector display
  - `welcome.html` - Welcome template

- **CSS** (`css/style.css`)
  - Single stylesheet for all pages
  - Responsive design
  - Dark theme suitable for projectors

- **JavaScript** (`js/`)
  - `operator.js` - Song selection, controls, settings
  - `projector.js` - Display rendering, WebSocket listener
  - `transliteration.js` - Singlish search (Sinhala/Tamil romanization)

- **Images** (`images/`)
  - `church-logo.png` - Customizable logo

### src/server/ (Backend)

Server-side Python code:

- **server.py**
  - HTTP server (port 8000)
  - WebSocket server (port 8765)
  - File serving from static/
  - Song management API endpoints
  - JSON upload/download

- **server-optimized.py**
  - Azure-optimized version
  - Gzip compression
  - Aggressive caching
  - Better performance metrics

### src/songs/ (Song Library)

JSON files containing song data:

- **Format**: One file per song
- **Naming**: lowercase-with-hyphens.json
- **Content**: Title + multi-line verses
- **Languages**: Supports Sinhala, Tamil, English

### deployment/

Separated by deployment method:

- **local/** - Local network instructions
- **azure/** - Cloud deployment scripts
- **pyinstaller/** - Windows executable creation

### docs/

Comprehensive documentation:

- Getting started guides
- Technical specifications
- Troubleshooting guides
- Feature documentation

---

## File Paths Reference

### When Running from src/static/

HTML files are served from `src/static/`:

```
URL: http://localhost:8000/index.html
FILE: src/static/index.html

URL: http://localhost:8000/css/style.css
FILE: src/static/css/style.css

URL: http://localhost:8000/js/operator.js
FILE: src/static/js/operator.js
```

### When Running from src/server/

Server reads from relative paths:

```
Python Working Dir: src/static/
Serving From: src/static/ (all HTML, CSS, JS, images)
Songs From: ../songs/ (relative to server.py)
Actual Path: src/songs/
```

### Song File Access

Songs are accessible via HTTP API:

```
URL: http://localhost:8000/songs/
Response: JSON list of song files

URL: http://localhost:8000/songs/amazing-grace.json
Response: Song JSON data
```

---

## Configuration Files

### Root Level

| File | Purpose |
|------|---------|
| `README.md` | Main project documentation |
| `requirements.txt` | Python dependencies |
| `start.bat` | Windows quick start |
| `startup.sh` | Linux/macOS quick start |
| `Dockerfile` | Docker container definition |
| `docker-compose.yml` | Multi-container orchestration |
| `.gitignore` | Git repository rules |
| `.dockerignore` | Docker build rules |

### In Deployment Folders

- **local/README.md** - How to set up local network
- **azure/README.md** - How to deploy to Azure
- **pyinstaller/README.md** - How to build Windows .exe

---

## Server Ports

| Port | Service | Purpose |
|------|---------|---------|
| 8000 | HTTP | Web interface access |
| 8765 | WebSocket | Real-time operator→projector communication |

Can be changed via environment variables:
```bash
HTTP_PORT=8080
WEBSOCKET_PORT=8766
```

---

## Data Flow

### Application Startup

```
1. Start: python src/server/server.py
2. HTTP Server: Serves src/static/* on port 8000
3. WebSocket Server: Listens on port 8765
4. Browser Access: http://localhost:8000/index.html
```

### Operator to Projector

```
1. Operator selects song in operator.html
2. JavaScript sends WebSocket message
3. Server forwards to all connected projectors
4. Projector displays the content
```

### Song Management

```
1. Operator uploads/edits songs via UI
2. HTTP POST to /api/save-songs or /api/update-song
3. Server saves to src/songs/
4. All clients notified to refresh song list
```

---

## Environment Variables

```bash
# HTTP Server
HTTP_PORT=8000          # Default: 8000
PYTHONUNBUFFERED=1      # Enable unbuffered output

# WebSocket Server
WEBSOCKET_PORT=8765     # Default: 8765

# Azure specific
PORT=8000               # Azure override for HTTP_PORT
```

---

## Docker Structure

### Build Process

```
Dockerfile:
├── Builder Stage
│   └── Install Python packages
├── Final Stage
│   ├── Copy packages
│   ├── Copy src/ (application)
│   ├── Copy deployment/ (scripts)
│   └── Run: python src/server/server-optimized.py
```

### Volume Mounts

```yaml
volumes:
  - ./src/songs:/app/src/songs  # Mount songs for easy updates
```

---

## Important Notes

### Path Dependencies

1. **Server Working Directory**: Must be `src/static/`
   - This is set in server.py: `os.chdir(STATIC_DIR)`
   - Ensures relative paths work correctly

2. **Song Directory**: Must be accessible as `../songs/`
   - Relative to `src/static/` → `src/songs/`

3. **HTML Relative Paths**: Are relative to `src/static/`
   ```html
   <link rel="stylesheet" href="css/style.css">
   <script src="js/operator.js"></script>
   ```

### Build Consistency

When using PyInstaller or Docker:

1. Always include the `src/` directory
2. Songs need to be bundled or mounted
3. Static files must be accessible

---

## Customization Paths

### Add Custom Logo

```
Replace: src/static/images/church-logo.png
New file: Your logo (150x150px recommended)
```

### Add New Song

```
Create: src/songs/my-song.json
Format: Multi-line verse JSON
```

### Customize Styling

```
Edit: src/static/css/style.css
Reload: Browser (clears cache if needed)
```

### Add New Features

```
Edit: src/static/js/operator.js or projector.js
Server endpoint: src/server/server.py
```

---

## Deployment Differences

### Local Network
- No Docker needed
- Python installed on server PC
- Run: `python src/server/server.py`

### Azure Container
- Docker image required
- Runs in cloud
- Port 8000 exposed
- Uses `server-optimized.py`

### Windows Executable
- PyInstaller bundles Python
- Single .exe file
- No additional installation
- Portable across Windows PCs

---

## Migration Notes

### From Old Structure

Old → New mapping:
```
server.py → src/server/server.py
server-optimized.py → src/server/server-optimized.py
*.html → src/static/*.html
css/ → src/static/css/
js/ → src/static/js/
images/ → src/static/images/
songs/ → src/songs/
azure/ → deployment/azure/
build/ → deployment/pyinstaller/
```

### Startup Script Changes

```bash
# Old
python server.py

# New
python src/server/server.py
```

---

## Troubleshooting

### Module Not Found
- Ensure songs directory is at: `src/songs/`
- Check relative paths in server.py

### Files Not Serving
- Verify server working directory: `src/static/`
- Check file paths in HTML (should be relative)

### Songs Not Loading
- Check `/songs/` endpoint is returning files
- Verify songs are in `src/songs/`
- Check JSON format is valid

### Port Issues
- Ensure ports 8000, 8765 not in use
- Use environment variables to change ports
- Check firewall settings

---

## Next Steps

- [Read Main README](../README.md)
- [Local Deployment Guide](../deployment/local/README.md)
- [Azure Deployment Guide](../deployment/azure/README.md)
- [PyInstaller Build Guide](../deployment/pyinstaller/README.md)
