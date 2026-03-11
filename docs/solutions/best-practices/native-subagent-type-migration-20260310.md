---
module: "Agent System"
date: 2026-03-10
problem_type: best_practice
component: tooling
symptoms:
  - "Skills using subagent_type: general-purpose with custom prompts instead of native built-in types"
  - "Outdated Task tool terminology instead of Agent tool"
  - "Version drift between AI_CODING_AGENT_GODMODE.md (5.3.0) and actual version (5.16.0)"
  - "Stale model IDs in plugin schemas"
root_cause: dependency_issue
resolution_type: code_fix
severity: medium
tags: [native-subagent, agent-tool, migration, subagent-type, task-tool, modernization, claude-code]
---

# Best Practice: Migrating to Native Subagent Types

## Problem
Claude Code evolved to provide native built-in `subagent_type` values matching all 24 custom agents (16 review, 4 research, 3 team, 1 product). The GODMODE project was still using `subagent_type: "general-purpose"` with inlined custom prompts and referencing the deprecated "Task tool" name.

## Environment
- Module: Agent System (skills, agents, guides)
- Affected Component: 29 skills, agent definitions, guides, CLAUDE.md
- Date: 2026-03-10

## Symptoms
- Skills spawning agents via `subagent_type: "general-purpose"` with long inlined prompts
- References to "Task tool" and "Task calls" throughout documentation
- Version 5.3.0 in protocol doc vs 5.16.0-experimental actual
- Old model ID `claude-sonnet-4-20250514` in plugin schemas

## Solution

### Workstream A: Migrate to Native Subagent Types

Replace `subagent_type: "general-purpose"` with the matching native type:

```
# Before:
subagent_type: "general-purpose"
model: "haiku"
prompt: "[entire learnings-researcher.md inlined here]"

# After:
subagent_type: "learnings-researcher"
model: "haiku"
prompt: "[task-specific instructions only — definition auto-loaded]"
```

Native types auto-load their agent definition files from `agents/` — no need to inline.

### Workstream B: Task tool → Agent tool

Find-and-replace across skills and guides:
- "Task tool" → "Agent tool"
- "Task calls" → "Agent calls"
- "Task Tool Config" → "Agent Tool Config"
- `Task(` → `Agent(` in code examples

### Workstream C: Version Sync
Update `AI_CODING_AGENT_GODMODE.md` version string.

### Workstream D: Model ID Update
Update stale model IDs in plugin schemas.

## Why This Works

Native subagent types eliminate prompt duplication — the platform loads agent definitions automatically. This reduces token cost, prevents drift between inlined copies and source definitions, and simplifies skill files.

## Prevention

### 5 Critical Gotchas

1. **Double-loading risk**: Native types auto-load agent definitions. If a skill ALSO inlines the definition, the agent gets duplicate instructions. After migrating to native types, STRIP inlined definition content and replace with a note like "Native type auto-loads definition."

2. **CLAUDE.md requires manual review**: Never bulk find-and-replace in CLAUDE.md. It loads with system priority — a bad edit corrupts every conversation. Review line-by-line with post-edit verification (keyword count, git diff, critical string check).

3. **TaskCreate/TaskUpdate/TeamCreate are REAL tool names**: These are Agent Teams coordination tools, NOT "Task tool" references. Do NOT rename them. The "Task tool" being renamed is the *spawning* tool (now called "Agent tool"), not these coordination tools.

4. **Skill() invocations keep godmode: prefix**: `Skill(skill="godmode:fresh-eyes-review")` is skill dispatching, not agent spawning. The `godmode:` prefix is the plugin namespace for skills. Do NOT change these — only change `subagent_type` values.

5. **"general-purpose" is sometimes correct**: `triage-issues/SKILL.md` legitimately uses `"general-purpose"` because each planning subagent gets a unique per-issue prompt with no matching named agent role. Exception criteria: custom prompt content that varies per invocation AND no single agent definition covers the use case.

### Migration Checklist
- [ ] Replace `subagent_type: "general-purpose"` with native type name
- [ ] Strip inlined agent definition content (prevent double-loading)
- [ ] Update orchestrator instructions from "reads and inlines" to "native types auto-load"
- [ ] Change "Task tool" → "Agent tool" in prose
- [ ] Verify `Skill()` invocations are NOT changed
- [ ] Verify `TaskCreate`/`TaskUpdate`/`TeamCreate` are NOT renamed
- [ ] Post-edit verify CLAUDE.md if touched

## Related Issues

- See also: [new-review-agent-wiring-checklist-20260224.md](new-review-agent-wiring-checklist-20260224.md)
- See also: [new-skill-agent-category-wiring-checklist-20260225.md](new-skill-agent-category-wiring-checklist-20260225.md)
