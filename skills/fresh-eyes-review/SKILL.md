---
name: fresh-eyes-review
version: "2.1"
description: 14-agent smart selection code review system with zero-context methodology and optional Agent Teams mode
referenced_by:
  - commands/review.md
  - guides/FRESH_EYES_REVIEW.md
  - guides/AGENT_TEAMS_GUIDE.md
---

# Fresh Eyes Review Skill

Zero-context multi-agent code review with smart agent selection.

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

## Step 0: Detect Execution Mode

**CRITICAL: Check your tool list RIGHT NOW.** Do NOT rely on what you did earlier in this conversation. Each skill invocation must re-evaluate independently — conversation history is not a valid signal for tool availability.

Check if the TeammateTool is available in your tool list.

- **Available** → follow `[TEAM MODE]` instructions throughout this skill
- **Not available** → follow `[SUBAGENT MODE]` instructions (existing Task tool behavior)

See `guides/AGENT_TEAMS_GUIDE.md` for full team formation patterns and best practices (Pattern A: Review Team).

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

### `[TEAM MODE]` — Agent Teams Execution

**Phase 1: Spawn Specialist Teammates**

Form a Review Team. You (the Lead) act as Coordinator, Supervisor, and Adversarial Validator.

1. Spawn one teammate per specialist from the roster (core + triggered conditional agents)
2. Each teammate receives a spawn prompt containing:
   - Zero conversation context (fresh eyes principle preserved)
   - The diff content from `/tmp/review-diff.txt`
   - Their agent definition file reference
   - Relevant checklist (security agent gets `checklists/AI_CODE_SECURITY_REVIEW.md`)
3. Create a shared task list with one review task per specialist
4. Teammates execute their reviews independently

**Teammate spawn prompt template:**
```
You are a [specialist type] with zero context about this project.
Read your review process from [agent definition file].
Review the code changes in /tmp/review-diff.txt.

Instructions:
- Post findings to the task list with severity (CRITICAL/HIGH/MEDIUM/LOW)
- Include file:line references and specific fixes
- If you find a CRITICAL issue, broadcast it to the team immediately
- If your finding overlaps with another reviewer's domain, message them
- When the Lead asks a question, respond with specific evidence from the code
- Format: [ID] severity:LEVEL file:line description

Mark your task as done when complete.
```

**Inter-agent communication during Phase 1:**
- Specialists may message each other about overlapping findings
- CRITICAL findings are broadcast to the entire team
- Lead monitors progress via the shared task list

**Phase 2: Lead Consolidation (Supervisor Role)**

After all specialists complete:
1. Read all specialist findings from the task list and messages
2. Identify duplicate findings — message involved specialists: "You and [other specialist] both flagged [location]. Can you clarify the distinction?"
3. For ambiguous findings — message the specialist: "What evidence supports [finding]? Is this exploitable or theoretical?"
4. Remove false positives based on specialist responses
5. Prioritize by severity AND real-world impact
6. Create todo specifications for CRITICAL/HIGH findings

**Phase 3: Lead Adversarial Validation**

After consolidation:
1. Inventory all claims from the implementation and the review
2. Challenge findings by messaging specialists directly: "Security Reviewer, what evidence confirms [claim]?"
3. Specialists respond with evidence or retract their finding
4. Classify claims: VERIFIED | UNVERIFIED | DISPROVED | INCOMPLETE
5. DISPROVED claims on CRITICAL/HIGH findings escalate to BLOCK verdict
6. Challenge your own consolidation decisions — did you remove any valid findings?

**Team cleanup:**
After producing the final report, shut down all specialist teammates and clean up the team.

---

### `[SUBAGENT MODE]` — Task Tool Execution (Fallback)

**Phase 1: Specialist Reviews (Parallel)**

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

**Phase 2: Supervisor (Sequential, after Phase 1)**

Launch Supervisor as a Task tool call with all specialist outputs:
- Validates each finding against code diff
- Removes false positives
- Consolidates duplicates
- Prioritizes by severity AND impact
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

**If "Fix all findings" or "Fix CRITICAL/HIGH only":**
1. Lead fixes each finding sequentially on the current branch
   - Apply each fix directly (small, well-scoped edits)
   - No parallel agents needed — review findings are small, same-branch fixes
2. Run validation: `lint, type-check, all tests pass`
3. Re-stage changes: `git add` the fixed files
4. Present fix summary:

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

5. Ask whether to re-run review on the fixed code:

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
3. Fix selected findings sequentially
4. Continue from step 2 above (validate, re-stage, summary)

**If "Dismiss and proceed":**
1. If CRITICAL/HIGH findings exist, confirm: "Are you sure? The following CRITICAL/HIGH findings will be unaddressed: [list]"
2. If confirmed, note dismissed findings in commit context
3. Proceed to commit

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
- **Output**: Verdict + findings with severity + fixes applied (if user chooses)
- **Consumed by**: `/ship` (commit-and-pr) as mandatory gate
- **Agent definitions**: `agents/review/*.md`
- **Checklists**: `checklists/AI_CODE_SECURITY_REVIEW.md`, `checklists/AI_CODE_REVIEW.md`
