---
name: document-review
description: "Document quality review for plans, brainstorms, and markdown documents -- assesses clarity, completeness, specificity, and YAGNI compliance"
---

# Document Review

Reviews documents (plans, brainstorms, ADRs) for quality across four dimensions: clarity, completeness, specificity, and YAGNI compliance. Complements `/fresh-eyes-review` which is code-only.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory interaction gates. You MUST hit them. NEVER skip them. NEVER replace them with internal reasoning.**

| Gate | Location | Options | What Happens If Skipped |
|------|----------|---------|------------------------|
| **Substantive Changes** | Step 5: Apply Changes | Apply suggested changes / Skip changes / Let me choose | User loses control over document modifications -- UNACCEPTABLE |
| **Next Action** | Step 6: Offer Next Action | Refine again / Review complete | User loses control of iteration -- UNACCEPTABLE |

---

## When to Apply

- After generating a plan to check quality before formal review
- After a brainstorm session to assess output quality
- When revisiting an older plan or document before acting on it
- When a document feels unclear, bloated, or indecisive
- As a lightweight alternative to a full multi-agent review process

---

## Process

### Step 1: Get Document

**If path provided:**
- Read the specified document file

**If no path provided, auto-detect the most recent document:**

1. Search for recent plans: look for `docs/plans/*.md` files, pick the most recently modified
2. Search for recent brainstorms: look for `docs/brainstorms/*.md` files, pick the most recently modified
3. If both found, present both and ask user to choose
4. If neither found, ask user to provide a file path

**Read the full document content** before proceeding.

### Step 2: Assess

Read through the document and ask these reflective questions about it:

1. **What is unclear?** -- Identify vague language, ambiguous terms, missing definitions, or sections that could be interpreted multiple ways.
2. **What is unnecessary?** -- Flag sections that add bulk without value: over-specification, premature detail, redundant content, scope creep.
3. **What decision is being avoided?** -- Surface places where the document hedges, defers, or lists options without choosing. Plans that avoid decisions become implementation bottlenecks.
4. **What assumption is untested?** -- Identify claims presented as fact without evidence: "this will scale," "users want X," "the API supports Y." Each untested assumption is a risk.

Present findings organized by these four questions. Include specific quotes from the document with line references where possible.

### Step 3: Score

Rate the document on 4 dimensions (1-5 each):

| Dimension | 1 (Poor) | 3 (Adequate) | 5 (Excellent) |
|-----------|----------|---------------|----------------|
| **Clarity** | Vague, ambiguous, jargon-heavy | Mostly clear, minor ambiguities | Precise, unambiguous, well-defined terms |
| **Completeness** | Major gaps, missing sections | Covers main points, some gaps | All necessary information present, no obvious gaps |
| **Specificity** | Abstract hand-waving | Some concrete details | Actionable, concrete, measurable criteria |
| **YAGNI Compliance** | Over-engineered, scope creep | Some unnecessary additions | Minimal -- every section earns its place |

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

### Step 5: Apply Changes -- MANDATORY GATE

Auto-fix formatting-only issues without asking:
- Heading level inconsistencies
- List style inconsistencies (mixed bullet types)
- Trailing whitespace and blank line consistency
- Markdown syntax errors (unclosed links, missing blank lines before lists)

All other changes -- including typo corrections that could alter meaning, pronoun resolution, and clarity improvements -- require user approval via the gate below.

For substantive changes (structural reorganization, adding/removing sections, changing meaning), present them and ask:

> I identified {N} substantive improvements beyond minor fixes. How should I proceed?
>
> 1. **Apply suggested changes** -- Apply all {N} substantive improvements to the document
> 2. **Skip changes** -- Keep the document as-is, I will handle changes myself
> 3. **Let me choose** -- Show me each change so I can approve individually

**WAIT** for user response before continuing.

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

### Step 6: Offer Next Action -- MANDATORY GATE

Present the following options:

> Document review complete. What would you like to do next?
>
> 1. **Refine again** -- Run another assessment pass on the updated document
> 2. **Review complete** -- Done, proceed to next workflow step

**WAIT** for user response before continuing.

**If "Refine again":**
- Return to Step 2 with the updated document
- Each pass is independent -- re-assess from scratch

**If "Review complete":**
- Summarize final scores and any changes applied
- Proceed to next workflow step

---

## Notes

- **Documents, not code:** This skill reviews plans, brainstorms, ADRs, and other markdown documents. For code review, use `/fresh-eyes-review`.
- **Lightweight:** Single-pass skill -- no multi-reviewer orchestration needed. Fast feedback loop.
- **Iterative:** "Refine again" allows multiple passes until the document meets quality standards.
- **Opinionated scoring:** The 4-dimension rubric intentionally penalizes over-engineering (YAGNI) and vagueness (Specificity). Documents that hedge or over-scope will score low.
- **Minor fixes are automatic:** Typos, formatting, and obvious clarity fixes are applied without asking. Only substantive changes require approval.

---

## Integration Points

- **Input**: Document file path, or auto-detected most recent plan/brainstorm
- **Output**: Quality scorecard (4 dimensions, 1-5 each), critical improvement, applied fixes
- **Consumed by**: Plan workflow (post-generation quality check), explore workflow (brainstorm quality check)
- **Complements**: `/fresh-eyes-review` (code-only review)
