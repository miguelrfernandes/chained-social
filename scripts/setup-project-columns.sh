#!/bin/bash

# Set up project columns and basic automation for the ChainedSocial project
# This implements the structure defined in issue #17

set -e

echo "🏗️ Setting up project columns and automation..."

# Project ID (should be 1 based on our previous work)
PROJECT_ID=1

echo "📊 Creating project columns..."

# Note: GitHub CLI doesn't have direct column creation commands
# We'll need to use the web interface or API
# For now, let's create a comprehensive setup guide

cat > PROJECT_SETUP_GUIDE.md << 'EOF'
# 🎯 Project Setup Guide

## 📊 Manual Column Setup Required

Since GitHub CLI doesn't support column creation, please manually create these columns in the GitHub Projects web interface:

### Required Columns (in order):
1. **📋 Backlog** - New epics and user stories
2. **🎯 Ready for Development** - Prioritized and refined stories  
3. **🔄 In Progress** - Currently being worked on
4. **👀 Review** - Ready for code review and testing
5. **✅ Done** - Completed and deployed

### Optional Columns:
- **🚀 Sprint Planning** - Stories selected for current sprint
- **🐛 Bug Fixes** - Issues and bugs to address
- **📚 Documentation** - Documentation tasks
- **🔧 Technical Debt** - Refactoring and improvements

## 🏷️ Label Setup

Run the following commands to create required labels:

```bash
# Type labels
gh label create "epic" --description "Large feature groups" --color "0e8a16"
gh label create "user-story" --description "Individual implementation tasks" --color "1d76db"
gh label create "bug" --description "Issues and bugs" --color "d73a4a"
gh label create "documentation" --description "Documentation tasks" --color "0075ca"
gh label create "technical-debt" --description "Refactoring needs" --color "fbca04"
gh label create "enhancement" --description "Feature improvements" --color "a2eeef"

# Priority labels
gh label create "priority:high" --description "High priority items" --color "d73a4a"
gh label create "priority:medium" --description "Medium priority items" --color "fbca04"
gh label create "priority:low" --description "Low priority items" --color "0e8a16"

# Status labels
gh label create "ready-for-dev" --description "Ready to be worked on" --color "0e8a16"
gh label create "in-progress" --description "Currently being developed" --color "1d76db"
gh label create "review-needed" --description "Ready for review" --color "fbca04"
gh label create "blocked" --description "Blocked by dependencies" --color "d73a4a"
gh label create "sprint-ready" --description "Selected for current sprint" --color "a2eeef"
```

## ⚙️ Automation Setup

### GitHub Actions Workflow for Project Automation

Create `.github/workflows/project-automation.yml`:

```yaml
name: Project Automation

on:
  issues:
    types: [opened, edited, closed, reopened, labeled, unlabeled]
  pull_request:
    types: [opened, edited, closed, reopened, labeled, unlabeled, ready_for_review, review_requested]

jobs:
  project-automation:
    runs-on: ubuntu-latest
    steps:
      - name: Auto-assign to project
        if: github.event.action == 'opened'
        run: |
          # Add new issues to project
          gh project item-add 1 ${{ github.event.issue.number }} --owner miguelrfernandes
      
      - name: Auto-assign labels
        if: github.event.action == 'opened'
        run: |
          # Auto-assign type labels based on title/content
          if [[ "${{ github.event.issue.title }}" == *"epic"* ]] || [[ "${{ github.event.issue.body }}" == *"epic"* ]]; then
            gh issue edit ${{ github.event.issue.number }} --add-label "epic"
          fi
          if [[ "${{ github.event.issue.title }}" == *"story"* ]] || [[ "${{ github.event.issue.title }}" == *"user story"* ]]; then
            gh issue edit ${{ github.event.issue.number }} --add-label "user-story"
          fi
          if [[ "${{ github.event.issue.title }}" == *"bug"* ]] || [[ "${{ github.event.issue.title }}" == *"fix"* ]]; then
            gh issue edit ${{ github.event.issue.number }} --add-label "bug"
          fi
          if [[ "${{ github.event.issue.title }}" == *"doc"* ]] || [[ "${{ github.event.issue.title }}" == *"documentation"* ]]; then
            gh issue edit ${{ github.event.issue.number }} --add-label "documentation"
          fi
```

## 📋 Next Steps

1. **Create columns manually** in GitHub Projects web interface
2. **Run label creation commands** above
3. **Create automation workflow** file
4. **Test automation** with new issues
5. **Train team** on new workflow
6. **Monitor and iterate** based on feedback

## 🎯 Success Metrics

- [ ] All columns created and functional
- [ ] Labels applied to existing items
- [ ] Automation working correctly
- [ ] Team trained on new process
- [ ] First sprint planned and executed
- [ ] Metrics dashboard configured
EOF

echo "✅ Created PROJECT_SETUP_GUIDE.md with comprehensive setup instructions!"
echo ""
echo "📋 Next steps:"
echo "1. Follow the guide to set up columns manually"
echo "2. Run the label creation commands"
echo "3. Set up the automation workflow"
echo "4. Test the complete system" 