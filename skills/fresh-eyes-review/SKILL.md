---
name: fresh-eyes-review
version: "2.1"
description: 11-agent smart selection code review system with zero-context methodology
referenced_by:
  - commands/review.md
  - guides/FRESH_EYES_REVIEW.md
---

# Fresh Eyes Review Skill

Zero-context multi-agent code review with smart agent selection.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory AskUserQuestion gates. You MUST hit them. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Post-Review Actions** | After presenting review report | Fix all / Fix CRITICAL+HIGH / Let me choose / Dismiss | User loses control of fix decisions — UNACCEPTABLE |
| **Re-Review Offer** | After applying fixes | Re-run review / Skip re-review | User can't verify fixes — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- After validation passes (tests/lint/security all green)
- Need comprehensive, unbiased code review
- Before committing and creating PR
- Prerequisites: code changes staged (`git add` completed)

---

## Core Principle

Review agents receive **zero conversation context** — they only see the code diff and their review checklist. This eliminates confirmation bias and ensures truly unbiased review.

---

## Agent Roster

### Core Agents (Always Run)

| # | Agent | Definition | Model | Focus |
|---|-------|-----------|-------|-------|
| 1 | Security Reviewer | `agents/review/security-reviewer.md` | opus | OWASP Top 10, injection, auth, secrets |
| 2 | Code Quality Reviewer | `agents/review/code-quality-reviewer.md` | sonnet | Naming, structure, SOLID, complexity |
| 3 | Edge Case Reviewer | `agents/review/edge-case-reviewer.md` | sonnet | Null/empty/boundary (biggest AI blind spot) |
| 4 | Supervisor | `agents/review/supervisor.md` | sonnet | Consolidate, deduplicate, prioritize |
| 5 | Adversarial Validator | `agents/review/adversarial-validator.md` | opus | Falsification over confirmation |

### Conditional Agents (Triggered by Diff)

See `skills/fresh-eyes-review/references/trigger-patterns.md` for detailed patterns.

| # | Agent | Model | Trigger Summary |
|---|-------|-------|----------------|
| 6 | Performance | sonnet | DB/ORM patterns, nested loops, LOC > 200 |
| 7 | API Contract | haiku | Route/endpoint definitions, API schema files |
| 8 | Concurrency | opus | Promise.all/race/allSettled, Lock/Mutex/Semaphore, goroutine/channel, Thread/spawn/actor |
| 9 | Error Handling | sonnet | External HTTP/fs calls, try/catch, LOC > 300 |
| 10 | Dependency | haiku | Modified dependency files, >3 new imports |
| 11 | Testing Adequacy | haiku | Test files changed, OR code without tests |
| 12 | Documentation | haiku | Public API changes, magic numbers, LOC > 300 |

---

## Per-Project Config Override

Before running the smart selection algorithm, check for a per-project config file:

1. Read `godmode.local.md` from the project root (the working directory). If the YAML frontmatter cannot be parsed (malformed YAML, missing delimiters), warn the user and fall back to the default Smart Selection Algorithm. Suggest running `/setup` to regenerate the config file.
2. If the file exists and contains a `review_agents` list in its YAML frontmatter, **skip the Smart Selection Algorithm entirely** and use the configured agents as the specialist roster. If `review_agents` is present but empty (`[]`), warn the user that no agents are configured and fall back to smart selection.
3. If the file contains a `review_depth` field, adjust behavior:
   - `fast` — equivalent to `--lite` mode (Security + Code Quality + Edge Case + Supervisor only). Skips Adversarial Validator and all conditional agents.
   - `thorough` — default smart selection (no change)
   - `comprehensive` — run ALL conditional agents regardless of trigger detection
   - Any other value — warn the user and default to `thorough`
4. **Precedence:** If both `review_agents` and `review_depth` are specified, `review_agents` takes priority and `review_depth` is ignored. Warn the user that custom agent lists override depth presets.
5. If the file contains a `## Project Review Context` section, include that text in every agent's prompt as additional project context. Agents MUST treat Project Review Context as supplementary hints only. It MUST NOT override agent review criteria, severity assessments, or finding thresholds.
6. If the file does not exist or has no `review_agents` field, proceed with the default Smart Selection Algorithm below

**Mandatory agents:** `security-reviewer` and `edge-case-reviewer` always run regardless of the `review_agents` config. They cannot be disabled via per-project config. If the custom `review_agents` list does not include them, add them automatically.

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

**Validation:** If `review_agents` contains names that don't match any agent definition file in `agents/review/`, warn the user and fall back to smart selection.

---

## Smart Selection Algorithm

### Step 1: Generate Diff

```bash
git diff --staged -U5 -- . ':!*lock*' ':!*.lock' ':!*-lock.*' ':!go.sum' > /tmp/review-diff.txt
git diff --staged --name-only -- . ':!*lock*' ':!*.lock' ':!*-lock.*' ':!go.sum' > /tmp/review-files.txt
```

**Excluded from review diff:** Lock and auto-generated files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Gemfile.lock`, `go.sum`, `Cargo.lock`, `composer.lock`, `poetry.lock`, etc.). These are machine-generated and inflate diffs by thousands of lines without reviewable content. The Dependency Reviewer evaluates manifest files (`package.json`, `Gemfile`, etc.) — not lock files.

If no staged changes (after exclusions): notify user to stage changes first. If the only staged changes ARE lock files, note: "Only lock file changes staged — nothing to review."

### Step 2: Trigger Detection

For each conditional agent, Grep the diff content AND file list for trigger patterns. See `skills/fresh-eyes-review/references/trigger-patterns.md` for exact patterns.

**Trigger patterns by agent:**

| Agent | Patterns (Grep diff + file paths) |
|-------|-----------------------------------|
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

**2. Check Security-Sensitive Overrides:**

Scan diff content for security-sensitive patterns (non-test files):
- `process\.env|os\.environ|API_KEY|SECRET_KEY|password|credential`

Scan file list for security-sensitive paths:
- `\.env|config\.|settings\.|auth|middleware|permission`

Scan file list for dependency files:
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
- **Smart mode** (from `commands/review.md` "Smart review"): Always run this gate — this is the intended path.
- **Explicit Full or Lite** (from `commands/review.md`): Skip this gate — user already chose.
- **Direct `/fresh-eyes-review` invocation** (no mode specified): Run this gate.

### Step 2.6: Hunk Extraction (Conditional Agents)

For each triggered conditional agent, extract only the diff hunks relevant to that agent's domain. This reduces token consumption by sending each agent only the code relevant to its review focus.

**Algorithm:**

1. **Parse the unified diff** into file-level blocks, each containing one or more hunks (sections starting with `@@`).

2. **For each conditional agent**, apply its trigger patterns from `skills/fresh-eyes-review/references/trigger-patterns.md`:
   - **Diff content patterns:** Include hunks where added lines (`+`) or removed lines (`-`) match the agent's content patterns.
   - **File path patterns:** Include ALL hunks from files whose path matches the agent's file path patterns.

3. **LOC-threshold-only agents** (triggered by LOC > N without a content or file path match): pass the full diff -- no filtering.

4. **Merge adjacent hunks** within 10 lines of each other in the same file to preserve context continuity.

5. **Full-diff fallback:** If the filtered diff contains >80% of the full diff's total hunks, pass the full diff instead (filtering provides negligible savings).

6. **Write filtered diff** to `/tmp/review-diff-{agent-name}.txt` (e.g., `/tmp/review-diff-performance.txt`).

**Agents that always receive the full diff (`/tmp/review-diff.txt`):**
- Core agents: Security Reviewer, Code Quality Reviewer, Edge Case Reviewer
- Supervisor (Phase 2)
- Adversarial Validator (Phase 3)

### Step 3: Build Roster

```
Roster = Core (Security, Code Quality, Edge Case) + Triggered Conditional Agents
Post-processing = Supervisor (after specialists) + Adversarial Validator (after supervisor)
```

### Step 4: Present Selection

Show user which agents will run with reasoning. Allow customization.

```
Fresh Eyes Review — Agent Selection

LOC changed: 234 lines (156 added, 78 removed)
Files changed: 5

Core agents (always run):
  - Security Reviewer
  - Code Quality Reviewer
  - Edge Case Reviewer

Conditional agents triggered:
  - Performance Reviewer (triggered: ORM patterns detected in diff)
  - Testing Adequacy Reviewer (triggered: 180 LOC implementation, no test files changed)

Total agents: 5 specialists + Supervisor + Adversarial Validator = 7

Proceed with this selection? (yes / customize): ___
```

---

## Execution Pattern

**Phase 1: Specialist Reviews (Parallel)**

Launch ALL specialist agents in a **single message** with multiple Task tool calls.

**Before launching:** The orchestrator reads all needed files and inlines their content into each agent prompt:
- Read each agent's definition file (`agents/review/[agent].md`)
- Read the diff (`/tmp/review-diff.txt`)
- Read the security checklist (`checklists/AI_CODE_SECURITY_REVIEW.md`) for the security agent

**Each agent receives (all inline, zero file reads needed):**
- Zero conversation context
- Agent review process (inlined from definition file)
- Diff content (inlined from `/tmp/review-diff.txt`)
- Security checklist (inlined, security agent only)

**CRITICAL — Zero file reads by agents:** Agents reading files triggers permission prompts on mobile clients (33 prompts across 11 agents is unacceptable UX). The orchestrator MUST inline all content. Agents should not need to use Read, Grep, or Glob tools.

**Model selection:** When spawning each agent via Task tool, pass the `model` parameter matching the agent's tier from the roster tables above (e.g., `model: "opus"` for Security Reviewer, `model: "sonnet"` for Code Quality Reviewer, `model: "haiku"` for Documentation Reviewer). The `Explore` subagent type manages its own model internally — do not pass `model` for it. Each agent's definition file also declares its tier in YAML frontmatter for reference.

**Agent prompt template (core agents — full diff):**
```
You are a [specialist type] with zero context about this project.

YOUR REVIEW PROCESS:
[inline content from agents/review/[agent].md]

[For security agent only:]
SECURITY CHECKLIST:
[inline content from checklists/AI_CODE_SECURITY_REVIEW.md]

CODE CHANGES TO REVIEW:
[inline content from /tmp/review-diff.txt]

OUTPUT FORMAT:
- Start DIRECTLY with findings. No preamble, philosophy, or methodology.
- Maximum 8 findings. If you find more, keep only the highest severity.
- One block per finding, exact format:

  [ID] SEVERITY: Brief description — file:line
    Evidence: code snippet or pattern (1-2 lines max)
    Fix: specific remediation (1 line)

- If no findings in your domain, return exactly: NO_FINDINGS
- Do NOT include passed checks, summaries, or recommendations sections.

CRITICAL RULES:
- Do NOT use Bash, Grep, Glob, Read, Write, or Edit tools. ZERO tool calls to access files.
- Everything you need is in this prompt. Do NOT read additional files for "context."
- Return ALL findings as text in your response. Do NOT write findings to files.
- No /tmp files, no intermediary files, no analysis documents. Text response ONLY.
```

**Agent prompt template (conditional agents — filtered diff):**
```
You are a [specialist type] with zero context about this project.

YOUR REVIEW PROCESS:
[inline content from agents/review/[agent].md]

CODE CHANGES TO REVIEW:
[inline content from /tmp/review-diff-[agent-name].txt]
This diff contains only hunks relevant to your review domain.

OUTPUT FORMAT:
- Start DIRECTLY with findings. No preamble, philosophy, or methodology.
- Maximum 8 findings. If you find more, keep only the highest severity.
- One block per finding, exact format:

  [ID] SEVERITY: Brief description — file:line
    Evidence: code snippet or pattern (1-2 lines max)
    Fix: specific remediation (1 line)

- If no findings in your domain, return exactly: NO_FINDINGS
- Do NOT include passed checks, summaries, or recommendations sections.

CRITICAL RULES:
- Do NOT use Bash, Grep, Glob, Read, Write, or Edit tools. ZERO tool calls to access files.
- Everything you need is in this prompt. Do NOT read additional files for "context."
- Return ALL findings as text in your response. Do NOT write findings to files.
- No /tmp files, no intermediary files, no analysis documents. Text response ONLY.
```

**Agent definitions referenced:**
- `agents/review/security-reviewer.md`
- `agents/review/code-quality-reviewer.md`
- `agents/review/edge-case-reviewer.md`
- `agents/review/performance-reviewer.md` (if triggered)
- `agents/review/api-contract-reviewer.md` (if triggered)
- `agents/review/concurrency-reviewer.md` (if triggered)
- `agents/review/error-handling-reviewer.md` (if triggered)
- `agents/review/dependency-reviewer.md` (if triggered)
- `agents/review/testing-adequacy-reviewer.md` (if triggered)
- `agents/review/documentation-reviewer.md` (if triggered)

**Phase 1.5: Summarize Specialist Output**

Before forwarding to the Supervisor, the orchestrator compacts each specialist's output into a structured summary. This prevents verbose narrative from consuming the Supervisor's context window.

**For each specialist output**, extract findings into this format:
```
[ID] SEVERITY file:line — description (fix: short_fix)
```

**Example:**
```
Security Reviewer (3 findings):
[SEC-001] CRITICAL src/api/users.ts:45 — Raw SQL with user input (fix: use parameterized query)
[SEC-002] HIGH src/config/payments.py:12 — Hardcoded Stripe key (fix: move to env var)
[SEC-003] MEDIUM src/auth/login.ts:34 — Password in debug log (fix: remove from log statement)
```

If a specialist returns no findings, summarize as: `[Agent]: No findings.`

**Phase 2: Supervisor (Sequential, after Phase 1.5)**

Launch Supervisor as a Task tool call with the **Phase 1.5 summarized findings** (not raw specialist output). **Do NOT include the diff** — the Supervisor's job is consolidation, not re-review. Summarized findings already contain file:line references and fix descriptions.

- Removes false positives (based on specialist evidence, not re-reading code)
- Consolidates duplicates across specialists
- Prioritizes by severity AND real-world impact
- Creates todo specifications for CRITICAL/HIGH

**Phase 3: Adversarial Validation (Sequential, after Phase 2)**

Launch Adversarial Validator as a Task tool call with all specialist outputs + Supervisor report:
- Inventories every claim in the implementation
- Demands evidence for each claim
- Challenges review findings
- Classifies claims: VERIFIED | UNVERIFIED | DISPROVED | INCOMPLETE
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

After determining the verdict, write a marker file that survives context compaction:

**File:** `.todos/review-verdict.md`

```markdown
---
verdict: [APPROVED | APPROVED_WITH_NOTES | FIX_BEFORE_COMMIT | BLOCK]
timestamp: YYYY-MM-DDTHH:MM:SS
files_reviewed: [count]
branch: [current branch name]
---
```

This file is read by `/ship` Step 0 to detect review status without relying on conversation context. Overwrite on each review run.

### Write Full Review Report

After writing the verdict marker, also write the full consolidated report to a persistent file:

**File:** `.todos/review-report.md`

```markdown
---
verdict: [APPROVED | APPROVED_WITH_NOTES | FIX_BEFORE_COMMIT | BLOCK]
timestamp: YYYY-MM-DDTHH:MM:SS
branch: [current branch name]
agents: [list of agents that ran]
findings_total: [N]
findings_critical: [N]
findings_high: [N]
---

# Review Report

## MUST FIX (CRITICAL/HIGH)
[CONS-001] HIGH: Description — file:line
  Fix: action | Acceptance: verification

## SHOULD FIX (MEDIUM)
[CONS-002] MEDIUM: Description — file:line

## CONSIDER (LOW)
[CONS-003] LOW: Description — file:line

## TODO SPECIFICATIONS
- File: [path] | Lines: [range] | Action: [change] | Reason: [finding ID]
```

**Purpose:** Survives context compaction. Fix subagents read finding details from this file instead of relying on conversation context. `/ship` can use YAML frontmatter for commit message enrichment. Overwrite on each review run.

---

## Post-Review Actions

After presenting the review report, ask the user how to proceed. Options vary by verdict.

**If verdict is BLOCK or FIX_BEFORE_COMMIT:**

```
AskUserQuestion:
  question: "Review found {N} issues ({C} CRITICAL, {H} HIGH). How should we proceed?"
  header: "Fix findings"
  options:
    - label: "Fix all findings"
      description: "Fix all {N} issues sequentially, then re-validate"
    - label: "Fix CRITICAL/HIGH only"
      description: "Fix {C+H} priority issues, defer {M+L} MEDIUM/LOW to later"
    - label: "Let me choose"
      description: "I'll specify which findings to fix"
    - label: "Dismiss and proceed"
      description: "I disagree with the findings — skip fixes"
```

**If verdict is APPROVED_WITH_NOTES:**

```
AskUserQuestion:
  question: "Review found {N} minor issues (MEDIUM/LOW only). How should we proceed?"
  header: "Fix findings"
  options:
    - label: "Fix all findings"
      description: "Fix all {N} issues before committing"
    - label: "Proceed without fixing"
      description: "MEDIUM/LOW findings — address later"
    - label: "Let me choose"
      description: "I'll specify which findings to fix"
```

**If verdict is APPROVED:** Skip post-review actions, proceed to commit.

### Fix Flow

**Why subagents:** Fix application can trigger context compaction when the main agent reads, edits, and validates each finding sequentially. Delegating to subagents keeps the main context lean — it only tracks dispatch and results.

**If "Fix all findings" or "Fix CRITICAL/HIGH only":**

1. **Group findings by file.** Collect all findings to fix and group them by target file path. Each group becomes one subagent task.

2. **Dispatch one subagent per file** using the Task tool. Launch all subagents in a single message (parallel execution). Each subagent receives:
   - The list of findings for its file (ID, severity, line, description, suggested fix)
   - The file path to edit
   - Instructions to read the file, apply all fixes, and report what it changed

   **Subagent prompt template:**
   ```
   You are a code fix agent. Apply the following review findings to the specified file.

   File: {file_path}

   Findings to fix:
   {findings_list — each with ID, severity, line, description, suggested fix}

   Instructions:
   1. Read the file
   2. Apply each fix — make minimal, precise edits
   3. Do NOT refactor surrounding code or make improvements beyond the findings
   4. If two findings interact (e.g. overlapping lines), apply them in a way that satisfies both
   5. Report back: for each finding ID, state FIXED or SKIPPED (with reason if skipped)
   ```

3. **Collect results.** After all subagents complete, collect their reports. Compile which findings were FIXED vs SKIPPED.

4. **Run validation:** `lint, type-check, all tests pass`. The main agent runs validation once after all subagents finish — not per-file.

5. **Re-stage changes:** `git add` the fixed files.

6. **Present fix summary:**

```
Fresh Eyes Review — Fixes Applied
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Findings fixed: [N/N]
  ✅ [SEC-1] CRITICAL: SQL injection in user query — parameterized
  ✅ [CQ-3] HIGH: Missing null check in processOrder — added guard
  ✅ [EC-2] HIGH: Empty array not handled in calculateTotal — added check
  ⏭️ [CQ-5] MEDIUM: Function too long (deferred)
  ⏭️ [DOC-1] LOW: Missing JSDoc on exported function (deferred)

Validation: ✅ All tests passing, lint clean
```

7. Ask whether to re-run review on the fixed code:

```
AskUserQuestion:
  question: "Fixes applied and validated. Re-run fresh-eyes-review on updated code?"
  header: "Re-review"
  options:
    - label: "Re-run review (Recommended)"
      description: "Verify fixes didn't introduce new issues"
    - label: "Skip re-review"
      description: "Fixes are clean — proceed to commit"
```

**If "Let me choose":**
1. Ask: "Which findings should I fix? (list IDs, e.g. SEC-1, CQ-3, EC-2)"
2. Wait for user response
3. Group selected findings by file and dispatch subagents as above (steps 1-6)
4. Continue from step 7 above (re-review gate)

**If "Dismiss and proceed":**
1. If CRITICAL/HIGH findings exist, confirm: "Are you sure? The following CRITICAL/HIGH findings will be unaddressed: [list]"
2. If confirmed, note dismissed findings in commit context
3. Proceed to commit

---

## Lite Review Mode

For quick reviews (`--lite`), run only:
- Security Reviewer
- Code Quality Reviewer
- Edge Case Reviewer
- Supervisor

Skip: Adversarial Validator, all conditional agents.

**Why Code Quality is included:** Code Quality catches naming, structure, and SOLID violations that are common even in small diffs. Dropping it creates a coverage gap where structural issues go entirely unreviewed.

**Auto-routing:** The LOC gate (Step 2.5) automatically recommends Lite review for small changesets (<= 50 LOC added, no security-sensitive patterns). Users can override at the gate prompt.

---

## Notes

- **Zero context:** Agents have NO conversation history (true fresh eyes)
- **Smart selection:** Agents triggered by diff content, not just LOC
- **Parallel execution:** All specialist agents run simultaneously for speed
- **Adversarial validation:** Final gate that challenges claims and findings
- **Re-runnable:** Re-run after fixing issues until APPROVED
- **Supervisor consolidates:** Deduplicates, removes false positives, prioritizes
- **Not a replacement for human review:** AI review supplements, doesn't replace
- **Diff-based:** Reviews only changed code, not entire codebase

---

## Integration Points

- **Input**: Staged git changes (diff)
- **Output**: Verdict + findings with severity + fixes applied (if user chooses)
- **Consumed by**: `/ship` (commit-and-pr) as mandatory gate
- **Agent definitions**: `agents/review/*.md`
- **Checklists**: `checklists/AI_CODE_SECURITY_REVIEW.md`, `checklists/AI_CODE_REVIEW.md`
