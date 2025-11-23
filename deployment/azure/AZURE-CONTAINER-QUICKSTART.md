# 🚀 Quick Start: Azure Container Deployment

Deploy your Church Presentation App to Azure in **5 minutes** with full WebSocket support!

---

## ⚡ Super Quick Start

### Windows
```powershell
# 1. Install prerequisites (one time)
# Download and install:
# - Azure CLI: https://aka.ms/installazurecliwindows
# - Docker Desktop: https://www.docker.com/products/docker-desktop
# (Restart computer after Docker install)

# 2. Deploy (run this in PowerShell from project folder)
.\deploy-azure-container.ps1 -AppName "mychurch-app"

# 3. Access your app at the URL shown (e.g., http://mychurch-app.eastus.azurecontainer.io:8080)
```

### Linux/macOS
```bash
# 1. Install prerequisites (one time)
# macOS:
brew install azure-cli docker

# Linux:
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# Install Docker: https://docs.docker.com/engine/install/

# 2. Deploy
chmod +x deploy-azure-container.sh
./deploy-azure-container.sh --app-name "mychurch-app"

# 3. Access your app at the URL shown
```

---

## 📋 Prerequisites Checklist

- [ ] Azure account (free tier works! Sign up at https://azure.microsoft.com/free/)
- [ ] Azure CLI installed
- [ ] Docker Desktop installed and running
- [ ] Project files downloaded

---

## 🎯 What You Get

After deployment:

✅ **Public URL** - Access from anywhere  
✅ **WebSocket Support** - Real-time operator-to-projector sync  
✅ **Two Ports**:
  - Port 8080: HTTP (web pages)
  - Port 8765: WebSocket (real-time communication)

Example URLs:
```
http://mychurch-app.eastus.azurecontainer.io:8080/index.html
http://mychurch-app.eastus.azurecontainer.io:8080/operator.html
http://mychurch-app.eastus.azurecontainer.io:8080/projector.html
```

---

## 💰 Costs

**Pay-per-second pricing** (only when running):

| Usage | Monthly Cost |
|-------|--------------|
| 3 hours/week (Sundays) | **$0.57/month** ⭐ |
| 6 hours/week (Sun + Wed) | **$1.14/month** |
| 24/7 | $35/month |

**💡 Pro Tip:** Stop the container when not in use to save money!

```powershell
# Before service
.\start-container.ps1

# After service
.\stop-container.ps1
```

---

## 🔧 Daily Workflow

### Sunday Morning (Before Service)
```bash
# Start the container
.\start-container.ps1  # Windows
./start-container.sh   # Linux/Mac

# Wait 30 seconds for container to start
```

### During Service
1. **Operator Computer:**
   - Open: `http://[your-app].azurecontainer.io:8080/operator.html`
   - Search and select songs
   - Control what displays

2. **Projector Computer:**
   - Open: `http://[your-app].azurecontainer.io:8080/projector.html`
   - Press F11 for fullscreen
   - Displays song lyrics to congregation

### After Service
```bash
# Stop the container to save money
.\stop-container.ps1  # Windows
./stop-container.sh   # Linux/Mac
```

---

## 🛠️ Deployment Options

### Option 1: Interactive (Recommended for First Time)
```powershell
# Windows
.\deploy-azure-container.ps1

# Linux/Mac
./deploy-azure-container.sh
```
Script will ask for:
- App name
- Azure region
- Confirmation

### Option 2: One Command
```powershell
# Windows
.\deploy-azure-container.ps1 -AppName "mychurch-app"

# Linux/Mac
./deploy-azure-container.sh --app-name "mychurch-app"
```

### Option 3: Full Custom
```powershell
# Windows
.\deploy-azure-container.ps1 `
  -AppName "mychurch-app" `
  -ResourceGroup "my-church-rg" `
  -Location "westus2"

# Linux/Mac
./deploy-azure-container.sh \
  --app-name "mychurch-app" \
  --resource-group "my-church-rg" \
  --location "westus2"
```

---

## 🌍 Azure Regions

Choose the region closest to you for best performance:

| Region | Location | Code |
|--------|----------|------|
| East US | Virginia, USA | `eastus` |
| West US 2 | Washington, USA | `westus2` |
| Central US | Iowa, USA | `centralus` |
| West Europe | Netherlands | `westeurope` |
| UK South | London, UK | `uksouth` |
| Southeast Asia | Singapore | `southeastasia` |
| Australia East | Sydney | `australiaeast` |

Full list: https://azure.microsoft.com/en-us/global-infrastructure/geographies/

---

## ❓ Troubleshooting

### "Azure CLI not found"
```powershell
# Windows: Download and install
https://aka.ms/installazurecliwindows

# Mac
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### "Docker not found"
```powershell
# Download Docker Desktop
https://www.docker.com/products/docker-desktop

# Install and restart computer
# Start Docker Desktop before running deploy script
```

### "Docker is not running"
- Open Docker Desktop
- Wait for it to fully start (whale icon in system tray)
- Try deployment again

### "App name already taken"
- Choose a different name
- Or add a unique suffix: `mychurch-app-2024`

### "Deployment failed"
```bash
# Check Azure login
az login

# Check Docker is running
docker ps

# View detailed logs
az container logs --resource-group church-presenter-rg --name mychurch-app
```

### WebSocket Not Connecting
1. Verify container is running:
   ```bash
   .\check-status.ps1
   ```
2. Check browser console (F12) for errors
3. Verify you're using `ws://` not `wss://`
4. Make sure both ports (8080, 8765) are accessible

---

## 🔄 Updating Your App

### Add New Songs
1. Add `.json` files to `songs/` folder
2. Redeploy:
   ```bash
   .\deploy-azure-container.ps1 -AppName "mychurch-app"
   ```

### Update Code
1. Edit HTML/CSS/JS files
2. Redeploy (same command as above)

### Fast Redeploy (Skip Build)
If you only changed songs or minor files:
```bash
# Windows
.\deploy-azure-container.ps1 -AppName "mychurch-app" -SkipBuild

# Linux/Mac  
./deploy-azure-container.sh --app-name "mychurch-app" --skip-build
```

---

## 📊 Monitoring

### Check Status
```bash
.\check-status.ps1  # Windows
./check-status.sh   # Linux/Mac
```

### View Logs
```bash
.\view-logs.ps1  # Windows
./view-logs.sh   # Linux/Mac
```

### Azure Portal
1. Go to: https://portal.azure.com
2. Search for your app name
3. View metrics, logs, and settings

---

## 🎓 Next Steps

After successful deployment:

1. ✅ Bookmark the operator and projector URLs
2. ✅ Test WebSocket connection (should show "Connected" in operator)
3. ✅ Add your church's songs to `songs/` folder
4. ✅ Practice controlling the projector from operator interface
5. ✅ Set up start/stop routine for cost optimization
6. ✅ Share projector URL with team members

---

## 📚 Full Documentation

For detailed information, see:

- **Full Guide:** [AZURE-CONTAINER-DEPLOYMENT.md](AZURE-CONTAINER-DEPLOYMENT.md)
- **Main README:** [README.md](../README.md)
- **Docker Compose:** Use `docker-compose.yml` for local testing

---

## 🆘 Need Help?

### Quick Checks
- [ ] Azure CLI installed? Run: `az --version`
- [ ] Docker running? Run: `docker ps`
- [ ] Logged into Azure? Run: `az account show`
- [ ] Container running? Run: `.\check-status.ps1`

### Common Commands
```bash
# Re-login to Azure
az login

# Check subscription
az account show

# List all container instances
az container list --output table

# Delete and redeploy
az container delete --resource-group church-presenter-rg --name mychurch-app --yes
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```

---

## 💡 Pro Tips

1. **Test Locally First**
   ```bash
   docker-compose up
   # Open http://localhost:8080
   ```

2. **Bookmark Management Scripts**
   - `start-container.ps1` - Start before service
   - `stop-container.ps1` - Stop after service
   - `view-logs.ps1` - Debug issues
   - `check-status.ps1` - Quick health check

3. **Set Up Auto-Start/Stop**
   Use Azure Automation to schedule start/stop times:
   - Start: Sunday 9:00 AM
   - Stop: Sunday 1:00 PM

4. **Mobile Access**
   The URLs work on phones/tablets too!
   - Control from phone
   - Display on tablet

5. **Multiple Services**
   Deploy separate instances for different languages:
   ```bash
   .\deploy-azure-container.ps1 -AppName "church-english"
   .\deploy-azure-container.ps1 -AppName "church-sinhala"
   ```

---

**Ready to deploy?** Run the deployment script and you'll be live in 5 minutes! 🚀

```powershell
# Windows
.\deploy-azure-container.ps1 -AppName "mychurch-app"

# Linux/Mac
./deploy-azure-container.sh --app-name "mychurch-app"
```
