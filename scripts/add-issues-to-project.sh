#!/bin/bash

# Add issues to the ChainedSocial Platform project
# This script adds all the recent issues to project #1

set -e

echo "📋 Adding issues to ChainedSocial Platform project..."

# Array of issue numbers (from the recent creation)
ISSUES=(32 33 34 35 36 37 38 39 40 41 42 43 44 45 46)

for issue in "${ISSUES[@]}"; do
    echo "Adding issue #$issue to project..."
    gh project item-add 1 --owner miguelrfernandes --url "https://github.com/miguelrfernandes/chained-social/issues/$issue"
done

echo "✅ All issues added to the project!"
echo ""
echo "📋 Project URL: https://github.com/users/miguelrfernandes/projects/1"
echo ""
echo "🎯 Next steps:"
echo "1. Visit the project URL to organize issues into columns"
echo "2. Set up automation workflows"
echo "3. Add assignees and milestones" 