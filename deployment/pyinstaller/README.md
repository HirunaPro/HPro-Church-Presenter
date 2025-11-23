# PyInstaller Build - Windows Executable

This folder contains everything needed to build and distribute the Church Presentation App as a standalone Windows executable that requires **no Python installation** on client PCs.

## Quick Start

### Step 1: Build the Executable

**On your development PC with Python installed:**

```powershell
cd .\build
.\build-executable.ps1
```

**Wait 2-3 minutes** for the build to complete.

### Step 2: Test It

```powershell
# Navigate to the created package
cd ..\ChurchApp-Standalone

# Double-click START.bat
# Or run it from PowerShell:
.\START.bat
```

### Step 3: Distribute

1. **Zip** the `ChurchApp-Standalone` folder
2. **Share** the ZIP file with others
3. Users **extract** and **double-click START.bat**

**That's it!** No Python, no dependencies, no installation.

---

## Files in This Folder

### Build Scripts
- **`build-executable.ps1`** - Main build script
  - Installs PyInstaller (one-time)
  - Builds the standalone executable
  - Creates distribution package
  - Includes all app files (songs, CSS, JS, images)

### Configuration Files
- **`SETUP.bat`** - End-user setup script
  - Detects network IP address
  - Creates desktop shortcut
  - Helps with firewall configuration

### Documentation
- **`PYINSTALLER-GUIDE.md`** - Complete technical guide
  - Detailed build instructions
  - Distribution methods (ZIP, USB, network)
  - Troubleshooting and firewall setup
  - Advanced configuration

- **`QUICK-START-EXECUTABLE.txt`** - User-friendly quick start
  - 2-minute setup for end users
  - Simple instructions
  - Common problems and solutions

---

## What Gets Created

When you run `build-executable.ps1`, you'll get:

```
ChurchApp-Standalone/          (Ready to distribute!)
├── Church-Presentation-Server.exe    (Standalone executable - NO PYTHON!)
├── START.bat                         (Double-click to run)
├── CONFIGURE-FIREWALL.bat            (Firewall setup for remote access)
├── README.txt                        (User instructions)
├── config.json                       (Configuration template)
├── songs/                            (Song database)
├── css/                              (Stylesheets)
├── js/                               (JavaScript files)
├── images/                           (Logo and images)
├── index.html                        (Landing page)
├── operator.html                     (Operator control)
├── projector.html                    (Projector display)
└── welcome.html                      (Welcome page)
```

**Total Size:** ~100-120 MB (includes everything)

---

## System Requirements (For Building)

- **Windows PC** with Python 3.7+ installed
- **PowerShell** (comes with Windows)
- **~500 MB** free disk space for build

### Prerequisites
1. Install Python from [python.org](https://www.python.org/downloads)
   - ✅ Check "Add Python to PATH" during installation
   - ✅ Check "Install pip" during installation

2. Install required packages:
   ```powershell
   pip install websockets pyinstaller
   ```

---

## Distribution Options

### Option 1: ZIP File (Recommended)

1. Run `build-executable.ps1`
2. Right-click `ChurchApp-Standalone` → "Send to" → "Compressed (zipped) folder"
3. Share the `.ZIP` file via:
   - Email
   - USB drive
   - Network drive
   - File sharing service (Google Drive, OneDrive, etc.)

### Option 2: USB Drive

1. Copy entire `ChurchApp-Standalone` folder to USB
2. Give USB to other users
3. Users copy folder to their PC and run `START.bat`

### Option 3: Network Share

1. Share `ChurchApp-Standalone` on your network
2. Create shortcut to `START.bat` on other PCs
3. Users can run directly from network

---

## Network Setup

### For End Users

**To access the app from another computer:**

1. **Configure Firewall (Important!):**
   - Right-click `CONFIGURE-FIREWALL.bat` in the ChurchApp-Standalone folder
   - Select "Run as administrator"
   - Wait for completion message
   - ✅ Firewall is now configured for remote access

2. **Get server IP address:**
   - On server PC: Open Command Prompt → `ipconfig`
   - Look for "IPv4 Address" (e.g., `192.168.1.100`)

3. **Access from other PC:**
   - Open browser
   - Go to: `http://192.168.1.100:8000`
   - Or: `http://[server-ip]:8000/projector.html` for projector

**Important:** Both computers must be on the same WiFi network.

---

## Firewall Configuration

If users can't connect from other PCs:

**Automatic Configuration (Easiest):**

1. Right-click `CONFIGURE-FIREWALL.bat` 
2. Select "Run as administrator"
3. Wait for success message
4. Done! Both ports (8000 and 8765) are now allowed

**What it does:**
- ✅ Allows HTTP traffic (port 8000) through firewall
- ✅ Allows WebSocket traffic (port 8765) through firewall
- ✅ Creates rules for the Church-Presentation-Server.exe

**Manual Configuration:**

If you prefer manual setup:

1. Open **Windows Defender Firewall**
2. Click **"Allow an app through firewall"**
3. Click **"Allow another app"** button
4. **Browse** to `Church-Presentation-Server.exe`
5. Check **both "Private" and "Public"**
6. Click **OK**

---

## Troubleshooting

### Build Issues

**Error: "Python is not installed"**
- Install Python from python.org
- Make sure "Add to PATH" was checked
- Restart PowerShell

**Error: "PyInstaller not found"**
- Run: `pip install pyinstaller`
- Try the build script again

**Build takes too long (>10 minutes)**
- This is normal for first build (2-3 min is typical)
- Check antivirus isn't scanning during build
- Try running PowerShell as Administrator

### Runtime Issues

**"Windows cannot find Church-Presentation-Server.exe"**
- Make sure all files are in the same folder
- Don't move the `.exe` away from `songs/`, `css/`, `js/`, `images/`
- Re-extract the ZIP file

**"Port 8000 already in use"**
- Another app is using port 8000
- Close other applications
- Or edit `server.py` to use different port (8001, 8002, etc.)

**Can't connect from other computers**
- Check both on same WiFi network
- Verify using correct IP address
- Check Windows Firewall (see above)
- Disable VPN if using one
- Try using server IP directly: `http://192.168.x.x:8000`

### WebSocket Connection Fails

If projector shows "Disconnected":

1. **Check firewall** allows ports 8000 and 8765
2. **Restart** the server (close and run START.bat again)
3. **Try different browser** (Chrome/Edge recommended)
4. **Check network** isn't blocking WebSocket connections (school/corporate WiFi)

---

## Advanced: Rebuild for Changes

If you modify the app (add songs, change settings, etc.):

### Option A: Just Update Songs (Easiest)

1. Update songs in `ChurchApp-Standalone/songs/` folder
2. Restart the server
3. No rebuild needed!

### Option B: Modify Source and Rebuild

1. Edit source files (HTML, CSS, JS, Python, etc.)
2. Run `.\build-executable.ps1` again
3. Creates new `ChurchApp-Standalone` with changes
4. Test and distribute the new version

### Option C: Update Specific Files

Edit files in already-built `ChurchApp-Standalone/`:
- `js/` - Update JavaScript
- `css/` - Update styles
- `songs/` - Add songs
- HTML files - Update pages
- `config.json` - Change settings

---

## Version Management

Keep multiple versions:

```
Backup/
├── ChurchApp-Standalone-v1.0/
├── ChurchApp-Standalone-v1.1/
├── ChurchApp-Standalone-v2.0/
└── ...
```

This lets you roll back if needed.

---

## Performance Notes

- **File Size:** ~100-120 MB (self-contained)
- **Memory Usage:** ~80-150 MB while running
- **CPU Usage:** Minimal (idle most of time)
- **Network Bandwidth:** Very low (only WebSocket messages)
- **Concurrent Users:** Supports 50+ simultaneous connections

---

## Pricing Comparison

### Standalone (This Method)
- **Cost:** $0 - runs on your PC
- **Setup:** ~10 minutes
- **Network:** Local/WiFi only
- **Reliability:** Depends on your PC/WiFi
- **Best for:** On-site church services

### Azure Cloud Deployment
- **Cost:** $0.57-$35/month depending on usage
- **Setup:** ~5 minutes
- **Network:** Works anywhere with internet
- **Reliability:** Professional 99.95% SLA
- **Best for:** Remote/multiple locations

See `../azure/README.md` for cloud deployment options.

---

## Security Note

⚠️ **Local Network Only**

This standalone app:
- ✅ Runs completely offline
- ✅ Works on private WiFi networks
- ⚠️ Has no authentication
- ⚠️ Not encrypted
- ⚠️ Not suitable for internet exposure

For **public internet access**, use Azure deployment (see `../azure/README.md`).

---

## Next Steps

1. **Build:** Run `.\build-executable.ps1`
2. **Test:** Double-click `ChurchApp-Standalone\START.bat`
3. **Verify:** Check operator and projector panels work
4. **Distribute:** Zip and share `ChurchApp-Standalone` folder
5. **Support:** Give users `QUICK-START-EXECUTABLE.txt` and `README.txt`

---

## Support

- **Build help:** See `PYINSTALLER-GUIDE.md`
- **User help:** See `QUICK-START-EXECUTABLE.txt`
- **General help:** See `../README.md`
- **Cloud deployment:** See `../azure/README.md`

---

**Version 1.0** - Nov 2025
