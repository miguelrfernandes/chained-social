# 🚀 Justfile for Chained Social ICP Project

# 📦 Install frontend dependencies
install-frontend:
    cd frontend && npm install

# 🛠️ Build frontend assets
build-frontend:
    cd frontend && npm run build

# 🚢 Deploy all canisters (backend & frontend)
deploy-canisters:
    dfx deploy

# 🌟 Full deploy: install, build, and deploy everything
deploy:
    just install-frontend
    just build-frontend
    just deploy-canisters

# Start dfx on background
start-dfx:
    dfx start --background