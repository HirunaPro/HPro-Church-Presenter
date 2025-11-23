# Church Presentation App - Distribution Guide

## Overview

This guide explains how to package and distribute the Church Presentation App as a standalone Windows executable that requires **no Python installation** on client PCs.

---

## Step 1: Build the Executable (On Your Server PC)

### Prerequisites
- Windows PC with Python 3.7+ installed
- Your PresentationApp project folder

### Build Process

1. **Open PowerShell as Administrator**
   - Right-click PowerShell → "Run as Administrator"
   - Navigate to your project: `cd d:\_Personal\Project\PresentationApp`

2. **Run the build script**
   ```powershell
   .\build-executable.ps1
   ```

3. **Wait for completion** (2-3 minutes)
   - PyInstaller will build your exe
   - A `ChurchApp-Standalone` folder will be created
   - Total size: ~100-120 MB

### What Gets Created

```
ChurchApp-Standalone/
├── Church-Presentation-Server.exe    (The executable - NO PYTHON NEEDED)
├── START.bat                          (Easy launcher)
├── README.txt                         (Quick instructions)
├── config.json                        (Configuration file)
├── songs/                             (Song database)
├── css/                               (Stylesheets)
├── js/                                (JavaScript)
├── images/                            (Logo and images)
└── *.html                             (Web pages)
```

---

## Step 2: Test the Executable

1. **Double-click `START.bat`** in the ChurchApp-Standalone folder
2. Watch the console window
3. Your browser should open automatically to `http://localhost:8000`
4. Test the operator panel and projector display

---

## Step 3: Distribute to Other PCs

### Option A: Zip File (Recommended)

1. **Right-click** the `ChurchApp-Standalone` folder
2. **Select** "Send to" → "Compressed (zipped) folder"
3. **Share** the ZIP file via:
   - USB drive
   - Email
   - Network drive
   - File sharing service

### Option B: USB Drive

1. **Copy** the entire `ChurchApp-Standalone` folder to USB
2. **Give** the USB to other users
3. Users copy folder to their PC and run START.bat

### Option C: Network Share

1. **Share** the `ChurchApp-Standalone` folder on your network
2. **Create shortcut** on other PCs pointing to START.bat
3. Users can run directly from network

---

## Step 4: Installation on Client PCs

### For End Users (Non-Technical)

**Just 3 steps:**

1. **Extract** the ZIP file (or copy from USB) to a folder
2. **Double-click** `START.bat`
3. **Enjoy!** The app opens automatically

**That's it!** No Python, no pip, no terminal commands needed.

### For Network Setup

Users need to know your server's IP address:

1. On **your server PC**, open Command Prompt:
   ```cmd
   ipconfig
   ```

2. Look for **IPv4 Address** (e.g., `192.168.1.100`)

3. Share this address with users

4. They access via: `http://192.168.1.100:8000`

---

## Step 5: Adding Songs to Distributed Version

### Option 1: Update and Rebuild

1. Add new songs to `songs/` folder on your development PC
2. Run `build-executable.ps1` again
3. Distribute the new `ChurchApp-Standalone` folder

### Option 2: Users Add Their Own Songs

1. Users can add `.json` files to the `songs/` folder in their ChurchApp-Standalone directory
2. Restart the server (close and run START.bat again)
3. Refresh the browser

---

## Firewall Configuration

If users on other PCs **can't connect**:

### Windows Defender Firewall Setup

1. **Open** Windows Defender Firewall
2. **Click** "Allow an app through firewall"
3. **Click** "Allow another app" button
4. **Browse** to `Church-Presentation-Server.exe`
5. **Check** both "Private" and "Public" networks
6. **Click** OK

### Alternative: Disable Firewall (Not Recommended)

⚠️ **Security Risk** - Only if firewall blocking access:

```cmd
netsh advfirewall set allprofiles state off
```

To re-enable:
```cmd
netsh advfirewall set allprofiles state on
```

---

## Troubleshooting

### Issue: "Windows cannot find Church-Presentation-Server.exe"

**Solutions:**
1. Check all files are in same folder
2. Don't move .exe away from songs/css/js/images folders
3. Re-extract the ZIP file
4. Rebuild the executable with `build-executable.ps1`

### Issue: "Port 8000 already in use"

**Solutions:**
1. Check if another instance is running
2. Close the server window and restart
3. Check for other apps using port 8000
4. Edit `server.py` to use different port (e.g., 8001)

### Issue: "Can't connect from other computers"

**Checklist:**
- ✓ Both PCs on same WiFi network?
- ✓ Using correct IP address?
- ✓ Server is running (console window open)?
- ✓ Firewall allows the app?
- ✓ No VPN or network restrictions?

**Debug:**
1. On server PC, open Command Prompt:
   ```cmd
   ipconfig
   ```
   Copy the IPv4 Address

2. On client PC, test connection:
   ```cmd
   ping <server-ip>
   ```

3. Try accessing in browser:
   ```
   http://<server-ip>:8000
   ```

### Issue: WebSocket Connection Fails

The app uses WebSocket on port 8765. If it fails:

1. **Check firewall** allows both ports 8000 and 8765
2. **Check network** isn't blocking WebSocket connections
3. **Restart** the server
4. **Try different browser** (Chrome/Edge recommended)

---

## Advanced Configuration

### Change Server Port

1. **Extract** the ZIP file
2. **Open** command prompt in folder
3. **Run:**
   ```cmd
   Church-Presentation-Server.exe --port 9000
   ```

4. **Access via:** `http://localhost:9000`

### Change Church Name

Edit `js/operator.js` before building:

```javascript
const CHURCH_NAME = "Your Church Name";
```

Then rebuild the executable.

### Custom Logo

Replace `images/church-logo.png` with your own image before rebuilding.

---

## Performance Notes

- **File Size:** ~100-120 MB (includes everything)
- **Memory Usage:** ~80-150 MB while running
- **CPU Usage:** Minimal (mostly idle)
- **Network:** Works on slow WiFi (only WebSocket messages)
- **Concurrent Users:** Supports 50+ simultaneous connections

---

## Backup & Updates

### Backup Your Setup

1. **Zip** the entire `ChurchApp-Standalone` folder
2. **Store** on external drive or cloud storage
3. **Keep** multiple versions dated (v1, v2, etc.)

### Update Process

1. **Get latest** project files
2. **Run** `build-executable.ps1` again
3. **Distribute** new ChurchApp-Standalone folder
4. Users replace old folder with new one

---

## Security Considerations

⚠️ **Important:**

- App runs on **local network only** (no internet exposure)
- **No authentication** - anyone on network can access
- **No data encryption** - WebSocket messages unencrypted
- **For local/private networks only**

For public internet deployment, consider:
- Adding authentication
- Using HTTPS/WSS encryption
- Azure Container deployment (from README)

---

## Support & Help

### Common Questions

**Q: Do I need Python on client PCs?**
A: No! The executable includes everything needed.

**Q: Can I modify the app?**
A: Yes! Edit source files and rebuild with `build-executable.ps1`.

**Q: How many people can use it?**
A: Tested with 50+ simultaneous connections. Should handle typical church needs.

**Q: Can I use it without WiFi?**
A: Yes! Use USB cable or shared monitor. Or set up static IP.

**Q: What about Macs/Linux?**
A: PyInstaller exe is Windows-only. Use Docker or original Python setup for other OS.

---

## Version History

- **v1.0** (Nov 2025) - Initial standalone executable release

---

For detailed feature documentation, see the original README.md.
