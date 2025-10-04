# 🚀 Quick Deploy - Azure Cheat Sheet

> Ultra-quick reference for deploying Church Presentation App to Azure

---

## ⚡ Fastest Deploy (Copy & Paste)

### Windows PowerShell
```powershell
# One-command deploy
.\deploy-to-azure-v2.ps1 -AppName "mychurch-$(Get-Random)"
```

### macOS/Linux
```bash
# One-command deploy
./deploy-to-azure-v2.sh --app-name "mychurch-$RANDOM"
```

---

## 📋 Prerequisites Checklist

- [ ] Azure account created (https://azure.microsoft.com/free/)
- [ ] Azure CLI installed
- [ ] Logged in with `az login`

**Install Azure CLI:**
```powershell
# Windows
winget install Microsoft.AzureCLI

# macOS
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

---

## 🎯 Common Commands

### Deploy
```powershell
# Windows - Free tier, ZIP deployment
.\deploy-to-azure-v2.ps1 -AppName "myapp-12345" -Tier Free -DeploymentMethod zip

# Linux/Mac - Free tier, ZIP deployment
./deploy-to-azure-v2.sh -a "myapp-12345" -t free -m zip
```

### Update Existing App
```powershell
# Windows
.\deploy-to-azure-v2.ps1 -AppName "existing-app-name"

# Linux/Mac
./deploy-to-azure-v2.sh -a "existing-app-name"
```

### View Logs
```bash
az webapp log tail --resource-group church-presenter-rg --name YOUR-APP-NAME
```

### Restart App
```bash
az webapp restart --resource-group church-presenter-rg --name YOUR-APP-NAME
```

### Stop App (Save Money)
```bash
az webapp stop --resource-group church-presenter-rg --name YOUR-APP-NAME
```

### Start App
```bash
az webapp start --resource-group church-presenter-rg --name YOUR-APP-NAME
```

### Delete Everything
```bash
az group delete --name church-presenter-rg --yes
```

---

## 💰 Pricing Quick Reference

| Tier | Cost | When to Use |
|------|------|-------------|
| **Free** | $0/month | ✅ Recommended for churches |
| **Basic** | $13/month | Regular use, testing |
| **Standard** | $69/month | Large churches, production |

**Free Tier Limits:**
- 60 minutes/day compute ✅ Plenty for services!
- Sleeps after 20 min inactivity
- Cold start: 10-30 seconds

---

## 🔧 Full Command Options

### PowerShell
```powershell
.\deploy-to-azure-v2.ps1 `
    -AppName "myapp" `              # REQUIRED: Globally unique name
    -ResourceGroup "church-rg" `    # Optional: Resource group name
    -Location "eastus" `            # Optional: Azure region
    -Tier Free `                    # Optional: Free|Basic|Standard
    -DeploymentMethod zip           # Optional: zip|git|github
```

### Bash
```bash
./deploy-to-azure-v2.sh \
    --app-name "myapp" \            # REQUIRED: Globally unique name
    --resource-group "church-rg" \  # Optional: Resource group name
    --location "eastus" \           # Optional: Azure region
    --tier free \                   # Optional: free|basic|standard
    --method zip                    # Optional: zip|git|github
```

---

## 🌍 Best Azure Regions

- **East US** (`eastus`) - Default, good for Americas
- **West Europe** (`westeurope`) - Good for Europe
- **Southeast Asia** (`southeastasia`) - Good for Asia

Choose the closest to your location!

---

## 🐛 Troubleshooting One-Liners

```bash
# App name taken? Add random number
.\deploy-to-azure-v2.ps1 -AppName "mychurch-$(Get-Random -Maximum 9999)"

# Check Azure login
az account show

# Login to Azure
az login

# View all your apps
az webapp list --output table

# Get app URL
az webapp show --resource-group church-presenter-rg --name YOUR-APP-NAME --query defaultHostName -o tsv

# Check app status
az webapp show --resource-group church-presenter-rg --name YOUR-APP-NAME --query state -o tsv
```

---

## 📱 Your App URLs

After deployment, access at:
```
https://YOUR-APP-NAME.azurewebsites.net/
https://YOUR-APP-NAME.azurewebsites.net/operator.html
https://YOUR-APP-NAME.azurewebsites.net/projector.html
```

---

## ⏱️ Timeline

1. **Install Azure CLI** - 2 minutes (one-time)
2. **Login to Azure** - 1 minute (one-time)
3. **Run deployment** - 2-5 minutes
4. **Total first time** - ~5-10 minutes
5. **Subsequent deploys** - ~2-3 minutes

---

## 🎯 Recommended Workflow

### First Time
```powershell
# 1. Install
winget install Microsoft.AzureCLI

# 2. Login
az login

# 3. Deploy
.\deploy-to-azure-v2.ps1 -AppName "mychurch-$(Get-Random)"

# 4. Open in browser
# https://mychurch-XXXXX.azurewebsites.net
```

### Updates
```powershell
# Just redeploy with same name
.\deploy-to-azure-v2.ps1 -AppName "mychurch-XXXXX"
```

### Before Sunday Service
```bash
# Test locally first
python server.py

# Verify Azure app is running
az webapp show --resource-group church-presenter-rg --name YOUR-APP --query state
```

---

## 💡 Pro Tips

1. **Save your app name** - Write it down! You'll need it for updates.

2. **Test Saturday** - Deploy Saturday, test before Sunday.

3. **Keep local backup** - Always have `python server.py` ready.

4. **Free tier is enough** - Don't overpay! Free tier works great.

5. **Add random numbers** - Makes app names unique: `mychurch-4521`

---

## 🆘 Emergency Commands

```bash
# App not working? Restart it!
az webapp restart --resource-group church-presenter-rg --name YOUR-APP

# See what's wrong
az webapp log tail --resource-group church-presenter-rg --name YOUR-APP

# Nuclear option: delete and redeploy
az group delete --name church-presenter-rg --yes
.\deploy-to-azure-v2.ps1 -AppName "new-app-name"
```

---

## 📞 Need More Help?

- **Full Guide:** See `docs/AZURE-DEPLOYMENT-V2.md`
- **Troubleshooting:** See troubleshooting section in full guide
- **Azure Docs:** https://docs.microsoft.com/azure/app-service/

---

**Remember:** Keep it simple! Free tier + ZIP deployment = Perfect for churches! 🎉
