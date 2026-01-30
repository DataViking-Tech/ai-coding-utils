# AI Agent Documentation - AI Coding Utils

**This project supports multiple AI coding agents.**

For quick start and common workflows, see **[AGENTS.md](AGENTS.md)** (3 minute read).

For comprehensive API documentation, see **[README.md](README.md)**.

---

## Quick Navigation

| What You Need | Read This |
|---------------|-----------|
| **First time here?** | [AGENTS.md](AGENTS.md) - Quick start guide |
| **How do I start a task?** | [AGENTS.md](AGENTS.md) → Quick Start Workflow |
| **How do I test my changes?** | [AGENTS.md](AGENTS.md) → Running Tests |
| **Slack CLI usage?** | [README.md](README.md) → Slack CLI |
| **Python API reference?** | [README.md](README.md) → Python API |
| **Integration with parent projects?** | [AGENTS.md](AGENTS.md) → Integration Examples |
| **How do I add a new notification type?** | [AGENTS.md](AGENTS.md) → Common Workflows |
| **Configuration options?** | [README.md](README.md) → Configuration |

---

## Supported AI Agents

This codebase is designed to work with:
- **Claude Code** (claude.ai/code) - You're here! Start with [AGENTS.md](AGENTS.md)
- **GitHub Copilot** - Use [AGENTS.md](AGENTS.md) as your entry point
- **Cursor** - Use [AGENTS.md](AGENTS.md) as your entry point
- **Windsurf** - Use [AGENTS.md](AGENTS.md) as your entry point
- **Roo Code** - Use [AGENTS.md](AGENTS.md) as your entry point
- **Aider** - Use [AGENTS.md](AGENTS.md) as your entry point
- **Other AI coding tools** - Start with [AGENTS.md](AGENTS.md)

---

## Documentation Structure

```
AGENTS.md (READ THIS FIRST)    # Quick start workflow guide
CLAUDE.md (this file)          # Navigation hub
README.md                      # Comprehensive API documentation
CONTRIBUTING.md                # Development setup
```

---

## Quick Commands

### Find Work
```bash
bd ready                    # List available tasks
bd show <id>                # Read task details
bd update <id> --claim      # Claim task atomically
```

### Testing
```bash
pytest tests/ -v                    # Run all tests
pytest tests/contract/ -v           # Contract tests only
pytest tests/unit/ -v               # Unit tests only
```

### Slack CLI
```bash
python -m slack.cli check           # Validate configuration
python -m slack.cli review "msg"    # Request review
python -m slack.cli blocked "msg"   # Report blocker
python -m slack.cli complete "msg"  # Mark complete
```

### Development
```bash
# Test integration with parent project
cd /workspaces/frontline-forge
./bin/py -m tooling.ai_coding_utils.slack.cli check

# Commit and tag
git commit -m "feat: new feature"
git tag v1.2.3
git push origin main --tags
```

---

**Start here:** Read [AGENTS.md](AGENTS.md) for a complete workflow guide.
