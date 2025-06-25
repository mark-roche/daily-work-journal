#!/bin/bash
# Migration Script: v1.0 → v2.0
# Migrates from multiple scripts to unified journal.sh system

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="$SCRIPT_DIR/backup-v1"
readonly TODAY=$(date +%Y-%m-%d)

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() {
    echo -e "${BLUE}[MIGRATE]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Create backup of old system
backup_old_system() {
    log "Creating backup of v1.0 system..."
    
    mkdir -p "$BACKUP_DIR/scripts"
    
    # List of old scripts to backup and remove
    local old_scripts=(
        "slack-auto-update.sh"
        "journal-timestamp-manager.sh"
        "smart-slack-update.sh"
        "auto-slack-update.py"
        "cursor-slack-automation.js"
        "setup-slack-automation.sh"
        "setup-daily-journal.sh"
        "quick-update.sh"
        "midday-journal-update.sh"
        "evening-journal-summary.sh"
        "morning-journal-setup.sh"
        "populate-slack-context.sh"
        "daily-journal-generator.sh"
    )
    
    for script in "${old_scripts[@]}"; do
        if [[ -f "scripts/$script" ]]; then
            mv "scripts/$script" "$BACKUP_DIR/scripts/"
            log "Backed up: $script"
        fi
    done
    
    # Backup old config files
    if [[ -d "config" ]]; then
        cp -r config "$BACKUP_DIR/"
        log "Backed up config directory"
    fi
    
    success "Backup completed: $BACKUP_DIR"
}

# Migrate logs and preserve data
migrate_logs() {
    log "Migrating log files..."
    
    # Rename old timestamp logs to new format
    if [[ -f "logs/.timestamps.log" ]]; then
        mv "logs/.timestamps.log" "logs/.activity.log"
        log "Migrated .timestamps.log → .activity.log"
    fi
    
    # Clean up old update history (data preserved in activity log)
    if [[ -f "logs/.update-history.log" ]]; then
        mv "logs/.update-history.log" "$BACKUP_DIR/"
        log "Moved .update-history.log to backup"
    fi
    
    success "Log migration completed"
}

# Update automation
update_automation() {
    log "Updating automation configuration..."
    
    # Remove old launchd jobs
    local old_plists=(
        "com.markgroche.daily-work-journal.plist"
        "com.markgroche.slack-journal-update.plist"
    )
    
    for plist in "${old_plists[@]}"; do
        local plist_path="$HOME/Library/LaunchAgents/$plist"
        if [[ -f "$plist_path" ]]; then
            launchctl unload "$plist_path" 2>/dev/null || true
            rm -f "$plist_path"
            log "Removed old automation: $plist"
        fi
    done
    
    # Setup new automation
    log "Setting up new v2.0 automation..."
    ./scripts/journal.sh setup
    
    success "Automation updated to v2.0"
}

# Create compatibility aliases
create_aliases() {
    log "Creating compatibility aliases..."
    
    cat > "scripts/aliases.sh" << 'EOF'
#!/bin/bash
# Compatibility aliases for v1.0 → v2.0 migration
# Source this file to use old command names

alias daily-journal-generator.sh='./journal.sh create'
alias slack-auto-update.sh='./journal.sh slack'
alias journal-timestamp-manager.sh='./journal.sh add'

echo "📝 Journal v2.0 aliases loaded!"
echo "Old commands now redirect to new journal.sh system"
echo ""
echo "Examples:"
echo "  daily-journal-generator.sh  →  ./journal.sh create"
echo "  slack-auto-update.sh        →  ./journal.sh slack"
echo ""
echo "Run './journal.sh help' for full v2.0 command reference"
EOF
    
    chmod +x "scripts/aliases.sh"
    success "Compatibility aliases created: scripts/aliases.sh"
}

# Test new system
test_new_system() {
    log "Testing new v2.0 system..."
    
    # Test journal creation
    if ./scripts/journal.sh create; then
        success "✅ Journal creation works"
    else
        error "❌ Journal creation failed"
        return 1
    fi
    
    # Test analytics
    if ./scripts/journal.sh analytics; then
        success "✅ Analytics works"
    else
        warn "⚠️ Analytics test failed (non-critical)"
    fi
    
    success "System test completed"
}

# Main migration process
main() {
    echo -e "${BLUE}🔄 Daily Work Journal Migration: v1.0 → v2.0${NC}"
    echo "=============================================="
    echo ""
    echo "This will:"
    echo "• Backup old scripts to backup-v1/"
    echo "• Remove redundant files"
    echo "• Migrate to unified journal.sh system"
    echo "• Update automation"
    echo "• Preserve all your journal data"
    echo ""
    
    read -p "Continue with migration? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Migration cancelled."
        exit 0
    fi
    
    echo ""
    log "Starting migration..."
    
    # Run migration steps
    backup_old_system
    migrate_logs
    update_automation
    create_aliases
    test_new_system
    
    echo ""
    echo -e "${GREEN}🎉 Migration Complete!${NC}"
    echo "===================="
    echo ""
    echo -e "${YELLOW}What's New in v2.0:${NC}"
    echo "• Single unified script: journal.sh"
    echo "• Streamlined journal template (50% shorter)"
    echo "• Enhanced analytics and timestamping"
    echo "• Improved automation (9 AM & 5 PM)"
    echo "• Better error handling and logging"
    echo "• Color-coded output"
    echo ""
    echo -e "${YELLOW}Quick Start:${NC}"
    echo "  ./scripts/journal.sh create     # Create today's journal"
    echo "  ./scripts/journal.sh open       # Open in editor"
    echo "  ./scripts/journal.sh slack      # Update Slack context"
    echo "  ./scripts/journal.sh analytics  # View statistics"
    echo "  ./scripts/journal.sh help       # Full command reference"
    echo ""
    echo -e "${YELLOW}Your Data:${NC}"
    echo "• All journal files preserved in logs/"
    echo "• Old scripts backed up to backup-v1/"
    echo "• Automation updated and active"
    echo ""
    echo -e "${BLUE}Happy journaling with v2.0! 📝✨${NC}"
}

# Execute migration
main "$@" 