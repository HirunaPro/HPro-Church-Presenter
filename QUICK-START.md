# 🚀 Quick Start Guide - Church Presentation App

## First Time Setup (Do Once)

### Step 1: Install Python
1. Download Python from https://www.python.org/downloads/
2. **Important:** Check "Add Python to PATH" during installation
3. Restart your computer after installation

### Step 2: Install Required Package
1. Open Command Prompt or Terminal
2. Navigate to the project folder:
   ```bash
   cd D:\_Personal\Project\PresentationApp
   ```
3. Install websockets:
   ```bash
   pip install websockets
   ```

---

## Every Time You Want to Use the App

### Method 1: Using Command Line (RECOMMENDED)

1. **Open Command Prompt or Terminal**
   - Windows: Press `Win + R`, type `cmd`, press Enter
   - Or right-click in the PresentationApp folder → "Open in Terminal"

2. **Navigate to the project folder** (if not already there):
   ```bash
   cd D:\_Personal\Project\PresentationApp
   ```

3. **Start the server**:
   ```bash
   python server.py
   ```

4. **You'll see this output:**
   ```
   ============================================================
     Church Presentation Web App Server
   ============================================================
   
   Access the application at:
     http://10.58.14.60:8000/index.html
   
   ============================================================
   HTTP Server running on:
     - http://localhost:8000
     - http://10.58.14.60:8000
   
   WebSocket Server running on:
     - ws://localhost:8765
     - ws://10.58.14.60:8765
   ============================================================
   ```

5. **Open your web browser** and go to:
   - On the same computer: `http://localhost:8000/index.html`
   - On other devices (same WiFi): `http://10.58.14.60:8000/index.html` (use YOUR IP address)

6. **Click the buttons:**
   - "Open Operator Control" - for controlling the presentation
   - "Open Projector Display" - for the projector screen

7. **To stop the server:**
   - Press `Ctrl + C` in the terminal

---

### Method 2: Using Batch File (Windows Only)

1. **Double-click `start.bat`** in the PresentationApp folder
2. A window will open and start the servers automatically
3. Follow the URLs shown in the window

**Note:** If you see errors, use Method 1 instead.

---

## Using the Application

### On the Host Computer (Your Laptop)

1. **Open Operator Control:**
   - Go to: `http://localhost:8000/operator.html`
   - You should see "Connected" (green) in the top left

2. **Control the presentation:**
   - Search and select songs
   - Click phrases to display them
   - Change font sizes
   - Show simple slides (Welcome, Prayer, etc.)
   - Enter custom text/Bible verses

### On the Projector Computer

1. **Open Projector Display:**
   - Go to: `http://YOUR-IP:8000/projector.html`
   - Replace `YOUR-IP` with the IP shown when server started
   - Example: `http://10.58.14.60:8000/projector.html`

2. **Press F11** for full-screen mode

3. **That's it!** Whatever you select on the operator page will appear here

---

## Troubleshooting

### "Disconnected" showing on Operator page?
- Make sure the server is running (`python server.py`)
- Refresh the browser page
- Check that no firewall is blocking ports 8000 and 8765

### Songs not showing?
- Make sure `.json` files are in the `songs/` folder
- Refresh the operator page
- Check browser console (F12) for errors

### Can't connect from another device?
- Both devices must be on the same WiFi network
- Use the IP address shown when server starts (not localhost)
- Check firewall settings

### Port already in use error?
- Another instance of the server is running
- Close all Python processes:
  - Windows Task Manager → Find Python → End Task
  - Or run: `taskkill /F /IM python.exe` in Command Prompt
- Try starting the server again

### Server won't start?
- Make sure you're in the correct folder: `D:\_Personal\Project\PresentationApp`
- Make sure Python is installed: `python --version`
- Make sure websockets is installed: `pip install websockets`

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start Server | `python server.py` |
| Stop Server | Press `Ctrl + C` |
| Install Package | `pip install websockets` |
| Check Python | `python --version` |
| Operator URL | `http://localhost:8000/operator.html` |
| Projector URL | `http://YOUR-IP:8000/projector.html` |
| Full Screen | Press `F11` |

---

## Tips

✅ Keep the terminal window open while using the app
✅ Use a wired connection for the projector if possible
✅ Test everything before the service starts
✅ Bookmark the URLs in your browser for quick access
✅ Keep the operator computer on the same WiFi as the projector

---

## Need Help?

1. Check the main README.md for detailed documentation
2. Look at the terminal output for error messages
3. Press F12 in your browser to see console errors
4. Make sure all files are in the correct folders

---

**Last Updated:** October 4, 2025
