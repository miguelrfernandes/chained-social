#!/bin/bash

# Setup single GitHub Project for ChainedSocial
# This script creates a comprehensive project with all development tasks

set -e

echo "🏗️ Setting up single GitHub Project for ChainedSocial..."

echo "📋 Creating comprehensive issues for the platform..."

# Development & Setup Issues
echo "Creating Development & Setup issues..."
gh issue create --title "Set up project columns and automation" \
  --body "Configure the ChainedSocial Platform project with proper columns and automation workflows" \
  --label "enhancement,documentation"

gh issue create --title "Implement user authentication flow" \
  --body "Complete the NFID authentication integration with proper user session management" \
  --label "enhancement,authentication"

gh issue create --title "Add comprehensive testing suite" \
  --body "Create unit tests, integration tests, and end-to-end tests for all canisters" \
  --label "testing"

# Feature Development Issues
echo "Creating Feature Development issues..."
gh issue create --title "User profile management system" \
  --body "Implement comprehensive user profile management with NFID integration" \
  --label "enhancement,authentication"

gh issue create --title "Content creation and management system" \
  --body "Build the content creation, editing, and management features" \
  --label "enhancement"

gh issue create --title "Social graph and relationship management" \
  --body "Implement following, followers, and social relationship features" \
  --label "enhancement"

gh issue create --title "Governance and voting system" \
  --body "Implement decentralized governance with voting mechanisms" \
  --label "enhancement"

gh issue create --title "Monetization and token system" \
  --body "Implement token-based monetization and reward systems" \
  --label "enhancement"

# Maintenance & Optimization Issues
echo "Creating Maintenance & Optimization issues..."
gh issue create --title "Code documentation improvements" \
  --body "Add comprehensive documentation for all canisters and frontend components" \
  --label "documentation"

gh issue create --title "Performance optimization" \
  --body "Optimize canister performance and frontend loading times" \
  --label "enhancement"

gh issue create --title "Security audit and improvements" \
  --body "Conduct security audit and implement security improvements" \
  --label "enhancement"

# CI/CD & Infrastructure Issues
echo "Creating CI/CD & Infrastructure issues..."
gh issue create --title "CI optimization" \
  --body "Optimize the CI pipeline for faster builds and better caching" \
  --label "enhancement"

gh issue create --title "Deployment automation" \
  --body "Automate deployment to playground and mainnet" \
  --label "enhancement"

gh issue create --title "Monitoring and alerting setup" \
  --body "Set up comprehensive monitoring and alerting for the platform" \
  --label "enhancement"

gh issue create --title "Integration testing for multi-canister applications" \
  --body "Implement comprehensive browser-based end-to-end testing for the multi-canister architecture" \
  --label "testing,enhancement"

echo "✅ Single GitHub Project setup complete!"
echo ""
echo "📋 Project URL: https://github.com/users/miguelrfernandes/projects/1"
echo ""
echo "🔧 Recommended columns for the project:"
echo "📋 Backlog - Planned features and tasks"
echo "🚀 To Do - Ready for development"
echo "🔄 In Progress - Currently being worked on"
echo "🧪 Testing - Under testing and validation"
echo "✅ Done - Completed tasks"
echo "🐛 Bugs - Issues and fixes needed"
echo ""
echo "🎯 Next steps:"
echo "1. Visit the project URL to configure columns"
echo "2. Organize issues into appropriate columns"
echo "3. Set up automation workflows"
echo "4. Add assignees and milestones" 