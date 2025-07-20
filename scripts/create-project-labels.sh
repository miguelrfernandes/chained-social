#!/bin/bash

# Create all required labels for the ChainedSocial project
# This implements the label management strategy from issue #17

set -e

echo "🏷️ Creating project labels..."

# Type labels
echo "Creating type labels..."
gh label create "epic" --description "Large feature groups" --color "0e8a16"
gh label create "user-story" --description "Individual implementation tasks" --color "1d76db"
gh label create "bug" --description "Issues and bugs" --color "d73a4a"
gh label create "documentation" --description "Documentation tasks" --color "0075ca"
gh label create "technical-debt" --description "Refactoring needs" --color "fbca04"
gh label create "enhancement" --description "Feature improvements" --color "a2eeef"

# Priority labels
echo "Creating priority labels..."
gh label create "priority:high" --description "High priority items" --color "d73a4a"
gh label create "priority:medium" --description "Medium priority items" --color "fbca04"
gh label create "priority:low" --description "Low priority items" --color "0e8a16"

# Status labels
echo "Creating status labels..."
gh label create "ready-for-dev" --description "Ready to be worked on" --color "0e8a16"
gh label create "in-progress" --description "Currently being developed" --color "1d76db"
gh label create "review-needed" --description "Ready for review" --color "fbca04"
gh label create "blocked" --description "Blocked by dependencies" --color "d73a4a"
gh label create "sprint-ready" --description "Selected for current sprint" --color "a2eeef"

echo "✅ All labels created successfully!"
echo ""
echo "📋 Created labels:"
echo "Type labels: epic, user-story, bug, documentation, technical-debt, enhancement"
echo "Priority labels: priority:high, priority:medium, priority:low"
echo "Status labels: ready-for-dev, in-progress, review-needed, blocked, sprint-ready" 