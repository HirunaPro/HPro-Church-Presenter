# Migration Guide: v1 to v2 Deployment

> How to upgrade from the old deployment scripts to the new v2 deployment

---

## 🎯 Why Upgrade?

The new v2 deployment scripts offer:

✅ **Faster deployment** - ZIP method is 2x faster  
✅ **Better error handling** - Clear messages with solutions  
✅ **More options** - Multiple deployment methods  
✅ **Improved UX** - Color-coded output, progress indicators  
✅ **Automatic configuration** - WebSocket, app settings, etc.  
✅ **Cost transparency** - See pricing before deploying  

---

## 🔄 Quick Migration

### If You Have an Existing Deployment

**Option 1: Keep Existing (Recommended)**

Your existing deployment will continue to work! No action needed.

**Option 2: Update In-Place**

Just run the new script with your existing app name:

```powershell
# Windows - Updates your existing app
.\deploy-to-azure-v2.ps1 -AppName "your-existing-app-name" -DeploymentMethod zip
```

```bash
# Linux/Mac - Updates your existing app
./deploy-to-azure-v2.sh --app-name "your-existing-app-name" --method zip
```

**Option 3: Fresh Deployment**

Deploy a new instance and switch over:

```powershell
# 1. Deploy new instance
.\deploy-to-azure-v2.ps1 -AppName "church-app-v2-$(Get-Random)"

# 2. Test the new deployment
# 3. Delete old deployment when ready
az webapp delete --resource-group church-presenter-rg --name "old-app-name"
```

---

## 📊 Feature Comparison

| Feature | v1 (Old Scripts) | v2 (New Scripts) |
|---------|------------------|------------------|
| **Deployment Methods** | Git only | ZIP, Git, GitHub |
| **Speed** | ~5 minutes | ~2-3 minutes (ZIP) |
| **Error Messages** | Generic | Specific + solutions |
| **Validation** | Minimal | Comprehensive |
| **Subscription Selection** | Manual | Interactive menu |
| **WebSocket Config** | Manual | Automatic |
| **App Settings** | Basic | Optimized |
| **Cost Info** | Limited | Full breakdown |
| **Output** | Plain text | Color-coded |
| **Help/Documentation** | Basic | Extensive |

---

## 🚦 Step-by-Step Migration

### Step 1: Backup Current Deployment Info

Write down your current:
- App name: `_________________`
- Resource group: `_________________`
- Azure region: `_________________`

Find them with:
```bash
az webapp list --output table
```

### Step 2: Test New Script Locally

```bash
# Don't deploy yet, just validate
python server.py

# Make sure everything works locally first
```

### Step 3: Choose Migration Path

#### Path A: Update Existing App (Zero Downtime)

```powershell
# This updates your existing app in-place
.\deploy-to-azure-v2.ps1 `
    -AppName "your-existing-app-name" `
    -ResourceGroup "your-resource-group" `
    -DeploymentMethod zip

# Your app URL stays the same!
```

**Pros:**
- ✅ Same URL, no need to update links
- ✅ Same resource group
- ✅ Fast update

**Cons:**
- ⚠️ Brief downtime during update (~30 seconds)

#### Path B: New Deployment (Safest)

```powershell
# Deploy new instance
.\deploy-to-azure-v2.ps1 `
    -AppName "church-app-new" `
    -ResourceGroup "church-presenter-v2" `
    -DeploymentMethod zip

# Test thoroughly

# When ready, delete old deployment
az group delete --name "old-resource-group" --yes
```

**Pros:**
- ✅ Zero risk to current deployment
- ✅ Test before switching
- ✅ Can keep both running

**Cons:**
- ⚠️ New URL to update
- ⚠️ Costs for both (if using paid tier)

### Step 4: Verify New Deployment

```bash
# Check app is running
az webapp show --resource-group church-presenter-rg --name YOUR-APP-NAME --query state

# View logs
az webapp log tail --resource-group church-presenter-rg --name YOUR-APP-NAME

# Test in browser
# https://YOUR-APP-NAME.azurewebsites.net/operator.html
```

### Step 5: Clean Up (Optional)

If you deployed a new instance and want to remove the old one:

```bash
# Delete old resource group
az group delete --name "old-resource-group-name" --yes

# Or just delete the old app
az webapp delete --resource-group "resource-group" --name "old-app-name"
```

---

## 🔧 Configuration Changes

### Old Startup Command
```bash
python server.py
```

### New Startup Command (v2)
```bash
gunicorn --bind=0.0.0.0:8000 --worker-class=gevent --workers=1 --timeout=600 server:app
```

> **Note:** The v2 script sets this automatically. If updating manually, use `python server.py` for simplicity.

### New App Settings Added

The v2 script automatically adds:
- `SCM_DO_BUILD_DURING_DEPLOYMENT=true`
- `ENABLE_ORYX_BUILD=true`
- `WEBSITE_HTTPLOGGING_RETENTION_DAYS=3`

These optimize the build process and logging.

---

## 📝 Script File Mapping

| Old Script | New Script | Notes |
|------------|------------|-------|
| `deploy-to-azure.ps1` | `deploy-to-azure-v2.ps1` | Complete rewrite |
| `deploy-to-azure.sh` | `deploy-to-azure-v2.sh` | Complete rewrite |
| `deploy-to-azure-b1.ps1` | Use `-Tier Basic` | Now unified |
| `deploy-to-azure-multi-region.ps1` | Use `-Location` param | Now unified |
| `deploy-to-azure-container.ps1` | Use `-DeploymentMethod` | Now unified |

**All deployment options are now in ONE script!**

---

## ❓ Common Questions

### Q: Will my songs be migrated?

**A:** If updating in-place (same app name), yes. If deploying new, you need to:
1. Download songs from old app
2. Upload to new app

Or manually copy the `/songs` folder.

### Q: Can I still use the old scripts?

**A:** Yes! They still work. But v2 is recommended for:
- Faster deployments
- Better error handling
- More features

### Q: What if something goes wrong?

**A:** 
1. Keep old deployment running until new one is tested
2. Have local backup: `python server.py`
3. You can always redeploy with old scripts

### Q: Do I need to change my code?

**A:** No! The application code is the same. Only deployment method changed.

### Q: Will my URL change?

**A:** 
- Update in-place: No, same URL
- New deployment: Yes, new URL

### Q: Can I use the same resource group?

**A:** Yes! Just use the same `-ResourceGroup` parameter.

---

## 🎯 Recommended Approach

For most users:

1. **Test new script with new app name**
   ```powershell
   .\deploy-to-azure-v2.ps1 -AppName "church-test-$(Get-Random)"
   ```

2. **Verify it works**
   - Test operator page
   - Test projector page
   - Test song upload

3. **When confident, update existing app**
   ```powershell
   .\deploy-to-azure-v2.ps1 -AppName "your-production-app-name"
   ```

4. **Delete test app**
   ```bash
   az webapp delete --resource-group church-presenter-rg --name "church-test-XXXX"
   ```

---

## 📞 Rollback Plan

If you need to revert to old deployment:

```powershell
# Option 1: Keep old scripts and use them
.\deploy-to-azure.ps1

# Option 2: Manual revert via Azure CLI
az webapp config set \
    --resource-group church-presenter-rg \
    --name your-app-name \
    --startup-file "python server.py"

# Restart app
az webapp restart --resource-group church-presenter-rg --name your-app-name
```

---

## 📊 Migration Checklist

- [ ] Backup current deployment info (app name, resource group)
- [ ] Test application locally: `python server.py`
- [ ] Install latest Azure CLI: `az upgrade`
- [ ] Download new scripts (v2)
- [ ] Test deploy to new app name
- [ ] Verify new deployment works
- [ ] Update production deployment OR switch URLs
- [ ] Test thoroughly before Sunday service
- [ ] Clean up old resources (optional)
- [ ] Update bookmarks/links if URL changed

---

## 💡 Pro Tips

1. **Migrate on Saturday** - Give yourself time to test before Sunday

2. **Keep both running initially** - Old and new, switch gradually

3. **Document your app names** - Save them in a text file

4. **Use ZIP deployment** - It's the fastest method in v2

5. **Test the full workflow** - Operator → Projector → Songs

---

## 🎉 Benefits After Migration

After migrating to v2 scripts, you get:

- ⚡ **50% faster deployments** (ZIP method)
- 🎨 **Better visual feedback** (colors, emojis)
- 🐛 **Easier troubleshooting** (clear error messages)
- 💰 **Cost transparency** (pricing shown upfront)
- 🔧 **More deployment options** (ZIP, Git, GitHub)
- ✅ **Better validation** (catches errors early)
- 📊 **Subscription selection** (no more manual switching)

---

## 🆘 Need Help?

- **Full v2 Guide:** `docs/AZURE-DEPLOYMENT-V2.md`
- **Quick Reference:** `docs/AZURE-QUICK-DEPLOY.md`
- **Old Guide:** `docs/AZURE-DEPLOYMENT.md` (still works!)

---

**Remember:** The old scripts still work! Migrate when you're ready. No rush! 🙂
