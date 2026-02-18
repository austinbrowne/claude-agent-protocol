---
name: Context Optimization
description: Reduce token usage and improve AI response quality through efficient context management. Strategies for targeted file reads, codebase maps, and avoiding context waste.
alwaysApply: false
---

# Context Optimization Guide

**Purpose:** Reduce token usage and improve AI response quality through efficient context management.

**Impact:** Proper context management can reduce costs by 30-50% while improving response accuracy.

---

## Core Principles

1. **Be surgical, not exhaustive** - Reference specific files/lines, not entire directories
2. **Summarize first** - For large files, request summaries before full reads
3. **Clear between tasks** - Don't carry irrelevant context across tasks
4. **Document architecture** - Create high-level maps to avoid repeated exploration

---

## Context Budgets

| Task Type | Target Tokens | Max Tokens | Strategy |
|-----------|---------------|------------|----------|
| **Simple bug fix** | <10k | 20k | Read only affected file |
| **Feature (small)** | <30k | 50k | Read relevant files + architecture doc |
| **Feature (large)** | <80k | 120k | Explore first, then implement |
| **Refactoring** | <50k | 100k | Read target files + tests |
| **Architecture review** | <60k | 100k | Use codebase map + selective reads |

---

## Strategies to Reduce Context Usage

### 1. Use Specific File References

**Bad (wasteful):**
```
Read all files in src/components/
```

**Good (targeted):**
```
Read src/components/UserProfile.tsx lines 45-120
```

Use search to find exact locations first, then read only the relevant sections.

### 2. Create Codebase Maps

Create a `.claude/CODEBASE_MAP.md` or similar architecture document covering:
- Tech stack summary
- Directory structure with purposes
- Key patterns (auth, database, error handling, API design)
- Common tasks (how to add endpoint, component, etc.)

Saves 5-10k tokens per task by avoiding repeated explanations.

### 3. Use Directory READMEs

Create `README.md` in each major directory explaining files, key functions, patterns, and testing approach. AI can read the README (1k tokens) instead of all files (10k tokens).

### 4. Summarize Large Files First

For files >500 lines:
1. Request summary (what it does, main functions, dependencies, gotchas)
2. Then read specific sections as needed

Savings: Summary = 500 tokens vs full file = 5k tokens.

### 5. Clear Context Between Unrelated Tasks

Use context clearing when switching to unrelated work. Auth context (10k tokens) isn't needed for payment work.

### 6. Use Search Before Reading

**Bad:** Read all TypeScript files to find the User interface

**Good:** Search for "interface User" in src/types/, then read the specific file and line range. 90% token reduction.

### 7. Batch Related Questions

**Bad:** 3 separate reads with overlapping context

**Good:** One comprehensive query covering all related questions, one targeted read.

### 8. Prefer Type Definitions Over Full Files

For TypeScript/Python projects, read type definition files (20 lines) to understand API surface instead of full implementation (200 lines).

---

## Context Optimization Checklist

Before each task:

- [ ] Do I need to read full files, or can I target specific lines?
- [ ] Should I summarize large files first?
- [ ] Can I use search to find exact locations?
- [ ] Is there a codebase map or directory README?
- [ ] Should I clear context from previous unrelated task?
- [ ] Am I batching related questions?

---

## Context Anti-Patterns

### 1. Reading Entire Directories
Search for what you need, then read the specific file.

### 2. Re-reading Same Files
Read a file once, ask all questions together.

### 3. Pasting Large Outputs
Use tools to query data directly, return summaries.

### 4. Not Using Summaries
Request summary of large files before reading specific sections.

### 5. Carrying Dead Context
Clear irrelevant context when switching tasks.

---

## Advanced: Caching Strategies

### Cache Common Queries in Docs

Create a `docs/FAQ.md` with answers to common questions (auth patterns, database query patterns, error handling patterns). Reference it instead of re-exploring each time.

### Use AI-Generated Architecture Docs

After exploration, create architecture documents for key systems. Next time, read the doc (2k tokens) instead of re-exploring (20k tokens).
