# 🚀 Justfile for Chained Social ICP Project

# 📦 Install frontend dependencies
install-frontend:
    cd frontend && npm install

# 🛠️ Build frontend assets
build-frontend:
    cd frontend && npm run build

# 🔄 Regenerate type declarations
generate:
    dfx generate

# 🚢 Deploy all canisters (backend & frontend)
deploy-canisters:
    just generate
    dfx start --background
    dfx deploy

# 🧹 Clean deploy all canisters
deploy-canisters-clean:
    just generate
    dfx stop
    dfx start --background --clean
    dfx deploy

# 🌟 Full deploy: install, build, and deploy everything
deploy:
    just install-frontend
    just build-frontend
    just deploy-canisters-clean

# Start dfx on background
start-dfx:
    dfx start --background

start-dfx-clean:
    dfx stop
    dfx start --background --clean
    dfx identity use m

# 🌍 Deploy to Internet Computer Playground
deploy-playground:
    # Stop local dfx and deploy to IC
    dfx stop
    dfx deploy --network ic
    # Show canister IDs and URLs
    @echo "🌍 Deployed to Internet Computer Playground!"
    @echo "Frontend: https://$(dfx canister id frontend --network ic).ic0.app"
    @echo "Backend: $(dfx canister id backend --network ic)"
    @echo "Content: $(dfx canister id content --network ic)"

# 🎮 Deploy to IC Playground (easier setup)
deploy-playground-easy:
    # Stop local dfx and deploy to playground
    dfx stop
    dfx deploy --playground
    # Show canister IDs and URLs
    @echo "🎮 Deployed to IC Playground!"
    @echo "Frontend: https://$(dfx canister id frontend --playground).ic0.app"
    @echo "Backend: $(dfx canister id backend --playground)"
    @echo "Content: $(dfx canister id content --playground)"

# 🎮 Deploy backend & content to IC Playground (frontend not allowlisted)
deploy-playground-backend:
    # Stop local dfx and deploy backend & content to playground
    dfx stop
    dfx deploy backend --playground
    dfx deploy content --playground
    # Show canister IDs
    @echo "🎮 Deployed backend & content to IC Playground!"
    @echo "Backend: $(dfx canister id backend --playground)"
    @echo "Content: $(dfx canister id content --playground)"
    @echo "Note: Frontend not deployed (not allowlisted in playground)"

# 💰 Check cycles balance
check-balance:
    @echo "💰 Checking cycles balance..."
    dfx wallet --network ic balance

# 💰 Check playground balance
check-balance-playground:
    @echo "💰 Checking playground balance..."
    dfx wallet --playground balance

# 🔧 Setup wallet for playground
setup-wallet-playground:
    @echo "🔧 Setting up wallet for playground..."
    dfx identity get-principal
    @echo "Now run: dfx identity deploy-wallet <CANISTER_ID> --playground"
    @echo "Or try: dfx deploy --playground (this will auto-setup wallet)"

# 🔄 Convert ICP to cycles
convert-cycles:
    @echo "🔄 Converting ICP to cycles..."
    @echo "Usage: dfx cycles convert --amount=0.123 --network ic"
    @echo "Example: dfx cycles convert --amount=0.5 --network ic"