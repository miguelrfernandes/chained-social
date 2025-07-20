#!/bin/bash

# Reorganize issues into epics with user stories
# This script will close current issues and create proper epics with sub-issues

set -e

echo "🔍 Analyzing current issues and reorganizing into epics..."

# First, let's close the current issues that need to be reorganized
echo "🗑️ Closing current issues that will be reorganized..."

# Issues to close (the ones we created for the project)
ISSUES_TO_CLOSE=(32 33 34 35 36 37 38 39 40 41 42 43 44 45 46)

for issue in "${ISSUES_TO_CLOSE[@]}"; do
    echo "Closing issue #$issue..."
    gh issue close $issue --reason "not planned"
done

echo "✅ Closed current issues"

echo "🏗️ Creating epics with user stories..."

# Epic 1: User Authentication & Profiles
echo "Creating Epic: User Authentication & Profiles"
EPIC_AUTH=$(gh issue create --title "Epic: User Authentication & Profile Management" \
  --body "## Epic: User Authentication & Profile Management

### Overview
Complete user authentication system with NFID integration and comprehensive profile management.

### Goals
- Secure user authentication with NFID
- User profile creation and management
- Session management and security
- User data privacy and control

### Success Criteria
- Users can authenticate securely with NFID
- Users can create and manage their profiles
- Session management works reliably
- User data is properly secured and private

### Dependencies
- NFID integration (already implemented)
- Backend user management system
- Frontend profile components" \
  --label "epic,authentication,enhancement")

echo "Created Epic: $EPIC_AUTH"

# Epic 2: Content Management System
echo "Creating Epic: Content Management System"
EPIC_CONTENT=$(gh issue create --title "Epic: Content Creation & Management System" \
  --body "## Epic: Content Creation & Management System

### Overview
Comprehensive content creation, editing, and management system for posts, articles, and media.

### Goals
- Content creation and editing
- Media upload and management
- Content organization and categorization
- Content moderation and quality control

### Success Criteria
- Users can create and edit content easily
- Media files can be uploaded and managed
- Content is properly organized and searchable
- Moderation tools are effective

### Dependencies
- User authentication system
- Storage system for media files
- Content moderation tools" \
  --label "epic,enhancement")

echo "Created Epic: $EPIC_CONTENT"

# Epic 3: Social Graph & Relationships
echo "Creating Epic: Social Graph & Relationships"
EPIC_SOCIAL=$(gh issue create --title "Epic: Social Graph & Relationship Management" \
  --body "## Epic: Social Graph & Relationship Management

### Overview
Social networking features including following, followers, and relationship management.

### Goals
- User following and follower system
- Social feed and content discovery
- Relationship management tools
- Social interactions and engagement

### Success Criteria
- Users can follow other users
- Social feed shows relevant content
- Relationship management is intuitive
- Social interactions are engaging

### Dependencies
- User authentication system
- Content management system
- Feed algorithm implementation" \
  --label "epic,enhancement")

echo "Created Epic: $EPIC_SOCIAL"

# Epic 4: Governance & Voting
echo "Creating Epic: Governance & Voting System"
EPIC_GOVERNANCE=$(gh issue create --title "Epic: Decentralized Governance & Voting" \
  --body "## Epic: Decentralized Governance & Voting

### Overview
Decentralized governance system with voting mechanisms and community decision-making.

### Goals
- Proposal creation and management
- Voting mechanisms and token governance
- Community decision-making tools
- Governance transparency and accountability

### Success Criteria
- Users can create and vote on proposals
- Voting is secure and transparent
- Governance decisions are properly executed
- Community engagement is high

### Dependencies
- User authentication system
- Token system implementation
- Smart contract governance" \
  --label "epic,enhancement")

echo "Created Epic: $EPIC_GOVERNANCE"

# Epic 5: Monetization & Token System
echo "Creating Epic: Monetization & Token System"
EPIC_MONETIZATION=$(gh issue create --title "Epic: Monetization & Token Economics" \
  --body "## Epic: Monetization & Token Economics

### Overview
Token-based monetization system with rewards, incentives, and economic mechanisms.

### Goals
- Token creation and distribution
- Reward mechanisms for content creators
- Economic incentives and gamification
- Revenue sharing and monetization

### Success Criteria
- Token system is functional and secure
- Content creators are properly rewarded
- Economic incentives drive engagement
- Revenue sharing is fair and transparent

### Dependencies
- User authentication system
- Content management system
- Smart contract token system" \
  --label "epic,enhancement")

echo "Created Epic: $EPIC_MONETIZATION"

# Epic 6: Platform Infrastructure
echo "Creating Epic: Platform Infrastructure & CI/CD"
EPIC_INFRASTRUCTURE=$(gh issue create --title "Epic: Platform Infrastructure & CI/CD" \
  --body "## Epic: Platform Infrastructure & CI/CD

### Overview
Comprehensive infrastructure setup including CI/CD, monitoring, and deployment automation.

### Goals
- Optimized Nix-based CI/CD pipeline
- Automated deployment to playground and mainnet
- Comprehensive monitoring and alerting
- Performance optimization and scaling

### Success Criteria
- CI/CD pipeline is fast and reliable
- Deployments are automated and secure
- Monitoring provides real-time insights
- Platform performance is optimized

### Dependencies
- Nix CI setup (already implemented)
- Monitoring tools integration
- Deployment automation scripts" \
  --label "epic,enhancement")

echo "Created Epic: $EPIC_INFRASTRUCTURE"

# Epic 7: Quality Assurance & Testing
echo "Creating Epic: Quality Assurance & Testing"
EPIC_TESTING=$(gh issue create --title "Epic: Quality Assurance & Testing" \
  --body "## Epic: Quality Assurance & Testing

### Overview
Comprehensive testing strategy including unit tests, integration tests, and end-to-end testing.

### Goals
- Unit tests for all canisters
- Integration tests for multi-canister communication
- End-to-end browser testing
- Performance and security testing

### Success Criteria
- All code is properly tested
- Integration tests cover all scenarios
- E2E tests validate user workflows
- Performance meets requirements

### Dependencies
- All feature implementations
- Testing framework setup
- Browser automation tools" \
  --label "epic,testing,enhancement")

echo "Created Epic: $EPIC_TESTING"

# Epic 8: Documentation & Maintenance
echo "Creating Epic: Documentation & Maintenance"
EPIC_DOCUMENTATION=$(gh issue create --title "Epic: Documentation & Maintenance" \
  --body "## Epic: Documentation & Maintenance

### Overview
Comprehensive documentation and ongoing maintenance for the platform.

### Goals
- Complete code documentation
- User and developer guides
- Performance optimization
- Security audits and improvements

### Success Criteria
- All code is well documented
- Guides are comprehensive and clear
- Performance is optimized
- Security is audited and improved

### Dependencies
- All feature implementations
- Documentation tools setup
- Security audit tools" \
  --label "epic,documentation,enhancement")

echo "Created Epic: $EPIC_DOCUMENTATION"

echo "✅ Epics created successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Create user stories as sub-issues for each epic"
echo "2. Add acceptance criteria to each user story"
echo "3. Organize epics in the project board"
echo "4. Set up epic-story relationships" 