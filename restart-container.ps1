#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Restart Azure Container Instance to fix port conflicts
.DESCRIPTION
    Stops and starts the container with proper delay to ensure ports are freed
.PARAMETER AppName
    Your application name
.PARAMETER ResourceGroup
    Resource group name (default: church-presenter-rg)
.EXAMPLE
    .\restart-container.ps1 -AppName "mychurch-app"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$AppName,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "church-presenter-rg"
)

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Container Restart Utility" -ForegroundColor Cyan
Write-Host "  Fixes port conflicts and other issues" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Get app name if not provided
if (-not $AppName) {
    $AppName = Read-Host "Enter your app name"
}

Write-Host "Restarting container: $AppName" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor Gray
Write-Host ""

# Check if container exists
Write-Host "[1/3] Checking container status..." -ForegroundColor Yellow
$container = az container show --name $AppName --resource-group $ResourceGroup 2>$null

if (-not $container) {
    Write-Host "❌ Container '$AppName' not found in resource group '$ResourceGroup'" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available containers:" -ForegroundColor Yellow
    az container list --resource-group $ResourceGroup --output table
    exit 1
}

$status = az container show --name $AppName --resource-group $ResourceGroup --query instanceView.state -o tsv
Write-Host "   Current status: $status" -ForegroundColor Gray
Write-Host "✅ Container found" -ForegroundColor Green
Write-Host ""

# Stop container
Write-Host "[2/3] Stopping container..." -ForegroundColor Yellow
az container stop --name $AppName --resource-group $ResourceGroup --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to stop container" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Container stopped" -ForegroundColor Green
Write-Host "   Waiting 15 seconds for resources to be released..." -ForegroundColor Gray

# Wait for resources to be freed
for ($i = 15; $i -gt 0; $i--) {
    Write-Host -NoNewline "`r   Waiting: $i seconds remaining... " -ForegroundColor Gray
    Start-Sleep -Seconds 1
}
Write-Host "`r   ✅ Wait complete                    " -ForegroundColor Green
Write-Host ""

# Start container
Write-Host "[3/3] Starting container..." -ForegroundColor Yellow
az container start --name $AppName --resource-group $ResourceGroup --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start container" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try viewing logs for more details:" -ForegroundColor Yellow
    Write-Host "  az container logs --name $AppName --resource-group $ResourceGroup" -ForegroundColor White
    exit 1
}

Write-Host "✅ Container started" -ForegroundColor Green
Write-Host ""

# Get container details
Write-Host "Getting container details..." -ForegroundColor Cyan
$fqdn = az container show --name $AppName --resource-group $ResourceGroup --query ipAddress.fqdn -o tsv
$ip = az container show --name $AppName --resource-group $ResourceGroup --query ipAddress.ip -o tsv

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✅ RESTART COMPLETE!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your application is now running at:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  🌐 HTTP:  http://${fqdn}:8080" -ForegroundColor White
Write-Host "  🔌 WebSocket: ws://${fqdn}:8765" -ForegroundColor White
Write-Host "  📍 Public IP: $ip" -ForegroundColor Gray
Write-Host ""
Write-Host "Application URLs:" -ForegroundColor Cyan
Write-Host "  🏠 Landing:   http://${fqdn}:8080/index.html" -ForegroundColor White
Write-Host "  🎮 Operator:  http://${fqdn}:8080/operator.html" -ForegroundColor White
Write-Host "  📺 Projector: http://${fqdn}:8080/projector.html" -ForegroundColor White
Write-Host ""
Write-Host "Give the container 30 seconds to fully start up." -ForegroundColor Yellow
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Cyan
Write-Host "  .\view-logs.ps1" -ForegroundColor White
Write-Host ""
Write-Host "To check status:" -ForegroundColor Cyan
Write-Host "  .\check-status.ps1" -ForegroundColor White
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
