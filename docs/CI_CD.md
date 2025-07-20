# 🚀 CI/CD Pipeline

This project uses GitHub Actions for continuous integration and deployment. The pipeline automatically runs tests, builds the application, and deploys previews for pull requests.

## 📋 Pipeline Overview

### 🧪 Test Job
- **Purpose**: Run unit tests and validate canister functionality
- **Triggers**: On push to main/develop and pull requests
- **Steps**:
  1. Setup dfx and local replica
  2. Install frontend dependencies
  3. Build frontend assets
  4. Deploy canisters locally
  5. Run unit tests using `scripts/run-tests.sh`
  6. Upload test results as artifacts

### 🏗️ Build & Validate Job
- **Purpose**: Validate deployment and run integration tests
- **Dependencies**: Runs after test job completes
- **Steps**:
  1. Deploy canisters
  2. Validate canister status
  3. Generate type declarations
  4. Run integration tests against canister functions
  5. Upload build artifacts

### 🔍 Lint & Format Job
- **Purpose**: Check code quality and formatting
- **Steps**:
  1. Install Node.js dependencies
  2. Run ESLint for code quality
  3. Check Prettier formatting
  4. Non-blocking (warnings only)

### 🚀 Deploy Preview Job
- **Purpose**: Deploy preview to playground for pull requests
- **Triggers**: Only on pull requests
- **Steps**:
  1. Deploy to Internet Computer playground
  2. Get canister IDs and URLs
  3. Comment on PR with preview link

## 🛠️ Local Development

### Running Tests Locally
```bash
# Run all tests
just test

# Or manually
chmod +x scripts/run-tests.sh
./scripts/run-tests.sh
```

### Code Quality Checks
```bash
# Lint frontend code
cd frontend && npm run lint

# Format code
cd frontend && npm run format

# Check formatting
cd frontend && npm run format:check
```

## 📊 Artifacts

The pipeline generates several artifacts:

- **test-results**: Test output and logs
- **build-artifacts**: Built frontend and canister declarations

## 🔧 Configuration

### Environment Variables
- `DFX_VERSION`: dfx version (0.27.0)
- `NODE_VERSION`: Node.js version (20)

### Dependencies
- **dfx**: Internet Computer SDK
- **Node.js**: For frontend build and linting
- **Python**: For dfx installation

## 🚀 Deployment

### Preview Deployments
- Automatically deployed to playground for pull requests
- URLs posted as comments on PRs
- Available until PR is closed

### Manual Deployment
```bash
# Deploy to playground
just deploy-playground

# Deploy to mainnet
just mainnet
```

## 📈 Monitoring

### Pipeline Status
- Check GitHub Actions tab for pipeline status
- View logs for detailed error information
- Download artifacts for debugging

### Test Results
- Unit test results available in artifacts
- Integration test results in build job logs
- Canister status validation in build job

## 🔍 Troubleshooting

### Common Issues

1. **dfx Installation Fails**
   - Check Internet Computer installation script
   - Verify network connectivity

2. **Tests Fail**
   - Check canister deployment status
   - Verify test script permissions
   - Review test logs in artifacts

3. **Build Fails**
   - Check frontend dependencies
   - Verify TypeScript compilation
   - Review build logs

4. **Deployment Fails**
   - Check dfx configuration
   - Verify canister declarations
   - Review deployment logs

### Debugging Commands
```bash
# Check dfx status
dfx ping

# Check canister status
dfx canister status backend
dfx canister status content
dfx canister status socialgraph
dfx canister status frontend

# View logs
dfx logs backend
dfx logs content
dfx logs socialgraph
```

## 📝 Adding New Tests

1. **Unit Tests**: Add to `backend/test.mo` or `socialgraph/test.mo`
2. **Integration Tests**: Add to build job in CI workflow
3. **Frontend Tests**: Add to frontend test suite

## 🔄 Workflow Triggers

- **Push to main/develop**: Full pipeline execution
- **Pull Request**: Test, build, lint, and preview deployment
- **Manual**: Can be triggered manually from GitHub Actions tab

## 📋 Requirements

- GitHub repository with Actions enabled
- dfx 0.27.0 or later
- Node.js 20 or later
- Python 3.11 or later 