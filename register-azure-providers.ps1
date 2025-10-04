# PowerShell script to register Azure resource providers
# Run this if you get "subscription not registered" errors

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Azure Resource Provider Registration" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Azure CLI not found!" -ForegroundColor Red
    Write-Host "Please install from: https://aka.ms/installazurecliwindows"
    exit 1
}

# Check login
Write-Host "📝 Checking Azure login..." -ForegroundColor Cyan
try {
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Host "Logging in to Azure..." -ForegroundColor Yellow
        az login
        $account = az account show | ConvertFrom-Json
    }
    Write-Host "✅ Logged in to subscription: $($account.name)" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to login" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Registering required resource providers..." -ForegroundColor Cyan
Write-Host ""

# Required providers for App Service
$providers = @(
    @{Name='Microsoft.Web'; Description='Azure App Service'},
    @{Name='Microsoft.Storage'; Description='Azure Storage'},
    @{Name='Microsoft.Network'; Description='Azure Networking'}
)

foreach ($provider in $providers) {
    Write-Host "Checking $($provider.Name) ($($provider.Description))..." -ForegroundColor Gray
    
    $status = az provider show --namespace $provider.Name --query "registrationState" -o tsv 2>$null
    
    if ($status -eq "Registered") {
        Write-Host "  ✅ Already registered" -ForegroundColor Green
    } elseif ($status -eq "Registering") {
        Write-Host "  ⏳ Currently registering... waiting..." -ForegroundColor Yellow
        az provider register --namespace $provider.Name --wait
        Write-Host "  ✅ Registration complete!" -ForegroundColor Green
    } else {
        Write-Host "  📝 Not registered. Registering now..." -ForegroundColor Yellow
        Write-Host "     (This may take 1-2 minutes)" -ForegroundColor Gray
        
        az provider register --namespace $provider.Name --wait
        
        # Verify registration
        $newStatus = az provider show --namespace $provider.Name --query "registrationState" -o tsv
        if ($newStatus -eq "Registered") {
            Write-Host "  ✅ Successfully registered!" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Status: $newStatus" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✅ All providers registered!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "You can now run the deployment script:" -ForegroundColor Cyan
Write-Host "  .\deploy-to-azure.ps1" -ForegroundColor White
Write-Host ""
