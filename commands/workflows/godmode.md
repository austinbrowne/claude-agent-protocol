---
description: Full feature development orchestrator — guides through complete planning, execution, and finalization workflow
---

# /godmode

**Description:** Full feature development orchestrator — drives the complete workflow from exploration to finalization

**When to use:**
- Starting a new feature from scratch
- Want guided, step-by-step workflow through all phases
- Complex features requiring planning → execution → finalization

**Prerequisites:** None (entry point command)

---

## Invocation

**Interactive mode:**
User types `/godmode` with no arguments. Claude asks for feature description.

**Direct mode:**
User types `/godmode [description]` where description is a natural-language feature description.

---

## Arguments

- `[description]` - Feature description in natural language
- No flags — the orchestrator adapts based on context

---

## Execution

### Smart Entry Point

Before starting Phase 0, check for existing context:

1. **PRD exists?** → Skip to Phase 1 (ask user to confirm)
2. **Issues exist?** → Skip to `/start-issue` (ask which issue)
3. **Nothing exists** → Start at Phase 0

```
AskUserQuestion:
  question: "Where should we start?"
  header: "Entry point"
  options:
    - label: "Phase 0: Planning"
      description: "Start from scratch — explore, brainstorm, plan"
    - label: "Phase 1: Execution"
      description: "PRD/issues exist — start implementing"
    - label: "Phase 2: Finalization"
      description: "Code done — refactor and finalize"
```

---

### Phase 0: Planning

**Step 0.1: Explore**
- Invoke `/explore` with the feature description
- Load skill: `skills/brainstorming/SKILL.md` for next step context
- After completion, `/explore` presents `AskUserQuestion` with options including `/brainstorm`

**Step 0.2: Brainstorm (optional)**
- If user selects brainstorm from `/explore`'s post-completion options
- Invoke `/brainstorm` with topic from description
- After completion, presents options including `/generate-prd`

**Step 0.3: Generate PRD**
- Invoke `/generate-prd` with feature description
- Incorporates brainstorm findings if available
- After completion, presents options including `/deepen-plan` or `/review-plan`

**Step 0.4: Deepen Plan (optional)**
- If user selects deepen from `/generate-prd`'s options
- Invoke `/deepen-plan` with PRD path
- After completion, presents options including `/review-plan`

**Step 0.5: Review Plan**
- Invoke `/review-plan` with PRD path
- Load skill: `skills/plan-review/SKILL.md`
- If REVISION_REQUESTED: guide user through fixes, re-run review
- If APPROVED: present option to create issues

**Step 0.6: Create Issues**
- Invoke `/create-issues` with PRD path
- After completion, presents option to start first issue

---

### Phase 1: Execution

**Step 1.1: Start Issue**
- Invoke `/start-issue` with issue number
- Past learnings surfaced, living plan created
- User implements the code

**Step 1.2: Generate Tests**
- After implementation, invoke `/generate-tests`
- After completion, presents option for validation

**Step 1.3: Run Validation**
- Invoke `/run-validation`
- If FAIL: fix and re-run
- If PASS: present option for fresh-eyes review

**Step 1.4: Fresh Eyes Review**
- Invoke `/fresh-eyes-review`
- Load skill: `skills/fresh-eyes-review/SKILL.md`
- If BLOCK/FIX_BEFORE_COMMIT: fix findings, re-run
- If APPROVED: present options for compound and commit

**Step 1.5: Compound (optional)**
- If user learned something worth capturing
- Invoke `/compound`
- Load skill: `skills/knowledge-compounding/SKILL.md`

**Step 1.6: Commit and PR**
- Invoke `/commit-and-pr`
- After completion, presents options for refactor or finalize

---

### Phase 2: Finalization

**Step 2.1: Refactor (optional)**
- Invoke `/refactor`
- After completion, presents option for finalize

**Step 2.2: Finalize**
- Invoke `/finalize`
- Workflow complete

---

## Flow Diagram

```
/godmode [description]
  ├─ Phase 0: Planning
  │   ├─ /explore → AskUserQuestion: [brainstorm / generate-prd / done]
  │   ├─ /brainstorm → AskUserQuestion: [generate-prd / done]
  │   ├─ /generate-prd → AskUserQuestion: [deepen-plan / review-plan / create-issues / done]
  │   ├─ /deepen-plan → AskUserQuestion: [review-plan / create-issues / done]
  │   └─ /review-plan → AskUserQuestion: [create-issues / revise-and-re-review / done]
  ├─ Phase 1: Execution
  │   ├─ /create-issues → AskUserQuestion: [start-issue / done]
  │   ├─ /start-issue → [implement] → AskUserQuestion: [generate-tests / fresh-eyes-review / done]
  │   ├─ /generate-tests → AskUserQuestion: [run-validation / fresh-eyes-review / done]
  │   ├─ /run-validation → AskUserQuestion: [fresh-eyes-review / fix-issues / done]
  │   ├─ /fresh-eyes-review → AskUserQuestion: [fix-findings / compound / commit-and-pr / done]
  │   ├─ /compound → AskUserQuestion: [commit-and-pr / done]
  │   └─ /commit-and-pr → AskUserQuestion: [refactor / finalize / done]
  └─ Phase 2: Finalization
      ├─ /refactor → AskUserQuestion: [finalize / done]
      └─ /finalize → Done
```

---

## Skills Referenced

- `skills/brainstorming/SKILL.md` — Brainstorming methodology
- `skills/knowledge-compounding/SKILL.md` — Knowledge capture
- `skills/fresh-eyes-review/SKILL.md` — Smart selection review
- `skills/plan-review/SKILL.md` — Multi-agent plan review
- `skills/security-review/SKILL.md` — OWASP security review
- `skills/file-todos/SKILL.md` — Todo tracking

---

## Notes

- **Adaptive flow**: Each step uses `AskUserQuestion` — user can skip, reorder, or exit at any point
- **Not rigid**: The orchestrator suggests the next logical step but doesn't force it
- **Context-aware**: Skips phases that are already done (existing PRD, existing issues)
- **Human in loop**: Every phase transition requires user confirmation
- **Exit anytime**: "Done" is always an option — user can leave and resume later
