# PowerShell script to start Azure App Service
# Usage: .\azure-start.ps1 -ResourceGroup <rg-name> -AppName <app-name>

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    
    [Parameter(Mandatory=$true)]
    [string]$AppName
)

# Function to print colored messages
function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

# Check if Azure CLI is installed
Write-Info "Checking for Azure CLI..."
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "Azure CLI not found!"
    Write-Host ""
    Write-Host "Please install Azure CLI from:"
    Write-Host "  https://aka.ms/installazurecliwindows"
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Starting Azure App Service" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Info "Resource Group: $ResourceGroup"
Write-Info "App Name:       $AppName"
Write-Host ""

# Check if logged in to Azure
Write-Info "Checking Azure login status..."
try {
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Warning-Custom "Not logged in to Azure"
        Write-Info "Logging in..."
        az login
        $account = az account show | ConvertFrom-Json
    }
    Write-Success "Logged in to Azure"
    Write-Info "Subscription: $($account.name)"
} catch {
    Write-Error-Custom "Failed to login to Azure"
    exit 1
}

Write-Host ""

# Check if app exists
Write-Info "Checking if app exists..."
try {
    $app = az webapp show --resource-group $ResourceGroup --name $AppName 2>$null | ConvertFrom-Json
    if (-not $app) {
        Write-Error-Custom "App not found!"
        Write-Host ""
        Write-Host "Please check:"
        Write-Host "  - Resource group name is correct"
        Write-Host "  - App name is correct"
        Write-Host "  - You have access to the subscription"
        exit 1
    }
    Write-Success "App found"
} catch {
    Write-Error-Custom "App not found!"
    Write-Host ""
    Write-Host "Please check:"
    Write-Host "  - Resource group name is correct"
    Write-Host "  - App name is correct"
    Write-Host "  - You have access to the subscription"
    exit 1
}

Write-Host ""

# Get current state
Write-Info "Getting current app state..."
$state = $app.state

if ($state -eq "Running") {
    Write-Success "App is already running!"
    Write-Host ""
    Write-Info "Access your app at: https://$($app.defaultHostName)"
    Write-Host ""
    exit 0
}

# Start the app
Write-Info "Starting the app..."
az webapp start --resource-group $ResourceGroup --name $AppName | Out-Null

Write-Success "App started successfully!"
Write-Host ""

# Wait a moment for the app to fully start
Write-Info "Waiting for app to be ready..."
Start-Sleep -Seconds 5

# Get app URL
$app = az webapp show --resource-group $ResourceGroup --name $AppName | ConvertFrom-Json
$appUrl = $app.defaultHostName

Write-Success "Your app is now running!"
Write-Host ""
Write-Info "Access your app at: https://$appUrl"
Write-Info "Operator control:   https://$appUrl/operator.html"
Write-Info "Projector display:  https://$appUrl/projector.html"
Write-Host ""
Write-Warning-Custom "Remember to stop the app when finished to save costs!"
Write-Info "Run: .\azure-stop.ps1 -ResourceGroup $ResourceGroup -AppName $AppName"
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
