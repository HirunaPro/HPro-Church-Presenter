#!/usr/bin/env pwsh
# Stop the Azure Container Instance to save money

Write-Host "Stopping container: twtr-screen" -ForegroundColor Yellow
az container stop --resource-group church-presenter-rg --name twtr-screen

Write-Host ""
Write-Host "✅ Container stopped!" -ForegroundColor Green
Write-Host "💰 You are no longer being charged for this container." -ForegroundColor Green
Write-Host ""
