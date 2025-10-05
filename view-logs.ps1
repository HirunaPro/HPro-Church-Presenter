#!/usr/bin/env pwsh
# View container logs

Write-Host "Fetching logs for: twtr-screen" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to exit" -ForegroundColor Gray
Write-Host ""
az container logs --resource-group church-presenter-rg --name twtr-screen --follow
