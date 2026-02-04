---
name: file-issue
version: "1.0"
description: File a single GitHub issue from a description — asks bug or feature, confirms details, then creates with needs_refinement label
argument-hint: "[issue description]"
---

# File Issue Skill

File a single GitHub issue quickly. Accepts a description as an argument, asks for type and any additional details, then creates the issue.

---

## When to Apply

- Filing a single bug or feature request
- Quick capture of one issue with a known description
- Invoked as `/file-issue <description>`

---

## Process

### 1. Parse Argument

If the user provided a description argument, use it as the initial issue description. If no argument, ask the user to describe the issue.

### 2. Ask Issue Type

```
AskUserQuestion:
  question: "What type of issue is this?"
  header: "Issue type"
  options:
    - label: "Bug"
      description: "Something is broken or behaving incorrectly"
    - label: "Feature / Enhancement"
      description: "New functionality or improvement to existing behavior"
```

### 3. Extract Details from Description

**For bugs**, extract what's available:
- Title (imperative mood, e.g. "Fix crash when submitting empty form")
- Bug description (what's happening)
- Steps to reproduce (if provided)
- Expected vs actual behavior (if provided)
- Severity (infer from context, default to `medium`)

**For features/enhancements**, extract:
- Title (imperative mood, e.g. "Add dark mode toggle to settings")
- Description (what needs to be built and why)
- User story (if obvious from context)

### 4. Confirm Before Creating

Present a summary of what will be filed, then ask:

```
AskUserQuestion:
  question: "Here's what I'll file. Want to add any more details before I create it?"
  header: "Confirm"
  options:
    - label: "Looks good, create it"
      description: "File the issue as shown"
    - label: "Add more details"
      description: "Let me add more context before filing"
```

**If "Add more details":** Ask the user for additional context. Incorporate it into the issue, then present the updated summary and ask again.
**If "Looks good":** Proceed to Step 5.

### 5. Create GitHub Issue

**For bugs** — load `templates/BUG_ISSUE_TEMPLATE.md` and fill sparsely:

```bash
gh issue create \
  --title "[Bug title]" \
  --body-file /tmp/issue-body.md \
  --label "type: bug,needs_refinement"
```

Fill only: Title, Bug Description, Steps to Reproduce (if provided), Expected/Actual (if provided), Severity. Leave all other sections as TBD or template defaults.

**For features** — load `templates/GITHUB_ISSUE_TEMPLATE.md` and fill sparsely:

```bash
gh issue create \
  --title "[Feature title]" \
  --body-file /tmp/issue-body.md \
  --label "type: feature,needs_refinement"
```

Fill only: Title, Description. Leave Acceptance Criteria, Technical Requirements, Testing Notes, and all other sections as template defaults.

### 6. Confirm

Print the created issue number and URL.

Suggest next steps: `/enhance-issue #NNN` to add details, or `/workflows:implement` to start working on it.

---

## Integration Points

- **Templates**: `templates/BUG_ISSUE_TEMPLATE.md`, `templates/GITHUB_ISSUE_TEMPLATE.md`
- **Output**: Single GitHub issue with `needs_refinement` label
- **Next step**: `/enhance-issue` to refine, or `/workflows:implement` to start working
