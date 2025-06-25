#!/bin/bash
# Evening Journal Summary - Reflection Focus
# Adds comprehensive daily summary with actual accomplishments

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$SCRIPT_DIR/../logs"
TODAY=$(date +%Y-%m-%d)
JOURNAL_FILE="$JOURNAL_DIR/$TODAY.md"
CURSOR_LOGS_DIR="$HOME/Development/tools/cursor-logging/logs"
TEMP_EVENING_FILE="/tmp/evening-summary-$TODAY.txt"

echo "🌅 Adding evening summary to journal for $TODAY..."

# Check if journal exists
if [ ! -f "$JOURNAL_FILE" ]; then
    echo "❌ Morning journal not found. Creating full journal now..."
    ~/Development/tools/daily-work-journal/scripts/daily-journal-generator.sh
fi

# Create evening summary content
cat > "$TEMP_EVENING_FILE" << 'EOF'

---

## 🌆 EVENING SUMMARY - ACTUAL ACCOMPLISHMENTS

*Added at end of day with real data and reflection*

## ✅ What Actually Got Done

### Completed Todos
EOF

# Extract completed todos from the journal
grep -E "^- \[x\]" "$JOURNAL_FILE" 2>/dev/null >> "$TEMP_EVENING_FILE" || echo "- [x] (Mark completed items above)" >> "$TEMP_EVENING_FILE"

cat >> "$TEMP_EVENING_FILE" << 'EOF'

### Unexpected Accomplishments
- 
- 

## 💻 Actual Cursor Activity

### Development Work Summary
EOF

# Include real Cursor activity if available
if [ -f "$CURSOR_LOGS_DIR/cursor-activity-$TODAY.md" ]; then
    echo "*Captured from today's Cursor activity:*" >> "$TEMP_EVENING_FILE"
    echo "" >> "$TEMP_EVENING_FILE"
    
    # Extract key sections from cursor log
    echo "**Files Modified Today:**" >> "$TEMP_EVENING_FILE"
    grep -A 10 "### Files changed in last 24 hours" "$CURSOR_LOGS_DIR/cursor-activity-$TODAY.md" 2>/dev/null | grep "^- \`" | head -10 >> "$TEMP_EVENING_FILE" || echo "- No files modified today" >> "$TEMP_EVENING_FILE"
    
    echo "" >> "$TEMP_EVENING_FILE"
    echo "**Git Commits Made:**" >> "$TEMP_EVENING_FILE"
    grep -A 20 "### Git Repositories with Changes" "$CURSOR_LOGS_DIR/cursor-activity-$TODAY.md" 2>/dev/null | grep -E "^####|^- \*\*|^  -" | head -15 >> "$TEMP_EVENING_FILE" || echo "- No commits made today" >> "$TEMP_EVENING_FILE"
    
    echo "" >> "$TEMP_EVENING_FILE"
    echo "**Terminal Commands Run:**" >> "$TEMP_EVENING_FILE"
    grep -A 10 "### Recent terminal commands" "$CURSOR_LOGS_DIR/cursor-activity-$TODAY.md" 2>/dev/null | grep "^- \`" | head -8 >> "$TEMP_EVENING_FILE" || echo "- No terminal activity captured" >> "$TEMP_EVENING_FILE"
else
    echo "*Cursor activity log not available for today*" >> "$TEMP_EVENING_FILE"
    echo "" >> "$TEMP_EVENING_FILE"
    echo "**Manual Development Summary:**" >> "$TEMP_EVENING_FILE"
    echo "- " >> "$TEMP_EVENING_FILE"
    echo "- " >> "$TEMP_EVENING_FILE"
fi

cat >> "$TEMP_EVENING_FILE" << 'EOF'

### Projects Actually Worked On
- 
- 

### Technologies/Tools Used
- 
- 

## 💬 Actual Slack Activity

### Key Conversations Had
EOF

# Add Slack MCP commands for evening context
cat >> "$TEMP_EVENING_FILE" << EOF
*(Use Slack MCP to capture today's actual conversations)*

\`\`\`bash
# Run these in Cursor to populate actual Slack activity:
# 1. Get all my messages from today
# 2. Search for responses to my questions  
# 3. Check for feedback received on work
# 4. Look for new action items created
\`\`\`

### Team Feedback Received
- 

### New Action Items Created
- [ ] 
- [ ] 

### Decisions Made in Slack
- 

## 🧠 Real Learning & Insights

### What I Actually Learned
- 
- 

### Technical Discoveries Made
- 
- 

### Process Improvements Identified
- 
- 

### Resources Found/Bookmarked
- 

## 🚧 Actual Challenges Faced

### Problems Encountered
- 

### Solutions Implemented
- 

### Still Stuck On
- 

### Help Requested/Received
- 

## 🎉 Real Wins & Achievements

### Major Accomplishments
- 

### Milestones Reached
- 

### Positive Feedback Received
- 

### Problems Solved for Others
- 

## 🤔 End of Day Reflection

### What Went Better Than Expected
- 

### What Was Harder Than Expected
- 

### What Would I Do Differently
- 

### Energy Level: ___/10

### Satisfaction Level: ___/10

## 📅 Tomorrow's Setup

### Top 3 Priorities for Tomorrow
- [ ] 
- [ ] 
- [ ] 

### Meetings Scheduled
- 

### Blockers to Address First Thing
- 

### Context to Remember
- 

---

**Evening Summary Completed:** $(date '+%Y-%m-%d %H:%M:%S')
**Total Work Hours:** ___
**Key Focus Areas:** 
**Tomorrow's First Task:** 

EOF

echo "📝 Adding evening summary to journal..."

# Append evening summary to journal
cat "$TEMP_EVENING_FILE" >> "$JOURNAL_FILE"

# Cleanup
rm "$TEMP_EVENING_FILE"

echo "✅ Evening summary added to: $JOURNAL_FILE"
echo "📊 Journal now includes both planning and actual accomplishments"
echo "🔗 Open with: cursor '$JOURNAL_FILE'"
echo ""
echo "📱 Next steps:"
echo "   1. Use Slack MCP to populate actual team interactions"
echo "   2. Fill in reflection sections with real insights"
echo "   3. Set tomorrow's priorities based on today's learnings"
echo "   4. Note any context to remember for tomorrow" 