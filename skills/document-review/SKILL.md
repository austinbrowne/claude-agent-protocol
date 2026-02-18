---
name: document-review
version: "1.0"
description: Document quality review for plans, brainstorms, and other markdown documents — assesses clarity, completeness, specificity, and YAGNI compliance
referenced_by:
  - commands/plan.md
  - skills/explore/SKILL.md
---

# Document Review Skill

Reviews documents (plans, brainstorms, ADRs) for quality across four dimensions: clarity, completeness, specificity, and YAGNI compliance. Complements `fresh-eyes-review` which is code-only.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory AskUserQuestion gates. You MUST hit them. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Substantive Changes** | Step 5: Apply Changes | Apply suggested changes / Skip changes / Let me choose | User loses control over document modifications — UNACCEPTABLE |
| **Next Action** | Step 6: Offer Next Action | Refine again / Review complete | User loses control of iteration — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- After generating a plan (via `generate-plan`) to check quality before review-plan
- After a brainstorm session to assess output quality
- When revisiting an older plan or document before acting on it
- When a document feels unclear, bloated, or indecisive
- As a lightweight alternative to the full multi-agent `review-plan` process

---

## Process

### Step 1: Get Document

**If path provided:**
- Read the specified document file

**If no path provided, auto-detect the most recent document:**

1. Search for recent plans:
   ```
   Glob pattern="docs/plans/*.md" — sort by modification time, pick most recent
   ```
2. Search for recent brainstorms:
   ```
   Glob pattern="docs/brainstorms/*.md" — sort by modification time, pick most recent
   ```
3. If both found, present both and ask user to choose
4. If neither found, ask user to provide a file path

**Read the full document content** before proceeding.

### Step 2: Assess

Read through the document and ask these reflective questions about it:

1. **What is unclear?** — Identify vague language, ambiguous terms, missing definitions, or sections that could be interpreted multiple ways.
2. **What is unnecessary?** — Flag sections that add bulk without value: over-specification, premature detail, redundant content, scope creep.
3. **What decision is being avoided?** — Surface places where the document hedges, defers, or lists options without choosing. Plans that avoid decisions become implementation bottlenecks.
4. **What assumption is untested?** — Identify claims presented as fact without evidence: "this will scale," "users want X," "the API supports Y." Each untested assumption is a risk.

Present findings organized by these four questions. Include specific quotes from the document with line references where possible.

### Step 3: Score

Rate the document on 4 dimensions (1-5 each):

| Dimension | 1 (Poor) | 3 (Adequate) | 5 (Excellent) |
|-----------|----------|---------------|----------------|
| **Clarity** | Vague, ambiguous, jargon-heavy | Mostly clear, minor ambiguities | Precise, unambiguous, well-defined terms |
| **Completeness** | Major gaps, missing sections | Covers main points, some gaps | All necessary information present, no obvious gaps |
| **Specificity** | Abstract hand-waving | Some concrete details | Actionable, concrete, measurable criteria |
| **YAGNI Compliance** | Over-engineered, scope creep | Some unnecessary additions | Minimal — every section earns its place |

Present scores in a table:

```
=== DOCUMENT QUALITY SCORECARD ===

Document: [filename]
Date: YYYY-MM-DD

| Dimension        | Score | Assessment                          |
|------------------|-------|-------------------------------------|
| Clarity          | X/5   | [one-line explanation]               |
| Completeness     | X/5   | [one-line explanation]               |
| Specificity      | X/5   | [one-line explanation]               |
| YAGNI Compliance | X/5   | [one-line explanation]               |
|                  |       |                                     |
| **Overall**      | X/20  | [one-line overall assessment]        |
```

### Step 4: Identify Critical Improvement

Determine the **single most impactful change** that would improve this document. This should be the one thing that, if fixed, would raise the overall quality the most.

Present it clearly:

```
=== CRITICAL IMPROVEMENT ===

[One sentence describing the change]

Why: [Why this is the highest-leverage fix]
Where: [Specific section(s) affected]
How: [Concrete suggestion for what to change]
```

### Step 5: Apply Changes — MANDATORY GATE

Auto-fix formatting-only issues without asking:
- Heading level inconsistencies
- List style inconsistencies (mixed bullet types)
- Trailing whitespace and blank line consistency
- Markdown syntax errors (unclosed links, missing blank lines before lists)

All other changes — including typo corrections that could alter meaning, pronoun resolution, and clarity improvements — require user approval via the gate below.

For substantive changes (structural reorganization, adding/removing sections, changing meaning), present them and ask:

**STOP. You MUST use AskUserQuestion here. Do NOT ask in plain text. Do NOT skip this step.**

```
AskUserQuestion:
  question: "I identified {N} substantive improvements beyond minor fixes. How should I proceed?"
  header: "Apply document changes"
  options:
    - label: "Apply suggested changes"
      description: "Apply all {N} substantive improvements to the document"
    - label: "Skip changes"
      description: "Keep the document as-is — I'll handle changes myself"
    - label: "Let me choose"
      description: "Show me each change so I can approve individually"
```

**If "Apply suggested changes":**
1. Apply all substantive changes to the document
2. Present a summary of what changed
3. Proceed to Step 6

**If "Skip changes":**
1. Note that minor fixes (formatting, typos) were still applied
2. Proceed to Step 6

**If "Let me choose":**
1. Present each substantive change individually with before/after
2. Ask user to approve or reject each one
3. Apply approved changes
4. Proceed to Step 6

### Step 6: Offer Next Action — MANDATORY GATE

**STOP. You MUST use AskUserQuestion here. Do NOT ask in plain text. Do NOT skip this step.**

```
AskUserQuestion:
  question: "Document review complete. What would you like to do next?"
  header: "Next action"
  options:
    - label: "Refine again"
      description: "Run another assessment pass on the updated document"
    - label: "Review complete"
      description: "Done — proceed to next workflow step"
```

**If "Refine again":**
- Return to Step 2 with the updated document
- Each pass is independent — re-assess from scratch

**If "Review complete":**
- Summarize final scores and any changes applied
- Proceed to next workflow step

---

## Notes

- **Documents, not code:** This skill reviews plans, brainstorms, ADRs, and other markdown documents. For code review, use `fresh-eyes-review`.
- **Lightweight:** Single-agent skill — no multi-agent orchestration needed. Fast feedback loop.
- **Iterative:** "Refine again" allows multiple passes until the document meets quality standards.
- **Opinionated scoring:** The 4-dimension rubric intentionally penalizes over-engineering (YAGNI) and vagueness (Specificity). Documents that hedge or over-scope will score low.
- **Minor fixes are automatic:** Typos, formatting, and obvious clarity fixes are applied without asking. Only substantive changes require approval.
- **Pairs with review-plan:** Use `document-review` for quick quality checks. Use `review-plan` for formal multi-agent adversarial validation before implementation.

---

## Integration Points

- **Input**: Document file path, or auto-detected most recent plan/brainstorm
- **Output**: Quality scorecard (4 dimensions, 1-5 each), critical improvement, applied fixes
- **Consumed by**: `/plan` workflow (post-generation quality check), `/explore` workflow (brainstorm quality check)
- **Complements**: `review-plan` (formal multi-agent review), `fresh-eyes-review` (code-only review)
