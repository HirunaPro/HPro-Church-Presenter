# Azure Deployment Resources

This folder contains all Azure-related deployment scripts, configuration files, and documentation.

## Contents

### Deployment Scripts

**Container Instances (Recommended) ⭐**
- `deploy-azure-container.ps1` - Deploy to Azure Container Instances (PowerShell)
- `deploy-azure-container.sh` - Deploy to Azure Container Instances (Bash/Shell)

**App Service (Alternative)**
- `deploy-to-azure-v2.ps1` - Deploy to Azure App Service v2 (PowerShell)
- `deploy-to-azure-v2.sh` - Deploy to Azure App Service v2 (Bash/Shell)
- `deploy-to-azure.ps1` - Deploy to Azure App Service (PowerShell)
- `deploy-to-azure.sh` - Deploy to Azure App Service (Bash/Shell)
- `deploy-to-azure-b1.ps1` - Deploy with B1 tier
- `deploy-to-azure-multi-region.ps1` - Deploy to multiple regions

### Management Scripts

- `azure-start.ps1` - Start Azure App Service
- `azure-start.sh` - Start Azure App Service (Bash)
- `azure-stop.ps1` - Stop Azure App Service
- `azure-stop.sh` - Stop Azure App Service (Bash)
- `register-azure-providers.ps1` - Register Azure providers
- `register-azure-providers.sh` - Register Azure providers (Bash)

### Configuration Files

- `.deployment` - Azure deployment configuration
- `web.config` - IIS web server configuration
- `server-azure.py` - Azure-specific server implementation
- `azure-cost-calculator.py` - Calculate Azure costs

### Documentation

**Quick Start & Implementation**
- `AZURE-CONTAINER-QUICKSTART.md` - 5-minute deployment guide
- `AZURE-CONTAINER-DEPLOYMENT.md` - Full Container Instances guide
- `AZURE-QUICK-DEPLOY.md` - Quick deployment steps

**Deployment Guides**
- `AZURE-DEPLOYMENT.md` - Comprehensive deployment guide
- `AZURE-DEPLOYMENT-V2.md` - Deployment v2 guide
- `AZURE-DEPLOYMENT-V2-SUMMARY.md` - Version 2 summary
- `DEPLOYMENT-COMPARISON.md` - Compare deployment options
- `DEPLOYMENT-OPTIONS-COMPARISON.md` - Detailed comparison
- `DEPLOYMENT-TROUBLESHOOTING.md` - Troubleshooting guide

**Setup & Configuration**
- `AZURE-SUBSCRIPTION-GUIDE.md` - Azure subscription setup
- `AZURE-QUICKSTART.md` - Quick setup guide
- `AZURE-BRANCH-SUMMARY.md` - Branch summary
- `DEPLOYMENT-READY.md` - Deployment readiness checklist
- `DEPLOYMENT-FIXES.md` - Common fixes

**Quota & Costs**
- `QUOTA-ISSUE-SOLUTIONS.md` - Quota problem solutions
- `QUOTA-QUICK-FIX.md` - Quick quota fix
- `FREE-TIER-QUOTA-ISSUE.md` - Free tier quota issues

**Migration**
- `MIGRATION-V1-TO-V2.md` - Migrate from v1 to v2

## Quick Start

### Deploy to Azure Container Instances (Recommended)

```powershell
# Windows PowerShell
.\deploy-azure-container.ps1 -AppName "mychurch-app"

# Or bash/shell
./deploy-azure-container.sh --app-name "mychurch-app"
```

### Deploy to Azure App Service

```powershell
# Windows PowerShell
.\deploy-to-azure-v2.ps1 -AppName "mychurch-app"

# Or bash/shell
./deploy-to-azure-v2.sh --app-name "mychurch-app"
```

## Pricing

### Container Instances ⭐
- 3 hours/week: **$0.57/month**
- 6 hours/week: **$1.14/month**
- 24/7: ~$35/month

### App Service
- Free (F1): $0/month (limited)
- Basic (B1): ~$13/month (or ~$0.43 with start/stop scripts)
- Standard (S1): ~$69/month

## Prerequisites

- Azure CLI installed
- Azure subscription
- Resource group created

## Documentation Structure

See individual `.md` files for:
- Step-by-step deployment instructions
- Troubleshooting guides
- Cost calculations
- Configuration details
- Best practices

## Local Development

For **local network** deployment without Azure, see:
- `../PYINSTALLER-GUIDE.md` - Standalone Windows executable
- `../README.md` - Full project documentation

## Support

For issues:
1. Check `DEPLOYMENT-TROUBLESHOOTING.md`
2. Review relevant guide (e.g., `AZURE-CONTAINER-DEPLOYMENT.md`)
3. Check Azure Portal for service status
4. Review script output for error messages
