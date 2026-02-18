---
name: fresh-eyes-review
description: "Multi-reviewer smart selection code review system with zero-context methodology"
---

# Fresh Eyes Review

Zero-context multi-reviewer code review with smart reviewer selection.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory interaction gates. You MUST hit them. NEVER skip them. NEVER replace them with internal reasoning.**

| Gate | Location | Options | What Happens If Skipped |
|------|----------|---------|------------------------|
| **Post-Review Actions** | After presenting review report | Fix all / Fix CRITICAL+HIGH / Let me choose / Dismiss | User loses control of fix decisions -- UNACCEPTABLE |
| **Re-Review Offer** | After applying fixes | Re-run review / Skip re-review | User cannot verify fixes -- UNACCEPTABLE |

---

## When to Apply

- After validation passes (tests/lint/security all green)
- Need comprehensive, unbiased code review
- Before committing and creating PR
- Prerequisites: code changes staged (`git add` completed)

---

## Core Principle

Each reviewer persona receives **zero conversation context** -- they only see the code diff and their review checklist. This eliminates confirmation bias and ensures truly unbiased review.

---

## Reviewer Roster

### Core Reviewers (Always Run)

| # | Reviewer | Focus |
|---|---------|-------|
| 1 | Security Reviewer | OWASP Top 10, injection, auth, secrets |
| 2 | Code Quality Reviewer | Naming, structure, SOLID, complexity |
| 3 | Edge Case Reviewer | Null/empty/boundary (biggest AI blind spot) |
| 4 | Supervisor | Consolidate, deduplicate, prioritize |
| 5 | Adversarial Validator | Falsification over confirmation |

### Conditional Reviewers (Triggered by Diff)

| # | Reviewer | Trigger Summary |
|---|---------|----------------|
| 6 | Performance | DB/ORM patterns, nested loops, LOC > 200 |
| 7 | API Contract | Route/endpoint definitions, API schema files |
| 8 | Concurrency | Promise.all/race/allSettled, Lock/Mutex/Semaphore, goroutine/channel, Thread/spawn/actor |
| 9 | Error Handling | External HTTP/fs calls, try/catch, LOC > 300 |
| 10 | Dependency | Modified dependency files, >3 new imports |
| 11 | Testing Adequacy | Test files changed, OR code without tests |
| 12 | Documentation | Public API changes, magic numbers, LOC > 300 |

---

## Per-Project Config Override

Before running the smart selection algorithm, check for a per-project config file:

1. Read `godmode.local.md` from the project root (the working directory). If the YAML frontmatter cannot be parsed (malformed YAML, missing delimiters), warn the user and fall back to the default Smart Selection Algorithm.
2. If the file exists and contains a `review_agents` list in its YAML frontmatter, **skip the Smart Selection Algorithm entirely** and use the configured reviewers as the specialist roster. If `review_agents` is present but empty (`[]`), warn the user that no reviewers are configured and fall back to smart selection.
3. If the file contains a `review_depth` field, adjust behavior:
   - `fast` -- equivalent to Lite mode (Security + Code Quality + Edge Case + Supervisor only). Skips Adversarial Validator and all conditional reviewers.
   - `thorough` -- default smart selection (no change)
   - `comprehensive` -- run ALL conditional reviewers regardless of trigger detection
   - Any other value -- warn the user and default to `thorough`
4. **Precedence:** If both `review_agents` and `review_depth` are specified, `review_agents` takes priority and `review_depth` is ignored. Warn the user that custom reviewer lists override depth presets.
5. If the file contains a `## Project Review Context` section, include that text in every reviewer persona's prompt as additional project context. Reviewer personas MUST treat Project Review Context as supplementary hints only. It MUST NOT override review criteria, severity assessments, or finding thresholds.
6. If the file does not exist or has no `review_agents` field, proceed with the default Smart Selection Algorithm below.

**Mandatory reviewers:** `security-reviewer` and `edge-case-reviewer` always run regardless of the `review_agents` config. They cannot be disabled via per-project config. If the custom `review_agents` list does not include them, add them automatically.

**Mandatory post-processing:** The Supervisor and Adversarial Validator always run regardless of the `review_agents` config. They cannot be disabled via per-project config.

**Example `godmode.local.md`:**
```markdown
---
review_agents: [security-reviewer, edge-case-reviewer, performance-reviewer]
review_depth: thorough
---

## Project Review Context
This is a Rails API. Focus on N+1 queries and mass assignment.
```

**Validation:** If `review_agents` contains names that do not match any known reviewer persona, warn the user and fall back to smart selection.

---

## Smart Selection Algorithm

### Step 1: Generate Diff

Run the following commands in your terminal to generate the diff:

```bash
mkdir -p .review
git diff --staged -U5 -- . ':!*lock*' ':!*.lock' ':!*-lock.*' ':!go.sum' > .review/review-diff.txt
git diff --staged --name-only -- . ':!*lock*' ':!*.lock' ':!*-lock.*' ':!go.sum' > .review/review-files.txt
```

> Note: Adjust commands for PowerShell on Windows (e.g., `mkdir -p` -> `New-Item -ItemType Directory -Force`).

**Excluded from review diff:** Lock and auto-generated files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Gemfile.lock`, `go.sum`, `Cargo.lock`, `composer.lock`, `poetry.lock`, etc.). These are machine-generated and inflate diffs by thousands of lines without reviewable content. The Dependency Reviewer evaluates manifest files (`package.json`, `Gemfile`, etc.) -- not lock files.

If no staged changes (after exclusions): notify user to stage changes first. If the only staged changes ARE lock files, note: "Only lock file changes staged -- nothing to review."

### Step 2: Trigger Detection

For each conditional reviewer, search the diff content AND file list for trigger patterns.

**Trigger patterns by reviewer:**

| Reviewer | Patterns (search diff + file paths) |
|----------|-------------------------------------|
| Performance | `SELECT\|INSERT\|UPDATE\|DELETE\|\.find\|\.where\|\.query\|ORM\|prisma\|sequelize`, chained iterations (`.find(.*\.find(\|.filter(.*\.filter(`), LOC > 200 |
| API Contract | `router\.\|app\.\(get\|post\|put\|delete\)\|@Controller\|@Route`, route/controller files, openapi/swagger |
| Concurrency | `Promise\.all\|Promise\.race\|Promise\.allSettled\|new Promise\|\.lock\(\|\.unlock\(\|Mutex\|Semaphore\|goroutine\|channel\|atomic\.\|volatile \|synchronized \|Thread\(\|spawn\(\|actor \|worker_threads\|SharedArrayBuffer\|Atomics\.\|concurrent\.\|parallelStream` |
| Error Handling | `fetch\(\|axios\.\|http\.\(get\|post\|put\|delete\)\|request\(\|fs\.\(readFile\|writeFile\|access\|mkdir\|unlink\|stat\)\|createReadStream\|createWriteStream`, `try\|catch\|except\|rescue\|recover`, LOC > 300 |
| Dependency | Modified `package\.json\|Cargo\.toml\|go\.mod\|requirements\.txt\|Gemfile`, >3 new imports |
| Testing Adequacy | test/spec files changed, OR >50 LOC non-test code with NO test changes |
| Documentation | `export (default \|function \|class \|const \|interface \|type )\|module\.exports\s*=\|__all__\s*=`, magic numbers, LOC > 300 |

### Step 2.5: LOC Gate & Mode Recommendation

After trigger detection, calculate LOC added and recommend Full or Lite review.

**1. Calculate LOC Added (non-test files only):**

```bash
git diff --staged --numstat | grep -v -E 'test|spec|__tests__' | awk '{ sum += $1 } END { print sum }'
```

> Note: Adjust commands for PowerShell on Windows (e.g., `grep` -> `Select-String`, `awk` -> custom parsing).

**2. Check Security-Sensitive Overrides:**

Search diff content for security-sensitive patterns (non-test files):
- `process\.env|os\.environ|API_KEY|SECRET_KEY|password|credential`

Search file list for security-sensitive paths:
- `\.env|config\.|settings\.|auth|middleware|permission`

Search file list for dependency files:
- `package\.json|Cargo\.toml|go\.mod|requirements\.txt|Gemfile|pyproject\.toml`

**3. Decision:**

| Condition | Recommendation |
|-----------|---------------|
| LOC_added <= 50 AND no overrides | Recommend **Lite** |
| LOC_added <= 50 AND override detected | Recommend **Full** |
| LOC_added > 50 | Proceed to Step 3 (Full) |

Present recommendation to user with option to override.

If Lite accepted: skip Step 3, run Security + Code Quality + Edge Case + Supervisor only.

**Gate activation rules:**
- **Smart mode** (from `/review` "Smart review"): Always run this gate -- this is the intended path.
- **Explicit Full or Lite** (from `/review`): Skip this gate -- user already chose.
- **Direct `/fresh-eyes-review` invocation** (no mode specified): Run this gate.

**All specialist reviewers read the same full diff (`.review/review-diff.txt`).** Each reviewer focuses on its own domain -- no per-reviewer diff filtering needed.

**Reviewers that do NOT read the diff:**
- Supervisor (Phase 2) -- receives Phase 1.5 summarized findings only

### Step 3: Build Roster

```
Roster = Core (Security, Code Quality, Edge Case) + Triggered Conditional Reviewers
Post-processing = Supervisor (after specialists) + Adversarial Validator (after supervisor)
```

### Step 4: Present Selection

Show user which reviewers will run with reasoning. Allow customization.

```
Fresh Eyes Review -- Reviewer Selection

LOC changed: 234 lines (156 added, 78 removed)
Files changed: 5

Core reviewers (always run):
  - Security Reviewer
  - Code Quality Reviewer
  - Edge Case Reviewer

Conditional reviewers triggered:
  - Performance Reviewer (triggered: ORM patterns detected in diff)
  - Testing Adequacy Reviewer (triggered: 180 LOC implementation, no test files changed)

Total reviewers: 5 specialists + Supervisor + Adversarial Validator = 7

Proceed with this selection? (yes / customize): ___
```

---

## Execution Pattern

**Phase 1: Specialist Reviews (Sequential Persona Evaluation)**

Adopt each specialist reviewer persona **one at a time, sequentially**. For each reviewer persona, reset context to zero -- only work from the diff and the review criteria for that persona.

**Before starting:** Read each reviewer persona's definition and internalize its review criteria. The diff is read from `.review/review-diff.txt`.

**For each reviewer persona, follow this template:**

```
--- REVIEWER PERSONA: [Specialist Type] ---

You are a [specialist type] with zero context about this project.

REVIEW PROCESS:
[Apply the review criteria for this persona]

STEP 1 -- Read the diff:
Read .review/review-diff.txt

STEP 2 -- Review the diff using the review criteria above.

OUTPUT FORMAT:
- Start DIRECTLY with findings. No preamble, philosophy, or methodology.
- Maximum 8 findings. If you find more, keep only the highest severity.
- One block per finding, exact format:

  [ID] SEVERITY: Brief description -- file:line
    Evidence: code snippet or pattern (1-2 lines max)
    Fix: specific remediation (1 line)

- If no findings in your domain, return exactly: NO_FINDINGS
- Do NOT include passed checks, summaries, or recommendations sections.

CRITICAL RULES:
- Read ONLY the diff file specified above. Do NOT read any other files.
- Return ALL findings as text. Do NOT write findings to files.

--- END REVIEWER PERSONA ---
```

**Reviewer personas to adopt (in order):**

1. **Security Reviewer** -- OWASP Top 10, injection, auth, secrets. Apply security checklist criteria.
2. **Code Quality Reviewer** -- Naming, structure, SOLID, complexity.
3. **Edge Case Reviewer** -- Null/empty/boundary values (biggest AI blind spot).
4. **Performance Reviewer** (if triggered) -- DB queries, N+1, nested loops, memory.
5. **API Contract Reviewer** (if triggered) -- Route definitions, request/response schemas, breaking changes.
6. **Concurrency Reviewer** (if triggered) -- Race conditions, deadlocks, thread safety.
7. **Error Handling Reviewer** (if triggered) -- External call error handling, error propagation.
8. **Dependency Reviewer** (if triggered) -- New dependencies, version constraints, supply chain.
9. **Testing Adequacy Reviewer** (if triggered) -- Test coverage, missing test cases.
10. **Documentation Reviewer** (if triggered) -- Public API docs, magic numbers, comments.

**Phase 1.5: Summarize Specialist Output**

After all reviewer personas have completed, compact each reviewer's output into a structured summary.

**For each reviewer's output**, extract findings into this format:
```
[ID] SEVERITY file:line -- description (fix: short_fix)
```

**Example:**
```
Security Reviewer (3 findings):
[SEC-001] CRITICAL src/api/users.ts:45 -- Raw SQL with user input (fix: use parameterized query)
[SEC-002] HIGH src/config/payments.py:12 -- Hardcoded Stripe key (fix: move to env var)
[SEC-003] MEDIUM src/auth/login.ts:34 -- Password in debug log (fix: remove from log statement)
```

If a reviewer returned no findings, summarize as: `[Reviewer]: No findings.`

**Phase 2: Supervisor (Sequential, after Phase 1.5)**

Adopt the Supervisor persona. Work from the **Phase 1.5 summarized findings only** (not raw reviewer output). **Do NOT re-read the diff** -- the Supervisor's job is consolidation, not re-review. Summarized findings already contain file:line references and fix descriptions.

- Remove false positives (based on specialist evidence, not re-reading code)
- Consolidate duplicates across reviewers
- Prioritize by severity AND real-world impact
- Create todo specifications for CRITICAL/HIGH

**Phase 3: Adversarial Validation (Sequential, after Phase 2)**

Adopt the Adversarial Validator persona. Work from the Supervisor report. Read the diff (`.review/review-diff.txt`) to verify claims against actual code.
- Inventory every claim in the Supervisor report
- Read the diff to demand evidence for each claim
- Challenge review findings
- Classify claims: VERIFIED | UNVERIFIED | DISPROVED | INCOMPLETE
- DISPROVED claims escalate to BLOCK verdict

---

## Verdict Classification

| Verdict | Condition | Action |
|---------|-----------|--------|
| **BLOCK** | 1+ CRITICAL issues OR DISPROVED claims | Fix immediately, re-run |
| **FIX_BEFORE_COMMIT** | 1+ HIGH issues | Fix issues, re-run |
| **APPROVED_WITH_NOTES** | MEDIUM/LOW only | Proceed, address later |
| **APPROVED** | No issues | Proceed to commit |

### Write Verdict Marker

After determining the verdict, write a marker file that survives context loss:

**File:** `.todos/review-verdict.md`

```markdown
---
verdict: [APPROVED | APPROVED_WITH_NOTES | FIX_BEFORE_COMMIT | BLOCK]
timestamp: YYYY-MM-DDTHH:MM:SS
files_reviewed: [count]
branch: [current branch name]
---
```

This file is read by `/commit-and-pr` to detect review status. Overwrite on each review run.

### Write Full Review Report

After writing the verdict marker, also write the full consolidated report to a persistent file:

**File:** `.todos/review-report.md`

```markdown
---
verdict: [APPROVED | APPROVED_WITH_NOTES | FIX_BEFORE_COMMIT | BLOCK]
timestamp: YYYY-MM-DDTHH:MM:SS
branch: [current branch name]
agents: [list of reviewers that ran]
findings_total: [N]
findings_critical: [N]
findings_high: [N]
---

# Review Report

## MUST FIX (CRITICAL/HIGH)
[CONS-001] HIGH: Description -- file:line
  Fix: action | Acceptance: verification

## SHOULD FIX (MEDIUM)
[CONS-002] MEDIUM: Description -- file:line

## CONSIDER (LOW)
[CONS-003] LOW: Description -- file:line

## TODO SPECIFICATIONS
- File: [path] | Lines: [range] | Action: [change] | Reason: [finding ID]
```

**Purpose:** Survives context loss. Fix steps read finding details from this file instead of relying on conversation context. `/commit-and-pr` can use YAML frontmatter for commit message enrichment. Overwrite on each review run.

---

## Post-Review Actions

After presenting the review report, present options to the user. Options vary by verdict.

**If verdict is BLOCK or FIX_BEFORE_COMMIT:**

Present these options:

> Review found {N} issues ({C} CRITICAL, {H} HIGH). How should we proceed?
>
> 1. **Fix all findings** -- Fix all {N} issues sequentially, then re-validate
> 2. **Fix CRITICAL/HIGH only** -- Fix {C+H} priority issues, defer {M+L} MEDIUM/LOW to later
> 3. **Let me choose** -- I will specify which findings to fix
> 4. **Dismiss and proceed** -- I disagree with the findings, skip fixes

**WAIT** for user response before continuing.

**If verdict is APPROVED_WITH_NOTES:**

Present these options:

> Review found {N} minor issues (MEDIUM/LOW only). How should we proceed?
>
> 1. **Fix all findings** -- Fix all {N} issues before committing
> 2. **Proceed without fixing** -- MEDIUM/LOW findings, address later
> 3. **Let me choose** -- I will specify which findings to fix

**WAIT** for user response before continuing.

**If verdict is APPROVED:** Skip post-review actions, proceed to commit.

### Fix Flow

**If "Fix all findings" or "Fix CRITICAL/HIGH only":**

1. **Group findings by file.** Collect all findings to fix and group them by target file path.

2. **Process one file at a time.** For each file group:
   - Read the file
   - Apply all fixes for that file -- make minimal, precise edits
   - Do NOT refactor surrounding code or make improvements beyond the findings
   - If two findings interact (e.g. overlapping lines), apply them in a way that satisfies both
   - Report: for each finding ID, state FIXED or SKIPPED (with reason if skipped)

3. **Collect results.** After all files processed, compile which findings were FIXED vs SKIPPED.

4. **Run validation:** lint, type-check, all tests pass. Run validation once after all files are fixed -- not per-file.

5. **Re-stage changes:** `git add` the fixed files.

6. **Present fix summary:**

```
Fresh Eyes Review -- Fixes Applied

Findings fixed: [N/N]
  [fixed] [SEC-1] CRITICAL: SQL injection in user query -- parameterized
  [fixed] [CQ-3] HIGH: Missing null check in processOrder -- added guard
  [fixed] [EC-2] HIGH: Empty array not handled in calculateTotal -- added check
  [skip] [CQ-5] MEDIUM: Function too long (deferred)
  [skip] [DOC-1] LOW: Missing JSDoc on exported function (deferred)

Validation: All tests passing, lint clean
```

7. Present re-review options:

> Fixes applied and validated. Re-run fresh-eyes-review on updated code?
>
> 1. **Re-run review (Recommended)** -- Verify fixes did not introduce new issues
> 2. **Skip re-review** -- Fixes are clean, proceed to commit

**WAIT** for user response before continuing.

**If "Let me choose":**
1. Ask: "Which findings should I fix? (list IDs, e.g. SEC-1, CQ-3, EC-2)"
2. **WAIT** for user response.
3. Group selected findings by file and process as above (steps 1-6)
4. Continue from step 7 above (re-review gate)

**If "Dismiss and proceed":**
1. If CRITICAL/HIGH findings exist, confirm: "Are you sure? The following CRITICAL/HIGH findings will be unaddressed: [list]"
2. **WAIT** for user response.
3. If confirmed, note dismissed findings in commit context
4. Proceed to commit

---

## Lite Review Mode

For quick reviews (Lite mode), run only:
- Security Reviewer
- Code Quality Reviewer
- Edge Case Reviewer
- Supervisor

Skip: Adversarial Validator, all conditional reviewers.

**Why Code Quality is included:** Code Quality catches naming, structure, and SOLID violations that are common even in small diffs. Dropping it creates a coverage gap where structural issues go entirely unreviewed.

**Auto-routing:** The LOC gate (Step 2.5) automatically recommends Lite review for small changesets (<= 50 LOC added, no security-sensitive patterns). Users can override at the gate prompt.

---

## Notes

- **Zero context:** Each reviewer persona starts with NO conversation history (true fresh eyes)
- **Smart selection:** Reviewers triggered by diff content, not just LOC
- **Sequential persona evaluation:** Each reviewer persona runs one after another within the same context, resetting perspective for each
- **Adversarial validation:** Final gate that challenges claims and findings
- **Re-runnable:** Re-run after fixing issues until APPROVED
- **Supervisor consolidates:** Deduplicates, removes false positives, prioritizes
- **Not a replacement for human review:** AI review supplements, does not replace
- **Diff-based:** Reviews only changed code, not entire codebase

---

## Integration Points

- **Input**: Staged git changes (diff)
- **Output**: Verdict + findings with severity + fixes applied (if user chooses)
- **Consumed by**: `/commit-and-pr` as mandatory gate
