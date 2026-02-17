# Agent Teams Guide

**Purpose:** Reference guide for integrating Claude Code Agent Teams into the protocol. Skills reference this guide for team formation, detection, fallback, and best practices.

**Status:** Experimental — Agent Teams is a Claude Code experimental feature gated behind `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`.

**See also:** [Official Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)

---

## Detection Mechanism

Only `team-implement` uses Agent Teams. It checks for `TeamCreate` in its tool list at Step 0. If unavailable, it halts and directs to single-agent `/implement` → `start-issue`.

**CRITICAL: The main agent never acts as Team Lead.** When Agent Teams is used, the main agent spawns a dedicated Team Lead via the Task tool (`godmode:team:team-lead`). The Lead handles team creation, teammate spawning, monitoring, and completion. The main agent's context window is reserved for user interaction — not coordination bookkeeping.

All other skills (reviews, planning, research) use subagents exclusively — no detection step needed.

---

## Team vs Subagent Decision Matrix

| Factor | Use Team | Use Subagent |
|--------|----------|-------------|
| Agents need to discuss findings | Yes | — |
| Lead needs to ask agents clarifying questions | Yes | — |
| Agents should coordinate to avoid duplicate work | Yes | — |
| Fire-and-forget research query | — | Yes |
| Single focused task returning a result | — | Yes |
| Token cost sensitivity is high | — | Yes |
| Agents work on independent tasks with no interaction needed | — | Yes |

**Current skill assignments:**

| Skill | Mode | Rationale |
|-------|------|-----------|
| `team-implement` (plan input) | Team | Analyst broadcasts findings to implementers in real-time; Lead coordinates file ownership. 2-4 teammates. |
| `start-issue` (team path) | Team | Same pattern as team-implement but for complex issues. Analyst + Implementers coordinated by spawned Lead. |
| `fresh-eyes-review` | Subagent | 3-14 independent parallel reviewers. No mid-task communication needed. Coordination overhead dominates at scale. |
| `review-plan` | Subagent | 4 independent reviewers + 1 sequential validator. Same pattern as fresh-eyes. |
| `deepen-plan` | Subagent | Sequential phases (research then review) negate real-time communication benefit. |
| `triage-issues` | Subagent | Fire-and-forget planning per issue, no inter-agent discussion needed |
| `generate-plan` | Subagent | Fire-and-forget research, no inter-agent discussion needed |
| `explore` | Subagent | Fire-and-forget research |
| `start-issue` (single-agent path) | Subagent | Learnings + codebase research before implementation |

**Why only `team-implement` uses teams:** Research showed Agent Teams costs 3-7x more tokens than subagents (1.5-2x). Teams are justified only when agents need mid-task communication — implementers coordinating on shared code, analysts broadcasting discoveries to active coders. Review agents are independent: each gets a diff/plan, returns findings, done. The Supervisor consolidates post-hoc. No mid-task cross-talk needed.

---

## Team Formation Patterns

### Pattern A: Review Team — DEPRECATED

**Previously used by:** `fresh-eyes-review`, `review-plan`. **Now uses subagents instead.** Review agents are independent (zero-context, no mid-task communication). Subagent fan-out/fan-in is cheaper and simpler. Kept here for reference only.

**Structure:**
```
Lead (you) = Coordinator + Supervisor + Adversarial Validator
Teammates = Specialist reviewers (one per domain)
```

**Lead responsibilities:**
- Spawn specialist teammates with specific review prompts
- Create shared task list with review tasks
- Wait for specialists to complete and share findings
- Ask clarifying questions to specific specialists via direct message
- Challenge findings (adversarial validation) via direct message
- Consolidate into final report

**Specialist teammate responsibilities:**
- Review the diff/plan against their domain checklist
- Post findings to the task list as they're discovered
- Message other specialists when findings overlap ("Edge Case reviewer, I found a null check issue at line 45 — does this also qualify as a security concern?")
- Broadcast CRITICAL findings immediately to the whole team
- Respond to Lead's clarification requests with evidence

**Key design decision:** The Supervisor and Adversarial Validator are Lead roles, not separate teammates. The Lead can message specialists for live clarification — something separate subagents can't do. This reduces total agent count while improving quality through interactive dialogue.

**Spawn prompt template for specialist teammates:**
```
You are a [specialist type] reviewing code changes. Read `agents/review/[agent-file].md` for your full review process and philosophy.

Review this [diff/plan]:
[content]

Your review checklist:
[agent-specific criteria from agent definition file]

Instructions:
- Post findings to the task list with severity (CRITICAL/HIGH/MEDIUM/LOW)
- If you find a CRITICAL issue, broadcast it immediately to the team
- If your finding overlaps with another reviewer's domain, message them directly
- When the Lead asks you a question, respond with specific evidence from the code
- Format: [ID] severity:LEVEL file:line description

When complete, mark your task as done.
```

---

### Pattern B: Research + Review Team — DEPRECATED

**Previously used by:** `deepen-plan`. **Now uses subagents instead.** Research and review phases are sequential in practice — by the time reviewers start, research is complete. The "real-time broadcast" benefit only exists if both phases run simultaneously, which means reviewers start before research finishes. Subagent fan-out/fan-in for each phase is cheaper and simpler. Kept here for reference only.

---

### Pattern C: Plan Implementation Swarm

**Used by:** `team-implement` (plan input with high swarmability)

**Structure:**
```
Main Agent = Input loading, assessment, user approval, result presentation
Team Lead (spawned via Task tool) = Coordinator + Monitor (see agents/team/lead.md)
Teammates = Implementers (one per independent task group, see agents/team/implementer.md)
Optional: Analyst (for mixed-independence plans, see agents/team/analyst.md)
```

**When to use:** Plan has 3+ implementation tasks with high independence (70%+ swarmability score). Each implementer owns different files and can work in parallel.

**Main agent responsibilities:**
- Run swarmability assessment on plan tasks
- Present assessment to user for approval
- Spawn dedicated Team Lead via Task tool with all context
- Present Team Lead's consolidated results to user

**Team Lead responsibilities (spawned agent):**
- Create team via TeamCreate, spawn Implementer teammates with exclusive file ownership
- Optionally spawn Analyst for mixed-independence plans (40-69% swarmability)
- Monitor progress via shared task list
- Handle blockers and file conflicts
- Track completion, return consolidated summary

**Implementer teammate responsibilities:**
- Execute assigned task following the FULL protocol pipeline (see `agents/team/implementer.md`):
  1. Load task context + plan reference
  2. Search `docs/solutions/` for relevant past learnings
  3. Create living plan for their task (`.todos/{task-id}-plan.md`)
  4. Write implementation code
  5. Generate tests
  6. Run validation (lint, type-check, tests pass)
- Message Lead about blockers
- Coordinate with other Implementers about file ownership conflicts
- Adjust approach based on Analyst broadcasts (if Analyst is present)
- Mark task complete when done

**CRITICAL:** Teammates must follow the protocol. They are not shortcutting — each one executes the same quality pipeline a single agent would. The value is parallelism, not cutting corners.

**Spawn prompts:** See `skills/team-implement/SKILL.md` Step 4 for the Team Lead spawn prompt template.

---

### Pattern D: Issue Implementation Team

**Used by:** `start-issue` (team path for LARGE complexity issues)

**Structure:**
```
Main Agent = Input loading, complexity assessment, user approval, result presentation
Team Lead (spawned via Task tool) = Coordinator + Monitor (see agents/team/lead.md)
Analyst = Real-time research support (see agents/team/analyst.md)
Implementer(s) = Code + tests + validation (see agents/team/implementer.md)
```

**When to use:** Single complex issue (MEDIUM/LARGE: 3+ files, multiple acceptance criteria, some unknowns). The Analyst researches the codebase and past learnings in parallel while the Implementer codes — mid-task information exchange that subagents cannot provide.

**Main agent responsibilities:**
- Assess issue complexity
- Present assessment to user for approval
- Spawn dedicated Team Lead via Task tool with all context
- Present Team Lead's consolidated results to user

**Team Lead responsibilities (spawned agent):**
- Create team, spawn Analyst + Implementer(s) with clear file ownership
- Monitor progress and relay critical Analyst findings
- Resolve conflicts between Analyst recommendations and Implementer direction
- Return consolidated summary when complete

**Analyst responsibilities (see `agents/team/analyst.md`):**
- Search `docs/solutions/` for past learnings relevant to the issue
- Explore codebase areas being modified — identify patterns, utilities, conventions
- Broadcast findings to Implementers as discovered (not after completion)
- Respond to on-demand research requests from Implementers
- Cross-reference implementation direction against issue requirements

**Implementer responsibilities (see `agents/team/implementer.md`):**
- Implement the issue within assigned file boundaries
- Follow the full protocol pipeline (learnings, living plan, code, tests, validation)
- Adjust approach based on Analyst broadcasts
- Message Lead about blockers

**Key insight:** The Analyst provides the communication advantage that justifies teams over subagents. A fire-and-forget research subagent returns results after the implementer has already committed to an approach. An Analyst teammate broadcasts "there's an existing utility for this" while the implementer is still coding.

**Spawn prompts:** See `skills/start-issue/SKILL.md` Step 5 for the Team Lead spawn prompt template.

---

### Note: Issue Triage (not an Agent Teams pattern)

`triage-issues` uses subagents only — no Agent Teams required. Each planning subagent works on a separate issue independently (no inter-agent communication needed). After triage, each issue is implemented separately via `/implement` → `start-issue` or `team-implement` per issue. See `skills/triage-issues/SKILL.md` for details.

---

## Team Role Definitions

Implementation teams use formally defined agent roles in `agents/team/`. Each role file follows the same pattern as review and research agents (frontmatter, philosophy, process, output format, examples).

| Role | File | Purpose |
|------|------|---------|
| **Lead** | `agents/team/lead.md` | Coordination, monitoring, conflict resolution, task assignment, result synthesis |
| **Implementer** | `agents/team/implementer.md` | Code + tests + validation within file ownership boundaries |
| **Analyst** | `agents/team/analyst.md` | Parallel research support: codebase patterns, past learnings, real-time broadcasts |

Skills compose these roles into spawn prompts. The role files define the agent's philosophy, responsibilities, communication protocol, and anti-patterns. This ensures consistent behavior across different skills that use teams.

---

## Swarmability Assessment Algorithm

Used by `team-implement` to determine whether a plan's implementation tasks can be parallelized.

### Step 1: Extract Tasks

Parse the plan's "Implementation Steps" section. Each numbered step is a candidate task. Extract:
- Step description
- Affected files (from step text + "Affected Files" section)
- Dependencies (explicit "depends on" or "after step N" references)

### Step 2: Build Independence Matrix

For each pair of tasks (i, j):

| Check | Result |
|-------|--------|
| Do they modify the same files? | File overlap → partial dependency |
| Does task j depend on task i's output? | Output dependency → must serialize |
| Do they modify the same data structures, configs, or shared types? | Shared state → partial dependency |
| Are they in different modules/directories? | Module isolation → likely independent |

### Step 3: Score

```
For each task:
  - No overlap with any other task → fully independent (score: 1.0)
  - Shares files with 1+ tasks → partially dependent (score: 0.5)
  - Depends on another task's output → blocked (score: 0.0)

Swarmability score = sum(task scores) / total tasks × 100
```

### Step 4: Group Tasks

- Fully independent tasks → each gets its own teammate
- Partially dependent tasks (shared files) → group into same teammate
- Blocked tasks → serialize after their dependency completes

### Step 5: Present to User

```
AskUserQuestion:
  question: "Swarmability assessment complete. How would you like to implement?"
  header: "Swarm mode"
  options:
    - label: "Team mode (Recommended)"
      description: "Score: {N}%. {X} teammates for {Y} independent task groups, {Z} serialized tasks"
    - label: "Standard sequential"
      description: "Execute all tasks one at a time (current behavior)"
    - label: "Adjust task groupings"
      description: "I want to change which tasks are grouped together"
```

### Recommendation Thresholds

| Score | Recommendation |
|-------|---------------|
| 70%+ | Recommend team mode |
| 40-69% | Mixed — note which tasks parallelize, which serialize |
| <40% | Recommend standard sequential mode |

The user always makes the final call, regardless of score.

---

## Branch Strategy

### Swarm Plan (Pattern C)

All teammates work on the **same feature branch**. The swarmability assessment ensures minimal file overlap — tasks assigned to different teammates touch different files.

If two tasks share a file, they're either:
1. Assigned to the same teammate (serialized within that teammate)
2. Serialized across teammates (task B waits for task A)

This keeps the branch model simple: one branch, one combined diff for review at the `/review` step.

### Per-Issue Implementation

When implementing individual issues (after triage), each issue gets its own branch via the standard `start-issue` or `team-implement` flow: `feat/issue-{number}-{slug}`. Each issue is implemented and reviewed independently — one branch, one PR per issue.

---

## Shared Task List Patterns

Agent Teams provides a shared task list that all teammates can see and update. Use it for coordination:

### Implementation Teams (Patterns C, D)
```
Task list:
- [ ] Implement auth middleware (assigned: teammate-1)
- [ ] Implement user routes (assigned: teammate-2)
- [ ] Implement database migrations (assigned: teammate-3)
- [ ] Update shared types (assigned: teammate-1, after auth middleware)
```

Tasks with dependencies block until their prerequisite completes. Teammates self-claim unblocked tasks when they finish their current work.

---

## Fallback Behavior

When Agent Teams is not available, `team-implement` halts and directs the user to `/implement` → `start-issue` for single-agent implementation. All other skills use subagents exclusively and do not require Agent Teams.

---

## Best Practices

### 1. Size Tasks Appropriately
- Too small: coordination overhead exceeds benefit
- Too large: teammates work too long without check-ins
- Right size: self-contained units that produce a clear deliverable

### 2. Avoid File Conflicts
- Swarmability assessment identifies overlap before spawning
- When conflict occurs: teammates message each other to resolve
- Unresolvable conflicts escalate to Lead → user

### 3. Give Teammates Full Context
- Teammates load CLAUDE.md automatically (project conventions)
- Spawn prompts include task-specific details, affected files, plan references
- Teammates search `docs/solutions/` for past learnings (protocol pipeline)

### 4. Monitor Progress
- Lead checks shared task list for stuck tasks
- Stale task status is a known limitation — Lead nudges teammates
- If a teammate fails, Lead can spawn a replacement or handle the task

### 5. Token Cost Awareness
- Teams use significantly more tokens than subagents
- Each teammate is a full Claude Code instance with its own context window
- Teams only activate when user explicitly enables Agent Teams AND approves team formation
- For routine tasks, subagents remain the default

### 6. Handle Experimental Instability
- Agent Teams is experimental — teammates may hang, fail to message, or not shut down cleanly
- Always have fallback paths
- If team formation fails, fall back to subagent mode gracefully
- Clean up teams when done (Lead runs cleanup)

### 7. Spawn Dedicated Team Lead
- The main agent MUST NOT act as Team Lead — spawn a `godmode:team:team-lead` agent via the Task tool
- Team coordination overhead (teammate messages, task monitoring, conflict resolution) stays in the Lead's context
- The main agent's context window is preserved for user interaction and subsequent workflow steps (e.g. `/review`, `/ship`)
- The main agent handles pre-team work (input loading, assessment, user approval) and post-team work (presenting results, next steps)

---

## Model Strategy

Three-tier model assignment reduces token cost by ~35-40% while preserving quality where it matters. Each agent's definition file declares its model tier in YAML frontmatter (`model: haiku|sonnet|opus`). Skills pass the `model` parameter in Task tool calls at runtime.

### Tiers

| Tier | Model | Cost | Agent Count | Criteria |
|------|-------|------|-------------|----------|
| **Haiku** | claude-haiku-4-5 | $1/$5 per MTok | 7 | Retrieval, search, pure pattern matching |
| **Sonnet** | claude-sonnet-4-5 | $3/$15 per MTok | 12 | Judgment-based review, flow analysis, implementation |
| **Opus** | claude-opus-4-6 | $5/$25 per MTok | 5 | Deep reasoning, security, architecture, adversarial, orchestration |

### Assignments

**Haiku:** documentation-reviewer, api-contract-reviewer, dependency-reviewer, testing-adequacy-reviewer, learnings-researcher, best-practices-researcher, framework-docs-researcher

**Sonnet:** code-quality-reviewer, data-validation-reviewer, config-secrets-reviewer, error-handling-reviewer, performance-reviewer, spec-flow-reviewer, edge-case-reviewer, simplicity-reviewer, supervisor, codebase-researcher, team-implementer, team-analyst

**Opus:** security-reviewer, adversarial-validator, architecture-reviewer, concurrency-reviewer, team-lead

### How It Works

1. **Agent YAML frontmatter** (`model: haiku|sonnet|opus`) — source of truth and documentation
2. **Task tool `model` parameter** — runtime mechanism. Skills pass this when spawning agents

Both layers are needed. Frontmatter alone is NOT automatically honored — skills must explicitly pass `model` in the Task tool call. For built-in subagent types (`Explore`, `Plan`), model selection is managed internally by Claude Code — do not pass `model` for these.

### Rollback

Each agent's model is a single YAML field. To promote an agent: change `model: haiku` to `model: sonnet` in its definition file and update the corresponding Task call in the skill file. Rollback can be done per-agent — no need to revert all at once.

---

## Known Limitations

From the official Agent Teams documentation:

| Limitation | Impact | Mitigation |
|-----------|--------|------------|
| No session resumption for in-process teammates | Can't resume after crash | Lead spawns new teammates if needed |
| Task status can lag | Blocked tasks may not unblock | Lead nudges teammates manually |
| Shutdown can be slow | Teammates finish current work before stopping | Wait patiently, don't force-kill |
| One team per session | Can't run multiple teams | Clean up between teams |
| No nested teams | Teammates can't spawn their own teams | Teammates use subagents if they need sub-parallelism |
| Lead is fixed | Can't promote teammates | Design prompts with Lead as coordinator |
| Permissions set at spawn | All teammates inherit Lead's permissions | Pre-approve common operations in settings |

---

**Last Updated:** February 2026
**Referenced by:** `skills/team-implement/SKILL.md`
