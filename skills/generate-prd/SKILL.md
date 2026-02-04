---
name: generate-prd
version: "1.0"
description: PRD generation methodology with parallel research and spec-flow analysis
referenced_by:
  - commands/plan.md
---

# PRD Generation Skill

Methodology for creating Product Requirements Documents with parallel research, brainstorm integration, and spec-flow analysis.

---

## When to Apply

- After exploring codebase and ready to formalize requirements
- Have clear feature description and want structured planning
- Need to document requirements before implementation

---

## Process

### 1. Parallel Local Research

**Before generating PRD content, launch 2 research agents in parallel (single message with multiple Task calls):**

**Agent 1: Learnings Researcher**
- Search `docs/solutions/` for relevant past solutions matching feature keywords
- Use multi-pass Grep: tags → category → content matching
- Reference: `agents/research/learnings-researcher.md`

**Agent 2: Codebase Pattern Researcher**
- Search codebase for existing patterns related to the feature
- Find similar implementations and identify conventions to follow
- Reference: `agents/research/codebase-researcher.md`

**Incorporate findings into:**
- Technical Approach section (use patterns found in codebase)
- Risks section (apply gotchas from past solutions)
- Test Strategy (past testing approaches for similar features)

### 2. Determine PRD Type (Lite or Full)

**Auto-detection criteria:**
- Lite PRD: Small bug fixes, minor features, simple refactoring, single-file changes
- Full PRD: New major features, multi-component changes, architectural changes, security-sensitive features, breaking changes

### 3. Check for Recent Brainstorms

**Search for relevant brainstorm documents:**
```
Glob: docs/brainstorms/*.md
```

**Filter for:** YAML frontmatter `status: decided`, matching tags, date within 14 days.

**If found:** Incorporate chosen approach into Technical Approach section. Rejected alternatives become "Alternatives Considered" section.

### 4. Generate PRD Using Appropriate Template

**Load template:** `PRD_TEMPLATE.md`

**For Lite PRD:** Problem, Solution, Success Metric, Acceptance Criteria, Test Strategy, Security Review, Past Learnings Applied, Risks.

**For Full PRD:** Complete all sections from template (Document Info through Rollback Plan). Auto-populate exploration data if available. Include past learnings in Technical Approach and Risks.

**Auto-detect security sensitivity:** Check if feature involves authentication/authorization, PII/sensitive data, external APIs, user input processing, file uploads, database queries with user input. If yes: Flag as `SECURITY_SENSITIVE`.

### 5. Spec-Flow Analysis

After generating initial PRD content:

1. **Enumerate all user flows** from the Solution section (primary, alternative, error flows)
2. **For each flow, check for:** happy path, error states, empty states, edge states, permission states, loading/transition states
3. **Generate flow map** with success/error/empty paths per step
4. **Identify gaps** — missing handling, undefined states
5. **Offer to add gaps to Acceptance Criteria**
6. **Add Spec-Flow Analysis section to PRD output**

### 6. Save PRD

**Filename format:** `docs/prds/YYYY-MM-DD-feature-name.md`
**Status:** `READY_FOR_REVIEW`

---

## Integration Points

- **Input from**: `/explore` output, brainstorm decisions, user description
- **Output**: PRD file in `docs/prds/`
- **Template**: `PRD_TEMPLATE.md`
- **Research agents**: `agents/research/learnings-researcher.md`, `agents/research/codebase-researcher.md`
- **Spec-flow reviewer**: `agents/review/spec-flow-reviewer.md`
- **Consumed by**: `/plan` workflow command
