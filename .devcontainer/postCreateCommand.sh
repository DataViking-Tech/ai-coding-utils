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
    npm install -g @anthropic-ai/claude-cli
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

echo ""
echo "✓ Development environment ready"
echo ""
echo "Available tools:"
echo "  - Python $(python --version 2>&1 | cut -d' ' -f2)"
echo "  - Claude CLI $(claude --version 2>&1 || echo '(auth needed)')"
echo "  - Codex CLI $(codex --version 2>&1 || echo '(not authenticated)')"
echo "  - beads $(bd --version 2>&1)"
