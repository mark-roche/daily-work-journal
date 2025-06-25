#!/bin/bash
# Midday Journal Update - Quick updates throughout the day
# Interactive script to add accomplishments, notes, and context

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$SCRIPT_DIR/../logs"
TODAY=$(date +%Y-%m-%d)
JOURNAL_FILE="$JOURNAL_DIR/$TODAY.md"
CURSOR_LOGS_DIR="$HOME/Development/tools/cursor-logging/logs"
TIMESTAMP=$(date '+%H:%M')

echo "⏰ Midday Journal Update for $TODAY at $TIMESTAMP"
echo "📝 Journal: $JOURNAL_FILE"
echo

# Check if journal exists
if [ ! -f "$JOURNAL_FILE" ]; then
    echo "❌ Journal file not found. Creating it now..."
    "$SCRIPT_DIR/daily-journal-generator.sh"
    echo
fi

# Function to add timestamped entry to a section
add_to_section() {
    local section_header="$1"
    local content="$2"
    local temp_file="/tmp/journal_update_$$"
    
    # Create backup
    cp "$JOURNAL_FILE" "$JOURNAL_FILE.backup"
    
    # Add content to the specified section
    awk -v section="$section_header" -v content="$content" -v timestamp="$TIMESTAMP" '
    $0 ~ "^" section {
        print $0
        found_section = 1
        next
    }
    found_section && /^##/ && !/^###/ {
        # We hit the next main section, add our content before it
        print "- [" timestamp "] " content
        print ""
        found_section = 0
        print $0
        next
    }
    found_section && /^###/ {
        # We hit a subsection, keep looking
        print $0
        next
    }
    { print }
    END {
        if (found_section) {
            # We reached end of file while in the section
            print "- [" timestamp "] " content
        }
    }
    ' "$JOURNAL_FILE.backup" > "$temp_file"
    
    mv "$temp_file" "$JOURNAL_FILE"
    rm "$JOURNAL_FILE.backup"
}

# Function to mark todo as completed
complete_todo() {
    local todo_text="$1"
    sed -i.backup "s/^- \[ \] $todo_text/- [x] [$TIMESTAMP] $todo_text/" "$JOURNAL_FILE"
    rm "$JOURNAL_FILE.backup"
}

# Interactive menu
echo "🎯 What would you like to update?"
echo
echo "1. ✅ Mark a todo as completed"
echo "2. 📝 Add new todo/priority"
echo "3. 💻 Log development work"
echo "4. 🎉 Record an achievement"
echo "5. 🚧 Note a challenge/blocker"
echo "6. 🧠 Add learning/insight"
echo "7. 💬 Add Slack/team context"
echo "8. 🤝 Record meeting notes"
echo "9. 📝 Add general notes"
echo "10. 🔄 Quick Slack context update"
echo "11. 📊 Update daily summary"
echo "q. Quit"
echo

read -p "Choose option (1-11 or q): " choice

case $choice in
    1)
        echo
        echo "Current open todos:"
        grep -n "^- \[ \]" "$JOURNAL_FILE" | head -10
        echo
        read -p "Enter the todo text to mark complete: " todo_text
        if [ -n "$todo_text" ]; then
            complete_todo "$todo_text"
            echo "✅ Todo marked as completed with timestamp"
        fi
        ;;
    2)
        echo
        read -p "Enter new todo/priority: " new_todo
        if [ -n "$new_todo" ]; then
            add_to_section "### Today's Priorities" "[ ] $new_todo"
            echo "📝 New todo added"
        fi
        ;;
    3)
        echo
        read -p "What development work did you complete? " dev_work
        if [ -n "$dev_work" ]; then
            add_to_section "### Projects Worked On" "$dev_work"
            echo "💻 Development work logged"
        fi
        ;;
    4)
        echo
        read -p "What achievement/win would you like to record? " achievement
        if [ -n "$achievement" ]; then
            add_to_section "### Completed Tasks" "$achievement"
            echo "🎉 Achievement recorded"
        fi
        ;;
    5)
        echo
        read -p "What challenge or blocker did you encounter? " challenge
        if [ -n "$challenge" ]; then
            add_to_section "### Issues Encountered" "$challenge"
            echo "🚧 Challenge noted"
        fi
        ;;
    6)
        echo
        read -p "What did you learn or discover? " learning
        if [ -n "$learning" ]; then
            add_to_section "### New Things Learned" "$learning"
            echo "🧠 Learning recorded"
        fi
        ;;
    7)
        echo
        read -p "Add team/Slack context or conversation note: " slack_note
        if [ -n "$slack_note" ]; then
            add_to_section "### Key Conversations" "$slack_note"
            echo "💬 Slack context added"
        fi
        ;;
    8)
        echo
        read -p "Meeting name/topic: " meeting
        if [ -n "$meeting" ]; then
            read -p "Key outcomes/decisions: " outcomes
            add_to_section "### Meetings Attended" "$meeting - $outcomes"
            echo "🤝 Meeting notes added"
        fi
        ;;
    9)
        echo
        read -p "Add general note or thought: " note
        if [ -n "$note" ]; then
            add_to_section "### Random Thoughts" "$note"
            echo "📝 Note added"
        fi
        ;;
    10)
        echo "🔄 Running quick Slack context update..."
        "$SCRIPT_DIR/populate-slack-context.sh"
        ;;
    11)
        echo
        read -p "Update focus areas: " focus
        read -p "Key achievements so far: " achievements
        read -p "Current blockers: " blockers
        
        # Update the daily summary section
        sed -i.backup \
            -e "s/^\*\*Focus Areas:\*\* $/\*\*Focus Areas:\*\* $focus/" \
            -e "s/^\*\*Key Achievements:\*\* $/\*\*Key Achievements:\*\* $achievements/" \
            -e "s/^\*\*Blockers:\*\* $/\*\*Blockers:\*\* $blockers/" \
            "$JOURNAL_FILE"
        rm "$JOURNAL_FILE.backup"
        echo "📊 Daily summary updated"
        ;;
    q|Q)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo
echo "✅ Journal updated successfully!"
echo "📄 View journal: cursor '$JOURNAL_FILE'"
echo "🔄 Run again: $0"
echo 