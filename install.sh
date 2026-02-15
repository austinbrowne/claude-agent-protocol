#!/bin/bash
#
# Claude Agent Protocol Installer
# Installs slash commands, checklists, guides, and templates to ~/.claude/
#

set -e

CLAUDE_DIR="$HOME/.claude"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Agent Protocol Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create directories if they don't exist
echo "Creating directories..."
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/checklists"
mkdir -p "$CLAUDE_DIR/guides"
mkdir -p "$CLAUDE_DIR/templates"
mkdir -p "$CLAUDE_DIR/platforms"

# Symlink core protocol files
echo "Installing core protocol files..."
ln -sf "$REPO_DIR/AI_CODING_AGENT_GODMODE.md" "$CLAUDE_DIR/"
ln -sf "$REPO_DIR/PRD_TEMPLATE.md" "$CLAUDE_DIR/"
ln -sf "$REPO_DIR/QUICK_START.md" "$CLAUDE_DIR/"

# Symlink commands
echo "Installing slash commands..."
for f in "$REPO_DIR/commands/"*.md; do
  if [ -f "$f" ]; then
    ln -sf "$f" "$CLAUDE_DIR/commands/"
  fi
done

# Symlink checklists
echo "Installing checklists..."
for f in "$REPO_DIR/checklists/"*.md; do
  if [ -f "$f" ]; then
    ln -sf "$f" "$CLAUDE_DIR/checklists/"
  fi
done

# Symlink guides
echo "Installing guides..."
for f in "$REPO_DIR/guides/"*.md; do
  if [ -f "$f" ]; then
    ln -sf "$f" "$CLAUDE_DIR/guides/"
  fi
done

# Symlink templates
echo "Installing templates..."
for f in "$REPO_DIR/templates/"*.md; do
  if [ -f "$f" ]; then
    ln -sf "$f" "$CLAUDE_DIR/templates/"
  fi
done

# Symlink platforms
echo "Installing platform files..."
for f in "$REPO_DIR/platforms/"*.md; do
  if [ -f "$f" ]; then
    ln -sf "$f" "$CLAUDE_DIR/platforms/"
  fi
done

# Handle CLAUDE.md specially - don't overwrite existing
echo ""
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  echo -e "${YELLOW}⚠  CLAUDE.md already exists at $CLAUDE_DIR/CLAUDE.md${NC}"
  echo "   Creating CLAUDE.md.example instead (won't overwrite your config)"
  cp "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.example"
  echo ""
  echo "   To use the protocol's CLAUDE.md, either:"
  echo "   1. Merge contents from CLAUDE.md.example into your CLAUDE.md"
  echo "   2. Or replace: cp ~/.claude/CLAUDE.md.example ~/.claude/CLAUDE.md"
else
  echo "Installing CLAUDE.md..."
  ln -sf "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Installed to: $CLAUDE_DIR"
echo ""
echo "Available slash commands:"
echo "  /explore          - Codebase exploration"
echo "  /generate-prd     - Create PRD (Lite or Full)"
echo "  /create-adr       - Document architecture decisions"
echo "  /create-issues    - Generate issues from PRD"
echo "  /start-issue      - Begin work on an issue"
echo "  /generate-tests   - Generate comprehensive tests"
echo "  /security-review  - Run OWASP security checklist"
echo "  /run-validation   - Tests + coverage + lint + security"
echo "  /fresh-eyes-review - Multi-agent code review"
echo "  /recovery         - Handle failed implementations"
echo "  /commit-and-pr    - Commit and create PR"
echo "  /refactor         - Guided refactoring"
echo "  /finalize         - Final docs and validation"
echo ""
echo "Get started:"
echo "  1. Open Claude Code in any project"
echo "  2. Type /explore to explore the codebase"
echo "  3. See ~/.claude/QUICK_START.md for workflows"
echo ""
