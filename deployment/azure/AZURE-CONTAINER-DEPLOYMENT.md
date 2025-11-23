# Azure Container Deployment Guide
## Church Presentation App with Full WebSocket Support

This guide shows you how to deploy your Church Presentation App to Azure Container Instances with full WebSocket support for real-time operator-to-projector communication.

---

## 🎯 Why Azure Container Instances?

✅ **Full WebSocket Support** - Native support for ws:// connections  
✅ **No Quota Issues** - Different quota from App Service  
✅ **Pay-per-Second** - Only pay when running (~$0.57/month for weekly use)  
✅ **Easy Start/Stop** - Start before service, stop after to save money  
✅ **Simple Deployment** - One command deployment  
✅ **Public IP + DNS** - Accessible from anywhere  

---

## 📋 Prerequisites

### 1. Install Azure CLI

**Windows:**
```powershell
# Download and install from:
https://aka.ms/installazurecliwindows
```

**macOS:**
```bash
brew update && brew install azure-cli
```

**Linux:**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 2. Install Docker

**Windows/macOS:**
- Download Docker Desktop: https://www.docker.com/products/docker-desktop
- Install and restart your computer
- Start Docker Desktop

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
# Log out and back in
```

### 3. Verify Installation

```bash
# Check Azure CLI
az --version

# Check Docker
docker --version
docker ps  # Should not show error
```

---

## 🚀 Quick Deployment

### Windows (PowerShell)

```powershell
# One-command deployment
.\deploy-azure-container.ps1 -AppName "mychurch-app"

# With custom settings
.\deploy-azure-container.ps1 -AppName "mychurch-app" -Location "westus2" -ResourceGroup "my-church-rg"

# Skip Docker rebuild (faster redeployment)
.\deploy-azure-container.ps1 -AppName "mychurch-app" -SkipBuild
```

### Linux/macOS (Bash)

```bash
# Make script executable
chmod +x deploy-azure-container.sh

# One-command deployment
./deploy-azure-container.sh --app-name "mychurch-app"

# With custom settings
./deploy-azure-container.sh --app-name "mychurch-app" --location "westus2" --resource-group "my-church-rg"

# Skip Docker rebuild
./deploy-azure-container.sh --app-name "mychurch-app" --skip-build
```

---

## 📝 Deployment Process

The script will:

1. ✅ Check prerequisites (Azure CLI, Docker)
2. ✅ Login to Azure
3. ✅ Create resource group
4. ✅ Create Azure Container Registry
5. ✅ Build Docker image
6. ✅ Push image to registry
7. ✅ Create container instance with:
   - HTTP port: 8080
   - WebSocket port: 8765
   - Public DNS name
   - 1 vCPU + 1.5 GB RAM

**Total time:** 3-5 minutes

---

## 🌐 Access Your Application

After deployment, you'll receive URLs like:

```
🌐 HTTP:  http://mychurch-app.eastus.azurecontainer.io:8080
🔌 WebSocket: ws://mychurch-app.eastus.azurecontainer.io:8765

Application URLs:
  🏠 Landing:   http://mychurch-app.eastus.azurecontainer.io:8080/index.html
  🎮 Operator:  http://mychurch-app.eastus.azurecontainer.io:8080/operator.html
  📺 Projector: http://mychurch-app.eastus.azurecontainer.io:8080/projector.html
```

### Open These URLs:

1. **Operator** (on control computer):
   - Open: `http://[your-app].azurecontainer.io:8080/operator.html`
   - Use this to control what displays on projector

2. **Projector** (on projector computer):
   - Open: `http://[your-app].azurecontainer.io:8080/projector.html`
   - Press F11 for fullscreen
   - This displays to congregation

---

## 💰 Cost Management

### Pricing
- **Per Second:** $0.0000133/second (~$0.048/hour)
- **3-hour service:** $0.14
- **Weekly (Sundays only):** $0.57/month ⭐
- **Weekly (Sun + Wed):** $1.14/month

### Start/Stop to Save Money

**Before Service:**
```bash
# Windows
.\start-container.ps1

# Linux/Mac
./start-container.sh
```

**After Service:**
```bash
# Windows
.\stop-container.ps1

# Linux/Mac
./stop-container.sh
```

**Or use Azure CLI directly:**
```bash
# Start
az container start --resource-group church-presenter-rg --name mychurch-app

# Stop
az container stop --resource-group church-presenter-rg --name mychurch-app
```

---

## 🔧 Management Commands

### View Logs
```bash
# Windows
.\view-logs.ps1

# Linux/Mac
./view-logs.sh

# Or directly
az container logs --resource-group church-presenter-rg --name mychurch-app --follow
```

### Check Status
```bash
# Windows
.\check-status.ps1

# Linux/Mac
./check-status.sh

# Or directly
az container show --resource-group church-presenter-rg --name mychurch-app --query instanceView.state -o tsv
```

### Get Container Details
```bash
az container show --resource-group church-presenter-rg --name mychurch-app
```

### Update Application (Redeploy)
```bash
# Windows
.\deploy-azure-container.ps1 -AppName "mychurch-app"

# Linux/Mac
./deploy-azure-container.sh --app-name "mychurch-app"
```

### Delete Everything
```bash
# Delete container
az container delete --resource-group church-presenter-rg --name mychurch-app --yes

# Delete entire resource group (container + registry)
az group delete --name church-presenter-rg --yes
```

---

## 🐳 Local Docker Testing

Before deploying to Azure, test locally with Docker:

### Build and Run Locally
```bash
# Build image
docker build -t church-presenter:latest .

# Run container
docker run -d \
  -p 8080:8080 \
  -p 8765:8765 \
  --name church-presenter \
  church-presenter:latest

# Test
# Open: http://localhost:8080/index.html

# View logs
docker logs -f church-presenter

# Stop
docker stop church-presenter
docker rm church-presenter
```

### Using Docker Compose
```bash
# Start
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

---

## 🔍 Troubleshooting

### Docker Build Fails
```bash
# Check Dockerfile exists
ls -la Dockerfile

# Check Docker is running
docker ps

# View build logs
docker build -t church-presenter:latest . --no-cache
```

### Container Won't Start
```bash
# Check logs
az container logs --resource-group church-presenter-rg --name mychurch-app

# Check events
az container show --resource-group church-presenter-rg --name mychurch-app --query instanceView
```

### WebSocket Connection Fails
1. Check both ports are open (8080, 8765)
2. Verify the WebSocket URL uses `ws://` not `wss://`
3. Check browser console for errors
4. Verify container is running:
   ```bash
   az container show --resource-group church-presenter-rg --name mychurch-app --query instanceView.state
   ```

### DNS Name Already Taken
- Use a different app name
- Or add a unique suffix: `mychurch-app-2024`

### Azure Login Issues
```bash
# Re-login
az logout
az login

# Check subscription
az account show

# List subscriptions
az account list --output table

# Set subscription
az account set --subscription "Your Subscription Name"
```

---

## 🔒 Security Considerations

### Current Setup (Development)
- ⚠️ HTTP only (not HTTPS)
- ⚠️ Public access
- ✅ Good for: Church internal use, testing

### Production Recommendations
1. **Add SSL/TLS** - Use Azure Application Gateway or Front Door
2. **Restrict Access** - Use Azure Network Security Groups
3. **Add Authentication** - Implement user login
4. **Use Managed Identity** - For secure access to Azure resources

### Basic IP Restriction
```bash
# Create Network Security Group
az network nsg create --resource-group church-presenter-rg --name church-nsg

# Allow only your church's IP
az network nsg rule create \
  --resource-group church-presenter-rg \
  --nsg-name church-nsg \
  --name AllowChurchIP \
  --priority 100 \
  --source-address-prefixes YOUR.CHURCH.IP.ADDRESS \
  --destination-port-ranges 8080 8765 \
  --access Allow
```

---

## 📊 Monitoring & Diagnostics

### View Container Metrics
```bash
# CPU and Memory usage
az monitor metrics list \
  --resource $(az container show --resource-group church-presenter-rg --name mychurch-app --query id -o tsv) \
  --metric CPUUsage MemoryUsage
```

### Set Up Alerts
```bash
# Alert when container stops
az monitor metrics alert create \
  --name container-stopped \
  --resource-group church-presenter-rg \
  --scopes $(az container show --resource-group church-presenter-rg --name mychurch-app --query id -o tsv) \
  --condition "count ContainerState == 0" \
  --description "Alert when container is stopped"
```

---

## 🔄 CI/CD Integration

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Azure Container Instances

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Build and Deploy
        run: |
          chmod +x deploy-azure-container.sh
          ./deploy-azure-container.sh --app-name "${{ secrets.APP_NAME }}"
```

---

## 📦 What Gets Deployed

### Docker Image Contents
- Python 3.11
- Application files (HTML, CSS, JS)
- Song files (.json)
- Python server (server-azure.py)
- WebSocket support (websockets library)

### Azure Resources Created
1. **Resource Group** - Container for all resources
2. **Container Registry** - Stores your Docker images
3. **Container Instance** - Runs your application
   - 1 vCPU
   - 1.5 GB RAM
   - Public IP
   - DNS name
   - Ports 8080 (HTTP) and 8765 (WebSocket)

---

## 🎓 Next Steps

### After Deployment
1. ✅ Test the operator interface
2. ✅ Test the projector display
3. ✅ Verify WebSocket connection (should show "Connected")
4. ✅ Add your songs to the `songs/` folder
5. ✅ Redeploy to update content

### Regular Workflow
1. **Sunday morning**: Run `start-container.ps1`
2. **During service**: Use operator interface to control projector
3. **After service**: Run `stop-container.ps1`
4. **Add new songs**: Add JSON files, redeploy

### Cost Optimization Tips
- 💡 Stop container when not in use
- 💡 Use scheduled Azure Automation to auto-start/stop
- 💡 Monitor usage with Azure Cost Management
- 💡 Consider smaller instance (0.5 vCPU) for very small churches

---

## 🆘 Support

### Common Issues

**Q: Can I use a custom domain?**  
A: Yes! Use Azure DNS or your domain provider to create a CNAME record pointing to your container's FQDN.

**Q: How do I add SSL/HTTPS?**  
A: Use Azure Application Gateway or Azure Front Door with SSL certificate.

**Q: Can I run this 24/7?**  
A: Yes, but it costs ~$35/month. Better to start/stop as needed.

**Q: How do I update songs?**  
A: Add JSON files to `songs/` folder, rebuild and redeploy.

**Q: WebSocket not connecting?**  
A: Check that port 8765 is accessible and you're using `ws://` not `wss://`.

---

## 📚 Additional Resources

- [Azure Container Instances Documentation](https://docs.microsoft.com/azure/container-instances/)
- [Docker Documentation](https://docs.docker.com/)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)
- [WebSocket API Reference](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)

---

## 📄 License

This deployment configuration is part of the Church Presentation App project.  
Free to use and modify for church purposes.

---

**Version:** 1.0  
**Last Updated:** October 2025  
**Deployment Type:** Azure Container Instances  
**WebSocket Support:** ✅ Full Support
