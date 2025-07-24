# 🚀 Justfile for Chained Social ICP Project

# 🧹 Clean: Clean build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    dfx stop || true
    dfx start --background --clean
    dfx stop
    rm -rf .dfx
    rm -rf frontend/dist
    rm -rf src/declarations
    @echo "✅ Clean complete!"

# 🚀 Deploy: Full deployment (install, build, deploy)
deploy:
    @echo "🚀 Setting up ChainedSocial project..."
    @echo "📦 Installing frontend dependencies..."
    cd frontend && npm install
    @echo "🚀 Starting dfx and deploying canisters..."
    dfx start --background || true
    @echo "🔄 Creating canisters..."
    dfx canister create --all
    @echo "🏗️ Building Motoko canisters..."
    dfx build backend
    dfx build content
    dfx build socialgraph
    @echo "🔄 Generating type declarations..."
    dfx generate backend
    dfx generate content
    dfx generate socialgraph
    @echo "🚀 Deploying canisters..."
    dfx deploy
    @echo "🏗️ Building frontend assets..."
    cd frontend && npm run build
    @echo "✅ Setup complete! Your project is ready."
    @echo "🔍 Verifying deployment..."
    dfx canister status --all
    just urls

# 🧪 Run unit tests
test:
    @echo "🧪 Running unit tests..."
    ./scripts/run-tests.sh

# 🚀 Deploy to playground
deploy-playground:
    @echo "🚀 Deploying to playground..."
    dfx deploy --playground
    dfx generate
    cd frontend && npm run build
    @echo "✅ Playground deployment complete!"
    @echo "🔗 URLs:"
    @dfx canister id frontend --network playground 2>/dev/null && echo "   Frontend: https://$$(dfx canister id frontend --network playground).icp0.io/" || echo "   Frontend: Not deployed"
    @dfx canister id backend --network playground 2>/dev/null && echo "   Backend: $$(dfx canister id backend --network playground)" || echo "   Backend: Not deployed"
    @dfx canister id content --network playground 2>/dev/null && echo "   Content: $$(dfx canister id content --network playground)" || echo "   Content: Not deployed"
    @dfx canister id socialgraph --network playground 2>/dev/null && echo "   SocialGraph: $$(dfx canister id socialgraph --network playground)" || echo "   SocialGraph: Not deployed"

# 🔍 Status: Check project status
status:
    @echo "🔍 Checking project status..."
    dfx canister status --all

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

# 🌿 Branch: Create a new feature branch with descriptive name
branch type description:
    @echo "🌿 Creating new feature branch..."
    git checkout main
    git pull origin main
    git checkout -b {{type}}/{{description}}
    @echo "✅ Branch '{{type}}/{{description}}' created!"
    @echo "💡 Next: Make changes, then 'just pr <title>' to create PR"

# 🚀 PR: Create a pull request for current branch
pr title body="":
    @echo "🚀 Creating pull request..."
    git push origin $(git branch --show-current)
    gh pr create --title "{{title}}" --body "{{body}}" --head $(git branch --show-current)
    @echo "✅ PR created! View at: $(gh pr view --json url --jq '.url')"

# 📋 PR-New: Create branch and PR in one command
pr-new type description title body="":
    @echo "📋 Creating branch and PR..."
    git checkout main
    git pull origin main
    git checkout -b {{type}}/{{description}}
    @echo "✅ Branch '{{type}}/{{description}}' created!"
    @echo "💡 Make your changes, then run: just pr '{{title}}' '{{body}}'"

# 🔧 Troubleshoot: Diagnose common issues
troubleshoot:
    @echo "🔧 Troubleshooting Guide:"
    @echo ""
    @echo "1. Check versions:"
    @node --version 2>/dev/null && echo "   ✅ Node.js: $$(node --version)" || echo "   ❌ Node.js not installed - recommended for macos: `brew install fnm && fnm install`, check https://nodejs.org/en/download"
    @dfx --version 2>/dev/null && echo "   ✅ DFX: $$(dfx --version)" || echo "   ❌ DFX not installed - run 'sh -ci \"$(curl -fsSL https://internetcomputer.org/install.sh)\"'"
    @echo ""
    @echo "2. Check if dfx is running:"
    @dfx ping 2>/dev/null && echo "   ✅ dfx is running" || echo "   ❌ dfx is not running - run 'dfx start'"
    @echo ""
    @echo "3. Check canister status:"
    @dfx canister status --all 2>/dev/null || echo "   ❌ Canisters not deployed - run 'dfx deploy'"
    @echo ""
    @echo "4. Check frontend build:"
    @test -f frontend/dist/index.html && echo "   ✅ Frontend built" || echo "   ❌ Frontend not built - run 'cd frontend && npm run build'"
    @echo ""
    @echo "5. Check dependencies:"
    @test -d frontend/node_modules && echo "   ✅ Dependencies installed" || echo "   ❌ Dependencies missing - run 'cd frontend && npm install'"
    @echo ""
    @echo "6. Common solutions:"
    @echo "   - Run 'just clean' to reset everything"
    @echo "   - Run 'just setup' for fresh installation"