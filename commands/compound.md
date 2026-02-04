---
description: Capture solved problems as searchable, reusable solution docs
---

# /compound

**Description:** Capture solved problems as searchable, reusable solution docs

**When to use:**
- After solving a tricky bug or unexpected behavior
- When discovering a gotcha that others will hit
- When a debugging session reveals a non-obvious root cause
- When you learn something important about a library, framework, or pattern
- Anytime knowledge would be lost if not written down

**Auto-trigger phrases:** Claude should proactively suggest `/compound` when it detects these phrases in conversation:
- "the trick was"
- "the fix was"
- "root cause was"
- "I learned that"
- "next time we should"
- "key insight"
- "important gotcha"
- "the issue turned out to be"
- "what actually happened was"
- "the real problem was"

**Prerequisites:** None (can be invoked at any time)
- Works best when the conversation contains the context of a recently solved problem
- Can also be invoked standalone with manual input

---

## Invocation

**Interactive mode:**
User types `/compound` with no arguments. Claude extracts the learning from conversation context.

**Direct mode:**
User types `/compound --title "JWT refresh token race condition"` with explicit title.

**Auto-suggest mode:**
Claude detects a trigger phrase and suggests:
```
It sounds like you discovered an important learning.
Capture it as a reusable solution? `/compound`
```

---

## Arguments

- `--title "title"` - Provide a descriptive title for the solution (direct mode)
- No other flags — all other fields are extracted or prompted interactively

---

## Execution Steps

### Step 1: Detect or invoke

**If auto-suggest (trigger phrase detected):**
- Claude detects a trigger phrase in the user's message
- Suggest capturing the learning:
  ```
  It sounds like you found an important insight:
  "[relevant quote from user]"

  Want to capture this as a reusable solution doc?
  This makes it searchable for future sessions.

  Run `/compound` to capture, or ignore to skip.
  ```
- Wait for user to invoke `/compound` or decline

**If manual invoke (user types `/compound`):**
- Proceed directly to Step 2

**If direct mode (`/compound --title "..."`):**
- Use provided title, proceed to Step 2

### Step 2: Extract the learning from context

**If conversation contains a recently solved problem:**

Scan conversation for:
1. **Problem:** What went wrong? (error messages, unexpected behavior, symptoms)
2. **Root cause:** What was actually wrong? (the underlying issue)
3. **Solution:** What fixed it? (code changes, config changes, approach)
4. **Gotchas:** What was tricky or non-obvious? (things easy to get wrong)

**Present extracted learning for confirmation:**
```
Extracted learning:

Title: [auto-generated or from --title]
Problem: [extracted problem description]
Root cause: [extracted root cause]
Solution: [extracted fix]
Gotchas:
- [gotcha 1]
- [gotcha 2]

Is this accurate? (yes/edit/start-over): _____
```

**If "edit":**
- Allow user to modify any field
- Re-present for confirmation

**If "start-over":**
- Ask user to describe the learning manually:
  ```
  Describe the learning:

  What was the problem? _____
  What was the root cause? _____
  What was the fix? _____
  Any gotchas or things to watch for? _____
  ```

**If no conversation context available (standalone invoke):**
- Go directly to manual input prompts above

### Step 3: Check for existing duplicates

**Search `docs/solutions/` for similar existing solutions:**

```bash
# Check if directory exists
ls docs/solutions/ 2>/dev/null
```

**If directory exists, run multi-pass Grep:**

1. **Title/summary match:**
   - Grep for keywords from the extracted title and problem summary
   - Example: `Grep pattern="refresh.*token|race.*condition" path="docs/solutions/"`

2. **Category match:**
   - Grep for the same category
   - Example: `Grep pattern="category: auth" path="docs/solutions/"`

3. **Tag overlap:**
   - Grep for tags that match the new solution's tags
   - Example: `Grep pattern="tags:.*jwt|tags:.*token" path="docs/solutions/"`

**If potential duplicates found:**
- Read the matching file(s)
- Compare content with new learning

### Step 4: Handle duplicates

**If duplicate detected:**
```
Potential duplicate found:

Existing: docs/solutions/auth-jwt-refresh-token-race-condition.md
Match reason: Same category (auth), overlapping tags (jwt, token, refresh)

Options:
1. Update existing — add new gotchas/details to existing solution
2. Create new — this is a different enough problem to warrant separate doc
3. Skip — existing solution already covers this

Your choice: _____
```

**If "Update existing":**
- Read existing solution file
- Merge new gotchas, details, and context into existing file
- Preserve original content, add new findings
- Update `discovered` date if more recent
- Save updated file

**If "Create new":**
- Continue to Step 5 (create new solution)
- Add reference to existing solution in `related_solutions` field

**If "Skip":**
```
Skipped. Existing solution covers this learning.

File: docs/solutions/auth-jwt-refresh-token-race-condition.md
```

### Step 5: Generate solution document

**Determine metadata:**

1. **Title:** From user input or auto-generated
2. **Category:** Auto-detect from context:
   - auth | api | database | testing | security | performance | error-handling | architecture | devops | refactoring | debugging
3. **Tags:** Extract 3-5 relevant keywords
4. **Language:** Detect from code in conversation (or "agnostic")
5. **Framework:** Detect from imports/patterns (or "agnostic")
6. **Complexity:** simple | moderate | complex (based on root cause depth)
7. **Confidence:** high | medium | low (based on how well-understood the fix is)
8. **Issue reference:** Extract from conversation if working on an issue

**Load template from:** `templates/SOLUTION_TEMPLATE.md`

**Generate solution content with YAML frontmatter:**

```markdown
---
title: "JWT refresh token race condition causes session loss"
category: auth
tags: [jwt, refresh-token, race-condition, concurrency, session]
language: typescript
framework: express
complexity: moderate
confidence: high
discovered: 2026-02-03
issue_ref: "#145"
problem_summary: "Concurrent refresh token requests invalidate each other"
solution_summary: "Implement token rotation with grace period"
status: validated
related_solutions: []
---

# JWT Refresh Token Race Condition Causes Session Loss

## Problem

**What happened:**
[Filled from extracted problem]

**Context:**
[Filled from conversation context]

**Root cause:**
[Filled from extracted root cause]

---

## Solution

**The fix:**
[Filled from extracted solution]

**Key code/config:**
[Relevant code snippet from conversation]

**Why it works:**
[Explanation of why the fix addresses root cause]

---

## Gotchas

- [Extracted gotcha 1]
- [Extracted gotcha 2]

---

## Prevention

**How to avoid this in the future:**
- [Specific practice or pattern]

**Related patterns:**
- [Links to related docs or solutions]

---

## Applicability

**Use this solution when:**
- [Condition derived from problem context]

**Do NOT use when:**
- [Counter-condition]
```

### Step 6: Save solution file

**Create directory if needed:**
```bash
mkdir -p docs/solutions
```

**Generate filename:**
- Format: `docs/solutions/{category}-{description-slug}.md`
- Category: from YAML frontmatter
- Description slug: kebab-case, 3-6 words from title
- Example: `docs/solutions/auth-jwt-refresh-token-race-condition.md`

**Check filename does not collide:**
```bash
ls docs/solutions/{generated-filename} 2>/dev/null
```

If collision: append incrementing number (e.g., `auth-jwt-refresh-token-race-condition-2.md`)

**Save file.**

### Step 7: Confirm with searchability note

```
Solution captured!

File: docs/solutions/auth-jwt-refresh-token-race-condition.md

Searchable by:
- Category: auth
- Tags: jwt, refresh-token, race-condition, concurrency, session
- Keywords: "refresh token", "race condition", "session loss"
- Language: typescript
- Framework: express

This solution will be found automatically when:
- `/brainstorm` explores auth-related features
- `/deepen-plan` researches token handling
- `/start-issue` begins work on auth issues
- `/explore` investigates authentication patterns

Tip: The more solutions you capture, the smarter future planning becomes.
```

---

## Output

**Solution file created:**
- Location: `docs/solutions/{category}-{description-slug}.md`
- YAML frontmatter with all searchable metadata
- Full problem/solution/gotchas documentation

**Searchability:**
- Category-based search
- Tag-based search
- Full-text keyword search
- Language/framework filtering

**Status:** `SOLUTION_CAPTURED`

---

## References

- See: `templates/SOLUTION_TEMPLATE.md` for solution document structure
- See: `agents/research/learnings-researcher.md` for how solutions are searched and surfaced
- See: `AI_CODING_AGENT_GODMODE.md` for how solutions feed back into planning

---

## Example Usage

**Example 1: Manual invoke after debugging session**
```
User: /compound

Claude: Extracted learning from conversation:

Title: N+1 query in user dashboard caused 30s load time
Problem: Dashboard page loading 30+ seconds
Root cause: Each user card triggered individual DB query for avatar
Solution: Eager-load avatars with JOIN in initial query
Gotchas:
- ORM default is lazy loading — must explicitly specify eager
- JOIN increases initial query size but eliminates N queries

Is this accurate? yes

Checking for duplicates in docs/solutions/...
No duplicates found.

Solution captured!

File: docs/solutions/database-n-plus-one-user-dashboard.md

Searchable by:
- Category: database
- Tags: n-plus-one, eager-loading, orm, performance, query
- Keywords: "N+1", "lazy loading", "JOIN"
```

**Example 2: Auto-suggest on trigger phrase**
```
User: The trick was that bcrypt.compare() is async but we were calling it
without await, so it always returned truthy (the Promise object).

Claude: It sounds like you found an important insight:
"bcrypt.compare() is async but was called without await"

Want to capture this as a reusable solution doc?
Run `/compound` to capture, or ignore to skip.

User: /compound

Claude: Extracted learning:

Title: bcrypt.compare() called without await always returns truthy
Problem: Authentication always succeeds regardless of password
Root cause: bcrypt.compare() returns a Promise, which is truthy
Solution: Add await before bcrypt.compare() call
Gotchas:
- TypeScript does not warn about unhandled Promise in boolean context
- This passes all "valid password" tests but never fails "wrong password" tests

Is this accurate? yes

Solution captured!

File: docs/solutions/auth-bcrypt-compare-missing-await.md
```

**Example 3: Duplicate detection**
```
User: /compound --title "JWT token not invalidated on logout"

Claude: Extracted learning:

Title: JWT token not invalidated on logout
Problem: Users remain authenticated after clicking logout
Root cause: JWTs are stateless — server cannot invalidate them
Solution: Implement token denylist with Redis TTL matching token expiry

Checking for duplicates in docs/solutions/...

Potential duplicate found:

Existing: docs/solutions/auth-jwt-session-invalidation.md
Match reason: Category (auth), tags (jwt, logout, session)

Options:
1. Update existing — add new gotchas/details
2. Create new — different enough problem
3. Skip — existing covers this

Your choice: 1

Claude: Updated existing solution with new details.

File: docs/solutions/auth-jwt-session-invalidation.md (updated)
Added:
- New gotcha: Redis TTL must match JWT expiry exactly
- New prevention tip: Consider short-lived tokens + refresh rotation
```

---

## Notes

- **Auto-suggest is non-intrusive:** Claude suggests `/compound` but does not block the conversation. The user can ignore the suggestion.
- **Conversation context is primary source:** Claude extracts the learning from what was just discussed. Manual input is a fallback.
- **Duplicate detection prevents bloat:** The `docs/solutions/` directory stays clean by merging related learnings into existing files.
- **YAML frontmatter enables search:** The `learnings-researcher` agent uses these fields for multi-pass Grep. Good metadata means better discoverability.
- **Category taxonomy is fixed:** Use only the defined categories (auth, api, database, testing, security, performance, error-handling, architecture, devops, refactoring, debugging). This ensures consistent search.
- **Compound knowledge grows over time:** Each captured solution makes future planning smarter. Commands like `/brainstorm`, `/deepen-plan`, and `/start-issue` automatically search past solutions.
- **Trigger phrases are suggestions, not requirements:** Claude can also suggest `/compound` based on contextual signals beyond the listed trigger phrases.
- **Status field:** Use `validated` for well-tested solutions, `draft` for uncertain ones, `deprecated` for outdated learnings.
- **Team knowledge base:** Over time, `docs/solutions/` becomes a project-specific knowledge base that persists across sessions and team members.
