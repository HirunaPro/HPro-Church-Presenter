# Azure Deployment Guide for Church Presentation App

Complete guide for deploying the Church Presentation App to Azure App Service, including cost optimization strategies.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Deployment Options](#deployment-options)
3. [Step-by-Step Deployment (Free Tier)](#step-by-step-deployment-free-tier)
4. [Cost Calculator](#cost-calculator)
5. [Start/Stop Scripts](#startstop-scripts)
6. [Troubleshooting](#troubleshooting)
7. [Cost Optimization Tips](#cost-optimization-tips)

---

## Prerequisites

### Required Tools

1. **Azure Account**
   - Sign up for free: https://azure.microsoft.com/free/
   - Free tier includes $200 credit for 30 days
   - Free App Service tier (F1) available permanently

2. **Azure CLI**
   - Windows: https://aka.ms/installazurecliwindows
   - macOS: `brew install azure-cli`
   - Linux: https://docs.microsoft.com/cli/azure/install-azure-cli

3. **Git**
   - Install from: https://git-scm.com/downloads
   - Required for deployment from repository

### Optional (for easier deployment)
- **VS Code** with Azure App Service extension
- **GitHub Account** for continuous deployment

---

## Deployment Options

### Option 1: Free Tier (F1) - **RECOMMENDED FOR CHURCHES**
- **Cost**: $0/month
- **Compute**: 60 minutes/day
- **WebSocket**: ✅ Supported
- **Best for**: Sunday services, occasional use

### Option 2: Basic Tier (B1)
- **Cost**: ~$13/month (or less with start/stop scripts)
- **Compute**: Unlimited
- **Always On**: Available
- **Best for**: Regular use, testing, development

### Option 3: Standard Tier (S1)
- **Cost**: ~$69/month
- **Features**: Auto-scaling, custom domain, SSL
- **Best for**: Large churches, multiple concurrent users

---

## Step-by-Step Deployment (Free Tier)

### Step 1: Install Azure CLI

**Windows:**
```powershell
# Download and run installer from:
# https://aka.ms/installazurecliwindows
```

**macOS:**
```bash
brew install azure-cli
```

**Linux:**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Step 2: Login to Azure

```bash
az login
```

This opens a browser window for authentication.

### Step 3: Create Resource Group

```bash
# Set variables (customize these)
RESOURCE_GROUP="church-presentation-rg"
LOCATION="eastus"
APP_NAME="church-presenter-app"  # Must be globally unique

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION
```

### Step 4: Create App Service Plan (Free Tier)

```bash
az appservice plan create \
  --name church-presentation-plan \
  --resource-group $RESOURCE_GROUP \
  --sku F1 \
  --is-linux
```

### Step 5: Create Web App

```bash
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan church-presentation-plan \
  --name $APP_NAME \
  --runtime "PYTHON:3.11"
```

### Step 6: Enable WebSocket

```bash
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --web-sockets-enabled true
```

### Step 7: Configure Startup Command

```bash
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --startup-file "python server.py"
```

### Step 8: Deploy from GitHub

**Option A: Deploy from your GitHub repository**

```bash
# If you've pushed to GitHub
az webapp deployment source config \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --repo-url https://github.com/YOUR-USERNAME/HPro-Church-Presenter \
  --branch azure-deployment \
  --manual-integration
```

**Option B: Deploy from local Git**

```bash
# Get deployment credentials
az webapp deployment user set \
  --user-name <deployment-username> \
  --password <deployment-password>

# Get Git URL
GIT_URL=$(az webapp deployment source config-local-git \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query url --output tsv)

# Add Azure remote and push
git remote add azure $GIT_URL
git push azure azure-deployment:master
```

**Option C: Deploy via ZIP file**

```bash
# Create ZIP of your project (excluding .git, __pycache__, etc.)
# Then deploy
az webapp deployment source config-zip \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --src church-presenter.zip
```

### Step 9: Access Your App

```bash
# Get your app URL
APP_URL=$(az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query defaultHostName --output tsv)

echo "Your app is running at: https://$APP_URL"
echo "Operator: https://$APP_URL/operator.html"
echo "Projector: https://$APP_URL/projector.html"
```

---

## Cost Calculator

Use the included cost calculator to estimate your monthly costs:

```bash
python azure-cost-calculator.py
```

### Example Scenarios

| Usage Pattern | Free Tier (F1) | Basic B1 (Full) | Basic B1 (Partial) |
|---------------|----------------|-----------------|-------------------|
| **Sunday only (2-3 hrs/week)** | $0 | $13.14 | $0.43 |
| **Sun + Wed (6 hrs/week)** | $0 | $13.14 | $1.08 |
| **Daily 2 hrs** | $0 | $13.14 | $2.60 |
| **24/7** | $0 | $13.14 | $13.14 |

**💡 Recommendation**: Start with Free Tier (F1) - it's perfect for most church use cases!

---

## Start/Stop Scripts

For **paid tiers only** (B1, S1), save costs by stopping the app when not in use.

### Windows (PowerShell)

**Start the app:**
```powershell
.\azure-start.ps1 -ResourceGroup church-presentation-rg -AppName church-presenter-app
```

**Stop the app:**
```powershell
.\azure-stop.ps1 -ResourceGroup church-presentation-rg -AppName church-presenter-app
```

### macOS/Linux (Bash)

**Start the app:**
```bash
./azure-start.sh church-presentation-rg church-presenter-app
```

**Stop the app:**
```bash
./azure-stop.sh church-presentation-rg church-presenter-app
```

### Automated Start/Stop (Advanced)

**Using Azure Automation (Free for first 500 minutes/month):**

1. Create Automation Account
2. Create Runbook with schedule
3. Start app Sunday 8 AM, stop Sunday 2 PM

Example runbook script:
```powershell
# Start-ChurchApp.ps1
param(
    [string]$ResourceGroup = "church-presentation-rg",
    [string]$AppName = "church-presenter-app"
)

# Connect using managed identity
Connect-AzAccount -Identity

# Start the app
Start-AzWebApp -ResourceGroupName $ResourceGroup -Name $AppName

Write-Output "App started at $(Get-Date)"
```

---

## Troubleshooting

### App Not Starting

**Check logs:**
```bash
az webapp log tail \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME
```

**Common issues:**
- Python version mismatch → Check `runtime.txt`
- Missing dependencies → Check `requirements.txt`
- Port configuration → Check `server.py` uses `PORT` environment variable

### WebSocket Not Working

**Verify WebSocket is enabled:**
```bash
az webapp config show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query webSocketsEnabled
```

**Enable if needed:**
```bash
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --web-sockets-enabled true
```

### App Sleeping (Free Tier)

The Free Tier (F1) sleeps after 20 minutes of inactivity:
- **Cold start**: 10-30 seconds
- **Workaround**: Keep a browser tab open, or upgrade to B1

### Deployment Failed

**Check deployment status:**
```bash
az webapp deployment list-publishing-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME
```

**View deployment logs:**
```bash
az webapp log deployment show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME
```

---

## Cost Optimization Tips

### 1. Use Free Tier (F1) for Most Churches
- Perfect for Sunday services (2-3 hours)
- $0/month forever
- 60 minutes/day compute time is plenty

### 2. For Paid Tiers: Stop When Not Needed
```bash
# Stop after Sunday service
./azure-stop.sh church-presentation-rg church-presenter-app

# Start before next service
./azure-start.sh church-presentation-rg church-presenter-app
```

**Savings Example** (B1 tier):
- 24/7 operation: $13.14/month
- Sunday only (3 hrs/week): $0.43/month
- **Saves**: $12.71/month (97% savings!)

### 3. Use Azure Automation for Scheduled Start/Stop
- Free for first 500 minutes/month
- Automatically start/stop on schedule
- Perfect for weekly services

### 4. Monitor Usage
```bash
# View metrics
az monitor metrics list \
  --resource $(az webapp show --resource-group $RESOURCE_GROUP --name $APP_NAME --query id -o tsv) \
  --metric "CpuTime" \
  --start-time 2025-10-01T00:00:00Z \
  --end-time 2025-10-31T23:59:59Z
```

### 5. Set Up Alerts
```bash
# Alert when app uses >80% of daily quota (Free tier)
az monitor metrics alert create \
  --name "church-app-quota-alert" \
  --resource-group $RESOURCE_GROUP \
  --scopes $(az webapp show --resource-group $RESOURCE_GROUP --name $APP_NAME --query id -o tsv) \
  --condition "avg CpuTime > 2880" \
  --description "Alert when app uses >80% of daily quota"
```

---

## Comparison: Local vs Azure

| Feature | Local Hosting | Azure (Free) | Azure (B1) |
|---------|--------------|--------------|------------|
| **Cost** | $0 (electricity only) | $0 | ~$1-13/month |
| **Internet Required** | No | Yes | Yes |
| **Setup Complexity** | Easy | Medium | Medium |
| **Remote Access** | WiFi only | Anywhere | Anywhere |
| **Reliability** | Your PC/network | Azure uptime | Azure uptime |
| **Maintenance** | Keep PC running | None | None |
| **Best For** | On-site services | Remote/hybrid | Production use |

---

## Recommendations by Church Size

### Small Church (< 50 people)
- **Local hosting** for Sunday services
- **Azure Free (F1)** for testing or backup
- **Cost**: $0

### Medium Church (50-200 people)
- **Local hosting** for primary use
- **Azure Free (F1)** for remote access
- **Cost**: $0

### Large Church (200+ people)
- **Azure Basic (B1)** for reliability
- **Use start/stop scripts** to minimize costs
- **Cost**: ~$2-6/month (with scheduled operation)

### Multi-Site Church
- **Azure Standard (S1)** for auto-scaling
- **Always on** for multiple services
- **Cost**: ~$69/month (justified by scale)

---

## Quick Reference Commands

### Deploy App
```bash
git push azure azure-deployment:master
```

### View Logs
```bash
az webapp log tail --resource-group <rg> --name <app>
```

### Restart App
```bash
az webapp restart --resource-group <rg> --name <app>
```

### Get App URL
```bash
az webapp show --resource-group <rg> --name <app> --query defaultHostName -o tsv
```

### Check App Status
```bash
az webapp show --resource-group <rg> --name <app> --query state -o tsv
```

### Delete Everything
```bash
az group delete --name <resource-group> --yes --no-wait
```

---

## Support

For issues specific to Azure deployment:
1. Check [Troubleshooting](#troubleshooting) section
2. View Azure logs: `az webapp log tail`
3. Azure documentation: https://docs.microsoft.com/azure/app-service/

For app-specific issues:
1. Check main [README.md](README.md)
2. Test locally first with `python server.py`

---

## Summary

✅ **Free Tier (F1)** is perfect for most churches  
✅ **60 minutes/day** is plenty for 2-3 hour services  
✅ **WebSocket support** works on all tiers  
✅ **Start/stop scripts** can reduce B1 costs by 90%+  
✅ **$0/month** is achievable for typical church use  

**Get Started**: Follow [Step-by-Step Deployment](#step-by-step-deployment-free-tier) above!

---

*Last updated: October 2025*
