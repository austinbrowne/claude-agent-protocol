---
description: Quick fix orchestrator — minimal flow for obvious fixes where root cause is known
---

# /quickfix

**Description:** Minimal fix flow for obvious issues where the root cause is already known

**When to use:**
- Typo-level fixes, config changes, obvious one-liners
- Root cause is already known — no investigation needed
- Small, well-understood changes
- Want the fastest path from fix to shipped

**When NOT to use (use `/bugfix` instead):**
- Root cause is unclear
- Bug needs investigation
- Fix involves multiple files or complex logic

**Prerequisites:** None (entry point command)

---

## Invocation

**Interactive mode:**
User types `/quickfix` with no arguments. Claude asks what to fix.

**Direct mode:**
User types `/quickfix [issue-number-or-description]` to start immediately.

---

## Arguments

- `[issue-number]` - GitHub issue number (e.g., `789`)
- `[description]` - Natural language fix description (e.g., `"fix typo in error message"`)

---

## Execution

### Step 1: Fix

**If issue number provided:**
- Invoke `/start-issue [number]` (creates branch, assigns issue)

**If description provided:**
- Implement fix inline based on description

**After fix:**
- Stage changes: `git add [files]`

---

### Step 2: Quick Review

- Invoke `/fresh-eyes-review --lite`
- Lite review: Security + Edge Case + Supervisor only
- If APPROVED: continue to Step 3
- If issues found: fix and re-run lite review

---

### Step 3: Compound (if learning discovered)

```
AskUserQuestion:
  question: "Did you discover anything worth capturing as a learning?"
  header: "Compound"
  options:
    - label: "Run /compound"
      description: "Capture what you learned for future reference"
    - label: "Skip"
      description: "Nothing noteworthy — proceed to commit"
```

---

### Step 4: Ship

- Invoke `/commit-and-pr`

---

## Flow Diagram

```
/quickfix [issue-or-description]
  ├─ /start-issue (or inline fix) → [implement fix]
  ├─ /fresh-eyes-review --lite
  ├─ /compound (if learning discovered)
  └─ /commit-and-pr
```

---

## Key Differences from /bugfix

| | `/bugfix` | `/quickfix` |
|---|---|---|
| **Investigation** | Yes — explore + learnings search | No — you already know the cause |
| **Brainstorming** | Optional | Never |
| **Review depth** | Lite (default) | Lite (always) |
| **Compound** | Strongly recommended | Only if learning found |
| **Typical scope** | Moderate bug fixes | Typos, config, one-liners |

---

## Skills Referenced

- `skills/fresh-eyes-review/SKILL.md` — Lite review mode
- `skills/compound/SKILL.md` — Optional learning capture

---

## Notes

- **No investigation**: This is the key differentiator — you already know what's wrong
- **Fastest path**: Fix → lite review → commit — that's it
- **Still reviews**: Even quick fixes get a lite security + edge case review
- **Compound is optional**: Only suggest if something non-obvious was discovered
- **Use judiciously**: If the fix turns out to be complex, switch to `/bugfix`
