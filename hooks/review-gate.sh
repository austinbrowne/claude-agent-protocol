#!/usr/bin/env bash
# Hook: Review-before-commit gate
# Event: PreToolUse (Bash matching "git commit")
# Purpose: Block commits when no review has been completed
#
# Checks for .todos/review-verdict.md. If absent or verdict is BLOCK,
# prevents the commit. Override with SKIP_REVIEW=1.

# Read tool input from stdin (must happen before any early exit to avoid broken pipes)
INPUT=$(cat)

# Allow override (with audit trail — persistent + stderr)
if [ "$SKIP_REVIEW" = "1" ]; then
  echo "$(date -Iseconds) SKIP_REVIEW bypass" >> .todos/review-audit.log 2>/dev/null
  echo "WARNING: Review gate bypassed (SKIP_REVIEW=1)" >&2
  echo '{"decision": "allow", "reason": "SKIP_REVIEW=1 override — review gate bypassed by user"}'
  exit 0
fi

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

# Check file is not empty
if [ ! -s "$VERDICT_FILE" ]; then
  echo '{"decision": "block", "reason": "Review verdict file exists but is empty. Run /review to generate a proper verdict, or set SKIP_REVIEW=1 to override."}'
  exit 0
fi

# Extract verdict from YAML frontmatter
VERDICT=$(grep -m1 "^verdict:" "$VERDICT_FILE" | sed 's/verdict: *//' | tr -d '[:space:]' | tr -d '"' | tr -d "'")

if [ -z "$VERDICT" ]; then
  echo '{"decision": "block", "reason": "Review verdict file exists but has no verdict field. Run /review to generate a proper verdict, or set SKIP_REVIEW=1 to override."}'
  exit 0
fi

# Allowlist of recognized verdicts — unknown verdicts block as a safety default
case "$VERDICT" in
  BLOCK)
    echo '{"decision": "block", "reason": "Review verdict is BLOCK. Fix critical findings before committing, or set SKIP_REVIEW=1 to override."}'
    exit 0
    ;;
  FIX_BEFORE_COMMIT)
    echo '{"decision": "block", "reason": "Review verdict is FIX_BEFORE_COMMIT. Fix HIGH findings before committing, or set SKIP_REVIEW=1 to override."}'
    exit 0
    ;;
  APPROVED|APPROVED_WITH_NOTES)
    # Permit commit
    exit 0
    ;;
  *)
    jq -n --arg v "$VERDICT" '{"decision": "block", "reason": ("Unrecognized review verdict \u0027" + $v + "\u0027. Expected BLOCK, FIX_BEFORE_COMMIT, APPROVED_WITH_NOTES, or APPROVED. Set SKIP_REVIEW=1 to override.")}'
    exit 0
    ;;
esac
