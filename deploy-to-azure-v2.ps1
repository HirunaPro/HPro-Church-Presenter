#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy Church Presentation App to Azure App Service

.DESCRIPTION
    Modern deployment script with multiple deployment methods:
    - Git-based deployment (local or GitHub)
    - ZIP deployment (fastest)
    - Container deployment (most flexible)
    
    Supports Free (F1), Basic (B1), and Standard (S1) tiers with cost optimization.

.PARAMETER AppName
    Globally unique name for your Azure Web App

.PARAMETER ResourceGroup
    Name of the Azure Resource Group (default: church-presenter-rg)

.PARAMETER Location
    Azure region (default: eastus)

.PARAMETER Tier
    Pricing tier: Free, Basic, or Standard (default: Free)

.PARAMETER DeploymentMethod
    Deployment method: git, zip, or github (default: zip)

.EXAMPLE
    .\deploy-to-azure-v2.ps1 -AppName "mychurch-app" -Tier Free -DeploymentMethod zip

.NOTES
    Author: Church Presenter Team
    Version: 2.0
    Last Updated: October 2025
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$AppName,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "church-presenter-rg",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('eastus', 'westus', 'westus2', 'centralus', 'northeurope', 'westeurope', 'southeastasia')]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Free', 'Basic', 'Standard')]
    [string]$Tier = "Free",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('git', 'zip', 'github')]
    [string]$DeploymentMethod = "zip"
)

# Script configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Color output functions
function Write-Header {
    param([string]$Message)
    Write-Host "`n$('='*70)" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "$('='*70)`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

function Write-Warning2 {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error2 {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n📍 $Message" -ForegroundColor Cyan
}

# Main script
try {
    Write-Header "Church Presentation App - Azure Deployment v2.0"
    
    # Check prerequisites
    Write-Step "Checking prerequisites..."
    
    # Check Azure CLI
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Error2 "Azure CLI not found!"
        Write-Host "`nPlease install Azure CLI first:"
        Write-Host "  Download: https://aka.ms/installazurecliwindows"
        Write-Host "  Or run: winget install Microsoft.AzureCLI`n"
        exit 1
    }
    Write-Success "Azure CLI installed"
    
    # Check Git (for git deployment)
    if ($DeploymentMethod -eq 'git' -or $DeploymentMethod -eq 'github') {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-Error2 "Git not found but required for $DeploymentMethod deployment!"
            Write-Host "`nPlease install Git: https://git-scm.com/downloads`n"
            exit 1
        }
        Write-Success "Git installed"
    }
    
    # Get app name if not provided
    if ([string]::IsNullOrWhiteSpace($AppName)) {
        Write-Host "`nℹ️  App name must be globally unique across Azure" -ForegroundColor Blue
        $AppName = Read-Host "Enter your app name (e.g., 'mychurch-presenter-$(Get-Random -Maximum 9999)')"
        
        if ([string]::IsNullOrWhiteSpace($AppName)) {
            Write-Error2 "App name is required!"
            exit 1
        }
    }
    
    # Validate app name
    if ($AppName -notmatch '^[a-z0-9][a-z0-9-]{0,58}[a-z0-9]$') {
        Write-Error2 "Invalid app name! Must be 2-60 characters, lowercase letters, numbers, and hyphens only"
        exit 1
    }
    
    # Display configuration
    Write-Host "`n" + "="*70
    Write-Host "  DEPLOYMENT CONFIGURATION" -ForegroundColor Cyan
    Write-Host "="*70
    Write-Host "  App Name:          $AppName" -ForegroundColor White
    Write-Host "  Resource Group:    $ResourceGroup" -ForegroundColor White
    Write-Host "  Location:          $Location" -ForegroundColor White
    Write-Host "  Pricing Tier:      $Tier" -ForegroundColor White
    Write-Host "  Deployment Method: $DeploymentMethod" -ForegroundColor White
    
    # Show pricing info
    Write-Host "`n  PRICING:" -ForegroundColor Yellow
    switch ($Tier) {
        "Free" {
            Write-Host "    💰 Cost: `$0/month" -ForegroundColor Green
            Write-Host "    ⏱️  Compute: 60 minutes/day" -ForegroundColor Gray
            Write-Host "    💤 Sleeps after 20 min inactivity" -ForegroundColor Gray
        }
        "Basic" {
            Write-Host "    💰 Cost: ~`$13/month (or less with start/stop)" -ForegroundColor Yellow
            Write-Host "    ⏱️  Compute: Unlimited" -ForegroundColor Gray
            Write-Host "    ✅ Always On available" -ForegroundColor Gray
        }
        "Standard" {
            Write-Host "    💰 Cost: ~`$69/month" -ForegroundColor Red
            Write-Host "    ⏱️  Compute: Unlimited" -ForegroundColor Gray
            Write-Host "    🚀 Auto-scaling, SSL, custom domain" -ForegroundColor Gray
        }
    }
    Write-Host "="*70 -ForegroundColor Cyan
    
    Write-Host ""
    $confirm = Read-Host "Proceed with deployment? (y/n)"
    if ($confirm -ne 'y') {
        Write-Warning2 "Deployment cancelled by user"
        exit 0
    }
    
    # Azure login
    Write-Step "Checking Azure authentication..."
    try {
        $account = az account show 2>$null | ConvertFrom-Json
        if (-not $account) {
            throw "Not logged in"
        }
        Write-Success "Already logged in to Azure"
    }
    catch {
        Write-Info "Please login to Azure..."
        az login
        if ($LASTEXITCODE -ne 0) {
            Write-Error2 "Failed to login to Azure"
            exit 1
        }
    }
    
    # Show subscriptions and select
    Write-Host ""
    Write-Info "Available Azure subscriptions:"
    $subscriptions = az account list --query "[].{Name:name, ID:id, State:state}" -o json | ConvertFrom-Json
    
    for ($i = 0; $i -lt $subscriptions.Count; $i++) {
        $sub = $subscriptions[$i]
        $marker = ""
        $currentSub = az account show --query id -o tsv
        if ($sub.ID -eq $currentSub) {
            $marker = " (current)"
        }
        Write-Host "  [$($i+1)] $($sub.Name) - $($sub.State)$marker" -ForegroundColor White
    }
    
    Write-Host ""
    $subChoice = Read-Host "Select subscription [1-$($subscriptions.Count)] or press Enter for current"
    
    if (-not [string]::IsNullOrWhiteSpace($subChoice)) {
        $subIndex = [int]$subChoice - 1
        if ($subIndex -ge 0 -and $subIndex -lt $subscriptions.Count) {
            $selectedSub = $subscriptions[$subIndex]
            Write-Info "Setting subscription to: $($selectedSub.Name)"
            az account set --subscription $selectedSub.ID
        }
    }
    
    $currentAccount = az account show | ConvertFrom-Json
    Write-Success "Using subscription: $($currentAccount.name)"
    
    # Register resource providers
    Write-Step "Registering required Azure resource providers..."
    $providers = @('Microsoft.Web', 'Microsoft.Storage', 'Microsoft.Network')
    
    foreach ($provider in $providers) {
        $status = az provider show --namespace $provider --query "registrationState" -o tsv 2>$null
        
        if ($status -ne "Registered") {
            Write-Info "Registering $provider..."
            az provider register --namespace $provider --wait 2>&1 | Out-Null
            Write-Success "$provider registered"
        }
        else {
            Write-Host "  ✓ $provider already registered" -ForegroundColor Gray
        }
    }
    
    # Create resource group
    Write-Step "Creating resource group..."
    $rgExists = az group exists --name $ResourceGroup
    
    if ($rgExists -eq "true") {
        Write-Info "Resource group '$ResourceGroup' already exists"
    }
    else {
        az group create --name $ResourceGroup --location $Location --output none
        Write-Success "Resource group created"
    }
    
    # Map tier to SKU
    $sku = switch ($Tier) {
        "Free"     { "F1" }
        "Basic"    { "B1" }
        "Standard" { "S1" }
    }
    
    # Create App Service Plan
    Write-Step "Creating App Service Plan..."
    $planName = "plan-$AppName"
    
    $planExists = az appservice plan show --name $planName --resource-group $ResourceGroup 2>$null
    
    if ($planExists) {
        Write-Info "App Service Plan already exists"
    }
    else {
        Write-Info "Creating $Tier tier plan (SKU: $sku)..."
        az appservice plan create `
            --name $planName `
            --resource-group $ResourceGroup `
            --sku $sku `
            --is-linux `
            --output none
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error2 "Failed to create App Service Plan"
            exit 1
        }
        Write-Success "App Service Plan created"
    }
    
    # Create Web App
    Write-Step "Creating Web App..."
    $webappExists = az webapp show --name $AppName --resource-group $ResourceGroup 2>$null
    
    if ($webappExists) {
        Write-Warning2 "Web App '$AppName' already exists! Using existing app..."
    }
    else {
        Write-Info "Creating Web App with Python 3.11 runtime..."
        az webapp create `
            --resource-group $ResourceGroup `
            --plan $planName `
            --name $AppName `
            --runtime "PYTHON:3.11" `
            --output none
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error2 "Failed to create Web App"
            Write-Host "`nPossible issues:" -ForegroundColor Yellow
            Write-Host "  • App name '$AppName' might be taken globally"
            Write-Host "  • Try: $AppName-$(Get-Random -Maximum 9999)"
            exit 1
        }
        Write-Success "Web App created"
    }
    
    # Configure Web App
    Write-Step "Configuring Web App..."
    
    # Enable WebSocket
    Write-Info "Enabling WebSocket support..."
    az webapp config set `
        --resource-group $ResourceGroup `
        --name $AppName `
        --web-sockets-enabled true `
        --output none
    
    # Set startup command
    Write-Info "Setting startup command..."
    az webapp config set `
        --resource-group $ResourceGroup `
        --name $AppName `
        --startup-file "gunicorn --bind=0.0.0.0:8000 --worker-class=gevent --workers=1 --timeout=600 server:app" `
        --output none
    
    # Set app settings
    Write-Info "Configuring application settings..."
    az webapp config appsettings set `
        --resource-group $ResourceGroup `
        --name $AppName `
        --settings `
            SCM_DO_BUILD_DURING_DEPLOYMENT=true `
            ENABLE_ORYX_BUILD=true `
            WEBSITE_HTTPLOGGING_RETENTION_DAYS=3 `
        --output none
    
    Write-Success "Web App configured"
    
    # Deploy application
    Write-Step "Deploying application code..."
    
    switch ($DeploymentMethod) {
        "zip" {
            Write-Info "Creating deployment package..."
            
            # Create temporary directory for deployment
            $tempDir = Join-Path $env:TEMP "church-deploy-$(Get-Random)"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            
            # Files and directories to include
            $includePaths = @(
                "*.html",
                "*.py",
                "requirements.txt",
                "runtime.txt",
                "web.config",
                "css",
                "js",
                "images",
                "songs"
            )
            
            foreach ($path in $includePaths) {
                $items = Get-Item -Path $path -ErrorAction SilentlyContinue
                foreach ($item in $items) {
                    if ($item.PSIsContainer) {
                        Copy-Item -Path $item.FullName -Destination $tempDir -Recurse -Force
                    }
                    else {
                        Copy-Item -Path $item.FullName -Destination $tempDir -Force
                    }
                }
            }
            
            # Create ZIP file
            $zipPath = Join-Path $env:TEMP "church-deploy-$(Get-Random).zip"
            Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force
            
            Write-Info "Uploading to Azure (this may take a minute)..."
            az webapp deployment source config-zip `
                --resource-group $ResourceGroup `
                --name $AppName `
                --src $zipPath `
                --output none
            
            # Cleanup
            Remove-Item -Path $tempDir -Recurse -Force
            Remove-Item -Path $zipPath -Force
            
            if ($LASTEXITCODE -ne 0) {
                Write-Error2 "Failed to deploy via ZIP"
                exit 1
            }
            
            Write-Success "Application deployed via ZIP"
        }
        
        "git" {
            Write-Info "Configuring local Git deployment..."
            
            # Configure deployment user (only needed once per subscription)
            Write-Info "Note: You may be prompted for deployment credentials"
            
            # Get deployment URL
            $deployUrl = az webapp deployment source config-local-git `
                --name $AppName `
                --resource-group $ResourceGroup `
                --query url -o tsv
            
            # Remove existing azure remote if present
            git remote remove azure 2>$null
            
            # Add azure remote
            git remote add azure $deployUrl
            
            Write-Info "Pushing code to Azure (this may take several minutes)..."
            Write-Host ""
            
            # Get current branch
            $currentBranch = git rev-parse --abbrev-ref HEAD
            
            # Push to Azure
            git push azure "${currentBranch}:master" --force
            
            if ($LASTEXITCODE -ne 0) {
                Write-Error2 "Failed to deploy via Git"
                Write-Host "`nYou may need to set deployment credentials:" -ForegroundColor Yellow
                Write-Host "  az webapp deployment user set --user-name <username> --password <password>"
                exit 1
            }
            
            Write-Success "Application deployed via Git"
        }
        
        "github" {
            Write-Info "Configuring GitHub deployment..."
            Write-Warning2 "GitHub deployment requires repository to be pushed to GitHub first"
            
            $repoUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/username/repo)"
            $branch = Read-Host "Enter branch name (default: main)"
            if ([string]::IsNullOrWhiteSpace($branch)) { $branch = "main" }
            
            az webapp deployment source config `
                --name $AppName `
                --resource-group $ResourceGroup `
                --repo-url $repoUrl `
                --branch $branch `
                --manual-integration `
                --output none
            
            if ($LASTEXITCODE -ne 0) {
                Write-Error2 "Failed to configure GitHub deployment"
                exit 1
            }
            
            Write-Success "GitHub deployment configured"
            Write-Info "Code will be deployed automatically from GitHub"
        }
    }
    
    # Get app URL
    $appUrl = "https://$AppName.azurewebsites.net"
    
    # Wait for deployment to complete
    Write-Step "Waiting for application to start..."
    Write-Info "This may take 30-60 seconds for first deployment..."
    
    Start-Sleep -Seconds 10
    
    # Restart app to ensure changes take effect
    Write-Info "Restarting application..."
    az webapp restart --resource-group $ResourceGroup --name $AppName --output none
    
    # Success message
    Write-Header "✅ DEPLOYMENT SUCCESSFUL!"
    
    Write-Host "Your Church Presentation App is now live!`n" -ForegroundColor Green
    
    Write-Host "📱 Application URLs:" -ForegroundColor Cyan
    Write-Host "  🏠 Home Page:    $appUrl/" -ForegroundColor White
    Write-Host "  🎮 Operator:     $appUrl/operator.html" -ForegroundColor White
    Write-Host "  📺 Projector:    $appUrl/projector.html" -ForegroundColor White
    Write-Host ""
    
    Write-Host "📊 Management:" -ForegroundColor Cyan
    Write-Host "  • View logs:     az webapp log tail --resource-group $ResourceGroup --name $AppName" -ForegroundColor Gray
    Write-Host "  • Restart:       az webapp restart --resource-group $ResourceGroup --name $AppName" -ForegroundColor Gray
    Write-Host "  • Stop:          az webapp stop --resource-group $ResourceGroup --name $AppName" -ForegroundColor Gray
    Write-Host "  • Start:         az webapp start --resource-group $ResourceGroup --name $AppName" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "💡 Important Notes:" -ForegroundColor Yellow
    if ($Tier -eq "Free") {
        Write-Host "  • Free tier may take 30-60 seconds to wake up after inactivity" -ForegroundColor Gray
        Write-Host "  • App sleeps after 20 minutes of no requests" -ForegroundColor Gray
        Write-Host "  • 60 minutes/day compute time limit" -ForegroundColor Gray
    }
    Write-Host "  • WebSocket is enabled for real-time sync" -ForegroundColor Gray
    Write-Host "  • Check application logs if you encounter issues" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Open $appUrl in your browser" -ForegroundColor White
    Write-Host "  2. Test the operator and projector pages" -ForegroundColor White
    Write-Host "  3. Upload your songs if needed" -ForegroundColor White
    Write-Host ""
    
    if ($Tier -ne "Free") {
        Write-Host "💰 Cost Optimization (for paid tiers):" -ForegroundColor Yellow
        Write-Host "  • Stop when not in use:  .\azure-stop.ps1 -ResourceGroup $ResourceGroup -AppName $AppName" -ForegroundColor Gray
        Write-Host "  • Start before service:  .\azure-start.ps1 -ResourceGroup $ResourceGroup -AppName $AppName" -ForegroundColor Gray
        Write-Host ""
    }
    
    Write-Host "="*70 -ForegroundColor Green
    Write-Host ""
    
    # Open browser
    $openBrowser = Read-Host "Would you like to open the app in your browser? (y/n)"
    if ($openBrowser -eq 'y') {
        Start-Process $appUrl
    }
}
catch {
    Write-Host ""
    Write-Error2 "Deployment failed: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "  1. Check if app name is globally unique" -ForegroundColor Gray
    Write-Host "  2. Verify you have appropriate Azure permissions" -ForegroundColor Gray
    Write-Host "  3. Check Azure CLI is up to date: az upgrade" -ForegroundColor Gray
    Write-Host "  4. Review error message above for specific issues" -ForegroundColor Gray
    Write-Host ""
    Write-Host "For detailed logs, run:" -ForegroundColor Cyan
    Write-Host "  az webapp log tail --resource-group $ResourceGroup --name $AppName" -ForegroundColor White
    Write-Host ""
    exit 1
}
