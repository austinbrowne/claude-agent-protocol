---
type: standard
title: "Product Owner Agent — Roadmap & Backlog Skills"
date: 2026-02-25
status: complete
security_sensitive: false
issue: 46
risk_flags: []
confidence: HIGH_CONFIDENCE
---

# Plan: Product Owner Agent — Roadmap & Backlog Skills

## Problem

Issue #46 proposes a Product Owner Agent with roadmap and backlog generation capabilities. The proposed files are AI-generated drafts that don't follow project conventions (missing YAML frontmatter, missing mandatory interaction gates, wrong section structure). The feature itself fills a real gap — the protocol handles *how* to build things but has no support for *what* to build from a product perspective.

## Goals

1. Introduce a Product Owner agent definition following project conventions
2. Add `/roadmap` and `/backlog` skills wired into the `/plan` workflow
3. Create a roadmap template following the existing 3-tier pattern
4. Update all documentation counts and references for consistency

## Solution

Add 4 new files (1 agent, 2 skills, 1 template) and 2 new directories (`docs/roadmaps/`, `docs/backlogs/`), rewritten from the issue's drafts to match project conventions. Wire both skills into `commands/plan.md` as new planning options via a "Product planning" parent option. Update counts across all documentation files.

### Design Decisions (Per User Input)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Workflow placement | Under `/plan` | Roadmap/backlog are planning activities, generated after a plan exists |
| Agent model | `sonnet` | Strategic content generation — needs good writing but not opus-level reasoning |
| Skill category | Planning skills | Aligns with existing grouping in WORKFLOW_REFERENCE |
| Roadmap output | `docs/roadmaps/` | **[DEEPENED]** Changed from `docs/plans/` — roadmaps in `docs/plans/` would collide with plan state detection in `commands/plan.md` Step 0, which globs `docs/plans/*.md` and filters by YAML `status` field. Roadmap files lack plan-compatible status values, causing incorrect "active plans exist" detection. Separate directory avoids the collision entirely. (EC-004, PERF-002) |
| Backlog output | `docs/backlogs/` | Own directory — backlogs are distinct deliverables that accumulate |
| Prioritization method | **[DEEPENED]** MoSCoW / qualitative tiers (High/Medium/Low) | Changed from RICE scoring — AI-generated RICE scores (Reach, Impact, Confidence, Effort) require quantitative data the agent cannot reliably source. Fabricated numbers create false precision that misleads stakeholders. Simple priority tiers communicate the same actionable signal without invented metrics. (ARCH-006, SIMP-005) |

## Technical Approach

### New Agent: `agents/product/PRODUCT_OWNER.md`

Rewrite the proposed agent to follow the review agent pattern (closest match for structured agent definitions):

```yaml
---
name: product-owner
model: sonnet
description: Product management agent for roadmap generation, backlog grooming, and user story decomposition with prioritization frameworks.
---
```

Sections to include:
- **Philosophy** — Outcome-driven product thinking
- **When to Invoke** — Called by `/roadmap` and `/backlog` skills (not a review agent — not triggered by file patterns)
- **Capabilities** — Roadmap generation, epic decomposition, user story writing, MoSCoW prioritization
- **Output Standards** — Now/Next/Later horizons, Given/When/Then acceptance criteria, Fibonacci story points
- **Persona Traits** — Retained from the proposal (outcome-driven, data-informed, collaborative, concise)

**[DEEPENED] Agent invocation pattern:** Skills invoke the Product Owner agent via Task tool with `subagent_type: "general-purpose"` and `model: "sonnet"`. The model is specified in the Task call (not inherited from the agent YAML), consistent with how existing research agents are invoked (e.g., learnings-researcher uses `model: "haiku"` in Task calls). The agent YAML `model` field serves as documentation of the recommended tier, not a runtime config. (ARCH-001 — verified against existing patterns: all research agents hardcode model in Task calls)

**[DEEPENED] Roadmap-to-backlog contract:** The Product Owner agent produces roadmap output following the ROADMAP_TEMPLATE structure. The backlog skill depends on this structure. The contract is: backlog expects roadmap content with `## Now`, `## Next`, `## Later` horizon sections, each containing epic-level entries with `**Problem:**` and `**Priority:**` fields. If these headings are missing, the backlog skill should surface a warning and ask the user to provide structured input instead. (ARCH-002)

### New Skill: `skills/roadmap/SKILL.md`

Rewrite with full convention compliance:

```yaml
---
name: roadmap
version: "1.0"
description: Generate structured product roadmaps from vision and goals
referenced_by:
  - commands/plan.md
---
```

**Process:**
1. **Gather Context** — AskUserQuestion for product name, vision, personas, time horizon, constraints
   - **[DEEPENED] Input validation:** Vision must be non-empty (minimum 10 characters). Time horizon must be a recognizable duration (e.g., "3 months", "1 year"). Product name is sanitized for filename use: strip all characters outside `[a-zA-Z0-9-_]`, replace spaces with hyphens, truncate to 50 chars. (EC-005, EC-009, EC-016, FLOW-012)
2. **Run Product Owner Agent** — Via Task tool, reading `agents/product/PRODUCT_OWNER.md` for persona instructions. Agent generates strategic themes, horizon mapping, epics, priorities, and risks
3. **[DEEPENED] Validate Agent Output** — Before presenting to user, verify output contains expected structural markers: at least one `##` heading, presence of horizon sections (Now/Next/Later or quarterly). If validation fails, surface a warning: "Agent output appears incomplete. Regenerate or proceed with caution?" (ARCH-003, EC-006, FLOW-009)
4. **Present to User** — Display generated roadmap content inline
5. **Human Review Gate** — MANDATORY AskUserQuestion: Accept / Request Changes / Reject
   - **[DEEPENED] Request Changes flow:** Collect feedback via freetext prompt: "What specific changes would you like?" Re-invoke agent with original context + change notes. Re-present updated output. Cap at 3 revision rounds. After 3rd round, present: "Accept current version / Save draft for manual editing / Discard." (FLOW-001, FLOW-014, EC-012)
   - **[DEEPENED] Reject flow:** Discard generated content (do NOT save to disk). Return to `/plan` menu with status message: "Roadmap discarded. Returning to plan menu." (FLOW-002, EC-011)
6. **Save Roadmap** — Output to `docs/roadmaps/YYYY-MM-DD-roadmap-[sanitized-name].md` using the roadmap template
   - **[DEEPENED] Collision check:** Before saving, check if filename already exists. If so, append counter suffix (`-v2`, `-v3`). Never silently overwrite. (EC-013)
   - **[DEEPENED] Directory creation:** Create `docs/roadmaps/` if it does not exist. (EC-014)
   - **[DEEPENED] YAML frontmatter:** Include `type: roadmap`, `status: active`, `product: [name]`, `date: YYYY-MM-DD`. This distinguishes roadmaps from plans in any future cross-directory searches. (EC-004)
7. **Chain offer** — After save, hand control back to `commands/plan.md` Step 3

**Mandatory Interaction Gates:**

| Gate | Step | AskUserQuestion | What Happens If Skipped |
|------|------|-----------------|------------------------|
| **Context Gathering** | Step 1 | Vision, personas, horizon, constraints | Roadmap generated without user requirements — GARBAGE |
| **Roadmap Acceptance** | Step 5 | Accept / Request Changes / Reject | Roadmap saved without user approval — UNACCEPTABLE |
| **Next Steps** | Handled by `commands/plan.md` Step 3 | Backlog / Return to plan / Done | User loses control of workflow — UNACCEPTABLE |

### New Skill: `skills/backlog/SKILL.md`

```yaml
---
name: backlog
version: "1.0"
description: Decompose roadmaps into groomed backlogs with epics, user stories, and MoSCoW prioritization
referenced_by:
  - commands/plan.md
---
```

**Process:**
1. **Load Roadmap Context**
   - **[DEEPENED] Roadmap discovery with guards (4 agents flagged this):**
     - Glob `docs/roadmaps/*.md`
     - **If 0 matches:** STOP. Present AskUserQuestion: "No roadmap found. Would you like to: (a) Run /roadmap first, (b) Paste roadmap content manually, (c) Describe goals as roadmap proxy." If option (b) or (c), collect freetext and proceed. (EC-001, FLOW-003, PERF-004)
     - **If 1 match:** Load that file automatically.
     - **If 2-4 matches:** Present AskUserQuestion listing files by name and date, prompt user to select one. (EC-003, FLOW-008)
     - **If 5+ matches:** Show 3 most recent as options + "Enter filename manually." (EC-007)
   - **[DEEPENED] YAML validation:** Wrap frontmatter parse in error handling. If malformed, surface warning identifying the file and skip it. (EC-008)
   - **[DEEPENED] Contract validation:** Verify loaded roadmap contains expected structure (horizon headings, epic entries per roadmap-backlog contract). If missing, warn user. (ARCH-002)
2. **Run Product Owner Agent** — Same invocation pattern as roadmap skill. Agent generates epic cards, user stories (3-6 per epic) with Given/When/Then acceptance criteria, story point estimates, MoSCoW priority tiers
3. **[DEEPENED] Validate Agent Output** — Verify output contains epic-level headings and at least one user story block. Surface warning if incomplete. (ARCH-003, EC-006)
4. **Present to User** — Display generated backlog content inline
5. **Human Review Gate** — MANDATORY AskUserQuestion: Accept / Request Changes / Reject
   - **[DEEPENED]** Same Request Changes / Reject flows as roadmap skill (3-round cap, discard on reject). (FLOW-001, FLOW-002)
6. **Save Backlog** — Output to `docs/backlogs/YYYY-MM-DD-backlog-[sanitized-name].md`
   - **[DEEPENED]** Same collision check, directory creation, and filename sanitization as roadmap skill. (EC-009, EC-013, EC-014)
7. **Chain offer** — After save, hand control back to `commands/plan.md` Step 3

**Mandatory Interaction Gates:**

| Gate | Step | AskUserQuestion | What Happens If Skipped |
|------|------|-----------------|------------------------|
| **Roadmap Selection** | Step 1 | Select roadmap (if multiple) or provide input (if none) | Backlog generated from wrong/missing context — GARBAGE |
| **Backlog Acceptance** | Step 5 | Accept / Request Changes / Reject | Backlog saved without user approval — UNACCEPTABLE |
| **Next Steps** | Handled by `commands/plan.md` Step 3 | Create Issues / Return to plan / Done | User loses control of workflow — UNACCEPTABLE |

### New Template: `templates/ROADMAP_TEMPLATE.md`

**[DEEPENED]** 2-tier template (changed from 3-tier — Comprehensive tier was speculative with no demonstrated need; start minimal, add when requested). (SIMP-004)

| Tier | When to Use | Sections |
|------|-------------|----------|
| **Minimal** | Early-stage, short horizon, quick alignment | Vision, Now/Next/Later, Open Questions, Out of Scope |
| **Standard** | Growing product, 3-6 month horizon, team alignment | + Strategic Themes table, MoSCoW priorities, Success Metrics, Decisions Made |

**YAML frontmatter in generated roadmaps:**
```yaml
---
type: roadmap
title: "[Product Name] Roadmap"
date: YYYY-MM-DD
status: active | archived
product: "[product-name]"
tier: minimal | standard
---
```

### Wiring: `commands/plan.md` Modifications

**[DEEPENED] Full specification of menu integration (3 agents flagged sub-menu pattern):**

The AskUserQuestion tool limits options to 4. The "active plans" menu already uses all 4 slots. The solution is a "Product planning" parent option that replaces one existing slot and branches into a sub-question.

**"No active plans" menu (currently 2 options → 3 options):**
```
AskUserQuestion:
  question: "No active plans found. What would you like to do?"
  header: "Plan"
  options:
    - label: "Generate plan"
      description: "Create a plan (Minimal, Standard, or Comprehensive) with integrated research"
    - label: "Product planning"
      description: "Generate a product roadmap or decompose into a backlog"
    - label: "Create ADR"
      description: "Document an architecture decision record"
```

**"Active plans exist" menu (currently 4 options → stays 4 with restructure):**
```
AskUserQuestion:
  question: "Which planning step would you like to run?"
  header: "Plan"
  options:
    - label: "Generate plan"
      description: "Create a new plan (Minimal, Standard, or Comprehensive) with integrated research"
    - label: "Product planning"
      description: "Generate a product roadmap or decompose into a backlog"
    - label: "Work on existing plan"
      description: "Deepen, review, or create issues from an existing plan"
    - label: "Create ADR"
      description: "Document an architecture decision record"
```

**Sub-menu when "Product planning" selected:**
```
AskUserQuestion:
  question: "Which product planning activity?"
  header: "Product"
  options:
    - label: "Generate roadmap"
      description: "Create a product roadmap from vision and goals"
    - label: "Generate backlog"
      description: "Decompose a roadmap into epics, user stories, and acceptance criteria"
```

**Sub-menu when "Work on existing plan" selected:**
```
AskUserQuestion:
  question: "What would you like to do with the existing plan?"
  header: "Plan"
  options:
    - label: "Deepen existing plan"
      description: "Enrich a plan with parallel research and review agents"
    - label: "Review plan"
      description: "Multi-agent plan review with adversarial validation"
    - label: "Create GitHub issues"
      description: "Generate GitHub issues from an approved plan"
```

**[DEEPENED] Note on precedent:** This two-level menu pattern has no exact precedent at the command level. The closest analogue is `skills/setup/SKILL.md` which uses cascading AskUserQuestion gates within a skill. This is the first command-level sub-menu. Document this pattern for future commands approaching the 4-option limit. (Codebase research finding)

**Add corresponding dispatch in Step 2:**
```
- "Generate roadmap" → Invoke Skill(skill="godmode:roadmap")
- "Generate backlog" → Invoke Skill(skill="godmode:backlog")
- "Deepen existing plan" → Invoke Skill(skill="godmode:deepen-plan") with plan path
- "Review plan" → Invoke Skill(skill="godmode:review-plan") with plan path
- "Create GitHub issues" → Invoke Skill(skill="godmode:create-issues") with plan path
```

**[DEEPENED] Post-skill AskUserQuestion gates in Step 3 (previously unspecified):** (FLOW-005, FLOW-006)

**After "Generate roadmap":**
```
AskUserQuestion:
  question: "Roadmap generated. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Generate backlog"
      description: "Decompose this roadmap into epics and user stories"
    - label: "Return to plan menu"
      description: "Go back to planning options"
    - label: "Done"
      description: "End workflow"
```

**After "Generate backlog":**
```
AskUserQuestion:
  question: "Backlog generated. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Create GitHub issues"
      description: "Push backlog stories as GitHub issues"
    - label: "Return to plan menu"
      description: "Go back to planning options"
    - label: "Done"
      description: "End workflow"
```

**[DEEPENED] Backlog → create-issues compatibility:** The `create-issues` skill expects a plan file with `status: approved` and an Implementation Steps section. A backlog file has neither — it has epic cards and user stories. The chain to `create-issues` will need the backlog skill to either: (a) format stories as Implementation Steps compatible with create-issues' parser, or (b) bypass create-issues and use `gh issue create` directly within the backlog skill. **Recommendation: option (b)** — the backlog skill should handle issue creation itself via a dedicated step, since story-to-issue mapping is a different format than plan-task-to-issue mapping. This means the post-backlog chain option should say "Create GitHub issues from backlog" and invoke a backlog-specific issue creation step, not the generic create-issues skill. (Codebase research finding on create-issues interface)

## Implementation Steps

### Task 1: Create agent definition
- Create `agents/product/` directory
- Create `agents/product/PRODUCT_OWNER.md` with proper YAML frontmatter and convention-aligned sections
- Include Philosophy, When to Invoke, Capabilities, Output Standards, Persona Traits sections

### Task 2: Create roadmap skill
- Create `skills/roadmap/` directory
- Create `skills/roadmap/SKILL.md` with all 5 mandatory sections
- Include proper AskUserQuestion gate enforcement
- **[DEEPENED]** Include input validation (vision min length, product name sanitization, horizon format)
- **[DEEPENED]** Include agent output validation step before presenting to user
- **[DEEPENED]** Include Request Changes loop (3-round cap) and Reject flow (discard + return)
- **[DEEPENED]** Include filename collision check and directory creation

### Task 3: Create backlog skill
- Create `skills/backlog/` directory
- Create `skills/backlog/SKILL.md` with all 5 mandatory sections
- Include proper AskUserQuestion gate enforcement
- **[DEEPENED]** Include roadmap discovery guards (0/1/2-4/5+ match handling)
- **[DEEPENED]** Include roadmap contract validation before agent invocation
- **[DEEPENED]** Include agent output validation step
- **[DEEPENED]** Include Request Changes loop and Reject flow
- **[DEEPENED]** Include filename collision check and directory creation
- **[DEEPENED]** Include backlog-specific issue creation step (not generic create-issues)

### Task 4: Create roadmap template
- Create `templates/ROADMAP_TEMPLATE.md` with **[DEEPENED]** 2-tier structure (Minimal/Standard)
- Include YAML frontmatter schema with `type: roadmap` discriminator

### Task 5: Wire into /plan workflow
- Modify `commands/plan.md`:
  - **[DEEPENED]** Restructure Step 1 menus: "Product planning" parent option + "Work on existing plan" grouping (both menu variants, respecting 4-option cap)
  - Add sub-menu dispatch for "Product planning" → roadmap or backlog
  - Add sub-menu dispatch for "Work on existing plan" → deepen, review, or create issues
  - **[DEEPENED]** Add fully specified post-skill AskUserQuestion gates in Step 3 (after roadmap, after backlog)
  - Add to "Additional Skills Available" section
- Update `commands/plan.md` YAML description to mention roadmap and backlog

### Task 6: Create output directories
- Create `docs/roadmaps/` directory with a `.gitkeep`
- Create `docs/backlogs/` directory with a `.gitkeep`

### Task 7: Update documentation references
Update counts and references across all files. Changes needed:

**Skill count: 27 → 29** (adding roadmap + backlog)
Files to update:
- `guides/PROJECT_CONVENTIONS.md` (lines 8, 62) — "27 reusable" → "29 reusable"
- `guides/WORKFLOW_REFERENCE.md` — add roadmap, backlog to Planning skills list
- `QUICK_START.md` (line 229) — "26 reusable" → "29 reusable"
- `AI_CODING_AGENT_GODMODE.md` (lines 7, 27, 933) — "26 reusable" / "27 skill" → "29"
- `README.md` (lines 6, 221, 271, 338) — various "26"/"27" → "29"
- `.claude-plugin/plugin.json` — "27 skill packages" → "29 skill packages"
- `.claude-plugin/marketplace.json` — "27 skill packages" → "29 skill packages"

**Agent count: 23 → 24** (adding 1 product agent)
Files to update:
- `guides/PROJECT_CONVENTIONS.md` — add `agents/product/` row to directory table + reference table
- `AI_CODING_AGENT_GODMODE.md` — add product agent line to architecture section
- `README.md` — "23 specialized agents (16 review + 4 research + 3 team)" → "24 specialized agents (16 review + 4 research + 3 team + 1 product)"
- `.claude-plugin/plugin.json` — "23 agents" → "24 agents"
- `.claude-plugin/marketplace.json` — "23 agents" → "24 agents"

**Template count: 10 → 11** (adding ROADMAP_TEMPLATE)
Files to update:
- `QUICK_START.md` — "10 reusable templates" → "11 reusable templates"
- `guides/PROJECT_CONVENTIONS.md` — "10 reusable templates"
- `README.md` — template count in directory tree

**New directory references:**
- `guides/PROJECT_CONVENTIONS.md` — add `docs/roadmaps/`, `docs/backlogs/`, and `agents/product/` to directory table
- `README.md` — add to directory tree

**CLAUDE.md embedded WORKFLOW_REFERENCE:**
- Add `roadmap`, `backlog` to Planning skills list

## Affected Files

### New Files (6)
- `agents/product/PRODUCT_OWNER.md` — Product Owner agent definition
- `skills/roadmap/SKILL.md` — Roadmap generation skill
- `skills/backlog/SKILL.md` — Backlog generation skill
- `templates/ROADMAP_TEMPLATE.md` — 2-tier roadmap template
- `docs/roadmaps/.gitkeep` — Empty directory placeholder
- `docs/backlogs/.gitkeep` — Empty directory placeholder

### Modified Files (~13)
- `commands/plan.md` — Restructure menus with sub-menu pattern + dispatch + post-gates
- `guides/PROJECT_CONVENTIONS.md` — Counts, directory table, reference table
- `guides/WORKFLOW_REFERENCE.md` — Planning skills list
- `QUICK_START.md` — Skill count, template count, file reference table
- `AI_CODING_AGENT_GODMODE.md` — Skill count, agent architecture, appendix
- `README.md` — Summary, counts, directory tree, changelog
- `.claude-plugin/plugin.json` — Description string counts
- `.claude-plugin/marketplace.json` — Description string counts
- `CLAUDE.md` — Embedded WORKFLOW_REFERENCE planning skills list

## Acceptance Criteria

- [ ] `agents/product/PRODUCT_OWNER.md` exists with valid YAML frontmatter (`name`, `model: sonnet`, `description`)
- [ ] `skills/roadmap/SKILL.md` follows all 5 mandatory sections with proper AskUserQuestion gates
- [ ] `skills/backlog/SKILL.md` follows all 5 mandatory sections with proper AskUserQuestion gates
- [ ] `templates/ROADMAP_TEMPLATE.md` has 2-tier structure (Minimal/Standard)
- [ ] `commands/plan.md` has restructured menus with "Product planning" and "Work on existing plan" groupings
- [ ] `commands/plan.md` has sub-menu dispatch and post-skill gates for both new skills
- [ ] All skill counts updated to 29 across all documentation files
- [ ] All agent counts updated to 24 across all documentation files
- [ ] Template count updated to 11 across all documentation files
- [ ] `agents/product/` added to PROJECT_CONVENTIONS directory table
- [ ] `docs/roadmaps/` and `docs/backlogs/` directories exist
- [ ] `roadmap` and `backlog` listed as Planning skills in WORKFLOW_REFERENCE
- [ ] Grep for old counts returns 0 matches
- [ ] **[DEEPENED]** Roadmap skill validates input before agent invocation (non-empty vision, sanitized name)
- [ ] **[DEEPENED]** Backlog skill handles 0/1/multiple roadmap files with guards
- [ ] **[DEEPENED]** Both skills validate agent output structure before presenting to user
- [ ] **[DEEPENED]** Request Changes flow caps at 3 iterations with escape hatch
- [ ] **[DEEPENED]** Reject flow discards content and returns to /plan menu
- [ ] **[DEEPENED]** No AskUserQuestion gate exceeds 4 options
- [ ] **[DEEPENED]** Generated filenames sanitized (alphanumeric + hyphens only)

## Test Strategy

- [ ] Grep for "27 skill" / "26 skill" returns 0 matches (all updated to 29)
- [ ] Grep for "23 agent" / "23 specialized" returns 0 matches (all updated to 24)
- [ ] Grep for "10 template" / "10 reusable template" returns 0 matches (all updated to 11)
- [ ] `ls skills/ | wc -l` returns 29
- [ ] `ls agents/product/ | wc -l` returns 1
- [ ] `ls templates/ | wc -l` returns 11
- [ ] All new YAML frontmatter parses correctly
- [ ] No broken markdown links in modified files
- [ ] commands/plan.md AskUserQuestion blocks are valid (max 4 options per gate — check for overflow)
- [ ] **[DEEPENED]** Verify docs/roadmaps/ is NOT globbed by commands/plan.md state detection (Step 0 globs docs/plans/ only)
- [ ] **[DEEPENED]** Verify "no active plans" menu has 3 options (under limit)
- [ ] **[DEEPENED]** Verify "active plans" menu has 4 options (at limit, not over)
- [ ] **[DEEPENED]** Verify sub-menus have 2-3 options each (under limit)

## Past Learnings Applied

- **Wiring checklist** (`docs/solutions/best-practices/new-review-agent-wiring-checklist-20260224.md`): Used as template for the documentation update sweep. Adapted from review-agent-specific steps to generic agent/skill registration.
- **AskUserQuestion gate enforcement**: All interaction gates use mandatory table format with CRITICAL/STOP language and "What Happens If Skipped" consequences.
- **Direct workflow routing**: Skill chains use `Skill(skill="godmode:...")` dispatch, not "suggest user invoke" pattern.
- **[DEEPENED] State-aware menu design**: Menus in commands detect state before presenting options. Roadmap/backlog availability should adapt — e.g., "Generate backlog" in the "no active plans" menu should note it requires roadmap context.

## Risks

- **[DEEPENED — RESOLVED] AskUserQuestion 4-option limit**: Restructured menus with "Product planning" and "Work on existing plan" groupings. Both variants stay at or under 4 options. Sub-menus have 2-3 options each. Verified against all 3 menu levels.
- **Count inconsistency baseline**: Skill counts are already inconsistent (some files say 26, some 27). This plan normalizes all to 29, which requires extra care during the count update sweep.
- **[DEEPENED — RESOLVED] Roadmap/plan state collision**: Roadmaps now go to `docs/roadmaps/` instead of `docs/plans/`, avoiding state detection interference.
- **[DEEPENED] Backlog → create-issues incompatibility**: The `create-issues` skill expects plan files with `status: approved` and Implementation Steps sections. Backlog files have a different format (epic cards, user stories). The backlog skill should handle its own issue creation step rather than delegating to the generic create-issues skill.
- **[DEEPENED] Sub-menu pattern is unprecedented at command level**: No existing command uses two-level AskUserQuestion menus. The `setup` skill uses cascading gates within a skill, but not at the command routing layer. This pattern should be documented as the standard approach for future commands that hit the 4-option limit.
- **[DEEPENED] Single agent serving two skills**: The Product Owner agent handles both roadmap (strategic) and backlog (tactical) tasks. If either skill's requirements diverge significantly in the future, be prepared to split into two agent definitions. For now, skill-level prompt context provides sufficient differentiation.

## Simplicity Review — Decisions Deferred

The simplicity reviewer raised several valid points. Decisions made and deferred:

| Finding | Decision | Rationale |
|---------|----------|-----------|
| `agents/product/` vs `agents/team/` | **Keep agents/product/** | Product Owner is conceptually distinct from execution team roles (Lead, Implementer, Analyst). If more product agents are added later (Scrum Master, Stakeholder Interviewer), the category is justified. If it stays at 1, can revisit. |
| Merge roadmap + backlog into one skill | **Keep separate** | Independent invocation is valuable — a roadmap without a backlog is useful for stakeholder alignment; a backlog can be generated from manual input without a formal roadmap. |
| 3-tier template | **Reduced to 2-tier** | Comprehensive tier had no demonstrated need. Start minimal. |
| RICE scoring | **Replaced with MoSCoW/qualitative** | AI cannot produce reliable quantitative RICE data. |
| Documentation count updates | **Keep** | Consistency matters for this project's quality standard, even if it's maintenance overhead. |

---

## Enhancement Summary (Deepening Results)

**Research agents launched:** 1 codebase research (sub-menu patterns, create-issues interface, option overflow)
**Review agents launched:** 6 (architecture, simplicity, security, performance, edge-case, spec-flow)

| Category | Findings | Priority Fixes |
|----------|----------|----------------|
| Architecture | 9 (0 critical, 3 high, 4 medium, 2 low) | Model param pattern, roadmap-backlog contract, agent output validation |
| Simplicity | 8 (2 critical, 3 high, 2 medium, 1 low) | Agent category justification, RICE → qualitative, 3-tier → 2-tier |
| Security | 3 (0 critical, 0 high, 0 medium, 3 low) | Negligible attack surface for local markdown tool |
| Performance | 4 (0 critical, 0 high, 2 medium, 2 low) | Null guard before agent invocation |
| Edge Cases | 18 (4 critical, 6 high, 6 medium, 2 low) | Roadmap guard, state detection collision, filename sanitization, multi-roadmap disambiguation |
| Spec-Flow | 16 (4 critical, 5 high, 5 medium, 2 low) | Request Changes loop, Reject flow, post-skill gates, backlog load fallback |

**Cross-agent consensus (3+ agents):**
- Roadmap guard in backlog skill (4 agents) → **ADDED**
- Filename sanitization (4 agents) → **ADDED**
- Agent output validation (3 agents) → **ADDED**
- Sub-menu pattern validation (3 agents) → **RESOLVED** with full menu specification

**Changes made to plan:**
1. Roadmap output directory: `docs/plans/` → `docs/roadmaps/` (avoids state detection collision)
2. Prioritization: RICE scoring → MoSCoW / qualitative tiers (avoids fabricated metrics)
3. Template: 3-tier → 2-tier (YAGNI — Comprehensive tier speculative)
4. Added input validation spec for both skills
5. Added agent output validation step for both skills
6. Added complete Request Changes loop spec (3-round cap)
7. Added complete Reject flow spec (discard + return)
8. Added roadmap discovery guards in backlog skill (0/1/2-4/5+ match handling)
9. Added roadmap-backlog contract definition
10. Added complete menu restructuring spec (no option limit violations)
11. Added complete post-skill AskUserQuestion gates
12. Added filename collision check and sanitization
13. Added backlog-specific issue creation (not generic create-issues)
14. Noted sub-menu pattern is unprecedented — should be documented
