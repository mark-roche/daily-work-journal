#!/bin/bash
# Smart Slack Update Script
# Handles different scenarios: locked computer, manual runs, etc.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$SCRIPT_DIR/../logs"
TODAY=$(date +%Y-%m-%d)
JOURNAL_FILE="$JOURNAL_DIR/$TODAY.md"
LOG_FILE="$JOURNAL_DIR/slack-automation.log"

# Function to log with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to send notification (macOS only)
send_notification() {
    local title="$1"
    local message="$2"
    
    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"$message\" with title \"$title\""
    fi
}

# Function to check if user is logged in and screen is unlocked
is_user_active() {
    # Check if someone is logged into the GUI
    if ! /usr/bin/who | grep -q console; then
        return 1
    fi
    
    # Check if screen is locked (this is approximate)
    if /usr/bin/python3 -c "
import Quartz
session = Quartz.CGSessionCopyCurrentDictionary()
if session and session.get('CGSSessionScreenIsLocked', False):
    exit(1)
exit(0)
" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to update journal with better instructions
update_journal_smart() {
    log_message "📝 Updating journal with smart instructions..."
    
    local current_time=$(date '+%H:%M')
    local user_status=""
    
    if is_user_active; then
        user_status="🟢 Ready to run - you're at your computer!"
    else
        user_status="🟡 Waiting for you - run when you're back at your computer"
    fi
    
    cat > "/tmp/slack-update-smart.md" << EOF
## 💬 Slack Context

### 🤖 Automated Update Status
**Updated:** $(date '+%Y-%m-%d %H:%M:%S')  
**Status:** $user_status

**Quick Action:**
\`\`\`bash
# If you want to run this manually right now:
cd "$SCRIPT_DIR" && ./slack-auto-update.sh --interactive
\`\`\`

### 📱 MCP Commands Ready to Run

**Copy and paste these one by one in Cursor:**

1️⃣ **Get today's messages:**
\`\`\`
Use mcp_slack-tools-mcp_slack_my_messages with since="$TODAY" and count=200
\`\`\`

2️⃣ **Search for your projects:**
\`\`\`
Search Slack for "escalation analysis"
Search Slack for "cursor logging"  
Search Slack for "daily journal"
\`\`\`

3️⃣ **Check your status:**
\`\`\`
Use mcp_slack-tools-mcp_slack_get_status
\`\`\`

4️⃣ **Find action items:**
\`\`\`
Search for 'TODO OR "action item" OR "follow up"'
\`\`\`

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
**💡 Tip:** After updating, run \`./slack-auto-update.sh --mark-complete\` to log completion

EOF

    # Replace the Slack section in the journal
    if [ -f "$JOURNAL_FILE" ]; then
        # Create backup
        cp "$JOURNAL_FILE" "$JOURNAL_FILE.backup"
        
        # Replace Slack section
        awk '
        BEGIN { in_slack_section = 0; slack_content_added = 0 }
        /^## 💬 Slack Context/ {
            in_slack_section = 1
            while ((getline line < "/tmp/slack-update-smart.md") > 0) {
                print line
            }
            close("/tmp/slack-update-smart.md")
            slack_content_added = 1
            next
        }
        /^## / && in_slack_section {
            in_slack_section = 0
            print $0
            next
        }
        !in_slack_section { print }
        END {
            if (!slack_content_added) {
                print ""
                while ((getline line < "/tmp/slack-update-smart.md") > 0) {
                    print line
                }
                close("/tmp/slack-update-smart.md")
            }
        }
        ' "$JOURNAL_FILE.backup" > "$JOURNAL_FILE"
        
        rm "$JOURNAL_FILE.backup" "/tmp/slack-update-smart.md"
        log_message "✅ Journal updated successfully"
        return 0
    else
        log_message "❌ Journal file not found: $JOURNAL_FILE"
        return 1
    fi
}

# Function to try opening Cursor intelligently
open_cursor_smart() {
    if is_user_active; then
        log_message "🎯 User is active - opening Cursor..."
        if command -v cursor &> /dev/null; then
            cursor "$JOURNAL_FILE" &
            send_notification "📝 Daily Journal" "Slack update ready! MCP commands loaded in Cursor."
            return 0
        else
            log_message "⚠️ Cursor command not found"
            send_notification "📝 Daily Journal" "Slack update ready! Please open Cursor manually."
            return 1
        fi
    else
        log_message "🔒 User not active - will notify when they return"
        send_notification "📝 Daily Journal" "Slack update prepared! Open your journal when you're back."
        return 1
    fi
}

# Main execution
main() {
    case "$1" in
        "--interactive")
            log_message "🎯 Interactive mode - opening immediately"
            update_journal_smart
            cursor "$JOURNAL_FILE" 2>/dev/null &
            ;;
        "--mark-complete")
            log_message "✅ User marked Slack update as complete"
            send_notification "📝 Daily Journal" "Slack update completed!"
            ;;
        "--check-status")
            if is_user_active; then
                echo "🟢 User is active and screen is unlocked"
            else
                echo "🔒 User is away or screen is locked"
            fi
            ;;
        *)
            log_message "🚀 Starting smart Slack update for $TODAY"
            
            # Always update the journal
            if update_journal_smart; then
                # Try to open Cursor if user is active
                if open_cursor_smart; then
                    log_message "✅ Successfully opened Cursor for user"
                else
                    log_message "📝 Journal updated, waiting for user to return"
                fi
            else
                log_message "❌ Failed to update journal"
                exit 1
            fi
            ;;
    esac
}

# Run main function
main "$@" 