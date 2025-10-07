#!/bin/bash

# Backend Dependencies Installation Script

set -e

print_status() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

print_status "Installing backend dependencies..."

cd "$(dirname "$0")/services/backend"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 16+ first."
    exit 1
fi

# Check if npm is installed  
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install npm first."
    exit 1
fi

print_status "Node.js version: $(node --version)"
print_status "npm version: $(npm --version)"

# Clean any existing node_modules and package-lock.json
if [ -d "node_modules" ]; then
    print_status "Cleaning existing node_modules..."
    rm -rf node_modules
fi

if [ -f "package-lock.json" ]; then
    print_status "Cleaning existing package-lock.json..."
    rm -f package-lock.json
fi

# Install dependencies
print_status "Installing dependencies with npm..."
npm install

# Create logs directory
mkdir -p logs

# Verify installation
if [ -d "node_modules" ]; then
    print_success "Backend dependencies installed successfully!"
    
    # Check if key packages are installed
    if [ -d "node_modules/express" ]; then
        print_success "Express installed: $(npm list express --depth=0 2>/dev/null | grep express || echo 'version check failed')"
    fi
    
    if [ -d "node_modules/mongoose" ]; then
        print_success "Mongoose installed: $(npm list mongoose --depth=0 2>/dev/null | grep mongoose || echo 'version check failed')"
    fi
else
    print_error "Installation failed - node_modules directory not created"
    exit 1
fi

print_success "Backend setup completed successfully!"
print_status "You can now run: npm start"