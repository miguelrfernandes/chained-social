# 🚀 Justfile for Chained Social ICP Project

# 🚀 Setup: Initial project setup (install dependencies, build, deploy)
setup:
    @echo "🚀 Setting up ChainedSocial project..."
    @echo "📦 Installing Node.js..."
    ./scripts/install-nodejs.sh
    @echo "📦 Installing DFX..."
    ./scripts/install-dfx.sh
    @echo "📦 Installing frontend dependencies..."
    cd frontend && npm install
    @echo "🏗️ Building frontend assets..."
    cd frontend && npm run build
    @echo "🚀 Starting dfx and deploying canisters..."
    dfx stop || true
    dfx start --background --clean
    dfx deploy
    @echo "🔄 Generating type declarations..."
    dfx generate
    @echo "✅ Setup complete! Your project is ready."
    just urls

# 🚀 Deploy: Full deployment (install, build, deploy)
deploy:
    @echo "🚀 Full deployment..."
    dfx stop || true
    dfx start --background --clean
    cd frontend && npm install
    dfx deploy
    dfx generate
    cd frontend && npm run build
    just urls

# 🧪 Run unit tests
test:
    @echo "🧪 Running unit tests..."
    ./scripts/run-tests.sh

# 🚀 Deploy to playground
deploy-playground:
    dfx deploy --playground

# 🛠️ Build: Build frontend and generate types
build:
    @echo "🏗️ Building frontend and generating types..."
    cd frontend && npm run build
    dfx generate

# 🚀 Start development server
dev:
    @echo "🚀 Starting development server..."
    cd frontend && npm run dev

# 🔧 Reset: Clean everything and start fresh
reset:
    @echo "🧹 Cleaning everything..."
    dfx stop
    rm -rf .dfx frontend/dist src/declarations
    @echo "✅ Clean complete. Run 'just setup' to start fresh."

# 🔍 Status: Check project status
status:
    @echo "📊 Project Status:"
    dfx ping
    @echo ""
    @echo "Canister IDs:"
    @echo "Backend: $(dfx canister id backend 2>/dev/null || echo 'Not deployed')"
    @echo "Content: $(dfx canister id content 2>/dev/null || echo 'Not deployed')"
    @echo "SocialGraph: $(dfx canister id socialgraph 2>/dev/null || echo 'Not deployed')"
    @echo "Frontend: $(dfx canister id frontend 2>/dev/null || echo 'Not deployed')"

# 🌐 URLs: Show current canister URLs
urls:
    chmod +x scripts/urls.sh
    ./scripts/urls.sh

# 🔧 Troubleshoot: Check deployment and connectivity
troubleshoot:
    @echo "🔧 Troubleshooting deployment issues..."
    @echo ""
    @echo "📊 Current Status:"
    dfx ping
    @echo ""
    @echo "🏗️ Canister Status:"
    dfx canister status backend 2>/dev/null || echo "Backend: Not deployed"
    dfx canister status content 2>/dev/null || echo "Content: Not deployed"
    dfx canister status socialgraph 2>/dev/null || echo "SocialGraph: Not deployed"
    dfx canister status frontend 2>/dev/null || echo "Frontend: Not deployed"
    @echo ""
    @echo "🌐 Current URLs:"
    just urls
    @echo ""
    @echo "💡 If canisters show 'Not deployed', run:"
    @echo "  just setup"
    @echo ""
    @echo "💡 If URLs show 'not-deployed', run:"
    @echo "  just deploy"

# 🚀 Codespaces: Setup and troubleshooting
codespaces:
    @echo "🚀 Codespaces Setup & Troubleshooting:"
    @echo ""
    @echo "📋 Port Forwarding:"
    @echo "  - Add port 4943 (dfx replica) to Ports tab"
    @echo "  - Set visibility to 'Public'"
    @echo ""
    @echo "🌐 Environment Check:"
    @echo "CODESPACES: ${CODESPACES:-'Not set'}"
    @echo "CODESPACE_NAME: ${CODESPACE_NAME:-'Not set'}"
    @echo ""
    @echo "🔗 Working Frontend URL:"
    @echo "https://your-codespace-4943.github.dev/?canisterId=$(dfx canister id frontend 2>/dev/null || echo 'FRONTEND_ID')"
    @echo ""
    @echo "💡 If frontend doesn't work:"
    @echo "1. Check Ports tab in VS Code"
    @echo "2. Click 'Open in Browser' for port 4943"
    @echo "3. Or run: just deploy"

# 🚀 Deploy to mainnet
mainnet:
    @echo "🚀 Deploying to mainnet..."
    dfx stop
    export DFX_WARNING=-mainnet_plaintext_identity
    dfx deploy --network ic
    @echo "Frontend: https://$(dfx canister id frontend --network ic).ic0.app"
    @echo "Backend: $(dfx canister id backend --network ic)"
    @echo "Content: $(dfx canister id content --network ic)"
    @echo "SocialGraph: $(dfx canister id socialgraph --network ic)"

# 💰 Wallet commands
balance:
    dfx wallet --network ic balance

cycles:
    dfx cycles convert --amount=0.5 --network ic

# 🆘 Help: Show available commands
help:
    @echo "🚀 Chained Social - Available Commands:"
    @echo ""
    @echo "📋 Core Commands:"
    @echo "  just setup        - Complete project setup and deployment"
    @echo "  just deploy       - Full deployment (install, build, deploy)"
    @echo "  just build        - Build frontend and generate types"
    @echo "  just dev          - Start development server"
    @echo "  just reset        - Clean everything and start fresh"
    @echo ""
    @echo "📊 Utility Commands:"
    @echo "  just status       - Check project status"
    @echo "  just urls         - Show current canister URLs"
    @echo "  just troubleshoot - Troubleshoot deployment issues"
    @echo "  just codespaces   - Codespaces setup and troubleshooting"
    @echo ""
    @echo "🚀 Deployment Commands:"
    @echo "  just mainnet      - Deploy to mainnet"
    @echo "  just balance      - Check wallet balance"
    @echo "  just cycles       - Convert ICP to cycles"
    @echo ""
    @echo "💡 Run 'just help' to see this message again"