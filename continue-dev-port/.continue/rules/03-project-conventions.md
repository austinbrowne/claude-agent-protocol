---
name: Project Conventions
description: Directory structure, status indicators, confidence levels, risk flags, and code style defaults for the GODMODE protocol
alwaysApply: true
---

# Project Conventions

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `.continue/rules/` | Always-on and conditional rules (core protocol, guides, checklists) |
| `.continue/rules/agents/review/` | Review agent persona rules |
| `.continue/rules/agents/research/` | Research agent persona rules |
| `.continue/rules/agents/team/` | Team role persona rules (Lead, Implementer, Analyst) |
| `.continue/rules/guides/` | Conditional reference guides (shell, review, recovery, optimization) |
| `.continue/rules/checklists/` | Security and code review checklists |
| `.continue/rules/solutions/` | Knowledge compounding -- captured solved problems |
| `.continue/prompts/workflows/` | Workflow entry point prompts (/explore, /plan, etc.) |
| `.continue/prompts/skills/` | Invocable skill prompts |
| `.continue/prompts/templates/` | Reusable templates (plan, ADR, test strategy, etc.) |
| `docs/solutions/` | Knowledge compounding -- captured solved problems (project-level) |
| `docs/brainstorms/` | Brainstorm session records |
| `docs/plans/` | Plans (Minimal, Standard, Comprehensive) |
| `.todos/` | File-based todo tracking (committed to git) |

## Status Indicators

Use in responses:
- `READY_FOR_REVIEW` - Phase complete, awaiting feedback
- `APPROVED_NEXT_PHASE` - Cleared to continue
- `HALT_PENDING_DECISION` - Blocked on decision
- `SECURITY_SENSITIVE` - Requires security review
- `RECOVERY_MODE` - Implementation failed, evaluating options

## Confidence Levels

- `HIGH_CONFIDENCE` - Well-understood, low-risk
- `MEDIUM_CONFIDENCE` - Some uncertainty, may need iteration
- `LOW_CONFIDENCE` - Significant unknowns, discuss before proceeding

## Risk Flags

- `BREAKING_CHANGE` - May affect existing functionality
- `SECURITY_SENSITIVE` - Touches auth, data, or external APIs
- `PERFORMANCE_IMPACT` - May affect latency or resources
- `DEPENDENCY_CHANGE` - Adds/removes/upgrades dependencies

## Extended Thinking

Users can request deeper reasoning:
- "think" - standard reasoning for moderate complexity
- "think hard" - multi-step problems, security architecture, debugging
- "ultrathink" - critical architecture decisions, major refactors

The AI should suggest extended thinking for security-sensitive or high-risk changes.

## Code Style Defaults

- Write tests for new code
- Use type hints (Python) or TypeScript
- Follow existing project conventions
- Conventional commits (feat:, fix:, docs:, refactor:)

## Reference Files

| File | Purpose |
|------|---------|
| `rules/04-godmode-protocol.md` | Full protocol documentation |
| `rules/00-core-protocol.md` | Critical safety rules (always loaded) |
| `rules/guides/*.md` | Reference guides (loaded on demand) |
| `rules/checklists/*.md` | Security and code review checklists |
| `rules/agents/review/*.md` | Review agent persona definitions |
| `rules/agents/research/*.md` | Research agent persona definitions |
| `rules/agents/team/*.md` | Team role persona definitions |
| `prompts/workflows/*.md` | Workflow entry point prompts |
| `prompts/skills/*.md` | Invocable skill prompts |
| `prompts/templates/*.md` | Reusable templates |
