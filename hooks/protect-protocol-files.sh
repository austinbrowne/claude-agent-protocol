#!/usr/bin/env bash
# Hook: Protected file guard
# Event: PreToolUse (Edit, Write)
# Purpose: Prevent /loop workers from modifying protocol files
#
# Only blocks when CLAUDE_LOOP_WORKER=1 (set in /loop worker spawn prompt).
# Interactive sessions are not affected.

# Only enforce for loop workers
if [ "$CLAUDE_LOOP_WORKER" != "1" ]; then
  exit 0
fi

# Read the tool input from stdin
INPUT=$(cat)

# Extract file path from the tool input JSON
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.content // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Protected path patterns (relative to .claude/)
PROTECTED_PATTERNS=(
  "commands/"
  "agents/"
  "skills/"
  "guides/"
  "templates/"
  "checklists/"
  "hooks/"
  "AI_CODING_AGENT_GODMODE.md"
  "CLAUDE.md"
  "QUICK_START.md"
  "settings.json"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo '{"decision": "block", "reason": "Protected protocol file. Loop workers cannot modify commands/, agents/, skills/, guides/, templates/, checklists/, hooks/, or core config files."}'
    exit 0
  fi
done

exit 0
