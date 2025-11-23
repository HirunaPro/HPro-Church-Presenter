# Azure Deployment v2 - Troubleshooting Guide

> Solutions to common deployment issues

---

## 🆘 Quick Fixes

### Issue: "Azure CLI not found"

**Error Message:**
```
❌ Azure CLI not found!
```

**Solution:**
```powershell
# Windows
winget install Microsoft.AzureCLI

# macOS
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**Verify Installation:**
```bash
az --version
```

---

### Issue: "App name already taken"

**Error Message:**
```
❌ Failed to create Web App
Possible issues:
  • App name 'myapp' might be taken globally
```

**Solution:**
```powershell
# Add random number to make it unique
.\deploy-to-azure-v2.ps1 -AppName "myapp-$(Get-Random -Maximum 9999)"

# Or use more specific name
.\deploy-to-azure-v2.ps1 -AppName "church-stmary-presenter"
```

**Test Availability:**
```bash
# Check if name is available
az webapp list --query "[?name=='myapp']" -o table
```

---

### Issue: "Not logged in to Azure"

**Error Message:**
```
❌ Failed to login to Azure
```

**Solution:**
```bash
# Login to Azure
az login

# This opens browser for authentication
# Complete the login in browser
# Return to terminal
```

**Verify:**
```bash
# Check current account
az account show

# List all subscriptions
az account list -o table
```

---

### Issue: "Git not found" (Git deployment)

**Error Message:**
```
❌ Git not found but required for git deployment!
```

**Solution:**
```powershell
# Install Git
# Windows: https://git-scm.com/downloads
# macOS: brew install git
# Linux: sudo apt install git

# Or switch to ZIP deployment
.\deploy-to-azure-v2.ps1 -AppName "myapp" -DeploymentMethod zip
```

---

### Issue: "zip command not found" (Linux/Mac)

**Error Message:**
```
❌ zip command not found but required for ZIP deployment!
```

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install zip

# macOS
brew install zip

# Or use Git deployment instead
./deploy-to-azure-v2.sh --app-name "myapp" --method git
```

---

### Issue: "Deployment failed" during upload

**Error Message:**
```
❌ Failed to deploy via ZIP
```

**Solutions:**

1. **Check file size:**
   ```bash
   # ZIP file might be too large (>2GB)
   # Remove unnecessary files before deployment
   ```

2. **Retry deployment:**
   ```powershell
   # Sometimes it's a transient error
   .\deploy-to-azure-v2.ps1 -AppName "myapp"
   ```

3. **Check Azure status:**
   - Visit: https://status.azure.com
   - Ensure no ongoing outages

4. **View detailed logs:**
   ```bash
   az webapp log tail --resource-group church-presenter-rg --name myapp
   ```

---

### Issue: "Invalid app name"

**Error Message:**
```
❌ Invalid app name! Must be 2-60 characters, lowercase letters, numbers, and hyphens only
```

**Valid Examples:**
```
✅ church-app
✅ mychurch-presenter
✅ stmary-church-123
✅ presenter-app-2024
```

**Invalid Examples:**
```
❌ MyApp                  # Uppercase not allowed
❌ church_app             # Underscores not allowed
❌ church.app             # Dots not allowed
❌ a                      # Too short (min 2 chars)
❌ church-app-with-very-long-name-exceeding-60-characters  # Too long
```

---

### Issue: "Subscription has quota limitations"

**Error Message:**
```
❌ Failed to create App Service Plan
Error: Subscription quota exceeded
```

**Solutions:**

1. **Check quotas:**
   ```bash
   az vm list-usage --location eastus -o table
   ```

2. **Try different region:**
   ```powershell
   .\deploy-to-azure-v2.ps1 -AppName "myapp" -Location "westus2"
   ```

3. **Delete unused resources:**
   ```bash
   # List all resource groups
   az group list -o table
   
   # Delete unused ones
   az group delete --name unused-rg --yes
   ```

4. **Request quota increase:**
   - Azure Portal → Subscriptions → Usage + quotas
   - Submit support request

---

### Issue: "Resource provider not registered"

**Error Message:**
```
The subscription is not registered to use namespace 'Microsoft.Web'
```

**Solution:**
```bash
# Register the provider
az provider register --namespace Microsoft.Web --wait

# Verify registration
az provider show --namespace Microsoft.Web --query "registrationState"
```

The v2 script does this automatically, but you can do it manually if needed.

---

### Issue: "Deployment succeeded but app not working"

**Symptoms:**
- Deployment completes successfully
- App URL shows error page
- 502/503 errors

**Solutions:**

1. **Wait for cold start (Free tier):**
   ```bash
   # Free tier takes 30-60 seconds to wake up
   # Just wait and refresh
   ```

2. **Check application logs:**
   ```bash
   az webapp log tail --resource-group church-presenter-rg --name myapp
   ```

3. **Restart the app:**
   ```bash
   az webapp restart --resource-group church-presenter-rg --name myapp
   ```

4. **Check startup command:**
   ```bash
   # View current startup command
   az webapp config show --resource-group church-presenter-rg --name myapp --query "appCommandLine"
   
   # Should be: python server.py
   # Or: gunicorn --bind=0.0.0.0:8000 server:app
   ```

5. **Verify Python version:**
   ```bash
   # Check runtime
   az webapp config show --resource-group church-presenter-rg --name myapp --query "linuxFxVersion"
   
   # Should be: PYTHON|3.11
   ```

6. **Check requirements.txt:**
   ```bash
   # Ensure websockets is listed
   cat requirements.txt
   # Should contain: websockets==12.0
   ```

---

### Issue: "WebSocket not connecting"

**Symptoms:**
- Operator shows "Disconnected"
- Projector doesn't receive updates

**Solutions:**

1. **Verify WebSocket is enabled:**
   ```bash
   az webapp config show --resource-group church-presenter-rg --name myapp --query "webSocketsEnabled"
   # Should be: true
   ```

2. **Enable if disabled:**
   ```bash
   az webapp config set --resource-group church-presenter-rg --name myapp --web-sockets-enabled true
   ```

3. **Check browser console:**
   - Press F12
   - Go to Console tab
   - Look for WebSocket errors

4. **Verify ports:**
   - HTTP: 8000 (or PORT environment variable)
   - WebSocket: 8765

5. **Check firewall:**
   - Some corporate firewalls block WebSocket
   - Try different network

---

### Issue: "Git push failed" (Git deployment)

**Error Message:**
```
❌ Failed to deploy via Git
```

**Solutions:**

1. **Set deployment credentials:**
   ```bash
   az webapp deployment user set --user-name myusername --password 'MySecureP@ssw0rd!'
   ```

2. **Get deployment URL:**
   ```bash
   az webapp deployment source config-local-git \
     --name myapp \
     --resource-group church-presenter-rg \
     --query url -o tsv
   ```

3. **Update remote:**
   ```bash
   git remote remove azure
   git remote add azure <deployment-url>
   git push azure main:master --force
   ```

4. **Check Git status:**
   ```bash
   git status
   git log --oneline -5
   ```

---

### Issue: "GitHub deployment not working"

**Symptoms:**
- GitHub linked but not deploying
- Changes not reflected

**Solutions:**

1. **Check webhook:**
   - GitHub → Settings → Webhooks
   - Verify Azure webhook is present and working

2. **Manual sync:**
   ```bash
   az webapp deployment source sync \
     --resource-group church-presenter-rg \
     --name myapp
   ```

3. **Re-configure:**
   ```bash
   .\deploy-to-azure-v2.ps1 -AppName "myapp" -DeploymentMethod github
   ```

4. **Check GitHub Actions:**
   - If using GitHub Actions
   - View workflow runs for errors

---

### Issue: "App is slow/times out"

**Symptoms:**
- Long loading times
- Request timeouts
- 504 errors

**Solutions:**

1. **Upgrade tier:**
   ```powershell
   # Free tier has limited resources
   # Upgrade to Basic for better performance
   az appservice plan update \
     --name plan-myapp \
     --resource-group church-presenter-rg \
     --sku B1
   ```

2. **Enable Always On (Basic tier only):**
   ```bash
   az webapp config set \
     --resource-group church-presenter-rg \
     --name myapp \
     --always-on true
   ```

3. **Increase timeout:**
   ```bash
   # Default is 230 seconds
   az webapp config set \
     --resource-group church-presenter-rg \
     --name myapp \
     --web-sockets-enabled true
   ```

4. **Check resource metrics:**
   ```bash
   az monitor metrics list \
     --resource $(az webapp show --resource-group church-presenter-rg --name myapp --query id -o tsv) \
     --metric "CpuTime,MemoryWorkingSet" \
     --start-time 2025-10-01T00:00:00Z
   ```

---

### Issue: "Songs not loading"

**Symptoms:**
- Song list is empty
- Songs don't appear in operator

**Solutions:**

1. **Check songs directory:**
   ```bash
   # List files in songs directory
   ls songs/
   
   # Should show .json files
   ```

2. **Verify JSON format:**
   ```bash
   # Test JSON validity
   python -m json.tool songs/your-song.json
   ```

3. **Check file permissions:**
   ```bash
   # Ensure files are readable
   chmod 644 songs/*.json
   ```

4. **Re-deploy:**
   ```powershell
   # Re-deploy to ensure songs are uploaded
   .\deploy-to-azure-v2.ps1 -AppName "myapp"
   ```

5. **Check browser console:**
   - F12 → Console
   - Look for fetch errors

---

### Issue: "Cannot delete resource group"

**Error Message:**
```
Cannot delete resource group as it contains resources
```

**Solutions:**

1. **Delete all resources first:**
   ```bash
   # Delete web app
   az webapp delete --resource-group church-presenter-rg --name myapp
   
   # Delete app service plan
   az appservice plan delete --name plan-myapp --resource-group church-presenter-rg
   
   # Then delete resource group
   az group delete --name church-presenter-rg --yes
   ```

2. **Force delete:**
   ```bash
   # Delete resource group and all resources
   az group delete --name church-presenter-rg --yes --no-wait
   ```

3. **Check locks:**
   ```bash
   # List locks
   az lock list --resource-group church-presenter-rg
   
   # Delete lock if present
   az lock delete --name lock-name --resource-group church-presenter-rg
   ```

---

## 🔍 Diagnostic Commands

### Check Deployment Status

```bash
# View deployment logs
az webapp log deployment show \
  --resource-group church-presenter-rg \
  --name myapp

# List deployments
az webapp deployment list-publishing-credentials \
  --resource-group church-presenter-rg \
  --name myapp
```

### View Application Logs

```bash
# Real-time logs
az webapp log tail \
  --resource-group church-presenter-rg \
  --name myapp

# Download logs
az webapp log download \
  --resource-group church-presenter-rg \
  --name myapp \
  --log-file logs.zip
```

### Check App Configuration

```bash
# View all settings
az webapp config show \
  --resource-group church-presenter-rg \
  --name myapp

# View app settings
az webapp config appsettings list \
  --resource-group church-presenter-rg \
  --name myapp

# View connection strings
az webapp config connection-string list \
  --resource-group church-presenter-rg \
  --name myapp
```

### Check App Status

```bash
# Get app state
az webapp show \
  --resource-group church-presenter-rg \
  --name myapp \
  --query state -o tsv

# Should return: Running

# Get app URL
az webapp show \
  --resource-group church-presenter-rg \
  --name myapp \
  --query defaultHostName -o tsv
```

### Monitor Resources

```bash
# CPU usage
az monitor metrics list \
  --resource $(az webapp show --resource-group church-presenter-rg --name myapp --query id -o tsv) \
  --metric "CpuTime" \
  --start-time 2025-10-01T00:00:00Z

# Memory usage
az monitor metrics list \
  --resource $(az webapp show --resource-group church-presenter-rg --name myapp --query id -o tsv) \
  --metric "MemoryWorkingSet" \
  --start-time 2025-10-01T00:00:00Z

# Request count
az monitor metrics list \
  --resource $(az webapp show --resource-group church-presenter-rg --name myapp --query id -o tsv) \
  --metric "Requests" \
  --start-time 2025-10-01T00:00:00Z
```

---

## 🔧 Advanced Troubleshooting

### Enable Debug Logging

```bash
# Enable application logging
az webapp log config \
  --resource-group church-presenter-rg \
  --name myapp \
  --application-logging true \
  --level verbose

# Enable web server logging
az webapp log config \
  --resource-group church-presenter-rg \
  --name myapp \
  --web-server-logging filesystem
```

### SSH into App Container

```bash
# Open SSH session (Linux App Service only)
az webapp ssh \
  --resource-group church-presenter-rg \
  --name myapp

# Inside container:
# Check files: ls -la
# View logs: cat /home/LogFiles/*.log
# Test Python: python --version
```

### Test Locally First

```bash
# Always test locally before deploying
python server.py

# Open in browser
http://localhost:8000/operator.html

# If works locally but not in Azure, likely config issue
```

### Compare with Working Deployment

```bash
# Export config from working app
az webapp config appsettings list \
  --resource-group church-presenter-rg \
  --name working-app \
  -o json > working-config.json

# Compare with broken app
az webapp config appsettings list \
  --resource-group church-presenter-rg \
  --name broken-app \
  -o json > broken-config.json

# Review differences
diff working-config.json broken-config.json
```

---

## 📞 Getting Help

### 1. Check Documentation

- [AZURE-DEPLOYMENT-V2.md](AZURE-DEPLOYMENT-V2.md) - Full guide
- [AZURE-QUICK-DEPLOY.md](AZURE-QUICK-DEPLOY.md) - Quick reference
- [MIGRATION-V1-TO-V2.md](MIGRATION-V1-TO-V2.md) - Migration guide

### 2. View Logs

```bash
az webapp log tail --resource-group church-presenter-rg --name myapp
```

### 3. Test Locally

```bash
python server.py
```

### 4. Check Azure Status

- Azure Status: https://status.azure.com
- Service Health: Azure Portal → Service Health

### 5. Azure Support

- Free support: https://azure.microsoft.com/support/community/
- Paid support: Azure Portal → Help + support

---

## ✅ Prevention Checklist

Before deploying:

- [ ] Azure CLI installed and updated
- [ ] Logged in to Azure (`az login`)
- [ ] App name is globally unique
- [ ] Subscription selected
- [ ] Resource providers registered
- [ ] Files are ready (songs, images, etc.)
- [ ] Tested locally (`python server.py`)
- [ ] Read deployment documentation

During deployment:

- [ ] Watch for errors in output
- [ ] Note the app URL provided
- [ ] Wait for deployment to complete
- [ ] Don't interrupt the process

After deployment:

- [ ] Test app URL in browser
- [ ] Check operator page
- [ ] Check projector page
- [ ] Verify WebSocket connection
- [ ] Test song loading
- [ ] Save deployment info

---

## 🎯 Common Mistakes

### 1. Wrong Python Version

**Problem:** Using Python 2.x or old Python 3.x

**Solution:**
```bash
# Check Python version
python --version
# Should be 3.7 or higher

# Update if needed
```

### 2. Missing Dependencies

**Problem:** `requirements.txt` incomplete

**Solution:**
```bash
# Ensure requirements.txt contains:
websockets==12.0

# Or regenerate:
pip freeze > requirements.txt
```

### 3. Incorrect Startup Command

**Problem:** Wrong startup command in Azure

**Solution:**
```bash
# Set correct command
az webapp config set \
  --resource-group church-presenter-rg \
  --name myapp \
  --startup-file "python server.py"
```

### 4. Firewall Blocking

**Problem:** Corporate firewall blocks Azure CLI or WebSocket

**Solution:**
- Use personal network for deployment
- Contact IT to whitelist Azure services
- Use VPN if available

### 5. Not Waiting for Cold Start

**Problem:** Accessing app immediately after deployment (Free tier)

**Solution:**
- Wait 30-60 seconds
- Refresh the page
- Check logs for actual errors

---

## 📊 Troubleshooting Flowchart

```
Is deployment failing?
├─ Yes → Check error message → See specific solutions above
└─ No → Continue

Is app deployed but not working?
├─ Yes → Check logs → `az webapp log tail`
└─ No → Continue

Is WebSocket connecting?
├─ No → Enable WebSocket → See WebSocket section
└─ Yes → Continue

Are songs loading?
├─ No → Check songs directory → Re-deploy
└─ Yes → Continue

Everything works! 🎉
```

---

**Remember:** Most issues are configuration-related. Check logs first, test locally, and compare with working deployments!

---

**Last Updated:** October 2025  
**Version:** 2.0
