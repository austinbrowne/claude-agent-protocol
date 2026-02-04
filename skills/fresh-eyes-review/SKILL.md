---
name: fresh-eyes-review
version: "1.0"
description: 13-agent smart selection code review system with zero-context methodology
referenced_by:
  - commands/fresh-eyes-review.md
  - commands/workflows/godmode.md
  - guides/FRESH_EYES_REVIEW.md
---

# Fresh Eyes Review Skill

Zero-context multi-agent code review with smart agent selection.

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

### Step 2: Trigger Detection

For each conditional agent, Grep the diff content AND file list for trigger patterns. See `skills/fresh-eyes-review/references/trigger-patterns.md` for exact patterns.

### Step 3: Build Roster

```
Roster = Core (Security, Code Quality, Edge Case) + Triggered Conditional Agents
Post-processing = Supervisor (after specialists) + Adversarial Validator (after supervisor)
```

### Step 4: Present Selection

Show user which agents will run with reasoning. Allow customization.

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

## Lite Review Mode

For quick reviews (`--lite`), run only:
- Security Reviewer
- Edge Case Reviewer
- Supervisor

Skip: Adversarial Validator, all conditional agents.

---

## Integration Points

- **Input**: Staged git changes (diff)
- **Output**: Verdict + findings with severity
- **Tracking**: File-based todos (`.todos/`) or GitHub issues
- **Consumed by**: `/commit-and-pr` (mandatory gate)
- **Agent definitions**: `agents/review/*.md`
- **Checklists**: `checklists/AI_CODE_SECURITY_REVIEW.md`, `checklists/AI_CODE_REVIEW.md`
