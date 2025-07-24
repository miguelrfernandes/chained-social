#!/bin/bash

# 🚀 Feature Branch Creator for ChainedSocial
# Usage: ./scripts/create-feature-branch.sh <branch-type> <description>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "justfile" ]; then
    print_error "This script must be run from the chainedsocial project root"
    exit 1
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    print_error "Git is not installed"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository"
    exit 1
fi

# Validate arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <branch-type> <description>"
    echo ""
    echo "Branch types:"
    echo "  feature     - New features or enhancements"
    echo "  fix         - Bug fixes"
    echo "  docs        - Documentation updates"
    echo "  refactor    - Code refactoring"
    echo "  test        - Test-related changes"
    echo "  chore       - Maintenance tasks"
    echo ""
    echo "Examples:"
    echo "  $0 feature user-authentication"
    echo "  $0 fix login-bug"
    echo "  $0 docs api-documentation"
    echo "  $0 refactor component-structure"
    exit 1
fi

BRANCH_TYPE=$1
DESCRIPTION=$2

# Validate branch type
VALID_TYPES=("feature" "fix" "docs" "refactor" "test" "chore")
if [[ ! " ${VALID_TYPES[@]} " =~ " ${BRANCH_TYPE} " ]]; then
    print_error "Invalid branch type: $BRANCH_TYPE"
    echo "Valid types: ${VALID_TYPES[*]}"
    exit 1
fi

# Create branch name
BRANCH_NAME="${BRANCH_TYPE}/${DESCRIPTION}"

# Convert to kebab-case if not already
BRANCH_NAME=$(echo "$BRANCH_NAME" | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')

print_info "Creating branch: $BRANCH_NAME"

# Ensure we're on main and it's up to date
print_status "Switching to main branch..."
git checkout main

print_status "Pulling latest changes..."
git pull origin main

# Create and switch to new branch
print_status "Creating new branch..."
git checkout -b "$BRANCH_NAME"

print_status "Branch '$BRANCH_NAME' created successfully!"
echo ""
print_info "Next steps:"
echo "  1. Make your changes"
echo "  2. git add ."
echo "  3. git commit -m 'descriptive commit message'"
echo "  4. git push origin $BRANCH_NAME"
echo "  5. Create PR at: https://github.com/miguelrfernandes/chained-social/pull/new/$BRANCH_NAME"
echo ""
print_info "Current branch: $(git branch --show-current)" 