#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Diagnose and fix DNS issues with Azure Container Instance
.DESCRIPTION
    Checks container status, DNS configuration, and provides working URLs
.PARAMETER AppName
    Your application name
.PARAMETER ResourceGroup
    Resource group name (default: church-presenter-rg)
.EXAMPLE
    .\diagnose-connection.ps1 -AppName "twtr-screen"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$AppName,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "church-presenter-rg"
)

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Container Connection Diagnostics" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Get app name if not provided
if (-not $AppName) {
    $AppName = Read-Host "Enter your app name"
}

Write-Host "Diagnosing: $AppName" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if container exists
Write-Host "[1/5] Checking if container exists..." -ForegroundColor Yellow
$container = az container show --name $AppName --resource-group $ResourceGroup 2>$null

if (-not $container) {
    Write-Host "❌ Container '$AppName' not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available containers:" -ForegroundColor Yellow
    az container list --resource-group $ResourceGroup --output table
    exit 1
}
Write-Host "✅ Container exists" -ForegroundColor Green
Write-Host ""

# Step 2: Check container state
Write-Host "[2/5] Checking container state..." -ForegroundColor Yellow
$state = az container show --name $AppName --resource-group $ResourceGroup --query instanceView.state -o tsv
Write-Host "   State: $state" -ForegroundColor Gray

if ($state -ne "Running") {
    Write-Host "⚠️  Container is not running (state: $state)" -ForegroundColor Yellow
    Write-Host ""
    $start = Read-Host "Start the container now? (y/n)"
    if ($start -eq 'y') {
        Write-Host "Starting container..." -ForegroundColor Cyan
        az container start --name $AppName --resource-group $ResourceGroup --output none
        Write-Host "✅ Container started" -ForegroundColor Green
        Write-Host "Waiting 30 seconds for container to initialize..." -ForegroundColor Gray
        Start-Sleep -Seconds 30
    } else {
        exit 0
    }
} else {
    Write-Host "✅ Container is running" -ForegroundColor Green
}
Write-Host ""

# Step 3: Get IP and DNS details
Write-Host "[3/5] Getting connection details..." -ForegroundColor Yellow
$details = az container show --name $AppName --resource-group $ResourceGroup --query "{FQDN:ipAddress.fqdn, IP:ipAddress.ip, Ports:ipAddress.ports}" | ConvertFrom-Json

$fqdn = $details.FQDN
$ip = $details.IP
$ports = $details.Ports

Write-Host "   Public IP: $ip" -ForegroundColor Gray
Write-Host "   DNS Name: $fqdn" -ForegroundColor Gray
Write-Host "   Ports: $($ports | ForEach-Object { "$($_.port)/$($_.protocol)" } | Join-String -Separator ', ')" -ForegroundColor Gray
Write-Host "✅ Connection details retrieved" -ForegroundColor Green
Write-Host ""

# Step 4: Test DNS resolution
Write-Host "[4/5] Testing DNS resolution..." -ForegroundColor Yellow
try {
    $dnsTest = Resolve-DnsName $fqdn -ErrorAction Stop
    Write-Host "✅ DNS resolves to: $($dnsTest.IPAddress)" -ForegroundColor Green
    
    if ($dnsTest.IPAddress -contains $ip) {
        Write-Host "✅ DNS points to correct IP" -ForegroundColor Green
    } else {
        Write-Host "⚠️  DNS points to different IP (may be propagating)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ DNS resolution failed" -ForegroundColor Red
    Write-Host "   This is normal for new deployments (DNS takes 5-15 minutes)" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Test HTTP connectivity
Write-Host "[5/5] Testing HTTP connectivity..." -ForegroundColor Yellow

# Test IP-based URL
$ipUrl = "http://${ip}:8080"
try {
    $response = Invoke-WebRequest -Uri $ipUrl -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ IP-based URL works: $ipUrl" -ForegroundColor Green
} catch {
    Write-Host "❌ Cannot reach container via IP" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
}

# Test DNS-based URL
if ($fqdn) {
    $dnsUrl = "http://${fqdn}:8080"
    try {
        $response = Invoke-WebRequest -Uri $dnsUrl -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        Write-Host "✅ DNS-based URL works: $dnsUrl" -ForegroundColor Green
    } catch {
        Write-Host "❌ Cannot reach container via DNS" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
        Write-Host "   Recommendation: Use IP-based URL until DNS propagates" -ForegroundColor Yellow
    }
}
Write-Host ""

# Summary
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Connection Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ WORKING URLs (Use these):" -ForegroundColor Green
Write-Host ""
Write-Host "  Via IP Address:" -ForegroundColor Cyan
Write-Host "  🏠 Landing:   http://${ip}:8080/index.html" -ForegroundColor White
Write-Host "  🎮 Operator:  http://${ip}:8080/operator.html" -ForegroundColor White
Write-Host "  📺 Projector: http://${ip}:8080/projector.html" -ForegroundColor White
Write-Host ""
Write-Host "  Via DNS (may take 5-15 min to work):" -ForegroundColor Yellow
Write-Host "  🏠 Landing:   http://${fqdn}:8080/index.html" -ForegroundColor White
Write-Host "  🎮 Operator:  http://${fqdn}:8080/operator.html" -ForegroundColor White
Write-Host "  📺 Projector: http://${fqdn}:8080/projector.html" -ForegroundColor White
Write-Host ""

Write-Host "💡 Troubleshooting Tips:" -ForegroundColor Cyan
Write-Host ""
Write-Host "If DNS not working:" -ForegroundColor Yellow
Write-Host "  1. Use IP-based URLs (work immediately)" -ForegroundColor White
Write-Host "  2. Wait 5-15 minutes for DNS to propagate" -ForegroundColor White
Write-Host "  3. Flush DNS cache on your computer:" -ForegroundColor White
Write-Host "     ipconfig /flushdns" -ForegroundColor Gray
Write-Host ""

Write-Host "If nothing works:" -ForegroundColor Yellow
Write-Host "  1. Check Azure service health" -ForegroundColor White
Write-Host "  2. Verify firewall/network settings" -ForegroundColor White
Write-Host "  3. View container logs:" -ForegroundColor White
Write-Host "     .\view-logs.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "Check DNS propagation status:" -ForegroundColor Cyan
Write-Host "  https://dnschecker.org/#A/${fqdn}" -ForegroundColor White
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
