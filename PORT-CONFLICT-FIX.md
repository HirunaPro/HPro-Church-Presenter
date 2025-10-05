# Port Already in Use - Quick Fix

## Error: "OSError: [Errno 98] Address already in use"

This error means port 8080 is being used by another process (usually an old container instance).

---

## ✅ Quick Fix (Choose One)

### Option 1: Restart the Container (Fastest)

```powershell
# Stop the container
az container stop --resource-group church-presenter-rg --name mychurch-app

# Wait 10 seconds
Start-Sleep -Seconds 10

# Start the container
az container start --resource-group church-presenter-rg --name mychurch-app
```

**OR use the helper scripts:**
```powershell
.\stop-container.ps1
# Wait 10 seconds
.\start-container.ps1
```

### Option 2: Redeploy (Recommended)

This ensures clean deployment with updated code:

```powershell
# Redeploy (this will delete old container first)
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```

The script now:
- Deletes old container completely
- Waits 10 seconds for resources to free
- Creates fresh container

### Option 3: Manual Container Delete

If the above don't work:

```powershell
# 1. Force delete the container
az container delete --resource-group church-presenter-rg --name mychurch-app --yes

# 2. Wait 30 seconds
Start-Sleep -Seconds 30

# 3. Redeploy
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```

---

## 🔍 Why This Happens

### Common Causes

1. **Old Container Still Running**
   - Previous deployment didn't complete cleanly
   - Container restart while old one still active

2. **Multiple Deployments**
   - Deploying while previous deployment still running
   - Two containers trying to use same port

3. **Azure Resource Delay**
   - Container marked as deleted but resources not freed yet
   - Need to wait for Azure to release the port

---

## 🛡️ Prevention

### Best Practices

1. **Always delete before redeploy:**
   ```powershell
   # The deployment script now does this automatically
   .\deploy-azure-container.ps1 -AppName "mychurch-app"
   ```

2. **Wait between operations:**
   ```powershell
   # Stop container
   .\stop-container.ps1
   
   # Wait 10-30 seconds
   Start-Sleep -Seconds 10
   
   # Start or redeploy
   .\start-container.ps1
   ```

3. **Check status first:**
   ```powershell
   # Check if container exists
   az container show --name mychurch-app --resource-group church-presenter-rg
   
   # Check container state
   .\check-status.ps1
   ```

---

## 🔧 Updated Deployment Script

The deployment scripts have been updated to:

✅ **Wait 10 seconds after deleting** old container  
✅ **Retry binding** if port is busy  
✅ **Better error messages** to help troubleshoot  

**To get the fix:**
Just use the updated deployment script - it's already fixed!

---

## 🆘 If Still Not Working

### Step 1: Check What's Using the Port

```powershell
# View all your containers
az container list --resource-group church-presenter-rg --output table

# Delete any old/stuck containers
az container delete --name OLD-CONTAINER-NAME --resource-group church-presenter-rg --yes
```

### Step 2: Use Different Port (Last Resort)

If port 8080 is permanently blocked, you can use a different port:

**Edit `deploy-azure-container.ps1` line ~260:**
```powershell
# Change:
--ports 8080 8765 \
--environment-variables PORT=8080 HTTP_PORT=8080 WEBSOCKET_PORT=8765 \

# To:
--ports 8081 8765 \
--environment-variables PORT=8081 HTTP_PORT=8081 WEBSOCKET_PORT=8765 \
```

Then access at: `http://your-app.azurecontainer.io:8081`

### Step 3: Contact Azure Support

If issue persists, there may be an Azure infrastructure issue:
- Check Azure Service Health: https://status.azure.com
- Contact Azure Support through portal

---

## ✅ Verification

After applying fix, check container logs:

```powershell
.\view-logs.ps1

# Look for:
# "HTTP Server running on:"
# "✅ Gzip compression"
# "✅ Aggressive caching"
# 
# Should NOT see:
# "OSError: [Errno 98]"
# "Address already in use"
```

---

## 📝 Summary

**The issue:** Port 8080 already in use by old container  
**The fix:** Deployment script now waits after deleting  
**Your action:** Redeploy with updated script  

```powershell
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```

**Time to fix:** 3-5 minutes (deployment time)

---

**This should resolve the port conflict issue!** 🎉

---

**Version:** 1.1  
**Issue:** Port already in use  
**Status:** ✅ Fixed in deployment script  
**Date:** October 2025
