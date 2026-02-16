# Fresh Eyes Code Review

**Status:** MANDATORY for ALL code changes
**Purpose:** Unbiased code review using specialized agents with zero conversation context
**When:** Phase 1, Step 6 - After implementation and testing, before commit
**Version:** 4.0 — Smart agent selection with 13 specialists

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
| 8 | Concurrency Reviewer | `agents/review/concurrency-reviewer.md` | async/await/Promise/Thread/Lock/Mutex/goroutine/Channel/atomic/volatile |
| 9 | Error Handling Reviewer | `agents/review/error-handling-reviewer.md` | External HTTP calls, file I/O, try/catch patterns, LOC > 300 |
| 10 | Data Validation Reviewer | `agents/review/data-validation-reviewer.md` | User input handling (req.body/params/form), file uploads, parse/decode |
| 11 | Dependency Reviewer | `agents/review/dependency-reviewer.md` | Modified dependency files, >3 new imports |
| 12 | Testing Adequacy Reviewer | `agents/review/testing-adequacy-reviewer.md` | Test files changed, OR implementation without tests, >50 LOC non-test |
| 13 | Config & Secrets Reviewer | `agents/review/config-secrets-reviewer.md` | Config patterns (env/secret/key/token/password), config file modifications |
| 14 | Documentation Reviewer | `agents/review/documentation-reviewer.md` | Public API changes, magic numbers, LOC > 300, README/docs changes |

---

## Smart Selection Algorithm

### Step 1: Generate Diff

```bash
git diff --staged > /tmp/review-diff.txt
git diff --staged --name-only > /tmp/review-files.txt
```

### Step 2: Trigger Detection

For each conditional agent, Grep the diff content AND file list for trigger patterns:

**Performance Reviewer triggers:**
- Diff content: `SELECT|INSERT|UPDATE|DELETE|\.find|\.where|\.query|ORM|prisma|sequelize|knex|typeorm`
- Diff content: nested `for|while|\.map.*\.map|\.forEach.*\.forEach`
- LOC changed > 200
- File paths: `model|service|api|repository`

**API Contract Reviewer triggers:**
- Diff content: `router\.|app\.(get|post|put|delete|patch)|@Controller|@Route|@Get|@Post|endpoint|handler`
- File paths: `route|controller|handler|endpoint|api`
- Diff content: `openapi|swagger|schema\.json|\.graphql`

**Concurrency Reviewer triggers:**
- Diff content: `async|await|Promise|Thread|Lock|Mutex|goroutine|channel|atomic|volatile|Semaphore|\.lock\(\)|synchronized|actor|spawn`

**Error Handling Reviewer triggers:**
- Diff content: `fetch\(|axios\.|http\.|request\(|\.get\(|\.post\(|fs\.|readFile|writeFile|open\(`
- Diff content: `try|catch|except|rescue|recover`
- LOC changed > 300

**Data Validation Reviewer triggers:**
- Diff content: `req\.body|req\.params|req\.query|request\.form|request\.data|params\[|FormData|multipart|upload|parse|decode|JSON\.parse|parseInt|parseFloat`

**Dependency Reviewer triggers:**
- File paths: `package\.json|Cargo\.toml|go\.mod|go\.sum|requirements\.txt|Gemfile|pom\.xml|build\.gradle|pyproject\.toml`
- Diff content: >3 new `import|require|from|use` statements

**Testing Adequacy Reviewer triggers:**
- File paths matching: `test|spec|__tests__`
- OR: >50 LOC of non-test code with NO test file changes

**Config & Secrets Reviewer triggers:**
- Diff content (non-test files): `env|secret|key|token|password|credential|api_key|API_KEY`
- File paths: `\.env|config\.|settings\.|\.config\.|\.yaml|\.yml|\.toml`

**Documentation Reviewer triggers:**
- Diff content: `export|public|module\.exports|__all__`
- Diff content: bare numeric literals > 1 (magic numbers)
- LOC changed > 300
- File paths: `README|docs|\.md`

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

**Each agent receives:**
- Zero conversation context (fresh eyes)
- `/tmp/review-diff.txt` (the code diff)
- Agent definition file (from `agents/review/`)
- Relevant checklist file (security → `checklists/AI_CODE_SECURITY_REVIEW.md`, etc.)

**Agent prompt template:**
```
You are a [specialist type] with zero context about this project.

Read your review process from [agent definition file].
Review the code changes in /tmp/review-diff.txt.

[Checklist reference if applicable]

Report findings with severity (CRITICAL, HIGH, MEDIUM, LOW).
Include file:line references and specific fixes for each finding.
```

**CRITICAL:** All specialist agents MUST run in parallel (single message).

### Phase 2: Supervisor Consolidation (Sequential)

After ALL specialists complete, launch Supervisor:
- Receives: all specialist findings + original diff
- Tasks: validate findings, remove false positives, deduplicate, prioritize
- Output: consolidated report with todo specifications

**See:** `agents/review/supervisor.md`

### Phase 3: Adversarial Validation (Sequential)

After Supervisor completes, launch Adversarial Validator:
- Receives: supervisor's consolidated report + original diff
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

---

## Finding Tracking

After review, findings are tracked via the user's chosen mode:

### Mode A: File-Based Todos (`.todos/`)

For CRITICAL and HIGH findings, create todo files:
- Filename: `.todos/{issue_id}-pending-{priority}-{description-slug}.md`
- Template: `templates/TODO_TEMPLATE.md`

### Mode B: Platform Issues

For CRITICAL and HIGH findings, create issues:
```bash
# GitHub:
gh issue create --title "[{agent}] {title}" --label "priority:p1,review-finding,agent:{name}" --assignee @me
# GitLab:
glab issue create --title "[{agent}] {title}" --label "priority::p1,review-finding,agent:{name}" --assignee @me
```

### Mode C: Both

Create both file-based todos AND platform issues.

---

## Lite Review

For quick reviews (`--lite` flag), run only:
- Security Reviewer
- Edge Case Reviewer
- Supervisor

Skip: Adversarial Validator, all conditional agents.

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
| Lite | 3 (Security + Edge Case + Supervisor) | ~$0.05-0.10 |
| Standard (3-5 triggered) | 6-8 total | ~$0.15-0.30 |
| Full (all triggered) | 14 total | ~$0.30-0.50 |

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
