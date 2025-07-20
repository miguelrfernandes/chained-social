# Docker CI Setup for ChainedSocial

This project uses a custom Docker image for CI/CD to ensure consistent builds and avoid installation issues with DFX and other tools.

## 🐳 Docker CI Image

### Overview
The CI Docker image (`Dockerfile.ci`) pre-installs all necessary tools for ICP development:
- **DFX 0.27.0** - Internet Computer SDK
- **Node.js 18** - Frontend development
- **Python 3.11** - Backend utilities
- **Ubuntu 22.04** - Base operating system

### Benefits
- ✅ **Consistent Environment** - Same tools and versions across all CI runs
- ✅ **Faster Builds** - No installation time during CI
- ✅ **Reliable DFX** - Pre-installed and tested DFX installation
- ✅ **Isolated Environment** - Clean, reproducible builds

## 🚀 Usage

### Local Development
Build the CI image locally for testing:

```bash
# Build the image
./scripts/build-ci-image.sh

# Test the image
docker run -it chainedsocial-ci:latest

# Run with your project mounted
docker run -it -v $(pwd):/workspace chainedsocial-ci:latest
```

### GitHub Actions
The CI workflow automatically uses the Docker image:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/miguelrfernandes/chained-social-ci:latest
      options: --user root
```

## 🔧 Image Details

### Pre-installed Tools
- **DFX 0.27.0** - Internet Computer SDK
- **Node.js 18.x** - JavaScript runtime
- **npm** - Package manager
- **Python 3.11** - Python runtime
- **Git** - Version control
- **curl/wget** - HTTP clients
- **build-essential** - Compilation tools

### User Setup
- Creates `ci-user` for non-root operations
- Proper PATH configuration for all tools
- Sudo access for system operations

## 📋 Build Process

### Automatic Build
The Docker image is automatically built and published when:
- `Dockerfile.ci` is modified
- Changes are pushed to `main` branch
- Manual workflow dispatch

### Manual Build
To manually trigger a build:

1. Go to GitHub Actions
2. Select "Build and Publish CI Docker Image"
3. Click "Run workflow"

## 🔍 Troubleshooting

### Image Not Found
If the CI fails with "image not found":

1. Check if the image exists: `ghcr.io/miguelrfernandes/chained-social-ci:latest`
2. Manually trigger the build workflow
3. Wait for the build to complete

### DFX Issues
If DFX still has problems:

1. Check the Dockerfile.ci for installation steps
2. Verify the PATH configuration
3. Test locally with the Docker image

### Local Testing
To test the CI environment locally:

```bash
# Build the image
docker build -f Dockerfile.ci -t ci-test .

# Run with your project
docker run -it -v $(pwd):/workspace ci-test

# Test DFX
dfx --version
```

## 📝 Configuration

### Environment Variables
The Docker image sets these environment variables:
- `DFX_VERSION=0.27.0`
- `NODE_VERSION=18`
- `PYTHON_VERSION=3.11`

### File Locations
- DFX: `/home/ci-user/.local/share/dfx/bin`
- Node.js: System installation
- Python: System installation

## 🔄 Updates

### Updating DFX Version
1. Update `DFX_VERSION` in `Dockerfile.ci`
2. Update `DFX_VERSION` in `.github/workflows/ci.yml`
3. Commit and push to trigger rebuild

### Adding New Tools
1. Add installation steps to `Dockerfile.ci`
2. Test locally with `./scripts/build-ci-image.sh`
3. Commit and push to trigger rebuild

## 📚 References

- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [GitHub Actions with Docker](https://docs.github.com/en/actions/using-containerized-services)
- [DFX Installation](https://internetcomputer.org/docs/current/developer-docs/setup/install/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/) 