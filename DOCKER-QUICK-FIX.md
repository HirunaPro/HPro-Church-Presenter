# 🚨 QUICK FIX: Docker Not Running Error

## Your Error
```
ERROR: error during connect: Head "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/_ping": 
open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
❌ Docker build failed
```

## ✅ Solution (2 Minutes)

### Step 1: Start Docker Desktop
1. Press `Win` key on keyboard
2. Type "Docker Desktop"
3. Click on "Docker Desktop" app
4. **Wait 1-2 minutes** for it to fully start

### Step 2: Look for Whale Icon
- Check bottom-right of your screen (system tray)
- Look for a **whale icon** 🐋
- Wait until the icon **stops moving/animating**

### Step 3: Verify Docker is Ready
```powershell
# In PowerShell, run:
docker ps
```

**Good output (Docker is ready):**
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

**Bad output (Docker not ready yet):**
```
error during connect: ...
```
→ Wait another minute and try again

### Step 4: Run Deployment Again
```powershell
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```

---

## 🆘 If Docker Desktop is Not Installed

1. **Download:** https://www.docker.com/products/docker-desktop
2. **Install** the downloaded file
3. **Restart your computer** (important!)
4. **Start Docker Desktop** from Start Menu
5. **Wait 2-3 minutes** for first-time initialization
6. **Run deployment script**

---

## 📖 Need More Help?

**Complete troubleshooting guide:**  
[docs/DOCKER-TROUBLESHOOTING.md](docs/DOCKER-TROUBLESHOOTING.md)

**Common issues covered:**
- Docker Desktop won't start
- WSL 2 errors
- Virtualization not enabled
- Installation problems

---

## 💡 Quick Checklist

Before running deployment:
- [ ] Docker Desktop is open (whale icon visible)
- [ ] Whale icon is **not** animating
- [ ] `docker ps` command works
- [ ] Computer was restarted after Docker installation (if first time)

---

**Once Docker is running, deployment takes 3-5 minutes! 🚀**
