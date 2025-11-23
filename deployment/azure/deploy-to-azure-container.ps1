# PowerShell deployment script for Azure Container Instances
# Alternative to App Service - uses different quota, often works when App Service quota unavailable
# Cost: Pay-per-use (~$0.000024/second when running)
#   - 3-hour service: ~$0.26
#   - Monthly (Sundays only): ~$1.04/month
#   - Monthly (Sun + Wed): ~$2.08/month

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Church Presentation App - Azure Deploy" -ForegroundColor Cyan
Write-Host "  Using Container Instances (Pay-per-use)" -ForegroundColor Cyan
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

# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Docker Desktop first:"
    Write-Host "  Download: https://www.docker.com/products/docker-desktop"
    Write-Host ""
    Write-Host "After installing, restart your computer and run this script again."
    exit 1
}

Write-Host "✅ Azure CLI found" -ForegroundColor Green
Write-Host "✅ Docker found" -ForegroundColor Green
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
Write-Host "  Pricing:        Pay-per-use (Azure Container Instances)" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Cost Estimate:" -ForegroundColor Yellow
Write-Host "   - Per second running: `$0.000024"
Write-Host "   - 3-hour Sunday service: `$0.26"
Write-Host "   - Monthly (Sundays only): `$1.04/month  ⭐"
Write-Host "   - Monthly (Sun + Wed): `$2.08/month"
Write-Host ""
Write-Host "   ✅ Only pay when container is running!" -ForegroundColor Green
Write-Host "   ✅ No quota issues like App Service" -ForegroundColor Green
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
    
    $account = az account show | ConvertFrom-Json
    Write-Host "✅ Logged in to Azure" -ForegroundColor Green
    Write-Host "   Active Subscription: $($account.name)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "❌ Failed to login to Azure" -ForegroundColor Red
    exit 1
}

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

# Create Container Registry
Write-Host "📦 Creating Azure Container Registry..." -ForegroundColor Cyan
$ACR_NAME = $APP_NAME -replace '[^a-zA-Z0-9]', ''  # Remove special chars
if ($ACR_NAME.Length -gt 50) {
    $ACR_NAME = $ACR_NAME.Substring(0, 50)
}

$acrResult = az acr create `
  --resource-group $RESOURCE_GROUP `
  --name $ACR_NAME `
  --sku Basic `
  --admin-enabled true `
  --output json 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create Container Registry" -ForegroundColor Red
    Write-Host $acrResult
    Write-Host ""
    Write-Host "The name '$ACR_NAME' might be taken. Try a different app name." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Container Registry created" -ForegroundColor Green
Write-Host ""

# Get ACR credentials
Write-Host "🔑 Getting registry credentials..." -ForegroundColor Cyan
$ACR_LOGIN_SERVER = az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query loginServer -o tsv
$ACR_USERNAME = az acr credential show --name $ACR_NAME --query username -o tsv
$ACR_PASSWORD = az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv

Write-Host "✅ Credentials retrieved" -ForegroundColor Green
Write-Host ""

# Create Dockerfile if it doesn't exist
if (-not (Test-Path "Dockerfile")) {
    Write-Host "📝 Creating Dockerfile..." -ForegroundColor Cyan
    @"
FROM python:3.11-slim

WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Expose port
EXPOSE 8080

# Run the application
CMD ["python", "server.py"]
"@ | Out-File -FilePath "Dockerfile" -Encoding utf8
    Write-Host "✅ Dockerfile created" -ForegroundColor Green
} else {
    Write-Host "✅ Dockerfile already exists" -ForegroundColor Gray
}
Write-Host ""

# Build Docker image
Write-Host "🔨 Building Docker image..." -ForegroundColor Cyan
Write-Host "   This may take a few minutes..." -ForegroundColor Gray

docker build -t ${APP_NAME}:latest .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build Docker image" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker image built" -ForegroundColor Green
Write-Host ""

# Login to ACR
Write-Host "🔐 Logging into Azure Container Registry..." -ForegroundColor Cyan
az acr login --name $ACR_NAME

Write-Host "✅ Logged into ACR" -ForegroundColor Green
Write-Host ""

# Tag and push image
Write-Host "📤 Pushing image to Azure Container Registry..." -ForegroundColor Cyan
Write-Host "   This may take several minutes..." -ForegroundColor Gray

$IMAGE_TAG = "$ACR_LOGIN_SERVER/${APP_NAME}:latest"
docker tag ${APP_NAME}:latest $IMAGE_TAG
docker push $IMAGE_TAG

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to push image" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Image pushed successfully" -ForegroundColor Green
Write-Host ""

# Create Container Instance
Write-Host "🚀 Creating Azure Container Instance..." -ForegroundColor Cyan

$containerResult = az container create `
  --resource-group $RESOURCE_GROUP `
  --name $APP_NAME `
  --image $IMAGE_TAG `
  --registry-login-server $ACR_LOGIN_SERVER `
  --registry-username $ACR_USERNAME `
  --registry-password $ACR_PASSWORD `
  --dns-name-label $APP_NAME `
  --ports 8080 `
  --cpu 1 `
  --memory 1 `
  --environment-variables PORT=8080 `
  --output json 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create Container Instance" -ForegroundColor Red
    Write-Host $containerResult
    exit 1
}

Write-Host "✅ Container Instance created" -ForegroundColor Green
Write-Host ""

# Get container FQDN
$FQDN = az container show `
  --resource-group $RESOURCE_GROUP `
  --name $APP_NAME `
  --query ipAddress.fqdn -o tsv

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✅ DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

$APP_URL = "http://${FQDN}:8080"

Write-Host "Your app is now live at:" -ForegroundColor Cyan
Write-Host "  🏠 Landing page:  $APP_URL/" -ForegroundColor White
Write-Host "  🎮 Operator:      $APP_URL/operator.html" -ForegroundColor White
Write-Host "  📺 Projector:     $APP_URL/projector.html" -ForegroundColor White
Write-Host ""
Write-Host "💰 Cost Management:" -ForegroundColor Yellow
Write-Host "   You're using Azure Container Instances (pay-per-use)"
Write-Host "   You only pay when the container is running!"
Write-Host ""
Write-Host "   🛑 Stop container when not in use:" -ForegroundColor Red
Write-Host "      az container stop --resource-group $RESOURCE_GROUP --name $APP_NAME"
Write-Host ""
Write-Host "   ▶️  Start container before service:" -ForegroundColor Green
Write-Host "      az container start --resource-group $RESOURCE_GROUP --name $APP_NAME"
Write-Host ""
Write-Host "   📊 Check container status:" -ForegroundColor Cyan
Write-Host "      az container show --resource-group $RESOURCE_GROUP --name $APP_NAME --query instanceView.state -o tsv"
Write-Host ""
Write-Host "   💡 Estimated costs:" -ForegroundColor Green
Write-Host "      - 3 hours/week (Sundays): `$1.04/month"
Write-Host "      - 6 hours/week (Sun+Wed): `$2.08/month"
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan

# Create helper scripts
Write-Host ""
Write-Host "📝 Creating helper scripts..." -ForegroundColor Cyan

# Container start script
@"
# Start Azure Container Instance
param(
    [string]`$ResourceGroup = "$RESOURCE_GROUP",
    [string]`$ContainerName = "$APP_NAME"
)

Write-Host "▶️  Starting container..." -ForegroundColor Green
az container start --resource-group `$ResourceGroup --name `$ContainerName

Write-Host "✅ Container started!" -ForegroundColor Green
Write-Host "App URL: $APP_URL"
"@ | Out-File -FilePath "azure-container-start.ps1" -Encoding utf8

# Container stop script
@"
# Stop Azure Container Instance
param(
    [string]`$ResourceGroup = "$RESOURCE_GROUP",
    [string]`$ContainerName = "$APP_NAME"
)

Write-Host "🛑 Stopping container..." -ForegroundColor Red
az container stop --resource-group `$ResourceGroup --name `$ContainerName

Write-Host "✅ Container stopped!" -ForegroundColor Green
Write-Host "💰 You are no longer being charged!"
"@ | Out-File -FilePath "azure-container-stop.ps1" -Encoding utf8

Write-Host "✅ Helper scripts created:" -ForegroundColor Green
Write-Host "   - azure-container-start.ps1"
Write-Host "   - azure-container-stop.ps1"
Write-Host ""
