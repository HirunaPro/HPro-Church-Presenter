# Quick Reference - 4 Deployment Methods

## 🚀 Choose Your Deployment Method

### 1️⃣ Local Network (On-Site)
**Best for:** Church services where devices are on same WiFi

```bash
# Windows
start.bat

# macOS/Linux
python3 src/server/server.py
```

**Access:** `http://localhost:8000/index.html`  
**Cost:** $0  
**Internet:** Not needed  
**Documentation:** [deployment/local/README.md](deployment/local/README.md)

---

### 2️⃣ Docker Container (Development)
**Best for:** Testing and development with container isolation

```bash
cd deployment/docker
docker-compose up
```

**Access:** `http://localhost:8000/index.html`  
**Cost:** $0 (Docker is free)  
**Internet:** Not needed  
**Setup:** Requires Docker installed  
**Documentation:** [deployment/docker/README.md](deployment/docker/README.md)

---

### 3️⃣ Azure Cloud (Global Access)
**Best for:** Remote access from anywhere

```powershell
# Windows PowerShell
.\deployment\azure\deploy-azure-container.ps1 -AppName "mychurch-app"

# Linux/macOS
./deployment/azure/deploy-azure-container.sh --app-name "mychurch-app"
```

**Cost:** ~$0.57/month (3 hrs/week)  
**Internet:** Required  
**Setup Time:** 5 minutes  
**Documentation:** [deployment/azure/README.md](deployment/azure/README.md)

---

### 4️⃣ Windows Executable (No Python Needed)
**Best for:** Distribution to other PCs

```powershell
cd .\deployment\pyinstaller
.\build-executable.ps1
```

**Creates:** `dist/ChurchApp.exe`  
**Size:** ~50MB  
**Platforms:** Windows only  
**Installation:** Just run the .exe  
**Documentation:** [deployment/pyinstaller/README.md](deployment/pyinstaller/README.md)

---

## 📁 New Project Structure

```
PresentationApp/
├── src/                 ← Application code
│   ├── static/         (HTML, CSS, JS)
│   ├── server/         (Python server)
│   └── songs/          (Song library)
├── deployment/         ← Deployment methods
│   ├── local/
│   ├── docker/
│   ├── azure/
│   └── pyinstaller/
└── docs/              ← Documentation
```

---

## ⚡ Quick Commands

### Start Local Server
```bash
start.bat                           # Windows
python3 src/server/server.py        # macOS/Linux
```

### Start Docker Container
```bash
cd deployment/docker
docker-compose up                   # Start container
docker-compose down                 # Stop container
```

### Deploy to Azure
```powershell
.\deployment\azure\deploy-azure-container.ps1 -AppName "my-app"
```

### Build Windows Executable
```powershell
.\deployment\pyinstaller\build-executable.ps1
```

### Add a New Song
1. Create: `src/songs/my-song.json`
2. Use multi-line format
3. Refresh operator page

---

## 📖 Documentation Map

| Need | See |
|------|-----|
| Local setup | [deployment/local/README.md](deployment/local/README.md) |
| Azure setup | [deployment/azure/README.md](deployment/azure/README.md) |
| Build .exe | [deployment/pyinstaller/README.md](deployment/pyinstaller/README.md) |
| Project structure | [docs/PROJECT-STRUCTURE.md](docs/PROJECT-STRUCTURE.md) |
| Song format | [docs/MULTI-LINE-SONG-FORMAT.md](docs/MULTI-LINE-SONG-FORMAT.md) |
| Search guide | [docs/SINGLISH-SEARCH-GUIDE.md](docs/SINGLISH-SEARCH-GUIDE.md) |
| Overview | [README.md](README.md) |

---

## 🌐 Access URLs

### Local Network
```
Landing Page:      http://localhost:8000/index.html
Operator Control:  http://localhost:8000/operator.html
Projector Display: http://localhost:8000/projector.html
```

### Azure Cloud
```
Landing Page:      http://<your-azure-ip>:8000/index.html
Operator Control:  http://<your-azure-ip>:8000/operator.html
Projector Display: http://<your-azure-ip>:8000/projector.html
```

### From Another Device
Replace `localhost` with your computer's IP address:
```
Windows: ipconfig
macOS/Linux: ifconfig | grep "inet "
```

---

## 🔧 Key Changes

| Item | Old | New |
|------|-----|-----|
| Server | `python server.py` | `python src/server/server.py` |
| Songs | `songs/` | `src/songs/` |
| HTML | `./` | `src/static/` |
| Deployments | Mixed | Organized in `deployment/` |

---

## ✅ Verification

**All files successfully moved:**
- ✅ HTML/CSS/JS in `src/static/`
- ✅ Server code in `src/server/`
- ✅ Songs in `src/songs/`
- ✅ Deployments in `deployment/`
- ✅ Documentation updated
- ✅ Scripts updated

---

## 🎯 Next Steps

1. **Choose your deployment:** Local, Azure, or Executable
2. **Read the guide:** See documentation map above
3. **Follow instructions:** Each guide has step-by-step setup
4. **Enjoy!** Everything is ready to use

---

## 💡 Tips

- **Local first:** Start with local network to test
- **Then scale:** Move to Azure if you need global access
- **Or distribute:** Build executable for other PCs
- **Test songs:** Add a test song before your service
- **Bookmark URLs:** Save the access URLs for quick access

---

## 📞 Need Help?

- **Local issues:** [deployment/local/README.md](deployment/local/README.md) - Troubleshooting section
- **Azure issues:** [deployment/azure/README.md](deployment/azure/README.md) - Troubleshooting section
- **Build issues:** [deployment/pyinstaller/README.md](deployment/pyinstaller/README.md) - Troubleshooting section
- **General:** [README.md](README.md) - Full documentation
- **Project details:** [docs/PROJECT-STRUCTURE.md](docs/PROJECT-STRUCTURE.md) - Technical details

---

**Version 2.0** - Reorganized with 3 deployment methods  
**Status:** ✅ Ready to deploy!
