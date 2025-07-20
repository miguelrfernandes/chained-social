#!/bin/bash

echo "📦 Installing DFX..."

# Check if DFX is already installed
if command -v dfx &> /dev/null; then
    echo "✅ DFX is already installed: $(dfx --version)"
    exit 0
fi

# Set up non-interactive installation
export DFXVM_INIT_YES=true

# Install DFX using the official installer
echo "🔧 Installing DFX using official installer..."
sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"

# Add DFX to PATH based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo "🐧 Setting up DFX for Linux..."
    export PATH="$HOME/.local/share/dfx/bin:$PATH"
    source "$HOME/.local/share/dfx/env"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "🍎 Setting up DFX for macOS..."
    export PATH="$HOME/Library/Application Support/org.dfinity.dfx/bin:$PATH"
    source "$HOME/Library/Application Support/org.dfinity.dfx/env"
else
    echo "❌ Unsupported OS: $OSTYPE"
    echo "   Please install DFX manually from https://internetcomputer.org/"
    exit 1
fi

# Verify installation
if command -v dfx &> /dev/null; then
    echo "✅ DFX installed successfully: $(dfx --version)"
else
    echo "❌ DFX installation failed"
    exit 1
fi 