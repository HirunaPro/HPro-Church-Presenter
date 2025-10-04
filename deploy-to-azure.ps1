# PowerShell deployment script for Azure App Service
# This script will deploy your Church Presentation App to Azure Free Tier

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Church Presentation App - Azure Deploy" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Azure CLI not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Azure CLI first:"
    Write-Host "  Download: https://aka.ms/installazurecliwindows"
    Write-Host ""
    exit 1
}

Write-Host "✅ Azure CLI found" -ForegroundColor Green
Write-Host ""

# Get user input
$APP_NAME = Read-Host "Enter your app name (must be globally unique, e.g., 'mychurch-presenter')"
$RESOURCE_GROUP = Read-Host "Enter resource group name (default: church-presenter-rg)"
if ([string]::IsNullOrWhiteSpace($RESOURCE_GROUP)) { $RESOURCE_GROUP = "church-presenter-rg" }

$LOCATION = Read-Host "Enter Azure region (default: eastus)"
if ([string]::IsNullOrWhiteSpace($LOCATION)) { $LOCATION = "eastus" }

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  App Name:       $APP_NAME"
Write-Host "  Resource Group: $RESOURCE_GROUP"
Write-Host "  Location:       $LOCATION"
Write-Host "  Pricing Tier:   Free (F1) - `$0/month"
Write-Host ""

$CONFIRM = Read-Host "Proceed with deployment? (y/n)"
if ($CONFIRM -ne "y") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting deployment..." -ForegroundColor Cyan
Write-Host ""

# Login to Azure
Write-Host "📝 Checking Azure login status..." -ForegroundColor Cyan
try {
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Host "Please login to Azure..." -ForegroundColor Yellow
        az login
    }
    
    # List available subscriptions
    Write-Host ""
    Write-Host "Available subscriptions:" -ForegroundColor Cyan
    $subscriptions = az account list --query "[].{Name:name, ID:id, Default:isDefault}" -o table
    Write-Host $subscriptions
    Write-Host ""
    
    # Prompt for subscription selection
    $subscriptionId = Read-Host "Enter the Subscription ID you want to use (or press Enter to use default)"
    
    if (-not [string]::IsNullOrWhiteSpace($subscriptionId)) {
        Write-Host "Setting subscription to: $subscriptionId" -ForegroundColor Cyan
        az account set --subscription $subscriptionId
    }
    
    # Get current account info
    $account = az account show | ConvertFrom-Json
    Write-Host "✅ Logged in to Azure" -ForegroundColor Green
    Write-Host "   Active Subscription: $($account.name)" -ForegroundColor Gray
    Write-Host "   Tenant ID: $($account.tenantId)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed to login to Azure" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Register required resource providers
Write-Host "📝 Checking required resource providers..." -ForegroundColor Cyan
$providers = @('Microsoft.Web', 'Microsoft.Storage', 'Microsoft.Network')

foreach ($provider in $providers) {
    $status = az provider show --namespace $provider --query "registrationState" -o tsv 2>$null
    
    if ($status -ne "Registered") {
        Write-Host "   Registering $provider..." -ForegroundColor Yellow
        az provider register --namespace $provider --wait
        Write-Host "   ✅ $provider registered" -ForegroundColor Green
    } else {
        Write-Host "   ✅ $provider already registered" -ForegroundColor Gray
    }
}
Write-Host ""

# Create resource group
Write-Host "📦 Creating resource group..." -ForegroundColor Cyan
try {
    $rg = az group show --name $RESOURCE_GROUP 2>$null | ConvertFrom-Json
    if ($rg) {
        Write-Host "   Resource group already exists, using it" -ForegroundColor Gray
    } else {
        az group create --name $RESOURCE_GROUP --location $LOCATION --output none
        Write-Host "✅ Resource group created" -ForegroundColor Green
    }
} catch {
    az group create --name $RESOURCE_GROUP --location $LOCATION --output none
    Write-Host "✅ Resource group created" -ForegroundColor Green
}
Write-Host ""

# Create App Service Plan
Write-Host "📋 Creating App Service Plan (Free Tier)..." -ForegroundColor Cyan
$PLAN_NAME = "church-plan-$(Get-Random)"

$planResult = az appservice plan create `
  --name $PLAN_NAME `
  --resource-group $RESOURCE_GROUP `
  --sku F1 `
  --is-linux `
  --output json 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create App Service Plan" -ForegroundColor Red
    Write-Host $planResult
    exit 1
}

Write-Host "✅ App Service Plan created" -ForegroundColor Green
Write-Host ""

# Create Web App
Write-Host "🌐 Creating Web App..." -ForegroundColor Cyan

$webappResult = az webapp create `
  --resource-group $RESOURCE_GROUP `
  --plan $PLAN_NAME `
  --name $APP_NAME `
  --runtime "PYTHON:3.11" `
  --output json 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create Web App" -ForegroundColor Red
    Write-Host $webappResult
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - App name '$APP_NAME' might already be taken (must be globally unique)"
    Write-Host "  - Try a different name like: $APP_NAME-$(Get-Random -Maximum 9999)"
    exit 1
}

Write-Host "✅ Web App created" -ForegroundColor Green
Write-Host ""

# Enable WebSocket
Write-Host "🔌 Enabling WebSocket support..." -ForegroundColor Cyan

$configResult = az webapp config set `
  --resource-group $RESOURCE_GROUP `
  --name $APP_NAME `
  --web-sockets-enabled true `
  --startup-file "python server.py" `
  --output json 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to enable WebSocket" -ForegroundColor Red
    Write-Host $configResult
    exit 1
}

Write-Host "✅ WebSocket enabled" -ForegroundColor Green
Write-Host ""

# Set up deployment
Write-Host "🚀 Setting up Git deployment..." -ForegroundColor Cyan
$DEPLOY_URL = az webapp deployment source config-local-git `
  --name $APP_NAME `
  --resource-group $RESOURCE_GROUP `
  --query url -o tsv

# Add Azure remote if it doesn't exist
$remotes = git remote
if ($remotes -contains "azure") {
    git remote remove azure
}

git remote add azure $DEPLOY_URL
Write-Host "✅ Git deployment configured" -ForegroundColor Green
Write-Host ""

# Push code
Write-Host "📤 Deploying your code to Azure..." -ForegroundColor Cyan
Write-Host "   This may take a few minutes..." -ForegroundColor Gray
Write-Host ""

git push azure azure-deployment:master

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✅ DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

$APP_URL = "https://$APP_NAME.azurewebsites.net"

Write-Host "Your app is now live at:" -ForegroundColor Cyan
Write-Host "  🏠 Landing page:  $APP_URL/" -ForegroundColor White
Write-Host "  🎮 Operator:      $APP_URL/operator.html" -ForegroundColor White
Write-Host "  📺 Projector:     $APP_URL/projector.html" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Yellow
Write-Host "  • App may take 30-60 seconds to start first time"
Write-Host "  • Free tier sleeps after 20 min - first request wakes it"
Write-Host "  • Cost: `$0/month (Free F1 tier)"
Write-Host ""
Write-Host "📊 To check costs anytime:" -ForegroundColor Cyan
Write-Host "  python azure-cost-calculator.py"
Write-Host ""
Write-Host "🛑 To stop the app (saves money on paid tiers):" -ForegroundColor Cyan
Write-Host "  .\azure-stop.ps1 -ResourceGroup $RESOURCE_GROUP -AppName $APP_NAME"
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
