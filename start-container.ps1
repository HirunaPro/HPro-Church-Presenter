#!/usr/bin/env pwsh
# Start the Azure Container Instance

Write-Host "Starting container: twtr-screen" -ForegroundColor Green
az container start --resource-group church-presenter-rg --name twtr-screen

Write-Host ""
Write-Host "✅ Container started!" -ForegroundColor Green
Write-Host ""
Write-Host "Application URLs:" -ForegroundColor Cyan
Write-Host "  http://twtr-screen.southindia.azurecontainer.io:8080/index.html" -ForegroundColor White
Write-Host "  http://twtr-screen.southindia.azurecontainer.io:8080/operator.html" -ForegroundColor White
Write-Host "  http://twtr-screen.southindia.azurecontainer.io:8080/projector.html" -ForegroundColor White
Write-Host ""
