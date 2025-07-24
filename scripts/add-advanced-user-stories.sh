#!/bin/bash

# Add Advanced User Stories to Existing Epics
# This script adds user stories to existing epics without creating new epics

set -e

echo "📝 Adding Advanced User Stories to Existing Epics..."
echo "=================================================="

# Add User Stories to Epic #71 (Proof of Humanity System)
echo "🛡️ Adding Security User Stories to Epic #71"
echo "=========================================="

# Rate-Limiting Nullifier (RLN)
gh issue create --title "User Story: Rate-Limiting Nullifier (RLN)" \
  --body "## User Story: Rate-Limiting Nullifier (RLN)

**As a** platform administrator
**I want to** implement RLN protocol for rate limiting
**So that** I can prevent spam and Sybil attacks effectively

### Acceptance Criteria
- [ ] RLN canister is deployed and functional
- [ ] Rate limiting is enforced per epoch
- [ ] Secret key leakage occurs for violations
- [ ] Economic penalties are applied
- [ ] Anonymous posting is rate-limited

### Technical Requirements
- RLN canister implementation
- Epoch-based rate limiting
- Secret key management
- Penalty enforcement system

### Definition of Done
- [ ] RLN protocol is implemented
- [ ] Rate limiting works correctly
- [ ] Penalties are enforced
- [ ] Security is maintained" \
  --label "user-story,proof-of-humanity,security,rln"

# Social Vouching System
gh issue create --title "User Story: Social Vouching System" \
  --body "## User Story: Social Vouching System

**As a** verified user
**I want to** vouch for new users joining the platform
**So that** I can help maintain community quality

### Acceptance Criteria
- [ ] Verified users can vouch for new users
- [ ] Vouching requires stake or reputation
- [ ] Disputes are resolved via Kleros
- [ ] Vouching history is tracked
- [ ] Bad vouches have consequences

### Technical Requirements
- Vouching canister
- Kleros integration
- Reputation system
- Dispute resolution

### Definition of Done
- [ ] Vouching system works
- [ ] Disputes are resolved
- [ ] Reputation is tracked
- [ ] Quality is maintained" \
  --label "user-story,proof-of-humanity,security,vouching"

# Add User Stories to Epic #51 (Monetization & Token Economics)
echo "💰 Adding Monetization User Stories to Epic #51"
echo "=============================================="

# Micro-Payment System
gh issue create --title "User Story: Micro-Payment System" \
  --body "## User Story: Micro-Payment System

**As a** user
**I want to** send and receive micro-payments in ICP and custom tokens
**So that** I can support creators and monetize my content

### Acceptance Criteria
- [ ] Users can send micro-payments to other users
- [ ] Payment processing is secure and reliable
- [ ] Multiple token types are supported
- [ ] Transaction history is available
- [ ] Payment notifications work

### Technical Requirements
- Payment processing canisters
- Token integration (ICP and custom tokens)
- Transaction management system
- Notification system

### Definition of Done
- [ ] Micro-payments work reliably
- [ ] Security is maintained
- [ ] User experience is smooth
- [ ] Notifications function properly" \
  --label "user-story,monetization,payments"

# Tip Jars & Donations
gh issue create --title "User Story: Tip Jars & Donations" \
  --body "## User Story: Tip Jars & Donations

**As a** content creator
**I want to** receive tips and donations from my audience
**So that** I can monetize my content and receive support

### Acceptance Criteria
- [ ] Users can set up tip jars on their profiles
- [ ] Donations can be sent anonymously or with messages
- [ ] Tip history is tracked and displayed
- [ ] Multiple payment methods are supported
- [ ] Tip notifications work properly

### Technical Requirements
- Tip jar canister
- Donation processing system
- Anonymous payment support
- Message attachment system

### Definition of Done
- [ ] Tip jars are functional
- [ ] Donations process correctly
- [ ] History is tracked properly
- [ ] Notifications work" \
  --label "user-story,monetization,donations"

# On-Chain Paywalls
gh issue create --title "User Story: On-Chain Paywalls" \
  --body "## User Story: On-Chain Paywalls

**As a** content creator
**I want to** create exclusive content behind paywalls
**So that** I can monetize premium content

### Acceptance Criteria
- [ ] Users can create paywalled content
- [ ] Payment is required to access content
- [ ] Revenue is distributed fairly
- [ ] Paywall analytics are available
- [ ] Multiple payment options exist

### Technical Requirements
- Paywall canister
- Content access control
- Revenue distribution system
- Analytics tracking

### Definition of Done
- [ ] Paywalls work correctly
- [ ] Payments are processed
- [ ] Revenue is distributed
- [ ] Analytics are accurate" \
  --label "user-story,monetization,paywalls"

# Add User Stories to Epic #48 (Content Creation & Management)
echo "🔍 Adding Content Discovery User Stories to Epic #48"
echo "=================================================="

# Hashtag System
gh issue create --title "User Story: Hashtag System" \
  --body "## User Story: Hashtag System

**As a** user
**I want to** use hashtags to organize and discover content
**So that** I can find relevant posts and categorize my own content

### Acceptance Criteria
- [ ] Users can add hashtags to posts
- [ ] Hashtags are clickable and searchable
- [ ] Trending hashtags are displayed
- [ ] Hashtag suggestions work
- [ ] Hashtag analytics are available

### Technical Requirements
- Hashtag indexing system
- Search functionality
- Trending algorithm
- Suggestion system

### Definition of Done
- [ ] Hashtags work properly
- [ ] Search is functional
- [ ] Trending works accurately
- [ ] Suggestions are helpful" \
  --label "user-story,content-discovery,hashtags"

# Mention System
gh issue create --title "User Story: Mention System" \
  --body "## User Story: Mention System

**As a** user
**I want to** mention other users in my posts
**So that** I can reference and notify specific people

### Acceptance Criteria
- [ ] Users can mention others with @username
- [ ] Mentions are clickable and link to profiles
- [ ] Mentioned users receive notifications
- [ ] Mention suggestions work
- [ ] Mention analytics are available

### Technical Requirements
- Mention parsing system
- Notification system
- Profile linking
- Suggestion algorithm

### Definition of Done
- [ ] Mentions work correctly
- [ ] Notifications are sent
- [ ] Links function properly
- [ ] Suggestions are accurate" \
  --label "user-story,content-discovery,mentions"

# Content Search & Discovery
gh issue create --title "User Story: Content Search & Discovery" \
  --body "## User Story: Content Search & Discovery

**As a** user
**I want to** search and discover content easily
**So that** I can find relevant posts and users

### Acceptance Criteria
- [ ] Full-text search works
- [ ] Search results are relevant
- [ ] Advanced filters are available
- [ ] Search history is saved
- [ ] Search suggestions work

### Technical Requirements
- Search canister
- Indexing system
- Relevance algorithm
- Filter system

### Definition of Done
- [ ] Search is fast and accurate
- [ ] Results are relevant
- [ ] Filters work properly
- [ ] Suggestions are helpful" \
  --label "user-story,content-discovery,search"

# Add UI/UX User Stories
echo "🎨 Adding UI/UX User Stories"
echo "============================"

# Dark Mode Implementation
gh issue create --title "User Story: Dark Mode Implementation" \
  --body "## User Story: Dark Mode Implementation

**As a** user
**I want to** use dark mode with #111827 color scheme
**So that** I can have a comfortable viewing experience in low-light conditions

### Acceptance Criteria
- [ ] Dark mode uses #111827 as primary dark color
- [ ] Theme switching is smooth and accessible
- [ ] All components are properly themed
- [ ] Dark mode works across all platform features
- [ ] Theme persists across sessions

### Technical Requirements
- CSS custom properties for theme variables
- Theme context and provider system
- Component theme integration
- Local storage for theme persistence

### Definition of Done
- [ ] Dark mode is fully functional
- [ ] All components support dark theme
- [ ] Theme switching works smoothly
- [ ] User preferences are saved" \
  --label "user-story,dark-mode,ui,accessibility"

# Screen Reader Support
gh issue create --title "User Story: Screen Reader Support" \
  --body "## User Story: Screen Reader Support

**As a** user with visual impairments
**I want to** navigate the platform using a screen reader
**So that** I can access all platform features independently

### Acceptance Criteria
- [ ] All content is properly labeled
- [ ] Navigation is logical and accessible
- [ ] Forms have proper labels and descriptions
- [ ] Images have alt text
- [ ] Interactive elements are properly announced

### Technical Requirements
- ARIA labels and roles
- Semantic HTML structure
- Screen reader testing
- Accessibility audit tools

### Definition of Done
- [ ] Screen reader compatibility verified
- [ ] All content is accessible
- [ ] Navigation works properly
- [ ] Testing confirms accessibility" \
  --label "user-story,accessibility,screen-reader"

# Multi-Language Support
gh issue create --title "User Story: Multi-Language Support" \
  --body "## User Story: Multi-Language Support

**As a** user
**I want to** use the platform in my preferred language
**So that** I can have a better user experience

### Acceptance Criteria
- [ ] UI supports multiple languages
- [ ] Language selection is available
- [ ] Content can be translated
- [ ] Language preference is saved
- [ ] RTL languages are supported

### Technical Requirements
- i18n framework integration
- Translation management system
- Language detection
- RTL layout support

### Definition of Done
- [ ] Multiple languages work
- [ ] Translations are complete
- [ ] Language switching works
- [ ] RTL support is functional" \
  --label "user-story,internationalization,i18n"

echo ""
echo "✅ Successfully created Advanced User Stories!"
echo ""
echo "📊 Summary of New User Stories:"
echo "=============================="
echo ""
echo "🛡️ Security (Epic #71):"
echo "  - Rate-Limiting Nullifier (RLN)"
echo "  - Social Vouching System"
echo ""
echo "💰 Monetization (Epic #51):"
echo "  - Micro-Payment System"
echo "  - Tip Jars & Donations"
echo "  - On-Chain Paywalls"
echo ""
echo "🔍 Content Discovery (Epic #48):"
echo "  - Hashtag System"
echo "  - Mention System"
echo "  - Content Search & Discovery"
echo ""
echo "🎨 UI/UX Enhancements:"
echo "  - Dark Mode Implementation"
echo "  - Screen Reader Support"
echo "  - Multi-Language Support"
echo ""
echo "🎯 Total New User Stories: 10"
echo ""
echo "🚀 Next Steps:"
echo "1. Add user stories to project board"
echo "2. Prioritize implementation order"
echo "3. Begin with high-priority security features"
echo "4. Plan UI/UX improvements"
echo ""
echo "✅ Advanced User Stories created successfully!" 