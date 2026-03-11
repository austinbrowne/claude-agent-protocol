---
type: standard
title: "GODMODE Modernization — Native Subagent Types, Tool References, Version Sync"
date: 2026-03-10
status: approved
security_sensitive: false
priority: high
---

# Plan: GODMODE Modernization — Native Subagent Types, Tool References, Version Sync

## Problem

The GODMODE project (v5.16.0-experimental) has accumulated technical debt from Claude Code platform evolution:

1. **Stale subagent types** — Skills spawn review/research/team agents via `subagent_type: "general-purpose"` with custom prompts inlined, but Claude Code now provides **all 24 agents as native built-in subagent types** (e.g., `security-reviewer`, `learnings-researcher`, `team-lead`). Using native types reduces token overhead and improves routing.

2. **Tool naming drift** — Skills reference "Task tool" and `TaskCreate`/`TaskUpdate`/`TaskGet`/`TaskList`, but the current Claude Code tool is `Agent` with `subagent_type` parameter. 18 files affected.

3. **Version drift** — `AI_CODING_AGENT_GODMODE.md` says v5.3.0 but plugin manifest and git say v5.16.0-experimental.

4. **Stale model IDs** — Plugin schema references `claude-sonnet-4-20250514` (old).

## Goals

- Migrate all agent spawning to use native `subagent_type` values instead of `"general-purpose"` with inlined prompts
- Update all "Task tool" references to "Agent tool" terminology
- Sync version numbers across all files
- Update stale model ID references

## Solution

Systematic, ordered migration across skills, guides, agents, and docs — organized into 4 workstreams with defined execution order and rollback strategy. **[DEEPENED]** Workstreams execute sequentially: A → B → C/D (not fully parallel) to avoid ambiguous mid-migration state.

**[REVIEWED] Risk separation:** Workstreams have distinct risk profiles:
- **Semantic migrations** (Workstream A): Changes agent dispatching behavior — higher risk, requires pilot/verification
- **Mechanical renames** (Workstream B): Text-only terminology changes — lower risk, phrase-exact replacement
- **Trivial fixes** (Workstreams C/D): Single-line corrections — near-zero risk

**[REVIEWED] Baseline capture:** Before starting any workstream, capture occurrence counts:
- `Grep "general-purpose" | wc -l` → baseline for Workstream A verification
- `Grep "Task tool" | wc -l` → baseline for Workstream B verification (expected: ~48)
- Compare post-migration counts against baseline to confirm all occurrences addressed

## Technical Approach

### Step 0: Discovery & Validation Gate (NEW — [DEEPENED])

**Before any file changes, verify assumptions:**

1. **Native type existence check** — Confirm each of the 24 agent names exists as a built-in `subagent_type` in Claude Code. The current built-in list includes: `security-reviewer`, `code-quality-reviewer`, `edge-case-reviewer`, `architecture-reviewer`, `performance-reviewer`, `concurrency-reviewer`, `api-contract-reviewer`, `dependency-reviewer`, `documentation-reviewer`, `error-handling-reviewer`, `simplicity-reviewer`, `testing-adequacy-reviewer`, `ui-reviewer`, `supervisor`, `adversarial-validator`, `spec-flow-reviewer`, `team-lead`, `team-implementer`, `team-analyst`, `product-owner`, `best-practices-researcher`, `codebase-researcher`, `framework-docs-researcher`, `learnings-researcher`. **All 24 confirmed as native types.**

2. **Double-loading behavior** — Native subagent types load agent definition files automatically from the `agents/` directory (matched by name). Skills that currently inline agent definition content into prompts MUST strip that inlined content after migration to avoid duplicate instructions. **Rule: After changing `subagent_type`, remove the `[inline content from agents/...]` block from the prompt template.**

3. **Model parameter behavior** — Native types read the `model` field from their YAML frontmatter. Explicit `model:` parameters in Agent tool calls take precedence (override). Current explicit model params should be KEPT for now as they match frontmatter values and provide explicit documentation.

4. **Create feature branch** — All changes on a single branch for atomic revert if needed.

### Workstream A: Native Subagent Migration (12 files)

Replace `subagent_type: "general-purpose"` with the matching native type wherever a known agent definition is referenced. **[DEEPENED]** After changing subagent_type, strip inlined agent definition content from prompt templates (native types auto-load these).

**Research agent mapping:**

| Current | Native `subagent_type` | Strip Inlined Content? |
|---|---|---|
| `"general-purpose"`, model: haiku, reads `learnings-researcher.md` | `"learnings-researcher"` | Yes — remove inlined definition |
| `"general-purpose"`, model: haiku, reads `best-practices-researcher.md` | `"best-practices-researcher"` | Yes — remove inlined definition |
| `"general-purpose"`, model: haiku, reads `framework-docs-researcher.md` | `"framework-docs-researcher"` | Yes — remove inlined definition |
| `"Explore"`, reads `codebase-researcher.md` | Keep `"Explore"` | No — Explore is a built-in meta-type, not a direct agent mapping |

**Review agent mapping (fresh-eyes-review, deepen-plan, review-plan):**

| Current | Native `subagent_type` | Strip Inlined Content? |
|---|---|---|
| Agent with inlined security-reviewer.md prompt | `"security-reviewer"` | Yes |
| Agent with inlined code-quality-reviewer.md prompt | `"code-quality-reviewer"` | Yes |
| (same pattern for all 16 review agents) | matching name from agent definition | Yes |

**Team/product agent mapping:**

| Current | Native `subagent_type` | Strip Inlined Content? |
|---|---|---|
| `"godmode:team:team-lead"` | `"team-lead"` | Yes — remove inlined role definitions |
| `"general-purpose"` with product-owner prompt | `"product-owner"` | Yes — remove inlined role definition |

**[DEEPENED] "general-purpose" Exception Criteria:**

The following usages of `"general-purpose"` should NOT be migrated because they are genuinely generic (no matching native agent type):

| File | Usage | Why Keep |
|---|---|---|
| `skills/triage-issues/SKILL.md` | Planning subagent for individual issues | Custom per-issue prompt, not a named agent role |
| Any future ad-hoc subagent | One-off tasks with custom prompts | No stable agent identity |

**Rule:** Migrate to native type ONLY when the subagent prompt references a specific agent definition file from `agents/`. If the prompt is custom/ad-hoc, keep `"general-purpose"`.

**[REVIEWED] "Strip inlined content" specification:**

Skills currently inline agent definitions using these patterns:
1. `YOUR REVIEW PROCESS:\n[inline content from agents/review/[agent].md]` — in fresh-eyes-review, deepen-plan, review-plan
2. `YOUR ROLE DEFINITION:\n[inline content from agents/team/lead.md]` + `IMPLEMENTER ROLE DEFINITION:\n[inline content from agents/team/implementer.md]` — in start-issue, team-implement
3. `YOUR ROLE DEFINITION:\n[inline content from agents/product/PRODUCT_OWNER.md]` — in backlog, roadmap

**What to strip:** Remove the entire `[inline content from agents/...]` placeholder block and any "Before launching: The orchestrator reads each agent's definition file and inlines the content" instruction. The native type auto-loads this content.

**What to keep:** The task-specific prompt context (plan content, diff path, issue details, acceptance criteria). Only the agent definition injection is removed — the unique per-invocation context stays.

**What replaces stripped content:** Nothing — the block is deleted. The native subagent type handles definition loading. The prompt template shrinks to just the task-specific context.

**Files with inlined content to strip (7 files):**
- `skills/fresh-eyes-review/SKILL.md` — 13 reviewer definition blocks
- `skills/deepen-plan/SKILL.md` — 6 reviewer + 3 researcher definitions
- `skills/review-plan/SKILL.md` — 5 reviewer definitions
- `skills/start-issue/SKILL.md` — 2 researcher + 3 team role definitions
- `skills/team-implement/SKILL.md` — 3 team role definitions
- `skills/backlog/SKILL.md` — 1 product-owner definition
- `skills/roadmap/SKILL.md` — 1 product-owner definition

**Files WITHOUT inlined content (5 files — subagent_type change only):**
- `skills/explore/SKILL.md` — table references, agents read their own definitions
- `skills/generate-plan/SKILL.md` — table references
- `skills/brainstorm/SKILL.md` — check if any inlining exists
- `skills/triage-issues/SKILL.md` — KEEP "general-purpose" (exception)
- `scripts/loop-prompts/review-worker.md` — template for loop orchestrator

### Workstream B: Task→Agent Tool Terminology (48 occurrences across ~20 files)

**[DEEPENED]** Detailed replacement patterns with exact scope:

| Pattern | Replace With | Scope | Count |
|---|---|---|---|
| `Task tool` (phrase) | `Agent tool` | All non-plan, non-cache files | ~48 |
| `Task Tool Config` (table header) | `Agent Tool Config` | skills/explore, skills/generate-plan | 2 |
| `Task(` (code example) | `Agent(` | skills/team-implement, start-issue, roadmap, backlog | ~8 |
| `via Task` (phrase, not `via TaskUpdate`) | `via Agent tool` | skills, guides | ~17 |

**[DEEPENED] Critical exclusions (do NOT rename):**
- `TaskCreate`, `TaskUpdate`, `TaskGet`, `TaskList`, `TaskStop`, `TaskOutput` — these are real Agent Teams coordination tool names
- `Skill(skill="godmode:...")` — these are skill invocations, not agent spawning
- `TeamCreate`, `TeamDelete`, `SendMessage` — Agent Teams tools
- Plan docs in `docs/plans/` — historical documents, leave as-is (per Simplicity Review: retroactive editing distorts the record)
- Solution docs in `docs/solutions/` — keep original terminology for historical accuracy

**[DEEPENED] CLAUDE.md special handling:**
CLAUDE.md is loaded with system priority. Each edit must be manually reviewed line-by-line, never bulk-replaced. Specific line: `CLAUDE.md:80` — "via the Task tool" → "via the Agent tool". Verify surrounding safety rules are unaltered.

**[REVIEWED] CLAUDE.md post-edit safety verification:**
After editing CLAUDE.md, run these checks:
1. `Grep pattern="NEVER|MUST|CRITICAL|ALWAYS" path="CLAUDE.md"` — compare line count before/after (must be identical)
2. `git diff CLAUDE.md` — verify ONLY the "Task tool" → "Agent tool" change appears, no collateral modifications
3. Confirm these exact strings still exist: "HUMAN IN LOOP", "SECURITY FIRST", "EXPLORE FIRST", "TEST EVERYTHING", "TeamCreate"

### Workstream C: Version Sync (1 file)

- `AI_CODING_AGENT_GODMODE.md` line 3: `5.3.0-experimental` → `5.16.0-experimental`
- **[DEEPENED]** Scope replacement to the `**Version:**` line only. Do NOT search-and-replace `5.3.0` globally — could match dependency versions.

### Workstream D: Model ID Update (1 file)

- `plugins/marketplaces/.../schemas.md`: `claude-sonnet-4-20250514` → `claude-sonnet-4-6-20250217`
- **[DEEPENED]** Target the exact JSON path containing `"executor_model"`, not a global find.

## Implementation Steps

**[DEEPENED] Execution order is sequential, not parallel:**

1. **Step 0: Discovery gate** — Verify native type existence, create feature branch
2. **Workstream C+D** — Version sync and model ID (trivial, do first to warm up)
3. **Workstream A** — Native subagent migration (highest risk, most files)
   - Start with ONE skill file (`skills/explore/SKILL.md`) as pilot
   - **[REVIEWED] Pilot pass/fail criteria:**
     - PASS if: (a) all `"general-purpose"` replaced with native types, (b) no `[inline content from agents/...]` blocks remain, (c) agent definition file paths still referenced in table/comments for documentation, (d) file reads coherently as a complete skill definition
     - FAIL if: any of the above not met, OR the file contains orphaned prompt fragments from stripped content
     - On FAIL: stop, diagnose, fix the pilot, re-verify before proceeding
     - On PASS: proceed with remaining 11 files using the same pattern
   - Then proceed with remaining 11 files
4. **Workstream B** — Task→Agent terminology (depends on A completing to avoid mid-migration ambiguity)
   - CLAUDE.md first (manual review)
   - Then guides, then skills, then agent definitions
5. **Count verification pass** — Grep for numeric count references across all files
6. **Final verification** — All grep checks from Test Strategy

**[DEEPENED] Affected files (refined):**

**Workstream A (12 files):**
- `skills/explore/SKILL.md` — 3 research agents (PILOT FILE)
- `skills/generate-plan/SKILL.md` — 3 research agents
- `skills/deepen-plan/SKILL.md` — 3 research + 6 review agents
- `skills/review-plan/SKILL.md` — 5 review agents
- `skills/fresh-eyes-review/SKILL.md` — 13 review agents (largest change)
- `skills/start-issue/SKILL.md` — 2 research agents + team-lead
- `skills/team-implement/SKILL.md` — team-lead
- `skills/triage-issues/SKILL.md` — KEEP "general-purpose" (exception)
- `skills/backlog/SKILL.md` — product-owner
- `skills/roadmap/SKILL.md` — product-owner
- `skills/brainstorm/SKILL.md` — check for agent spawning
- `scripts/loop-prompts/review-worker.md` — review agents

**Workstream B (~20 files, 48 occurrences):**
- `CLAUDE.md` — 1 occurrence (manual review)
- `AI_CODING_AGENT_GODMODE.md` — multiple occurrences
- `guides/AGENT_TEAMS_GUIDE.md` — 11 occurrences
- `guides/MULTI_AGENT_PATTERNS.md` — 2 occurrences
- `guides/FRESH_EYES_REVIEW.md` — 1 occurrence
- `commands/loop.md` — occurrences
- 11 skill files — variable occurrences
- `agents/product/PRODUCT_OWNER.md` — 1 occurrence
- **SKIP:** `docs/plans/*`, `docs/solutions/*` (historical)

**Workstream C (1 file):** `AI_CODING_AGENT_GODMODE.md`

**Workstream D (1 file):** `plugins/marketplaces/.../schemas.md`

## Acceptance Criteria

- [ ] No remaining `subagent_type: "general-purpose"` where a native type exists
- [ ] No remaining "Task tool" references (except historical docs and `TaskUpdate`/`TaskCreate` tool names)
- [ ] `AI_CODING_AGENT_GODMODE.md` version matches plugin.json (5.16.0-experimental)
- [ ] No stale model IDs (no `claude-*-4-20250514` patterns)
- [ ] All skills still correctly reference their agent definition files for documentation
- [ ] `godmode:team:team-lead` → `team-lead` in all skill files
- [ ] Inlined agent definition content stripped from prompt templates in migrated skills
- [ ] `Skill(skill="godmode:...")` invocations unchanged
- [ ] `TaskCreate`/`TaskUpdate`/`TaskGet`/`TaskList` tool names unchanged
- [ ] CLAUDE.md safety rules verified intact after edit
- [ ] Grep verification passes for all migration targets
- [ ] **[DEEPENED]** Count references (e.g., "16 review", "24 agent", "29 skill") verified consistent

## Test Strategy

- **Verification grep:** `"general-purpose"` — should only appear in triage-issues and generic/fallback contexts
- **Verification grep:** `"Task tool"` — should return zero matches outside historical docs
- **Verification grep:** `"Task("` — should return zero matches (replaced with `Agent(`)
- **Verification grep:** `5.3.0` — should return zero matches in version declarations
- **Verification grep:** `claude-sonnet-4-20250514` — should return zero matches
- **Verification grep:** `godmode:team:` — should return zero matches in subagent_type contexts (only in Skill() calls)
- **[DEEPENED] Count verification grep:** Search for patterns like `\d+ review`, `\d+ agent`, `\d+ skill`, `\d+ research` — verify all numeric counts are consistent
- **[DEEPENED] Safety verification:** Diff CLAUDE.md before/after — confirm only "Task tool" → "Agent tool" changed, no collateral damage
- **[DEEPENED] Pilot validation:** After updating `skills/explore/SKILL.md`, manually read and verify the file is coherent before proceeding

## Security Review

- [ ] **[DEEPENED]** CLAUDE.md changes manually reviewed — safety rules intact
- [ ] **[DEEPENED]** `TeamCreate` detection logic in Step 0 patterns preserved
- [ ] **[DEEPENED]** Security-reviewer native type verified to match custom prompt coverage (OWASP checklist reference preserved in agent definition file)
- [ ] **[REVIEWED]** Verify `agents/review/security-reviewer.md` still contains OWASP reference and all 13 review process items after migration — native type loads this file, so content integrity = coverage integrity
- [ ] N/A for other workstreams — documentation/configuration changes only

## Past Learnings Applied

- **new-skill-agent-category-wiring-checklist-20260225.md**: Run systematic checklist across all registration points; verify count references remain accurate. **[DEEPENED]** Adapted Phase 3 as "Naming Refactor Checklist" — find all refs → normalize → verify consistency
- **agent-teams-context-pollution.md**: Preserve Step 0 fresh-check patterns; don't remove `TeamCreate` detection logic. **[DEEPENED]** After migration, add CRITICAL language noting native types supersede "general-purpose" pattern
- **new-review-agent-wiring-checklist-20260224.md**: After changes, Grep for count patterns to ensure consistency
- **[DEEPENED] askuserquestion-gate-enforcement.md**: Documentation consistency — ensure AskUserQuestion gate descriptions still match after terminology changes

## Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **[DEEPENED]** Double-loading: native type auto-loads definition AND skill inlines it | High (if not addressed) | Medium | Strip inlined content from prompts after migration — explicit rule in Workstream A |
| **[DEEPENED]** Native type behavioral parity — security-reviewer may differ from custom prompt | Low | High | Agent definition files are auto-loaded by native types; custom review process stays intact |
| `TaskUpdate`/`TaskCreate` incorrectly renamed in team agent coordination | Medium | Medium | Only rename "Task tool" narrative text; preserve actual tool names. Exact phrase matching. |
| **[DEEPENED]** CLAUDE.md safety rule corruption from bulk replace | Low | Critical | Manual line-by-line review of CLAUDE.md. Never bulk-replace. |
| Count references become stale (e.g., "29 skills" mentioned in docs) | Medium | Low | Final grep pass for count patterns |
| `godmode:` namespace references in Skill() calls get accidentally modified | Low | High | Only change `subagent_type` values, not `Skill(skill="godmode:...")` invocations |
| **[DEEPENED]** Code examples in docs showing old syntax get broken | Medium | Low | Deliberately update code examples to show new syntax; verify code fences |

## Rollback Plan ([DEEPENED] — new section)

All changes are on a feature branch. Rollback options:

1. **Per-file revert:** `git checkout main -- path/to/file.md` for individual files
2. **Full revert:** `git checkout main` to abandon entire branch
3. **Partial rollback:** If Workstream A causes issues but B/C/D are fine, revert only the 12 Workstream A files

**Rollback triggers:**
- Native subagent types don't dispatch correctly after migration
- CLAUDE.md safety rules fail validation
- Skills produce errors when invoked after terminology changes

## Enhancement Summary ([DEEPENED])

**Deepening applied:** 6 review agents (Architecture, Simplicity, Security, Performance, Edge Case, Spec-Flow) + 2 research agents (Codebase, Learnings).

| Category | Findings | Priority Fixes |
|---|---|---|
| Architecture | 3 CRITICAL/HIGH, 3 MEDIUM | Added Step 0 discovery gate, double-loading rule, rollback plan |
| Simplicity | 2 workstreams questioned | Justified B (tool actually renamed); deferred plan doc updates |
| Security | 2 HIGH, 2 MEDIUM | CLAUDE.md manual review rule, TeamCreate preservation |
| Performance | 2 HIGH, 2 MEDIUM | Strip inlined content rule (saves ~26K tokens/review) |
| Edge Case | 1 HIGH, 4 MEDIUM | Phrase-exact matching, version scoping, code example handling |
| Spec-Flow | 2 HIGH, 4 MEDIUM/LOW | Sequential ordering, rollback plan, count verification pass |
| Learnings | 3 applicable solutions | Wiring checklist adapted, context pollution guards preserved |

**Key additions from deepening:**
1. Step 0 discovery/validation gate (pre-flight check)
2. Double-loading mitigation rule (strip inlined content)
3. Sequential execution order (A before B)
4. "general-purpose" exception criteria
5. CLAUDE.md special handling rule
6. Rollback plan with per-file granularity
7. Expanded acceptance criteria (12 checks, up from 7)
8. Historical doc exclusion (plans/solutions left as-is)
9. Pilot file strategy (explore/SKILL.md first)
10. Count verification pass

## Plan Review Findings ([REVIEWED])

**Review date:** 2026-03-10
**Reviewers:** Architecture, Simplicity, Spec-Flow, Security + Adversarial Validator
**Initial verdict:** REVISION_REQUESTED → **Revised verdict after fixes:** APPROVED_WITH_NOTES

**Blockers addressed:**
1. Pilot pass/fail criteria — defined explicit PASS/FAIL conditions and recovery path
2. "Strip inlined content" — specified exact patterns, files, and replacement rules (7 files with content, 5 without)
3. CLAUDE.md safety verification — added 3-step post-edit check (keyword count, git diff, string existence)
4. Risk separation — distinguished semantic migrations (A) from mechanical renames (B) from trivial fixes (C/D)

**Adversarial findings addressed:**
- Baseline capture added (grep counts before/after)
- Security-reviewer equivalence verification added
- Cross-file dependency risk mitigated by separating "files with inlined content" (7) from "subagent_type change only" (5)

**Accepted non-blocking suggestions:**
- Count references verified via grep pass (already in plan)
- Model ID verified against published list (Step 0 confirmation)
- Discovery gate kept (Adversarial overruled Simplicity's "over-engineered" assessment)
