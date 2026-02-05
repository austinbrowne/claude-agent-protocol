---
name: generate-plan
version: "2.0"
description: Plan generation methodology with integrated research, 3-tier complexity, and spec-flow analysis
referenced_by:
  - commands/plan.md
---

# Plan Generation Skill

Methodology for creating plans with integrated multi-agent research, brainstorm integration, and spec-flow analysis. Self-sufficient — runs its own research without requiring a prior `/explore` step.

---

## When to Apply

- Ready to formalize requirements for a feature, fix, or change
- Have clear description and want structured planning
- Need to document requirements before implementation
- Can be used directly without running `/explore` first

---

## Process

### 1. Parallel Research (Self-Sufficient)

**CRITICAL:** Launch all applicable research agents simultaneously via Task tool in a single message. This skill runs its own research — no prior `/explore` required.

**Smart research decision (for agents 3 & 4):**
- High-risk topics (security, payments, external APIs) → always research
- Strong local context (good patterns, CLAUDE.md has guidance) → skip external
- Uncertainty or unfamiliar territory → research

| # | Agent | Condition | Task Tool Config |
|---|-------|-----------|-----------------|
| 1 | **Codebase Research Agent** | Always runs | `subagent_type: "Explore"`, reads `agents/research/codebase-researcher.md` for process |
| 2 | **Learnings Research Agent** | Always runs (if `docs/solutions/` has files) | `subagent_type: "general-purpose"`, searches `docs/solutions/` per `agents/research/learnings-researcher.md` |
| 3 | **Best Practices Research Agent** | Conditional: unfamiliar technology, external APIs, or user explicitly asks | `subagent_type: "general-purpose"`, web search per `agents/research/best-practices-researcher.md` |
| 4 | **Framework Docs Research Agent** | Conditional: known framework detected in package.json/Gemfile/requirements.txt/go.mod/Cargo.toml | `subagent_type: "general-purpose"`, queries Context7 MCP per `agents/research/framework-docs-researcher.md` |

**Codebase Research Agent prompt:**
```
Explore the [target] in this codebase. Identify:
1. Key files and their purposes
2. Architecture patterns used
3. Important functions/classes
4. Dependencies and relationships
5. Potential areas of concern

Provide a structured summary suitable for planning new work.
```

**Learnings Research Agent prompt:**
```
Search docs/solutions/ for past solutions relevant to [target].
Use multi-pass Grep strategy: tags → category → keywords → full-text.
Return relevant findings with applicability assessment.
```

**Thoroughness level for Codebase Research Agent:**
- Simple queries (single file/class): "quick"
- Feature areas: "medium"
- Full codebase: "very thorough"

**Incorporate findings into:**
- Technical Approach section (use patterns found in codebase)
- Risks section (apply gotchas from past solutions)
- Test Strategy (past testing approaches for similar features)

### 2. Determine Plan Tier (Minimal, Standard, or Comprehensive)

**Auto-detection criteria:**

| Tier | Indicators |
|------|------------|
| **Minimal** | Small bug fixes, minor features, simple refactoring, single-file changes, clear cause |
| **Standard** | Multi-file features, moderate complexity, some unknowns, new functionality |
| **Comprehensive** | Architectural changes, multi-component changes, security-sensitive features, breaking changes, high-risk |

### 3. Check for Recent Brainstorms

**Search for relevant brainstorm documents:**
```
Glob: docs/brainstorms/*.md
```

**Filter for:** YAML frontmatter `status: decided`, matching tags, date within 14 days.

**If found:** Incorporate chosen approach into Technical Approach section. Rejected alternatives become "Alternatives Considered" section (Standard/Comprehensive tiers).

### 4. Generate Plan Using Appropriate Template

**Load template:** `PLAN_TEMPLATE.md`

**For Minimal plan:** Problem, Solution, Affected Files, Acceptance Criteria, Test Strategy, Risks.

**For Standard plan:** Problem, Goals, Solution, Technical Approach, Implementation Steps, Affected Files, Acceptance Criteria, Test Strategy, Security Review, Past Learnings Applied, Risks.

**For Comprehensive plan:** Complete all sections from template (Document Info through Rollback Plan). Auto-populate research data. Include past learnings in Technical Approach and Risks. Include Spec-Flow Analysis and Alternatives Considered.

**Auto-detect security sensitivity:** Check if feature involves authentication/authorization, PII/sensitive data, external APIs, user input processing, file uploads, database queries with user input. If yes: Flag as `SECURITY_SENSITIVE`.

### 5. Spec-Flow Analysis (Standard and Comprehensive)

After generating initial plan content:

1. **Enumerate all user flows** from the Solution section (primary, alternative, error flows)
2. **For each flow, check for:** happy path, error states, empty states, edge states, permission states, loading/transition states
3. **Generate flow map** with success/error/empty paths per step
4. **Identify gaps** — missing handling, undefined states
5. **Offer to add gaps to Acceptance Criteria**
6. **Add Spec-Flow Analysis section to plan output** (Comprehensive tier includes this in template; Standard tier appends if significant flows exist)

### 6. Save Plan

**Filename format:** `docs/plans/YYYY-MM-DD-type-name-plan.md`
- Replace `type` with: `minimal`, `standard`, or `comprehensive`
- Replace `name` with: lowercase-hyphenated feature name

**Examples:**
- `docs/plans/2026-02-04-minimal-fix-login-bug-plan.md`
- `docs/plans/2026-02-04-standard-user-auth-plan.md`
- `docs/plans/2026-02-04-comprehensive-api-redesign-plan.md`

**Status:** `READY_FOR_REVIEW`

---

## Integration Points

- **Input from**: `/explore` output (optional), brainstorm decisions, user description
- **Output**: Plan file in `docs/plans/`
- **Template**: `PLAN_TEMPLATE.md`
- **Research agents**: `agents/research/learnings-researcher.md`, `agents/research/codebase-researcher.md`, `agents/research/best-practices-researcher.md`, `agents/research/framework-docs-researcher.md`
- **Spec-flow reviewer**: `agents/review/spec-flow-reviewer.md`
- **Consumed by**: `/plan` workflow command
