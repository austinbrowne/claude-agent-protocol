---
name: workflows:learn
description: "Knowledge capture — save solved problems as searchable, reusable solution docs"
---

# /learn — Knowledge Capture

**Workflow command.** Captures solved problems, gotchas, and insights as searchable solution documents in `docs/solutions/`.

---

## Auto-Trigger Detection

Claude should proactively suggest `/learn` when detecting these phrases in conversation:

- "the trick was" / "the fix was" / "root cause was"
- "I learned that" / "next time we should" / "key insight"
- "important gotcha" / "the issue turned out to be"
- "what actually happened was" / "the real problem was"
- "that worked" / "it's fixed" / "working now"

**Suggestion format:**
```
It sounds like you found an important insight:
"[relevant quote from user]"

Want to capture this as a reusable solution doc?
Run `/learn` to capture, or ignore to skip.
```

---

## Step 1: Extract or Prompt for Learning

**If conversation contains a recently solved problem:**
- Extract learning from conversation context automatically
- Present extracted learning for user confirmation

**If no context available (standalone invoke):**
- Prompt user for: problem, root cause, fix, gotchas

---

## Step 2: Execute Knowledge Capture

**Load and follow:** `skills/learn/SKILL.md`

This handles:
- Learning extraction and confirmation
- Deduplication search against existing `docs/solutions/`
- Solution document generation with enum-validated YAML frontmatter
- File creation in the appropriate category subdirectory
- Searchability confirmation

---

## Step 3: Next Steps

```
AskUserQuestion:
  question: "Solution captured. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Ship it"
      description: "Move to /ship to commit and create PR"
    - label: "Done"
      description: "End workflow — solution saved to docs/solutions/"
```

**If "Ship it":** Suggest user invoke `/ship`.
**If "Done":** End workflow.
