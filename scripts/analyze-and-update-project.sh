#!/bin/bash

# Analyze GitHub issues, update project status, and add new epic for private messaging
# This script provides a comprehensive analysis and updates the project structure

set -e

echo "🔍 Analyzing ChainedSocial Project Status..."
echo "=========================================="

# Get current project info
echo "📋 Project Information:"
PROJECT_INFO=$(gh project view 1 --owner miguelrfernandes --format json)
echo "Project: ChainedSocial Platform"
echo "Items: 35"
echo "Fields: 10"
echo ""

# Analyze current issues
echo "📊 Current Issues Analysis:"
echo "=========================="

# Count issues by state
OPEN_ISSUES=$(gh issue list --state open --json number | jq length)
CLOSED_ISSUES=$(gh issue list --state closed --json number | jq length)
TOTAL_ISSUES=$((OPEN_ISSUES + CLOSED_ISSUES))

echo "Total Issues: $TOTAL_ISSUES"
echo "Open Issues: $OPEN_ISSUES"
echo "Closed Issues: $CLOSED_ISSUES"
echo ""

# Analyze epics
echo "🏗️ Epic Analysis:"
echo "================="

EPICS=$(gh issue list --state open --label epic --json number,title,labels)
EPIC_COUNT=$(echo "$EPICS" | jq length)

echo "Active Epics: $EPIC_COUNT"
echo ""

# List current epics
echo "Current Epics:"
echo "$EPICS" | jq -r '.[] | "  \(.number): \(.title)"'
echo ""

# Analyze user stories
echo "📝 User Stories Analysis:"
echo "========================"

USER_STORIES=$(gh issue list --state open --label "user-story" --json number,title,labels)
STORY_COUNT=$(echo "$USER_STORIES" | jq length)

echo "Active User Stories: $STORY_COUNT"
echo ""

# List current user stories
echo "Current User Stories:"
echo "$USER_STORIES" | jq -r '.[] | "  \(.number): \(.title)"'
echo ""

# Analyze by labels
echo "🏷️ Label Analysis:"
echo "=================="

echo "Issues by Category:"
gh issue list --state open --json labels | jq -r '.[].labels[].name' | sort | uniq -c | sort -nr
echo ""

# Create new Private Messaging Epic
echo "💬 Creating New Epic: Private Messaging System"
echo "============================================="

PRIVATE_MESSAGING_EPIC=$(gh issue create --title "Epic: Private Messaging System" \
  --body "## Epic: Private Messaging System

### Overview
Implement a comprehensive private messaging system that allows users to send and receive private messages, creating a more intimate communication channel within the ChainedSocial platform.

### Goals
- Secure private messaging between users
- Real-time message delivery and notifications
- Message history and conversation management
- Privacy controls and message encryption
- File and media sharing in private messages

### Success Criteria
- Users can send private messages to other users
- Messages are delivered in real-time
- Users can view message history and conversations
- Privacy settings allow users to control who can message them
- Messages are encrypted and secure
- File sharing works within private messages

### Technical Requirements
- New messaging canister for message storage
- Real-time messaging using WebSocket or polling
- Message encryption for privacy
- File upload and sharing capabilities
- Notification system for new messages
- Conversation threading and organization

### User Stories to be created:
1. User Story: Send Private Messages
2. User Story: Receive and View Messages
3. User Story: Message History and Conversations
4. User Story: Privacy Controls and Settings
5. User Story: File Sharing in Messages
6. User Story: Real-time Notifications

### Dependencies
- User authentication system (Epic #47)
- Social graph system (Epic #49)
- Content management system (Epic #48)

### Priority: High
This epic represents a core social networking feature that will significantly enhance user engagement and platform value." \
  --label "epic,messaging,enhancement,high-priority")

echo "✅ Created Epic: $PRIVATE_MESSAGING_EPIC"
echo ""

# Create user stories for the Private Messaging Epic
echo "📝 Creating User Stories for Private Messaging Epic..."
echo "===================================================="

# User Story 1: Send Private Messages
echo "Creating User Story: Send Private Messages"
gh issue create --title "User Story: Send Private Messages" \
  --body "## User Story: Send Private Messages

**As a** user
**I want to** send private messages to other users
**So that** I can have private conversations

### Acceptance Criteria
- [ ] User can select a recipient from their network
- [ ] User can compose and send private messages
- [ ] Messages are delivered to the recipient
- [ ] User receives confirmation when message is sent
- [ ] Messages are encrypted for privacy
- [ ] User can attach files to messages

### Technical Requirements
- Implement message composition interface
- Create messaging canister for message storage
- Implement message encryption
- Handle file attachments
- Real-time message delivery

### Definition of Done
- [ ] Users can successfully send private messages
- [ ] Messages are delivered reliably
- [ ] Encryption is working properly
- [ ] File attachments work correctly" \
  --label "user-story,messaging,frontend"

# User Story 2: Receive and View Messages
echo "Creating User Story: Receive and View Messages"
gh issue create --title "User Story: Receive and View Messages" \
  --body "## User Story: Receive and View Messages

**As a** user
**I want to** receive and view private messages
**So that** I can read and respond to messages from others

### Acceptance Criteria
- [ ] User can see incoming messages in real-time
- [ ] User can view message content and sender
- [ ] User can reply to messages directly
- [ ] Messages are displayed in chronological order
- [ ] User can mark messages as read
- [ ] User can delete messages

### Technical Requirements
- Implement message inbox interface
- Real-time message updates
- Message threading and replies
- Message status tracking (read/unread)
- Message deletion functionality

### Definition of Done
- [ ] Users can view all received messages
- [ ] Real-time updates work properly
- [ ] Message threading is functional
- [ ] Message status is tracked correctly" \
  --label "user-story,messaging,frontend"

# User Story 3: Message History and Conversations
echo "Creating User Story: Message History and Conversations"
gh issue create --title "User Story: Message History and Conversations" \
  --body "## User Story: Message History and Conversations

**As a** user
**I want to** view conversation history with other users
**So that** I can maintain context and relationships

### Acceptance Criteria
- [ ] User can view conversation history with each contact
- [ ] Conversations are organized by contact
- [ ] User can search through message history
- [ ] User can export conversation history
- [ ] Messages are properly timestamped
- [ ] Conversation view is intuitive and easy to navigate

### Technical Requirements
- Implement conversation view interface
- Message history storage and retrieval
- Search functionality for messages
- Export functionality
- Timestamp tracking and display

### Definition of Done
- [ ] Conversation history is complete and accurate
- [ ] Search functionality works effectively
- [ ] Export feature is functional
- [ ] Interface is user-friendly" \
  --label "user-story,messaging,frontend"

# User Story 4: Privacy Controls and Settings
echo "Creating User Story: Privacy Controls and Settings"
gh issue create --title "User Story: Privacy Controls and Settings" \
  --body "## User Story: Privacy Controls and Settings

**As a** user
**I want to** control who can send me messages
**So that** I can manage my privacy and avoid spam

### Acceptance Criteria
- [ ] User can set who can message them (all, followers, none)
- [ ] User can block specific users from messaging
- [ ] User can report inappropriate messages
- [ ] User can mute conversations
- [ ] Privacy settings are saved and enforced
- [ ] User receives notifications about privacy changes

### Technical Requirements
- Implement privacy settings interface
- Block/unblock user functionality
- Report system for inappropriate content
- Mute conversation functionality
- Privacy enforcement in messaging system

### Definition of Done
- [ ] Privacy settings work correctly
- [ ] Blocking functionality is effective
- [ ] Report system is functional
- [ ] Settings are properly enforced" \
  --label "user-story,messaging,privacy"

# User Story 5: File Sharing in Messages
echo "Creating User Story: File Sharing in Messages"
gh issue create --title "User Story: File Sharing in Messages" \
  --body "## User Story: File Sharing in Messages

**As a** user
**I want to** share files and media in private messages
**So that** I can share content with specific users

### Acceptance Criteria
- [ ] User can attach files to messages
- [ ] User can share images, documents, and other media
- [ ] Files are properly uploaded and stored
- [ ] Recipients can download and view shared files
- [ ] File size limits are enforced
- [ ] File types are validated for security

### Technical Requirements
- File upload functionality
- File storage in messaging canister
- File type validation
- File size limits
- File download functionality
- Media preview for images

### Definition of Done
- [ ] File sharing works reliably
- [ ] File security is maintained
- [ ] File previews work correctly
- [ ] Size and type limits are enforced" \
  --label "user-story,messaging,file-sharing"

# User Story 6: Real-time Notifications
echo "Creating User Story: Real-time Notifications"
gh issue create --title "User Story: Real-time Notifications" \
  --body "## User Story: Real-time Notifications

**As a** user
**I want to** receive notifications for new messages
**So that** I don't miss important communications

### Acceptance Criteria
- [ ] User receives browser notifications for new messages
- [ ] User receives in-app notifications
- [ ] Notifications show sender and message preview
- [ ] User can click notifications to open messages
- [ ] User can customize notification settings
- [ ] Notifications work when app is in background

### Technical Requirements
- Browser notification API integration
- In-app notification system
- Notification preferences management
- Background notification handling
- Notification click handling

### Definition of Done
- [ ] Notifications work reliably
- [ ] Notification settings are customizable
- [ ] Background notifications work
- [ ] Notification clicks work properly" \
  --label "user-story,messaging,notifications"

echo "✅ Created all user stories for Private Messaging Epic"
echo ""

# Update project status summary
echo "📊 Updated Project Status Summary:"
echo "=================================="
echo ""
echo "🏗️ Epics: $((EPIC_COUNT + 1)) (including new Private Messaging Epic)"
echo "📝 User Stories: $((STORY_COUNT + 6)) (including 6 new messaging stories)"
echo "📋 Total Issues: $((TOTAL_ISSUES + 7)) (including new epic and stories)"
echo ""
echo "🎯 New Focus: Private Messaging System"
echo "   - Epic #65: Private Messaging System"
echo "   - User Stories #66-71: Messaging functionality"
echo ""
echo "📈 Project Progress:"
echo "   - Authentication & Profiles: In Progress"
echo "   - Content Management: In Progress"
echo "   - Social Graph: In Progress"
echo "   - Private Messaging: New Priority"
echo ""
echo "🚀 Next Steps:"
echo "1. Add new epic and stories to project board"
echo "2. Prioritize private messaging development"
echo "3. Update sprint planning to include messaging features"
echo "4. Begin implementation of messaging canister"
echo ""
echo "✅ Analysis and updates completed successfully!" 