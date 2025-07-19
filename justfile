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
    just generate
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

# Convert ICP to cycles
convert-cycles:
    dfx cycles convert --amount=0.5 --network ic