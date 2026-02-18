---
name: generate-plan
description: "Plan generation with integrated research, 3-tier complexity, and spec-flow analysis"
---

# Plan Generation Skill

Methodology for creating plans with integrated research, brainstorm integration, and spec-flow analysis. Self-sufficient -- runs its own research without requiring a prior `/explore` step.

---

## Mandatory Interaction Gates

**This skill has TWO mandatory interaction gates. You MUST hit both. NEVER skip them.**

| Gate | Step | Interaction | What Happens If Skipped |
|------|------|-------------|------------------------|
| **Plan Acceptance** | Step 6 | Accept / Request Changes / Reject | Plan gets saved without user approval -- UNACCEPTABLE |
| **Next Steps** | After save | Deepen / Review / Create Issues / Implement | User loses control of workflow -- UNACCEPTABLE |

---

## When to Apply

- Ready to formalize requirements for a feature, fix, or change
- Have clear description and want structured planning
- Need to document requirements before implementation
- Can be used directly without running `/explore` first

---

## Process

### 1. Research (Sequential, Self-Sufficient)

Perform the following research steps sequentially. This skill runs its own research -- no prior `/explore` required.

**Smart research decision (for steps 3 & 4):**
- High-risk topics (security, payments, external APIs) -> always research
- Strong local context (good patterns, project docs have guidance) -> skip external
- Uncertainty or unfamiliar territory -> research

#### Research Step 1: Codebase Research (Always)

Explore the target area in the codebase. Identify:
1. Key files and their purposes
2. Architecture patterns used
3. Important functions/classes
4. Dependencies and relationships
5. Potential areas of concern

Provide a structured summary suitable for planning new work.

**Thoroughness level:**
- Simple queries (single file/class): quick scan
- Feature areas: medium depth
- Full codebase: very thorough

#### Research Step 2: Learnings Research (Always, if `docs/solutions/` has files)

Search `docs/solutions/` for past solutions relevant to the target area.
Use multi-pass search strategy: tags -> category -> keywords -> full-text.
Record relevant findings with applicability assessment.

#### Research Step 3: Best Practices Research (Conditional)

**Condition:** Unfamiliar technology, external APIs, or user explicitly asks.

Search the web for current best practices, common mistakes to avoid, and industry recommendations.

#### Research Step 4: Framework Docs Research (Conditional)

**Condition:** Known framework detected in package.json/Gemfile/requirements.txt/go.mod/Cargo.toml.

Look up framework-specific conventions, version-specific notes, and relevant API documentation.

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

**Search for relevant brainstorm documents:** look for files matching `docs/brainstorms/*.md`.

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
4. **Identify gaps** -- missing handling, undefined states
5. **Offer to add gaps to Acceptance Criteria**
6. **Add Spec-Flow Analysis section to plan output** (Comprehensive tier includes this in template; Standard tier appends if significant flows exist)

### 6. Present Plan for Acceptance -- MANDATORY GATE

**STOP. Do NOT save the plan yet. Do NOT proceed to Step 7. You MUST present the plan and get explicit acceptance FIRST.**

After generating the plan content, present it to the user and ask for explicit acceptance:

> **Plan review**
>
> Here's the generated plan. Do you accept it?
>
> 1. **Accept plan** -- Plan looks good -- save it and continue
> 2. **Request changes** -- I have specific changes I'd like to make
> 3. **Reject and start over** -- This approach isn't right -- let me explain why

**WAIT** for user response before continuing.

**If "Accept plan":** Proceed to Step 7 (Save Plan).

**If "Request changes":**
1. **STOP and ask explicitly:** "What specific changes would you like me to make to this plan?"
2. **WAIT** for user response -- do NOT infer, assume, or take action until the user provides specific feedback.
3. Make ONLY the changes the user explicitly requested
4. Present the updated plan again for acceptance (return to Step 6)

**If "Reject and start over":**
1. **STOP and ask explicitly:** "What's wrong with this approach? Please explain so I understand."
2. **WAIT** for user response -- do NOT assume the problem or start over without understanding.
3. Based on their explanation, offer options:
   - Return to brainstorming (`/brainstorm`) if the approach itself is wrong
   - Re-run plan generation with different constraints if requirements were misunderstood
   - End workflow if user wants to think more

**CRITICAL:** Never make autonomous changes based on vague feedback like "do more research" or "make it better". Always ask for specifics first.

**CRITICAL:** Do NOT proceed to Step 7 until the user selects "Accept plan". No exceptions.

### 7. Save Plan

**Filename format:** `docs/plans/YYYY-MM-DD-type-name-plan.md`
- Replace `type` with: `minimal`, `standard`, or `comprehensive`
- Replace `name` with: lowercase-hyphenated feature name

**Examples:**
- `docs/plans/2026-02-04-minimal-fix-login-bug-plan.md`
- `docs/plans/2026-02-04-standard-user-auth-plan.md`
- `docs/plans/2026-02-04-comprehensive-api-redesign-plan.md`

**Status:** `READY_FOR_REVIEW`

**Plan status lifecycle:** After saving the plan file, ensure its YAML frontmatter contains `status: ready_for_review`. If the frontmatter does not already have a `status` field, add one. This status is used by downstream skills (review-plan, start-issue, team-implement) to track plan progression through the lifecycle: `ready_for_review` -> `approved` -> `in_progress` -> `complete`.

---

## Integration Points

- **Input from**: `/explore` output (optional), brainstorm decisions, user description
- **Output**: Plan file in `docs/plans/`
- **Template**: `PLAN_TEMPLATE.md`
- **Consumed by**: `/deepen-plan`, `/review-plan`, `/create-issues`
