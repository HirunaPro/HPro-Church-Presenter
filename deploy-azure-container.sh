#!/bin/bash
# Deploy Church Presentation App to Azure Container Instances with WebSocket support
# Supports full WebSocket connections for real-time communication

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
RESOURCE_GROUP="church-presenter-rg"
LOCATION="eastus"
SKIP_BUILD=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --app-name)
            APP_NAME="$2"
            shift 2
            ;;
        --resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        --location)
            LOCATION="$2"
            shift 2
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Banner
echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}  Church Presentation App${NC}"
echo -e "${CYAN}  Azure Container Instances Deployment${NC}"
echo -e "${CYAN}  With Full WebSocket Support${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found!${NC}"
    echo ""
    echo -e "${YELLOW}Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Azure CLI installed${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found!${NC}"
    echo ""
    echo -e "${YELLOW}Install Docker from: https://www.docker.com/products/docker-desktop${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker installed${NC}"

if ! docker ps &> /dev/null; then
    echo -e "${RED}❌ Docker is not running!${NC}"
    echo -e "${YELLOW}Please start Docker and try again.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker is running${NC}"

echo ""

# Get app name
if [ -z "$APP_NAME" ]; then
    read -p "Enter your app name (lowercase, alphanumeric, e.g., 'mychurch-app'): " APP_NAME
fi

# Validate and clean app name
APP_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
if [ ${#APP_NAME} -lt 3 ]; then
    echo -e "${RED}❌ App name must be at least 3 characters${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}Configuration:${NC}"
echo "  App Name:       $APP_NAME"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location:       $LOCATION"
echo ""
echo -e "${GREEN}Features:${NC}"
echo "  ✅ Full WebSocket support (ws://)"
echo "  ✅ HTTP + WebSocket on same container"
echo "  ✅ Public IP with DNS name"
echo "  ✅ No quota issues"
echo ""
echo -e "${YELLOW}Pricing (Pay-per-second):${NC}"
echo "  1 vCPU + 1.5 GB RAM: ~\$0.0000133/second"
echo "  3-hour service:        ~\$0.14"
echo "  Weekly (Sun only):     ~\$0.57/month"
echo "  Weekly (Sun + Wed):    ~\$1.14/month"
echo -e "${GREEN}  💡 Stop when not in use to save money!${NC}"
echo ""

read -p "Continue with deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}Starting deployment...${NC}"
echo ""

# Step 1: Azure Login
echo -e "${CYAN}[1/8] Checking Azure login...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Logging in to Azure...${NC}"
    az login
fi
ACCOUNT_NAME=$(az account show --query user.name -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
echo -e "${GREEN}✅ Logged in as: $ACCOUNT_NAME${NC}"
echo -e "   Subscription: $SUBSCRIPTION_NAME"
echo ""

# Step 2: Create Resource Group
echo -e "${CYAN}[2/8] Creating resource group...${NC}"
if az group exists --name "$RESOURCE_GROUP" | grep -q "false"; then
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
    echo -e "${GREEN}✅ Resource group created${NC}"
else
    echo -e "${GREEN}✅ Resource group already exists${NC}"
fi
echo ""

# Step 3: Create Container Registry
echo -e "${CYAN}[3/8] Creating Azure Container Registry...${NC}"
ACR_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9]//g' | cut -c1-50)

if ! az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    az acr create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$ACR_NAME" \
        --sku Basic \
        --admin-enabled true \
        --output none
    echo -e "${GREEN}✅ Container Registry created: $ACR_NAME${NC}"
else
    echo -e "${GREEN}✅ Container Registry already exists: $ACR_NAME${NC}"
fi
echo ""

# Step 4: Get ACR credentials
echo -e "${CYAN}[4/8] Getting registry credentials...${NC}"
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)
echo -e "${GREEN}✅ Credentials retrieved${NC}"
echo ""

# Step 5: Build Docker image
if [ "$SKIP_BUILD" = false ]; then
    echo -e "${CYAN}[5/8] Building Docker image...${NC}"
    echo "   This may take a few minutes on first build..."
    
    docker build -t "${APP_NAME}:latest" .
    
    echo -e "${GREEN}✅ Docker image built${NC}"
else
    echo -e "${YELLOW}[5/8] Skipping Docker build (using existing image)${NC}"
fi
echo ""

# Step 6: Login to ACR and push image
echo -e "${CYAN}[6/8] Pushing image to Azure Container Registry...${NC}"
az acr login --name "$ACR_NAME" --output none

IMAGE_TAG="${ACR_LOGIN_SERVER}/${APP_NAME}:latest"
docker tag "${APP_NAME}:latest" "$IMAGE_TAG"
docker push "$IMAGE_TAG"

echo -e "${GREEN}✅ Image pushed to registry${NC}"
echo ""

# Step 7: Delete existing container if it exists
echo -e "${CYAN}[7/8] Checking for existing container...${NC}"
if az container show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo "   Deleting existing container..."
    az container delete --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --yes --output none
    echo -e "${GREEN}✅ Existing container deleted${NC}"
    echo "   Waiting for resources to be freed..."
    sleep 10
else
    echo -e "${GREEN}✅ No existing container found${NC}"
fi
echo ""

# Step 8: Create Container Instance with WebSocket support
echo -e "${CYAN}[8/8] Creating Azure Container Instance...${NC}"
echo "   Configuring HTTP (8080) and WebSocket (8765) ports..."

az container create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --image "$IMAGE_TAG" \
    --os-type Linux \
    --registry-login-server "$ACR_LOGIN_SERVER" \
    --registry-username "$ACR_USERNAME" \
    --registry-password "$ACR_PASSWORD" \
    --dns-name-label "$APP_NAME" \
    --ports 8080 8765 \
    --protocol TCP \
    --cpu 1 \
    --memory 1.5 \
    --environment-variables \
        PORT=8080 \
        HTTP_PORT=8080 \
        WEBSOCKET_PORT=8765 \
    --output none

echo -e "${GREEN}✅ Container instance created${NC}"
echo ""

# Get container FQDN
echo -e "${CYAN}Getting container details...${NC}"
FQDN=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --query ipAddress.fqdn -o tsv)

PUBLIC_IP=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --query ipAddress.ip -o tsv)

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  ✅ DEPLOYMENT SUCCESSFUL!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo -e "${CYAN}Your application is running at:${NC}"
echo ""
echo "  🌐 HTTP:  http://${FQDN}:8080"
echo "  🔌 WebSocket: ws://${FQDN}:8765"
echo "  📍 Public IP: $PUBLIC_IP"
echo ""
echo -e "${CYAN}Application URLs:${NC}"
echo "  🏠 Landing:   http://${FQDN}:8080/index.html"
echo "  🎮 Operator:  http://${FQDN}:8080/operator.html"
echo "  📺 Projector: http://${FQDN}:8080/projector.html"
echo ""
echo -e "${YELLOW}Management Commands:${NC}"
echo ""
echo -e "${RED}  Stop container (save money):${NC}"
echo "    az container stop --resource-group $RESOURCE_GROUP --name $APP_NAME"
echo ""
echo -e "${GREEN}  Start container:${NC}"
echo "    az container start --resource-group $RESOURCE_GROUP --name $APP_NAME"
echo ""
echo -e "${CYAN}  View logs:${NC}"
echo "    az container logs --resource-group $RESOURCE_GROUP --name $APP_NAME --follow"
echo ""
echo -e "${CYAN}  Check status:${NC}"
echo "    az container show --resource-group $RESOURCE_GROUP --name $APP_NAME --query instanceView.state -o tsv"
echo ""
echo -e "${RED}  Delete container:${NC}"
echo "    az container delete --resource-group $RESOURCE_GROUP --name $APP_NAME --yes"
echo ""
echo -e "${YELLOW}Cost Optimization:${NC}"
echo "  💰 Current pricing: ~\$0.0000133/second when running"
echo -e "${GREEN}  💡 Stop when not in use to avoid charges!${NC}"
echo "  📊 Monthly cost (3hr/week): ~\$0.57/month"
echo ""
echo -e "${CYAN}==========================================${NC}"
echo ""

# Create helper scripts
echo -e "${CYAN}Creating helper scripts...${NC}"

# Start script
cat > start-container.sh << EOF
#!/bin/bash
# Start the Azure Container Instance

echo -e "\033[0;32mStarting container: $APP_NAME\033[0m"
az container start --resource-group $RESOURCE_GROUP --name $APP_NAME

echo ""
echo -e "\033[0;32m✅ Container started!\033[0m"
echo ""
echo -e "\033[0;36mApplication URLs:\033[0m"
echo "  http://${FQDN}:8080/index.html"
echo "  http://${FQDN}:8080/operator.html"
echo "  http://${FQDN}:8080/projector.html"
echo ""
EOF

# Stop script
cat > stop-container.sh << EOF
#!/bin/bash
# Stop the Azure Container Instance to save money

echo -e "\033[1;33mStopping container: $APP_NAME\033[0m"
az container stop --resource-group $RESOURCE_GROUP --name $APP_NAME

echo ""
echo -e "\033[0;32m✅ Container stopped!\033[0m"
echo -e "\033[0;32m💰 You are no longer being charged for this container.\033[0m"
echo ""
EOF

# Logs script
cat > view-logs.sh << EOF
#!/bin/bash
# View container logs

echo -e "\033[0;36mFetching logs for: $APP_NAME\033[0m"
echo "Press Ctrl+C to exit"
echo ""
az container logs --resource-group $RESOURCE_GROUP --name $APP_NAME --follow
EOF

# Status script
cat > check-status.sh << EOF
#!/bin/bash
# Check container status

echo -e "\033[0;36mChecking status for: $APP_NAME\033[0m"
echo ""

STATUS=\$(az container show --resource-group $RESOURCE_GROUP --name $APP_NAME --query instanceView.state -o tsv)
IP=\$(az container show --resource-group $RESOURCE_GROUP --name $APP_NAME --query ipAddress.ip -o tsv)

if [ "\$STATUS" = "Running" ]; then
    echo -e "Status: \033[0;32m\$STATUS\033[0m"
else
    echo -e "Status: \033[1;33m\$STATUS\033[0m"
fi
echo "IP: \$IP"
echo "URL: http://${FQDN}:8080"
echo ""
EOF

# Make scripts executable
chmod +x start-container.sh stop-container.sh view-logs.sh check-status.sh

echo -e "${GREEN}✅ Helper scripts created:${NC}"
echo "   - start-container.sh"
echo "   - stop-container.sh"
echo "   - view-logs.sh"
echo "   - check-status.sh"
echo ""

echo -e "${GREEN}Deployment complete! 🎉${NC}"
echo ""
