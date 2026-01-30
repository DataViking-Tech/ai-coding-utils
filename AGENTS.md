# AI Agent Guide - AI Coding Utils

**Quick reference for AI coding agents working on ai-coding-utils.**

This is a reusable utility library for AI agent workflows. It provides Slack notifications, beads workflow integration, and git hooks.

---

## First Time Here?

**Read this file first** (3 minutes) → Then reference [README.md](README.md) for API details.

---

## Project Overview

**AI Coding Utils** provides infrastructure for AI coding agents to:
- Send Slack notifications (review requests, blockers, status updates)
- Integrate with beads issue tracking
- Automate git hooks for workflow synchronization

**Used by:** frontline-forge, and other projects requiring AI agent coordination.

**Tech stack:**
- Python 3.12
- Pytest for testing
- Requests library for Slack webhooks
- Git hooks for automation

---

## Quick Start Workflow

### 1. Find Available Work
```bash
bd ready                    # List tasks with no blockers
bd show <id>                # Read full task details
bd update <id> --claim      # Atomically claim task
```

### 2. Development Environment

**Running from submodule context:**
```bash
cd tooling/ai-coding-utils
python -m slack.cli check   # Test Slack configuration
pytest tests/ -v            # Run all tests
```

**Running from parent project:**
```bash
# Python wrapper handles PYTHONPATH correctly
./bin/py -m tooling.ai_coding_utils.slack.cli check
```

### 3. Run Tests Before Committing
```bash
# Install dev dependencies
pip install -r .devcontainer/requirements.txt

# Run all tests
pytest tests/ -v

# Run specific test category
pytest tests/contract/ -v     # Contract tests only
pytest tests/unit/ -v         # Unit tests only
```

### 4. Commit Your Work
```bash
git add <specific-files>    # Add specific files (not -A)
git commit -m "Your message"
git push origin main
```

**For version bumps:** Use semantic versioning tags:
```bash
git tag v1.2.3              # Patch, minor, or major version
git push origin main --tags
```

### 5. Complete Task
```bash
bd close <id>               # Mark task complete
bd ready                    # Find next task
```

---

## Repository Structure

```
ai-coding-utils/
├── slack/              # Slack notification system
│   ├── cli.py          # Command-line interface for agents
│   ├── notifier.py     # Core SlackNotifier class
│   └── config.py       # Configuration from env/files
├── beads/              # Beads workflow integration
│   ├── hooks/          # Git hooks for auto-sync
│   └── patterns/       # Workflow examples
├── examples/           # Usage examples
├── tests/              # Contract and unit tests
│   ├── contract/       # API contract tests
│   └── unit/           # Unit tests
└── .devcontainer/      # Development container setup
```

---

## Common Commands

### Slack CLI Testing
```bash
# Check configuration (validates webhook URL and env vars)
python -m slack.cli check

# Send test notifications
python -m slack.cli review "Test review request" --issue test-123
python -m slack.cli blocked "Test blocker" --issue test-123
python -m slack.cli message "Test message" --issue test-123
python -m slack.cli complete "Test completion" --issue test-123
```

**Exit codes:**
- `0` - Success (message sent or config valid)
- `1` - Failure (send failed or config missing)

### Running Tests
```bash
# Quick test run
pytest tests/ -v

# With coverage
pytest tests/ --cov=slack --cov-report=term-missing

# Specific test file
pytest tests/unit/test_notifier.py -v

# Watch mode (requires pytest-watch)
ptw tests/ -- -v
```

### Development Workflow
```bash
# 1. Make changes to code
vim slack/notifier.py

# 2. Add tests
vim tests/unit/test_notifier.py

# 3. Run tests
pytest tests/ -v

# 4. Test integration with parent project
cd /workspaces/frontline-forge
./bin/py -m tooling.ai_coding_utils.slack.cli check

# 5. Commit
cd /workspaces/frontline-forge/tooling/ai-coding-utils
git add slack/ tests/
git commit -m "feat: add retry logic to SlackNotifier"
git push origin main
```

---

## Integration Examples

### Using in Parent Project

**As a submodule:**
```bash
# In parent project root
git submodule add https://github.com/DataViking-Tech/ai-coding-utils.git tooling/ai-coding-utils
git submodule update --init --recursive
```

**Using Slack CLI:**
```bash
# From parent project
python -m tooling.ai_coding_utils.slack.cli review "Need approval"
```

**Using Python API:**
```python
# In parent project code
from tooling.ai_coding_utils.slack.notifier import SlackNotifier, SlackConfig

config = SlackConfig()  # Auto-loads from environment
notifier = SlackNotifier(config)
notifier.send(text="Agent completed task", blocks=[...])
```

### Configuration Setup

**Environment variables:**
```bash
export AI_CODING_UTILS_BASE="/workspaces/frontline-forge"
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
export BEADS_AGENT_ID="my-agent"
export BEADS_ISSUE_ID="frontline-abc"
```

**Secrets file (recommended):**
```bash
# In parent project
mkdir -p .secrets
chmod 700 .secrets
echo "https://hooks.slack.com/..." > .secrets/slack_webhook
chmod 600 .secrets/slack_webhook
```

---

## Testing Workflows

### Contract Tests

Verify API contracts remain stable:
```bash
pytest tests/contract/ -v
```

**What contract tests check:**
- SlackNotifier API surface
- CLI command signatures
- Configuration loading behavior
- Error handling contracts

### Unit Tests

Test individual components:
```bash
pytest tests/unit/ -v
```

**What unit tests check:**
- Slack message formatting
- Rate limiting logic
- Configuration validation
- CLI argument parsing

### Integration Testing

Test with parent project:
```bash
# In frontline-forge
./bin/py -m tooling.ai_coding_utils.slack.cli check
./bin/py python/slack_notify.py review "Test from parent"
```

---

## Common Workflows

### Adding a New Slack Notification Type

1. **Add CLI command** (`slack/cli.py`):
   ```python
   @cli.command()
   @click.argument('message')
   def warning(message: str):
       """Send warning notification."""
       # Implementation
   ```

2. **Add color mapping** (if needed):
   ```python
   COLOR_MAP = {
       'review': '#FFA500',
       'blocked': '#FF0000',
       'warning': '#FFFF00',  # New
   }
   ```

3. **Add tests**:
   ```python
   # tests/unit/test_cli.py
   def test_warning_command():
       result = runner.invoke(cli, ['warning', 'Test warning'])
       assert result.exit_code == 0
   ```

4. **Update README** with new command

### Fixing a Bug

1. **Create test that reproduces bug**:
   ```python
   # tests/unit/test_notifier.py
   def test_bug_xyz():
       # Reproduce the bug
       assert False, "Bug not fixed yet"
   ```

2. **Fix the code** until test passes

3. **Run all tests** to ensure no regressions:
   ```bash
   pytest tests/ -v
   ```

4. **Commit with semver tag**:
   ```bash
   git commit -m "fix: handle empty message gracefully"
   git tag v1.2.4
   git push origin main --tags
   ```

### Adding Git Hook

1. **Create hook script** in `beads/hooks/`:
   ```bash
   #!/bin/bash
   # pre-commit hook
   bd sync
   ```

2. **Add install script** (`beads/hooks/install.sh`)

3. **Document in README**

4. **Test in parent project**:
   ```bash
   cd /workspaces/frontline-forge
   ./tooling/ai-coding-utils/beads/hooks/install.sh
   git commit -m "test"  # Should trigger hook
   ```

---

## When You Need More Info

| Topic | Read This |
|-------|-----------|
| **Full API reference** | [README.md](README.md) |
| **Slack CLI usage** | [README.md](README.md) → Slack CLI |
| **Python API** | [README.md](README.md) → Python API |
| **Integration guide** | [README.md](README.md) → Integration Guide |
| **Configuration** | [README.md](README.md) → Configuration |
| **Architecture** | [README.md](README.md) → Architecture |
| **Examples** | [README.md](README.md) → Examples |

---

## Before Claiming Work Complete

**STOP** - Before saying "done" or closing a task, verify:

1. **Tests pass:**
   ```bash
   pytest tests/ -v
   ```

2. **Code follows patterns:**
   - Type hints on all functions
   - Docstrings for public APIs
   - Error handling for network calls

3. **Integration works:**
   ```bash
   # Test in parent project
   cd /workspaces/frontline-forge
   ./bin/py -m tooling.ai_coding_utils.slack.cli check
   ```

4. **Documentation updated:**
   - README.md (if API changed)
   - AGENTS.md (if workflow changed)
   - Docstrings (always)

---

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
   ```bash
   pytest tests/ -v
   ```
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

---

## Multi-Agent Coordination

This is a shared utility library. Before making changes:

1. **Check dependent projects:**
   - frontline-forge uses this as submodule
   - Breaking changes affect all consumers

2. **Coordinate via beads:**
   ```bash
   bd list --status=in_progress  # See what others are working on
   bd comment <id> "Planning to change SlackNotifier API"
   ```

3. **Use semantic versioning:**
   - Patch (v1.2.3 → v1.2.4): Bug fixes, no API changes
   - Minor (v1.2.3 → v1.3.0): New features, backward compatible
   - Major (v1.2.3 → v2.0.0): Breaking changes

4. **Test in parent projects:**
   ```bash
   cd /workspaces/frontline-forge
   ./bin/py -m tooling.ai_coding_utils.slack.cli check
   # Run parent project tests
   ```

---

**You're ready to start.** Run `bd ready` and pick your first task.

For detailed API documentation, see [README.md](README.md).
