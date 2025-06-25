# 📝 Daily Work Journal

An automated daily work journal system with comprehensive timestamp tracking, Slack integration, and intelligent automation.

## 🚀 Features

### ⏰ **Comprehensive Timestamp Tracking**
- **Automatic timestamping** for all journal updates
- **Activity timeline** generation and historical tracking
- **Section-specific** update monitoring
- **Smart cleanup** of old timestamp data

### 💬 **Slack Integration**
- **MCP-powered** Slack context gathering
- **Automated daily updates** at 5 PM
- **Interactive and quick modes** for manual updates
- **Smart status tracking** (pending vs completed)

### 🤖 **Intelligent Automation**
- **Daily journal generation** with structured sections
- **Cursor activity integration** (when available)
- **LaunchD-based scheduling** for macOS
- **Comprehensive logging** and error tracking

### 📊 **Analytics & Insights**
- **Daily timeline reports** showing all activity
- **Productivity pattern analysis** 
- **Section update frequency** tracking
- **Historical data retention** with configurable cleanup

## 📁 Project Structure

```
daily-work-journal/
├── scripts/                          # Core automation scripts
│   ├── journal-timestamp-manager.sh  # Central timestamp management
│   ├── slack-auto-update.sh         # Slack integration with timestamps
│   ├── daily-journal-generator.sh   # Main journal creation
│   └── [other automation scripts]
├── logs/                             # Journal files and activity logs
│   ├── YYYY-MM-DD.md                # Daily journal files
│   ├── .timestamps.log              # Master activity log
│   ├── .update-history.log          # Section-specific updates
│   └── .daily-timeline-*.md         # Daily summary reports
├── config/                          # Configuration files
│   └── launchd-*.xml               # macOS automation configs
├── TIMESTAMP_FEATURES.md           # Detailed timestamp documentation
└── HOW_SLACK_AUTOMATION_WORKS.md   # Slack integration guide
```

## 🛠️ Installation & Setup

### Prerequisites
- macOS (for LaunchD automation)
- Bash shell
- [Cursor](https://cursor.sh) with Slack MCP tools (for Slack integration)
- Git (for version control)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/markgroche/daily-work-journal.git
   cd daily-work-journal
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Generate your first journal:**
   ```bash
   ./scripts/daily-journal-generator.sh
   ```

4. **Set up 17:00 automation:**
   ```bash
   ./scripts/slack-auto-update.sh --setup-automation
   ```

## 📖 Usage

### Daily Workflow

**Morning Setup:**
```bash
# Generate today's journal with timestamps
./scripts/daily-journal-generator.sh
```

**Throughout the Day:**
```bash
# Add timestamped updates as you work
./scripts/journal-timestamp-manager.sh add-update "💻 Cursor Activity" "Completed code review" "Fixed 3 bugs"

# Log significant events
./scripts/journal-timestamp-manager.sh log "Meeting with design team" "MEETING"
```

**Afternoon Slack Update (17:00):**
```bash
# Interactive mode (opens Cursor with MCP commands)
./scripts/slack-auto-update.sh --interactive

# After running MCP commands manually
./scripts/slack-auto-update.sh --mark-complete
```

**End of Day:**
```bash
# Generate timeline summary
./scripts/journal-timestamp-manager.sh summary

# View daily statistics
./scripts/journal-timestamp-manager.sh stats
```

### Command Reference

#### Timestamp Manager
```bash
# Core timestamp operations
./scripts/journal-timestamp-manager.sh log "message" [section]
./scripts/journal-timestamp-manager.sh add-update "section" "action" [details]
./scripts/journal-timestamp-manager.sh update-section "section" "content"
./scripts/journal-timestamp-manager.sh summary
./scripts/journal-timestamp-manager.sh stats
./scripts/journal-timestamp-manager.sh cleanup [days]
```

#### Slack Automation
```bash
# Different modes of operation
./scripts/slack-auto-update.sh --interactive    # Opens Cursor for manual MCP execution
./scripts/slack-auto-update.sh --quick          # Quick instruction update
./scripts/slack-auto-update.sh --mark-complete  # Mark MCP commands as completed
./scripts/slack-auto-update.sh --stats          # Show current status
./scripts/slack-auto-update.sh --setup-automation  # Configure 17:00 daily run
```

## 🎯 Key Benefits

### 📈 **Productivity Tracking**
- See exactly when you're most productive
- Track time spent on different activities  
- Identify patterns in your work habits

### 🔍 **Activity Analysis**
- Understand which journal sections get updated most
- Track completion rates for automated tasks
- Monitor consistency of journaling habits

### 📊 **Historical Data**
- Maintain detailed logs of all activities
- Generate timeline reports for any day
- Clean up old data automatically

### ⚡ **Automation Intelligence**
- Smart detection of pending vs completed tasks
- Automatic status updates with timestamps
- Detailed logging for troubleshooting automation issues

## 📚 Documentation

- **[TIMESTAMP_FEATURES.md](TIMESTAMP_FEATURES.md)** - Comprehensive guide to timestamp functionality
- **[HOW_SLACK_AUTOMATION_WORKS.md](HOW_SLACK_AUTOMATION_WORKS.md)** - Slack integration details
- **[scripts/](scripts/)** - Individual script documentation in comments

## 🔧 Configuration

### Timestamp Settings
- **Full timestamps**: `2025-06-25 14:13:18`
- **Time-only**: `14:13` (used in journal entries)
- **Default retention**: 30 days (configurable)

### Automation Schedule
- **Daily generation**: 9:00 AM (configurable in LaunchD)
- **Slack update**: 17:00 PM (5 PM)
- **Cleanup**: Weekly (configurable)

### Slack Integration
Requires Cursor with MCP Slack tools for:
- Message retrieval
- Project mention searches
- Status checking
- Action item discovery

## 🤝 Contributing

This is a personal productivity tool, but contributions and suggestions are welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - Feel free to adapt this system for your own productivity needs!

## 🙏 Acknowledgments

- Built for use with [Cursor](https://cursor.sh) and its MCP ecosystem
- Inspired by productivity systems and daily reflection practices
- Designed for knowledge workers who want to track their daily activities

---

**Happy journaling! 📝✨** 