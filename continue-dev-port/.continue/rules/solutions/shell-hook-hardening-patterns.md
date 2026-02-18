---
alwaysApply: false
description: "Solution: Shell hook hardening patterns — stdin consumption, jq for JSON, allowlist gates, cross-platform date parsing in hook scripts"
module: Hooks
date: 2026-02-18
problem_type: best_practice
component: tooling
symptoms:
  - "Broken pipe errors when hook exits before consuming stdin"
  - "Malformed JSON output when shell variable contains quotes or special chars"
  - "Review gate silently permits commits with unrecognized verdict values"
  - "Cross-platform date parsing fails on macOS (BSD date vs GNU date)"
root_cause: logic_error
resolution_type: code_fix
severity: high
tags: [shell, hooks, stdin, json, jq, date-parsing, bsd, macos, allowlist, review-gate, cross-platform]
---

# Best Practice: Shell Hook Hardening Patterns

## Problem

Shell hooks (PreToolUse, SessionStart) are shell scripts that receive tool input JSON on stdin and return structured JSON decisions. Several non-obvious patterns cause silent failures: broken pipes, malformed JSON, bypassed gates, and cross-platform date incompatibilities.

## Environment

- Module: Hook scripts
- Language: Bash
- Affected Component: `hooks/*.sh` (PreToolUse, SessionStart event handlers)
- Date: 2026-02-18

## Symptoms

- Broken pipe errors when a hook exits before consuming stdin
- Malformed JSON output when a shell variable contains `"`, `\`, or newline characters
- Review gate silently permits commits when verdict value is unrecognized (typo, format change)
- Date parsing fails silently on macOS, skipping staleness checks

## What Didn't Work

**Attempted: Blocklist approach for verdicts** — Checking only `if [ "$VERDICT" = "BLOCK" ]` and letting everything else pass through. A typo like `APPROAVED` silently permits the commit.

**Attempted: String interpolation for JSON** — Using `"${VERDICT}"` inside a manually-constructed JSON string. Any special characters in the variable break the JSON structure.

**Attempted: GNU-only date parsing** — `date -d "$TIMESTAMP"` works on Linux but fails silently on macOS/BSD.

## Solution

### 1. Always consume stdin before early exit

```bash
# WRONG — broken pipe if hook runner expects stdin to be drained:
if [ "$SKIP_CHECK" = "1" ]; then
  exit 0
fi
INPUT=$(cat)

# RIGHT — consume stdin first, then check early-exit conditions:
INPUT=$(cat)
if [ "$SKIP_CHECK" = "1" ]; then
  exit 0
fi
```

### 2. Use jq for JSON construction with variables

```bash
# WRONG — breaks if VERDICT contains quotes:
echo "{\"decision\": \"block\", \"reason\": \"Unknown verdict '${VERDICT}'\"}"

# RIGHT — jq safely escapes all special characters:
jq -n --arg v "$VERDICT" \
  '{"decision": "block", "reason": ("Unknown verdict: " + $v)}'
```

### 3. Use allowlist (case statement) for gate values

```bash
# WRONG — blocklist only catches known-bad values:
if [ "$VERDICT" = "BLOCK" ]; then block; fi
# Unknown values silently pass through!

# RIGHT — allowlist with safe default:
case "$VERDICT" in
  APPROVED|APPROVED_WITH_NOTES) exit 0 ;;
  BLOCK|FIX_BEFORE_COMMIT)
    echo '{"decision":"block","reason":"..."}'
    exit 0 ;;
  *)
    # Unknown = block (safe default)
    jq -n --arg v "$VERDICT" '{"decision":"block","reason":("Unknown: "+$v)}'
    exit 0 ;;
esac
```

### 4. Cross-platform date parsing

```bash
# Validate format first (structural check):
if ! echo "$TS" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}'; then
  EPOCH="0"  # Invalid format — skip
elif date -d "2000-01-01" +%s >/dev/null 2>&1; then
  # GNU date (Linux)
  EPOCH=$(date -d "$TS" +%s 2>/dev/null || echo "0")
elif date -j -f "%Y-%m-%dT%H:%M:%S" "2000-01-01T00:00:00" +%s >/dev/null 2>&1; then
  # BSD date (macOS) — strip ALL timezone suffix variants
  CLEAN=$(echo "$TS" | sed 's/Z$//; s/[+-][0-9][0-9]:[0-9][0-9]$//; s/[+-][0-9]\{4\}$//')
  EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$CLEAN" +%s 2>/dev/null || echo "0")
else
  EPOCH="0"  # Unsupported platform — skip gracefully
fi

# Guard against future timestamps (clock skew):
NOW=$(date +%s)
if [ "$EPOCH" != "0" ] && [ "$NOW" -ge "$EPOCH" ]; then
  AGE_HOURS=$(( (NOW - EPOCH) / 3600 ))
else
  AGE_HOURS=0
fi
```

## Why This Works

1. **Stdin consumption:** The hook runner pipes tool input JSON to the script's stdin. If the script exits without reading it, the pipe breaks. Moving `INPUT=$(cat)` to the top ensures the pipe is always drained.

2. **jq encoding:** `jq -n --arg` treats the variable as a string value, automatically escaping `"`, `\`, newlines, and control characters per JSON spec.

3. **Allowlist pattern:** A case statement with explicit known values and a `*` default that blocks is fail-safe. New verdict values require explicit opt-in, not accidental pass-through.

4. **Platform detection:** Testing `date -d` with a known value determines GNU vs BSD at runtime. The `|| echo "0"` fallback plus `!= "0"` guard makes invalid timestamps skip the check rather than produce garbage.

## Prevention

- Always test hooks on both Linux and macOS if cross-platform support is needed
- Never interpolate variables directly into JSON strings — use jq
- Default to the safe action (block/deny) for unrecognized values in security gates
- Always consume stdin before any early exit in hook scripts
- Use `|| echo "fallback"` with subsequent guard checks rather than letting commands fail silently
- Test hooks with malformed input: empty files, missing fields, special characters in values
