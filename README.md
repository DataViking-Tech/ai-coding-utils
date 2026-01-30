# AI Coding Utils

Reusable utilities for AI coding agents across multiple projects. Provides Slack notifications, beads workflow integration, multi-agent coordination via MCP, and git hooks for automated agent workflows.

## Purpose

This library enables AI coding agents to:
- **Notify humans** via Slack when they need review, are blocked, or complete work
- **Track work** using beads issue tracking with automated hooks
- **Coordinate agents** via MCP agent mail (message passing, file reservation, search)
- **Integrate seamlessly** into any Python project as a git submodule

**Use this when:** Building AI agent workflows that need human-in-the-loop notifications and standardized issue tracking.

## Quick Start

### As a Git Submodule (Recommended)

```bash
# In your project root
git submodule add https://github.com/DataViking-Tech/ai-coding-utils.git tooling/ai-coding-utils
git submodule update --init --recursive

# Use the Slack CLI
python -m tooling.ai-coding-utils.slack.cli review "Need human input on API design"
```

### As a Python Package (Development)

```bash
# Clone and install in editable mode
git clone https://github.com/DataViking-Tech/ai-coding-utils.git
cd ai-coding-utils
pip install -e .
```

## Features

### 1. Slack CLI for Agent Notifications

Send structured notifications from AI agents to Slack channels.

```bash
# Request human review
python -m slack.cli review "Need approval on database schema changes"

# Report blocker
python -m slack.cli blocked "Waiting on API credentials from ops team"

# Send status update
python -m slack.cli message "Completed 3/5 tasks in epic frontline-xyz"

# Mark work complete
python -m slack.cli complete "All tests passing, PR #42 ready for review"

# Check configuration
python -m slack.cli check
```

**Slack message format:**
- Agent ID (from `BEADS_AGENT_ID` or hostname)
- Issue ID (from `BEADS_ISSUE_ID` or --issue flag)
- Color-coded by notification type (review=yellow, blocked=red, complete=green)

### 2. Beads Workflow Hooks

Git hooks for automatic beads issue tracking synchronization.

```bash
# Install hooks in your project
./beads/hooks/install.sh

# Available hooks:
# - pre-commit: Validates beads state before commit
# - post-checkout: Updates beads on branch switch
```

**What the hooks do:**
- Auto-sync beads on git operations
- Prevent commits with invalid beads state
- Track issue progress across branches

### 3. Python API

```python
from slack.notifier import SlackNotifier, SlackConfig

# Configure
config = SlackConfig(webhook_url="https://hooks.slack.com/...")
notifier = SlackNotifier(config)

# Send notification
success = notifier.send(
    text="Agent needs review",
    blocks=[
        {"type": "section", "text": {"type": "mrkdwn", "text": "*Review Request*"}}
    ]
)
```

**Rate limiting:** 30 requests per 60 seconds (automatically enforced)

## Integration Guide

### Adding to Existing Project

1. **Add as submodule:**
   ```bash
   git submodule add https://github.com/DataViking-Tech/ai-coding-utils.git tooling/ai-coding-utils
   ```

2. **Configure secrets:**
   ```bash
   mkdir -p .secrets
   chmod 700 .secrets
   echo "https://hooks.slack.com/services/YOUR/WEBHOOK/URL" > .secrets/slack_webhook
   chmod 600 .secrets/slack_webhook
   ```

3. **Set environment variables (optional):**
   ```bash
   export AI_CODING_UTILS_BASE="/path/to/your/project"
   export SLACK_WEBHOOK_URL="https://hooks.slack.com/..."  # Alternative to .secrets file
   export BEADS_AGENT_ID="my-agent-name"
   export BEADS_ISSUE_ID="frontline-abc"
   ```

4. **Install hooks (optional):**
   ```bash
   ./tooling/ai-coding-utils/beads/hooks/install.sh
   ```

### Usage in CI/CD

```yaml
# .github/workflows/agent-workflow.yml
- name: Notify on completion
  run: |
    python -m tooling.ai-coding-utils.slack.cli complete "Build passed, deployed to staging"
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
    BEADS_AGENT_ID: github-actions
    BEADS_ISSUE_ID: ${{ github.event.issue.number }}
```

## Configuration

### Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `AI_CODING_UTILS_BASE` | Project root for `.beads/` and `.secrets/` | Current directory |
| `SLACK_WEBHOOK_URL` | Slack webhook URL (alternative to secrets file) | None |
| `BEADS_AGENT_ID` | Agent identifier for notifications | Hostname |
| `BEADS_ISSUE_ID` | Current beads issue ID | None |

### Secrets File

Location: `$AI_CODING_UTILS_BASE/.secrets/slack_webhook`

```bash
# Create secrets file
mkdir -p .secrets
chmod 700 .secrets
echo "https://hooks.slack.com/services/T00/B00/xxx" > .secrets/slack_webhook
chmod 600 .secrets/slack_webhook
```

**Security:** Must be mode `0600` (read/write for owner only)

## Architecture

```
ai-coding-utils/
├── slack/              # Slack notification system
│   ├── cli.py          # Command-line interface
│   ├── notifier.py     # Core SlackNotifier class
│   └── config.py       # Configuration management
├── beads/              # Beads workflow integration
│   ├── hooks/          # Git hooks for auto-sync
│   └── patterns/       # Workflow examples
├── examples/           # Usage examples
└── tests/              # Contract and unit tests
```

**Key components:**
- **SlackNotifier**: Rate-limited, sanitized Slack webhook sender
- **SlackConfig**: Secure configuration from environment/files
- **CLI**: Simple agent-friendly command interface
- **Git hooks**: Automated beads synchronization

## API Reference

### SlackNotifier

```python
class SlackNotifier:
    def __init__(self, config: SlackConfig):
        """Initialize with configuration"""

    def send(self, text: str, blocks: Optional[list] = None) -> bool:
        """Send message to Slack. Returns True on success (HTTP 200)"""
```

### CLI Commands

```bash
python -m slack.cli review <message> [--issue ID]    # Request review
python -m slack.cli blocked <message> [--issue ID]   # Report blocker
python -m slack.cli message <message> [--issue ID]   # Send update
python -m slack.cli complete <message> [--issue ID]  # Mark complete
python -m slack.cli check                            # Validate config
```

**Exit codes:**
- `0` - Success (message sent or config valid)
- `1` - Failure (send failed or config missing)

## Examples

### Agent Review Workflow

```bash
# Agent starts work
bd update frontline-abc --status in_progress

# Agent encounters unclear requirement
python -m slack.cli review "Should we use OAuth2 or API keys for auth?" \
  --issue frontline-abc

# Human responds via Slack, agent continues...

# Agent completes work
bd close frontline-abc
python -m slack.cli complete "Authentication implemented with OAuth2" \
  --issue frontline-abc
```

### Multi-Agent Notification

```bash
# Agent A requests review
BEADS_AGENT_ID=agent-a python -m slack.cli review "PR #42 ready"

# Agent B reports blocker
BEADS_AGENT_ID=agent-b python -m slack.cli blocked "Waiting for PR #42 merge"
```

## Agent Mail (Multi-Agent Coordination)

The devcontainer includes [mcp-agent-mail](https://github.com/Dicklesworthstone/mcp_agent_mail), an MCP server that enables multi-agent coordination through message passing, file path reservation, and full-text search.

- **Server**: Runs on port 8765, auto-started in the devcontainer
- **Web UI**: http://localhost:8765/mail
- **MCP tools**: `register_agent`, `send_message`, `check_my_messages`, `reserve_file_paths`, `search_messages`

```bash
# Server management
am-start    # Start server
am-stop     # Stop server
am-logs     # View logs
```

See [AGENTS.md](AGENTS.md) for full tool documentation.

## Development

### Running Tests

```bash
# Install dev dependencies
pip install -r .devcontainer/requirements.txt

# Run tests
pytest tests/ -v

# Run contract tests only
pytest tests/contract/ -v
```

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## Related Projects

- **dev-infra** - Development infrastructure components (secrets, setup)
- **render-bridges** - GPU render queue and Blender/Godot integration
- **frontline-forge** - Main game project using these utilities

## License

See LICENSE file for details.

## Support

- Issues: https://github.com/DataViking-Tech/ai-coding-utils/issues
- Beads: Use `bd` for issue tracking in this repo
