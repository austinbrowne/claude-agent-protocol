---
description: Bug fix orchestrator with investigation — explore, fix, validate, ship
---

# /bugfix

**Description:** Bug fix orchestrator with investigation step — understand the bug before fixing it

**When to use:**
- Fixing a reported bug that needs investigation
- Root cause is not immediately obvious
- Bug affects production or critical functionality
- Want structured investigate → fix → validate → ship flow

**Prerequisites:** None (entry point command)

---

## Invocation

**Interactive mode:**
User types `/bugfix` with no arguments. Claude asks for bug description or issue number.

**Direct mode:**
User types `/bugfix [issue-number-or-description]` to start immediately.

---

## Arguments

- `[issue-number]` - GitHub issue number (e.g., `456`)
- `[description]` - Natural language bug description (e.g., `"login fails with special characters"`)

---

## Execution

### Step 1: Investigate

**1.1: Load bug context**

If issue number provided:
```bash
gh issue view [number] --json title,body,labels
```

If description provided:
- Use as investigation target

**1.2: Explore affected code**
- Invoke `/explore` targeting the bug area
- Searches `docs/solutions/` for past fixes in this area automatically

**1.3: Present investigation findings**

```
Bug Investigation:

Context: [bug description or issue details]
Affected files: [key files identified]
Past solutions: [relevant learnings from docs/solutions/]

Root cause hypothesis: [what we think is wrong]
```

**1.4: Choose next action**

```
AskUserQuestion:
  question: "Investigation complete. How should we proceed?"
  header: "Next step"
  options:
    - label: "Proceed to fix"
      description: "Root cause identified — implement the fix"
    - label: "Run /brainstorm"
      description: "Multiple approaches possible — brainstorm first"
    - label: "Done"
      description: "Need more investigation — pause workflow"
```

---

### Step 2: Fix

**2.1: Start issue (if issue exists)**
- Invoke `/start-issue [number]` if working from a GitHub issue
- Otherwise, implement fix inline

**2.2: Implement the fix**
- Apply the fix based on investigation findings
- Reference past learnings if applicable

**2.3: Choose next action**

```
AskUserQuestion:
  question: "Fix implemented. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Run /generate-tests"
      description: "Generate regression tests for the bug fix"
    - label: "Run /fresh-eyes-review --lite"
      description: "Quick review (Security + Edge Case + Supervisor)"
    - label: "Done"
      description: "Continue working — run commands manually later"
```

---

### Step 3: Validate

**3.1: Generate regression test**
- Invoke `/generate-tests` focused on the bug scenario
- Test should fail without fix, pass with fix

**3.2: Quick review**
- Invoke `/fresh-eyes-review --lite` (lighter review for bug fixes)
- If issues found: fix and re-review

**3.3: Choose next action**

```
AskUserQuestion:
  question: "Validation complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Run /compound"
      description: "Capture what caused the bug and the fix as a learning"
    - label: "Run /commit-and-pr"
      description: "Commit and create pull request"
    - label: "Done"
      description: "End workflow"
```

---

### Step 4: Ship

**4.1: Compound (recommended)**
- Invoke `/compound` — bug fixes are prime learning opportunities
- Captures: what went wrong, root cause, fix, gotchas

**4.2: Commit and PR**
- Invoke `/commit-and-pr`

---

## Flow Diagram

```
/bugfix [issue-or-description]
  ├─ Step 1: Investigate
  │   ├─ /explore [bug area]
  │   ├─ Search docs/solutions/ for past fixes
  │   └─ AskUserQuestion: [proceed-to-fix / brainstorm / done]
  ├─ Step 2: Fix
  │   ├─ /start-issue (if issue exists) or inline fix
  │   └─ AskUserQuestion: [generate-tests / fresh-eyes-review --lite / done]
  ├─ Step 3: Validate
  │   ├─ /generate-tests (regression test)
  │   ├─ /fresh-eyes-review --lite
  │   └─ AskUserQuestion: [compound / commit-and-pr / done]
  └─ Step 4: Ship
      ├─ /compound (capture the learning)
      └─ /commit-and-pr
```

---

## Key Differences from /godmode

| | `/godmode` | `/bugfix` |
|---|---|---|
| **Starting point** | Exploration + planning | Investigation of bug |
| **Planning phase** | Full PRD generation | None (investigate instead) |
| **Review depth** | Full smart selection | Lite review (--lite) |
| **Compound** | Optional | Strongly recommended |
| **Typical duration** | Hours to days | Minutes to hours |

---

## Skills Referenced

- `skills/compound/SKILL.md` — Capture bug learnings
- `skills/fresh-eyes-review/SKILL.md` — Lite review mode
- `skills/todos/SKILL.md` — Todo tracking

---

## Notes

- **Investigation first**: Unlike `/quickfix`, this command always investigates before fixing
- **Past learnings**: Automatically searches `docs/solutions/` during investigation
- **Lite review by default**: Bug fixes use `--lite` review (Security + Edge Case + Supervisor)
- **Compound encouraged**: Bug fixes are prime learning opportunities — always suggest `/compound`
- **Regression test**: Generate a test that specifically covers the bug scenario
