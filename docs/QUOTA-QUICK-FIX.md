# 🚨 QUOTA ISSUE - QUICK FIX

## Your Error:
```
Operation cannot be completed without additional quota.
Current Limit (Free VMs): 0
```

## ⚡ FASTEST FIX (Try This First):

```powershell
.\deploy-to-azure-multi-region.ps1
```

This script will automatically try 10+ regions to find available quota.

---

## ✅ BEST FIX (If Above Fails):

### Step 1: Install Docker
Download: https://www.docker.com/products/docker-desktop
→ Install it
→ **Restart your computer**

### Step 2: Deploy with Container Instances
```powershell
.\deploy-to-azure-container.ps1
```

**Why this works:**
- Uses different quota (Container Instances, not App Service)
- Almost always available
- Low cost: $1-2/month for typical church use
- Pay only when running

---

## 💰 Cost Comparison:

| Method | Sunday Only | Notes |
|--------|-------------|-------|
| Multi-Region (B1) | $0.43/mo | If quota available |
| Container Instances | $1.04/mo | Always works ✅ |

---

## 🎯 TL;DR

1. Try: `.\deploy-to-azure-multi-region.ps1`
2. If fails → Install Docker → `.\deploy-to-azure-container.ps1`
3. Done! ✅

---

## After Deployment:

### Container Instances:
```powershell
# Start before church
.\azure-container-start.ps1

# Stop after church
.\azure-container-stop.ps1
```

### App Service (Multi-Region):
```powershell
# Stop after church
.\azure-stop.ps1 -ResourceGroup church-presenter-rg -AppName YOUR-APP-NAME

# Start before church
.\azure-start.ps1 -ResourceGroup church-presenter-rg -AppName YOUR-APP-NAME
```

---

## 📖 Full Guide:
See `QUOTA-ISSUE-SOLUTIONS.md` for detailed explanations.
