#!/bin/bash
# Automated Slack Journal Update Script
# Integrates with Cursor to run MCP commands and update journal with timestamps

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$SCRIPT_DIR/../logs"
TODAY=$(date +%Y-%m-%d)
JOURNAL_FILE="$JOURNAL_DIR/$TODAY.md"
SLACK_TEMP_FILE="/tmp/slack-update-$TODAY.md"
CURSOR_WORKSPACE="$HOME/Cursor Projects"
TIMESTAMP_MANAGER="$SCRIPT_DIR/journal-timestamp-manager.sh"

# Source timestamp manager functions
if [ -f "$TIMESTAMP_MANAGER" ]; then
    chmod +x "$TIMESTAMP_MANAGER"
else
    echo "❌ Timestamp manager not found at $TIMESTAMP_MANAGER"
    exit 1
fi

# Enhanced logging function with timestamps
log_automation() {
    local message="$1"
    local level="${2:-INFO}"
    echo "[$level] $message" | tee -a "$JOURNAL_DIR/slack-automation.log"
    "$TIMESTAMP_MANAGER" log "$message" "SLACK_AUTOMATION"
}

log_automation "🚀 Starting automated Slack journal update for $TODAY..." "START"

# Function to check if interactive mode is requested
check_interactive_mode() {
    local interactive="${1:-auto}"
    
    if [[ "$interactive" == "--interactive" || "$interactive" == "-i" ]]; then
        log_automation "🎯 Interactive mode - opening immediately" "MODE"
        return 0
    elif [[ "$interactive" == "--quick" || "$interactive" == "-q" ]]; then
        log_automation "⚡ Quick mode - generating instructions only" "MODE"
        return 1
    else
        log_automation "🤖 Auto mode - attempting automation" "MODE"
        return 2
    fi
}

# Function to create smart MCP instructions with timestamps
create_smart_instructions() {
    log_automation "📝 Updating journal with smart instructions..." "UPDATE"
    
    # Use timestamp manager to update Slack Context section
    local slack_instructions=$(cat << 'EOF'
### 🤖 Automated Update Status
**Updated:** $(date '+%Y-%m-%d %H:%M:%S')  
**Status:** 🟡 Waiting for you - run when you're back at your computer

**Quick Action:**
```bash
# If you want to run this manually right now:
cd "$(pwd)" && ./slack-auto-update.sh --interactive
```

### 📱 MCP Commands Ready to Run

**Copy and paste these one by one in Cursor:**

1️⃣ **Get today's messages:**
```
Use mcp_slack-tools-mcp_slack_my_messages with since="$TODAY" and count=200
```

2️⃣ **Search for your projects:**
```
Search Slack for "escalation analysis"
Search Slack for "cursor logging"  
Search Slack for "daily journal"
```

3️⃣ **Check your status:**
```
Use mcp_slack-tools-mcp_slack_get_status
```

4️⃣ **Find action items:**
```
Search for 'TODO OR "action item" OR "follow up"'
```

### 📋 After Running MCP Commands

**Update these sections with your results:**

#### My Messages from Today
*(Paste MCP results here)*

#### Project Mentions Found
*(Paste search results here)*

#### Current Slack Status
*(Paste status here)*

#### Action Items Discovered
*(Paste action items here)*

---
**💡 Tip:** After updating, run `./slack-auto-update.sh --mark-complete` to log completion
EOF
)

    # Update the Slack Context section with timestamps
    "$TIMESTAMP_MANAGER" update-section "💬 Slack Context" "$slack_instructions"
    
    # Add comprehensive MCP commands section
    local mcp_commands=$(cat << 'EOF'
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
)

    # Add the MCP commands section if it doesn't exist
    if ! grep -q "## 🤖 Slack MCP Commands to Run in Cursor" "$JOURNAL_FILE" 2>/dev/null; then
        echo "$mcp_commands" >> "$JOURNAL_FILE"
        "$TIMESTAMP_MANAGER" add-update "💻 Cursor Activity" "Added MCP command instructions" "Ready for manual execution"
    fi
    
    log_automation "✅ Journal updated successfully" "SUCCESS"
}

# Function to mark completion
mark_completion() {
    log_automation "✅ Marking Slack update as complete" "COMPLETE"
    
    "$TIMESTAMP_MANAGER" add-update "💬 Slack Context" "Manual MCP execution completed" "User ran commands manually"
    
    # Update the status in the journal
    if grep -q "🟡 Waiting for you" "$JOURNAL_FILE" 2>/dev/null; then
        sed -i.bak 's/🟡 Waiting for you.*/🟢 Completed - MCP commands executed/' "$JOURNAL_FILE"
        "$TIMESTAMP_MANAGER" add-update "💬 Slack Context" "Status updated" "Changed from waiting to completed"
    fi
    
    # Generate timestamp summary
    "$TIMESTAMP_MANAGER" summary
    
    log_automation "✅ Completion marked successfully" "SUCCESS"
}

# Function to show current timestamp stats
show_stats() {
    echo "📊 Current Journal Status"
    echo "========================"
    echo "Date: $TODAY"
    echo "Journal file: $JOURNAL_FILE"
    echo ""
    
    if [ -f "$JOURNAL_FILE" ]; then
        echo "📝 Journal exists ($(wc -l < "$JOURNAL_FILE") lines)"
        echo ""
        echo "🕒 Recent timestamps in journal:"
        grep -o '\[[0-9][0-9]:[0-9][0-9]\]' "$JOURNAL_FILE" | tail -5 | sort -u
    else
        echo "❌ No journal file found for today"
    fi
    
    echo ""
    "$TIMESTAMP_MANAGER" stats
}

# Function to run interactive mode
run_interactive() {
    log_automation "🎯 Interactive mode activated" "INTERACTIVE"
    
    echo "🤖 Interactive Slack Journal Update"
    echo "=================================="
    echo ""
    echo "This will:"
    echo "1. Update your journal with MCP command instructions"
    echo "2. Open Cursor to the journal file"
    echo "3. You can then run the MCP commands manually"
    echo ""
    read -p "Continue? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_smart_instructions
        
        # Try to open in Cursor
        if command -v cursor &> /dev/null; then
            log_automation "📂 Opening journal in Cursor" "OPEN"
            cursor "$JOURNAL_FILE"
        else
            log_automation "📂 Opening journal in default editor" "OPEN"
            open "$JOURNAL_FILE"
        fi
        
        echo ""
        echo "✅ Journal updated and opened!"
        echo "💡 Run MCP commands in Cursor, then use:"
        echo "   ./slack-auto-update.sh --mark-complete"
        echo ""
    else
        log_automation "❌ Interactive mode cancelled by user" "CANCELLED"
    fi
}

# Function to create automation for 17:00 run
setup_automation() {
    log_automation "⚙️ Setting up 17:00 automation" "SETUP"
    
    # Create or update launchd configuration for 17:00 run
    local plist_file="$HOME/Library/LaunchAgents/com.markgroche.slack-journal-update.plist"
    
    cat > "$plist_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.markgroche.slack-journal-update</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_DIR/slack-auto-update.sh</string>
        <string>--auto</string>
    </array>
    
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>17</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    
    <key>StandardOutPath</key>
    <string>$JOURNAL_DIR/slack-automation.log</string>
    
    <key>StandardErrorPath</key>
    <string>$JOURNAL_DIR/slack-automation-error.log</string>
    
    <key>RunAtLoad</key>
    <false/>
    
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

    # Load the launch agent
    launchctl unload "$plist_file" 2>/dev/null || true
    launchctl load "$plist_file"
    
    log_automation "✅ 17:00 automation configured" "SETUP_COMPLETE"
    echo "✅ Automation set up for 17:00 daily"
}

# Main execution logic
main() {
    local mode="${1:-auto}"
    
    case "$mode" in
        "--interactive"|"-i")
            run_interactive
            ;;
        "--quick"|"-q")
            create_smart_instructions
            ;;
        "--mark-complete"|"-c")
            mark_completion
            ;;
        "--stats"|"-s")
            show_stats
            ;;
        "--setup-automation")
            setup_automation
            ;;
        "--cleanup")
            "$TIMESTAMP_MANAGER" cleanup "${2:-30}"
            ;;
        "--auto"|"auto"|"")
            # Auto mode - try to be smart about what to do
            if [ ! -f "$JOURNAL_FILE" ]; then
                log_automation "📋 No journal found, creating with instructions" "AUTO"
                create_smart_instructions
            elif grep -q "🟡 Waiting for you" "$JOURNAL_FILE" 2>/dev/null; then
                log_automation "📋 Journal already has instructions, updating timestamp" "AUTO"
                "$TIMESTAMP_MANAGER" add-update "💬 Slack Context" "Automation check" "Instructions still pending"
            else
                log_automation "📋 Creating fresh instructions for today" "AUTO"
                create_smart_instructions
            fi
            ;;
        "--help"|"-h"|"help")
            echo "Slack Journal Auto-Update Script"
            echo "Usage: $0 [option]"
            echo ""
            echo "Options:"
            echo "  --interactive, -i    Run in interactive mode (opens Cursor)"
            echo "  --quick, -q          Quick mode (just update instructions)"
            echo "  --mark-complete, -c  Mark MCP commands as completed"
            echo "  --stats, -s          Show current journal statistics"
            echo "  --setup-automation   Set up 17:00 daily automation"
            echo "  --cleanup [days]     Clean up old timestamps (default: 30 days)"
            echo "  --auto               Auto mode (default)"
            echo "  --help, -h           Show this help"
            ;;
        *)
            echo "❌ Unknown option: $mode"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@" 