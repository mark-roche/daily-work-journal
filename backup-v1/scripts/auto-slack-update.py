#!/usr/bin/env python3
"""
Automated Slack Journal Update Script
Runs Slack MCP commands and updates the daily journal automatically
"""

import os
import sys
import json
import subprocess
import tempfile
from datetime import datetime, date
from pathlib import Path

# Configuration
SCRIPT_DIR = Path(__file__).parent
JOURNAL_DIR = SCRIPT_DIR / "../logs"
TODAY = date.today().strftime("%Y-%m-%d")
JOURNAL_FILE = JOURNAL_DIR / f"{TODAY}.md"

class SlackJournalUpdater:
    def __init__(self):
        self.today = TODAY
        self.journal_file = JOURNAL_FILE
        self.slack_data = {}
        
    def log(self, message):
        print(f"📱 {message}")
        
    def run_mcp_command(self, tool_name, parameters=None):
        """
        Run MCP command via Cursor's CLI (if available)
        This would integrate with Cursor's MCP system
        """
        try:
            # This is a conceptual implementation
            # In practice, this would call Cursor's MCP interface
            cmd = ["cursor", "mcp", tool_name]
            if parameters:
                cmd.extend(["--params", json.dumps(parameters)])
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                return json.loads(result.stdout)
            else:
                self.log(f"MCP command failed: {result.stderr}")
                return None
        except Exception as e:
            self.log(f"Error running MCP command: {e}")
            return None
    
    def fetch_slack_data(self):
        """Fetch all Slack data using MCP commands"""
        self.log("Fetching Slack messages from today...")
        
        # 1. Get my messages from today
        messages = self.run_mcp_command(
            "mcp_slack-tools-mcp_slack_my_messages",
            {"since": self.today, "count": 200}
        )
        self.slack_data['my_messages'] = messages
        
        # 2. Search for project mentions
        searches = [
            "escalation analysis",
            "cursor logging", 
            "daily journal",
            "markgroche tool"
        ]
        
        self.slack_data['project_mentions'] = {}
        for search_term in searches:
            self.log(f"Searching for: {search_term}")
            results = self.run_mcp_command(
                "mcp_slack-tools-mcp_slack_search",
                {"query": search_term, "count": 50}
            )
            self.slack_data['project_mentions'][search_term] = results
        
        # 3. Get current status
        status = self.run_mcp_command("mcp_slack-tools-mcp_slack_get_status")
        self.slack_data['current_status'] = status
        
        # 4. Search for action items
        action_items = self.run_mcp_command(
            "mcp_slack-tools-mcp_slack_search",
            {"query": 'TODO OR "action item" OR "follow up"', "count": 50}
        )
        self.slack_data['action_items'] = action_items
        
        self.log("Slack data collection complete!")
        
    def parse_slack_messages(self, messages_data):
        """Parse Slack messages into structured format"""
        if not messages_data:
            return "No messages found for today."
            
        parsed = []
        # This would parse the actual MCP response format
        # For now, returning placeholder
        parsed.append("**Key Conversations:**")
        parsed.append("- (Parsed from MCP response)")
        
        return "\n".join(parsed)
    
    def generate_slack_section(self):
        """Generate the complete Slack context section"""
        section = []
        
        section.append("## 💬 Slack Context")
        section.append("")
        
        # Messages from today
        section.append("### My Messages from Today")
        section.append("")
        messages_summary = self.parse_slack_messages(self.slack_data.get('my_messages'))
        section.append(messages_summary)
        section.append("")
        
        # Project mentions
        section.append("### Mentions of My Projects")
        section.append("")
        for project, results in self.slack_data.get('project_mentions', {}).items():
            if results:
                section.append(f"**{project.title()}:**")
                section.append(f"- Found {len(results) if isinstance(results, list) else 'some'} mentions")
        section.append("")
        
        # Current status
        section.append("### Current Status")
        section.append("")
        status = self.slack_data.get('current_status', {})
        if status:
            section.append(f"**Slack Status:** {status.get('text', 'No status set')}")
        else:
            section.append("**Slack Status:** No status set")
        section.append("")
        
        # Action items
        section.append("### Action Items from Slack")
        section.append("")
        action_items = self.slack_data.get('action_items')
        if action_items:
            section.append("- Found action items to review")
        else:
            section.append("- No specific action items found")
        section.append("")
        
        return "\n".join(section)
    
    def update_journal(self):
        """Update the journal file with Slack context"""
        if not self.journal_file.exists():
            self.log(f"Journal file not found: {self.journal_file}")
            return False
            
        self.log("Updating journal with Slack context...")
        
        # Read current journal
        with open(self.journal_file, 'r') as f:
            content = f.read()
        
        # Generate new Slack section
        new_slack_section = self.generate_slack_section()
        
        # Replace Slack section
        import re
        pattern = r'## 💬 Slack Context.*?(?=## |\Z)'
        if re.search(pattern, content, re.DOTALL):
            content = re.sub(pattern, new_slack_section + "\n\n", content, flags=re.DOTALL)
        else:
            # Add section if it doesn't exist
            content += "\n\n" + new_slack_section
        
        # Write back to file
        with open(self.journal_file, 'w') as f:
            f.write(content)
            
        self.log("Journal updated successfully!")
        return True
    
    def run(self):
        """Main execution function"""
        self.log(f"Starting automated Slack journal update for {self.today}")
        
        # Fetch Slack data
        self.fetch_slack_data()
        
        # Update journal
        success = self.update_journal()
        
        if success:
            self.log("✅ Automated Slack update complete!")
            print(f"\n📖 View updated journal: cursor {self.journal_file}")
        else:
            self.log("❌ Failed to update journal")
            return 1
            
        return 0

if __name__ == "__main__":
    updater = SlackJournalUpdater()
    sys.exit(updater.run()) 