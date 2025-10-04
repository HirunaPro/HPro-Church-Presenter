# Quick Start - Azure Deployment

Deploy your Church Presentation App to Azure in under 10 minutes!

## Prerequisites

- Azure account (sign up free: https://azure.microsoft.com/free/)
- Azure CLI installed (https://aka.ms/installazurecliwindows)
- This repository cloned locally

## One-Command Deployment

### Step 1: Login to Azure
```bash
az login
```

### Step 2: Run Deployment Script

**Windows (PowerShell):**
```powershell
# Coming soon - automated deployment script
```

**macOS/Linux (Bash):**
```bash
# Coming soon - automated deployment script
```

### Step 3: Manual Deployment (5 Minutes)

```bash
# 1. Set your variables
RESOURCE_GROUP="church-app-rg"
APP_NAME="my-church-app"  # Must be globally unique!
LOCATION="eastus"

# 2. Create everything
az group create --name $RESOURCE_GROUP --location $LOCATION

az appservice plan create \
  --name church-plan \
  --resource-group $RESOURCE_GROUP \
  --sku F1 \
  --is-linux

az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan church-plan \
  --name $APP_NAME \
  --runtime "PYTHON:3.11"

az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --web-sockets-enabled true \
  --startup-file "python server.py"

# 3. Deploy from local Git
git remote add azure https://$APP_NAME.scm.azurewebsites.net/$APP_NAME.git
git push azure azure-deployment:master

# 4. Get your URL
echo "Your app: https://$APP_NAME.azurewebsites.net"
```

## What You Get

✅ **Free hosting** (F1 tier = $0/month)  
✅ **HTTPS** enabled automatically  
✅ **WebSocket** support for real-time updates  
✅ **Global access** from anywhere  

## Access Your App

After deployment:
- **Landing page**: `https://YOUR-APP-NAME.azurewebsites.net/`
- **Operator**: `https://YOUR-APP-NAME.azurewebsites.net/operator.html`
- **Projector**: `https://YOUR-APP-NAME.azurewebsites.net/projector.html`

## Cost Management

### Use the Cost Calculator
```bash
python azure-cost-calculator.py
```

### Start/Stop Scripts (for paid tiers)
```bash
# Start before service
./azure-start.sh church-app-rg my-church-app

# Stop after service
./azure-stop.sh church-app-rg my-church-app
```

## Need Help?

See full guide: [AZURE-DEPLOYMENT.md](AZURE-DEPLOYMENT.md)

---

**Estimated deployment time**: 5-10 minutes  
**Cost**: $0 with Free Tier (F1)
