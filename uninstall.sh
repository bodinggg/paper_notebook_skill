#!/bin/bash

# Uninstall paper-reader-skill from Claude Code

SKILL_DIR="$HOME/.claude/skills/paper-reader"

echo "Uninstalling paper-reader skill..."

if [ -d "$SKILL_DIR" ]; then
    rm -rf "$SKILL_DIR"
    echo "✓ Uninstalled from $SKILL_DIR"
else
    echo "✗ Skill not found at $SKILL_DIR"
fi