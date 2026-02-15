#!/bin/bash
#
# Claude Agent Protocol Uninstaller
# Removes installed files from ~/.claude/
#

set -e

CLAUDE_DIR="$HOME/.claude"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Agent Protocol Uninstaller"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if ~/.claude exists
if [ ! -d "$CLAUDE_DIR" ]; then
  echo -e "${YELLOW}⚠  $CLAUDE_DIR does not exist. Nothing to uninstall.${NC}"
  exit 0
fi

echo "This will remove Claude Agent Protocol files from $CLAUDE_DIR"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Uninstall cancelled."
  exit 0
fi

echo ""
echo "Removing core protocol files..."
rm -f "$CLAUDE_DIR/AI_CODING_AGENT_GODMODE.md"
rm -f "$CLAUDE_DIR/PRD_TEMPLATE.md"
rm -f "$CLAUDE_DIR/QUICK_START.md"
rm -f "$CLAUDE_DIR/CLAUDE.md.example"

echo "Removing slash commands..."
rm -f "$CLAUDE_DIR/commands/explore.md"
rm -f "$CLAUDE_DIR/commands/generate-prd.md"
rm -f "$CLAUDE_DIR/commands/create-adr.md"
rm -f "$CLAUDE_DIR/commands/create-issues.md"
rm -f "$CLAUDE_DIR/commands/create-issue-from-prd.md"
rm -f "$CLAUDE_DIR/commands/start-issue.md"
rm -f "$CLAUDE_DIR/commands/generate-tests.md"
rm -f "$CLAUDE_DIR/commands/security-review.md"
rm -f "$CLAUDE_DIR/commands/run-validation.md"
rm -f "$CLAUDE_DIR/commands/fresh-eyes-review.md"
rm -f "$CLAUDE_DIR/commands/recovery.md"
rm -f "$CLAUDE_DIR/commands/commit-and-pr.md"
rm -f "$CLAUDE_DIR/commands/refactor.md"
rm -f "$CLAUDE_DIR/commands/finalize.md"
rm -f "$CLAUDE_DIR/commands/review-agent-protocol.md"

echo "Removing checklists..."
rm -f "$CLAUDE_DIR/checklists/AI_CODE_SECURITY_REVIEW.md"
rm -f "$CLAUDE_DIR/checklists/AI_CODE_REVIEW.md"

echo "Removing guides..."
rm -f "$CLAUDE_DIR/guides/CONTEXT_OPTIMIZATION.md"
rm -f "$CLAUDE_DIR/guides/MULTI_AGENT_PATTERNS.md"
rm -f "$CLAUDE_DIR/guides/GITHUB_PROJECT_INTEGRATION.md"
rm -f "$CLAUDE_DIR/guides/GITLAB_PROJECT_INTEGRATION.md"
rm -f "$CLAUDE_DIR/guides/PROJECT_INTEGRATION.md"
rm -f "$CLAUDE_DIR/guides/FRESH_EYES_REVIEW.md"
rm -f "$CLAUDE_DIR/guides/FAILURE_RECOVERY.md"

echo "Removing templates..."
rm -f "$CLAUDE_DIR/templates/TEST_STRATEGY.md"
rm -f "$CLAUDE_DIR/templates/ADR_TEMPLATE.md"
rm -f "$CLAUDE_DIR/templates/ISSUE_TEMPLATE.md"
rm -f "$CLAUDE_DIR/templates/GITHUB_ISSUE_TEMPLATE.md"
rm -f "$CLAUDE_DIR/templates/RECOVERY_REPORT.md"

echo "Removing platform files..."
rm -f "$CLAUDE_DIR/platforms/detect.md"
rm -f "$CLAUDE_DIR/platforms/github.md"
rm -f "$CLAUDE_DIR/platforms/gitlab.md"

# Clean up empty directories (but don't remove ~/.claude itself)
rmdir "$CLAUDE_DIR/commands" 2>/dev/null || true
rmdir "$CLAUDE_DIR/checklists" 2>/dev/null || true
rmdir "$CLAUDE_DIR/guides" 2>/dev/null || true
rmdir "$CLAUDE_DIR/templates" 2>/dev/null || true
rmdir "$CLAUDE_DIR/platforms" 2>/dev/null || true

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Uninstall complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Note: Your CLAUDE.md file was preserved (if it existed).${NC}"
echo "      Remove manually if desired: rm ~/.claude/CLAUDE.md"
echo ""
