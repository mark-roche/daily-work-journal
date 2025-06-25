#!/bin/bash
# Setup Script for Daily Work Journal System
# Comprehensive work logging with Cursor activity and Slack context

echo "🚀 Setting up Daily Work Journal System..."
echo

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$SCRIPT_DIR/../logs"
PLIST_NAME="com.markgroche.daily-work-journal.plist"
LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$SCRIPT_DIR"/{scripts,config,logs}
mkdir -p "$JOURNAL_DIR"

# Make scripts executable
echo "📝 Making scripts executable..."
chmod +x "$SCRIPT_DIR/scripts/"*.sh

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$LAUNCHAGENTS_DIR"

# Copy plist to LaunchAgents
echo "📋 Installing LaunchAgent for daily automation..."
cp "$SCRIPT_DIR/config/launchd-daily-journal.xml" "$LAUNCHAGENTS_DIR/$PLIST_NAME"

# Load the LaunchAgent
echo "🔄 Loading LaunchAgent..."
launchctl load "$LAUNCHAGENTS_DIR/$PLIST_NAME"

# Test run the journal generator
echo "🧪 Running test journal generation..."
"$SCRIPT_DIR/scripts/daily-journal-generator.sh"

# Test run the Slack context populator
echo "📱 Setting up Slack context integration..."
"$SCRIPT_DIR/scripts/populate-slack-context.sh"

# Create a .cursorrules file for the journal project
cat > "$SCRIPT_DIR/.cursorrules" << 'EOF'
# Cursor Rules for Daily Work Journal System

## Project Context
This is a comprehensive daily work journal system that captures:
- Cursor IDE activity and development work
- Slack team communications and context
- Daily todos, achievements, and reflections
- Learning and insights from daily work

## File Organization
- `scripts/` - Executable shell scripts for journal generation
- `config/` - Configuration files (LaunchAgent plist)
- `logs/` - System logs for automation
- `daily-work-journal/logs/` - Daily journal markdown files

## Journal Structure
Each daily journal includes:
- Todos (carried over from previous day)
- Cursor activity (files modified, git commits, projects)
- Slack context (team communications, feedback, action items)
- Meetings and collaboration notes
- Learning and insights
- Challenges and blockers
- Achievements and wins
- Reflection and planning for tomorrow

## Integration Points
- **Cursor Activity**: Automatically pulls from cursor-logging system
- **Slack MCP**: Provides guided commands to populate team context
- **Git Integration**: Captures commits and repository changes
- **Daily Automation**: Runs at 9 AM via macOS LaunchAgent

## Usage Patterns
- Journal auto-generates each morning at 9 AM
- Use Slack MCP commands to populate team context
- Update throughout the day with activities and insights
- Review and plan for tomorrow at end of day
- Carry over incomplete todos to next day's journal

## Slack MCP Integration
The system provides specific MCP commands to run in Cursor:
- Get my messages from today
- Search for project mentions
- Check team feedback on tools
- Look for action items and follow-ups
- Monitor current status and reminders
EOF

# Create helper aliases
echo "🔗 Creating helpful aliases..."
cat >> ~/.zshrc << 'EOF'

# Daily Work Journal Aliases
alias journal-today="cursor \$SCRIPT_DIR/../logs/\$(date +%Y-%m-%d).md"
alias journal-generate="\$SCRIPT_DIR/daily-journal-generator.sh"
alias journal-slack="\$SCRIPT_DIR/populate-slack-context.sh"
alias journal-dir="ls -la \$SCRIPT_DIR/../logs/ | tail -10"
alias journal-update="\$SCRIPT_DIR/midday-journal-update.sh"
alias journal-quick="\$SCRIPT_DIR/quick-update.sh"
alias journal-evening="\$SCRIPT_DIR/evening-journal-summary.sh"
EOF

echo
echo "✅ Daily Work Journal System Setup Complete!"
echo
echo "📊 System Details:"
echo "   • Journal Directory: $JOURNAL_DIR"
echo "   • Daily Generation: 9:00 AM (automatic)"
echo "   • LaunchAgent: $PLIST_NAME"
echo "   • Today's Journal: $(ls -1 "$JOURNAL_DIR"/$(date +%Y-%m-%d).md 2>/dev/null || echo 'Not yet created')"
echo
echo "🔧 Manual Commands:"
echo "   • Generate today: $SCRIPT_DIR/scripts/daily-journal-generator.sh"
echo "   • Add Slack context: $SCRIPT_DIR/scripts/populate-slack-context.sh"
echo "   • Open today's journal: cursor $JOURNAL_DIR/$(date +%Y-%m-%d).md"
echo "   • View all journals: ls $JOURNAL_DIR/"
echo
echo "📱 Slack MCP Integration:"
echo "   • Your Slack MCP is configured and ready"
echo "   • Journal includes specific MCP commands to run"
echo "   • Use these to populate team context automatically"
echo
echo "🔄 Automation:"
echo "   • Stop service: launchctl unload $LAUNCHAGENTS_DIR/$PLIST_NAME"
echo "   • Start service: launchctl load $LAUNCHAGENTS_DIR/$PLIST_NAME"
echo "   • Check status: launchctl list | grep daily-work-journal"
echo
echo "📝 Next Steps:"
echo "   1. Open today's journal: cursor '$JOURNAL_DIR/$(date +%Y-%m-%d).md'"
echo "   2. Run the Slack MCP commands listed in the journal"
echo "   3. Fill in your daily activities and reflections"
echo "   4. The system will auto-generate a new journal each morning"
echo
echo "🎯 New Shell Aliases Available (restart terminal):"
echo "   • journal-today    - Open today's journal"
echo "   • journal-generate - Create new journal"
echo "   • journal-slack    - Add Slack context"
echo "   • journal-dir      - List recent journals"
echo 