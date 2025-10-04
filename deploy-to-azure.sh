#!/bin/bash
# Quick deployment script for Azure App Service
# This script will deploy your Church Presentation App to Azure Free Tier

set -e

echo "=========================================="
echo "  Church Presentation App - Azure Deploy"
echo "=========================================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found!"
    echo ""
    echo "Please install Azure CLI first:"
    echo "  Windows: https://aka.ms/installazurecliwindows"
    echo "  macOS:   brew install azure-cli"
    echo "  Linux:   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    echo ""
    exit 1
fi

echo "✅ Azure CLI found"
echo ""

# Get user input
read -p "Enter your app name (must be globally unique, e.g., 'mychurch-presenter'): " APP_NAME
read -p "Enter resource group name (default: church-presenter-rg): " RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-church-presenter-rg}
read -p "Enter Azure region (default: eastus): " LOCATION
LOCATION=${LOCATION:-eastus}

echo ""
echo "Configuration:"
echo "  App Name:       $APP_NAME"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location:       $LOCATION"
echo "  Pricing Tier:   Free (F1) - $0/month"
echo ""
read -p "Proceed with deployment? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "Starting deployment..."
echo ""

# Login to Azure
echo "📝 Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo "Please login to Azure..."
    az login
fi

# List available subscriptions
echo ""
echo "Available subscriptions:"
az account list --query "[].{Name:name, ID:id, Default:isDefault}" -o table
echo ""

# Prompt for subscription selection
read -p "Enter the Subscription ID you want to use (or press Enter to use default): " SUBSCRIPTION_ID

if [ -n "$SUBSCRIPTION_ID" ]; then
    echo "Setting subscription to: $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"
fi

# Get current subscription info
echo "✅ Logged in to Azure"
SUBSCRIPTION=$(az account show --query name -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "   Active Subscription: $SUBSCRIPTION"
echo "   Tenant ID: $TENANT_ID"
echo ""

# Create resource group
echo "📦 Creating resource group..."
if az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo "   Resource group already exists, using it"
else
    az group create --name $RESOURCE_GROUP --location $LOCATION --output none
    echo "✅ Resource group created"
fi
echo ""

# Create App Service Plan
echo "📋 Creating App Service Plan (Free Tier)..."
PLAN_NAME="church-plan-$RANDOM"
az appservice plan create \
  --name $PLAN_NAME \
  --resource-group $RESOURCE_GROUP \
  --sku F1 \
  --is-linux \
  --output none

echo "✅ App Service Plan created"
echo ""

# Create Web App
echo "🌐 Creating Web App..."
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $PLAN_NAME \
  --name $APP_NAME \
  --runtime "PYTHON:3.11" \
  --output none

echo "✅ Web App created"
echo ""

# Enable WebSocket
echo "🔌 Enabling WebSocket support..."
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --web-sockets-enabled true \
  --startup-file "python server.py" \
  --output none

echo "✅ WebSocket enabled"
echo ""

# Set up deployment
echo "🚀 Setting up Git deployment..."
DEPLOY_URL=$(az webapp deployment source config-local-git \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query url -o tsv)

# Add Azure remote if it doesn't exist
if git remote | grep -q "^azure$"; then
    git remote remove azure
fi

git remote add azure $DEPLOY_URL
echo "✅ Git deployment configured"
echo ""

# Push code
echo "📤 Deploying your code to Azure..."
echo "   This may take a few minutes..."
echo ""

git push azure azure-deployment:master

echo ""
echo "=========================================="
echo "  ✅ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""

APP_URL="https://$APP_NAME.azurewebsites.net"

echo "Your app is now live at:"
echo "  🏠 Landing page:  $APP_URL/"
echo "  🎮 Operator:      $APP_URL/operator.html"
echo "  📺 Projector:     $APP_URL/projector.html"
echo ""
echo "💡 Tips:"
echo "  • App may take 30-60 seconds to start first time"
echo "  • Free tier sleeps after 20 min - first request wakes it"
echo "  • Cost: $0/month (Free F1 tier)"
echo ""
echo "📊 To check costs anytime:"
echo "  python azure-cost-calculator.py"
echo ""
echo "🛑 To stop the app (saves money on paid tiers):"
echo "  ./azure-stop.sh $RESOURCE_GROUP $APP_NAME"
echo ""
echo "=========================================="
