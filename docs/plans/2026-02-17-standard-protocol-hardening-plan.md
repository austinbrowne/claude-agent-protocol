---
type: standard
title: "Protocol Hardening + Fresh-Eyes Review Optimization"
date: 2026-02-17
status: draft
security_sensitive: false
priority: high
---

# Plan: Protocol Hardening + Fresh-Eyes Review Optimization

## Problem

Two related problems:

### A. Advisory-Only Enforcement

The GODMODE protocol currently relies almost entirely on advisory CLAUDE.md instructions for enforcement. Claude Code provides deterministic enforcement mechanisms — hooks, permissions, sandbox settings, environment variables — that are completely unused. This creates several issues:

1. **CLAUDE.md is 234 lines** (official recommendation: <150). Long files cause Claude to deprioritize or skip instructions.
2. **settings.json has 1 setting** (`alwaysThinkingEnabled`). The full schema supports permissions, hooks, env vars, sandbox, attribution, and more.
3. **No hooks configured.** Critical rules like "review before commit" and "don't modify protected files" are advisory only — they can be ignored or forgotten, especially after context compaction.
4. **No permission rules.** Every tool call goes through default behavior instead of pre-approved or pre-denied patterns.
5. **No compaction preservation.** When context compacts, critical protocol state and safety rules may be lost.
6. **Version inconsistency.** GODMODE.md says 5.3.0, QUICK_START.md says 5.4.0, git says 5.7.0.

### B. Fresh-Eyes Review Token Waste and Detail Loss

The 14-agent fresh-eyes review system has significant token inefficiency and context overflow risk:

7. **Diff duplicated N times in main context.** The diff content (~15K tokens for a 500-line change) is inlined into each specialist's Task prompt. With 7 agents, that's 7 copies of the diff stored in the main agent's context as Task tool call arguments. A full 14-agent review wastes ~195K tokens on diff duplication alone.
8. **Progressive consolidation documented but not implemented.** The solution doc (`docs/solutions/workflow-issues/progressive-consolidation-context-overflow-20260217.md`) describes the file-based batched processing pattern, but the SKILL.md still inlines all specialist outputs into the Supervisor prompt — the very pattern that caused context overflow.
9. **No output constraints on specialists.** Agents return variable-length prose with preambles restating their philosophy. No token budget, no max findings count. Verbose agents bloat the consolidation phase.
10. **Findings exist only in conversation context.** After review, findings live in the main agent's context. Context compaction can lose detail. Fix agents rely on context for finding details. No persistent artifact for `/ship` to reference.
11. **Re-review re-runs everything from scratch.** After fixing 2 findings, the entire agent roster runs again on the full diff. No incremental mode — same cost whether fixing 1 finding or 20.

## Goals

- Reduce CLAUDE.md to <150 lines using @import syntax for modular content
- Configure deterministic enforcement via hooks for the 3-5 most critical rules
- Set up permission allow/deny patterns for common operations
- Add environment variable tuning for optimal Claude Code behavior
- Close the /loop worker file protection loophole
- Fix version number inconsistency across all files
- Reduce fresh-eyes review token cost by ~60% through diff deduplication and output optimization
- Implement progressive consolidation to prevent Supervisor context overflow
- Persist review findings to files so they survive context compaction
- Add incremental re-review mode to reduce cost of fix-and-re-review cycles

## Solution

Two workstreams:

**Workstream A (Steps 1-8): Protocol Hardening.** Restructure CLAUDE.md into a lean core file that @imports modular reference files. Configure settings.json with permissions, hooks, and environment variables. Priority: enforce the rules that matter most when advisory instructions fail.

**Workstream B (Steps 9-13): Fresh-Eyes Review Optimization.** Remove diff duplication from specialist prompts, implement progressive consolidation for the Supervisor, enforce compact output format, persist findings to files, and add incremental re-review. Priority: reduce token cost by ~60% while improving detail preservation.

## Technical Approach

### Protocol Hardening

Claude Code's `@path/to/file` syntax in CLAUDE.md allows modular organization. The imported files are loaded alongside CLAUDE.md but are separate documents — this keeps the core file lean while preserving all content. Hooks run as shell commands or LLM prompts at deterministic lifecycle points and cannot be skipped by the model.

**Key design decisions:**
- Use `PreToolUse` hooks for preventing dangerous operations (not `PostToolUse` which runs after)
- Use `Stop` hook for review-before-ship enforcement
- Use `UserPromptSubmit` hook for context priming (reminder of compacted state)
- Permission rules use `allow` for common safe operations, `ask` for destructive ones
- Keep hooks lightweight — shell commands that check conditions and return exit codes

### Fresh-Eyes Review Optimization

The core insight: **the diff is the largest token cost in every review, and it's currently duplicated into every specialist's spawn prompt.** Each Task tool call stores the full prompt (including inlined diff) in the main agent's context. With 7-14 specialists, this means 7-14 copies of the diff consuming main context.

**Key design decisions:**
- Specialists read diff from `/tmp/review-diff.txt` instead of receiving it inline. Permission rule `Read(/tmp/review-*)` (from Step 3) eliminates the mobile permission prompt issue that originally motivated inlining. The diff is written once, read N times — one copy in main context, not N.
- Progressive consolidation (Phase 1.5 + batched Phase 2) implements the pattern documented in `docs/solutions/workflow-issues/progressive-consolidation-context-overflow-20260217.md`. Specialist outputs are written to files; Supervisor reads in batches of 3-4 with a working file for accumulated state.
- Compact output format with explicit constraints: max 8 findings per specialist, one-block-per-finding structure, no preamble/philosophy restatement. ~50% output size reduction.
- Full review report persisted to `.todos/review-report.md` alongside verdict marker. Survives context compaction. Fix agents and `/ship` read from file, not conversation context.
- Incremental re-review generates a delta diff (changes since last review), only runs agents relevant to the delta, and skips agents that had zero findings initially.

## Implementation Steps

- [ ] **Step 1: Create modular CLAUDE.md import files**
  - Create `guides/AI_BLIND_SPOTS.md` — extract AI blind spots section (edge cases, security vulns, error handling, performance)
  - Create `guides/WORKFLOW_REFERENCE.md` — extract workflow commands table, quick workflows, individual skills catalog
  - Create `guides/PROJECT_CONVENTIONS.md` — extract directory structure, status indicators, confidence levels, risk flags, code style defaults
  - Files: `guides/AI_BLIND_SPOTS.md` (new), `guides/WORKFLOW_REFERENCE.md` (new), `guides/PROJECT_CONVENTIONS.md` (new)

- [ ] **Step 2: Restructure CLAUDE.md to <150 lines**
  - Keep inline: Communication Style, Core Principles table, Do NOT list (critical safety — must be highest priority)
  - Replace sections with @imports: `@guides/AI_BLIND_SPOTS.md`, `@guides/WORKFLOW_REFERENCE.md`, `@guides/PROJECT_CONVENTIONS.md`
  - Add @import for existing files: `@QUICK_START.md` (replaces duplicated reference table)
  - Target: ~100-120 lines core + imports
  - Files: `CLAUDE.md`

- [ ] **Step 3: Configure permissions in settings.json**
  - `allow`: Common safe operations that currently prompt unnecessarily
    - `Bash(git status)`, `Bash(git diff *)`, `Bash(git log *)`, `Bash(git branch *)` — read-only git
    - `Bash(gh issue view *)`, `Bash(gh issue list *)`, `Bash(gh pr view *)` — read-only GitHub
    - `Bash(npm test *)`, `Bash(npm run lint *)`, `Bash(npm run build *)` — test/lint/build
    - `Bash(npx tsc *)` — type checking
    - `Read(*)` — all file reads (includes `/tmp/review-*` needed by Step 9's diff-from-file pattern)
  - `deny`: Operations that should never happen
    - `Bash(rm -rf *)` — prevent recursive force delete
    - `Bash(git push --force *)` — prevent force push
    - `Bash(git reset --hard *)` — prevent hard reset
  - Files: `settings.json`

- [ ] **Step 4: Configure hooks in settings.json**
  - **Hook 1 — Protected file guard** (`PreToolUse` on `Edit` and `Write`):
    Shell script that checks if the target file is in the protected set (`commands/*.md`, `agents/*.md`, `skills/*/SKILL.md`, `guides/*.md`, `templates/*.md`, `AI_CODING_AGENT_GODMODE.md`, `CLAUDE.md`, `QUICK_START.md`, `settings.json`). Returns `{"decision": "block", "reason": "..."}` if a /loop worker or subagent attempts to modify protocol files. Only blocks when `CLAUDE_LOOP_WORKER=1` env var is set (set by /loop worker prompt).
    Files: `hooks/protect-protocol-files.sh` (new), `settings.json`

  - **Hook 2 — Review-before-commit gate** (`PreToolUse` on `Bash` matching `git commit`):
    Shell script that checks for `.todos/review-verdict.md` (the existing marker written by fresh-eyes-review). If absent or verdict is `BLOCK`, blocks the commit with: "Run /review before committing. Set SKIP_REVIEW=1 to override." Aligns with existing pattern already used by `/ship` (Step 0) and `fresh-eyes-review` (Step 6).
    Files: `hooks/review-gate.sh` (new), `settings.json`

  - **Hook 3 — Compaction preservation** (`PreCompact`):
    LLM prompt hook that reminds Claude to preserve critical state: current task, protocol phase, and any pending gates. Uses `type: "prompt"` with a message like: "Before compaction, ensure you note: (1) current workflow step, (2) any pending AskUserQuestion gates, (3) whether fresh-eyes review has been completed."
    Files: `settings.json`

  - **Hook 4 — Session start primer** (`SessionStart`):
    Simple hook that checks for stale state files (`.claude/loop-context.md` with status: running, stale `.todos/` plans) and warns about them.
    Files: `hooks/session-start.sh` (new), `settings.json`

- [ ] **Step 5: Configure environment variables in settings.json**
  - `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE: "80"` — compact at 80% context (default is later, this gives more headroom)
  - `CLAUDE_CODE_MAX_TURN_OUTPUT_TOKENS: "16000"` — prevent truncated outputs on complex analysis
  - Files: `settings.json`

- [ ] **Step 6: Fix version numbers**
  - Update all version references to `5.8.0-experimental` (next minor bump from current 5.7.0)
  - Files: `AI_CODING_AGENT_GODMODE.md`, `QUICK_START.md`

- [ ] **Step 7: Update /loop worker prompt for file protection**
  - Add `CLAUDE_LOOP_WORKER=1` env var to /loop worker subagent spawns so the protected file hook can identify them
  - Add explicit protected file list to worker prompt as belt-and-suspenders (advisory + deterministic)
  - Files: `commands/loop.md`

- [ ] **Step 8: Verify review marker integration**
  - Verify `fresh-eyes-review` already writes `.todos/review-verdict.md` (it does — Step 6 of skill)
  - Verify `/ship` already reads it (it does — Step 0 of ship command)
  - Hook 2 from Step 4 completes the enforcement chain: advisory marker → deterministic gate
  - No skill file changes needed — the hook bridges the existing pattern to deterministic enforcement
  - Files: (none — hook in Step 4 handles this)

### Workstream B: Fresh-Eyes Review Optimization

- [ ] **Step 9: Remove diff inlining from specialist prompts**
  - **Current behavior:** Orchestrator reads `/tmp/review-diff.txt`, then inlines the full diff content into each specialist's Task prompt under `CODE CHANGES TO REVIEW:`. Each Task call (prompt included) is stored in main agent context.
  - **New behavior:** Specialist prompts instruct agents to `Read /tmp/review-diff.txt` as their first action. The diff content is NOT in the prompt — agents read it from file.
  - **Permission dependency:** Step 3 adds `Read(/tmp/review-*)` to the allow list, eliminating the mobile permission prompt issue that originally motivated inlining. Each agent's Read call hits the allow rule → no prompt.
  - **Update agent prompt template** in `skills/fresh-eyes-review/SKILL.md`:
    - Remove `CODE CHANGES TO REVIEW: [inline content]` block from template
    - Replace with: `Read /tmp/review-diff.txt to get the code changes to review.`
    - Update CRITICAL RULES: allow `Read` tool for `/tmp/review-*` files only, keep ban on all other tools
    - Keep inlining the agent definition (small, ~80 lines) — only the diff moves to file
  - **Token savings estimate:** For a 500-line diff (~15K tokens), 7-agent review saves ~90K tokens. 14-agent review saves ~195K tokens. Main context reduction: ~40-60%.
  - Files: `skills/fresh-eyes-review/SKILL.md`

- [ ] **Step 10: Implement progressive consolidation (Phase 1.5 + batched Phase 2)**
  - **Current behavior:** All specialist Task return values are concatenated and inlined into the Supervisor's prompt. For a full review (9+ specialists with verbose output), this overflows the Supervisor's context window — the exact problem documented in `docs/solutions/workflow-issues/progressive-consolidation-context-overflow-20260217.md`.
  - **New behavior — Phase 1.5 (after specialists complete, before Supervisor):**
    - Orchestrator writes each specialist's output to `/tmp/review-findings/{agent-name}.md`
    - Creates manifest file `/tmp/review-findings/manifest.md` listing all finding files with batch groupings
    - Batches group related agents: (security + config-secrets), (code-quality + error-handling), (edge-case + data-validation), (performance + concurrency), (remaining agents)
  - **New behavior — Phase 2 (Supervisor):**
    - Supervisor prompt includes manifest path, NOT specialist outputs
    - Supervisor reads manifest, then processes finding files in batches of 3-4
    - After each batch: writes accumulated findings to working file `/tmp/review-findings/consolidated.md`
    - Re-reads working file at start of each batch (file is ground truth, not conversation memory)
    - Final pass: produces consolidated report from working file
  - **New behavior — Phase 3 (Adversarial Validator):**
    - Reads consolidated report from `/tmp/review-findings/consolidated.md`
    - Selectively reads individual specialist files for spot-checks on challenged findings
    - Does NOT receive all specialist outputs inline
  - Files: `skills/fresh-eyes-review/SKILL.md`

- [ ] **Step 11: Enforce compact output format for specialists**
  - **Current behavior:** Agent prompt says "Report findings with severity (CRITICAL, HIGH, MEDIUM, LOW). Include file:line references and specific fixes." No format constraints. Agents return variable-length prose, often restating their philosophy and methodology before findings.
  - **New output format constraints added to agent prompt template:**
    ```
    OUTPUT RULES:
    - Start DIRECTLY with findings. No preamble, philosophy, or methodology description.
    - Maximum 8 findings. If you find more, keep only the highest severity.
    - One block per finding, exact format:

    [ID] SEVERITY: Brief description — file:line
      Evidence: code snippet or pattern (1-2 lines max)
      Fix: specific remediation (1 line)

    - If no findings in your domain, return exactly: NO_FINDINGS
    - Do NOT include passed checks, summaries, or recommendations sections.
    ```
  - **Rationale:** Current agent outputs average 100-400 tokens. With constraints, expect 50-200 tokens. The passed checks/summary/recommendations sections add bulk without decision value — the Supervisor handles prioritization.
  - **Agent definition files unchanged** — the output format in agent definitions stays as documentation. The prompt template in the SKILL.md adds the runtime constraints. This keeps agent definitions reusable across contexts (plan-review, security-review, etc.) while the skill enforces tight format for the review-specific context.
  - Files: `skills/fresh-eyes-review/SKILL.md`

- [ ] **Step 12: Persist full review report to file**
  - **Current behavior:** Verdict marker (`.todos/review-verdict.md`) stores verdict/timestamp/branch but NOT findings. The full review report (findings, todo specs, agent roster) exists only in conversation context. Context compaction can lose detail.
  - **New behavior:** After Phase 3 (Adversarial Validation), orchestrator writes full consolidated report to `.todos/review-report.md`:
    ```markdown
    ---
    verdict: APPROVED_WITH_NOTES
    timestamp: 2026-02-17T14:30:00
    branch: feat/user-auth
    agents: [security-reviewer, code-quality-reviewer, edge-case-reviewer, performance-reviewer]
    findings_total: 5
    findings_critical: 0
    findings_high: 1
    ---

    # Review Report

    ## MUST FIX
    [CONS-001] HIGH: Missing null check — src/api/users.ts:45
      Fix: Add guard clause | Acceptance: Tests pass with null input

    ## SHOULD FIX
    [CONS-002] MEDIUM: ...

    ## TODO SPECIFICATIONS
    - File: src/api/users.ts | Lines: 45-48 | Action: Add null guard | Reason: CONS-001
    ```
  - **Consumers:**
    - Fix subagents read finding details from file (not from context) — more reliable
    - `/ship` reads YAML frontmatter for commit message enrichment (finding counts, agent roster)
    - Next review run can diff against previous report to detect regressions
  - **Overwrites on each review run** (same as verdict marker)
  - Files: `skills/fresh-eyes-review/SKILL.md`

- [ ] **Step 13: Add incremental re-review mode**
  - **Current behavior:** Re-running review after fixes re-generates the full diff, re-runs the full agent roster, re-processes from scratch. Same cost as the initial review.
  - **New behavior — when re-reviewing after fixes:**
    1. Generate delta diff: `git diff --staged` compared against the diff at initial review time (stored at `/tmp/review-diff-baseline.txt` from Step 9)
    2. Run trigger detection on the delta only — typically triggers fewer conditional agents
    3. Only run specialists whose domain is affected by the delta (e.g., if fix was a null check, run edge-case + code-quality, skip security/performance/API)
    4. Always re-run Security Reviewer (mandatory, cheap insurance)
    5. Skip agents that had `NO_FINDINGS` in the initial run AND whose trigger patterns don't match the delta
    6. Supervisor receives: previous consolidated report (from file) + new specialist outputs. Merges, checking that previous findings are resolved and no new ones introduced.
  - **Trigger:** Re-review is incremental when `.todos/review-report.md` exists with same branch name AND `/tmp/review-diff-baseline.txt` exists. Otherwise, full review.
  - **Token savings estimate:** Typical re-review after fixing 2-3 findings runs 3-4 agents instead of 7-14. ~60-70% cost reduction on re-review cycles.
  - **Implementation note:** Save the baseline diff during Step 9's diff generation:
    ```bash
    cp /tmp/review-diff.txt /tmp/review-diff-baseline.txt
    ```
  - Files: `skills/fresh-eyes-review/SKILL.md`

## Affected Files

### New Files
- `guides/AI_BLIND_SPOTS.md` — Extracted AI blind spots content
- `guides/WORKFLOW_REFERENCE.md` — Extracted workflow and skills reference
- `guides/PROJECT_CONVENTIONS.md` — Extracted conventions, status indicators, code style
- `hooks/protect-protocol-files.sh` — Protected file guard script
- `hooks/review-gate.sh` — Review-before-commit gate script
- `hooks/session-start.sh` — Session start state checker

### Modified Files
- `CLAUDE.md` — Restructured with @imports, reduced to <150 lines
- `settings.json` — Permissions (including `Read(/tmp/review-*)`), hooks, environment variables
- `AI_CODING_AGENT_GODMODE.md` — Version bump
- `QUICK_START.md` — Version bump
- `commands/loop.md` — Worker env var for file protection
- `skills/fresh-eyes-review/SKILL.md` — Major rewrite: diff-from-file, Phase 1.5 progressive consolidation, compact output format, finding persistence, incremental re-review
- `guides/FRESH_EYES_REVIEW.md` — Update Phase 2/3 descriptions to match new file-based consolidation

## Acceptance Criteria

### Workstream A: Protocol Hardening
- [ ] CLAUDE.md is under 150 lines (excluding @imports)
- [ ] All @imported files exist and contain the extracted content
- [ ] settings.json has permission allow/deny rules configured
- [ ] Protected file hook blocks writes to protocol files when CLAUDE_LOOP_WORKER=1
- [ ] Review gate hook blocks `git commit` when `.todos/review-verdict.md` is absent or verdict is BLOCK
- [ ] PreCompact hook fires with preservation prompt
- [ ] Session start hook detects stale loop-context.md
- [ ] Environment variables are set in settings.json
- [ ] Version numbers are consistent across all files
- [ ] All existing workflows still function (no regressions from restructuring)

### Workstream B: Fresh-Eyes Review Optimization
- [ ] Specialist prompts do NOT contain inline diff content — agents read from `/tmp/review-diff.txt`
- [ ] `Read(/tmp/review-*)` is in the permission allow list (no prompts on mobile)
- [ ] Phase 1.5 writes specialist outputs to `/tmp/review-findings/{agent-name}.md`
- [ ] Supervisor reads findings in batches from manifest, writes to working file
- [ ] Adversarial Validator reads from consolidated file, not inline
- [ ] Specialist output follows compact format (no preamble, max 8 findings, `NO_FINDINGS` for empty)
- [ ] Full review report written to `.todos/review-report.md` with YAML frontmatter
- [ ] Re-review after fixes uses incremental mode (delta diff, reduced agent roster)
- [ ] Fix subagents read finding details from `.todos/review-report.md`, not conversation context
- [ ] Review still produces correct verdicts (no accuracy regression)

## Test Strategy

### Workstream A
- **Hook testing:** Manually trigger each hook by performing the gated action and verifying the hook fires
  - Try to edit a protected file with CLAUDE_LOOP_WORKER=1 → should block
  - Try to commit without `.todos/review-verdict.md` → should block
  - Try to commit with verdict=BLOCK → should block
  - Try to commit with verdict=APPROVED → should allow
  - Start a new session with stale loop-context.md → should warn
- **CLAUDE.md validation:** Verify @imports resolve correctly by starting a new Claude Code session and checking that imported content appears in context
- **Permission testing:** Verify allowed commands execute without prompting, denied commands are blocked
- **Regression testing:** Run a simple /explore → /plan workflow to verify no broken references

### Workstream B
- **Diff deduplication test:** Run a full review, check main context does not contain duplicate diff content. Verify specialists successfully read diff from file.
- **Progressive consolidation test:** Run a full review (8+ agents), verify Supervisor processes in batches (check for `/tmp/review-findings/` directory with individual agent files + manifest + consolidated working file)
- **Compact output test:** Verify specialist outputs start directly with findings (no preamble). Verify `NO_FINDINGS` returned when nothing found. Verify max 8 findings enforced.
- **Finding persistence test:** After review, verify `.todos/review-report.md` exists with correct YAML frontmatter and all findings. Verify content matches what was presented to user.
- **Incremental re-review test:** Fix one finding, re-run review. Verify fewer agents are triggered. Verify delta diff is generated. Verify previous findings are checked for resolution.
- **Accuracy regression test:** Run full review on a known-bad diff (with intentional SQL injection + null handling gaps). Verify all expected findings still appear. Compare finding count against a baseline.

## Security Review

- [ ] N/A — not security-sensitive (configuration changes only, no auth/data/APIs)

## Past Learnings Applied

- `docs/solutions/workflow-issues/progressive-consolidation-context-overflow-20260217.md` — Context overflow during full reviews. Both the compaction preservation hook (Step 4) and progressive consolidation implementation (Step 10) directly address this. The solution doc described the architecture; Step 10 implements it.
- Protocol loopholes identified during review session: advisory-only enforcement, unprotected protocol files, missing version consistency.
- Research finding: structured output compresses agent outputs by ~50% vs prose narratives. Applied in Step 11.
- Research finding: diff deduplication in fan-out patterns saves N×diff_size tokens. Applied in Step 9.

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| @import syntax not working as expected | Low | Medium | Test with a simple import first before restructuring everything |
| Hooks blocking legitimate operations | Medium | Medium | All hooks have override env vars (SKIP_REVIEW, etc.) |
| Settings.json format errors breaking Claude Code | Low | High | Validate JSON before saving; keep backup of original |
| /loop workers ignoring CLAUDE_LOOP_WORKER env var | Low | Low | Belt-and-suspenders: hook + advisory prompt rules |
| Specialists fail to read diff from file (Step 9) | Low | High | If Read fails, fall back to inline. Check first specialist's output before launching remaining. Permission rule should prevent this. |
| Progressive consolidation loses findings between batches | Low | High | Working file is append-only ground truth. Supervisor re-reads full file each batch. Test with 14-agent review. |
| Compact output format causes agents to drop valid findings | Medium | Medium | Max 8 findings is generous (typical is 2-5). Monitor for truncation across first 5-10 real reviews. |
| Incremental re-review misses regression from fix | Low | Medium | Security Reviewer always re-runs (mandatory). Supervisor compares against previous report. If unsure, user can force full re-review. |
| /loop command's review worker uses different architecture | Low | Medium | /loop uses Agent Teams for review, standard /review uses Task subagents. Changes to SKILL.md need to be reflected in loop.md review worker prompt. Document the divergence. |
