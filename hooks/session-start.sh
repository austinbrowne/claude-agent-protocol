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
    # Validate timestamp is ISO 8601 format before passing to date
    if ! echo "$TIMESTAMP" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}'; then
      WARNINGS="${WARNINGS}NOTE: Review verdict timestamp is not valid ISO 8601: ${TIMESTAMP}\n"
      VERDICT_EPOCH="0"
    elif date -d "2000-01-01" +%s >/dev/null 2>&1; then
      # GNU date (Linux)
      VERDICT_EPOCH=$(date -d "$TIMESTAMP" +%s 2>/dev/null || echo "0")
    elif date -j -f "%Y-%m-%dT%H:%M:%S" "2000-01-01T00:00:00" +%s >/dev/null 2>&1; then
      # BSD date (macOS) — strip timezone suffix for parsing
      CLEAN_TS=$(echo "$TIMESTAMP" | sed 's/Z$//; s/[+-][0-9][0-9]:[0-9][0-9]$//; s/[+-][0-9]\{4\}$//')
      VERDICT_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$CLEAN_TS" +%s 2>/dev/null || echo "0")
    else
      # Fallback: skip staleness check
      VERDICT_EPOCH="0"
      WARNINGS="${WARNINGS}NOTE: Could not parse review verdict timestamp (unsupported date command).\n"
    fi
    NOW_EPOCH=$(date +%s)
    # Guard: skip if parse failed (0) or timestamp is in the future (clock skew)
    if [ "$VERDICT_EPOCH" != "0" ] && [ "$NOW_EPOCH" -ge "$VERDICT_EPOCH" ]; then
      AGE_HOURS=$(( (NOW_EPOCH - VERDICT_EPOCH) / 3600 ))
    else
      AGE_HOURS=0
    fi
    if [ "$VERDICT_EPOCH" != "0" ] && [ "$AGE_HOURS" -gt 24 ]; then
      WARNINGS="${WARNINGS}NOTE: Review verdict is ${AGE_HOURS}h old. May be stale if you've made changes since.\n"
    fi
  fi
fi

if [ -n "$WARNINGS" ]; then
  echo -e "$WARNINGS"
fi

exit 0
