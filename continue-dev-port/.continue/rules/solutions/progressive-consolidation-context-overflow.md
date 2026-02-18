---
alwaysApply: false
description: "Solution: Progressive consolidation pattern for multi-agent context overflow — file persistence as external memory when aggregating outputs from many agents"
title: Progressive Consolidation for Multi-Agent Context Overflow
category: workflow-issues
severity: high
tags: [fresh-eyes-review, supervisor, context-window, multi-agent, consolidation, file-persistence, compound-engineering]
date: 2026-02-17
---

# Progressive Consolidation for Multi-Agent Context Overflow

## Problem

When a multi-agent review ran with many specialists (10-14 agents), the **supervisor agent's context overflowed** and the session was lost. The root cause: all specialist outputs were inlined into the supervisor's prompt as a single concatenated block. With verbose specialist output (especially when agents read files directly and include code snippets), this exceeded the supervisor's context window.

The adversarial validator had the same exposure — it received all specialist outputs + the supervisor report inline.

## Root Cause

The orchestrator collected specialist return values (text responses) and passed them **all inline** in the supervisor's prompt. No intermediary storage existed. The system was designed for small reviews (3-5 agents with brief output) and didn't account for full reviews with 10+ verbose agents.

## Solution

**Progressive consolidation with file persistence.** Instead of inlining all specialist outputs into the supervisor's prompt, write outputs to files and have the supervisor read them in batches, maintaining a working file on disk as external memory.

### Architecture

```
Phase 1:   Specialists run in parallel (unchanged)
Phase 1.5: Orchestrator writes each output to /tmp/review-findings/{agent}.md
           Creates manifest with batch groupings
Phase 2:   Supervisor reads manifest, processes files in batches of 2-3
           Writes accumulated findings to working file after each batch
           Final pass produces consolidated report
Phase 3:   Adversarial Validator reads consolidated report from file
           Selectively reads specialist files for spot-checks
```

### Key Design Decisions

**Why files, not inline prompts?** The supervisor is a sequential agent — its only input is its prompt. Inlining 14 agent outputs overflows that prompt. Files let the supervisor read on demand, keeping each turn's context manageable.

**Why batches of 2-3?** One-at-a-time means too many turns (14+ cycles). All-at-once recreates the overflow. Batches of 2-3 balance context usage vs. turn count. Related agents are batched together (security + config-secrets, code-quality + error-handling) to improve within-batch deduplication.

**Why a working file?** When automatic context summarization compresses earlier turns, the supervisor loses detail from previous batches. The working file persists ALL accumulated findings on disk. The supervisor re-reads it each batch to get full fidelity — the file is the source of truth, not conversation memory.

**Why doesn't the adversarial validator need batching?** The consolidated report (supervisor output) is compact — deduplicated findings with structured format. It fits in context for a single read. The AV only selectively reads specialist files when it needs to verify a specific claim (false positive removal, severity downgrade), not all of them.

## Key Insight — Compound Engineering Pattern

**File state as external memory for long-running agents.** When an agent's task requires processing more data than fits in its context window, persist intermediate results to files and re-read them each turn. Automatic summarization becomes harmless because the ground truth is on disk, not in conversation memory. This is the same pattern as state-aware menu transitions — detect state from files, not from context — applied to agent processing rather than workflow routing.

The working file pattern:
1. Agent reads its working file to load accumulated state
2. Agent processes a new batch of input
3. Agent writes the updated working file (append, not replace)
4. Context summarization compresses the turn — doesn't matter, file has everything
5. Next turn: re-read working file, process next batch

This pattern applies to any multi-agent consolidation where the aggregator might overflow: review supervisors, team lead progress tracking, research synthesis across many sources.

## Prevention

When designing multi-agent systems where an aggregator processes output from many agents:
1. **Never inline all agent outputs into the aggregator's prompt.** Write to files, pass file paths.
2. **Use a working file for progressive processing.** The aggregator persists intermediate results after each batch so context summarization doesn't cause information loss.
3. **Batch related agents together.** Cross-domain deduplication is more accurate within a batch than across batches.
4. **Re-read the working file each batch.** Never rely on memory of previous batches — the file is the source of truth.
5. **Design the aggregator's output to be compact.** Downstream consumers (adversarial validator, fix agents) should be able to work from the consolidated output without re-reading all raw inputs.
