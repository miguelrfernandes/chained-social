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

# Install Node.js (if needed)
./scripts/install-nodejs.sh

# Install DFX (if needed)
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
```

### CI/CD Pipeline
The Nix CI workflow (`ci-nix.yml`) automatically:
- ✅ **Installs Nix** with DeterminateSystems installer
- ✅ **Enables flakes** for modern Nix features
- ✅ **Caches Nix store** for faster builds
- ✅ **Installs Node.js** using official installer
- ✅ **Installs DFX** using official DFinity GitHub Action
- ✅ **Runs all tests** in reproducible environment
- ✅ **Deploys to playground** for preview

## 🔧 Configuration

### `flake.nix`
Defines the development environment with:
- **Python 3.11** - Backend utilities
- **Development tools** - Git, curl, build tools
- **Node.js installation** - Via official installer to avoid compilation issues
- **DFX installation** - Via official DFinity GitHub Action

### CI Workflow Features
- **Multi-stage pipeline** - Test → Build → Deploy
- **Nix caching** - Faster subsequent runs
- **Official installers** - Node.js and DFX via official installers
- **Playground deployment** - Automatic preview for PRs
- **Integration testing** - Inter-canister communication

## 📋 Usage

### Local Development
```bash
# Enter development shell
nix develop

# Install Node.js (if needed)
./scripts/install-nodejs.sh

# Install DFX (if needed)
./scripts/install-dfx.sh

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

### Testing Nix Environment
```bash
# Run the test script
./scripts/test-nix.sh
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

### Node.js Issues
```bash
# Install Node.js using official installer
./scripts/install-nodejs.sh

# Or manually install
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Cache Issues

#### Common Cache Problems
1. **Cache Miss on First Run**: Normal behavior - cache will be created
2. **Cache Key Changes**: Happens when `flake.lock` is updated
3. **Cache Size Limits**: GitHub Actions has cache size limits

#### Debugging Cache Issues
```bash
# Check cache key generation
echo "Cache key: nix-store-$(uname -s)-$(sha256sum flake.lock | cut -d' ' -f1)"

# Check Nix store size
du -sh /nix/store

# List cached packages
ls /nix/store | head -20
```

#### Cache Optimization Strategies
1. **Use `save-always: true`**: Ensures cache is updated even on failures
2. **Multiple restore-keys**: Provides fallback cache options
3. **Separate config cache**: Caches Nix configuration separately
4. **Cache warming**: Pre-builds common dependencies

#### Cache Performance Tips
- **First run**: ~5-10 minutes (downloads)
- **Subsequent runs**: ~2-3 minutes (cached)
- **Cache hit rate**: Should be >80% after first run
- **Cache size**: Monitor for GitHub Actions limits

### DFX Issues
```bash
# Install DFX using official installer
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

# Check DFX installation
dfx --version

# Reset DFX environment
dfx start --clean --background
```

### Recent Fixes
- ✅ **Fixed Node.js compilation issues** - Now uses official installer
- ✅ **Fixed DFX installation issues** - Now uses official DFinity GitHub Action
- ✅ **Simplified flake.nix** - Removed problematic packages
- ✅ **Improved cache strategy** - Better fallback keys
- ✅ **Added cache debugging** - Better visibility into cache behavior 