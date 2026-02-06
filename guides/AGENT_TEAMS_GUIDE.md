# Agent Teams Guide

**Purpose:** Reference guide for integrating Claude Code Agent Teams into the protocol. Skills reference this guide for team formation, detection, fallback, and best practices.

**Status:** Experimental — Agent Teams is a Claude Code experimental feature gated behind `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`.

**See also:** [Official Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)

---

## Detection Mechanism

Every skill that supports team mode checks for availability at its start:

```
Step 0: Detect Execution Mode

CRITICAL: Check your tool list RIGHT NOW. Do NOT use conversation history to decide.
Each skill invocation re-evaluates independently.

Check if the TeammateTool is available in your tool list.
  → Available: follow [TEAM MODE] instructions throughout this skill
  → Not available: follow [SUBAGENT MODE] instructions (existing Task tool behavior)
```

This is prompt-level detection. No config files, no environment variable checks. The agent inspects its own available tools **at invocation time**.

**Re-evaluate every time.** If you used subagent mode earlier in this conversation, that does NOT mean you should use subagent mode now. Check your tool list fresh. Conversation history is not a valid signal for tool availability.

**Fallback is mandatory.** Agent Teams is experimental and may not be available. Every skill MUST have a working `[SUBAGENT MODE]` path that produces identical output.

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
| `fresh-eyes-review` | Team | Specialists can cross-validate, Lead can interrogate |
| `review-plan` | Team | Reviewers can debate trade-offs, Lead challenges live |
| `deepen-plan` | Team | Research findings inform review focus in real-time |
| `swarm-plan` | Team | Teammates coordinate on shared implementation |
| `triage-issues` | Subagent | Fire-and-forget planning per issue, no inter-agent discussion needed |
| `generate-plan` | Subagent | Fire-and-forget research, no inter-agent discussion needed |
| `explore` | Subagent | Fire-and-forget research |
| `start-issue` | Subagent | Single learnings query |

---

## Team Formation Patterns

### Pattern A: Review Team

**Used by:** `fresh-eyes-review`, `review-plan`

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

### Pattern B: Research + Review Team

**Used by:** `deepen-plan`

**Structure:**
```
Lead (you) = Coordinator + Consolidator
Research Teammates = Codebase, Learnings, Best Practices, Framework Docs
Review Teammates = Architecture, Simplicity, Security, Performance, Edge Case, Spec-Flow
```

**Lead responsibilities:**
- Spawn all teammates (research + review) with specific prompts
- Create shared task list for research and review phases
- Monitor cross-team communication
- Synthesize all findings into plan annotations

**Research teammate responsibilities:**
- Execute assigned research against their domain
- Broadcast relevant findings as discovered (don't wait until done)
- Respond to reviewer requests for deeper investigation
- Example broadcast: "Codebase Researcher here — found an existing auth middleware pattern at `src/middleware/auth.ts` that uses JWT validation. Relevant to anyone reviewing auth-related plan sections."

**Review teammate responsibilities:**
- Review plan against domain criteria
- Consume research findings as they arrive — adjust focus accordingly
- Request specific research via direct message: "Learnings Researcher, do we have any past solutions for handling rate limiting? The plan doesn't address it."
- Message other reviewers about overlapping concerns

**Spawn prompt template for research teammates:**
```
You are a [research type] researching the codebase to support plan enrichment. Read `agents/research/[agent-file].md` for your full research process.

Research target:
[plan content / section assignments]

Instructions:
- As you discover relevant findings, broadcast them to the team immediately
- Don't wait until you're done — share as you go so reviewers can use your findings
- If a reviewer asks you for deeper research on a topic, prioritize that
- Post your final summary to the task list when complete
- Mark your task as done when finished
```

---

### Pattern C: Implementation Swarm

**Used by:** `swarm-plan`

**Structure:**
```
Lead (you) = Coordinator + Monitor
Teammates = Implementers (one per independent task group)
```

**Lead responsibilities:**
- Analyze plan tasks for independence (swarmability assessment)
- Present assessment to user for approval
- Spawn implementation teammates, each assigned a task group
- Monitor progress via shared task list
- Handle blockers — reassign work if a teammate gets stuck
- Track completion, present summary when all done

**Implementer teammate responsibilities:**
- Execute assigned task following the FULL protocol pipeline:
  1. Load task context + plan reference
  2. Search `docs/solutions/` for relevant past learnings
  3. Create living plan for their task (`.todos/{task-id}-plan.md`)
  4. Write implementation code
  5. Generate tests
  6. Run validation (lint, type-check, tests pass)
- Message Lead about blockers
- Message other teammates about minor file conflicts
- Mark task complete when done

**CRITICAL:** Teammates must follow the protocol. They are not shortcutting — each one executes the same quality pipeline a single agent would. The value is parallelism, not cutting corners.

**Spawn prompt template for implementer teammates:**
```
You are implementing a task from an approved plan. Follow the FULL protocol pipeline.

Your assigned task:
[task description from plan]

Affected files:
[file list]

Plan reference:
[plan file path]

Protocol pipeline (follow ALL steps):
1. Search docs/solutions/ for past learnings relevant to this task
2. Create a living plan at .todos/[task-id]-plan.md
3. Implement the code changes
4. Generate tests (happy path + edge cases + error conditions)
5. Run validation: lint, type-check, all tests pass

Rules:
- Do NOT modify files outside your assigned list unless absolutely necessary
- If you need to modify a shared file, message the Lead first
- If you discover a blocker, message the Lead immediately
- When done, mark your task as complete and message the Lead with a summary

Project context:
- Read CLAUDE.md for project conventions
- Check docs/solutions/ for past learnings before writing code
- Follow existing patterns in the codebase
```

---

### Note: Issue Triage (not an Agent Teams pattern)

`triage-issues` uses subagents only — no Agent Teams required. Each planning subagent works on a separate issue independently (no inter-agent communication needed). After triage, each issue is implemented separately via `/implement` → `start-issue` or `swarm-plan` per issue. See `skills/triage-issues/SKILL.md` for details.

---

## Swarmability Assessment Algorithm

Used by `swarm-plan` to determine whether a plan's implementation tasks can be parallelized.

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

When implementing individual issues (after triage), each issue gets its own branch via the standard `start-issue` or `swarm-plan` flow: `feat/issue-{number}-{slug}`. Each issue is implemented and reviewed independently — one branch, one PR per issue.

---

## Shared Task List Patterns

Agent Teams provides a shared task list that all teammates can see and update. Use it for coordination:

### Review Teams (Patterns A, B)
```
Task list:
- [ ] Security review of diff (assigned: security-reviewer)
- [ ] Code quality review (assigned: code-quality-reviewer)
- [ ] Edge case review (assigned: edge-case-reviewer)
- [ ] Consolidate findings (assigned: lead, blocked by above)
- [ ] Adversarial validation (assigned: lead, blocked by consolidation)
```

### Implementation Swarms (Patterns C, D)
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

When Agent Teams is not available, skills fall back to `[SUBAGENT MODE]`:

- **Review skills:** Launch specialists as parallel Task tool calls (existing behavior). Supervisor and Adversarial Validator run as sequential Task tool calls. No inter-agent communication.
- **Implementation skills:** Execute tasks sequentially via existing `start-issue` skill. No parallelization.

The output format is **identical** regardless of execution mode. Users see the same review reports, the same plan annotations, the same implementation results.

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
**Referenced by:** `skills/fresh-eyes-review/SKILL.md`, `skills/review-plan/SKILL.md`, `skills/deepen-plan/SKILL.md`, `skills/swarm-plan/SKILL.md`, `skills/triage-issues/SKILL.md`
