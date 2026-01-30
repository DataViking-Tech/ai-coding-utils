#!/bin/bash
set -e

echo "Setting up AI Coding Utils development environment..."

# Python dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r .devcontainer/requirements.txt

# Install Claude CLI
echo "Installing Claude CLI..."
if ! command -v claude &> /dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
    echo "✓ Claude CLI installed"
else
    echo "✓ Claude CLI already installed"
fi

# Install Codex CLI
echo "Installing Codex CLI..."
if ! command -v codex &> /dev/null; then
    npm install -g @openai/codex
    echo "✓ Codex CLI installed"
else
    echo "✓ Codex CLI already installed"
fi

# Install beads (bd)
echo "Installing beads (bd)..."
if ! command -v bd &> /dev/null; then
    npm install -g @beads/bd
    echo "✓ beads (bd) installed"
else
    echo "✓ beads (bd) already installed"
fi

# Install mcp-agent-mail
echo "Installing mcp-agent-mail..."
if [ ! -d /opt/mcp-agent-mail ]; then
    # Install uv if not present
    if ! command -v uv &> /dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
        echo "✓ uv installed"
    fi

    # Clone and set up in isolated location
    sudo mkdir -p /opt/mcp-agent-mail
    sudo chown "$(whoami)" /opt/mcp-agent-mail
    git clone https://github.com/Dicklesworthstone/mcp_agent_mail.git /opt/mcp-agent-mail
    cd /opt/mcp-agent-mail
    uv venv .venv
    uv sync
    cd -

    # Generate bearer token
    mkdir -p ~/.secrets
    chmod 700 ~/.secrets
    python3 -c "import secrets; print(secrets.token_urlsafe(32))" > ~/.secrets/agent-mail-token
    chmod 600 ~/.secrets/agent-mail-token
    AGENT_MAIL_TOKEN=$(cat ~/.secrets/agent-mail-token)

    # Write .env for the server
    cat > /opt/mcp-agent-mail/.env <<ENVEOF
HTTP_BEARER_TOKEN=${AGENT_MAIL_TOKEN}
ENVEOF
    chmod 600 /opt/mcp-agent-mail/.env

    # Configure Claude MCP settings (merge into existing settings)
    CLAUDE_SETTINGS="$HOME/.claude/settings.json"
    mkdir -p "$HOME/.claude"
    if [ -f "$CLAUDE_SETTINGS" ]; then
        python3 -c "
import json, sys
settings = json.load(open('$CLAUDE_SETTINGS'))
settings.setdefault('mcpServers', {})
settings['mcpServers']['mcp-agent-mail'] = {
    'type': 'http',
    'url': 'http://127.0.0.1:8765/mcp/',
    'headers': {'Authorization': 'Bearer $AGENT_MAIL_TOKEN'}
}
json.dump(settings, open('$CLAUDE_SETTINGS', 'w'), indent=2)
"
    else
        python3 -c "
import json
settings = {
    'mcpServers': {
        'mcp-agent-mail': {
            'type': 'http',
            'url': 'http://127.0.0.1:8765/mcp/',
            'headers': {'Authorization': 'Bearer $AGENT_MAIL_TOKEN'}
        }
    }
}
json.dump(settings, open('$CLAUDE_SETTINGS', 'w'), indent=2)
"
    fi

    echo "✓ mcp-agent-mail installed"
else
    echo "✓ mcp-agent-mail already installed"
fi

# Start mcp-agent-mail server
AGENT_MAIL_TOKEN=$(cat ~/.secrets/agent-mail-token 2>/dev/null || true)
if [ -n "$AGENT_MAIL_TOKEN" ] && [ -d /opt/mcp-agent-mail ]; then
    echo "Starting mcp-agent-mail server..."
    cd /opt/mcp-agent-mail
    nohup .venv/bin/python -m mcp_agent_mail.http \
        --host 0.0.0.0 --port 8765 \
        > /tmp/mcp-agent-mail.log 2>&1 &
    cd -
    echo "✓ mcp-agent-mail server started on port 8765"
fi

# Add shell aliases for agent-mail management
if ! grep -q 'am-start' ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc <<'ALIASEOF'

# mcp-agent-mail aliases
alias am-start='cd /opt/mcp-agent-mail && nohup .venv/bin/python -m mcp_agent_mail.http --host 0.0.0.0 --port 8765 > /tmp/mcp-agent-mail.log 2>&1 & cd -'
alias am-stop='pkill -f "mcp_agent_mail.http" 2>/dev/null && echo "Stopped" || echo "Not running"'
alias am-logs='tail -f /tmp/mcp-agent-mail.log'
ALIASEOF
    echo "✓ Shell aliases added (am-start, am-stop, am-logs)"
fi

echo ""
echo "✓ Development environment ready"
echo ""
echo "Available tools:"
echo "  - Python $(python --version 2>&1 | cut -d' ' -f2)"
echo "  - Claude CLI $(claude --version 2>&1 || echo '(auth needed)')"
echo "  - Codex CLI $(codex --version 2>&1 || echo '(not authenticated)')"
echo "  - beads $(bd --version 2>&1)"
echo "  - mcp-agent-mail (http://localhost:8765/mail)"
