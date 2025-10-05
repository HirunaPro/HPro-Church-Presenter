#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy Church Presentation App to Azure Container Instances with WebSocket support
.DESCRIPTION
    Complete deployment script for Azure Container Instances
    - Supports WebSocket connections (ws://)
    - No quota issues like App Service
    - Pay-per-second pricing
    - Easy start/stop for cost optimization
.PARAMETER AppName
    Unique name for your application (e.g., "mychurch-presenter")
.PARAMETER ResourceGroup
    Azure resource group name (default: "church-presenter-rg")
.PARAMETER Location
    Azure region (default: "eastus")
.PARAMETER SkipBuild
    Skip Docker build if image already exists locally
.EXAMPLE
    .\deploy-azure-container.ps1 -AppName "mychurch-app"
.EXAMPLE
    .\deploy-azure-container.ps1 -AppName "mychurch-app" -Location "westus2" -SkipBuild
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$AppName,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "church-presenter-rg",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

# Banner
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Church Presentation App" -ForegroundColor Cyan
Write-Host "  Azure Container Instances Deployment" -ForegroundColor Cyan
Write-Host "  With Full WebSocket Support" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Prerequisites check
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Azure CLI not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Azure CLI installed" -ForegroundColor Green

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Write-Host "After installation, restart your computer and run this script again." -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Docker installed" -ForegroundColor Green

# Check if Docker is running
Write-Host "Checking if Docker is running..." -ForegroundColor Gray
$dockerRunning = $false
try {
    $dockerOutput = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        $dockerRunning = $true
    }
} catch {
    $dockerRunning = $false
}

if (-not $dockerRunning) {
    Write-Host "❌ Docker is not running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please follow these steps:" -ForegroundColor Yellow
    Write-Host "  1. Open Docker Desktop from the Start Menu" -ForegroundColor White
    Write-Host "  2. Wait for Docker to fully start (look for whale icon in system tray)" -ForegroundColor White
    Write-Host "  3. Verify with: docker ps" -ForegroundColor White
    Write-Host "  4. Run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "If Docker Desktop is not installed:" -ForegroundColor Yellow
    Write-Host "  Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor White
    Write-Host "  After installation, restart your computer" -ForegroundColor White
    Write-Host ""
    exit 1
}
Write-Host "✅ Docker is running" -ForegroundColor Green

Write-Host ""

# Get app name if not provided
if (-not $AppName) {
    $AppName = Read-Host "Enter your app name (lowercase, alphanumeric, e.g., 'mychurch-app')"
}

# Validate app name
$AppName = $AppName.ToLower() -replace '[^a-z0-9-]', ''
if ($AppName.Length -lt 3) {
    Write-Host "❌ App name must be at least 3 characters" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  App Name:       $AppName" -ForegroundColor White
Write-Host "  Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "  Location:       $Location" -ForegroundColor White
Write-Host ""
Write-Host "Features:" -ForegroundColor Green
Write-Host "  ✅ Full WebSocket support (ws://)" -ForegroundColor White
Write-Host "  ✅ HTTP + WebSocket on same container" -ForegroundColor White
Write-Host "  ✅ Public IP with DNS name" -ForegroundColor White
Write-Host "  ✅ No quota issues" -ForegroundColor White
Write-Host ""
Write-Host "Pricing (Pay-per-second):" -ForegroundColor Yellow
Write-Host "  1 vCPU + 1.5 GB RAM: ~`$0.0000133/second" -ForegroundColor White
Write-Host "  3-hour service:        ~`$0.14" -ForegroundColor White
Write-Host "  Weekly (Sun only):     ~`$0.57/month" -ForegroundColor White
Write-Host "  Weekly (Sun + Wed):    ~`$1.14/month" -ForegroundColor White
Write-Host "  💡 Stop when not in use to save money!" -ForegroundColor Green
Write-Host ""

$confirm = Read-Host "Continue with deployment? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Deployment cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting deployment..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Azure Login
Write-Host "[1/8] Checking Azure login..." -ForegroundColor Cyan
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "Logging in to Azure..." -ForegroundColor Yellow
    az login
    $account = az account show | ConvertFrom-Json
}
Write-Host "✅ Logged in as: $($account.user.name)" -ForegroundColor Green
Write-Host "   Subscription: $($account.name)" -ForegroundColor Gray
Write-Host ""

# Step 2: Create Resource Group
Write-Host "[2/8] Creating resource group..." -ForegroundColor Cyan
$rgExists = az group exists --name $ResourceGroup
if ($rgExists -eq "false") {
    az group create --name $ResourceGroup --location $Location --output none
    Write-Host "✅ Resource group created" -ForegroundColor Green
} else {
    Write-Host "✅ Resource group already exists" -ForegroundColor Green
}
Write-Host ""

# Step 3: Create Container Registry
Write-Host "[3/8] Creating Azure Container Registry..." -ForegroundColor Cyan
$acrName = $AppName -replace '[^a-zA-Z0-9]', ''
if ($acrName.Length -gt 50) { $acrName = $acrName.Substring(0, 50) }

$acrExists = az acr show --name $acrName --resource-group $ResourceGroup 2>$null
if (-not $acrExists) {
    az acr create `
        --resource-group $ResourceGroup `
        --name $acrName `
        --sku Basic `
        --admin-enabled true `
        --output none
    Write-Host "✅ Container Registry created: $acrName" -ForegroundColor Green
} else {
    Write-Host "✅ Container Registry already exists: $acrName" -ForegroundColor Green
}
Write-Host ""

# Step 4: Get ACR credentials
Write-Host "[4/8] Getting registry credentials..." -ForegroundColor Cyan
$acrLoginServer = az acr show --name $acrName --resource-group $ResourceGroup --query loginServer -o tsv
$acrUsername = az acr credential show --name $acrName --query username -o tsv
$acrPassword = az acr credential show --name $acrName --query "passwords[0].value" -o tsv
Write-Host "✅ Credentials retrieved" -ForegroundColor Green
Write-Host ""

# Step 5: Build Docker image
if (-not $SkipBuild) {
    Write-Host "[5/8] Building Docker image..." -ForegroundColor Cyan
    Write-Host "   This may take a few minutes on first build..." -ForegroundColor Gray
    
    docker build -t "${AppName}:latest" .
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Docker build failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Docker image built" -ForegroundColor Green
} else {
    Write-Host "[5/8] Skipping Docker build (using existing image)" -ForegroundColor Yellow
}
Write-Host ""

# Step 6: Login to ACR and push image
Write-Host "[6/8] Pushing image to Azure Container Registry..." -ForegroundColor Cyan
az acr login --name $acrName --output none

$imageTag = "${acrLoginServer}/${AppName}:latest"
docker tag "${AppName}:latest" $imageTag
docker push $imageTag

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to push image" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Image pushed to registry" -ForegroundColor Green
Write-Host ""

# Step 7: Delete existing container if it exists
Write-Host "[7/8] Checking for existing container..." -ForegroundColor Cyan
$existingContainer = az container show --name $AppName --resource-group $ResourceGroup 2>$null
if ($existingContainer) {
    Write-Host "   Deleting existing container..." -ForegroundColor Yellow
    az container delete --name $AppName --resource-group $ResourceGroup --yes --output none
    Write-Host "✅ Existing container deleted" -ForegroundColor Green
    Write-Host "   Waiting for resources to be freed..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
} else {
    Write-Host "✅ No existing container found" -ForegroundColor Green
}
Write-Host ""

# Step 8: Create Container Instance with WebSocket support
Write-Host "[8/8] Creating Azure Container Instance..." -ForegroundColor Cyan
Write-Host "   Configuring HTTP (8080) and WebSocket (8765) ports..." -ForegroundColor Gray

az container create `
    --resource-group $ResourceGroup `
    --name $AppName `
    --image $imageTag `
    --os-type Linux `
    --registry-login-server $acrLoginServer `
    --registry-username $acrUsername `
    --registry-password $acrPassword `
    --dns-name-label $AppName `
    --ports 8080 8765 `
    --protocol TCP `
    --cpu 1 `
    --memory 1.5 `
    --environment-variables `
        PORT=8080 `
        HTTP_PORT=8080 `
        WEBSOCKET_PORT=8765 `
    --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create container instance" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Container instance created" -ForegroundColor Green
Write-Host ""

# Get container FQDN
Write-Host "Getting container details..." -ForegroundColor Cyan
$fqdn = az container show `
    --resource-group $ResourceGroup `
    --name $AppName `
    --query ipAddress.fqdn -o tsv

$publicIP = az container show `
    --resource-group $ResourceGroup `
    --name $AppName `
    --query ipAddress.ip -o tsv

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✅ DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your application is running at:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  🌐 HTTP:  http://${fqdn}:8080" -ForegroundColor White
Write-Host "  🔌 WebSocket: ws://${fqdn}:8765" -ForegroundColor White
Write-Host "  📍 Public IP: $publicIP" -ForegroundColor Gray
Write-Host ""
Write-Host "Application URLs:" -ForegroundColor Cyan
Write-Host "  🏠 Landing:   http://${fqdn}:8080/index.html" -ForegroundColor White
Write-Host "  🎮 Operator:  http://${fqdn}:8080/operator.html" -ForegroundColor White
Write-Host "  📺 Projector: http://${fqdn}:8080/projector.html" -ForegroundColor White
Write-Host ""
Write-Host "Management Commands:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Stop container (save money):" -ForegroundColor Red
Write-Host "    az container stop --resource-group $ResourceGroup --name $AppName" -ForegroundColor Gray
Write-Host ""
Write-Host "  Start container:" -ForegroundColor Green
Write-Host "    az container start --resource-group $ResourceGroup --name $AppName" -ForegroundColor Gray
Write-Host ""
Write-Host "  View logs:" -ForegroundColor Cyan
Write-Host "    az container logs --resource-group $ResourceGroup --name $AppName --follow" -ForegroundColor Gray
Write-Host ""
Write-Host "  Check status:" -ForegroundColor Cyan
Write-Host "    az container show --resource-group $ResourceGroup --name $AppName --query instanceView.state -o tsv" -ForegroundColor Gray
Write-Host ""
Write-Host "  Delete container:" -ForegroundColor Red
Write-Host "    az container delete --resource-group $ResourceGroup --name $AppName --yes" -ForegroundColor Gray
Write-Host ""
Write-Host "Cost Optimization:" -ForegroundColor Yellow
Write-Host "  💰 Current pricing: ~`$0.0000133/second when running" -ForegroundColor White
Write-Host "  💡 Stop when not in use to avoid charges!" -ForegroundColor Green
Write-Host "  📊 Monthly cost (3hr/week): ~`$0.57/month" -ForegroundColor White
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Create helper scripts
Write-Host "Creating helper scripts..." -ForegroundColor Cyan

# Start script
@"
#!/usr/bin/env pwsh
# Start the Azure Container Instance

Write-Host "Starting container: $AppName" -ForegroundColor Green
az container start --resource-group $ResourceGroup --name $AppName

Write-Host ""
Write-Host "✅ Container started!" -ForegroundColor Green
Write-Host ""
Write-Host "Application URLs:" -ForegroundColor Cyan
Write-Host "  http://${fqdn}:8080/index.html" -ForegroundColor White
Write-Host "  http://${fqdn}:8080/operator.html" -ForegroundColor White
Write-Host "  http://${fqdn}:8080/projector.html" -ForegroundColor White
Write-Host ""
"@ | Out-File -FilePath "start-container.ps1" -Encoding utf8

# Stop script
@"
#!/usr/bin/env pwsh
# Stop the Azure Container Instance to save money

Write-Host "Stopping container: $AppName" -ForegroundColor Yellow
az container stop --resource-group $ResourceGroup --name $AppName

Write-Host ""
Write-Host "✅ Container stopped!" -ForegroundColor Green
Write-Host "💰 You are no longer being charged for this container." -ForegroundColor Green
Write-Host ""
"@ | Out-File -FilePath "stop-container.ps1" -Encoding utf8

# Logs script
@"
#!/usr/bin/env pwsh
# View container logs

Write-Host "Fetching logs for: $AppName" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to exit" -ForegroundColor Gray
Write-Host ""
az container logs --resource-group $ResourceGroup --name $AppName --follow
"@ | Out-File -FilePath "view-logs.ps1" -Encoding utf8

# Status script
@"
#!/usr/bin/env pwsh
# Check container status

Write-Host "Checking status for: $AppName" -ForegroundColor Cyan
Write-Host ""

`$status = az container show --resource-group $ResourceGroup --name $AppName --query instanceView.state -o tsv
`$ip = az container show --resource-group $ResourceGroup --name $AppName --query ipAddress.ip -o tsv

Write-Host "Status: `$status" -ForegroundColor $(if (`$status -eq "Running") { "Green" } else { "Yellow" })
Write-Host "IP: `$ip" -ForegroundColor White
Write-Host "URL: http://${fqdn}:8080" -ForegroundColor Cyan
Write-Host ""
"@ | Out-File -FilePath "check-status.ps1" -Encoding utf8

Write-Host "✅ Helper scripts created:" -ForegroundColor Green
Write-Host "   - start-container.ps1" -ForegroundColor Gray
Write-Host "   - stop-container.ps1" -ForegroundColor Gray
Write-Host "   - view-logs.ps1" -ForegroundColor Gray
Write-Host "   - check-status.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "Deployment complete! 🎉" -ForegroundColor Green
Write-Host ""
