#!/bin/bash

# Add all new epics and user stories to the project board
# This script adds the new epics (#71-73) and user stories (#74-91) to the project

set -e

echo "📋 Adding All New Epics and User Stories to Project Board..."
echo "============================================================"

# Add the new epics to the project
echo "Adding new epics to project..."
for issue in {71..73}; do
    echo "Adding epic #$issue to project..."
    gh project item-add 1 --owner miguelrfernandes --url "https://github.com/miguelrfernandes/chained-social/issues/$issue"
done

# Add user stories to the project
echo "Adding user stories to project..."
for issue in {74..91}; do
    echo "Adding user story #$issue to project..."
    gh project item-add 1 --owner miguelrfernandes --url "https://github.com/miguelrfernandes/chained-social/issues/$issue"
done

echo ""
echo "✅ Successfully added all new epics and user stories to project!"
echo ""
echo "📊 Updated Project Structure:"
echo "============================"
echo ""
echo "🏗️ All Epics in Project:"
echo "  #47: User Authentication & Profile Management"
echo "  #48: Content Creation & Management System"
echo "  #49: Social Graph & Relationship Management"
echo "  #50: Decentralized Governance & Voting"
echo "  #51: Monetization & Token Economics"
echo "  #52: Platform Infrastructure & CI/CD"
echo "  #53: Quality Assurance & Testing"
echo "  #54: Documentation & Maintenance"
echo "  #64: Private Messaging System (High Priority)"
echo "  #71: Proof of Humanity System (High Priority) - NEW"
echo "  #72: DeFi Integration (Medium Priority) - NEW"
echo "  #73: Gaming Platform (Medium Priority) - NEW"
echo ""
echo "📝 All User Stories in Project:"
echo "  #55-57: Authentication & Profiles"
echo "  #58-59: Content Management"
echo "  #60-61: Social Graph"
echo "  #62-63: Infrastructure"
echo "  #65-70: Private Messaging"
echo "  #74-79: Proof of Humanity (NEW)"
echo "  #80-85: DeFi Integration (NEW)"
echo "  #86-91: Gaming Platform (NEW)"
echo ""
echo "🎯 New Epic Details:"
echo "==================="
echo ""
echo "👤 Proof of Humanity (#71):"
echo "  - Human verification system"
echo "  - Bot detection and prevention"
echo "  - Reputation and trust scores"
echo "  - Human-only features"
echo "  - Verification management"
echo "  - Trust score display"
echo ""
echo "💰 DeFi Integration (#72):"
echo "  - Token earning system"
echo "  - Staking and governance"
echo "  - Yield farming features"
echo "  - Token trading interface"
echo "  - Platform economy management"
echo "  - DeFi analytics dashboard"
echo ""
echo "🎮 Gaming Platform (#73):"
echo "  - Social games implementation"
echo "  - Leaderboards and achievements"
echo "  - Gaming tournaments"
echo "  - Gamified content creation"
echo "  - Gaming rewards system"
echo "  - Gaming analytics dashboard"
echo ""
echo "📈 Updated Project Status:"
echo "  Total Items: 63 (42 + 21 new items)"
echo "  Epics: 12"
echo "  User Stories: 33"
echo ""
echo "🚀 Priority Recommendations:"
echo "=========================="
echo "1. HIGH PRIORITY: Proof of Humanity (#71) - Critical for platform security"
echo "2. HIGH PRIORITY: Private Messaging (#64) - Core social feature"
echo "3. MEDIUM PRIORITY: DeFi Integration (#72) - Platform economy"
echo "4. MEDIUM PRIORITY: Gaming Platform (#73) - User engagement"
echo ""
echo "📋 Next Steps:"
echo "1. Organize items into appropriate columns (To Do, In Progress, Done)"
echo "2. Set up epic-story relationships"
echo "3. Assign story points and priorities"
echo "4. Begin implementation of Proof of Humanity canister"
echo "5. Plan DeFi and Gaming implementation phases"
echo "6. Update sprint planning to include new epics"
echo ""
echo "💡 Project URL: https://github.com/users/miguelrfernandes/projects/1" 