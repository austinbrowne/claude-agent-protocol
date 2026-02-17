---
title: Smart Model Assignment Across All Agents
type: standard
status: complete
date: 2026-02-17
tags: [cost-optimization, model-selection, agents, performance]
security_sensitive: false
---

# Smart Model Assignment Across All Agents

## Problem

All 24 agents inherit Opus 4.6 ($5/$25 per MTok). Most agent tasks don't require Opus-level reasoning. A retrieval-focused learnings search costs the same as an adversarial security review. This drives unnecessary token cost across every workflow that uses agents — reviews, plans, research, and team implementation.

## Goals

- Assign each agent the cheapest model that maintains quality
- Achieve ~35-40% cost reduction across all agent operations (varies by workflow mix)
- Preserve Opus for genuinely complex reasoning (security, architecture, adversarial validation)

## Technical Approach

**Three-tier model assignment based on task complexity:**

| Tier | Model | Pricing | Agent Count | Criteria |
|------|-------|---------|-------------|----------|
| **Haiku** | claude-haiku-4-5 | $1/$5 per MTok | **7** | Retrieval, search, pure pattern matching |
| **Sonnet** | claude-sonnet-4-5 | $3/$15 per MTok | **12** | Judgment-based review, flow analysis, implementation |
| **Opus** | claude-opus-4-6 | $5/$25 per MTok | **5** | Deep reasoning, security, architecture, adversarial, orchestration |

### Model Mechanism

The Task tool accepts an optional `model` parameter (`"haiku"`, `"sonnet"`, `"opus"`). If omitted, the agent inherits the parent's model. The implementation uses two layers:

1. **Agent YAML frontmatter** (`model: haiku|sonnet|opus`) — source of truth and documentation. Declares the agent's intended model tier.
2. **Task tool `model` parameter** — runtime mechanism. Skills pass this when spawning agents. This is what actually selects the model.

Both are needed: frontmatter for reference/documentation, Task parameter for runtime selection. The frontmatter alone is NOT automatically honored — skills must explicitly pass the `model` parameter.

For built-in subagent types (`Explore`, `Plan`, etc.), model selection is managed internally by Claude Code. The `model` parameter applies to `general-purpose` and custom agent types (e.g., `godmode:review:*`, `godmode:research:*`, `godmode:team:*`).

### Research Backing

- **Qodo benchmark (400 real PRs):** Haiku 4.5 outperformed Sonnet 4 in code review quality (6.55 vs 6.20). With thinking mode, Haiku beat Sonnet 4.5 Thinking 58% of the time (7.29 vs 6.60). Note: benchmark tested general code review, not structured multi-section output format compliance.
- **SWE-bench:** Haiku 73.3%, Sonnet 77.2%, Opus ~80.9%. Haiku within 5 points of Sonnet.
- **Haiku weakness:** Multi-file architectural reasoning and judgment-based analysis — Sonnet excels here.
- **Multi-agent recommendation (Caylent):** "Deploy Sonnet for orchestration, Haiku for sub-task execution." Cost per agent task: Haiku $0.07, Sonnet $0.21.
- **Claude Code Task tool docs:** "Prefer haiku for quick, straightforward tasks to minimize cost and latency."

### Agent Assignments

**Haiku Tier — 7 agents** (retrieval, pure pattern matching, synthesis):

| Agent | Rationale |
|-------|-----------|
| `documentation-reviewer` | Naming clarity, comment quality, README accuracy — checklist |
| `api-contract-reviewer` | HTTP method/status correctness, response format — convention matching |
| `dependency-reviewer` | License check, CVE lookup, maintenance health — retrieval-heavy |
| `testing-adequacy-reviewer` | Coverage gaps, mock quality, assertion specificity — checklist |
| `learnings-researcher` | Multi-pass Grep search over docs/solutions/ — pure retrieval |
| `best-practices-researcher` | Web search + summarize — retrieval + synthesis |
| `framework-docs-researcher` | Context7 MCP query + summarize — retrieval + synthesis |

**Sonnet Tier — 12 agents** (judgment-based review, flow analysis, implementation):

| Agent | Rationale |
|-------|-----------|
| `code-quality-reviewer` | SOLID principles, design pattern appropriateness, cyclomatic complexity — judgment, not checklist |
| `data-validation-reviewer` | Allowlist vs blocklist quality, regex permissiveness, attack vector understanding — security-adjacent judgment |
| `config-secrets-reviewer` | Credential flow analysis ("compiled or loaded at runtime?"), false positive vs real secret distinction — contextual reasoning |
| `error-handling-reviewer` | Requires understanding call graphs, async error propagation, retry logic |
| `performance-reviewer` | N+1 detection requires data flow reasoning across functions |
| `spec-flow-reviewer` | Creative thinking about missing states, user flow gaps |
| `edge-case-reviewer` | Systematic but requires lateral thinking about failure modes — the "AI blind spot" agent |
| `simplicity-reviewer` | YAGNI judgment — "is this too complex?" requires nuanced assessment |
| `supervisor` | Cross-references all specialist findings, deduplicates, assesses real-world impact. Needs adequate reasoning capability when upstream specialists are at lower tiers |
| `codebase-researcher` | Multi-file exploration, pattern identification, architecture understanding |
| `team-implementer` | Full implementation pipeline: code, tests, validation within file boundaries |
| `team-analyst` | Real-time codebase research, pattern discovery, cross-reference with requirements |

**Opus Tier — 5 agents** (deep reasoning, security-critical, orchestration):

| Agent | Rationale |
|-------|-----------|
| `security-reviewer` | OWASP, injection, auth bypass — security too critical for cheaper models |
| `adversarial-validator` | Challenge assumptions, find blind spots, falsification — deepest reasoning |
| `architecture-reviewer` | Cross-system reasoning, component boundaries — Sonnet's documented weakness |
| `concurrency-reviewer` | Race conditions, deadlocks, thread safety — extremely subtle timing analysis |
| `team-lead` | Task decomposition, conflict resolution, multi-agent coordination |

## Implementation Steps

### Step 1: Update agent YAML frontmatter

Change `model: inherit` to `model: haiku`, `model: sonnet`, or `model: opus` in all 24 agent definition files. This is the source of truth for model selection.

### Step 2: Update fresh-eyes-review skill

Add `model` parameter to all Task tool calls when spawning review agents. Read agent tier from the assignment table and pass the corresponding value.

### Step 3: Update review-plan skill

Same pattern as Step 2: pass `model` parameter when spawning the 4 specialist reviewers and the adversarial validator.

### Step 4: Update generate-plan skill

Pass `model: "haiku"` for learnings-researcher, best-practices-researcher, framework-docs-researcher. The codebase-researcher uses `subagent_type: "Explore"` which manages its own model internally, so no model parameter needed there.

### Step 5: Update start-issue skill

Pass appropriate model for research agent spawns (Step 2 research) and team role spawns (Step 5 team path).

### Step 6: Update team-implement skill

Team Lead prompt should instruct spawning implementers with `model: "sonnet"` and analyst with `model: "sonnet"`. Team Lead itself inherits from parent (typically Opus).

### Step 7: Update deepen-plan skill

Pass model parameter for research and review agent spawns.

### Step 8: Update explore skill

Pass `model: "haiku"` for learnings-researcher, best-practices-researcher, framework-docs-researcher spawns.

### Step 9: Update brainstorm skill

Pass `model: "haiku"` for learnings-researcher spawn.

### Step 10: Add model strategy section to AGENT_TEAMS_GUIDE.md

Add a "Model Strategy" section to the existing `guides/AGENT_TEAMS_GUIDE.md` documenting the three-tier approach, rationale, and per-agent assignments. Keep it concise — no separate guide file needed.

## Affected Files

| File | Change |
|------|--------|
| `agents/review/*.md` (14 files) | Update `model:` frontmatter |
| `agents/research/*.md` (4 files) | Update `model:` frontmatter |
| `agents/team/*.md` (3 files) | Update `model:` frontmatter |
| `skills/fresh-eyes-review/SKILL.md` | Add model parameter to Task spawns |
| `skills/review-plan/SKILL.md` | Add model parameter to Task spawns |
| `skills/generate-plan/SKILL.md` | Add model parameter to research agent spawns |
| `skills/deepen-plan/SKILL.md` | Add model parameter to research + review agent spawns |
| `skills/start-issue/SKILL.md` | Add model parameter to research and team spawns |
| `skills/team-implement/SKILL.md` | Add model parameter to team role spawns |
| `skills/explore/SKILL.md` | Add model parameter to research agent spawns |
| `skills/brainstorm/SKILL.md` | Add model parameter to learnings-researcher spawn |
| `guides/AGENT_TEAMS_GUIDE.md` | Add Model Strategy section |

## Acceptance Criteria

- [ ] All 24 agent files have correct `model:` frontmatter value (haiku/sonnet/opus)
- [ ] All 9 skill files that spawn agents pass `model` parameter in Task tool calls
- [ ] `guides/AGENT_TEAMS_GUIDE.md` has Model Strategy section with tier rationale
- [ ] No agent regression: all agents produce structured findings in expected output format
- [ ] `model` parameter passed for `general-purpose` and custom agent subagent types; built-in types (`Explore`, `Plan`) manage their own model selection
- [ ] Skills with missing `model` parameter default to parent model (backward compatible)

## Cost Impact

Savings vary by workflow because agents have unequal usage frequency. Opus-tier agents (security, adversarial, architecture) tend to run longer and consume more tokens. Haiku-tier agents are often conditional and fire less frequently.

| Scenario | Estimated Savings |
|----------|------------------|
| **Typical `/review` run** (6-8 agents) | ~30-40% |
| **Plan review** (5 agents, Opus-heavy) | ~15-20% |
| **Research phase** (3-4 agents, mostly Haiku) | ~50-60% |
| **Overall weighted estimate** | **~35-40%** |

## Test Strategy

1. Run `/review` on a known diff and compare finding quality between all-Opus and three-tier
2. Run `/plan` with research phase and verify Haiku researchers return usable findings
3. Verify Sonnet supervisor correctly consolidates findings from mixed-model specialists
4. Verify correct model was used by checking agent output quality matches expected tier
5. Verify Haiku agents produce findings in the expected structured output format (severity, file:line, evidence sections)

## Risks

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Haiku produces lower-quality findings for some review agents | MEDIUM | Monitor quality in first 5 review runs; promote individual agents to Sonnet via one-line frontmatter change |
| Sonnet edge-case-reviewer misses subtle issues Opus would catch | MEDIUM | Note: adversarial-validator challenges existing claims but cannot detect absent findings. If quality drops, promote to Opus |
| Supervisor at Sonnet has reduced ability to catch false positives from lower-tier specialists | LOW | Supervisor is at Sonnet (not Haiku) — adequate for consolidation. Opus adversarial-validator provides second layer |
| Model parameter not passed in a skill spawn call (silent Opus fallback) | LOW | Grep all Task calls in skills/ during implementation to verify model parameter present |
| No automated quality regression detection | LOW | Manual monitoring initially. Future: output format validation with auto-escalation |

## Rollback Plan

Each agent's model assignment is a single YAML field change. To rollback:
1. Change `model: haiku` or `model: sonnet` back to `model: inherit` in the agent file
2. Remove the `model` parameter from the corresponding Task tool call in the skill file
3. Agent reverts to inheriting the parent model (Opus)

Rollback can be done per-agent — no need to revert all 24 at once.

## Sources

- [Qodo: Benchmarking Claude Haiku 4.5 and Sonnet 4.5 on 400 Real PRs](https://www.qodo.ai/blog/thinking-vs-thinking-benchmarking-claude-haiku-4-5-and-sonnet-4-5-on-400-real-prs/)
- [Anthropic: Models Overview](https://platform.claude.com/docs/en/about-claude/models/overview)
- [Caylent: Claude Haiku 4.5 Deep Dive — Multi-Agent Opportunity](https://caylent.com/blog/claude-haiku-4-5-deep-dive-cost-capabilities-and-the-multi-agent-opportunity)
- [Anthropic: Introducing Claude Haiku 4.5](https://www.anthropic.com/news/claude-haiku-4-5)

## Review History

**Review Date:** 2026-02-17
**Verdict:** REVISION_REQUESTED → revised → APPROVED
**Key revisions from review:**
- Promoted `config-secrets-reviewer`, `data-validation-reviewer`, `code-quality-reviewer` from Haiku to Sonnet (security-adjacent judgment, SOLID evaluation)
- Added missing affected skills: `explore/SKILL.md`, `brainstorm/SKILL.md`
- Clarified model mechanism (frontmatter = documentation, Task parameter = runtime)
- Revised savings estimate from ~48% to ~35-40% (unequal token distribution)
- Added rollback plan
- Replaced standalone MODEL_STRATEGY.md with section in existing AGENT_TEAMS_GUIDE.md
- Added structured output format validation to test strategy
