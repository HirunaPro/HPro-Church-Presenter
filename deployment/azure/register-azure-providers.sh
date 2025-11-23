#!/bin/bash
# Bash script to register Azure resource providers
# Run this if you get "subscription not registered" errors

set -e

echo "=========================================="
echo "  Azure Resource Provider Registration"
echo "=========================================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found!"
    echo "Please install from: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Check login
echo "📝 Checking Azure login..."
if ! az account show &> /dev/null; then
    echo "Logging in to Azure..."
    az login
fi

SUBSCRIPTION=$(az account show --query name -o tsv)
echo "✅ Logged in to subscription: $SUBSCRIPTION"
echo ""

echo "Registering required resource providers..."
echo ""

# Required providers for App Service
declare -A PROVIDERS
PROVIDERS=(
    ["Microsoft.Web"]="Azure App Service"
    ["Microsoft.Storage"]="Azure Storage"
    ["Microsoft.Network"]="Azure Networking"
)

for provider in "${!PROVIDERS[@]}"; do
    echo "Checking $provider (${PROVIDERS[$provider]})..."
    
    status=$(az provider show --namespace "$provider" --query "registrationState" -o tsv 2>/dev/null)
    
    if [ "$status" = "Registered" ]; then
        echo "  ✅ Already registered"
    elif [ "$status" = "Registering" ]; then
        echo "  ⏳ Currently registering... waiting..."
        az provider register --namespace "$provider" --wait
        echo "  ✅ Registration complete!"
    else
        echo "  📝 Not registered. Registering now..."
        echo "     (This may take 1-2 minutes)"
        
        az provider register --namespace "$provider" --wait
        
        # Verify registration
        newStatus=$(az provider show --namespace "$provider" --query "registrationState" -o tsv)
        if [ "$newStatus" = "Registered" ]; then
            echo "  ✅ Successfully registered!"
        else
            echo "  ⚠️  Status: $newStatus"
        fi
    fi
    echo ""
done

echo "=========================================="
echo "  ✅ All providers registered!"
echo "=========================================="
echo ""
echo "You can now run the deployment script:"
echo "  ./deploy-to-azure.sh"
echo ""
