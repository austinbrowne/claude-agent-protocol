---
module: Review Pipeline
date: 2026-02-24
problem_type: best_practice
component: tooling
symptoms:
  - "New review agent exists as file but doesn't trigger during reviews"
  - "Agent count references inconsistent across protocol documentation"
  - "Setup skill doesn't offer new agent in configuration"
root_cause: config_error
resolution_type: documentation_update
severity: medium
tags: [review-agent, fresh-eyes-review, wiring, checklist, new-agent, registration, protocol]
---

# Best Practice: Adding a New Review Agent — Complete Wiring Checklist

## Problem
Adding a new review agent to the fresh-eyes-review pipeline requires changes across 6+ files. Missing any registration point leaves the agent partially integrated — it may exist as a file but never trigger, or trigger but not appear in setup configuration.

## Environment
- Module: Review Pipeline (fresh-eyes-review)
- Affected Component: Agent registration across protocol files
- Date: 2026-02-24

## Symptoms
- Agent definition file exists in `agents/review/` but never runs during reviews
- Agent count references are inconsistent (some say 15, some say 16)
- `/setup` doesn't offer the new agent in its selection menu
- Frontend/backend preset doesn't include the new agent

## Solution

### Complete Checklist (6 tasks, ~13 files)

**1. Create agent definition** — `agents/review/{name}-reviewer.md`
- YAML frontmatter: `name`, `model` (opus/sonnet/haiku), `description`
- Sections: Philosophy, When to Invoke, Review Process (8-13 checkpoints), Output Format, Examples
- Follow existing agent patterns for format consistency

**2. Add trigger patterns** — `skills/fresh-eyes-review/references/trigger-patterns.md`
- Add new `## {Name} Reviewer` section
- Define: file path patterns, file extension patterns, diff content patterns
- Optional: LOC threshold

**3. Update fresh-eyes-review SKILL.md** — `skills/fresh-eyes-review/SKILL.md`
- Add row to **Conditional Agents table** (agent #, name, model, trigger summary)
- Add row to **Step 2 trigger patterns table**
- Add to **agent definitions reference list** in execution pattern section
- Update frontmatter **description count** (e.g., "11-agent" -> "12-agent")

**4. Update FRESH_EYES_REVIEW guide** — `guides/FRESH_EYES_REVIEW.md`
- Add row to **Conditional Agents table** (mirrors SKILL.md)

**5. Update setup skill** — `skills/setup/SKILL.md`
- Add to **Step 4 agent selection options** (label + description)
- Add to relevant **preset** (e.g., Frontend, Backend, Database-Heavy)
- Add to **Available Review Agents Reference table**

**6. Update reference counts** — Grep for old count, update all occurrences:
- `guides/PROJECT_CONVENTIONS.md` — directory table + reference table
- `QUICK_START.md` — file reference table
- `AI_CODING_AGENT_GODMODE.md` — architecture section + appendix
- `README.md` — summary paragraph + agents section + directory tree
- `commands/review.md` — review option description
- `.claude-plugin/plugin.json` — description field
- `.claude-plugin/marketplace.json` — description field

### Grep commands for finding all count references:
```bash
# Find all "N review agent" references
Grep pattern="15 review" path="."
# Find all "N-agent" references
Grep pattern="11-agent|11 agent" path="."
# Don't forget total agent counts (review + research + team)
Grep pattern="22 agent|22 specialized" path="."
```

## Why This Works
The protocol uses a distributed registration pattern — agents are auto-discovered by filename but their metadata (trigger patterns, model tier, descriptions) is configured across multiple files. The checklist ensures no registration point is missed.

## Prevention
- Use this checklist every time a new review agent is added
- After implementation, run the Grep commands above to verify all counts are consistent
- Verify the actual file count matches: `ls agents/review/ | wc -l`
- The plan template at `docs/plans/2026-02-24-standard-ui-review-agent-plan.md` serves as a reusable reference

## Related Issues
- UI Reviewer addition: PR #44
