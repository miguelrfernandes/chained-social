#!/bin/bash

# Add epics and user stories to the ChainedSocial Platform project
# This script adds all epics and user stories to project #1

set -e

echo "📋 Adding epics and user stories to ChainedSocial Platform project..."

# Epics (issues 47-54)
echo "Adding epics to project..."
for issue in {47..54}; do
    echo "Adding epic #$issue to project..."
    gh project item-add 1 --owner miguelrfernandes --url "https://github.com/miguelrfernandes/chained-social/issues/$issue"
done

# User Stories (issues 55-63)
echo "Adding user stories to project..."
for issue in {55..63}; do
    echo "Adding user story #$issue to project..."
    gh project item-add 1 --owner miguelrfernandes --url "https://github.com/miguelrfernandes/chained-social/issues/$issue"
done

echo "✅ All epics and user stories added to the project!"
echo ""
echo "📋 Project URL: https://github.com/users/miguelrfernandes/projects/1"
echo ""
echo "🏗️ Epic Structure:"
echo "Epic #47: User Authentication & Profile Management"
echo "Epic #48: Content Creation & Management System"
echo "Epic #49: Social Graph & Relationship Management"
echo "Epic #50: Decentralized Governance & Voting"
echo "Epic #51: Monetization & Token Economics"
echo "Epic #52: Platform Infrastructure & CI/CD"
echo "Epic #53: Quality Assurance & Testing"
echo "Epic #54: Documentation & Maintenance"
echo ""
echo "📝 User Stories:"
echo "User Stories #55-57: Authentication & Profiles"
echo "User Stories #58-59: Content Management"
echo "User Stories #60-61: Social Graph"
echo "User Stories #62-63: Infrastructure"
echo ""
echo "🎯 Next steps:"
echo "1. Visit the project URL to organize items into columns"
echo "2. Set up epic-story relationships"
echo "3. Assign story points and priorities"
echo "4. Create sprint planning" 