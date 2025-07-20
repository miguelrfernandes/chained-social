#!/bin/bash

# Build CI Docker image locally for testing
# Usage: ./scripts/build-ci-image.sh

set -e

echo "🐳 Building CI Docker image..."

# Get the repository name
REPO_NAME=$(basename $(git rev-parse --show-toplevel))

# Build the image
docker build -f Dockerfile.ci -t ${REPO_NAME}-ci:latest .

echo "✅ CI Docker image built successfully!"
echo "📋 Image: ${REPO_NAME}-ci:latest"
echo ""
echo "🧪 To test the image locally:"
echo "   docker run -it ${REPO_NAME}-ci:latest"
echo ""
echo "🚀 To run with your project:"
echo "   docker run -it -v \$(pwd):/workspace ${REPO_NAME}-ci:latest" 