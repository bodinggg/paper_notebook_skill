#!/bin/bash

# Install paper-reader-skill to Claude Code

SKILL_DIR="$HOME/.claude/skills/paper-reader"
COMMAND_FILE="$HOME/.claude/commands/paper-reader.md"
CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing paper-reader skill..."

# Create skill directory
mkdir -p "$SKILL_DIR"

# Copy all files except .git
rsync -av --exclude='.git' "$CURRENT_DIR/" "$SKILL_DIR/"

echo "✓ Installed to $SKILL_DIR"

# Install slash command
mkdir -p "$HOME/.claude/commands"
cp "$CURRENT_DIR/.claude/commands/paper-reader.md" "$COMMAND_FILE"
echo "✓ Slash command registered: /paper-reader"
echo ""
echo "Usage:"
echo "  /paper-reader <论文链接或文件路径>"
echo "  or share a paper and say '学习笔记'"