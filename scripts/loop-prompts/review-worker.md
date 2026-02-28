You are running a FULL fresh-eyes code review. You have ZERO memory of
previous work — read files for ALL context.

## Setup

1. Start commit: `{START_COMMIT}`
2. Review round: {REVIEW_ROUND}
3. Last reviewed commit: `{LAST_REVIEWED_COMMIT}`

## Phase 1: Generate Diff

1. Generate the diff:
   - If review round is 0 OR last reviewed commit equals start commit:
     Full diff: `git diff {START_COMMIT}..HEAD`
   - Otherwise:
     Incremental diff: `git diff {LAST_REVIEWED_COMMIT}..HEAD`
     (Only review changes since last review round)
2. Generate the file list: `git diff --name-only {START_COMMIT}..HEAD` (always full for context)
3. Read `guides/FRESH_EYES_REVIEW.md` for the smart selection algorithm

## Phase 2: Smart Agent Selection

Run SMART SELECTION against the diff content and file list:
- Core agents (always): Security, Code Quality, Edge Case
- Conditional agents (only if triggered): Performance, API Contract, Concurrency,
  Error Handling, Data Validation, Dependency, Testing Adequacy, Config & Secrets,
  Documentation

## Phase 3: Run Reviews

For EACH selected specialist, spawn a parallel `general-purpose` Task subagent
with mode: bypassPermissions. Each subagent runs:

  You are a {specialist type} reviewer with ZERO context about this project.
  Read your review process from {agent definition file path from agents/review/*.md}.
  Review the code changes by running: git diff {START_COMMIT}..HEAD

  Instructions:
  - Output findings in this exact format, one per line:
    [{SEVERITY}] {ID}: {description} ({file}:{line})
    Where SEVERITY is CRITICAL, HIGH, MEDIUM, or LOW
  - Include specific file:line references for every finding
  - If you find a CRITICAL issue, mention it prominently at the top
  - Do NOT fix any code. Review ONLY.
  - Do NOT modify any files or commit anything.

Wait for all subagents to complete and collect their findings.

## Phase 4: Consolidation

After all specialists complete:
1. Collect all findings from subagent results
2. Remove duplicate findings (same file:line, same issue)
3. Remove false positives based on context
4. Prioritize by severity AND real-world impact

## Phase 5: Adversarial Validation

1. Challenge each CRITICAL and HIGH finding: Is this exploitable or theoretical?
2. Classify: VERIFIED | UNVERIFIED | DISPROVED
3. Drop DISPROVED findings from the final list

## Phase 6: Output

Output the FINAL consolidated findings in this EXACT format, bracketed by sentinels:

---LOOP_REVIEW_START---
- [CRITICAL] ID: description (file:line)
- [HIGH] ID: description (file:line)
- [MEDIUM] ID: description (file:line)
- [LOW] ID: description (file:line)
---LOOP_REVIEW_END---

If there are NO findings at any severity, output exactly:

---LOOP_REVIEW_START---
CLEAN
---LOOP_REVIEW_END---

## Rules
- Do NOT fix any code. Review ONLY.
- Do NOT modify any files.
- Do NOT commit anything.
- Read the FULL diff — do not skip files or truncate.
- Every finding MUST have a specific file and line reference.
- Be thorough. This is the last line of defense before merge.
