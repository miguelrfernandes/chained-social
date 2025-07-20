#!/bin/bash

# Create user stories as sub-issues for epics
# This script creates detailed user stories with acceptance criteria

set -e

echo "📝 Creating user stories for epics..."

# Epic 1: User Authentication & Profiles - User Stories
echo "Creating user stories for Epic: User Authentication & Profiles"

gh issue create --title "User Story: NFID Authentication Integration" \
  --body "## User Story: NFID Authentication Integration

**As a** user
**I want to** authenticate securely using NFID
**So that** I can access the platform safely

### Acceptance Criteria
- [ ] User can click 'Login with NFID' button
- [ ] NFID popup opens with authentication options
- [ ] User can authenticate with Gmail, Apple, or other providers
- [ ] User receives a valid Internet Computer principal
- [ ] User is redirected back to the platform after authentication
- [ ] User session is properly established
- [ ] Authentication state persists across page refreshes

### Technical Requirements
- Integrate @nfid/embed library
- Handle authentication callbacks
- Store user principal securely
- Implement session management

### Definition of Done
- [ ] User can successfully authenticate
- [ ] Authentication works on all supported browsers
- [ ] Error handling is implemented
- [ ] Session timeout is configured
- [ ] Logout functionality works" \
  --label "user-story,authentication,frontend"

gh issue create --title "User Story: User Profile Creation" \
  --body "## User Story: User Profile Creation

**As a** newly authenticated user
**I want to** create my profile
**So that** I can personalize my presence on the platform

### Acceptance Criteria
- [ ] User can access profile creation form after first login
- [ ] User can set a display name
- [ ] User can add a bio/description
- [ ] User can upload a profile picture
- [ ] User can set privacy preferences
- [ ] Profile is saved to the backend
- [ ] Profile is displayed correctly

### Technical Requirements
- Create profile form component
- Implement file upload for profile pictures
- Store profile data in backend canister
- Handle profile validation

### Definition of Done
- [ ] Profile creation form is functional
- [ ] Profile data is stored securely
- [ ] Profile display works correctly
- [ ] Privacy settings are respected" \
  --label "user-story,authentication,frontend"

gh issue create --title "User Story: Profile Management" \
  --body "## User Story: Profile Management

**As a** user with an existing profile
**I want to** edit and manage my profile
**So that** I can keep my information up to date

### Acceptance Criteria
- [ ] User can access profile settings
- [ ] User can edit display name
- [ ] User can update bio/description
- [ ] User can change profile picture
- [ ] User can update privacy settings
- [ ] Changes are saved immediately
- [ ] User receives confirmation of changes

### Technical Requirements
- Create profile management interface
- Implement real-time updates
- Handle profile data validation
- Update backend canister

### Definition of Done
- [ ] Profile editing works smoothly
- [ ] Changes are saved reliably
- [ ] User feedback is provided
- [ ] Profile updates are reflected immediately" \
  --label "user-story,authentication,frontend"

# Epic 2: Content Management System - User Stories
echo "Creating user stories for Epic: Content Management System"

gh issue create --title "User Story: Create New Post" \
  --body "## User Story: Create New Post

**As a** user
**I want to** create a new post
**So that** I can share content with the community

### Acceptance Criteria
- [ ] User can access post creation form
- [ ] User can write text content
- [ ] User can add media (images, videos)
- [ ] User can set post visibility (public/private)
- [ ] User can add tags/categories
- [ ] Post is published successfully
- [ ] Post appears in user's feed

### Technical Requirements
- Create post composition interface
- Implement media upload functionality
- Store post data in content canister
- Handle post validation and moderation

### Definition of Done
- [ ] Post creation is intuitive
- [ ] Media upload works reliably
- [ ] Posts are stored correctly
- [ ] Post appears in feeds immediately" \
  --label "user-story,enhancement,frontend"

gh issue create --title "User Story: Edit and Delete Posts" \
  --body "## User Story: Edit and Delete Posts

**As a** post author
**I want to** edit or delete my posts
**So that** I can maintain control over my content

### Acceptance Criteria
- [ ] User can edit their own posts
- [ ] User can delete their own posts
- [ ] Edit history is tracked
- [ ] Deleted posts are removed from feeds
- [ ] Users cannot edit/delete others' posts
- [ ] Changes are reflected immediately

### Technical Requirements
- Implement post editing interface
- Add delete confirmation dialog
- Update content canister with edit/delete functions
- Handle permissions and access control

### Definition of Done
- [ ] Post editing works smoothly
- [ ] Delete functionality is secure
- [ ] Changes are reflected immediately
- [ ] Permissions are properly enforced" \
  --label "user-story,enhancement,frontend"

# Epic 3: Social Graph & Relationships - User Stories
echo "Creating user stories for Epic: Social Graph & Relationships"

gh issue create --title "User Story: Follow Other Users" \
  --body "## User Story: Follow Other Users

**As a** user
**I want to** follow other users
**So that** I can see their content in my feed

### Acceptance Criteria
- [ ] User can click 'Follow' button on profiles
- [ ] Follow action is recorded in social graph
- [ ] User receives confirmation of follow
- [ ] Followed users' content appears in feed
- [ ] User can see their following list
- [ ] User can see their followers list

### Technical Requirements
- Implement follow/unfollow functionality
- Update social graph canister
- Create following/followers lists
- Update feed algorithm

### Definition of Done
- [ ] Follow functionality works correctly
- [ ] Social graph is updated properly
- [ ] Feed shows followed users' content
- [ ] Lists are displayed correctly" \
  --label "user-story,enhancement,frontend"

gh issue create --title "User Story: Social Feed" \
  --body "## User Story: Social Feed

**As a** user
**I want to** see a personalized feed
**So that** I can discover relevant content

### Acceptance Criteria
- [ ] Feed shows posts from followed users
- [ ] Feed is sorted by relevance/date
- [ ] User can scroll through feed
- [ ] Feed loads more content on scroll
- [ ] Feed updates in real-time
- [ ] User can interact with posts in feed

### Technical Requirements
- Implement feed algorithm
- Create infinite scroll functionality
- Add real-time updates
- Handle feed performance optimization

### Definition of Done
- [ ] Feed loads quickly
- [ ] Content is relevant and fresh
- [ ] Infinite scroll works smoothly
- [ ] Real-time updates function properly" \
  --label "user-story,enhancement,frontend"

# Epic 4: Platform Infrastructure - User Stories
echo "Creating user stories for Epic: Platform Infrastructure"

gh issue create --title "User Story: Optimize CI Pipeline" \
  --body "## User Story: Optimize CI Pipeline

**As a** developer
**I want to** have a fast and reliable CI pipeline
**So that** I can deploy changes quickly and safely

### Acceptance Criteria
- [ ] CI builds complete in under 5 minutes
- [ ] CI cache is properly utilized
- [ ] Build failures are clearly reported
- [ ] CI runs on all PRs automatically
- [ ] Deployment to playground is automated
- [ ] Build artifacts are cached efficiently

### Technical Requirements
- Optimize CI store caching
- Improve build time with parallel builds
- Add comprehensive error reporting
- Implement automated deployment

### Definition of Done
- [ ] Build times are under 5 minutes
- [ ] Cache hit rate is >80%
- [ ] Error reporting is clear and actionable
- [ ] Deployment is fully automated" \
  --label "user-story,enhancement,ci/cd"

gh issue create --title "User Story: Monitoring and Alerting" \
  --body "## User Story: Monitoring and Alerting

**As a** platform operator
**I want to** monitor system health and performance
**So that** I can respond to issues quickly

### Acceptance Criteria
- [ ] System metrics are collected
- [ ] Performance alerts are configured
- [ ] Error rates are monitored
- [ ] Uptime is tracked
- [ ] Alerts are sent to appropriate channels
- [ ] Dashboard shows real-time metrics

### Technical Requirements
- Implement metrics collection
- Set up monitoring infrastructure
- Configure alerting rules
- Create monitoring dashboard

### Definition of Done
- [ ] All critical metrics are monitored
- [ ] Alerts are sent promptly
- [ ] Dashboard provides clear insights
- [ ] False positives are minimized" \
  --label "user-story,enhancement,ci/cd"

echo "✅ User stories created successfully!"
echo ""
echo "📋 Summary:"
echo "- Created 8 epics covering all major features"
echo "- Created 9 user stories with detailed acceptance criteria"
echo "- Each user story has clear definition of done"
echo ""
echo "🎯 Next steps:"
echo "1. Add epics and user stories to the project board"
echo "2. Set up epic-story relationships"
echo "3. Assign story points and priorities"
echo "4. Create sprint planning" 