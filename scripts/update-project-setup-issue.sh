#!/bin/bash

# Update issue #17 with comprehensive details about project setup and automation

set -e

echo "📋 Updating issue #17 with comprehensive project setup details..."

# Update the issue with detailed description
gh issue edit 17 --body "## 🎯 Project Setup and Automation Configuration

### 📊 **Project Board Structure**

#### **Required Columns:**
1. **📋 Backlog** - New epics and user stories
2. **🎯 Ready for Development** - Prioritized and refined stories
3. **🔄 In Progress** - Currently being worked on
4. **👀 Review** - Ready for code review and testing
5. **✅ Done** - Completed and deployed

#### **Optional Columns:**
- **🚀 Sprint Planning** - Stories selected for current sprint
- **🐛 Bug Fixes** - Issues and bugs to address
- **📚 Documentation** - Documentation tasks
- **🔧 Technical Debt** - Refactoring and improvements

### ⚙️ **Automation Workflows**

#### **Issue Automation:**
- **Auto-assign labels** based on issue type (epic, user-story, bug, etc.)
- **Auto-move to Ready** when epic is created and user stories are added
- **Auto-assign to project** when new issues are created with specific labels

#### **Pull Request Automation:**
- **Auto-move to In Progress** when PR is created
- **Auto-move to Review** when PR is ready for review
- **Auto-move to Done** when PR is merged

#### **Sprint Management:**
- **Sprint planning automation** - Move selected stories to Sprint Planning
- **Sprint completion** - Move completed stories to Done
- **Sprint retrospective** - Archive completed sprint items

### 🏷️ **Label Management**

#### **Required Labels:**
- `epic` - Large feature groups
- `user-story` - Individual implementation tasks
- `bug` - Issues and bugs
- `documentation` - Documentation tasks
- `technical-debt` - Refactoring needs
- `enhancement` - Feature improvements
- `priority:high` - High priority items
- `priority:medium` - Medium priority items
- `priority:low` - Low priority items

#### **Status Labels:**
- `ready-for-dev` - Ready to be worked on
- `in-progress` - Currently being developed
- `review-needed` - Ready for review
- `blocked` - Blocked by dependencies
- `sprint-ready` - Selected for current sprint

### 📈 **Metrics and Reporting**

#### **Project Metrics:**
- **Velocity tracking** - Stories completed per sprint
- **Cycle time** - Time from Ready to Done
- **Lead time** - Time from creation to completion
- **Burndown charts** - Sprint progress visualization

#### **Automated Reports:**
- **Weekly progress** - Stories moved to Done
- **Sprint summary** - Completed vs planned stories
- **Blocked items** - Items stuck in progress
- **Technical debt** - Accumulated debt items

### 🔄 **Workflow Rules**

#### **Epic Workflow:**
1. Create epic → Add to Backlog
2. Add user stories → Auto-assign to epic
3. Prioritize stories → Move to Ready for Development
4. Epic complete → Move all stories to Done

#### **User Story Workflow:**
1. Create story → Add to Backlog
2. Refine story → Move to Ready for Development
3. Start work → Move to In Progress
4. Ready for review → Move to Review
5. Complete → Move to Done

#### **Bug Workflow:**
1. Report bug → Add to Backlog
2. Prioritize → Move to Ready for Development
3. Fix bug → Move to In Progress
4. Test fix → Move to Review
5. Deploy fix → Move to Done

### 🎨 **Custom Fields (Optional)**

#### **Story Points:**
- Add custom field for story point estimation
- Track velocity based on story points
- Use Fibonacci sequence (1, 2, 3, 5, 8, 13)

#### **Sprint Assignment:**
- Add custom field for sprint assignment
- Track sprint progress and completion
- Generate sprint reports

#### **Assignee Tracking:**
- Track who is working on what
- Balance workload across team members
- Identify bottlenecks

### 📋 **Acceptance Criteria**

- [ ] **Project columns created** with proper workflow stages
- [ ] **Automation rules configured** for issue and PR movement
- [ ] **Labels created and applied** to all existing items
- [ ] **Workflow documentation** created for team reference
- [ ] **Metrics dashboard** configured for tracking progress
- [ ] **Sprint planning process** established
- [ ] **Team training** completed on new workflow
- [ ] **Automated reports** configured and tested

### 🚀 **Next Steps**

1. **Set up columns** in GitHub Projects
2. **Configure automation** using GitHub Actions or third-party tools
3. **Create labels** and apply to existing items
4. **Document workflow** for team reference
5. **Train team** on new process
6. **Monitor and iterate** based on team feedback

### 📚 **Resources**

- [GitHub Projects Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [GitHub Actions for Automation](https://docs.github.com/en/actions)
- [Agile Project Management Best Practices](https://www.atlassian.com/agile)
- [Scrum Framework Guide](https://scrumguides.org/scrum-guide.html)"

echo "✅ Updated issue #17 with comprehensive project setup details!" 