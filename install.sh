#!/bin/bash

# Shared Capital Loan System - VPS Installation Script
# This script automates the installation process

set -e

echo "=========================================="
echo "  Shared Capital Loan System Installer"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Note: Some commands may require sudo privileges${NC}"
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Step 1: Checking system requirements..."
echo "----------------------------------------"

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        echo -e "${GREEN}[OK] Node.js $(node -v) installed${NC}"
    else
        echo -e "${RED}[ERROR] Node.js 18+ required. Current: $(node -v)${NC}"
        echo "Install Node.js 18+ from: https://nodejs.org/"
        exit 1
    fi
else
    echo -e "${RED}[ERROR] Node.js not found${NC}"
    echo "Install Node.js 18+ from: https://nodejs.org/"
    echo "Or run: curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs"
    exit 1
fi

# Check npm
if command_exists npm; then
    echo -e "${GREEN}[OK] npm $(npm -v) installed${NC}"
else
    echo -e "${RED}[ERROR] npm not found${NC}"
    exit 1
fi

# Check PostgreSQL
if command_exists psql; then
    echo -e "${GREEN}[OK] PostgreSQL client installed${NC}"
else
    echo -e "${YELLOW}[WARNING] PostgreSQL client not found (psql)${NC}"
    echo "You'll need PostgreSQL for the database."
fi

echo ""
echo "Step 2: Setting up environment..."
echo "----------------------------------------"

# Check if .env exists
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        echo "Creating .env from .env.example..."
        cp .env.example .env
        echo -e "${YELLOW}[ACTION REQUIRED] Edit .env file with your database credentials${NC}"
    else
        echo -e "${RED}[ERROR] No .env.example found${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}[OK] .env file exists${NC}"
fi

echo ""
echo "Step 3: Installing dependencies..."
echo "----------------------------------------"
npm install

echo ""
echo "Step 4: Building the application..."
echo "----------------------------------------"
npm run build

echo ""
echo "Step 5: Database setup..."
echo "----------------------------------------"

# Check if DATABASE_URL is set
if grep -q "your-super-secret" .env 2>/dev/null || grep -q "username:password" .env 2>/dev/null; then
    echo -e "${YELLOW}[ACTION REQUIRED] Update your .env file with actual database credentials${NC}"
    echo ""
    echo "After updating .env, run these commands:"
    echo "  1. npm run db:push    # Creates database tables"
    echo "  2. npm run start      # Starts the application"
else
    echo "Pushing database schema..."
    npm run db:push
    echo -e "${GREEN}[OK] Database schema created${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Installation Complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Ensure your .env file has correct database credentials"
echo "  2. Run: npm run db:push (if not done)"
echo "  3. Run: npm run start"
echo "  4. Access the app at: http://localhost:5000"
echo ""
echo "For production with PM2:"
echo "  npm install -g pm2"
echo "  pm2 start dist/index.cjs --name shared-capital"
echo "  pm2 save"
echo "  pm2 startup"
echo ""
