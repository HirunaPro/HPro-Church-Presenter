#!/bin/bash

#
# Church Presentation App - Azure Deployment Script v2.0
#
# Modern deployment script with multiple deployment methods:
# - Git-based deployment (local or GitHub)
# - ZIP deployment (fastest)
# - Container deployment (most flexible)
#
# Supports Free (F1), Basic (B1), and Standard (S1) tiers with cost optimization.
#
# Usage:
#   ./deploy-to-azure-v2.sh [OPTIONS]
#
# Options:
#   -a, --app-name NAME          Globally unique app name (required)
#   -g, --resource-group NAME    Resource group name (default: church-presenter-rg)
#   -l, --location LOCATION      Azure region (default: eastus)
#   -t, --tier TIER             Pricing tier: free, basic, standard (default: free)
#   -m, --method METHOD         Deployment method: git, zip, github (default: zip)
#   -h, --help                  Show this help message
#
# Examples:
#   ./deploy-to-azure-v2.sh --app-name mychurch-app --tier free --method zip
#   ./deploy-to-azure-v2.sh -a mychurch-app -t basic -m git
#

set -e

# Default values
APP_NAME=""
RESOURCE_GROUP="church-presenter-rg"
LOCATION="eastus"
TIER="free"
DEPLOYMENT_METHOD="zip"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Output functions
print_header() {
    echo -e "\n${CYAN}======================================================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}======================================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step() {
    echo -e "\n${CYAN}📍 $1${NC}"
}

# Help function
show_help() {
    cat << EOF
Church Presentation App - Azure Deployment Script v2.0

Usage:
  $0 [OPTIONS]

Options:
  -a, --app-name NAME          Globally unique app name (required)
  -g, --resource-group NAME    Resource group name (default: church-presenter-rg)
  -l, --location LOCATION      Azure region (default: eastus)
  -t, --tier TIER             Pricing tier: free, basic, standard (default: free)
  -m, --method METHOD         Deployment method: git, zip, github (default: zip)
  -h, --help                  Show this help message

Pricing Tiers:
  free      - F1 tier, \$0/month, 60 min/day compute
  basic     - B1 tier, ~\$13/month, unlimited compute
  standard  - S1 tier, ~\$69/month, auto-scaling

Deployment Methods:
  zip       - Fastest, packages and uploads files directly
  git       - Deploy from local Git repository
  github    - Deploy from GitHub repository

Examples:
  $0 --app-name mychurch-app --tier free --method zip
  $0 -a mychurch-app -t basic -m git

EOF
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--app-name)
            APP_NAME="$2"
            shift 2
            ;;
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -t|--tier)
            TIER="${2,,}"  # Convert to lowercase
            shift 2
            ;;
        -m|--method)
            DEPLOYMENT_METHOD="${2,,}"  # Convert to lowercase
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Run '$0 --help' for usage information"
            exit 1
            ;;
    esac
done

# Main script
print_header "Church Presentation App - Azure Deployment v2.0"

# Check prerequisites
print_step "Checking prerequisites..."

# Check Azure CLI
if ! command -v az &> /dev/null; then
    print_error "Azure CLI not found!"
    echo ""
    echo "Please install Azure CLI first:"
    echo "  Windows: https://aka.ms/installazurecliwindows"
    echo "  macOS:   brew install azure-cli"
    echo "  Linux:   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    echo ""
    exit 1
fi
print_success "Azure CLI installed"

# Check Git (for git/github deployment)
if [[ "$DEPLOYMENT_METHOD" == "git" || "$DEPLOYMENT_METHOD" == "github" ]]; then
    if ! command -v git &> /dev/null; then
        print_error "Git not found but required for $DEPLOYMENT_METHOD deployment!"
        echo ""
        echo "Please install Git: https://git-scm.com/downloads"
        echo ""
        exit 1
    fi
    print_success "Git installed"
fi

# Check zip command (for zip deployment)
if [[ "$DEPLOYMENT_METHOD" == "zip" ]]; then
    if ! command -v zip &> /dev/null; then
        print_error "zip command not found but required for ZIP deployment!"
        echo ""
        echo "Please install zip utility"
        echo ""
        exit 1
    fi
    print_success "zip utility installed"
fi

# Get app name if not provided
if [[ -z "$APP_NAME" ]]; then
    echo ""
    print_info "App name must be globally unique across Azure"
    read -p "Enter your app name (e.g., 'mychurch-presenter-$RANDOM'): " APP_NAME
    
    if [[ -z "$APP_NAME" ]]; then
        print_error "App name is required!"
        exit 1
    fi
fi

# Validate app name
if [[ ! "$APP_NAME" =~ ^[a-z0-9][a-z0-9-]{0,58}[a-z0-9]$ ]]; then
    print_error "Invalid app name! Must be 2-60 characters, lowercase letters, numbers, and hyphens only"
    exit 1
fi

# Validate tier
case "$TIER" in
    free|basic|standard)
        ;;
    *)
        print_error "Invalid tier: $TIER (must be: free, basic, or standard)"
        exit 1
        ;;
esac

# Validate deployment method
case "$DEPLOYMENT_METHOD" in
    git|zip|github)
        ;;
    *)
        print_error "Invalid deployment method: $DEPLOYMENT_METHOD (must be: git, zip, or github)"
        exit 1
        ;;
esac

# Display configuration
echo ""
echo "======================================================================"
echo -e "${CYAN}  DEPLOYMENT CONFIGURATION${NC}"
echo "======================================================================"
echo "  App Name:          $APP_NAME"
echo "  Resource Group:    $RESOURCE_GROUP"
echo "  Location:          $LOCATION"
echo "  Pricing Tier:      $TIER"
echo "  Deployment Method: $DEPLOYMENT_METHOD"

# Show pricing info
echo ""
echo -e "${YELLOW}  PRICING:${NC}"
case "$TIER" in
    free)
        echo -e "    ${GREEN}💰 Cost: \$0/month${NC}"
        echo -e "    ${GRAY}⏱️  Compute: 60 minutes/day${NC}"
        echo -e "    ${GRAY}💤 Sleeps after 20 min inactivity${NC}"
        ;;
    basic)
        echo -e "    ${YELLOW}💰 Cost: ~\$13/month (or less with start/stop)${NC}"
        echo -e "    ${GRAY}⏱️  Compute: Unlimited${NC}"
        echo -e "    ${GRAY}✅ Always On available${NC}"
        ;;
    standard)
        echo -e "    ${RED}💰 Cost: ~\$69/month${NC}"
        echo -e "    ${GRAY}⏱️  Compute: Unlimited${NC}"
        echo -e "    ${GRAY}🚀 Auto-scaling, SSL, custom domain${NC}"
        ;;
esac
echo -e "${CYAN}======================================================================${NC}"

echo ""
read -p "Proceed with deployment? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    print_warning "Deployment cancelled by user"
    exit 0
fi

# Azure login
print_step "Checking Azure authentication..."
if ! az account show &> /dev/null; then
    print_info "Please login to Azure..."
    az login
    if [[ $? -ne 0 ]]; then
        print_error "Failed to login to Azure"
        exit 1
    fi
fi
print_success "Logged in to Azure"

# Show subscriptions and select
echo ""
print_info "Available Azure subscriptions:"
subscriptions=$(az account list --query "[].{Name:name, ID:id, State:state}" -o json)
current_sub=$(az account show --query id -o tsv)

echo "$subscriptions" | jq -r '.[] | "\(.Name) - \(.State)"' | nl -w2 -s'. '

echo ""
read -p "Select subscription [1-$(echo "$subscriptions" | jq length)] or press Enter for current: " sub_choice

if [[ -n "$sub_choice" ]]; then
    selected_id=$(echo "$subscriptions" | jq -r ".[$((sub_choice-1))].ID")
    if [[ -n "$selected_id" && "$selected_id" != "null" ]]; then
        selected_name=$(echo "$subscriptions" | jq -r ".[$((sub_choice-1))].Name")
        print_info "Setting subscription to: $selected_name"
        az account set --subscription "$selected_id"
    fi
fi

current_account=$(az account show --query name -o tsv)
print_success "Using subscription: $current_account"

# Register resource providers
print_step "Registering required Azure resource providers..."
providers=("Microsoft.Web" "Microsoft.Storage" "Microsoft.Network")

for provider in "${providers[@]}"; do
    status=$(az provider show --namespace "$provider" --query "registrationState" -o tsv 2>/dev/null)
    
    if [[ "$status" != "Registered" ]]; then
        print_info "Registering $provider..."
        az provider register --namespace "$provider" --wait &> /dev/null
        print_success "$provider registered"
    else
        echo -e "  ${GRAY}✓ $provider already registered${NC}"
    fi
done

# Create resource group
print_step "Creating resource group..."
if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    print_info "Resource group '$RESOURCE_GROUP' already exists"
else
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
    print_success "Resource group created"
fi

# Map tier to SKU
case "$TIER" in
    free)
        SKU="F1"
        ;;
    basic)
        SKU="B1"
        ;;
    standard)
        SKU="S1"
        ;;
esac

# Create App Service Plan
print_step "Creating App Service Plan..."
PLAN_NAME="plan-$APP_NAME"

if az appservice plan show --name "$PLAN_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_info "App Service Plan already exists"
else
    print_info "Creating $TIER tier plan (SKU: $SKU)..."
    az appservice plan create \
        --name "$PLAN_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --sku "$SKU" \
        --is-linux \
        --output none
    
    if [[ $? -ne 0 ]]; then
        print_error "Failed to create App Service Plan"
        exit 1
    fi
    print_success "App Service Plan created"
fi

# Create Web App
print_step "Creating Web App..."
if az webapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_warning "Web App '$APP_NAME' already exists! Using existing app..."
else
    print_info "Creating Web App with Python 3.11 runtime..."
    az webapp create \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$PLAN_NAME" \
        --name "$APP_NAME" \
        --runtime "PYTHON:3.11" \
        --output none
    
    if [[ $? -ne 0 ]]; then
        print_error "Failed to create Web App"
        echo ""
        echo -e "${YELLOW}Possible issues:${NC}"
        echo "  • App name '$APP_NAME' might be taken globally"
        echo "  • Try: $APP_NAME-$RANDOM"
        exit 1
    fi
    print_success "Web App created"
fi

# Configure Web App
print_step "Configuring Web App..."

# Enable WebSocket
print_info "Enabling WebSocket support..."
az webapp config set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --web-sockets-enabled true \
    --output none

# Set startup command
print_info "Setting startup command..."
az webapp config set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --startup-file "gunicorn --bind=0.0.0.0:8000 --worker-class=gevent --workers=1 --timeout=600 server:app" \
    --output none

# Set app settings
print_info "Configuring application settings..."
az webapp config appsettings set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --settings \
        SCM_DO_BUILD_DURING_DEPLOYMENT=true \
        ENABLE_ORYX_BUILD=true \
        WEBSITE_HTTPLOGGING_RETENTION_DAYS=3 \
    --output none

print_success "Web App configured"

# Deploy application
print_step "Deploying application code..."

case "$DEPLOYMENT_METHOD" in
    zip)
        print_info "Creating deployment package..."
        
        # Create temporary directory
        TEMP_DIR=$(mktemp -d)
        ZIP_FILE=$(mktemp).zip
        
        # Copy files to temporary directory
        cp -r *.html "$TEMP_DIR/" 2>/dev/null || true
        cp -r *.py "$TEMP_DIR/" 2>/dev/null || true
        cp requirements.txt "$TEMP_DIR/" 2>/dev/null || true
        cp runtime.txt "$TEMP_DIR/" 2>/dev/null || true
        cp web.config "$TEMP_DIR/" 2>/dev/null || true
        cp -r css "$TEMP_DIR/" 2>/dev/null || true
        cp -r js "$TEMP_DIR/" 2>/dev/null || true
        cp -r images "$TEMP_DIR/" 2>/dev/null || true
        cp -r songs "$TEMP_DIR/" 2>/dev/null || true
        
        # Create ZIP file
        (cd "$TEMP_DIR" && zip -r "$ZIP_FILE" .) > /dev/null
        
        print_info "Uploading to Azure (this may take a minute)..."
        az webapp deployment source config-zip \
            --resource-group "$RESOURCE_GROUP" \
            --name "$APP_NAME" \
            --src "$ZIP_FILE" \
            --output none
        
        # Cleanup
        rm -rf "$TEMP_DIR"
        rm -f "$ZIP_FILE"
        
        if [[ $? -ne 0 ]]; then
            print_error "Failed to deploy via ZIP"
            exit 1
        fi
        
        print_success "Application deployed via ZIP"
        ;;
    
    git)
        print_info "Configuring local Git deployment..."
        
        # Get deployment URL
        DEPLOY_URL=$(az webapp deployment source config-local-git \
            --name "$APP_NAME" \
            --resource-group "$RESOURCE_GROUP" \
            --query url -o tsv)
        
        # Remove existing azure remote if present
        git remote remove azure 2>/dev/null || true
        
        # Add azure remote
        git remote add azure "$DEPLOY_URL"
        
        print_info "Pushing code to Azure (this may take several minutes)..."
        echo ""
        
        # Get current branch
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        
        # Push to Azure
        git push azure "${CURRENT_BRANCH}:master" --force
        
        if [[ $? -ne 0 ]]; then
            print_error "Failed to deploy via Git"
            echo ""
            echo -e "${YELLOW}You may need to set deployment credentials:${NC}"
            echo "  az webapp deployment user set --user-name <username> --password <password>"
            exit 1
        fi
        
        print_success "Application deployed via Git"
        ;;
    
    github)
        print_info "Configuring GitHub deployment..."
        print_warning "GitHub deployment requires repository to be pushed to GitHub first"
        
        read -p "Enter your GitHub repository URL (e.g., https://github.com/username/repo): " REPO_URL
        read -p "Enter branch name (default: main): " BRANCH
        BRANCH=${BRANCH:-main}
        
        az webapp deployment source config \
            --name "$APP_NAME" \
            --resource-group "$RESOURCE_GROUP" \
            --repo-url "$REPO_URL" \
            --branch "$BRANCH" \
            --manual-integration \
            --output none
        
        if [[ $? -ne 0 ]]; then
            print_error "Failed to configure GitHub deployment"
            exit 1
        fi
        
        print_success "GitHub deployment configured"
        print_info "Code will be deployed automatically from GitHub"
        ;;
esac

# Get app URL
APP_URL="https://$APP_NAME.azurewebsites.net"

# Wait for deployment to complete
print_step "Waiting for application to start..."
print_info "This may take 30-60 seconds for first deployment..."

sleep 10

# Restart app to ensure changes take effect
print_info "Restarting application..."
az webapp restart --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" --output none

# Success message
print_header "✅ DEPLOYMENT SUCCESSFUL!"

echo -e "${GREEN}Your Church Presentation App is now live!${NC}\n"

echo -e "${CYAN}📱 Application URLs:${NC}"
echo -e "  🏠 Home Page:    $APP_URL/"
echo -e "  🎮 Operator:     $APP_URL/operator.html"
echo -e "  📺 Projector:    $APP_URL/projector.html"
echo ""

echo -e "${CYAN}📊 Management:${NC}"
echo -e "  ${GRAY}• View logs:     az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME${NC}"
echo -e "  ${GRAY}• Restart:       az webapp restart --resource-group $RESOURCE_GROUP --name $APP_NAME${NC}"
echo -e "  ${GRAY}• Stop:          az webapp stop --resource-group $RESOURCE_GROUP --name $APP_NAME${NC}"
echo -e "  ${GRAY}• Start:         az webapp start --resource-group $RESOURCE_GROUP --name $APP_NAME${NC}"
echo ""

echo -e "${YELLOW}💡 Important Notes:${NC}"
if [[ "$TIER" == "free" ]]; then
    echo -e "  ${GRAY}• Free tier may take 30-60 seconds to wake up after inactivity${NC}"
    echo -e "  ${GRAY}• App sleeps after 20 minutes of no requests${NC}"
    echo -e "  ${GRAY}• 60 minutes/day compute time limit${NC}"
fi
echo -e "  ${GRAY}• WebSocket is enabled for real-time sync${NC}"
echo -e "  ${GRAY}• Check application logs if you encounter issues${NC}"
echo ""

echo -e "${CYAN}🚀 Next Steps:${NC}"
echo "  1. Open $APP_URL in your browser"
echo "  2. Test the operator and projector pages"
echo "  3. Upload your songs if needed"
echo ""

if [[ "$TIER" != "free" ]]; then
    echo -e "${YELLOW}💰 Cost Optimization (for paid tiers):${NC}"
    echo -e "  ${GRAY}• Stop when not in use:  ./azure-stop.sh $RESOURCE_GROUP $APP_NAME${NC}"
    echo -e "  ${GRAY}• Start before service:  ./azure-start.sh $RESOURCE_GROUP $APP_NAME${NC}"
    echo ""
fi

echo "======================================================================"
echo ""

# Open browser (if available)
read -p "Would you like to open the app in your browser? (y/n): " open_browser
if [[ "$open_browser" == "y" ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open "$APP_URL" 2>/dev/null || true
    elif command -v open &> /dev/null; then
        open "$APP_URL" 2>/dev/null || true
    else
        print_info "Please open $APP_URL in your browser manually"
    fi
fi

exit 0
