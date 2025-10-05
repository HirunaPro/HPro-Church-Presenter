# Docker Desktop Troubleshooting Guide

## ❌ Error: "The system cannot find the file specified" or "Docker is not running"

This guide helps you fix Docker-related deployment issues.

---

## 🔍 The Problem

When you see errors like:
```
ERROR: error during connect: Head "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/_ping": 
open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
```

Or:
```
❌ Docker is not running!
```

This means **Docker Desktop is not running** on your computer.

---

## ✅ Solution (Step-by-Step)

### Step 1: Check if Docker Desktop is Installed

**Windows:**
1. Press `Win` key and type "Docker Desktop"
2. If you see it, go to Step 2
3. If not, go to "Installing Docker Desktop" section below

### Step 2: Start Docker Desktop

**Method 1: Using Start Menu**
1. Press `Win` key
2. Type "Docker Desktop"
3. Click on "Docker Desktop" to open it
4. Wait for it to start (this can take 1-2 minutes)

**Method 2: Using Desktop Shortcut**
1. Find Docker Desktop icon on your desktop
2. Double-click to start it
3. Wait for it to fully start

### Step 3: Verify Docker is Running

**Look for the Whale Icon:**
1. Check your system tray (bottom-right of Windows taskbar)
2. Look for a **whale icon** 🐋
3. When Docker is running, the icon should be steady (not animated)

**Test in PowerShell:**
```powershell
# Open PowerShell and run:
docker ps

# You should see output like:
# CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

# If you see an error, Docker is not ready yet - wait a bit longer
```

### Step 4: Run Deployment Again

Once Docker is running:
```powershell
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```

---

## 🆕 Installing Docker Desktop (If Not Installed)

### Windows 10/11

1. **Download Docker Desktop:**
   - Go to: https://www.docker.com/products/docker-desktop
   - Click "Download for Windows"
   - Or direct link: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe

2. **Install:**
   - Run the downloaded installer
   - Check "Use WSL 2 instead of Hyper-V" (recommended)
   - Click "Ok"
   - Wait for installation to complete

3. **Restart Computer:**
   - **Important:** Restart your computer after installation
   - Docker Desktop won't work properly until you restart

4. **First Launch:**
   - After restart, Docker Desktop should start automatically
   - If not, launch it from Start Menu
   - Accept the terms and conditions
   - Wait for Docker to finish initializing (can take 2-3 minutes)

5. **Verify Installation:**
   ```powershell
   # Open PowerShell and run:
   docker --version
   # Should show: Docker version 24.x.x or similar
   
   docker ps
   # Should show an empty list (no containers yet)
   ```

---

## 🔧 Common Issues & Fixes

### Issue 1: "Docker Desktop is starting..." (Taking Forever)

**Symptoms:**
- Docker Desktop shows "Starting..." for more than 5 minutes
- Whale icon keeps animating

**Fix:**
1. **Restart Docker Desktop:**
   - Right-click whale icon in system tray
   - Click "Quit Docker Desktop"
   - Wait 30 seconds
   - Start Docker Desktop again

2. **Restart Computer:**
   - If restart Docker doesn't work, restart your computer
   - Start Docker Desktop after restart

3. **Check for Updates:**
   - Right-click whale icon
   - Click "Check for updates"
   - Install any available updates

### Issue 2: "WSL 2 installation is incomplete"

**Fix:**
1. **Install WSL 2:**
   ```powershell
   # Open PowerShell as Administrator and run:
   wsl --install
   
   # Or update WSL:
   wsl --update
   ```

2. **Restart Computer**

3. **Start Docker Desktop again**

### Issue 3: "Virtualization is not enabled"

**Symptoms:**
- Error about virtualization or Hyper-V

**Fix:**
1. **Enable Virtualization in BIOS:**
   - Restart computer
   - Press F2, F10, F12, or DEL during boot (depends on your computer)
   - Find "Virtualization Technology" or "VT-x" or "AMD-V"
   - Enable it
   - Save and exit BIOS

2. **Enable Hyper-V (Windows):**
   ```powershell
   # Open PowerShell as Administrator and run:
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
   
   # Restart computer
   ```

### Issue 4: Docker Desktop Won't Start

**Fix 1: Reset Docker Desktop**
1. Right-click whale icon in system tray
2. Click "Troubleshoot"
3. Click "Reset to factory defaults"
4. Wait for reset to complete
5. Start Docker Desktop

**Fix 2: Reinstall Docker Desktop**
1. Uninstall Docker Desktop from Windows Settings
2. Restart computer
3. Download fresh installer from docker.com
4. Install again
5. Restart computer

### Issue 5: "docker: command not found" in PowerShell

**Fix:**
1. **Close and reopen PowerShell**
   - Docker path needs to be loaded

2. **Check PATH environment variable:**
   ```powershell
   # Check if Docker is in PATH
   $env:Path -split ';' | Select-String -Pattern "Docker"
   
   # Should show: C:\Program Files\Docker\Docker\resources\bin
   ```

3. **Add Docker to PATH manually:**
   - Open System Properties → Environment Variables
   - Edit "Path" variable
   - Add: `C:\Program Files\Docker\Docker\resources\bin`
   - Click OK
   - Restart PowerShell

---

## 🎯 Quick Checklist

Before running deployment, verify:

- [ ] Docker Desktop is installed
- [ ] Computer has been restarted after Docker installation
- [ ] Docker Desktop is running (whale icon in system tray)
- [ ] Whale icon is steady, not animating
- [ ] `docker ps` command works in PowerShell
- [ ] `docker --version` shows version number

---

## 🚀 Alternative: Test Locally First

If you're having persistent Docker issues, test with a simpler command first:

```powershell
# Test Docker with a simple container
docker run hello-world

# If this works, Docker is properly configured
# Then try the deployment again
```

---

## 💡 Pro Tips

### 1. Make Docker Start Automatically
1. Right-click whale icon
2. Click "Settings"
3. Check "Start Docker Desktop when you log in"
4. Click "Apply & Restart"

### 2. Check Docker Status Quickly
```powershell
# Create a quick status check script
# Save as check-docker.ps1:

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "✅ Docker installed" -ForegroundColor Green
    
    $test = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker is running" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker is not running - Please start Docker Desktop" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Docker not installed" -ForegroundColor Red
}
```

### 3. Docker Desktop Settings for Better Performance
1. Right-click whale icon → Settings
2. Resources → Advanced
3. Set:
   - CPUs: 2-4 (depending on your computer)
   - Memory: 4GB (minimum for Azure deployments)
   - Swap: 1GB
4. Click "Apply & Restart"

---

## 🆘 Still Having Issues?

### Get Docker Logs
```powershell
# Check Docker Desktop logs
# Location: C:\Users\[YourUsername]\AppData\Local\Docker\log.txt
```

### Check System Requirements
**Minimum Requirements:**
- Windows 10 64-bit: Pro, Enterprise, or Education (Build 19041 or higher)
- Or Windows 11 64-bit
- 4GB RAM (8GB recommended)
- BIOS-level hardware virtualization support enabled
- WSL 2 feature enabled

### Alternative Deployment Methods

If Docker Desktop continues to have issues, you can:

1. **Use Cloud Shell (No Docker needed):**
   - Go to: https://shell.azure.com
   - Upload your files
   - Run deployment from there

2. **Use GitHub Actions:**
   - Push code to GitHub
   - Let GitHub build and deploy for you

3. **Use Azure App Service instead:**
   ```powershell
   # Doesn't require Docker
   .\deploy-to-azure-v2.ps1 -AppName "mychurch-app"
   ```

---

## 📞 Additional Help

- **Docker Documentation:** https://docs.docker.com/desktop/windows/
- **Docker Desktop Issues:** https://github.com/docker/for-win/issues
- **WSL 2 Setup:** https://docs.microsoft.com/en-us/windows/wsl/install

---

**Once Docker is running, you're ready to deploy! 🚀**

```powershell
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```
