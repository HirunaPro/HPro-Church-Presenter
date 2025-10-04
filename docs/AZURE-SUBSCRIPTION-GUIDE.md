# Azure Subscription Management Guide

This guide helps you manage multiple Azure subscriptions and tenants when deploying the Church Presentation App.

---

## 🔐 Understanding Azure Subscriptions & Tenants

- **Tenant**: Your organization's Azure Active Directory (AAD) instance
- **Subscription**: A billing container within a tenant
- You can have **multiple subscriptions** in one tenant
- You can have access to **multiple tenants**

---

## 📋 View Your Subscriptions

### List All Subscriptions
```bash
az account list --output table
```

This shows:
- Subscription Name
- Subscription ID
- Tenant ID
- Which one is currently active (IsDefault: True)

### Show Current Subscription
```bash
az account show
```

---

## 🔄 Switch Subscriptions

### Method 1: Using Subscription ID
```bash
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

### Method 2: Using Subscription Name
```bash
az account set --subscription "Your Subscription Name"
```

### Verify the Change
```bash
az account show --query "{Name:name, ID:id, TenantID:tenantId}" -o table
```

---

## 🏢 Working with Multiple Tenants

### Login to a Specific Tenant
```bash
# Login with tenant ID
az login --tenant "YOUR-TENANT-ID"

# Login and select specific subscription
az login --tenant "YOUR-TENANT-ID"
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

### List All Tenants You Have Access To
```bash
az account list --query "[].{Tenant:tenantId, Subscription:name}" -o table | sort | uniq
```

---

## 🚀 Using Scripts with Specific Subscription

### Option 1: Set Before Running Scripts

**PowerShell:**
```powershell
# Set your subscription first
az account set --subscription "YOUR-SUBSCRIPTION-ID"

# Then run the script
.\azure-start.ps1 -ResourceGroup church-rg -AppName my-app
```

**Bash:**
```bash
# Set your subscription first
az account set --subscription "YOUR-SUBSCRIPTION-ID"

# Then run the script
./azure-start.sh church-rg my-app
```

### Option 2: Scripts Now Prompt You!

The updated scripts will:
1. Show all your subscriptions
2. Ask which one to use
3. Let you press Enter to use the default

**Example:**
```
Available subscriptions:
Name                          ID                                    Default
----------------------------  ------------------------------------  ---------
Visual Studio Enterprise      12345678-1234-1234-1234-123456789abc  True
Pay-As-You-Go                 87654321-4321-4321-4321-cba987654321  False
Church Ministry               abcdef12-abcd-abcd-abcd-123456abcdef  False

Enter the Subscription ID you want to use (or press Enter to use default):
```

Just paste your desired Subscription ID!

---

## 💡 Common Scenarios

### Scenario 1: You Have Work & Personal Subscriptions

```bash
# List them
az account list -o table

# Set to personal subscription
az account set --subscription "Personal-Subscription-ID"

# Deploy to personal subscription
.\deploy-to-azure.ps1
```

### Scenario 2: Church Has Its Own Tenant/Subscription

```bash
# Login to church tenant
az login --tenant "church-tenant-id"

# Select church subscription
az account set --subscription "church-subscription-id"

# Verify
az account show

# Deploy
.\deploy-to-azure.ps1
```

### Scenario 3: Using Azure Free Account

```bash
# Login
az login

# Your free subscription should be default
az account show

# If not, set it
az account set --subscription "Azure subscription 1"

# Deploy with free tier
.\deploy-to-azure.ps1
```

---

## 🛠️ Troubleshooting

### "Subscription not found" Error

**Problem**: Wrong subscription selected

**Solution**:
```bash
# List all subscriptions
az account list -o table

# Copy the correct Subscription ID
# Set it
az account set --subscription "CORRECT-ID"

# Verify
az account show
```

### "Insufficient permissions" Error

**Problem**: Don't have access to the subscription

**Solution**:
1. Verify you're in the right subscription:
   ```bash
   az account show
   ```
2. Check your role:
   ```bash
   az role assignment list --assignee YOUR-EMAIL@example.com
   ```
3. You need at least "Contributor" role
4. Contact your Azure admin to grant access

### Multiple Tenants Confusion

**Problem**: Resources are in different tenants

**Solution**:
```bash
# Clear Azure CLI cache
az account clear

# Login to specific tenant
az login --tenant "YOUR-TENANT-ID"

# List resources
az resource list -o table
```

---

## 📝 Quick Reference Commands

### Get Your Tenant ID
```bash
az account show --query tenantId -o tsv
```

### Get Your Subscription ID
```bash
az account show --query id -o tsv
```

### Get Your Subscription Name
```bash
az account show --query name -o tsv
```

### See All Your Resource Groups
```bash
az group list --query "[].{Name:name, Location:location}" -o table
```

### Find Which Subscription Has Your App
```bash
# Search all subscriptions
az account list --query "[].id" -o tsv | while read -r sub; do
    echo "Checking subscription: $sub"
    az webapp list --subscription $sub --query "[].{Name:name, ResourceGroup:resourceGroup}" -o table
done
```

---

## 🎯 Best Practices

1. **Set Default Subscription**
   ```bash
   # Set your preferred subscription as default
   az account set --subscription "YOUR-PREFERRED-ID"
   ```

2. **Use Subscription Names in Scripts**
   - Instead of hardcoding IDs, use names
   - More readable and maintainable

3. **Document Your Subscriptions**
   ```bash
   # Save your subscription info
   az account list > my-subscriptions.json
   ```

4. **Environment-Specific Subscriptions**
   - Dev/Test: Use free or low-cost subscription
   - Production: Use dedicated subscription

---

## ✅ Recommended Workflow for Church App

1. **First Time Setup**:
   ```bash
   # Login
   az login
   
   # List and choose subscription
   az account list -o table
   
   # Set your church subscription
   az account set --subscription "church-subscription-id"
   
   # Verify
   az account show
   ```

2. **Deploy**:
   ```powershell
   # Run deployment (it will now show subscription options)
   .\deploy-to-azure.ps1
   ```

3. **Daily Use**:
   ```powershell
   # Start before service
   .\azure-start.ps1 -ResourceGroup church-rg -AppName my-church-app
   
   # Stop after service
   .\azure-stop.ps1 -ResourceGroup church-rg -AppName my-church-app
   ```

---

## 📞 Need Help?

**View this file**: `AZURE-SUBSCRIPTION-GUIDE.md`

**Check current settings**:
```bash
az account show --query "{Subscription:name, Tenant:tenantId, ID:id}" -o json
```

**Reset everything**:
```bash
az logout
az login
```

---

*Last updated: October 2025*
