# Deployment Script Fixes - Change Log

## October 5, 2025 - Bug Fixes

### Issue 1: Docker Not Running Error
**Error:** `The system cannot find the file specified` when Docker Desktop is not running

**Fix Applied:**
- Improved Docker running check in `deploy-azure-container.ps1`
- Better error messages with step-by-step instructions
- Created comprehensive troubleshooting guides

**Files Updated:**
- `deploy-azure-container.ps1` - Enhanced Docker status check
- `docs/DOCKER-TROUBLESHOOTING.md` - Complete troubleshooting guide
- `DOCKER-QUICK-FIX.md` - Quick reference for common error
- `DEPLOYMENT-READY.md` - Updated with better Docker error info

**User Action Required:**
- Start Docker Desktop before running deployment
- Wait for whale icon to appear in system tray
- Verify with `docker ps` command

---

### Issue 2: OS Type Missing Error
**Error:** `The 'osType' for container group '<null>' is invalid. The value must be one of 'Windows,Linux'.`

**Fix Applied:**
- Added `--os-type Linux` parameter to Azure Container Instance creation
- Updated both PowerShell and Bash deployment scripts

**Files Updated:**
- `deploy-azure-container.ps1` - Added `--os-type Linux` parameter
- `deploy-azure-container.sh` - Added `--os-type Linux` parameter

**Technical Details:**
```powershell
# Before (missing parameter):
az container create \
    --name $AppName \
    --image $imageTag \
    ...

# After (fixed):
az container create \
    --name $AppName \
    --image $imageTag \
    --os-type Linux \  # <-- Added this line
    ...
```

**User Action Required:**
- None - fix is automatic
- Just run the deployment script again:
  ```powershell
  .\deploy-azure-container.ps1 -AppName "mychurch-app"
  ```

---

## How to Use Updated Scripts

### If You Already Tried Deployment

1. **Docker was not running:**
   - Start Docker Desktop
   - Wait for it to fully initialize
   - Run deployment again

2. **OS Type error occurred:**
   - The script is now fixed
   - Just run deployment again:
     ```powershell
     .\deploy-azure-container.ps1 -AppName "mychurch-app"
     ```

### Fresh Deployment

1. Ensure Docker Desktop is running
2. Run deployment script:
   ```powershell
   .\deploy-azure-container.ps1 -AppName "mychurch-app"
   ```
3. Wait 3-5 minutes for completion

---

## Verification

After these fixes, the deployment should:
1. ✅ Properly detect if Docker is running
2. ✅ Provide helpful error messages if Docker is not running
3. ✅ Successfully create Azure Container Instance with correct OS type
4. ✅ Complete deployment without errors

---

## Additional Resources

**For Docker issues:**
- [DOCKER-QUICK-FIX.md](DOCKER-QUICK-FIX.md)
- [docs/DOCKER-TROUBLESHOOTING.md](docs/DOCKER-TROUBLESHOOTING.md)

**For deployment help:**
- [DEPLOYMENT-READY.md](DEPLOYMENT-READY.md)
- [docs/AZURE-CONTAINER-QUICKSTART.md](docs/AZURE-CONTAINER-QUICKSTART.md)

---

**Status:** ✅ All known issues fixed  
**Version:** 1.0.1  
**Date:** October 5, 2025
