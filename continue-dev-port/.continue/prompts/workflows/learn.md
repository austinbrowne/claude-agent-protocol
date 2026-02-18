---
name: learn
description: "Knowledge capture — save solved problems as searchable, reusable solution docs"
invokable: true
---

# /learn — Knowledge Capture

Captures solved problems, gotchas, and insights as searchable solution documents in `docs/solutions/`.

{{{ input }}}

---

## Auto-Trigger Detection

Proactively suggest `/learn` when detecting these phrases in conversation:

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
Run /learn to capture, or ignore to skip.
```

---

## Step 1: Extract or Prompt for Learning

**If conversation contains a recently solved problem:**
- Extract the learning from conversation context automatically
- Present the extracted learning for user confirmation

**If no context available (standalone invoke):**
- Prompt the user for: problem encountered, root cause, fix applied, gotchas

---

## Step 2: Execute Knowledge Capture

Execute the `/capture-learning` command.

This handles:
- Learning extraction and confirmation
- Deduplication search against existing `docs/solutions/`
- Solution document generation with enum-validated YAML frontmatter
- File creation in the appropriate category subdirectory
- Searchability confirmation

---

## Step 3: Next Steps

Present the following options and WAIT for the user's response before proceeding:

1. **Ship it** — Move to `/ship` to commit and create PR
2. **Done** — End workflow — solution saved to `docs/solutions/`

Do NOT proceed until the user selects an option.

**Routing:**
- **"Ship it"** — Execute the `/ship` command from Step 0. Do NOT skip any steps.
- **"Done"** — End workflow.
