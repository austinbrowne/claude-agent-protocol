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

## Skills

**Load before execution:** Read and follow `skills/knowledge-compounding/SKILL.md` for auto-trigger phrase detection, solution document schema, deduplication search patterns, and `docs/solutions/` conventions.

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
Module: [detected module/area]
Problem type: [enum value]
Symptoms:
- [symptom 1]
- [symptom 2]
Root cause: [enum value] — [explanation]
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

**If directory exists, narrow by category first, then run multi-pass Grep:**

**Category narrowing:** If `problem_type` is known, search the specific subdirectory:
- Example: `Grep pattern="race.*condition" path="docs/solutions/security-issues/"`

**Then run multi-pass Grep across all of `docs/solutions/`:**

1. **Tag match:**
   - Grep for tags from the new solution
   - Example: `Grep pattern="tags:.*(jwt|token|refresh)" path="docs/solutions/"`

2. **Module match:**
   - Grep for the same module/area
   - Example: `Grep pattern="module:.*Authentication" path="docs/solutions/"`

3. **Problem type match:**
   - Grep for the same problem type enum
   - Example: `Grep pattern="problem_type: security_issue" path="docs/solutions/"`

4. **Symptom match:**
   - Grep for keywords from observed symptoms
   - Example: `Grep pattern="symptoms:.*race condition|symptoms:.*session" path="docs/solutions/"`

5. **Full-text search:**
   - Grep for domain-specific keywords in body content
   - Example: `Grep pattern="refresh token|race condition" path="docs/solutions/"`

**If potential duplicates found:**
- Read the matching file(s)
- Compare content with new learning

### Step 4: Handle duplicates

**If duplicate detected:**
```
Potential duplicate found:

Existing: docs/solutions/security-issues/jwt-refresh-token-race-condition-20260115.md
Match reason: Same problem_type (security_issue), overlapping tags (jwt, token, refresh)

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
- Update `date` if more recent
- Save updated file

**If "Create new":**
- Continue to Step 5 (create new solution)
- Add reference to existing solution in `related_solutions` field

**If "Skip":**
```
Skipped. Existing solution covers this learning.

File: docs/solutions/security-issues/jwt-refresh-token-race-condition-20260115.md
```

### Step 5: Generate solution document

**Determine metadata using enum-validated fields:**

1. **Module:** Project area (e.g., "Authentication", "API", "Database")
2. **Problem type:** Auto-detect from context — determines subdirectory:
   - `build_error`, `test_failure`, `runtime_error`, `performance_issue`, `database_issue`, `security_issue`, `ui_bug`, `integration_issue`, `logic_error`, `developer_experience`, `workflow_issue`, `best_practice`, `documentation_gap`
3. **Component:** Technical component involved:
   - `model`, `controller`, `view`, `service`, `background_job`, `database`, `frontend`, `realtime`, `api_client`, `auth`, `payments`, `config`, `testing`, `tooling`, `documentation`
4. **Symptoms:** 1-5 specific observable symptoms (error messages, behaviors)
5. **Root cause:** Enum value:
   - `missing_association`, `missing_eager_load`, `missing_index`, `wrong_api`, `scope_error`, `race_condition`, `async_timing`, `memory_issue`, `config_error`, `logic_error`, `test_isolation`, `missing_validation`, `missing_permission`, `type_error`, `encoding_error`, `dependency_issue`
6. **Resolution type:** `code_fix`, `migration`, `config_change`, `test_fix`, `dependency_update`, `environment_setup`, `workflow_improvement`, `documentation_update`, `tooling_addition`
7. **Severity:** `critical`, `high`, `medium`, `low`
8. **Tags:** Extract 3-5 relevant keywords (lowercase, hyphen-separated)
9. **Language:** Detect from code in conversation (optional)
10. **Framework:** Detect from imports/patterns (optional)
11. **Issue reference:** Extract from conversation if working on an issue (optional)

**Load template from:** `templates/SOLUTION_TEMPLATE.md`

**Generate solution content with YAML frontmatter:**

```markdown
---
module: "Authentication"
date: 2026-02-03
problem_type: security_issue
component: auth
symptoms:
  - "JWT refresh token race condition"
  - "Sessions lost on concurrent requests"
root_cause: race_condition
resolution_type: code_fix
severity: high
tags: [jwt, refresh-token, race-condition, concurrency, session]
language: typescript
framework: express
issue_ref: "#145"
related_solutions: []
---

# Troubleshooting: JWT Refresh Token Race Condition Causes Session Loss

## Problem
Concurrent refresh token requests invalidate each other, causing users to lose their sessions intermittently.

## Environment
- Module: Authentication
- Language/Framework: TypeScript / Express
- Affected Component: Auth service — token refresh endpoint
- Date: 2026-02-03

## Symptoms
- Sessions lost intermittently on concurrent requests
- Token refresh endpoint returns 401 when called in parallel

## What Didn't Work

**Attempted Solution 1:** Simple token refresh without locking
- **Why it failed:** Concurrent requests each invalidate the previous token

## Solution

Implement token rotation with grace period — allow the previous token to remain valid for a short window after rotation.

**Code changes:**
```
# Before (broken):
[Problematic code]

# After (fixed):
[Corrected code]
```

## Why This Works

1. Root cause was concurrent refresh requests invalidating each other
2. Grace period allows in-flight requests to complete with the old token
3. Token rotation still happens, maintaining security

## Prevention

- Always consider concurrency when designing token refresh flows
- Use a grace period or mutex for stateful token operations

## Related Issues

- See also: [related-solution.md](../category/related-solution.md)
```

### Step 6: Save solution file

**Create category subdirectory if needed:**

Map `problem_type` to directory:

| problem_type | Directory |
|---|---|
| `build_error` | `docs/solutions/build-errors/` |
| `test_failure` | `docs/solutions/test-failures/` |
| `runtime_error` | `docs/solutions/runtime-errors/` |
| `performance_issue` | `docs/solutions/performance-issues/` |
| `database_issue` | `docs/solutions/database-issues/` |
| `security_issue` | `docs/solutions/security-issues/` |
| `ui_bug` | `docs/solutions/ui-bugs/` |
| `integration_issue` | `docs/solutions/integration-issues/` |
| `logic_error` | `docs/solutions/logic-errors/` |
| `developer_experience` | `docs/solutions/developer-experience/` |
| `workflow_issue` | `docs/solutions/workflow-issues/` |
| `best_practice` | `docs/solutions/best-practices/` |
| `documentation_gap` | `docs/solutions/documentation-gaps/` |

```bash
mkdir -p docs/solutions/{category-directory}
```

**Generate filename:**
- Format: `docs/solutions/{category-directory}/{slug}-{YYYYMMDD}.md`
- Slug: kebab-case, 3-6 words from title
- Date: today's date in YYYYMMDD format
- Example: `docs/solutions/security-issues/jwt-refresh-token-race-condition-20260203.md`

**Check filename does not collide:**
```bash
ls docs/solutions/{category-directory}/{generated-filename} 2>/dev/null
```

If collision: append incrementing number (e.g., `jwt-refresh-token-race-condition-20260203-2.md`)

**Save file.**

### Step 7: Confirm with searchability note

```
Solution captured!

File: docs/solutions/security-issues/jwt-refresh-token-race-condition-20260203.md

Searchable by:
- Module: Authentication
- Problem type: security_issue → docs/solutions/security-issues/
- Component: auth
- Tags: jwt, refresh-token, race-condition, concurrency, session
- Symptoms: "JWT refresh token race condition", "Sessions lost on concurrent requests"
- Root cause: race_condition

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
- Location: `docs/solutions/{problem_type-directory}/{slug}-{YYYYMMDD}.md`
- Enum-validated YAML frontmatter with all searchable metadata
- Full problem/solution/gotchas documentation

**Searchability:**
- Category directory narrowing (by `problem_type`)
- Module, component, and tag-based Grep
- Symptom keyword matching
- Root cause enum filtering
- Full-text keyword search

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
Module: User Dashboard
Problem type: performance_issue
Symptoms:
- Dashboard page loading 30+ seconds
- Individual DB query per user card avatar
Root cause: missing_eager_load — Each user card triggered individual DB query
Solution: Eager-load avatars with JOIN in initial query
Gotchas:
- ORM default is lazy loading — must explicitly specify eager
- JOIN increases initial query size but eliminates N queries

Is this accurate? yes

Checking for duplicates in docs/solutions/performance-issues/...
No duplicates found.

Solution captured!

File: docs/solutions/performance-issues/n-plus-one-user-dashboard-20260203.md

Searchable by:
- Module: User Dashboard
- Problem type: performance_issue → docs/solutions/performance-issues/
- Component: model
- Tags: n-plus-one, eager-loading, orm, performance, query
- Root cause: missing_eager_load
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
Module: Authentication
Problem type: security_issue
Symptoms:
- Authentication always succeeds regardless of password
- "wrong password" tests never fail
Root cause: async_timing — bcrypt.compare() returns a Promise, which is truthy
Solution: Add await before bcrypt.compare() call
Gotchas:
- TypeScript does not warn about unhandled Promise in boolean context
- This passes all "valid password" tests but never fails "wrong password" tests

Is this accurate? yes

Solution captured!

File: docs/solutions/security-issues/bcrypt-compare-missing-await-20260203.md
```

**Example 3: Duplicate detection**
```
User: /compound --title "JWT token not invalidated on logout"

Claude: Extracted learning:

Title: JWT token not invalidated on logout
Module: Authentication
Problem type: security_issue
Symptoms:
- Users remain authenticated after clicking logout
- JWT token persists after logout action
Root cause: logic_error — JWTs are stateless, server cannot invalidate them
Solution: Implement token denylist with Redis TTL matching token expiry

Checking for duplicates in docs/solutions/security-issues/...

Potential duplicate found:

Existing: docs/solutions/security-issues/jwt-session-invalidation-20260115.md
Match reason: Same problem_type (security_issue), overlapping tags (jwt, logout, session)

Options:
1. Update existing — add new gotchas/details
2. Create new — different enough problem
3. Skip — existing covers this

Your choice: 1

Claude: Updated existing solution with new details.

File: docs/solutions/security-issues/jwt-session-invalidation-20260115.md (updated)
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
- **Enum taxonomy is fixed:** Use only the defined `problem_type` values (build_error, test_failure, runtime_error, performance_issue, database_issue, security_issue, ui_bug, integration_issue, logic_error, developer_experience, workflow_issue, best_practice, documentation_gap). This ensures consistent directory structure and search.
- **All YAML fields use enums:** `component`, `root_cause`, `resolution_type`, and `severity` also have fixed enum values. See `templates/SOLUTION_TEMPLATE.md` for the complete list.
- **Compound knowledge grows over time:** Each captured solution makes future planning smarter. Commands like `/brainstorm`, `/deepen-plan`, and `/start-issue` automatically search past solutions.
- **Trigger phrases are suggestions, not requirements:** Claude can also suggest `/compound` based on contextual signals beyond the listed trigger phrases.
- **Compatible with compound-engineering plugin:** The YAML schema and directory structure are compatible with the compound-engineering plugin's `compound-docs` skill. Docs created by either system are searchable by both.
- **Team knowledge base:** Over time, `docs/solutions/` becomes a project-specific knowledge base that persists across sessions and team members.

---

## Post-Completion Flow

After capturing the solution, present next options using `AskUserQuestion`:

```
AskUserQuestion:
  question: "Solution captured. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Run /commit-and-pr"
      description: "Commit changes and create pull request"
    - label: "Done"
      description: "End workflow — solution saved to docs/solutions/"
```

Based on user's selection, invoke the chosen command.
