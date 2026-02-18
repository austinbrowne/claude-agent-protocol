#!/usr/bin/env bash
# Hook: Review-before-commit gate
# Event: PreToolUse (Bash matching "git commit")
# Purpose: Block commits when no review has been completed
#
# Checks for .todos/review-verdict.md. If absent or verdict is BLOCK,
# prevents the commit. Override with SKIP_REVIEW=1.

# Allow override
if [ "$SKIP_REVIEW" = "1" ]; then
  exit 0
fi

# Read tool input from stdin
INPUT=$(cat)

# Check if this is a git commit command
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [[ "$COMMAND" != *"git commit"* ]]; then
  exit 0
fi

# Check for review verdict file
VERDICT_FILE=".todos/review-verdict.md"

if [ ! -f "$VERDICT_FILE" ]; then
  echo '{"decision": "block", "reason": "No review completed. Run /review before committing, or set SKIP_REVIEW=1 to override."}'
  exit 0
fi

# Extract verdict from YAML frontmatter
VERDICT=$(grep -m1 "^verdict:" "$VERDICT_FILE" | sed 's/verdict: *//' | tr -d '[:space:]')

if [ "$VERDICT" = "BLOCK" ]; then
  echo '{"decision": "block", "reason": "Review verdict is BLOCK. Fix critical findings before committing, or set SKIP_REVIEW=1 to override."}'
  exit 0
fi

exit 0
