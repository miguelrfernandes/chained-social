# 🚀 Justfile for Chained Social ICP Project

# 🚀 Setup: Initial project setup (install dependencies, build, deploy)
setup:
    @echo "🚀 Setting up ChainedSocial project..."
    @echo "📦 To install Node.js, I recommend using fnm"
    @echo "📦 To install DFX, I recommend using the install script"
    @echo "   Run: sh -ci \"$(curl -fsSL https://internetcomputer.org/install.sh)\""
    @echo "   Or visit: https://internetcomputer.org/docs/current/developer-docs/setup/install/"
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
    @echo "🏗️ Building project..."
    cd frontend && npm install
    cd frontend && npm run build
    dfx generate
    @echo "✅ Build complete!"

# 🔍 Status: Check project status
status:
    @echo "🔍 Checking project status..."
    dfx canister status --all

# 🧹 Clean: Clean build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    dfx stop || true
    rm -rf .dfx
    rm -rf frontend/dist
    rm -rf src/declarations
    @echo "✅ Clean complete!"

# 🔗 URLs: Show current canister URLs
urls:
    @echo "🔗 Current Canister URLs:"
    @echo ""
    @echo "🌐 Frontend:"
    @dfx canister id frontend 2>/dev/null && echo "   https://$$(dfx canister id frontend).icp0.io/" || echo "   Not deployed"
    @echo ""
    @echo "🔧 Backend:"
    @dfx canister id backend 2>/dev/null && echo "   $$(dfx canister id backend)" || echo "   Not deployed"
    @echo ""
    @echo "📝 Content:"
    @dfx canister id content 2>/dev/null && echo "   $$(dfx canister id content)" || echo "   Not deployed"
    @echo ""
    @echo "👥 Social Graph:"
    @dfx canister id socialgraph 2>/dev/null && echo "   $$(dfx canister id socialgraph)" || echo "   Not deployed"
    @echo ""
    @echo "📋 Candid Interfaces:"
    @dfx canister id backend 2>/dev/null && echo "   Backend: https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=$$(dfx canister id backend)" || echo "   Backend: Not deployed"
    @dfx canister id content 2>/dev/null && echo "   Content: https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=$$(dfx canister id content)" || echo "   Content: Not deployed"
    @dfx canister id socialgraph 2>/dev/null && echo "   SocialGraph: https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=$$(dfx canister id socialgraph)" || echo "   SocialGraph: Not deployed"

# 📖 Explain URLs: Understand different URL types
explain-urls:
    @echo "📖 URL Types Explanation:"
    @echo ""
    @echo "🌐 Frontend URL:"
    @echo "   - Used for normal web browsing"
    @echo "   - Contains the React application"
    @echo "   - Example: https://abc123.icp0.io/"
    @echo ""
    @echo "🔧 Canister IDs:"
    @echo "   - Used for direct canister interaction"
    @echo "   - Used in code and API calls"
    @echo "   - Example: abc123-def456-ghi789"
    @echo ""
    @echo "📋 Candid URLs:"
    @echo "   - Used for testing canister functions"
    @echo "   - Web interface for canister APIs"
    @echo "   - Example: https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=abc123"
    @echo ""
    @echo "💡 Usage:"
    @echo "   - Frontend URL: Share with users"
    @echo "   - Canister IDs: Use in development"
    @echo "   - Candid URLs: Test canister functions"

# 🔧 Troubleshoot: Diagnose common issues
troubleshoot:
    @echo "🔧 Troubleshooting Guide:"
    @echo ""
    @echo "1. Check if dfx is running:"
    @dfx ping 2>/dev/null && echo "   ✅ dfx is running" || echo "   ❌ dfx is not running - run 'dfx start'"
    @echo ""
    @echo "2. Check canister status:"
    @dfx canister status --all 2>/dev/null || echo "   ❌ Canisters not deployed - run 'dfx deploy'"
    @echo ""
    @echo "3. Check frontend build:"
    @test -f frontend/dist/index.html && echo "   ✅ Frontend built" || echo "   ❌ Frontend not built - run 'cd frontend && npm run build'"
    @echo ""
    @echo "4. Check dependencies:"
    @test -d frontend/node_modules && echo "   ✅ Dependencies installed" || echo "   ❌ Dependencies missing - run 'cd frontend && npm install'"
    @echo ""
    @echo "5. Common solutions:"
    @echo "   - Run 'just clean' to reset everything"
    @echo "   - Run 'just setup' for fresh installation"
    @echo "   - Check dfx version: dfx --version"