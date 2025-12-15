#!/bin/bash

# Shared Capital Loan System - Start Script

set -e

echo "Starting Shared Capital Loan System..."

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check if dist exists
if [ ! -d "dist" ]; then
    echo "Building application..."
    npm run build
fi

# Start the application
echo "Server starting on port ${PORT:-5000}..."
npm run start
