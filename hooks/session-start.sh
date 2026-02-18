#!/usr/bin/env bash
# Hook: Session start primer
# Event: SessionStart
# Purpose: Detect stale state files and warn about them

WARNINGS=""

# Check for stale loop context
if [ -f ".claude/loop-context.md" ]; then
  STATUS=$(grep -m1 "^status:" ".claude/loop-context.md" | sed 's/status: *//' | tr -d '[:space:]')
  if [ "$STATUS" = "running" ]; then
    STARTED=$(grep -m1 "^started_at:" ".claude/loop-context.md" | sed 's/started_at: *//' | tr -d '"' | tr -d '[:space:]')
    WARNINGS="${WARNINGS}WARNING: Stale loop-context.md found (status: running, started: ${STARTED}). A previous /loop may not have completed cleanly.\n"
  fi
fi

# Check for stale review verdict (older than 24 hours)
if [ -f ".todos/review-verdict.md" ]; then
  TIMESTAMP=$(grep -m1 "^timestamp:" ".todos/review-verdict.md" | sed 's/timestamp: *//' | tr -d '"' | tr -d '[:space:]')
  if [ -n "$TIMESTAMP" ]; then
    VERDICT_EPOCH=$(date -d "$TIMESTAMP" +%s 2>/dev/null || echo "0")
    NOW_EPOCH=$(date +%s)
    AGE_HOURS=$(( (NOW_EPOCH - VERDICT_EPOCH) / 3600 ))
    if [ "$AGE_HOURS" -gt 24 ]; then
      WARNINGS="${WARNINGS}NOTE: Review verdict is ${AGE_HOURS}h old. May be stale if you've made changes since.\n"
    fi
  fi
fi

if [ -n "$WARNINGS" ]; then
  echo -e "$WARNINGS"
fi

exit 0
