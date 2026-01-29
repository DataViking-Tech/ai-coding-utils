# AI Coding Utils

Utilities for AI coding agents: Slack notifications, beads workflows, and hooks.

## Slack CLI

```bash
python -m slack.cli review "Need human input"
python -m slack.cli blocked "Waiting on dependency"
python -m slack.cli message "Status update"
python -m slack.cli complete "Finished work"
python -m slack.cli check
```

## Beads hooks

```bash
./beads/hooks/install.sh
```

## Environment

- `AI_CODING_UTILS_BASE` (optional) sets the project root for `.beads/` and `.secrets/`.
- `SLACK_WEBHOOK_URL` (optional) for webhook URL.
