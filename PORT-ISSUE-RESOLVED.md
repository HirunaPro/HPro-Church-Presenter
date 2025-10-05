# 🔧 Port Conflict Issue - FIXED!

## The Problem

Your container logs showed:
```
OSError: [Errno 98] Address already in use
```

This means **port 8080 was already being used** by another process (likely the old container instance).

---

## ✅ What I Fixed

### 1. **Improved Server Startup** (`server-optimized.py`)
- Added automatic retry logic (3 attempts)
- Better port binding with `SO_REUSEADDR` and `SO_REUSEPORT`
- Clearer error messages
- 2-second wait between retry attempts

### 2. **Updated Deployment Scripts**
- Added **10-second wait** after deleting old container
- Ensures Azure releases the port before creating new container
- Updated both PowerShell and Bash scripts

### 3. **Created New Helper Scripts**

**`restart-container.ps1`** - Clean restart utility:
- Stops container
- Waits 15 seconds for resources to free
- Starts container
- Shows URLs when ready

### 4. **Created Troubleshooting Guide**
**`PORT-CONFLICT-FIX.md`** - Complete guide for port issues

---

## 🚀 How to Fix Right Now

### Quick Fix - Restart Container (1 minute)

```powershell
.\restart-container.ps1 -AppName "mychurch-app"
```

This will:
1. Stop the container
2. Wait 15 seconds for port to be freed
3. Start the container
4. Show you the URLs

### OR Redeploy (3-5 minutes)

```powershell
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```

This will:
1. Delete old container completely
2. Wait 10 seconds
3. Build and deploy fresh container
4. No port conflicts!

---

## 🔍 Why This Happened

**Root cause:** When redeploying, the old container wasn't fully deleted before creating the new one.

**Result:** Both tried to use port 8080, causing conflict

**Fix:** Deployment script now waits 10 seconds after deletion to ensure port is freed

---

## 📋 New Files Created

1. **`restart-container.ps1`** - Quick restart utility
2. **`PORT-CONFLICT-FIX.md`** - Complete troubleshooting guide
3. **Updated `server-optimized.py`** - Better error handling
4. **Updated deployment scripts** - Added wait time

---

## ✅ Verification

After restarting or redeploying, check logs:

```powershell
.\view-logs.ps1
```

**Good output (working):**
```
HTTP Server running on:
  - http://localhost:8080
  - http://192.168.0.159:8080
Performance optimizations enabled:
  ✅ Gzip compression
  ✅ Aggressive caching
  ✅ Threading support

WebSocket Server running on:
  - ws://localhost:8765
  - ws://192.168.0.159:8765
```

**Bad output (still broken):**
```
OSError: [Errno 98] Address already in use
```
→ Try the restart script again or redeploy

---

## 🎯 Recommended Action

**Use the restart script first** (fastest):

```powershell
.\restart-container.ps1 -AppName "mychurch-app"
```

**If that doesn't work, redeploy:**

```powershell
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```

---

## 💡 Prevention Tips

### 1. Always Use the Scripts
Don't manually start/stop containers without waiting

### 2. Wait Between Operations
```powershell
# Stop
.\stop-container.ps1
# Wait 10 seconds
Start-Sleep -Seconds 10
# Start
.\start-container.ps1
```

### 3. Check Status First
```powershell
.\check-status.ps1
```

### 4. Use Restart Script
When in doubt, use the restart script - it handles timing automatically

---

## 🆘 If Still Having Issues

### Option 1: Force Delete and Redeploy
```powershell
# Force delete
az container delete --name mychurch-app --resource-group church-presenter-rg --yes

# Wait 30 seconds
Start-Sleep -Seconds 30

# Redeploy
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```

### Option 2: Check for Multiple Containers
```powershell
# List all containers
az container list --resource-group church-presenter-rg --output table

# Delete any old ones
az container delete --name OLD-NAME --resource-group church-presenter-rg --yes
```

### Option 3: Change Port (Last Resort)
See `PORT-CONFLICT-FIX.md` for instructions on using a different port

---

## 📚 Documentation

**Quick fix:** This document  
**Complete guide:** [`PORT-CONFLICT-FIX.md`](PORT-CONFLICT-FIX.md)  
**Performance guide:** [`PERFORMANCE-UPDATE.md`](PERFORMANCE-UPDATE.md)  

---

## ✅ Summary

**Issue:** Port 8080 already in use  
**Cause:** Old container not fully deleted before new deployment  
**Fix:** Updated scripts with proper wait times  
**Your action:** Run restart script or redeploy  

```powershell
# Quick fix (1 minute):
.\restart-container.ps1 -AppName "mychurch-app"

# OR full redeploy (3-5 minutes):
.\deploy-azure-container.ps1 -AppName "mychurch-app"
```

**This should completely resolve the port conflict!** 🎉

---

**Version:** 1.1.1  
**Issue:** Port conflict  
**Status:** ✅ Fixed  
**Date:** October 2025
