# 📅 Google Calendar Integration Guide

This guide explains how to use the enhanced Daily Work Journal with Google Calendar and Slack integration using MCP (Model Context Protocol) commands.

## 🚀 Quick Start

### Generate Journal with Both Integrations
```bash
# Create today's journal
./scripts/journal.sh create

# Update both Slack and Calendar contexts (recommended)
./scripts/journal.sh update

# Or update individually
./scripts/journal.sh calendar
./scripts/journal.sh slack
```

## 📅 Calendar Integration Commands

### Available Commands
```bash
./scripts/journal.sh calendar      # Update calendar section with MCP commands
./scripts/journal.sh cal-complete  # Mark calendar integration as completed
./scripts/journal.sh update        # Update both calendar and Slack
./scripts/journal.sh all-complete  # Mark both integrations as completed
```

### MCP Commands Generated

When you run `./scripts/journal.sh calendar`, it adds these MCP commands to your journal:

```
1. mcp_gworkspace_calendar_events time_min="2025-06-26" time_max="2025-06-27"
2. mcp_gworkspace_calendar_availability email_list=["your-email@shopify.com"]
3. mcp_gworkspace_list_calendars
```

## 📊 Sample Calendar Data

Here's what the calendar integration returns:

### Today's Events (June 26, 2025)
- **09:00-09:10** - Check Performance
- **10:00-10:30** - Carina / Mark
- **10:30-11:00** - 1x1 Mark/Zeus
- **12:30-13:00** - Lunch
- **13:00-14:00** - TaskUs - Plus - Performance Meet (19 attendees)
- **14:30-15:00** - TaskUs Weekly - Premium Support Check-in (22 attendees)
- **16:00-16:45** - Retail Support Stakeholder Weekly Connect (18 attendees)
- **16:15-16:45** - New TaskUs Leadership Meet and Greet (9 attendees)
- **16:30-06:30+1** - Out of office

### Available Calendars
- **Primary:** mark.roche@shopify.com
- **Team:** Vendor Solutions Team
- **Hiring:** New Hire Dates (SUPPORT, AMERICAS, EMEA, APAC)
- **Company:** Important Shopify Dates, Retail
- **Regional:** Holidays in Ireland

## 🤖 Integration Workflow

### 1. Morning Setup (7:00 AM - Automated)
```bash
# Automatically creates journal
./scripts/journal.sh create
```

### 2. Mid-Morning Calendar Update (9:00 AM - Automated)
```bash
# Automatically updates calendar context
./scripts/journal.sh calendar
```

### 3. Evening Full Update (5:00 PM - Automated)
```bash
# Automatically updates both integrations
./scripts/journal.sh update
```

### 4. Manual Operations
```bash
# Copy MCP commands from journal and run in Cursor
# Then mark as completed:
./scripts/journal.sh all-complete
```

## 💻 Using with Cursor

### Step 1: Run the Integration
```bash
cd daily-work-journal
./scripts/journal.sh update
```

### Step 2: Open Journal in Cursor
```bash
./scripts/journal.sh open
```

### Step 3: Copy MCP Commands
Look for the "📱 MCP Commands" sections and copy the commands:

**Calendar Commands:**
```
mcp_gworkspace_calendar_events time_min="2025-06-26" time_max="2025-06-27"
mcp_gworkspace_calendar_availability email_list=["mark.roche@shopify.com"]
mcp_gworkspace_list_calendars
```

**Slack Commands:**
```
mcp_slack-tools-mcp_slack_my_messages since="2025-06-26" count=100
Search: "escalation analysis", "cursor logging", "daily journal"
mcp_slack-tools-mcp_slack_get_status
Search: 'TODO OR "action item" OR "follow up"'
```

### Step 4: Execute in Cursor
- Run the MCP commands in Cursor's chat
- Copy the results back to your journal
- Mark as completed: `./scripts/journal.sh all-complete`

## 📈 Analytics & Tracking

### View Integration Status
```bash
./scripts/journal.sh analytics
```

**Sample Output:**
```
📊 Daily Journal Analytics
================================
Date: 2025-06-26
Journal: 2025-06-26.md

📝 Content: 94 lines
✅ Completed: 1 tasks
⏳ Pending: 11 tasks
🕒 Timestamped entries: 0
📅 Calendar status: 🟢 Completed
💬 Slack status: 🟡 Queued
```

## ⚙️ Automation Setup

### Enhanced Automation Schedule
```bash
./scripts/journal.sh setup
```

This configures:
- **07:00** - Create daily journal
- **09:00** - Update calendar context
- **17:00** - Update all contexts (Slack + Calendar)

### Manual Automation Testing
```bash
# Test automation (simulates scheduled runs)
./scripts/journal.sh auto
```

## 🎯 Best Practices

### 1. Morning Routine
1. Check that journal was auto-created at 7 AM
2. Review calendar context added at 9 AM
3. Add manual entries as needed

### 2. Midday Usage
```bash
# Add timestamped entries throughout the day
./scripts/journal.sh add "✅ Tasks" "Completed performance review analysis"
./scripts/journal.sh add "💻 Development" "Fixed calendar integration bug"
./scripts/journal.sh add "📅 Calendar" "Rescheduled 1x1 with Zeus"
```

### 3. Evening Workflow
1. Let automation run at 5 PM to update contexts
2. Open Cursor and run MCP commands
3. Process results and add insights
4. Mark integrations as complete
5. Plan tomorrow's priorities

### 4. Weekly Cleanup
```bash
# Clean up old logs (keeps 30 days by default)
./scripts/journal.sh cleanup
```

## 🔧 Troubleshooting

### Calendar Not Updating
```bash
# Check if journal exists
ls logs/$(date +%Y-%m-%d).md

# Force calendar update
./scripts/journal.sh calendar

# Check logs
tail -20 logs/.activity.log
```

### Integration Status Issues
```bash
# Reset all integration statuses
./scripts/journal.sh update
```

### MCP Command Failures
- Ensure you're logged into Google Workspace
- Check your email in the availability command
- Verify calendar permissions

## 🎉 Success Example

After running the full workflow, your journal will contain:

### Calendar Section
```markdown
## 📅 Calendar & Schedule

### 🤖 Calendar Auto-Update
**Status:** 🟢 Completed | **Updated:** 16:30

### Today's Events
- 09:00-09:10: Check Performance
- 10:00-10:30: Carina / Mark
- 13:00-14:00: TaskUs - Plus - Performance Meet (19 attendees)
- 16:00-16:45: Retail Support Stakeholder Weekly Connect

### Key Meetings
- Performance review with TaskUs team
- Leadership stakeholder sync
- 1x1s with direct reports

### Time Blocks
- Morning: Individual work (9:10-10:00)
- Afternoon: Back-to-back meetings (13:00-16:45)
- Evening: Out of office (16:30+)

### Availability Gaps
- 10:30-12:30: Available for ad-hoc meetings
- Early morning (before 9:00): Deep work time
```

This integration provides a comprehensive view of your day, combining calendar events with Slack communications for complete context in your daily journal. 