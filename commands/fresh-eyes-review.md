---
description: Multi-agent unbiased code review with smart agent selection (zero context)
---

# /fresh-eyes-review

**Description:** Multi-agent unbiased code review with smart agent selection (zero conversation context)

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
User types `/fresh-eyes-review` with no arguments. Claude auto-selects agents based on diff analysis.

**Direct mode:**
User types `/fresh-eyes-review --lite` for minimal review, or `/fresh-eyes-review --track=files` to specify tracking mode.

---

## Arguments

- `--lite` - Lite review (Security + Edge Case + Supervisor only) for quick reviews
- `--track=files` - Track findings as file-based todos in `.todos/`
- `--track=github` - Track findings as GitHub issues
- `--track=both` - Track findings in both systems

---

## Execution Steps

### Step 1: Create diff file from staged changes

**Generate diff:**
```bash
git diff --staged > /tmp/review-diff.txt
```

**If no staged changes:**
```
No staged changes found!

Stage your changes first:
  git add <files>

Then run: `/fresh-eyes-review`
```

### Step 2: Analyze diff for smart agent selection

**Count lines of code changed:**
- Count added lines (+) and removed lines (-)
- Total LOC changed = |added| + |removed|

**Get changed file list:**
```bash
git diff --staged --name-only > /tmp/review-files.txt
```

**Run trigger detection against diff content and file paths:**

| # | Agent | Trigger Patterns (Grep diff content + file paths) |
|---|-------|----------------------------------------------------|
| 5 | Performance | `SELECT\|INSERT\|UPDATE\|DELETE\|\.find\|\.where\|\.query\|ORM\|model\|prisma\|sequelize\|knex\|typeorm`, nested `for\|while\|\.map.*\.map\|\.forEach.*\.forEach`, LOC > 200, file paths matching `model\|service\|api\|repository` |
| 6 | API Contract | `router\.\|app\.\(get\|post\|put\|delete\|patch\)\|@Controller\|@Route\|@Get\|@Post\|endpoint\|handler`, file paths matching `route\|controller\|handler\|endpoint\|api`, `openapi\|swagger\|schema\.json\|\.graphql` |
| 7 | Concurrency | `async\|await\|Promise\|Thread\|Lock\|Mutex\|goroutine\|channel\|atomic\|volatile\|Semaphore\|\.lock\(\)\|synchronized\|actor\|spawn` |
| 8 | Error Handling | `fetch\(\|axios\.\|http\.\|request\(\|\.get\(\|\.post\(\|fs\.\|readFile\|writeFile\|open\(`, `try\|catch\|except\|rescue\|recover`, LOC > 300 |
| 9 | Data Validation | `req\.body\|req\.params\|req\.query\|request\.form\|request\.data\|params\[\|FormData\|multipart\|upload\|parse\|decode\|JSON\.parse\|parseInt\|parseFloat` |
| 10 | Dependency | Modified `package\.json\|Cargo\.toml\|go\.mod\|go\.sum\|requirements\.txt\|Gemfile\|pom\.xml\|build\.gradle\|pyproject\.toml`, >3 new import/require statements |
| 11 | Testing Adequacy | File paths matching `test\|spec\|__tests__`, OR >50 LOC non-test code with NO test file changes |
| 12 | Config & Secrets | `env\|secret\|key\|token\|password\|credential\|api_key\|API_KEY\|\.env\|config\.\|settings\.\|\.config\.\|\.yaml\|\.yml\|\.toml` (in non-test files) |
| 13 | Documentation | Exported/public API changes (`export\|public\|module\.exports\|__all__`), magic numbers (bare numeric literals >1), LOC > 300, file paths matching `README\|docs\|\.md` |

**Smart selection algorithm:**
1. Grep `/tmp/review-diff.txt` for each conditional agent's trigger patterns
2. Grep `/tmp/review-files.txt` for file path triggers
3. Build agent roster: **Core agents always run** (Security, Code Quality, Edge Case) + triggered conditional agents
4. Present selection to user with reasoning:

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
  - API Contract Reviewer (triggered: route definitions in src/api/users.ts)

Total agents: 6 specialists + Supervisor + Adversarial Validator = 8

Proceed with this selection? (yes / customize): ___
```

### Step 3: Launch specialist review agents IN PARALLEL

**CRITICAL:** All specialist agents launch in a SINGLE message with multiple Task tool calls.

Each agent receives:
- Zero conversation context (fresh eyes — intentional for unbiased review)
- `/tmp/review-diff.txt` (the code diff)
- Its agent definition from `agents/review/{agent-name}.md`
- Relevant checklist files (security agent gets `checklists/AI_CODE_SECURITY_REVIEW.md`, etc.)

**Agent prompt template:**
```
You are a [specialist type] with zero context about this project.

Read your review process from [agent definition file path].
Review the code changes in /tmp/review-diff.txt.

[Agent-specific checklist reference if applicable]

Report findings with severity (CRITICAL, HIGH, MEDIUM, LOW).

Output format:
[AGENT NAME] REVIEW FINDINGS:

CRITICAL:
- [Finding with file:line reference and specific fix]

HIGH:
- [Finding with file:line reference and specific fix]

MEDIUM:
- [Finding with file:line reference]

LOW:
- [Finding with file:line reference]

PASSED:
- [List of checks that passed]

Total issues: N
Recommendation: BLOCK | FIX_BEFORE_COMMIT | APPROVED
```

**Agent definitions referenced:**
- `agents/review/security-reviewer.md`
- `agents/review/code-quality-reviewer.md`
- `agents/review/edge-case-reviewer.md`
- `agents/review/performance-reviewer.md` (if triggered)
- `agents/review/api-contract-reviewer.md` (if triggered)
- `agents/review/concurrency-reviewer.md` (if triggered)
- `agents/review/error-handling-reviewer.md` (if triggered)
- `agents/review/data-validation-reviewer.md` (if triggered)
- `agents/review/dependency-reviewer.md` (if triggered)
- `agents/review/testing-adequacy-reviewer.md` (if triggered)
- `agents/review/config-secrets-reviewer.md` (if triggered)
- `agents/review/documentation-reviewer.md` (if triggered)

### Step 4: Launch Supervisor AFTER all specialists complete

**Read:** `agents/review/supervisor.md`

**Supervisor receives:**
- All specialist findings
- Original diff file: `/tmp/review-diff.txt`

**Supervisor tasks:**
1. Validate each finding against the code diff
2. Remove false positives
3. Consolidate duplicate findings
4. Prioritize by severity AND impact
5. Create todo specifications for CRITICAL and HIGH findings

### Step 5: Launch Adversarial Validator AFTER Supervisor

**Read:** `agents/review/adversarial-validator.md`

**Adversarial Validator receives:**
- Original diff file: `/tmp/review-diff.txt`
- Supervisor's consolidated report

**Adversarial Validator tasks:**
1. Inventory every claim in the implementation (implied by diff): "handles edge cases", "validates input", "error handling present"
2. Demand evidence for each claim — look for actual code, not just assertions
3. Challenge review findings — are any false positives? Is anything missed?
4. Probe AI blind spots systematically
5. Classify claims as: **VERIFIED** | **UNVERIFIED** | **DISPROVED** | **INCOMPLETE**
6. DISPROVED claims escalate to BLOCK verdict

### Step 6: Determine verdict

**Verdict categories:**

| Verdict | Meaning | Action |
|---------|---------|--------|
| **BLOCK** | 1+ CRITICAL issues or DISPROVED claims | Fix immediately, re-run review |
| **FIX_BEFORE_COMMIT** | 1+ HIGH issues | Fix issues, re-run review |
| **APPROVED_WITH_NOTES** | MEDIUM/LOW only | Proceed, address notes later |
| **APPROVED** | No issues | Proceed to commit |

### Step 7: Create findings tracking

**Ask user for tracking preference (if not specified via --track flag):**

```
Review findings ready. Track them as:
1. File-based todos (.todos/ directory) (Recommended for solo work)
2. GitHub issues (project board) (Recommended for teams)
3. Both (file-based + GitHub issues)
4. None (just show findings, don't track)

Choice: ___
```

**If a project's CLAUDE.md specifies a default tracking mode, use that without asking.**

**File-based todos (.todos/):**
For each CRITICAL and HIGH finding, create a todo file:
- Filename: `.todos/{issue_id}-pending-{priority}-{description-slug}.md`
- Use template from `templates/TODO_TEMPLATE.md`
- Fill in: issue_id, priority, title, source (fresh-eyes-review), agent, file, line, finding, action

For MEDIUM findings: ask user "Track MEDIUM findings as todos? (yes/no)"

**GitHub issues:**
For each CRITICAL and HIGH finding:
```bash
gh issue create \
  --title "[{agent}] {finding title}" \
  --label "priority:{p1|p2|p3},review-finding,agent:{agent-name}" \
  --body "{finding details, file/line, suggested fix, acceptance criteria}" \
  --assignee @me
```

### Step 8: Report findings and suggest next steps

**Output format:**

```
=== FRESH EYES REVIEW VERDICT ===

Agents: Security, Code Quality, Edge Case, Performance, Testing Adequacy + Supervisor + Adversarial Validator
LOC Changed: 234 lines

=== CRITICAL ISSUES (BLOCK) ===
[Security] SQL Injection in src/api/users.ts:45
  Finding: Raw SQL with user input concatenation
  Fix: Use parameterized queries
  Claim status: VERIFIED (adversarial validator confirmed)

=== HIGH PRIORITY ISSUES (FIX BEFORE COMMIT) ===
[Edge Case] Missing null check in src/auth/AuthService.ts:67
  Finding: user.email accessed without null guard
  Fix: Add if (!user?.email) guard clause

=== MEDIUM PRIORITY ISSUES (ADDRESS SOON) ===
[Code Quality] Complex function in src/utils/validate.ts:23
  Finding: Cyclomatic complexity = 12 (target: <8)
  Fix: Extract helper functions

=== LOW PRIORITY / SUGGESTIONS ===
[Documentation] Magic number in src/config.ts:15
  Finding: Hardcoded 86400 (seconds in day)
  Suggestion: const SECONDS_PER_DAY = 86400

=== ADVERSARIAL VALIDATION ===
Claims checked: 8
VERIFIED: 5 | UNVERIFIED: 2 | DISPROVED: 0 | INCOMPLETE: 1

Unverified claims:
- "Handles concurrent requests" — no concurrency tests found
- Incomplete: "Input validation" — validates email format but not length

=== VERDICT ===
Status: FIX_BEFORE_COMMIT

Findings tracked: 3 todos created in .todos/

Action required:
1. Fix SQL injection in src/api/users.ts:45
2. Fix missing null check in src/auth/AuthService.ts:67
3. Re-run review after fixes
```

**If BLOCK or FIX_BEFORE_COMMIT:**
```
Fix CRITICAL/HIGH issues before committing.

Next steps:
- Fix issues listed above
- Re-run review: `/fresh-eyes-review`
- If unfixable, consider: `/recovery`
```

**If APPROVED:**
```
No blocking issues found.

Next steps:
- Commit and create PR: `/commit-and-pr`
- Capture learnings: `/compound` (if you learned something worth documenting)
```

---

## Output

**Review findings:**
- CRITICAL issues (if any)
- HIGH priority issues (if any)
- MEDIUM priority issues (if any)
- LOW priority / suggestions (if any)
- Adversarial validation results

**Verdict:** BLOCK | FIX_BEFORE_COMMIT | APPROVED | APPROVED_WITH_NOTES

**Metadata:**
- Agents involved (core + triggered)
- LOC changed
- Trigger reasoning
- Claim verification summary
- Confidence level

**Tracking:** Todos created in `.todos/` and/or GitHub issues (per user choice)

**Suggested next steps:**
- If BLOCK/FIX: "Fix issues and re-run `/fresh-eyes-review`"
- If APPROVED: "Proceed to `/commit-and-pr`"

---

## References

- See: `agents/review/*.md` for individual agent definitions
- See: `guides/FRESH_EYES_REVIEW.md` for full review workflow and trigger table
- See: `checklists/AI_CODE_SECURITY_REVIEW.md` for security checklist
- See: `checklists/AI_CODE_REVIEW.md` for code quality checklist
- See: `templates/TODO_TEMPLATE.md` for todo file format
- See: `AI_CODING_AGENT_GODMODE.md` Phase 1 Step 6 for review guidance

---

## Example Usage

**Example 1: Smart selection (auto)**
```
User: /fresh-eyes-review

Claude: Fresh Eyes Review — Agent Selection

LOC changed: 234 lines
Files changed: 5

Core agents (always run):
  - Security Reviewer
  - Code Quality Reviewer
  - Edge Case Reviewer

Conditional agents triggered:
  - Performance Reviewer (ORM patterns)
  - Testing Adequacy (180 LOC, no test changes)

Proceed? yes

[Launches 5 specialists in parallel]
[Launches Supervisor after specialists]
[Launches Adversarial Validator after Supervisor]

Fresh Eyes Review: FIX_BEFORE_COMMIT
1 HIGH issue: Missing null check

Tracked: 1 todo created in .todos/

Fix and re-run: `/fresh-eyes-review`
```

**Example 2: Lite review**
```
User: /fresh-eyes-review --lite

Claude: Lite Review — 3 agents only (Security + Edge Case + Supervisor)

[Launches review]

Fresh Eyes Review: APPROVED

Next: `/commit-and-pr`
```

**Example 3: With GitHub issue tracking**
```
User: /fresh-eyes-review --track=github

Claude: [Runs full smart selection review]

Fresh Eyes Review: FIX_BEFORE_COMMIT
2 findings tracked as GitHub issues:
  - Issue #201: [Security] SQL injection risk
  - Issue #202: [Edge Case] Missing null check

Fix and re-run.
```

---

## Notes

- **Zero context:** Agents have NO conversation history (true fresh eyes)
- **Smart selection:** Agents triggered by diff content, not just LOC
- **Parallel execution:** All specialist agents run simultaneously for speed
- **Adversarial validation:** Final gate that challenges claims and findings
- **Dual tracking:** File-based todos OR GitHub issues (user chooses)
- **Re-runnable:** Re-run after fixing issues until APPROVED
- **Supervisor consolidates:** Deduplicates, removes false positives, prioritizes
- **Not a replacement for human review:** AI review supplements, doesn't replace
- **Diff-based:** Reviews only changed code, not entire codebase
