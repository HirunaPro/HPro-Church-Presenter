# Azure Deployment Guide v2.0

> **Modern, streamlined deployment for Church Presentation App on Azure**

This guide provides a completely rewritten deployment experience with improved automation, better error handling, and multiple deployment options.

---

## 🚀 Quick Start

### Prerequisites

1. **Azure Account** (Free tier available)
   - Sign up: https://azure.microsoft.com/free/
   - $200 free credit for 30 days + permanent free services

2. **Azure CLI** installed
   - Windows: `winget install Microsoft.AzureCLI`
   - macOS: `brew install azure-cli`
   - Linux: `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

3. **Git** (optional, for Git deployment)
   - Download: https://git-scm.com/downloads

---

## 📋 Deployment Methods

### Method 1: Quick Deploy (Recommended) ✨

**Windows PowerShell:**
```powershell
.\deploy-to-azure-v2.ps1 -AppName "mychurch-app-$(Get-Random)" -Tier Free -DeploymentMethod zip
```

**macOS/Linux Bash:**
```bash
chmod +x deploy-to-azure-v2.sh
./deploy-to-azure-v2.sh --app-name "mychurch-app-$RANDOM" --tier free --method zip
```

### Method 2: Interactive Deployment

**Windows:**
```powershell
.\deploy-to-azure-v2.ps1
# Script will prompt for all required information
```

**macOS/Linux:**
```bash
./deploy-to-azure-v2.sh
# Script will prompt for all required information
```

### Method 3: Advanced Options

```powershell
# Windows - Deploy to Basic tier with Git
.\deploy-to-azure-v2.ps1 `
    -AppName "church-presenter-prod" `
    -ResourceGroup "church-production" `
    -Location "westus2" `
    -Tier Basic `
    -DeploymentMethod git
```

```bash
# Linux/Mac - Deploy to Standard tier with ZIP
./deploy-to-azure-v2.sh \
    --app-name "church-presenter-prod" \
    --resource-group "church-production" \
    --location "westus2" \
    --tier standard \
    --method zip
```

---

## 🎯 Deployment Options Explained

### Pricing Tiers

| Tier | Cost | Compute | Best For |
|------|------|---------|----------|
| **Free (F1)** | $0/month | 60 min/day | Sunday services, occasional use ✅ |
| **Basic (B1)** | ~$13/month | Unlimited | Regular use, testing |
| **Standard (S1)** | ~$69/month | Auto-scaling | Large churches, production |

**💡 Recommendation:** Start with **Free tier** - perfect for most churches!

### Deployment Methods

| Method | Speed | Complexity | When to Use |
|--------|-------|------------|-------------|
| **ZIP** | ⚡ Fast | Simple | Quick deployments, updates |
| **Git** | Medium | Medium | Version control workflow |
| **GitHub** | Slow | Complex | CI/CD, team collaboration |

**💡 Recommendation:** Use **ZIP** for simplicity and speed.

---

## 📊 What's New in v2.0

### ✨ Major Improvements

1. **Multiple Deployment Methods**
   - ZIP deployment (fastest)
   - Local Git deployment
   - GitHub integration

2. **Better Error Handling**
   - Validates all inputs before deployment
   - Clear error messages with solutions
   - Automatic retry for transient failures

3. **Enhanced User Experience**
   - Color-coded output
   - Progress indicators
   - Interactive prompts with defaults
   - Subscription selection

4. **Smart Configuration**
   - Automatic WebSocket enablement
   - Optimized app settings for Python
   - Proper startup command configuration

5. **Cost Optimization**
   - Clear pricing information upfront
   - Tier comparison
   - Start/stop script integration

### 🆚 Comparison: v1 vs v2

| Feature | v1 (Old) | v2 (New) |
|---------|----------|----------|
| Deployment Methods | Git only | ZIP/Git/GitHub |
| Error Messages | Generic | Specific with solutions |
| Input Validation | Minimal | Comprehensive |
| Subscription Selection | Manual | Interactive |
| Configuration | Manual | Automatic |
| Cost Transparency | Limited | Full breakdown |

---

## 🔧 Detailed Usage

### PowerShell Script

```powershell
.\deploy-to-azure-v2.ps1 [OPTIONS]

OPTIONS:
  -AppName <string>           Globally unique app name (required)
  -ResourceGroup <string>     Resource group name (default: church-presenter-rg)
  -Location <string>          Azure region (default: eastus)
  -Tier <Free|Basic|Standard> Pricing tier (default: Free)
  -DeploymentMethod <git|zip|github> Deployment method (default: zip)

EXAMPLES:
  # Quick deploy with defaults
  .\deploy-to-azure-v2.ps1 -AppName "mychurch-12345"
  
  # Custom configuration
  .\deploy-to-azure-v2.ps1 -AppName "church-app" -Tier Basic -Location "westeurope"
  
  # GitHub deployment
  .\deploy-to-azure-v2.ps1 -AppName "church-app" -DeploymentMethod github
```

### Bash Script

```bash
./deploy-to-azure-v2.sh [OPTIONS]

OPTIONS:
  -a, --app-name NAME          Globally unique app name (required)
  -g, --resource-group NAME    Resource group name (default: church-presenter-rg)
  -l, --location LOCATION      Azure region (default: eastus)
  -t, --tier TIER             Pricing tier: free, basic, standard (default: free)
  -m, --method METHOD         Deployment method: git, zip, github (default: zip)
  -h, --help                  Show help message

EXAMPLES:
  # Quick deploy with defaults
  ./deploy-to-azure-v2.sh --app-name "mychurch-12345"
  
  # Custom configuration
  ./deploy-to-azure-v2.sh -a "church-app" -t basic -l "westeurope"
  
  # GitHub deployment
  ./deploy-to-azure-v2.sh -a "church-app" -m github
```

---

## 🌍 Available Azure Regions

Choose a region close to your church for best performance:

### Americas
- `eastus` - East US (Virginia) ✅ **Default**
- `westus2` - West US 2 (Washington)
- `centralus` - Central US (Iowa)

### Europe
- `northeurope` - North Europe (Ireland)
- `westeurope` - West Europe (Netherlands)

### Asia Pacific
- `southeastasia` - Southeast Asia (Singapore)

💡 **Tip:** Use `eastus` for churches in Eastern US/Americas, `westeurope` for Europe, `southeastasia` for Asia.

---

## 📖 Step-by-Step Walkthrough

### 1. Install Azure CLI

**Windows:**
```powershell
winget install Microsoft.AzureCLI
# or download from: https://aka.ms/installazurecliwindows
```

**macOS:**
```bash
brew install azure-cli
```

**Linux:**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 2. Login to Azure

```bash
az login
```

This opens your browser for authentication. Follow the prompts.

### 3. Run Deployment Script

**Interactive Mode (Easiest):**

```powershell
# Windows
.\deploy-to-azure-v2.ps1

# The script will ask you:
# - App name (must be globally unique)
# - Confirm configuration
# - Select Azure subscription
# - Open browser when done
```

```bash
# macOS/Linux
./deploy-to-azure-v2.sh

# Same interactive prompts as Windows
```

**Non-Interactive Mode:**

```powershell
# Windows - All parameters specified
.\deploy-to-azure-v2.ps1 `
    -AppName "church-presenter-$(Get-Random)" `
    -ResourceGroup "church-rg" `
    -Location "eastus" `
    -Tier Free `
    -DeploymentMethod zip
```

### 4. Wait for Deployment

The script will:
1. ✅ Validate prerequisites (Azure CLI, Git, etc.)
2. 🔐 Check Azure login
3. 📋 Register required resource providers
4. 📦 Create resource group
5. 🏗️ Create App Service Plan
6. 🌐 Create Web App
7. ⚙️ Configure WebSocket and settings
8. 📤 Deploy your application
9. 🎉 Show success message with URLs

**Typical Duration:** 2-5 minutes

### 5. Access Your App

After deployment, your app will be available at:

- **Home:** `https://your-app-name.azurewebsites.net/`
- **Operator:** `https://your-app-name.azurewebsites.net/operator.html`
- **Projector:** `https://your-app-name.azurewebsites.net/projector.html`

---

## 🐛 Troubleshooting

### Common Issues

#### 1. "App name already taken"

**Problem:** App names must be globally unique across all Azure users.

**Solution:**
```powershell
# Add a random number to make it unique
.\deploy-to-azure-v2.ps1 -AppName "mychurch-app-$(Get-Random -Maximum 9999)"
```

#### 2. "Azure CLI not found"

**Problem:** Azure CLI is not installed.

**Solution:**
```powershell
# Windows
winget install Microsoft.AzureCLI

# macOS
brew install azure-cli
```

#### 3. "Deployment failed" during Git push

**Problem:** Deployment credentials not set or incorrect.

**Solution:**
```bash
# Set deployment credentials
az webapp deployment user set --user-name myusername --password 'MyP@ssw0rd!'

# Try deployment again
```

#### 4. "App not responding" after deployment

**Problem:** App is still starting (cold start on Free tier).

**Solution:**
- Wait 30-60 seconds
- Refresh the page
- Check logs: `az webapp log tail --resource-group <rg> --name <app>`

#### 5. "Subscription has quota limitations"

**Problem:** Free tier quota exceeded or subscription limits.

**Solution:**
```bash
# Check your quotas
az vm list-usage --location eastus -o table

# Try different region
.\deploy-to-azure-v2.ps1 -AppName "myapp" -Location "westus2"

# Or upgrade to Basic tier
.\deploy-to-azure-v2.ps1 -AppName "myapp" -Tier Basic
```

### View Logs

```bash
# Real-time log streaming
az webapp log tail --resource-group church-presenter-rg --name your-app-name

# Download logs
az webapp log download --resource-group church-presenter-rg --name your-app-name
```

### Restart App

```bash
az webapp restart --resource-group church-presenter-rg --name your-app-name
```

---

## 💰 Cost Management

### Free Tier (F1) - Recommended

**Cost:** $0/month forever

**Limitations:**
- 60 minutes/day compute time
- Sleeps after 20 minutes inactivity
- Cold start: 10-30 seconds

**Perfect for:**
- ✅ Sunday services (2-3 hours/week)
- ✅ Midweek services
- ✅ Occasional use
- ✅ Testing

### Basic Tier (B1) with Cost Optimization

**Full Cost:** $13.14/month (24/7)

**Optimized Cost Examples:**

| Usage Pattern | Hours/Month | Cost/Month | Savings |
|--------------|-------------|------------|---------|
| Sunday only (3 hrs/week) | 12 | $0.43 | 97% |
| Sun + Wed (6 hrs/week) | 24 | $1.08 | 92% |
| Daily 2 hrs | 60 | $2.60 | 80% |

**How to Optimize:**

```bash
# Stop after service
az webapp stop --resource-group church-presenter-rg --name your-app-name

# Start before service
az webapp start --resource-group church-presenter-rg --name your-app-name

# Or use provided scripts
.\azure-stop.ps1 -ResourceGroup church-presenter-rg -AppName your-app-name
.\azure-start.ps1 -ResourceGroup church-presenter-rg -AppName your-app-name
```

### Calculate Your Costs

```bash
# Use the included cost calculator
python azure-cost-calculator.py
```

---

## 🔄 Updating Your Deployment

### Update via ZIP (Fastest)

```powershell
# Re-run deployment script
.\deploy-to-azure-v2.ps1 -AppName "existing-app-name" -DeploymentMethod zip
```

### Update via Git

```bash
# If you used Git deployment, just push changes
git add .
git commit -m "Update app"
git push azure main:master
```

### Manual Update

```bash
# Package and upload manually
zip -r app.zip *.html *.py requirements.txt runtime.txt css/ js/ images/ songs/

az webapp deployment source config-zip \
    --resource-group church-presenter-rg \
    --name your-app-name \
    --src app.zip
```

---

## 🗑️ Deleting Everything

### Delete Just the App

```bash
az webapp delete --resource-group church-presenter-rg --name your-app-name
az appservice plan delete --name plan-your-app-name --resource-group church-presenter-rg
```

### Delete Entire Resource Group (Everything)

```bash
# This deletes all resources in the group
az group delete --name church-presenter-rg --yes --no-wait
```

💡 **Tip:** Resource group deletion is permanent and cannot be undone!

---

## 📚 Advanced Topics

### Custom Domain

```bash
# Add custom domain (requires Standard tier)
az webapp config hostname add \
    --webapp-name your-app-name \
    --resource-group church-presenter-rg \
    --hostname "presenter.yourchurch.org"

# Enable SSL
az webapp config ssl bind \
    --certificate-thumbprint <thumbprint> \
    --ssl-type SNI \
    --name your-app-name \
    --resource-group church-presenter-rg
```

### Auto-Scaling (Standard tier)

```bash
# Enable auto-scale
az monitor autoscale create \
    --resource-group church-presenter-rg \
    --resource your-app-name \
    --resource-type Microsoft.Web/serverfarms \
    --name autoscale-church-app \
    --min-count 1 \
    --max-count 3 \
    --count 1
```

### Continuous Deployment from GitHub

```bash
# Set up GitHub Actions
az webapp deployment github-actions add \
    --resource-group church-presenter-rg \
    --name your-app-name \
    --repo "username/repository" \
    --branch main \
    --token <github-pat>
```

---

## ❓ FAQ

### Q: Which tier should I choose?

**A:** For most churches, **Free (F1)** is perfect. It provides:
- Unlimited use during service times
- $0 cost
- All features needed for presentation

Upgrade to Basic only if:
- You need 24/7 availability
- You want faster cold starts
- You exceed 60 min/day compute

### Q: How long does deployment take?

**A:** Typically 2-5 minutes:
- ZIP deployment: ~2-3 minutes
- Git deployment: ~3-5 minutes
- First-time setup: +1-2 minutes (resource provider registration)

### Q: Can I deploy multiple instances?

**A:** Yes! Just use different app names:
```powershell
.\deploy-to-azure-v2.ps1 -AppName "church-production"
.\deploy-to-azure-v2.ps1 -AppName "church-testing"
```

### Q: Will my songs be saved?

**A:** Songs uploaded to Azure are stored in the app's file system. However:
- Free tier may reset files periodically
- Recommendation: Keep local backups
- Advanced: Use Azure Blob Storage for persistence

### Q: How do I backup my deployment?

**A:** Your code is your backup. Just keep the project folder safe and you can redeploy anytime.

### Q: What if I need help?

**A:** 
1. Check this guide's troubleshooting section
2. View logs: `az webapp log tail --resource-group <rg> --name <app>`
3. Check main project README.md
4. Test locally first: `python server.py`

---

## 🎯 Best Practices

### 1. Use Unique App Names

```powershell
# Good - includes organization and random number
church-saintjohn-presenter-4521

# Bad - too generic
my-app
presenter
church
```

### 2. Keep Resource Groups Organized

```bash
# Development
church-presenter-dev

# Production
church-presenter-prod

# Testing
church-presenter-test
```

### 3. Monitor Your Usage

```bash
# Check app metrics
az monitor metrics list \
    --resource $(az webapp show --resource-group church-presenter-rg --name your-app-name --query id -o tsv) \
    --metric "Requests" \
    --start-time 2025-10-01T00:00:00Z
```

### 4. Test Before Sunday

- Deploy on Saturday
- Test operator and projector pages
- Verify song loading
- Check WebSocket connectivity

### 5. Have a Backup Plan

- Keep local installation ready: `python server.py`
- Test locally before each service
- Save deployment commands in a script

---

## 📞 Support Resources

- **Azure Documentation:** https://docs.microsoft.com/azure/app-service/
- **Azure CLI Reference:** https://docs.microsoft.com/cli/azure/
- **Azure Free Tier:** https://azure.microsoft.com/free/
- **Pricing Calculator:** https://azure.microsoft.com/pricing/calculator/

---

## 📝 Summary

**Deployment in 3 Commands:**

```powershell
# 1. Install Azure CLI (one-time)
winget install Microsoft.AzureCLI

# 2. Login to Azure (one-time)
az login

# 3. Deploy!
.\deploy-to-azure-v2.ps1 -AppName "mychurch-$(Get-Random)"
```

**Your app will be live at:** `https://your-app-name.azurewebsites.net`

---

**Last Updated:** October 2025  
**Version:** 2.0  
**Compatibility:** Windows PowerShell 5.1+, Bash 4.0+, Azure CLI 2.40+
