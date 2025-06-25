#!/bin/bash
# Morning Journal Setup - Planning Focus
# Creates today's journal structure with planning sections

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$SCRIPT_DIR/../logs"
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d)
JOURNAL_FILE="$JOURNAL_DIR/$TODAY.md"

# Ensure journal directory exists
mkdir -p "$JOURNAL_DIR"

echo "🌅 Setting up daily journal for $TODAY..."

# Start the journal with header and planning focus
cat > "$JOURNAL_FILE" << EOF
# Daily Work Journal - $TODAY

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')  
**Day:** $(date '+%A')  
**Week:** Week $(date '+%U') of $(date '+%Y')

---

## 📊 Daily Summary

**Status:** Planning  
**Focus Areas:** 
**Key Goals for Today:** 
**Expected Challenges:** 

## 📋 Today's Plan

### Priorities (Carried Over + New)
EOF

# Carry over incomplete todos from yesterday
if [ -f "$JOURNAL_DIR/$YESTERDAY.md" ]; then
    echo "**From yesterday:**" >> "$JOURNAL_FILE"
    # Look for incomplete todos in various sections
    grep -E "^- \[ \]" "$JOURNAL_DIR/$YESTERDAY.md" 2>/dev/null | head -10 >> "$JOURNAL_FILE" || echo "- [ ] (No open todos from yesterday)" >> "$JOURNAL_FILE"
else
    echo "- [ ] (No previous journal found)" >> "$JOURNAL_FILE"
fi

cat >> "$JOURNAL_FILE" << 'EOF'

**New for today:**
- [ ] 
- [ ] 
- [ ] 

### Time Blocks
- **9:00-11:00**: 
- **11:00-13:00**: 
- **13:00-15:00**: 
- **15:00-17:00**: 

### Expected Meetings
- 

### Key Projects to Advance
- 

## 💬 Slack Context (To Fill Later)

### Team Priorities for Today
*(Use Slack MCP to check for urgent items)*

### Action Items from Yesterday
*(Check Slack for follow-ups)*

## 🎯 Success Metrics for Today

### Must Complete
- [ ] 
- [ ] 

### Would Like to Complete  
- [ ] 
- [ ] 

### Learning Goals
- 

---

*This is the morning planning version. Evening summary will be added at 5 PM.*
*Use: `journal-evening` to populate with actual accomplishments*

EOF

echo "✅ Morning journal setup complete: $JOURNAL_FILE"
echo "📝 Focus: Planning and priority setting"
echo "🔗 Open with: cursor '$JOURNAL_FILE'" 