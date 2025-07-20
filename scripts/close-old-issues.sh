#!/bin/bash

# Close old duplicate issues that have been migrated to epics and user stories
# These issues (18-31) are duplicates of the new organized structure

set -e

echo "🗑️ Closing old duplicate issues that have been migrated to epics..."

# Old issues that are now covered by epics and user stories
OLD_ISSUES=(18 19 20 21 22 23 24 25 26 27 28 29 30 31)

for issue in "${OLD_ISSUES[@]}"; do
    echo "Closing old issue #$issue (migrated to epics/user stories)..."
    gh issue close $issue --reason "completed" --comment "This issue has been migrated to the new epic and user story structure. The functionality is now properly organized in epics with detailed user stories and acceptance criteria."
done

echo "✅ Closed all old duplicate issues!"
echo ""
echo "📋 Migration Summary:"
echo "- Issues 18-31: Closed (migrated to epics)"
echo "- Epics 47-54: Created (comprehensive feature organization)"
echo "- User Stories 55-63: Created (detailed implementation tasks)"
echo ""
echo "🎯 Current Structure:"
echo "- 8 Epics covering all major features"
echo "- 9 User Stories with acceptance criteria"
echo "- Proper epic-story relationships"
echo "- Clear definition of done for each story" 