# 🚀 Justfile for Chained Social ICP Project

# 🛠️ Setup: Complete project initialization and first-time setup
setup:
    @echo "🚀 Setting up Chained Social project..."
    @echo "📦 Installing frontend dependencies..."
    just install-frontend
    @echo "🚀 Starting dfx and deploying canisters..."
    just deploy-canisters-clean
    @echo "🔄 Generating type declarations..."
    just generate
    @echo "🏗️ Building frontend assets..."
    just build-frontend
    @echo "✅ Setup complete! Your project is ready."
    @echo "🌐 Frontend: http://localhost:4943"
    @echo "📚 Backend API: http://127.0.0.1:4943/?canisterId=umunu-kh777-77774-qaaca-cai&id=uxrrr-q7777-77774-qaaaq-cai"

# 🛠️ Setup: Development environment only (no deployment)
setup-dev:
    @echo "🛠️ Setting up development environment..."
    @echo "📦 Installing frontend dependencies..."
    just install-frontend
    @echo "🚀 Starting dfx in background..."
    just start-dfx
    @echo "🔄 Generating type declarations..."
    just generate
    @echo "🏗️ Building frontend assets..."
    just build-frontend
    @echo "✅ Development setup complete!"
    @echo "💡 Run 'just deploy' to deploy your canisters"

# 📦 Install frontend dependencies
install-frontend:
    cd frontend && npm install

# 🛠️ Build frontend assets
build-frontend:
    @echo "🏗️ Building frontend assets..."
    cd frontend && npm run build

# 🛠️ Build frontend assets (without type declarations)
build-frontend-no-types:
    @echo "🏗️ Building frontend assets (without type declarations)..."
    cd frontend && npm run build -- --mode development

# 🏗️ Build: Build frontend and generate types
build:
    just build-frontend
    just generate

# 🔄 Regenerate type declarations
generate:
    @echo "🔄 Generating type declarations..."
    dfx generate || @echo "⚠️ Type generation failed - canisters may not be deployed yet"

# 🚢 Deploy all canisters (backend & frontend)
deploy-canisters:
    dfx start --background
    dfx deploy
    just generate

# 🧹 Clean deploy all canisters
deploy-canisters-clean:
    dfx stop
    dfx start --background --clean
    dfx deploy
    just generate

# 🌟 Full deploy: install, build, and deploy everything
deploy:
    just start-dfx | echo "dfx already running"
    just install-frontend
    just deploy-canisters-clean
    just generate
    just build-frontend

# Start dfx on background
start-dfx:
    dfx start --background

start-dfx-clean:
    dfx stop
    dfx start --background --clean
    dfx identity use m

# Deploy to playground
deploy-playground:
    dfx stop
    dfx deploy backend --playground
    dfx deploy content --playground
    @echo "Backend: $(dfx canister id backend --playground)"
    @echo "Content: $(dfx canister id content --playground)"

# Deploy to mainnet
deploy-mainnet:
    dfx stop
    export DFX_WARNING=-mainnet_plaintext_identity
    dfx deploy --network ic
    @echo "Frontend: https://$(dfx canister id frontend --network ic).ic0.app"
    @echo "Backend: $(dfx canister id backend --network ic)"
    @echo "Content: $(dfx canister id content --network ic)"

# Check balance
check-balance:
    dfx wallet --network ic balance

# 🚀 Start development server
dev:
    @echo "🚀 Starting development server..."
    cd frontend && npm run dev

# Convert ICP to cycles
convert-cycles:
    dfx cycles convert --amount=0.5 --network ic

# 🔧 Reset: Clean everything and start fresh
reset:
    @echo "🧹 Cleaning everything..."
    dfx stop
    rm -rf .dfx
    rm -rf frontend/dist
    rm -rf src/declarations
    @echo "✅ Clean complete. Run 'just setup' to start fresh."

# 🔍 Status: Check project status
status:
    @echo "📊 Project Status:"
    @echo "DFX Status:"
    dfx ping
    @echo ""
    @echo "Canister IDs:"
    @echo "Backend: $(dfx canister id backend 2>/dev/null || echo 'Not deployed')"
    @echo "Content: $(dfx canister id content 2>/dev/null || echo 'Not deployed')"
    @echo "Frontend: $(dfx canister id frontend 2>/dev/null || echo 'Not deployed')"
    @echo ""
    @echo "Network: $(dfx info identity 2>/dev/null || echo 'Not configured')"

# 🐳 DevContainer: Setup optimized for devcontainer environment
setup-devcontainer:
    @echo "🐳 Setting up Chained Social in devcontainer..."
    @echo "📦 Installing frontend dependencies..."
    just install-frontend
    @echo "🚀 Starting dfx and deploying canisters..."
    dfx stop || true
    dfx start --background --clean
    dfx deploy
    @echo "🔄 Generating type declarations..."
    dfx generate
    @echo "🏗️ Building frontend assets..."
    just build-frontend
    @echo "✅ DevContainer setup complete!"
    @echo "🌐 Frontend: http://localhost:4943"

# 🆘 Help: Show available commands
help:
    @echo "🚀 Chained Social - Available Commands:"
    @echo ""
    @echo "📋 Setup Commands:"
    @echo "  just setup        - Complete project setup and deployment"
    @echo "  just setup-dev    - Development environment setup only"
    @echo "  just setup-devcontainer - DevContainer optimized setup"
    @echo "  just reset        - Clean everything and start fresh"
    @echo ""
    @echo "🛠️ Development Commands:"
    @echo "  just deploy       - Full deployment (install, build, deploy)"
    @echo "  just build        - Build frontend and generate types"
    @echo "  just dev          - Start development server"
    @echo ""
    @echo "🚀 Deployment Commands:"
    @echo "  just deploy-mainnet - Deploy to mainnet"
    @echo "  just deploy-playground - Deploy to playground"
    @echo ""
    @echo "📊 Utility Commands:"
    @echo "  just status       - Check project status"
    @echo "  just check-balance - Check wallet balance"
    @echo "  just convert-cycles - Convert ICP to cycles"
    @echo ""
    @echo "💡 Run 'just help' to see this message again"