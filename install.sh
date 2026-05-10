#!/bin/bash

# Install paper-reader-skill to Claude Code

SKILL_DIR="$HOME/.claude/skills/paper-reader"
CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing paper-reader skill..."

# Create skill directory
mkdir -p "$SKILL_DIR"

# Copy all files except .git
rsync -av --exclude='.git' "$CURRENT_DIR/" "$SKILL_DIR/"

echo "✓ Installed to $SKILL_DIR"
echo ""
echo "Usage: Share a paper with Claude Code and say '学习笔记' or 'Heilmeier分析'"