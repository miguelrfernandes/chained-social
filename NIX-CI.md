# Nix CI Setup for ChainedSocial

This project uses Nix for reproducible CI/CD, following the same approach as the [DFinity Motoko repository](https://github.com/dfinity/motoko/pull/5067/). Nix provides better reproducibility, caching, and reliability than Docker for ICP development.

## 🐧 Why Nix?

### Benefits over Docker:
- ✅ **Reproducible builds** - Exact same environment every time
- ✅ **Better caching** - Nix store caching is more efficient
- ✅ **No image building** - No Docker build failures
- ✅ **Faster setup** - Direct tool installation
- ✅ **ICP ecosystem** - Used by DFinity and Motoko projects

### Based on DFinity's approach:
- 📚 [DFinity Motoko CI](https://github.com/dfinity/motoko/pull/5067/)
- 📚 [Nix CI Documentation](https://nix.dev/tutorials/continuous-integration-github-actions)

## 🚀 Setup

### Local Development
```bash
# Install Nix (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Enter development environment
nix develop

# Or run specific commands
nix develop --command dfx --version
nix develop --command npm install
```

### CI/CD Pipeline
The Nix CI workflow (`ci-nix.yml`) automatically:
- ✅ **Installs Nix** with DeterminateSystems installer
- ✅ **Enables flakes** for modern Nix features
- ✅ **Caches Nix store** for faster builds
- ✅ **Runs all tests** in reproducible environment
- ✅ **Deploys to playground** for preview

## 🔧 Configuration

### `flake.nix`
Defines the development environment with:
- **DFX 0.27.0** - Internet Computer SDK
- **Node.js 18** - Frontend development
- **Python 3.11** - Backend utilities
- **Development tools** - Git, curl, build tools

### CI Workflow Features
- **Multi-stage pipeline** - Test → Build → Deploy
- **Nix caching** - Faster subsequent runs
- **Playground deployment** - Automatic preview for PRs
- **Integration testing** - Inter-canister communication

## 📋 Usage

### Local Development
```bash
# Enter development shell
nix develop

# Run DFX commands
dfx start --clean --background
dfx deploy

# Install frontend dependencies
cd frontend && npm install

# Run tests
npm test
```

### CI Commands
```bash
# Install dependencies
nix develop --command echo "Dependencies installed"

# Run tests
nix develop --command bash -c 'dfx build && dfx test'

# Deploy to playground
nix develop --command bash -c 'dfx deploy --playground'
```

## 🔍 Troubleshooting

### Nix Installation Issues
```bash
# Reinstall Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Cache Issues
```bash
# Clear Nix cache
nix store gc

# Rebuild environment
nix develop --command echo "Rebuilt"
```

### DFX Issues
```bash
# Check DFX installation
nix develop --command dfx --version

# Reset DFX environment
nix develop --command bash -c 'dfx start --clean --background'
```

## 📊 Performance

### Caching Benefits
- **Nix store cache** - Shared across CI runs
- **Dependency cache** - No re-downloading
- **Build cache** - Faster subsequent builds

### Expected Times
- **First run**: ~5-10 minutes (downloads)
- **Subsequent runs**: ~2-3 minutes (cached)
- **Dependency updates**: ~1-2 minutes (incremental)

## 🔄 Migration from Docker

### Benefits of Migration
- ✅ **No Docker build failures** - Direct tool installation
- ✅ **Better caching** - Nix store vs Docker layers
- ✅ **Reproducible** - Exact same environment
- ✅ **ICP ecosystem** - Used by DFinity projects

### Migration Steps
1. **Add `flake.nix`** - Define development environment
2. **Update CI workflow** - Use Nix instead of Docker
3. **Test locally** - `nix develop`
4. **Deploy** - Monitor CI performance

## 📚 References

- [Nix CI Documentation](https://nix.dev/tutorials/continuous-integration-github-actions)
- [DFinity Motoko CI](https://github.com/dfinity/motoko/pull/5067/)
- [DeterminateSystems Nix Installer](https://github.com/DeterminateSystems/nix-installer)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [GitHub Actions Nix](https://github.com/DeterminateSystems/nix-installer-action) 