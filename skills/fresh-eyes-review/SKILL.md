---
name: fresh-eyes-review
version: "1.1"
description: 13-agent smart selection code review system with zero-context methodology
referenced_by:
  - commands/review.md
  - guides/FRESH_EYES_REVIEW.md
---

# Fresh Eyes Review Skill

Zero-context multi-agent code review with smart agent selection.

---

## When to Apply

- After validation passes (tests/lint/security all green)
- Need comprehensive, unbiased code review
- Before committing and creating PR/MR
- Prerequisites: code changes staged (`git add` completed)

---

## Core Principle

Review agents receive **zero conversation context** — they only see the code diff and their review checklist. This eliminates confirmation bias and ensures truly unbiased review.

---

## Agent Roster

### Core Agents (Always Run)

| # | Agent | Definition | Focus |
|---|-------|-----------|-------|
| 1 | Security Reviewer | `agents/review/security-reviewer.md` | OWASP Top 10, injection, auth, secrets |
| 2 | Code Quality Reviewer | `agents/review/code-quality-reviewer.md` | Naming, structure, SOLID, complexity |
| 3 | Edge Case Reviewer | `agents/review/edge-case-reviewer.md` | Null/empty/boundary (biggest AI blind spot) |
| 4 | Supervisor | `agents/review/supervisor.md` | Consolidate, deduplicate, prioritize |
| 5 | Adversarial Validator | `agents/review/adversarial-validator.md` | Falsification over confirmation |

### Conditional Agents (Triggered by Diff)

See `skills/fresh-eyes-review/references/trigger-patterns.md` for detailed patterns.

| # | Agent | Trigger Summary |
|---|-------|----------------|
| 6 | Performance | DB/ORM patterns, nested loops, LOC > 200 |
| 7 | API Contract | Route/endpoint definitions, API schema files |
| 8 | Concurrency | async/await/Promise/Thread/Lock/Mutex patterns |
| 9 | Error Handling | External calls, try/catch, LOC > 300 |
| 10 | Data Validation | User input handling, parse/decode operations |
| 11 | Dependency | Modified dependency files, >3 new imports |
| 12 | Testing Adequacy | Test files changed, OR code without tests |
| 13 | Config & Secrets | Config patterns, env/secret/key/token |
| 14 | Documentation | Public API changes, magic numbers, LOC > 300 |

---

## Smart Selection Algorithm

### Step 1: Generate Diff

```bash
git diff --staged > /tmp/review-diff.txt
git diff --staged --name-only > /tmp/review-files.txt
```

If no staged changes: notify user to stage changes first.

### Step 2: Trigger Detection

For each conditional agent, Grep the diff content AND file list for trigger patterns. See `skills/fresh-eyes-review/references/trigger-patterns.md` for exact patterns.

**Trigger patterns by agent:**

| Agent | Patterns (Grep diff + file paths) |
|-------|-----------------------------------|
| Performance | `SELECT\|INSERT\|UPDATE\|DELETE\|\.find\|\.where\|\.query\|ORM\|prisma\|sequelize`, nested loops, LOC > 200 |
| API Contract | `router\.\|app\.\(get\|post\|put\|delete\)\|@Controller\|@Route`, route/controller files, openapi/swagger |
| Concurrency | `async\|await\|Promise\|Thread\|Lock\|Mutex\|goroutine\|channel\|atomic\|Semaphore` |
| Error Handling | `fetch\(\|axios\.\|http\.\|fs\.\|readFile\|writeFile`, `try\|catch\|except\|rescue`, LOC > 300 |
| Data Validation | `req\.body\|req\.params\|req\.query\|FormData\|upload\|parse\|JSON\.parse\|parseInt` |
| Dependency | Modified `package\.json\|Cargo\.toml\|go\.mod\|requirements\.txt\|Gemfile`, >3 new imports |
| Testing Adequacy | test/spec files changed, OR >50 LOC non-test code with NO test changes |
| Config & Secrets | `env\|secret\|key\|token\|password\|credential\|api_key\|\.env\|config\.\|settings\.` |
| Documentation | Exported/public API changes, magic numbers, LOC > 300 |

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

### Phase 1: Specialist Reviews (Parallel)

Launch ALL specialist agents in a **single message** with multiple Task tool calls.

**Each agent receives:**
- Zero conversation context
- `/tmp/review-diff.txt`
- Agent definition file
- Relevant checklist (security agent gets `checklists/AI_CODE_SECURITY_REVIEW.md`)

**Agent prompt template:**
```
You are a [specialist type] with zero context about this project.
Read your review process from [agent definition file].
Review the code changes in /tmp/review-diff.txt.
Report findings with severity (CRITICAL, HIGH, MEDIUM, LOW).
Include file:line references and specific fixes.
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

### Phase 2: Supervisor (Sequential, after Phase 1)

- Validates each finding against code diff
- Removes false positives
- Consolidates duplicates
- Prioritizes by severity AND impact
- Creates todo specifications for CRITICAL/HIGH

### Phase 3: Adversarial Validation (Sequential, after Phase 2)

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

---

## Findings Tracking

After review, offer tracking options:
1. **File-based todos** (`.todos/` directory) — recommended for solo work
2. **Platform issues** (GitHub/GitLab) — recommended for teams
3. **Both** — file-based + platform issues
4. **None** — just show findings

For CRITICAL and HIGH findings, create tracking items automatically. For MEDIUM findings, ask user preference.

---

## Lite Review Mode

For quick reviews (`--lite`), run only:
- Security Reviewer
- Edge Case Reviewer
- Supervisor

Skip: Adversarial Validator, all conditional agents.

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
- **Output**: Verdict + findings with severity
- **Tracking**: File-based todos (`.todos/`) or platform issues (GitHub/GitLab)
- **Consumed by**: `/ship` (commit-and-pr) as mandatory gate
- **Agent definitions**: `agents/review/*.md`
- **Checklists**: `checklists/AI_CODE_SECURITY_REVIEW.md`, `checklists/AI_CODE_REVIEW.md`
