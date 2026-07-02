#!/bin/bash
# Install tools array
TOOLS=(
  "@anthropic-ai/claude-code"
  "codex-cli"
  "qwen-code"
  "gemini-cli"
  "goose-cli"
  "openclaw"
  "augment-code"
  "codebuddy"
  "kimi-cli"
  "opencode"
  "factory-droid"
  "@githubnext/github-copilot-cli"
  "qoder-cli"
  "mistral-vibe"
  "nanobot"
  "aion-cli"
  "snow-cli"
  "hermes-agent"
  "cursor-agent"
  "kiro"
  "command-code"
  "antigravity"
  "omniroute"
  "hermes-workspace"
  "aion-ui"
)

echo "Installing AI CLIs and Tools..."
for tool in "${TOOLS[@]}"; do
  echo "Attempting to install $tool via npm..."
  npm install -g "$tool" || echo "Warning: Could not install $tool. Continuing..."
done
echo "Tool installation complete."
