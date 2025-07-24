#!/bin/bash

# Comprehensive Project Status Report for ChainedSocial
# This script provides detailed analysis of current project state and recommendations

set -e

echo "📊 ChainedSocial Project Status Report"
echo "====================================="
echo "Generated: $(date)"
echo ""

# Get current project statistics
echo "📈 Project Statistics:"
echo "======================"

TOTAL_ISSUES=$(gh issue list --state all --json number | jq length)
OPEN_ISSUES=$(gh issue list --state open --json number | jq length)
CLOSED_ISSUES=$(gh issue list --state closed --json number | jq length)
EPICS=$(gh issue list --state open --label epic --json number | jq length)
USER_STORIES=$(gh issue list --state open --label "user-story" --json number | jq length)

echo "Total Issues: $TOTAL_ISSUES"
echo "Open Issues: $OPEN_ISSUES"
echo "Closed Issues: $CLOSED_ISSUES"
echo "Active Epics: $EPICS"
echo "Active User Stories: $USER_STORIES"
echo ""

# Epic Analysis
echo "🏗️ Epic Analysis:"
echo "================="

EPIC_LIST=$(gh issue list --state open --label epic --json number,title,labels)
echo "Current Epics:"
echo "$EPIC_LIST" | jq -r '.[] | "  \(.number): \(.title)"'
echo ""

# Progress by Epic
echo "📊 Progress by Epic:"
echo "===================="

# Authentication Epic Progress
AUTH_STORIES=$(gh issue list --state open --label "user-story,authentication" --json number | jq length)
echo "Epic #47 - Authentication & Profiles:"
echo "  User Stories: $AUTH_STORIES"
echo "  Status: In Progress"
echo ""

# Content Management Epic Progress
CONTENT_STORIES=$(gh issue list --state open --label "user-story,frontend" --json number | jq length)
echo "Epic #48 - Content Management:"
echo "  User Stories: $CONTENT_STORIES"
echo "  Status: In Progress"
echo ""

# Social Graph Epic Progress
SOCIAL_STORIES=$(gh issue list --state open --label "user-story,frontend" --json number | jq length)
echo "Epic #49 - Social Graph:"
echo "  User Stories: $SOCIAL_STORIES"
echo "  Status: In Progress"
echo ""

# Private Messaging Epic Progress
MESSAGING_STORIES=$(gh issue list --state open --label "user-story,messaging" --json number | jq length)
echo "Epic #64 - Private Messaging (NEW PRIORITY):"
echo "  User Stories: $MESSAGING_STORIES"
echo "  Status: New Priority"
echo ""

# Label Analysis
echo "🏷️ Issues by Category:"
echo "======================"
gh issue list --state open --json labels | jq -r '.[].labels[].name' | sort | uniq -c | sort -nr
echo ""

# Recent Activity
echo "🕒 Recent Activity:"
echo "=================="
RECENT_ISSUES=$(gh issue list --state open --limit 5 --json number,title,createdAt)
echo "Recent Issues:"
echo "$RECENT_ISSUES" | jq -r '.[] | "  \(.number): \(.title) (\(.createdAt))"'
echo ""

# Priority Analysis
echo "🎯 Priority Analysis:"
echo "===================="

HIGH_PRIORITY=$(gh issue list --state open --label "high-priority" --json number,title | jq length)
echo "High Priority Issues: $HIGH_PRIORITY"

if [ $HIGH_PRIORITY -gt 0 ]; then
    echo "High Priority Items:"
    gh issue list --state open --label "high-priority" --json number,title | jq -r '.[] | "  \(.number): \(.title)"'
fi
echo ""

# Technical Debt
echo "🔧 Technical Debt Analysis:"
echo "==========================="

TECH_DEBT=$(gh issue list --state open --label "enhancement" --json number,title | jq length)
echo "Enhancement Issues: $TECH_DEBT"
echo ""

# Recommendations
echo "💡 Recommendations:"
echo "=================="
echo ""
echo "🚀 Immediate Actions:"
echo "1. Prioritize Private Messaging Epic (#64) - This is the new focus"
echo "2. Begin implementation of messaging canister"
echo "3. Complete authentication system before messaging"
echo "4. Set up real-time messaging infrastructure"
echo ""
echo "📋 Sprint Planning:"
echo "1. Sprint 1: Complete authentication (Epic #47)"
echo "2. Sprint 2: Begin messaging canister development"
echo "3. Sprint 3: Implement messaging frontend"
echo "4. Sprint 4: Add privacy controls and notifications"
echo ""
echo "🔧 Technical Priorities:"
echo "1. Create messaging canister (backend/messaging.mo)"
echo "2. Implement WebSocket or polling for real-time updates"
echo "3. Add message encryption for privacy"
echo "4. Create messaging UI components"
echo "5. Implement file sharing in messages"
echo ""
echo "📊 Success Metrics:"
echo "1. Complete messaging epic by end of month"
echo "2. Achieve 80% test coverage for messaging features"
echo "3. User acceptance testing for messaging functionality"
echo "4. Performance testing for real-time messaging"
echo ""

# Project Health
echo "🏥 Project Health:"
echo "=================="

COMPLETION_RATE=$((CLOSED_ISSUES * 100 / TOTAL_ISSUES))
echo "Completion Rate: $COMPLETION_RATE%"

if [ $COMPLETION_RATE -gt 60 ]; then
    echo "✅ Project is progressing well"
elif [ $COMPLETION_RATE -gt 30 ]; then
    echo "⚠️ Project needs attention"
else
    echo "❌ Project needs immediate focus"
fi

echo ""
echo "📈 Velocity:"
echo "  Issues closed this week: $(gh issue list --state closed --json closedAt | jq -r '.[] | select(.closedAt > "'$(date -d '7 days ago' -Iseconds)'") | .closedAt' | wc -l)"
echo "  Issues created this week: $(gh issue list --state open --json createdAt | jq -r '.[] | select(.createdAt > "'$(date -d '7 days ago' -Iseconds)'") | .createdAt' | wc -l)"
echo ""

echo "✅ Project Status Report Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Review and prioritize the Private Messaging Epic"
echo "2. Update sprint planning to include messaging features"
echo "3. Begin technical implementation of messaging canister"
echo "4. Set up epic-story relationships in project board"
echo "5. Assign story points and team members"
echo ""
echo "💡 Project URL: https://github.com/users/miguelrfernandes/projects/1" 