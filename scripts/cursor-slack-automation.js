// Cursor automation script for Slack MCP
// This would be run within Cursor's environment

const today = new Date().toISOString().split('T')[0];

async function runSlackMCP() {
    const results = {};
    
    try {
        // Get my messages from today
        console.log('Fetching messages from today...');
        const messages = await cursor.mcp.call('mcp_slack-tools-mcp_slack_my_messages', {
            since: today,
            count: 200
        });
        results.messages = messages;
        
        // Search for project mentions
        console.log('Searching for project mentions...');
        const projectSearches = ['escalation analysis', 'cursor logging', 'daily journal'];
        results.projectMentions = {};
        
        for (const query of projectSearches) {
            const searchResults = await cursor.mcp.call('mcp_slack-tools-mcp_slack_search', {
                query: query,
                count: 50
            });
            results.projectMentions[query] = searchResults;
        }
        
        // Get current status
        console.log('Getting current status...');
        const status = await cursor.mcp.call('mcp_slack-tools-mcp_slack_get_status');
        results.status = status;
        
        // Search for action items
        console.log('Searching for action items...');
        const actionItems = await cursor.mcp.call('mcp_slack-tools-mcp_slack_search', {
            query: 'TODO OR "action item" OR "follow up"',
            count: 50
        });
        results.actionItems = actionItems;
        
        return results;
    } catch (error) {
        console.error('Error running Slack MCP:', error);
        return null;
    }
}

// Format results for journal
function formatForJournal(results) {
    if (!results) return '## 💬 Slack Context\n\n❌ Failed to fetch Slack data\n';
    
    let output = '## 💬 Slack Context\n\n';
    
    // Messages section
    output += '### My Messages from Today\n\n';
    if (results.messages) {
        output += '**Key Conversations:**\n';
        // Parse and format messages
        output += '- Successfully fetched today\'s messages\n';
    } else {
        output += '- No messages found for today\n';
    }
    output += '\n';
    
    // Project mentions
    output += '### Mentions of My Projects\n\n';
    for (const [project, mentions] of Object.entries(results.projectMentions || {})) {
        if (mentions) {
            output += `**${project}:**\n`;
            output += `- Found activity related to ${project}\n`;
        }
    }
    output += '\n';
    
    // Current status
    output += '### Current Status\n\n';
    if (results.status) {
        output += `**Slack Status:** ${results.status.text || 'No status set'}\n`;
    } else {
        output += '**Slack Status:** No status set\n';
    }
    output += '\n';
    
    return output;
}

// Main execution
runSlackMCP().then(results => {
    const formatted = formatForJournal(results);
    console.log('=== FORMATTED RESULTS ===');
    console.log(formatted);
    console.log('=== END RESULTS ===');
});
