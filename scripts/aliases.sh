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
