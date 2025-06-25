#!/bin/bash
# Quick Journal Update - Single command updates
# Usage: ./quick-update.sh [type] [message]
# Example: ./quick-update.sh todo "Review PR #123"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$SCRIPT_DIR/../logs"
TODAY=$(date +%Y-%m-%d)
JOURNAL_FILE="$JOURNAL_DIR/$TODAY.md"
TIMESTAMP=$(date '+%H:%M')

# Check if journal exists
if [ ! -f "$JOURNAL_FILE" ]; then
    echo "❌ Journal file not found. Creating it now..."
    "$SCRIPT_DIR/daily-journal-generator.sh"
fi

# Function to add timestamped entry
add_entry() {
    local section="$1"
    local entry="$2"
    local temp_file="/tmp/quick_update_$$"
    
    awk -v section="$section" -v entry="$entry" -v timestamp="$TIMESTAMP" '
    $0 ~ "^" section {
        print $0
        found = 1
        next
    }
    found && /^##/ && !/^###/ {
        print "- [" timestamp "] " entry
        print ""
        found = 0
        print $0
        next
    }
    found && /^###/ {
        print $0
        next
    }
    { print }
    END {
        if (found) print "- [" timestamp "] " entry
    }
    ' "$JOURNAL_FILE" > "$temp_file"
    
    mv "$temp_file" "$JOURNAL_FILE"
}

# Parse command line arguments
TYPE="$1"
MESSAGE="$2"

if [ -z "$TYPE" ]; then
    echo "📝 Quick Journal Update Commands:"
    echo
    echo "Usage: $0 [type] [message]"
    echo
    echo "Types:"
    echo "  todo     - Add new todo"
    echo "  done     - Mark something as completed"
    echo "  work     - Log development work"
    echo "  win      - Record achievement"
    echo "  block    - Note challenge/blocker"
    echo "  learn    - Add learning/insight"
    echo "  meet     - Record meeting note"
    echo "  note     - Add general note"
    echo
    echo "Examples:"
    echo "  $0 todo 'Review PR #123'"
    echo "  $0 done 'Fixed authentication bug'"
    echo "  $0 work 'Updated journal system with midday updates'"
    echo "  $0 win 'Successfully deployed new feature'"
    echo "  $0 block 'Waiting for API documentation'"
    echo "  $0 learn 'Discovered new bash scripting technique'"
    echo "  $0 meet 'Standup: discussed sprint goals'"
    echo "  $0 note 'Good idea for tomorrow: automate report generation'"
    exit 0
fi

if [ -z "$MESSAGE" ]; then
    read -p "Enter message: " MESSAGE
fi

case "$TYPE" in
    todo|t)
        add_entry "### Today's Priorities" "[ ] $MESSAGE"
        echo "📝 Todo added: $MESSAGE"
        ;;
    done|d)
        add_entry "### Completed Today" "$MESSAGE"
        echo "✅ Completion logged: $MESSAGE"
        ;;
    work|w)
        add_entry "### Projects Worked On" "$MESSAGE"
        echo "💻 Work logged: $MESSAGE"
        ;;
    win|achievement|a)
        add_entry "### Completed Tasks" "$MESSAGE"
        echo "🎉 Achievement logged: $MESSAGE"
        ;;
    block|blocker|b)
        add_entry "### Issues Encountered" "$MESSAGE"
        echo "🚧 Blocker noted: $MESSAGE"
        ;;
    learn|l)
        add_entry "### New Things Learned" "$MESSAGE"
        echo "🧠 Learning recorded: $MESSAGE"
        ;;
    meet|meeting|m)
        add_entry "### Meetings Attended" "$MESSAGE"
        echo "🤝 Meeting logged: $MESSAGE"
        ;;
    note|n)
        add_entry "### Random Thoughts" "$MESSAGE"
        echo "📝 Note added: $MESSAGE"
        ;;
    *)
        echo "❌ Unknown type: $TYPE"
        echo "Run '$0' without arguments to see available types"
        exit 1
        ;;
esac

echo "⏰ Timestamp: $TIMESTAMP" 