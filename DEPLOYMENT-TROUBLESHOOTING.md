# Quick Fix Guide - Deployment Errors

## Problem: "Subscription not registered to use namespace 'Microsoft.Web'"

This error means your Azure subscription doesn't have the required resource providers registered yet.

---

## ✅ Solution 1: Use the Updated Deployment Script (Easiest)

The deployment script has been updated to automatically register providers!

**Just run it again:**
```powershell
.\deploy-to-azure.ps1
```

It will now:
1. Check if providers are registered
2. Auto-register Microsoft.Web, Microsoft.Storage, and Microsoft.Network
3. Wait for registration to complete
4. Then create your resources

---

## ✅ Solution 2: Manually Register Providers (If needed)

If you want to register providers separately first:

**PowerShell:**
```powershell
.\register-azure-providers.ps1
```

**Bash:**
```bash
chmod +x register-azure-providers.sh
./register-azure-providers.sh
```

Then run the deployment:
```powershell
.\deploy-to-azure.ps1
```

---

## ✅ Solution 3: Manual Commands

```powershell
# Login and select your subscription
az login
az account set --subscription "YOUR-SUBSCRIPTION-ID"

# Register the required providers (takes 1-2 minutes each)
az provider register --namespace Microsoft.Web --wait
az provider register --namespace Microsoft.Storage --wait
az provider register --namespace Microsoft.Network --wait

# Verify registration
az provider show --namespace Microsoft.Web --query registrationState
```

When it shows `"Registered"`, you're ready to deploy!

---

## 🔄 Clean Up Failed Resources (If needed)

If you have partial resources from the failed deployment:

```powershell
# Delete the resource group and start fresh
az group delete --name church-presenter-rg --yes

# Then run the deployment again
.\deploy-to-azure.ps1
```

---

## 📋 Step-by-Step Deployment (After Fixing)

1. **Register Providers** (automatic in updated script):
   ```powershell
   .\deploy-to-azure.ps1
   ```

2. **When prompted**:
   - Select your subscription
   - Enter a **unique** app name (e.g., `gracechurch-presenter-2025`)
   - Resource group: `church-presenter-rg` (or your choice)
   - Location: `eastus` (or nearest region)

3. **Wait for deployment** (5-10 minutes):
   - Providers will register (1-2 min)
   - Resources will be created (3-5 min)
   - Code will be deployed (2-3 min)

4. **Access your app**:
   - The script will show your URLs
   - `https://YOUR-APP-NAME.azurewebsites.net`

---

## ⚠️ Important Notes

### App Name Must Be Globally Unique

If you get "name already taken" error:

```powershell
# Try adding your church name or year
# Instead of: twtr-present
# Use: gracechurch-presenter
# Or: firstbaptist-worship-2025
```

### Provider Registration Takes Time

- First time: 1-2 minutes per provider
- The updated script waits for completion automatically
- You only need to do this once per subscription

---

## 🎯 Quick Checklist

Before deploying, make sure:

- [ ] Azure CLI is installed
- [ ] You're logged in: `az login`
- [ ] You've selected the correct subscription
- [ ] Providers are registered (script does this automatically now)
- [ ] Your app name is unique
- [ ] You have contributor access to the subscription

---

## 💡 Still Having Issues?

**Check your subscription access:**
```powershell
az role assignment list --assignee YOUR-EMAIL@domain.com
```

You need at least "Contributor" role.

**Check provider status:**
```powershell
az provider list --query "[?namespace=='Microsoft.Web'].{Namespace:namespace, State:registrationState}" -o table
```

Should show: `Registered`

---

## ✅ Next Steps After Successful Deployment

1. **Test your app**:
   - Visit `https://YOUR-APP-NAME.azurewebsites.net`
   - Open operator and projector pages
   - Test the connection

2. **Configure your church**:
   - Update church name in code
   - Add your songs
   - Upload church logo

3. **Use start/stop scripts** to save costs:
   ```powershell
   # Before service
   .\azure-start.ps1 -ResourceGroup church-presenter-rg -AppName YOUR-APP-NAME
   
   # After service
   .\azure-stop.ps1 -ResourceGroup church-presenter-rg -AppName YOUR-APP-NAME
   ```

---

**The deployment script is now fixed and will handle provider registration automatically!**

Just run: `.\deploy-to-azure.ps1` 🚀
