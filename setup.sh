#!/bin/bash

# Inception Project Setup Script
# This script sets up the Inception project environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

print_status "Starting Inception project setup..."

# Check required commands
command -v docker >/dev/null 2>&1 || { print_error "Docker is required but not installed. Aborting."; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { print_error "Docker Compose is required but not installed. Aborting."; exit 1; }

print_success "Docker and Docker Compose are installed"

# Get current user
CURRENT_USER=$(whoami)
print_status "Current user: $CURRENT_USER"

# Update .env file with current user
if [ -f "srcs/.env" ]; then
    # Replace serferna with current username in .env file
    sed -i "s/serferna\.42\.fr/$CURRENT_USER.42.fr/g" srcs/.env
    print_success "Updated domain name to $CURRENT_USER.42.fr"
else
    print_error ".env file not found in srcs/ directory"
    exit 1
fi

# Create data directories
DATA_DIR="/home/$CURRENT_USER/data"
print_status "Creating data directories in $DATA_DIR"

sudo mkdir -p "$DATA_DIR/wordpress"
sudo mkdir -p "$DATA_DIR/mariadb"
sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$DATA_DIR"

print_success "Data directories created and configured"

# Update /etc/hosts file
HOSTS_ENTRY="127.0.0.1 $CURRENT_USER.42.fr"

if ! grep -q "$CURRENT_USER.42.fr" /etc/hosts; then
    print_status "Adding entry to /etc/hosts file"
    echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts
    print_success "Added $CURRENT_USER.42.fr to /etc/hosts"
else
    print_warning "$CURRENT_USER.42.fr already exists in /etc/hosts"
fi

# Validate .env file exists
if [ ! -f "srcs/.env" ]; then
    print_error ".env file not found in srcs/ directory"
    exit 1
fi

print_success "Environment configuration file found"

# Check Docker daemon
if ! docker info >/dev/null 2>&1; then
    print_error "Docker daemon is not running. Please start Docker first."
    exit 1
fi

print_success "Docker daemon is running"

# Create .dockerignore files for all services
SERVICES=("nginx" "wordpress" "mariadb")

for service in "${SERVICES[@]}"; do
    SERVICE_DIR="srcs/requirements/$service"
    if [ -d "$SERVICE_DIR" ] && [ ! -f "$SERVICE_DIR/.dockerignore" ]; then
        cat > "$SERVICE_DIR/.dockerignore" << EOF
*.log
*.tmp
.git
.gitignore
README.md
Dockerfile
.dockerignore
EOF
        print_status "Created .dockerignore for $service"
    fi
done

print_success "Setup completed successfully!"
print_status "You can now run 'make' to build and start the infrastructure"

echo -e "\n${GREEN}=== Inception Project Setup Summary ===${NC}"
echo -e "Domain: ${YELLOW}https://$CURRENT_USER.42.fr${NC}"
echo -e "Data Directory: ${YELLOW}$DATA_DIR${NC}"
echo -e "\n${BLUE}Services included (mandatory part only):${NC}"
echo -e "- ${YELLOW}NGINX${NC}: Reverse proxy with SSL/TLS (port 443)"
echo -e "- ${YELLOW}WordPress${NC}: PHP-FPM application server"
echo -e "- ${YELLOW}MariaDB${NC}: Database server"
echo -e "\n${BLUE}Next steps:${NC}"
echo -e "1. Run ${YELLOW}'make'${NC} to build and start all services"
echo -e "2. Run ${YELLOW}'make logs'${NC} to view service logs"
echo -e "3. Run ${YELLOW}'make help'${NC} to see all available commands"
echo -e "\n${GREEN}Note:${NC} This is the mandatory part only. No bonus services included."
echo -e "\n${BLUE}Access your site at:${NC} ${YELLOW}https://$CURRENT_USER.42.fr${NC}"
