#!/bin/bash
# Slack Context Populator for Daily Journal
# Uses Slack MCP to gather team context and communications

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$SCRIPT_DIR/../logs"
TODAY=$(date +%Y-%m-%d)
JOURNAL_FILE="$JOURNAL_DIR/$TODAY.md"
TEMP_SLACK_FILE="/tmp/slack-context-$TODAY.txt"

echo "📱 Gathering Slack context for $TODAY..."

# Check if journal exists
if [ ! -f "$JOURNAL_FILE" ]; then
    echo "❌ Journal file not found: $JOURNAL_FILE"
    echo "Run daily-journal-generator.sh first"
    exit 1
fi

# Create temporary file for Slack data
> "$TEMP_SLACK_FILE"

echo "🔍 Fetching Slack data..."

# Function to add Slack data to temp file
add_slack_data() {
    echo "" >> "$TEMP_SLACK_FILE"
    echo "$1" >> "$TEMP_SLACK_FILE"
    echo "" >> "$TEMP_SLACK_FILE"
}

# Gather Slack context (these would be actual MCP calls in Cursor)
add_slack_data "### My Messages from Today"
add_slack_data "*(Run in Cursor: Use Slack MCP to fetch my messages from today)*"
add_slack_data "- Use: \`mcp_slack-tools-mcp_slack_my_messages\` with since=\"$TODAY\""

add_slack_data "### Mentions of My Projects"
add_slack_data "*(Run in Cursor: Search for mentions of your current projects)*"
add_slack_data "- Use: \`mcp_slack-tools-mcp_slack_search\` with query=\"escalation analysis\""
add_slack_data "- Use: \`mcp_slack-tools-mcp_slack_search\` with query=\"cursor logging\""
add_slack_data "- Use: \`mcp_slack-tools-mcp_slack_search\` with query=\"daily journal\""

add_slack_data "### Team Feedback on Tools"
add_slack_data "*(Run in Cursor: Search for feedback on tools you've built)*"
add_slack_data "- Use: \`mcp_slack-tools-mcp_slack_search\` with query=\"from:@me has:link\""
add_slack_data "- Use: \`mcp_slack-tools-mcp_slack_search\` with query=\"markgroche tool\""

add_slack_data "### Current Status"
add_slack_data "*(Run in Cursor: Check your current Slack status)*"
add_slack_data "- Use: \`mcp_slack-tools-mcp_slack_get_status\`"

add_slack_data "### Reminders & Follow-ups"
add_slack_data "*(Check for any reminders or scheduled follow-ups)*"

# Instructions for manual population
cat >> "$TEMP_SLACK_FILE" << 'EOF'

## 🤖 Slack MCP Commands to Run in Cursor

Copy and paste these commands in Cursor to populate your Slack context:

### 1. Get My Messages from Today
```
Use the Slack MCP tool to fetch my messages from today
```

### 2. Search for Project Mentions
```
Search Slack for mentions of "escalation analysis" 
Search Slack for mentions of "cursor logging"
Search Slack for mentions of "daily journal"
```

### 3. Check Team Feedback
```
Search for messages containing "markgroche" and "tool"
Search for messages from me that contain links (tools I've shared)
```

### 4. Get Current Status
```
Get my current Slack status and any active reminders
```

### 5. Look for Action Items
```
Search for messages containing "TODO" or "action item" or "follow up"
```

## 📋 Manual Steps After Running MCP Commands

1. Copy relevant information from MCP results
2. Update the journal sections:
   - Key Conversations
   - Team Feedback on My Work  
   - Action Items from Slack
3. Note any important context or decisions
4. Identify follow-up actions needed

EOF

echo "📝 Updating journal with Slack context template..."

# Find the Slack Context section and replace it
if grep -q "## 💬 Slack Context" "$JOURNAL_FILE"; then
    # Create a backup
    cp "$JOURNAL_FILE" "$JOURNAL_FILE.backup"
    
    # Use awk to replace the Slack Context section
    awk '
    /^## 💬 Slack Context/ {
        print $0
        print ""
        while ((getline line < "'$TEMP_SLACK_FILE'") > 0) {
            print line
        }
        close("'$TEMP_SLACK_FILE'")
        # Skip until next section
        while (getline && !/^## /) continue
        if (/^## /) print $0
        next
    }
    { print }
    ' "$JOURNAL_FILE.backup" > "$JOURNAL_FILE"
    
    rm "$JOURNAL_FILE.backup"
    echo "✅ Slack context section updated in journal"
else
    echo "❌ Could not find Slack Context section in journal"
    exit 1
fi

# Cleanup
rm "$TEMP_SLACK_FILE"

echo ""
echo "🎯 Next Steps:"
echo "   1. Open journal: cursor '$JOURNAL_FILE'"
echo "   2. Run the Slack MCP commands listed in the journal"
echo "   3. Copy results into the appropriate sections"
echo "   4. Update throughout the day as you work"
echo ""
echo "📱 Slack MCP is configured and ready to use!" 