#!/bin/bash
# Setup Script for Slack Journal Automation
# Installs and configures automated Slack data collection

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
LAUNCHD_DIR="$HOME/Library/LaunchAgents"
LAUNCHD_PLIST="com.markgroche.slack-journal-update.plist"

echo "🚀 Setting up Slack Journal Automation..."

# Make scripts executable
echo "📋 Making scripts executable..."
chmod +x "$SCRIPT_DIR/slack-auto-update.sh"
chmod +x "$SCRIPT_DIR/auto-slack-update.py"

# Copy launchd plist to LaunchAgents
echo "⏰ Installing launchd job..."
if [ ! -d "$LAUNCHD_DIR" ]; then
    mkdir -p "$LAUNCHD_DIR"
fi

cp "$PROJECT_DIR/config/launchd-slack-update.xml" "$LAUNCHD_DIR/$LAUNCHD_PLIST"

# Load the launchd job
echo "🔄 Loading launchd job..."
launchctl unload "$LAUNCHD_DIR/$LAUNCHD_PLIST" 2>/dev/null || true
launchctl load "$LAUNCHD_DIR/$LAUNCHD_PLIST"

# Test the automation
echo "🧪 Testing automation script..."
"$SCRIPT_DIR/slack-auto-update.sh" --test

echo ""
echo "✅ Slack Journal Automation Setup Complete!"
echo ""
echo "📅 Schedule:"
echo "   • Daily at 5:00 PM: Automatic Slack data collection"
echo "   • Opens Cursor with update instructions"
echo ""
echo "🛠️  Manual Commands:"
echo "   • Run now: $SCRIPT_DIR/slack-auto-update.sh"
echo "   • Automated: $SCRIPT_DIR/slack-auto-update.sh --automated"
echo "   • Test: $SCRIPT_DIR/slack-auto-update.sh --test"
echo ""
echo "📋 Launchd Management:"
echo "   • Check status: launchctl list | grep slack-journal"
echo "   • Unload: launchctl unload $LAUNCHD_DIR/$LAUNCHD_PLIST"
echo "   • Reload: launchctl load $LAUNCHD_DIR/$LAUNCHD_PLIST"
echo ""
echo "📁 Log Files:"
echo "   • Output: $PROJECT_DIR/logs/slack-automation.log"
echo "   • Errors: $PROJECT_DIR/logs/slack-automation-error.log"
echo ""

# Show next steps
echo "🎯 Next Steps:"
echo "   1. Test the automation: Run the script manually to see how it works"
echo "   2. The system will automatically run at 5 PM daily"
echo "   3. It will open Cursor with MCP commands ready to run"
echo "   4. You can also run it manually anytime during the day"
echo ""
echo "💡 Pro Tips:"
echo "   • The automation integrates with your existing journal system"
echo "   • It preserves your manual entries and adds Slack context"
echo "   • You can customize the timing by editing the launchd plist"
echo "" 