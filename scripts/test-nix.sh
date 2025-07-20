#!/bin/bash

echo "🧪 Testing Nix environment..."

# Test basic Nix commands
echo "📦 Testing Nix commands..."
nix --version
nix develop --command echo "Nix develop works"

# Test Python
echo "📦 Testing Python..."
nix develop --command python3 --version
nix develop --command pip --version

# Test Node.js (if installed via official installer)
echo "📦 Testing Node.js..."
if command -v node &> /dev/null; then
    node --version
    npm --version
else
    echo "Node.js not installed - run ./scripts/install-nodejs.sh to install"
fi

# Test DFX installation
echo "📦 Testing DFX installation..."
if command -v dfx &> /dev/null; then
    dfx --version
else
    echo "DFX not installed - will be installed when needed"
fi

echo "✅ Nix environment test completed!" 