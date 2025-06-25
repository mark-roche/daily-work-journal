#!/bin/bash
# Journal Timestamp Manager
# Manages all timestamp-related functionality for daily work journal

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$SCRIPT_DIR/../logs"
CONFIG_DIR="$SCRIPT_DIR/../config"
TODAY=$(date +%Y-%m-%d)
JOURNAL_FILE="$JOURNAL_DIR/$TODAY.md"
TIMESTAMP_LOG="$JOURNAL_DIR/.timestamps.log"
UPDATE_LOG="$JOURNAL_DIR/.update-history.log"

# Ensure directories exist
mkdir -p "$JOURNAL_DIR" "$CONFIG_DIR"

# Function to log with timestamp
log_with_timestamp() {
    local message="$1"
    local section="${2:-GENERAL}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$section] $message" | tee -a "$TIMESTAMP_LOG"
}

# Function to add update entry to journal
add_update_entry() {
    local section="$1"
    local action="$2"
    local details="${3:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local time_only=$(date '+%H:%M')
    
    # Log to update history
    echo "[$timestamp] $section: $action - $details" >> "$UPDATE_LOG"
    
    # Find the section in the journal and add timestamp
    if grep -q "^## $section" "$JOURNAL_FILE" 2>/dev/null; then
        # Add timestamp entry under the section
        local temp_file=$(mktemp)
        local section_found=false
        local entry_added=false
        
        while IFS= read -r line; do
            echo "$line" >> "$temp_file"
            
            # If we find the section and haven't added entry yet
            if [[ "$line" =~ ^##[[:space:]]*"$section" ]] && [ "$entry_added" = false ]; then
                section_found=true
                entry_added=true
                echo "" >> "$temp_file"
                echo "- [$time_only] $action$(if [ -n "$details" ]; then echo " - $details"; fi)" >> "$temp_file"
            fi
        done < "$JOURNAL_FILE"
        
        mv "$temp_file" "$JOURNAL_FILE"
    else
        # Section doesn't exist, add it with timestamp
        echo "" >> "$JOURNAL_FILE"
        echo "## $section" >> "$JOURNAL_FILE"
        echo "" >> "$JOURNAL_FILE"
        echo "- [$time_only] $action$(if [ -n "$details" ]; then echo " - $details"; fi)" >> "$JOURNAL_FILE"
    fi
    
    log_with_timestamp "$action in $section section" "JOURNAL_UPDATE"
}

# Function to update section with timestamp
update_section_with_timestamp() {
    local section="$1"
    local content="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local time_only=$(date '+%H:%M')
    
    if grep -q "^## $section" "$JOURNAL_FILE" 2>/dev/null; then
        # Add timestamped content under existing section
        local temp_file=$(mktemp)
        local in_section=false
        
        while IFS= read -r line; do
            echo "$line" >> "$temp_file"
            
            if [[ "$line" =~ ^##[[:space:]]*"$section" ]]; then
                in_section=true
                echo "" >> "$temp_file"
                echo "**Updated:** $time_only" >> "$temp_file"
                echo "" >> "$temp_file"
                echo "$content" >> "$temp_file"
                echo "" >> "$temp_file"
                in_section=false
            fi
        done < "$JOURNAL_FILE"
        
        mv "$temp_file" "$JOURNAL_FILE"
    else
        # Create new section with timestamp
        echo "" >> "$JOURNAL_FILE"
        echo "## $section" >> "$JOURNAL_FILE"
        echo "" >> "$JOURNAL_FILE"
        echo "**Updated:** $time_only" >> "$JOURNAL_FILE"
        echo "" >> "$JOURNAL_FILE"
        echo "$content" >> "$JOURNAL_FILE"
        echo "" >> "$JOURNAL_FILE"
    fi
    
    log_with_timestamp "Updated $section section" "SECTION_UPDATE"
}

# Function to add timestamp to existing entry
timestamp_existing_entry() {
    local pattern="$1"
    local timestamp=$(date '+%H:%M')
    
    if grep -q "$pattern" "$JOURNAL_FILE" 2>/dev/null; then
        sed -i.bak "s|$pattern|$pattern [$timestamp]|g" "$JOURNAL_FILE"
        log_with_timestamp "Added timestamp to: $pattern" "TIMESTAMP_ADD"
    fi
}

# Function to generate timestamp summary
generate_timestamp_summary() {
    local summary_file="$JOURNAL_DIR/.daily-timeline-$TODAY.md"
    
    cat > "$summary_file" << EOF
# Daily Timeline - $TODAY

## Update History
EOF
    
    if [ -f "$UPDATE_LOG" ]; then
        grep "^\\[$TODAY" "$UPDATE_LOG" | while read -r line; do
            echo "- $line" >> "$summary_file"
        done
    fi
    
    echo "" >> "$summary_file"
    echo "## Activity Timeline" >> "$summary_file"
    
    # Extract all timestamps from today's journal
    if [ -f "$JOURNAL_FILE" ]; then
        grep -o '\[.*\]' "$JOURNAL_FILE" | sort | uniq | while read -r time_entry; do
            echo "- $time_entry" >> "$summary_file"
        done
    fi
    
    log_with_timestamp "Generated timestamp summary" "SUMMARY"
}

# Function to clean up old timestamps
cleanup_old_timestamps() {
    local days_to_keep="${1:-30}"
    local cutoff_date=$(date -v-${days_to_keep}d +%Y-%m-%d)
    
    # Clean up old entries from timestamp log
    if [ -f "$TIMESTAMP_LOG" ]; then
        grep -v "^\\[.*$cutoff_date" "$TIMESTAMP_LOG" > "$TIMESTAMP_LOG.tmp"
        mv "$TIMESTAMP_LOG.tmp" "$TIMESTAMP_LOG"
    fi
    
    # Clean up old update history
    if [ -f "$UPDATE_LOG" ]; then
        grep -v "^\\[.*$cutoff_date" "$UPDATE_LOG" > "$UPDATE_LOG.tmp"
        mv "$UPDATE_LOG.tmp" "$UPDATE_LOG"
    fi
    
    log_with_timestamp "Cleaned up timestamps older than $days_to_keep days" "CLEANUP"
}

# Function to show timestamp statistics
show_timestamp_stats() {
    echo "📊 Timestamp Statistics for $TODAY"
    echo "=================================="
    
    if [ -f "$UPDATE_LOG" ]; then
        local today_updates=$(grep "^\\[$TODAY" "$UPDATE_LOG" | wc -l)
        echo "Total updates today: $today_updates"
        
        echo ""
        echo "Updates by section:"
        grep "^\\[$TODAY" "$UPDATE_LOG" | cut -d':' -f2 | cut -d' ' -f2 | sort | uniq -c | sort -nr
    fi
    
    if [ -f "$TIMESTAMP_LOG" ]; then
        echo ""
        echo "Activity timeline:"
        grep "^\\[$TODAY" "$TIMESTAMP_LOG" | tail -10
    fi
}

# Main execution based on arguments
case "${1:-help}" in
    "log")
        log_with_timestamp "$2" "${3:-MANUAL}"
        ;;
    "add-update")
        add_update_entry "$2" "$3" "$4"
        ;;
    "update-section")
        update_section_with_timestamp "$2" "$3"
        ;;
    "timestamp-entry")
        timestamp_existing_entry "$2"
        ;;
    "summary")
        generate_timestamp_summary
        ;;
    "cleanup")
        cleanup_old_timestamps "$2"
        ;;
    "stats")
        show_timestamp_stats
        ;;
    "help"|*)
        echo "Journal Timestamp Manager"
        echo "Usage: $0 [command] [args...]"
        echo ""
        echo "Commands:"
        echo "  log <message> [section]           - Log message with timestamp"
        echo "  add-update <section> <action> [details] - Add timestamped update to section"
        echo "  update-section <section> <content>       - Update section with timestamp"
        echo "  timestamp-entry <pattern>               - Add timestamp to existing entry"
        echo "  summary                                 - Generate timestamp summary"
        echo "  cleanup [days]                          - Clean up old timestamps (default: 30 days)"
        echo "  stats                                   - Show timestamp statistics"
        echo "  help                                    - Show this help"
        ;;
esac 