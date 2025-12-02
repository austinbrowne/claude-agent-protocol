---
description: Multi-agent unbiased code review (zero context)
---

# /fresh-eyes-review

**Description:** Multi-agent unbiased code review (zero conversation context)

**When to use:**
- After validation passes (`/run-validation` complete)
- Need comprehensive, unbiased code review
- Before committing and creating PR
- GODMODE Phase 1 Step 6 (after validation, before commit)

**Prerequisites:**
- Code changes staged (`git add` completed)
- Validation passed (`/run-validation` shows PASS)

---

## Invocation

**Interactive mode:**
User types `/fresh-eyes-review` with no arguments. Claude auto-selects review tier based on LOC.

**Direct mode:**
User types `/fresh-eyes-review --lite`, `--standard`, or `--full` to specify tier.

---

## Arguments

- `--lite` - Lite review (Security + Supervisor only) for <100 LOC
- `--standard` - Standard review (Security + Code Quality + Supervisor) for 100-500 LOC
- `--full` - Full review (Security + Code Quality + Performance + Supervisor) for >500 LOC

---

## Execution Steps

### Step 1: Create diff file from staged changes

**Generate diff:**
```bash
git diff --staged > /tmp/review-diff.txt
```

**If no staged changes:**
```
⚠️  No staged changes found!

Stage your changes first:
  git add <files>

Or stage all changes:
  git add .

Then run: `/fresh-eyes-review`
```

### Step 2: Count lines of code changed

**Parse diff file:**
- Count added lines (+)
- Count removed lines (-)
- Total LOC changed = |added| + |removed|

**Example:**
- +150 lines added
- -50 lines removed
- Total: 200 LOC changed

### Step 3: Auto-select review tier (or use specified tier)

**Tier selection criteria:**

| LOC Changed | Recommended Tier | Agents |
|-------------|------------------|--------|
| <100 | Lite | Security + Supervisor |
| 100-500 | Standard | Security + Code Quality + Supervisor |
| >500 | Full | Security + Code Quality + Performance + Supervisor |

**If direct mode (--tier specified):**
- Use specified tier

**If interactive mode (no tier specified):**
- Auto-select based on LOC
- Confirm with user:
  ```
  👀 Fresh Eyes Code Review

  Changes: 234 lines
  Recommended: Standard Review (Security + Code Quality + Supervisor)

  Review tiers:
  1. Lite (<100 LOC): Security + Supervisor
  2. Standard (100-500 LOC): Security + Code Quality + Supervisor
  3. Full (>500 LOC): Security + Code Quality + Performance + Supervisor

  Use recommended tier [2]? (1/2/3): _____
  ```

### Step 4: Execute Fresh Eyes Review workflow

**Read:** `~/.claude/guides/FRESH_EYES_REVIEW.md`

**Launch review agents using Task tool:**

**Important:**
- Each agent has ZERO conversation context (fresh eyes)
- **CRITICAL: Launch ALL specialist agents IN PARALLEL using a single message with multiple Task tool calls**
- Only the Supervisor runs AFTER specialists complete (it needs their findings)

**For Lite tier:**
1. **PARALLEL:** Launch Security Agent
   - Reviews /tmp/review-diff.txt
   - Applies security checklist
   - Returns security findings
2. **AFTER Security completes:** Launch Supervisor Agent
   - Reviews /tmp/review-diff.txt + Security findings
   - Consolidates final verdict

**For Standard tier:**
1. **PARALLEL (single message, multiple Task calls):**
   - Security Agent - security checklist review
   - Code Quality Agent - naming, structure, complexity, edge cases
2. **AFTER both complete:** Launch Supervisor Agent
   - Reviews diff + both agent findings
   - Consolidates final verdict

**For Full tier:**
1. **PARALLEL (single message, multiple Task calls):**
   - Security Agent - security checklist review
   - Code Quality Agent - naming, structure, complexity, edge cases
   - Performance Agent - N+1 queries, inefficient algorithms, memory leaks
2. **AFTER all three complete:** Launch Supervisor Agent
   - Reviews diff + all agent findings
   - Consolidates final verdict

**Parallel agent launch pattern (MUST use single message):**
```
In ONE response, call Task tool THREE times:

Task 1:
- subagent_type: "general-purpose"
- description: "Fresh Eyes Security Review"
- prompt: "You are a security specialist..."

Task 2:
- subagent_type: "general-purpose"
- description: "Fresh Eyes Code Quality Review"
- prompt: "You are a code quality specialist..."

Task 3:
- subagent_type: "general-purpose"
- description: "Fresh Eyes Performance Review"
- prompt: "You are a performance specialist..."

All three run simultaneously. Wait for all to complete before launching Supervisor.
```

**Individual agent prompts:**

**Security Agent:**
```
You are a security specialist with zero context about this project.

Review the code changes in /tmp/review-diff.txt for security issues.

Apply the security checklist from ~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md.

Report findings with severity (CRITICAL, HIGH, MEDIUM, LOW).
```

**Code Quality Agent:**
```
You are a code quality specialist with zero context about this project.

Review the code changes in /tmp/review-diff.txt for code quality issues.

Check: naming conventions, code structure, cyclomatic complexity, edge case handling, error handling.

Report findings with severity (CRITICAL, HIGH, MEDIUM, LOW).
```

**Performance Agent:**
```
You are a performance specialist with zero context about this project.

Review the code changes in /tmp/review-diff.txt for performance issues.

Check: N+1 queries, inefficient algorithms, memory leaks, unnecessary allocations, missing pagination.

Report findings with severity (CRITICAL, HIGH, MEDIUM, LOW).
```

### Step 5: Consolidate findings from all agents

**Supervisor agent output format:**
```
=== FRESH EYES REVIEW VERDICT ===

Tier: Standard
Agents: Security, Code Quality, Supervisor
LOC Changed: 234 lines

=== CRITICAL ISSUES (BLOCK) ===
❌ [Security] SQL Injection in src/api/users.ts:45
   Finding: Raw SQL with user input
   Fix: Use parameterized queries

=== HIGH PRIORITY ISSUES (FIX BEFORE COMMIT) ===
⚠️  [Code Quality] Missing null check in src/auth/AuthService.ts:67
   Finding: user.email accessed without null check
   Fix: Add if (!user) guard clause

=== MEDIUM PRIORITY ISSUES (ADDRESS SOON) ===
⚠️  [Code Quality] Complex function in src/utils/validate.ts:23
   Finding: Cyclomatic complexity = 12 (target: <8)
   Fix: Extract helper functions

=== LOW PRIORITY / SUGGESTIONS ===
ℹ️  [Code Quality] Consider extracting magic number in src/config.ts:15
   Finding: Hardcoded 86400 (seconds in day)
   Suggestion: const SECONDS_PER_DAY = 86400

=== VERDICT ===
Status: FIX_BEFORE_COMMIT

Reason: 1 CRITICAL issue must be fixed before committing.

Action required:
1. Fix SQL injection in src/api/users.ts:45
2. Fix missing null check in src/auth/AuthService.ts:67
3. Re-run review after fixes

Confidence: HIGH_CONFIDENCE
```

### Step 6: Determine verdict

**Verdict categories:**

| Verdict | Meaning | Action |
|---------|---------|--------|
| **BLOCK** | Critical issues found, do NOT commit | Fix immediately, re-run review |
| **FIX_BEFORE_COMMIT** | High priority issues, fix before commit | Fix issues, re-run review |
| **APPROVED** | No blocking issues, safe to commit | Proceed to commit |
| **APPROVED_WITH_NOTES** | Minor issues noted, can commit | Proceed, address notes later |

**Severity thresholds:**
- 1+ CRITICAL → BLOCK
- 1+ HIGH → FIX_BEFORE_COMMIT
- MEDIUM/LOW only → APPROVED_WITH_NOTES
- No issues → APPROVED

### Step 7: Report findings and suggest next steps

**If BLOCK or FIX_BEFORE_COMMIT:**
```
❌ Fresh Eyes Review: FIX_BEFORE_COMMIT

1 CRITICAL, 1 HIGH, 1 MEDIUM, 1 LOW issue found.

Fix CRITICAL/HIGH issues before committing.

Next steps:
- Fix issues listed above
- Re-run review: `/fresh-eyes-review`
- If unfixable, consider: `/recovery`
```

**If APPROVED:**
```
✅ Fresh Eyes Review: APPROVED

No blocking issues found.
0 CRITICAL, 0 HIGH, 1 MEDIUM, 2 LOW issues noted.

Next steps:
- Commit and create PR: `/commit-and-pr`
- Or address MEDIUM/LOW issues first (optional)
```

---

## Output

**Review findings:**
- CRITICAL issues (if any)
- HIGH priority issues (if any)
- MEDIUM priority issues (if any)
- LOW priority / suggestions (if any)

**Verdict:** BLOCK | FIX_BEFORE_COMMIT | APPROVED | APPROVED_WITH_NOTES

**Metadata:**
- Tier used (Lite, Standard, Full)
- Agents involved
- LOC changed
- Confidence level

**Suggested next steps:**
- If BLOCK/FIX: "Fix issues and re-run `/fresh-eyes-review`"
- If APPROVED: "Proceed to `/commit-and-pr`"

---

## References

- See: `~/.claude/guides/FRESH_EYES_REVIEW.md` for full review workflow
- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Phase 1 Step 6 for review guidance
- See: `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md` for security checklist
- See: `~/.claude/checklists/AI_CODE_REVIEW.md` for code quality checklist

---

## Example Usage

**Example 1: Auto-select tier (Standard)**
```
User: /fresh-eyes-review

Claude: 👀 Fresh Eyes Code Review

Changes: 234 lines
Recommended: Standard Review

Use recommended tier? yes

[Launching agents...]

✅ Fresh Eyes Review: APPROVED

0 CRITICAL, 0 HIGH, 1 MEDIUM, 2 LOW

Next steps:
- Commit: `/commit-and-pr`
```

**Example 2: Direct mode with tier**
```
User: /fresh-eyes-review --full

Claude: [Immediately launches Full review]

❌ Fresh Eyes Review: BLOCK

1 CRITICAL issue found.

Issue:
❌ [Security] SQL Injection in src/api/users.ts:45

Fix and re-run: `/fresh-eyes-review`
```

**Example 3: Interactive tier selection**
```
User: /fresh-eyes-review

Claude: Changes: 520 lines
Recommended: Full Review

Review tiers:
1. Lite
2. Standard
3. Full

Use recommended tier [3]? 2

[Launches Standard review instead of Full]
```

---

## Notes

- **Zero context:** Agents have NO conversation history (true fresh eyes)
- **Tier auto-selection:** Based on LOC changed, can override
- **Token optimization:** Use appropriate tier to manage token usage
- **Re-runnable:** Re-run after fixing issues until APPROVED
- **Supervisor consolidates:** Final verdict from Supervisor agent
- **Confidence levels:** Agents report confidence (HIGH/MEDIUM/LOW)
- **Not a replacement for human review:** This is AI review, human review still valuable
- **Diff-based:** Reviews only changed code, not entire codebase
