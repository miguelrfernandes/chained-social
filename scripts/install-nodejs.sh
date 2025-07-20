#!/bin/bash

echo "📦 Installing Node.js..."

# Check if Node.js is already installed
if command -v node &> /dev/null; then
    echo "✅ Node.js is already installed: $(node --version)"
    echo "✅ npm is available: $(npm --version)"
    exit 0
fi

# Detect OS and install Node.js
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo "🐧 Installing Node.js on Linux..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "🍎 Installing Node.js on macOS..."
    if command -v brew &> /dev/null; then
        brew install node@20
        brew link node@20 --force
    else
        echo "❌ Homebrew not found. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
else
    echo "❌ Unsupported OS: $OSTYPE"
    echo "   Please install Node.js manually from https://nodejs.org/"
    exit 1
fi

# Verify installation
if command -v node &> /dev/null; then
    echo "✅ Node.js installed successfully: $(node --version)"
    echo "✅ npm is available: $(npm --version)"
else
    echo "❌ Node.js installation failed"
    exit 1
fi 