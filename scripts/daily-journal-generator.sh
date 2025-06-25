#!/bin/bash
# Daily Work Journal Generator
# Comprehensive logging of all daily work activities

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$SCRIPT_DIR/../logs"
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d)
JOURNAL_FILE="$JOURNAL_DIR/$TODAY.md"
CURSOR_LOGS_DIR="$HOME/Development/tools/cursor-logging/logs"

# Ensure journal directory exists
mkdir -p "$JOURNAL_DIR"

# Function to add section to journal
add_section() {
    echo "" >> "$JOURNAL_FILE"
    echo "## $1" >> "$JOURNAL_FILE"
    echo "" >> "$JOURNAL_FILE"
}

# Function to add subsection
add_subsection() {
    echo "" >> "$JOURNAL_FILE"
    echo "### $1" >> "$JOURNAL_FILE"
    echo "" >> "$JOURNAL_FILE"
}

echo "🚀 Generating Daily Work Journal for $TODAY..."

# Start the journal with header
cat > "$JOURNAL_FILE" << EOF
# Daily Work Journal - $TODAY

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')  
**Day:** $(date '+%A')  
**Week:** Week $(date '+%U') of $(date '+%Y')

---

## 📊 Daily Summary

**Status:** In Progress  
**Focus Areas:** 
**Key Achievements:** 
**Blockers:** 

EOF

# 1. TODOS SECTION (carry over from yesterday + new)
add_section "📋 Todos"
echo "### Today's Priorities" >> "$JOURNAL_FILE"
if [ -f "$JOURNAL_DIR/$YESTERDAY.md" ]; then
    echo "**Carried over from yesterday:**" >> "$JOURNAL_FILE"
    grep -A 20 "### Today's Priorities\|### Tomorrow's Priorities" "$JOURNAL_DIR/$YESTERDAY.md" 2>/dev/null | grep "^- \[ \]" | head -10 >> "$JOURNAL_FILE" || echo "- [ ] (No open todos from yesterday)" >> "$JOURNAL_FILE"
else
    echo "- [ ] (No previous journal found)" >> "$JOURNAL_FILE"
fi

echo "" >> "$JOURNAL_FILE"
echo "**New priorities for today:**" >> "$JOURNAL_FILE"
echo "- [ ] " >> "$JOURNAL_FILE"
echo "- [ ] " >> "$JOURNAL_FILE"
echo "- [ ] " >> "$JOURNAL_FILE"

add_subsection "Completed Today"
echo "- [x] Generated daily journal" >> "$JOURNAL_FILE"

# 2. CURSOR ACTIVITY SECTION
add_section "💻 Cursor Activity"

# Include Cursor logging data if available
if [ -f "$CURSOR_LOGS_DIR/cursor-activity-$TODAY.md" ]; then
    echo "### Development Work" >> "$JOURNAL_FILE"
    echo "*Automatically captured from Cursor activity:*" >> "$JOURNAL_FILE"
    echo "" >> "$JOURNAL_FILE"
    
    # Extract key sections from cursor log
    echo "**Recently Modified Files:**" >> "$JOURNAL_FILE"
    grep -A 10 "### Files changed in last 24 hours" "$CURSOR_LOGS_DIR/cursor-activity-$TODAY.md" 2>/dev/null | grep "^- \`" | head -10 >> "$JOURNAL_FILE" || echo "- No files modified today" >> "$JOURNAL_FILE"
    
    echo "" >> "$JOURNAL_FILE"
    echo "**Git Activity:**" >> "$JOURNAL_FILE"
    grep -A 20 "### Git Repositories with Changes" "$CURSOR_LOGS_DIR/cursor-activity-$TODAY.md" 2>/dev/null | grep -E "^####|^- \*\*|^  -" | head -15 >> "$JOURNAL_FILE" || echo "- No git activity today" >> "$JOURNAL_FILE"
else
    echo "### Development Work" >> "$JOURNAL_FILE"
    echo "*Cursor activity log not available for today*" >> "$JOURNAL_FILE"
fi

add_subsection "Projects Worked On"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Code Changes & Commits"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Tools & Technologies Used"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

# 3. SLACK CONTEXT SECTION
add_section "💬 Slack Context"

echo "### Team Communications" >> "$JOURNAL_FILE"
echo "*Use Slack MCP to gather today's context:*" >> "$JOURNAL_FILE"
echo "" >> "$JOURNAL_FILE"
echo '```bash' >> "$JOURNAL_FILE"
echo "# Run these commands in Cursor to populate Slack context:" >> "$JOURNAL_FILE"
echo "# 1. Check my messages from today" >> "$JOURNAL_FILE"
echo "# 2. Search for mentions of my projects" >> "$JOURNAL_FILE"
echo "# 3. Look for feedback on tools I've built" >> "$JOURNAL_FILE"
echo '```' >> "$JOURNAL_FILE"

add_subsection "Key Conversations"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Team Feedback on My Work"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Action Items from Slack"
echo "- [ ] " >> "$JOURNAL_FILE"
echo "- [ ] " >> "$JOURNAL_FILE"

# 4. MEETINGS & COLLABORATION
add_section "🤝 Meetings & Collaboration"

add_subsection "Meetings Attended"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Key Decisions Made"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Collaboration Highlights"
echo "- " >> "$JOURNAL_FILE"

# 5. LEARNING & INSIGHTS
add_section "🧠 Learning & Insights"

add_subsection "New Things Learned"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Technical Discoveries"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Process Improvements"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Tools & Resources Found"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

# 6. CHALLENGES & BLOCKERS
add_section "🚧 Challenges & Blockers"

add_subsection "Issues Encountered"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Solutions Found"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Still Blocked On"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Help Needed"
echo "- " >> "$JOURNAL_FILE"

# 7. ACHIEVEMENTS & WINS
add_section "🎉 Achievements & Wins"

add_subsection "Completed Tasks"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Milestones Reached"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Positive Feedback Received"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Problems Solved"
echo "- " >> "$JOURNAL_FILE"

# 8. REFLECTION & PLANNING
add_section "🤔 Reflection & Planning"

add_subsection "What Went Well Today"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

add_subsection "What Could Be Improved"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Tomorrow's Priorities"
echo "- [ ] " >> "$JOURNAL_FILE"
echo "- [ ] " >> "$JOURNAL_FILE"
echo "- [ ] " >> "$JOURNAL_FILE"

add_subsection "Week Ahead Planning"
echo "- " >> "$JOURNAL_FILE"
echo "- " >> "$JOURNAL_FILE"

# 9. NOTES & MISCELLANEOUS
add_section "📝 Notes & Miscellaneous"

add_subsection "Random Thoughts"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Ideas for Future"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Links & Resources to Remember"
echo "- " >> "$JOURNAL_FILE"

add_subsection "Follow-up Items"
echo "- [ ] " >> "$JOURNAL_FILE"

# Footer
echo "" >> "$JOURNAL_FILE"
echo "---" >> "$JOURNAL_FILE"
echo "" >> "$JOURNAL_FILE"
echo "**Journal Links:**" >> "$JOURNAL_FILE"
echo "- **Yesterday:** [$YESTERDAY.md]($YESTERDAY.md)" >> "$JOURNAL_FILE"
echo "- **Tomorrow:** [$(date -v+1d +%Y-%m-%d).md]($(date -v+1d +%Y-%m-%d).md)" >> "$JOURNAL_FILE"
echo "- **This Week:** [$(date +%Y-W%U) journals](../)" >> "$JOURNAL_FILE"
echo "" >> "$JOURNAL_FILE"
echo "*Generated automatically by daily-journal-generator.sh*" >> "$JOURNAL_FILE"
echo "*Last updated: $(date '+%Y-%m-%d %H:%M:%S')*" >> "$JOURNAL_FILE"

# Output summary
echo "✅ Daily work journal created: $JOURNAL_FILE"
echo "📊 Journal size: $(wc -l < "$JOURNAL_FILE") lines"
echo "🔗 Open with: cursor '$JOURNAL_FILE'"
echo ""
echo "📋 Next steps:"
echo "   1. Open the journal in Cursor"
echo "   2. Use Slack MCP to populate team context"
echo "   3. Fill in your daily activities and reflections"
echo "   4. Update throughout the day as you work" 