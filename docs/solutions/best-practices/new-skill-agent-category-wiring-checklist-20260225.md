---
module: Plugin Architecture
date: 2026-02-25
problem_type: best_practice
component: tooling
symptoms:
  - "New skill files exist but workflow command doesn't offer them"
  - "Agent/skill/template counts inconsistent across 8+ documentation files"
  - "New output directory collides with existing state detection glob patterns"
  - "Workflow command exceeds AskUserQuestion 4-option limit after adding new skills"
root_cause: config_error
resolution_type: documentation_update
severity: medium
tags: [skill, agent, wiring, checklist, new-skill, new-agent, plugin, protocol, sub-menu, state-detection]
issue_ref: "#46"
related_solutions:
  - docs/solutions/best-practices/new-review-agent-wiring-checklist-20260224.md
  - docs/solutions/workflow-issues/return-path-menus-nested-skills-20260214.md
---

# Best Practice: Adding New Skills + Agent Categories — Complete Wiring Checklist

## Problem
Adding new skills, agent categories, and templates to the protocol requires changes across 13+ files. Missing any registration point leaves the skill partially integrated — it exists as a file but is never offered in workflow menus, counts are inconsistent, or output directories collide with existing state detection.

## Environment
- Module: Plugin Architecture (skills/, agents/, commands/, templates/)
- Affected Component: Cross-file registration and count management
- Date: 2026-02-25

## Symptoms
- New skill SKILL.md exists but workflow command doesn't offer it in AskUserQuestion menu
- Agent/skill/template counts are inconsistent (some files say 27, others say 29)
- New output directory (e.g., `docs/roadmaps/`) triggers false positives in workflow state detection
- Workflow command crashes with >4 options in AskUserQuestion after adding new skills

## What Didn't Work

**Direct solution:** The full wiring was completed on the first attempt using a systematic checklist approach. Key issues were caught during review rather than during implementation.

## Solution

### Checklist: Adding New Skills (2 skills + 1 agent + 1 template)

**Phase 1: Create New Files**

- [ ] **Agent definition** — `agents/{category}/AGENT_NAME.md` with YAML frontmatter (`name`, `model`, `description`), sections (Philosophy, When to Invoke, Capabilities, Output Standards, Examples)
- [ ] **Skill files** — `skills/{name}/SKILL.md` with YAML frontmatter (`name`, `version`, `description`, `referenced_by`), 5 mandatory sections (Mandatory Interaction Gates, When to Apply, Skills Referenced, Process, Integration Points)
- [ ] **Template file** — `templates/TEMPLATE_NAME.md` with YAML frontmatter and tier-appropriate content
- [ ] **Output directories** — `docs/{output-dir}/.gitkeep` for skill output (e.g., `docs/roadmaps/`, `docs/backlogs/`)

**Phase 2: Wire into Workflow Command**

- [ ] **Workflow command** — Add new skills to the appropriate `commands/*.md` AskUserQuestion menu
- [ ] **Sub-menu pattern** — If adding skills pushes options past 4, use sub-menu (parent option dispatches to a second AskUserQuestion with child options)
- [ ] **Step 2 dispatch** — Add `Skill(skill="godmode:{name}")` routing entries
- [ ] **Step 3 post-skill gates** — Add "After {skill}" AskUserQuestion with appropriate next-step options
- [ ] **State detection (Step 0)** — Verify new output directories don't collide with existing glob patterns

**Phase 3: Update Documentation Counts (8+ files)**

| File | What to Update |
|------|---------------|
| `README.md` | Summary paragraph counts, directory tree, skills table |
| `QUICK_START.md` | Skills count, agents section, files reference table |
| `AI_CODING_AGENT_GODMODE.md` | "Current" summary line, architecture section, appendix |
| `.claude-plugin/plugin.json` | Description string (skill/agent/template counts) |
| `.claude-plugin/marketplace.json` | Description string (same counts) |
| `guides/PROJECT_CONVENTIONS.md` | Directory table, reference files table, counts |
| `guides/WORKFLOW_REFERENCE.md` | Skills list under appropriate category |

**Phase 4: Verify**

- [ ] All count references match across all files
- [ ] New skills appear in workflow command menu
- [ ] Output directories don't trigger false positives in state detection
- [ ] AskUserQuestion gates stay at 4 options max
- [ ] Post-skill routing chains to appropriate next workflows

### Key Gotchas

**1. State Detection Collision**
Workflow commands use glob patterns (e.g., `docs/plans/*.md`) for state detection in Step 0. If a new skill outputs files to an existing glob path, it will trigger false positives. Example: roadmap files in `docs/plans/` would be detected as "active plans" by `/plan` Step 0. Solution: use dedicated output directories (`docs/roadmaps/`, `docs/backlogs/`).

**2. AskUserQuestion 4-Option Limit**
AskUserQuestion supports max 4 options. When adding skills to a workflow command pushes past 4, use the sub-menu pattern:
- Parent option: "Product planning" (groups related skills)
- Child AskUserQuestion: "Generate roadmap" / "Generate backlog"
This was the first command-level sub-menu in the project (commands/plan.md).

**3. YAML Template Pipe Syntax**
Never use `status: active | archived` in YAML templates — an LLM agent will copy the literal pipe character. Use comment notation: `status: active  # options: active, archived`.

**4. Non-ASCII Input Sanitization**
Filename sanitization with `[a-zA-Z0-9-_ ]` strips all non-ASCII characters. A product name in CJK, Arabic, or accented characters produces an empty string. Always guard: "If empty after sanitization, set to fallback value."

**5. Revision Loop Lifecycle**
When defining a revision loop (e.g., "Request changes" up to N times), explicitly specify: counter initialization (0 before first gate), increment (on each request), reset (on acceptance), and cap behavior (escape hatch AskUserQuestion at limit).

**6. Cross-Skill Consistency**
When two skills share a specification (e.g., filename sanitization rules), define it canonically in one skill and cross-reference from the other. Add a DRY mirror note: "This protocol is shared with `skills/{other}/SKILL.md` Step N. Changes here must be mirrored there."

**7. Count Normalization**
Before updating counts, grep the entire project for the old count to find ALL references. Some files may have stale counts from previous releases (e.g., one file says 26 while another says 27). Normalize all to the correct new value.

## Why This Works

The protocol's distributed architecture means a single addition touches many files. A systematic checklist ensures nothing is missed. The gotchas address patterns that were caught only during multi-agent review, not during implementation — making them particularly valuable for future additions.

## Prevention

- Run this checklist for every new skill, agent, or template addition
- Use `Grep` to find all count references before updating (search for the current count as a number)
- After implementation, run `/review` with fresh-eyes to catch state detection collisions and spec gaps
- Test workflow commands end-to-end: invoke the command, verify new options appear, verify routing works
- For the review-agent-specific subset, see the companion checklist: `new-review-agent-wiring-checklist-20260224.md`

## Related Issues

- See also: [new-review-agent-wiring-checklist-20260224.md](./new-review-agent-wiring-checklist-20260224.md)
- See also: [return-path-menus-nested-skills-20260214.md](../workflow-issues/return-path-menus-nested-skills-20260214.md)
- GitHub issue: #46 (Product Owner Agent)
