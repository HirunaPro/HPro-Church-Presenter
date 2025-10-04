# Azure Deployment Branch - Summary

**Branch**: `azure-deployment`  
**Created**: October 4, 2025  
**Purpose**: Enable deployment to Azure App Service with cost optimization

---

## What's New in This Branch

### 📋 Configuration Files

1. **requirements.txt** - Python dependencies (websockets)
2. **runtime.txt** - Specifies Python 3.11 for Azure
3. **startup.sh** - Azure startup script
4. **.deployment** - Azure build configuration
5. **web.config** - IIS/Azure web server configuration

### 🖥️ Server Files

6. **server-azure.py** - Azure-compatible version of server.py
   - Reads PORT from environment variables
   - Compatible with Azure App Service
   - Same functionality as original server.py

### 💰 Cost Management Tools

7. **azure-cost-calculator.py** - Interactive cost calculator
   - Estimates monthly costs based on usage
   - Church-specific scenarios (Sunday only, multiple services, etc.)
   - Compares Free, Basic, and Standard tiers

### 🔧 Automation Scripts

8. **azure-start.ps1** (PowerShell) - Start App Service
9. **azure-stop.ps1** (PowerShell) - Stop App Service
10. **azure-start.sh** (Bash) - Start App Service
11. **azure-stop.sh** (Bash) - Stop App Service

### 📚 Documentation

12. **AZURE-DEPLOYMENT.md** - Complete deployment guide
    - Step-by-step instructions
    - Troubleshooting
    - Cost optimization tips
    - Comparison tables

13. **AZURE-QUICKSTART.md** - Quick start guide
    - 5-minute deployment
    - Essential commands only

14. **.gitignore** - Updated to exclude Azure-specific files

---

## How to Use

### 1. Run the Cost Calculator

See what your Azure costs would be:

```bash
python azure-cost-calculator.py
```

**Example Output:**
```
📋 SCENARIO: Sunday Service Only
Description: Running only during Sunday morning service (2-3 hours/week)

  Free Tier (F1)
  ────────────────────────────────────────
    Monthly Cost:  $0.00
    Daily Cost:    $0.00
    Hourly Rate:   $0.000

    Notes:
      ✅ 60 minutes of compute time per day
      ⚠️ App sleeps after 20 minutes of inactivity
      ⚠️ Cold start delay (~10-30 seconds)
      ✅ WebSocket support included
      💡 Perfect for Sunday-only services!
```

### 2. Deploy to Azure

Follow the guide in **AZURE-DEPLOYMENT.md** or use the quick start:

```bash
# Quick deployment commands
az login
az group create --name church-app-rg --location eastus
az appservice plan create --name church-plan --resource-group church-app-rg --sku F1 --is-linux
az webapp create --resource-group church-app-rg --plan church-plan --name YOUR-APP-NAME --runtime "PYTHON:3.11"
az webapp config set --resource-group church-app-rg --name YOUR-APP-NAME --web-sockets-enabled true --startup-file "python server.py"

# Deploy
git push azure azure-deployment:master
```

### 3. Manage Costs (for paid tiers)

**Windows:**
```powershell
# Start before service
.\azure-start.ps1 -ResourceGroup church-app-rg -AppName YOUR-APP-NAME

# Stop after service
.\azure-stop.ps1 -ResourceGroup church-app-rg -AppName YOUR-APP-NAME
```

**macOS/Linux:**
```bash
# Start before service
./azure-start.sh church-app-rg YOUR-APP-NAME

# Stop after service
./azure-stop.sh church-app-rg YOUR-APP-NAME
```

---

## Cost Comparison

| Scenario | Free (F1) | Basic B1 (24/7) | Basic B1 (Sunday only) |
|----------|-----------|-----------------|------------------------|
| **Sunday service (3 hrs)** | $0 | $13.14/month | $0.43/month |
| **Sun + Wed (6 hrs)** | $0 | $13.14/month | $1.08/month |
| **Daily (2 hrs)** | $0 | $13.14/month | $2.60/month |

**💡 Recommendation: Use Free Tier (F1) - it's perfect for most churches!**

---

## Key Benefits

✅ **Free hosting option** - $0/month with F1 tier  
✅ **WebSocket support** - Real-time operator ↔ projector communication  
✅ **Global access** - Access from anywhere with internet  
✅ **HTTPS included** - Secure by default  
✅ **Cost optimization** - Scripts to start/stop and save 90%+ on paid tiers  
✅ **Easy deployment** - Push to Git and you're done  

---

## Files Modified/Created

```
PresentationApp/
├── .deployment                 # NEW - Azure build config
├── .gitignore                  # MODIFIED - Added Azure exclusions
├── requirements.txt            # NEW - Python dependencies
├── runtime.txt                 # NEW - Python version
├── startup.sh                  # NEW - Azure startup script
├── web.config                  # NEW - Azure web config
├── server-azure.py             # NEW - Azure-compatible server
├── azure-cost-calculator.py    # NEW - Cost estimation tool
├── azure-start.ps1             # NEW - PowerShell start script
├── azure-stop.ps1              # NEW - PowerShell stop script
├── azure-start.sh              # NEW - Bash start script
├── azure-stop.sh               # NEW - Bash stop script
├── AZURE-DEPLOYMENT.md         # NEW - Complete deployment guide
└── AZURE-QUICKSTART.md         # NEW - Quick start guide
```

---

## Next Steps

1. **Test the cost calculator**:
   ```bash
   python azure-cost-calculator.py
   ```

2. **Read the deployment guide**:
   - Quick start: [AZURE-QUICKSTART.md](AZURE-QUICKSTART.md)
   - Full guide: [AZURE-DEPLOYMENT.md](AZURE-DEPLOYMENT.md)

3. **Deploy to Azure** (optional):
   - Follow the step-by-step guide
   - Start with Free Tier (F1)
   - Test with your church

4. **Merge to main** (when ready):
   ```bash
   git checkout main
   git merge azure-deployment
   git push origin main
   ```

---

## Support

- **Azure issues**: See [AZURE-DEPLOYMENT.md](AZURE-DEPLOYMENT.md) → Troubleshooting section
- **App issues**: See main [README.md](README.md)
- **Cost questions**: Run `python azure-cost-calculator.py`

---

## Summary

This branch adds complete Azure deployment support while maintaining full backward compatibility with local hosting. You can:

1. Continue using local hosting (no changes needed)
2. Deploy to Azure for remote access
3. Use Free Tier for $0/month
4. Optimize costs with start/stop scripts

**Best for**: Churches wanting remote access without ongoing costs!
