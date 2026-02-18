# Fresh Eyes Code Review

**Status:** MANDATORY for ALL code changes
**Purpose:** Unbiased code review using specialized agents with zero conversation context
**When:** Phase 1, Step 6 - After implementation and testing, before commit
**Version:** 5.0 — Smart agent selection with 11 specialists, LOC gate, hunk extraction, output summarization

---

## CRITICAL: This Step is MANDATORY

**CHECKPOINT: You CANNOT proceed to commit/PR without completing this review.**

**Why this matters:**
- Eliminates confirmation bias (review agents don't know your implementation reasoning)
- Catches security vulnerabilities (45% of AI code has security issues)
- Validates edge case handling (null, empty, boundaries)
- Prevents bugs from reaching production
- Adversarial validation challenges claims with evidence, not assertions

**If you find yourself skipping this step:**
- STOP immediately
- This is a protocol violation

---

## Agent Roster

### Core Agents (Always Run)

| # | Agent | Definition | Focus |
|---|-------|-----------|-------|
| 1 | Security Reviewer | `agents/review/security-reviewer.md` | OWASP Top 10, injection, auth, secrets, input validation |
| 2 | Code Quality Reviewer | `agents/review/code-quality-reviewer.md` | Naming, structure, complexity, SOLID, error handling |
| 3 | Edge Case Reviewer | `agents/review/edge-case-reviewer.md` | Null/empty/boundary/unicode/off-by-one (dedicated — biggest AI blind spot) |
| 4 | Supervisor | `agents/review/supervisor.md` | Consolidate findings, deduplicate, prioritize, create todo specs. Runs AFTER specialists. |
| 5 | Adversarial Validator | `agents/review/adversarial-validator.md` | Falsification over confirmation. Challenges claims AND findings. Runs AFTER Supervisor. |

### Conditional Agents (Triggered by Diff Analysis)

| # | Agent | Definition | Trigger Patterns |
|---|-------|-----------|-----------------|
| 6 | Performance Reviewer | `agents/review/performance-reviewer.md` | DB/ORM patterns, nested loops, LOC > 200, model/service/api file paths |
| 7 | API Contract Reviewer | `agents/review/api-contract-reviewer.md` | Route/endpoint definitions, controller/handler paths, API schema files |
| 8 | Concurrency Reviewer | `agents/review/concurrency-reviewer.md` | Promise.all/race/allSettled, Lock/Mutex/Semaphore, goroutine/channel, Thread/spawn/actor |
| 9 | Error Handling Reviewer | `agents/review/error-handling-reviewer.md` | External HTTP/fs calls, try/catch patterns, LOC > 300 |
| 10 | Dependency Reviewer | `agents/review/dependency-reviewer.md` | Modified dependency files, >3 new imports |
| 11 | Testing Adequacy Reviewer | `agents/review/testing-adequacy-reviewer.md` | Test files changed, OR implementation without tests, >50 LOC non-test |
| 12 | Documentation Reviewer | `agents/review/documentation-reviewer.md` | Public API changes, magic numbers, LOC > 300, README/docs changes |

---

## Smart Selection Algorithm

### Step 1: Generate Diff

```bash
git diff --staged -U5 > /tmp/review-diff.txt
git diff --staged --name-only > /tmp/review-files.txt
```

### Step 2: Trigger Detection

For each conditional agent, Grep the diff content AND file list for trigger patterns:

**Performance Reviewer triggers:**
- Diff content: `SELECT|INSERT|UPDATE|DELETE|\.find|\.where|\.query|ORM|prisma|sequelize|knex|typeorm`
- Diff content: chained iterations `\.find\(.*\.find\(|\.filter\(.*\.filter\(|\.map\(.*\.map\(|\.forEach\(.*\.forEach\(`
- LOC changed > 200
- File paths: `model|service|api|repository`

**API Contract Reviewer triggers:**
- Diff content: `router\.|app\.(get|post|put|delete|patch)|@Controller|@Route|@Get|@Post|endpoint|handler`
- File paths: `route|controller|handler|endpoint|api`
- Diff content: `openapi|swagger|schema\.json|\.graphql`

**Concurrency Reviewer triggers:**
- Diff content: `Promise\.all|Promise\.race|Promise\.allSettled|new Promise|\.lock\(|\.unlock\(|Mutex|Semaphore|goroutine|channel|atomic\.|volatile |synchronized |Thread\(|spawn\(|actor |worker_threads|SharedArrayBuffer|Atomics\.|concurrent\.|parallelStream`

**Error Handling Reviewer triggers:**
- Diff content: `fetch\(|axios\.|http\.(get|post|put|delete)|request\(|fs\.(readFile|writeFile|access|mkdir|unlink|stat)|open\(.*O_|createReadStream|createWriteStream`
- Diff content: `try|catch|except|rescue|recover`
- LOC changed > 300

**Dependency Reviewer triggers:**
- File paths: `package\.json|Cargo\.toml|go\.mod|go\.sum|requirements\.txt|Gemfile|pom\.xml|build\.gradle|pyproject\.toml`
- Diff content: >3 new `import|require|from|use` statements

**Testing Adequacy Reviewer triggers:**
- File paths matching: `test|spec|__tests__`
- OR: >50 LOC of non-test code with NO test file changes

**Documentation Reviewer triggers:**
- Diff content: `export (default |function |class |const |interface |type )|module\.exports\s*=|__all__\s*=`
- Diff content: bare numeric literals > 1 (magic numbers)
- LOC changed > 300
- File paths: `README|docs|\.md`

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

**Agents that read the full diff (`/tmp/review-diff.txt`):**
- Core agents: Security Reviewer, Code Quality Reviewer, Edge Case Reviewer
- Adversarial Validator (Phase 3)

**Agents that do NOT read the diff:**
- Supervisor (Phase 2) — receives Phase 1.5 summarized findings only

### Step 3: Build Agent Roster

```
Roster = Core (Security, Code Quality, Edge Case) + Triggered Conditional Agents
```

### Step 4: Present Selection

Show user which agents will run and why, with option to customize.

---

## Review Workflow

### Phase 1: Specialist Reviews (Parallel)

Launch ALL specialist agents simultaneously in a single message with multiple Task tool calls.

**Each agent receives in its prompt:**
- Zero conversation context (fresh eyes)
- Agent review process (inlined from `agents/review/`)
- Security checklist (inlined, security agent only)
- File path to diff — agent reads it via the Read tool:
  - **Core agents** read: `/tmp/review-diff.txt`
  - **Conditional agents** read: `/tmp/review-diff-{agent-name}.txt` (produced by Step 2.6)

**Why agents read the diff themselves:** Inlining the diff into every agent prompt stores N copies in the orchestrator's context window. With 8+ agents on a large diff, this exceeds context limits before Phase 2 can run. Agents reading from `/tmp/` keeps the diff in their own context only.

**Compact output format:** All agents use a structured format — max 8 findings, no preamble/philosophy, `NO_FINDINGS` for empty results. See SKILL.md for exact template.

**CRITICAL:** All specialist agents MUST run in parallel (single message).

### Phase 2: Supervisor Consolidation (Sequential)

After ALL specialists complete, launch Supervisor:
- Receives: Phase 1.5 summarized findings (not raw output)
- Tasks: validate findings, remove false positives, deduplicate, prioritize
- Output: consolidated report with todo specifications

**See:** `agents/review/supervisor.md`

### Phase 3: Adversarial Validation (Sequential)

After Supervisor completes, launch Adversarial Validator:
- Receives: Supervisor's consolidated report + diff file path (`/tmp/review-diff.txt`)
- AV reads the diff itself to verify claims against actual code
- Tasks: inventory claims, demand evidence, challenge findings, classify claims
- Output: claim verification (VERIFIED / UNVERIFIED / DISPROVED / INCOMPLETE)

**DISPROVED claims escalate to BLOCK verdict.**

**See:** `agents/review/adversarial-validator.md`

---

## Verdict Determination

| Verdict | Condition | Action |
|---------|-----------|--------|
| **BLOCK** | 1+ CRITICAL issues OR DISPROVED claims | Fix immediately, re-run review |
| **FIX_BEFORE_COMMIT** | 1+ HIGH issues | Fix issues, re-run review |
| **APPROVED_WITH_NOTES** | MEDIUM/LOW only | Proceed, address notes later |
| **APPROVED** | No issues | Proceed to commit |

### Post-Verdict: Persist Results

After determining the verdict:
1. Write verdict to `.todos/review-verdict.md` (read by `/ship` Step 0)
2. Write full report to `.todos/review-report.md` — includes YAML frontmatter (verdict, timestamp, branch, agents, finding counts) and all findings with todo specifications. Survives context compaction. Fix subagents read from this file.

Both files are overwritten on each review run.

---

## Finding Tracking

After review, findings are tracked via the user's chosen mode:

### Mode A: File-Based Todos (`.todos/`)

For CRITICAL and HIGH findings, create todo files:
- Filename: `.todos/{issue_id}-pending-{priority}-{description-slug}.md`
- Template: `templates/TODO_TEMPLATE.md`

### Mode B: GitHub Issues

For CRITICAL and HIGH findings, create issues:
```bash
gh issue create --title "[{agent}] {title}" --label "priority:p1,review-finding,agent:{name}" --assignee @me
```

### Mode C: Both

Create both file-based todos AND GitHub issues.

---

## Lite Review

For quick reviews (`--lite` flag), run only:
- Security Reviewer
- Code Quality Reviewer
- Edge Case Reviewer
- Supervisor

Skip: Adversarial Validator, all conditional agents.

**Why Code Quality is included:** Code Quality catches naming, structure, and SOLID violations that are common even in small diffs. Dropping it creates a coverage gap where structural issues go entirely unreviewed.

**Auto-routing:** The LOC gate (Step 2.5) automatically recommends Lite review for small changesets (<= 50 LOC added, no security-sensitive patterns). Users can override at the gate prompt.

---

## Why Fresh Eyes Review Works

**Eliminates Confirmation Bias:**
- Review agents have zero conversation context
- They don't know your implementation reasoning
- They only see: code diff + checklist

**Catches What You Miss:**
- Edge cases (null, empty, boundaries) — dedicated agent
- Security vulnerabilities (you forgot input validation)
- Performance issues (N+1 queries you didn't notice)
- Adversarial validator challenges your assumptions

**Smart Selection:**
- Only runs agents relevant to your changes
- Reduces noise from irrelevant findings
- Faster reviews for focused changes

---

## Cost Optimization

| Review Type | Agents | Estimated Cost |
|-------------|--------|---------------|
| Lite | 4 (Security + Code Quality + Edge Case + Supervisor) | ~$0.08-0.15 |
| Standard (3-5 triggered) | 6-8 total | ~$0.15-0.30 |
| Full (all triggered) | 12 total | ~$0.30-0.50 |

**ROI:** Prevents costly production bugs, security vulnerabilities, and technical debt.

---

## Common Pitfalls

### Skipping Review for "Small" Changes

One-line changes can introduce critical bugs: missing null check → production crash, hardcoded credential → security breach, off-by-one → data corruption.

**Solution:** Use Lite Review for small changes.

### Ignoring MEDIUM/LOW Findings

MEDIUM issues compound into technical debt. LOW issues flag patterns.

**Solution:** Track as todos, address in next iteration.

### Not Re-Running After Major Fixes

Fixes may introduce new issues.

**Solution:** Re-run review if >3 issues fixed or if fixes touch multiple areas.

---

## Troubleshooting

### Review Agent Returns Empty Findings
**Cause:** No diff to review (nothing staged)
**Fix:** Ensure staged changes exist: `git diff --staged` should show output

### Supervisor Marks Everything as False Positive
**Cause:** Review agents misunderstood context or checklist too strict
**Fix:** Review supervisor reasoning. If legitimate, update checklist to clarify.

### Too Many Conditional Agents Triggered
**Cause:** Large diff touches many domains
**Fix:** Break into smaller commits. Review incrementally per feature.

---

**Last Updated:** February 2026
**See Also:**
- `agents/review/*.md` - Individual agent definitions
- `checklists/AI_CODE_SECURITY_REVIEW.md` - Security checklist
- `checklists/AI_CODE_REVIEW.md` - Code quality checklist
- `templates/TODO_TEMPLATE.md` - Todo file format
- `guides/MULTI_AGENT_PATTERNS.md` - Agent coordination patterns
