#!/bin/bash
# Stop Azure App Service
# Usage: ./azure-stop.sh <resource-group> <app-name>
#
# This script stops your Azure App Service to save costs when not in use.
# For paid tiers (B1, S1), you only pay when the app is running.

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI not found!"
    echo ""
    echo "Please install Azure CLI:"
    echo "  Windows:   https://aka.ms/installazurecliwindows"
    echo "  macOS:     brew install azure-cli"
    echo "  Linux:     https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Get parameters
RESOURCE_GROUP=$1
APP_NAME=$2

if [ -z "$RESOURCE_GROUP" ] || [ -z "$APP_NAME" ]; then
    print_error "Missing required parameters!"
    echo ""
    echo "Usage: $0 <resource-group> <app-name>"
    echo ""
    echo "Example:"
    echo "  $0 church-presentation-rg church-presenter-app"
    exit 1
fi

echo ""
echo "=========================================="
echo "  Stopping Azure App Service"
echo "=========================================="
echo ""
print_info "Resource Group: $RESOURCE_GROUP"
print_info "App Name:       $APP_NAME"
echo ""

# Check if logged in to Azure
print_info "Checking Azure login status..."
if ! az account show &> /dev/null; then
    print_warning "Not logged in to Azure"
    print_info "Logging in..."
    az login
fi

# List available subscriptions
echo ""
print_info "Available subscriptions:"
az account list --query "[].{Name:name, ID:id, Default:isDefault}" -o table
echo ""

# Prompt for subscription selection
read -p "Enter the Subscription ID you want to use (or press Enter to use default): " SUBSCRIPTION_ID

if [ -n "$SUBSCRIPTION_ID" ]; then
    print_info "Setting subscription to: $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"
fi

# Get current subscription info
SUBSCRIPTION=$(az account show --query name -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
print_success "Logged in to Azure"
print_info "Active Subscription: $SUBSCRIPTION"
print_info "Tenant ID: $TENANT_ID"
echo ""

# Check if app exists
print_info "Checking if app exists..."
if ! az webapp show --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" &> /dev/null; then
    print_error "App not found!"
    echo ""
    echo "Please check:"
    echo "  - Resource group name is correct"
    echo "  - App name is correct"
    echo "  - You have access to the subscription"
    exit 1
fi

print_success "App found"
echo ""

# Get current state
print_info "Getting current app state..."
STATE=$(az webapp show --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" --query state -o tsv)

if [ "$STATE" == "Stopped" ]; then
    print_success "App is already stopped!"
    echo ""
    print_info "No action needed - app is not running"
    echo ""
    exit 0
fi

# Stop the app
print_info "Stopping the app..."
az webapp stop --resource-group "$RESOURCE_GROUP" --name "$APP_NAME"

print_success "App stopped successfully!"
echo ""

# Get pricing tier info
SKU=$(az appservice plan list --resource-group "$RESOURCE_GROUP" --query "[0].sku.name" -o tsv)

if [ "$SKU" == "F1" ]; then
    print_info "App is on Free Tier (F1) - stopping doesn't save costs"
else
    print_success "App stopped - you're now saving money on the $SKU tier!"
fi

echo ""
print_info "To start the app again, run:"
print_info "  ./azure-start.sh $RESOURCE_GROUP $APP_NAME"
echo ""
echo "=========================================="
