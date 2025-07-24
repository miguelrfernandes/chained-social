#!/bin/bash

# Add the new Private Messaging Epic and its user stories to the project board
# This script adds the messaging epic (#64) and user stories (#65-70) to the project

set -e

echo "📋 Adding Private Messaging Epic and User Stories to Project Board..."
echo "===================================================================="

# Add the new epic to the project
echo "Adding Epic #64: Private Messaging System to project..."
gh project item-add 1 --owner miguelrfernandes --url "https://github.com/miguelrfernandes/chained-social/issues/64"

# Add user stories to the project
echo "Adding User Stories to project..."
for issue in {65..70}; do
    echo "Adding user story #$issue to project..."
    gh project item-add 1 --owner miguelrfernandes --url "https://github.com/miguelrfernandes/chained-social/issues/$issue"
done

echo ""
echo "✅ Successfully added Private Messaging Epic and User Stories to project!"
echo ""
echo "📊 Updated Project Structure:"
echo "============================"
echo ""
echo "🏗️ Epics in Project:"
echo "  #47: User Authentication & Profile Management"
echo "  #48: Content Creation & Management System"
echo "  #49: Social Graph & Relationship Management"
echo "  #50: Decentralized Governance & Voting"
echo "  #51: Monetization & Token Economics"
echo "  #52: Platform Infrastructure & CI/CD"
echo "  #53: Quality Assurance & Testing"
echo "  #54: Documentation & Maintenance"
echo "  #64: Private Messaging System (NEW PRIORITY)"
echo ""
echo "📝 User Stories in Project:"
echo "  #55-57: Authentication & Profiles"
echo "  #58-59: Content Management"
echo "  #60-61: Social Graph"
echo "  #62-63: Infrastructure"
echo "  #65-70: Private Messaging (NEW)"
echo ""
echo "🎯 Private Messaging User Stories:"
echo "  #65: Send Private Messages"
echo "  #66: Receive and View Messages"
echo "  #67: Message History and Conversations"
echo "  #68: Privacy Controls and Settings"
echo "  #69: File Sharing in Messages"
echo "  #70: Real-time Notifications"
echo ""
echo "📈 Project Status:"
echo "  Total Items: 42 (35 + 7 new items)"
echo "  Epics: 9"
echo "  User Stories: 15"
echo ""
echo "🚀 Next Steps:"
echo "1. Organize items into appropriate columns (To Do, In Progress, Done)"
echo "2. Set up epic-story relationships"
echo "3. Assign story points and priorities"
echo "4. Begin implementation of messaging canister"
echo "5. Update sprint planning to prioritize messaging features"
echo ""
echo "💡 Project URL: https://github.com/users/miguelrfernandes/projects/1" 