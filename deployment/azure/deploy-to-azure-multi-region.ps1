# PowerShell deployment script - Try multiple regions to find one with quota
# This script will try different regions until it finds one that works

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Church Presentation App - Azure Deploy" -ForegroundColor Cyan
Write-Host "  Multi-Region Auto-Deploy (B1 Tier)" -ForegroundColor Cyan
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

# List of regions to try (ordered by likelihood of having quota)
$REGIONS = @(
    "southcentralus",
    "westus2",
    "westus3",
    "westeurope",
    "northeurope",
    "southeastasia",
    "australiaeast",
    "uksouth",
    "canadacentral",
    "centralindia"
)

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  App Name:       $APP_NAME"
Write-Host "  Resource Group: $RESOURCE_GROUP"
Write-Host "  Pricing Tier:   Basic B1 - ~`$13/month (or less with start/stop)" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 This script will try multiple regions to find available quota" -ForegroundColor Yellow
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
} catch {
    Write-Host "❌ Failed to login to Azure" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Try each region
$SUCCESS = $false
$LOCATION = ""

foreach ($region in $REGIONS) {
    Write-Host "🌍 Trying region: $region" -ForegroundColor Yellow
    
    # Create resource group
    Write-Host "   📦 Creating resource group..." -ForegroundColor Gray
    try {
        $rg = az group show --name $RESOURCE_GROUP 2>$null | ConvertFrom-Json
        if ($rg) {
            Write-Host "   Deleting existing resource group..." -ForegroundColor Gray
            az group delete --name $RESOURCE_GROUP --yes --no-wait
            Start-Sleep -Seconds 30
        }
    } catch {
        # Resource group doesn't exist, continue
    }
    
    az group create --name $RESOURCE_GROUP --location $region --output none
    
    # Try to create App Service Plan
    Write-Host "   📋 Creating App Service Plan in $region..." -ForegroundColor Gray
    $PLAN_NAME = "church-plan-$(Get-Random)"
    
    $planResult = az appservice plan create `
      --name $PLAN_NAME `
      --resource-group $RESOURCE_GROUP `
      --location $region `
      --sku B1 `
      --is-linux `
      --output json 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Success! Found available quota in $region" -ForegroundColor Green
        $SUCCESS = $true
        $LOCATION = $region
        break
    } else {
        Write-Host "   ❌ No quota in $region, trying next..." -ForegroundColor Red
        # Clean up failed resource group
        az group delete --name $RESOURCE_GROUP --yes --no-wait 2>$null
    }
    
    Write-Host ""
}

if (-not $SUCCESS) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Red
    Write-Host "  ❌ NO AVAILABLE QUOTA FOUND" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "None of the tested regions have available App Service quota." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Next Steps:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1️⃣  Request Quota Increase (RECOMMENDED):" -ForegroundColor Green
    Write-Host "   - Go to: https://portal.azure.com"
    Write-Host "   - Search: 'Quotas' or 'Support'"
    Write-Host "   - Request: Basic App Service Plan quota"
    Write-Host "   - Wait: 1-2 business days"
    Write-Host ""
    Write-Host "2️⃣  Try a Different Subscription:" -ForegroundColor Yellow
    Write-Host "   - Some subscriptions have restrictions"
    Write-Host "   - Try Pay-As-You-Go or Azure for Students"
    Write-Host ""
    Write-Host "3️⃣  Alternative: Azure Container Instances:" -ForegroundColor Cyan
    Write-Host "   - Uses different quota"
    Write-Host "   - Pay-per-use pricing (~`$1-2/month for church use)"
    Write-Host "   - Let me know if you want deployment scripts for this"
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✅ App Service Plan Created!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Region: $LOCATION" -ForegroundColor Cyan
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
Write-Host "📍 Deployed to region: $LOCATION" -ForegroundColor Cyan
Write-Host ""
Write-Host "💰 Cost Management (IMPORTANT!):" -ForegroundColor Yellow
Write-Host "   Your app is running on Basic B1 tier (`$13.14/month if left running 24/7)"
Write-Host ""
Write-Host "   ⭐ To save 97% of costs, stop the app when not in use:"
Write-Host ""
Write-Host "   🛑 Stop after service:" -ForegroundColor Red
Write-Host "      .\azure-stop.ps1 -ResourceGroup $RESOURCE_GROUP -AppName $APP_NAME"
Write-Host ""
Write-Host "   ▶️  Start before service:" -ForegroundColor Green
Write-Host "      .\azure-start.ps1 -ResourceGroup $RESOURCE_GROUP -AppName $APP_NAME"
Write-Host ""
Write-Host "   💡 Running only on Sundays (3 hours/week) = `$0.43/month!" -ForegroundColor Green
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
