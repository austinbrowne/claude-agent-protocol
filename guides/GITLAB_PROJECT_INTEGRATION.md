# GitLab Project Integration Guide

Complete guide for using GitLab Boards, Milestones, and the `glab` CLI with the AI Coding Agent Protocol.

---

## Prerequisites

```bash
# Install glab CLI
# macOS: brew install glab
# Linux: see https://gitlab.com/gitlab-org/cli/-/releases

# Authenticate
glab auth login

# For self-hosted instances
glab auth login --hostname gitlab.example.com

# Verify
glab auth status
```

---

## Step 1: Set Up Labels

GitLab supports **scoped labels** natively. Scoped labels use `::` as a separator and enforce mutual exclusivity within a scope (e.g., only one `priority::` label can be active at a time).

```bash
# Type labels
glab label create "type::feature" --description "New feature" --color "#0E8A16"
glab label create "type::bug" --description "Bug fix" --color "#D93F0B"
glab label create "type::enhancement" --description "Enhancement to existing feature" --color "#1D76DB"
glab label create "type::docs" --description "Documentation" --color "#0075CA"
glab label create "type::refactor" --description "Code refactoring" --color "#D4C5F9"
glab label create "type::test" --description "Tests" --color "#BFD4F2"
glab label create "type::infrastructure" --description "CI/CD, tooling, config" --color "#C2E0C6"

# Priority labels
glab label create "priority::critical" --description "Must fix immediately" --color "#B60205"
glab label create "priority::high" --description "Current sprint priority" --color "#D93F0B"
glab label create "priority::medium" --description "Next sprint candidate" --color "#FBCA04"
glab label create "priority::low" --description "Backlog" --color "#0E8A16"

# Status labels
glab label create "status::backlog" --description "In backlog" --color "#E4E669"
glab label create "status::ready" --description "Ready for development" --color "#0075CA"
glab label create "status::in-progress" --description "Currently being worked on" --color "#7057FF"
glab label create "status::review" --description "In code review" --color "#FBCA04"
glab label create "status::done" --description "Completed" --color "#0E8A16"

# Area labels
glab label create "area::frontend" --description "Frontend/UI" --color "#D4C5F9"
glab label create "area::backend" --description "Backend/API" --color "#C2E0C6"
glab label create "area::infrastructure" --description "CI/CD, deploy, config" --color "#BFD4F2"
glab label create "area::security" --description "Security related" --color "#B60205"

# Flag labels (non-scoped, can have multiple)
glab label create "security-sensitive" --description "Requires security review" --color "#B60205"
glab label create "performance-critical" --description "Has performance budget" --color "#D93F0B"
glab label create "breaking-change" --description "May break existing functionality" --color "#B60205"
```

---

## Step 2: Set Up Issue Board

GitLab Issue Boards are **configured via the web UI**, not the CLI.

1. Navigate to your project → **Plan** → **Issue boards**
2. Create a new board or edit the default board
3. Add label lists for each status label:
   - `status::backlog`
   - `status::ready`
   - `status::in-progress`
   - `status::review`
   - `status::done`
4. Issues move between columns by changing their status label

**Key difference from GitHub Projects:** GitLab boards are label-driven. Moving an issue between columns automatically updates its labels.

---

## Step 3: Set Up Milestones (Optional)

Milestones are GitLab's way of grouping issues into sprints or releases.

```bash
# Create a milestone via API
glab api -X POST "projects/:fullpath/milestones" \
  -f title="v1.0 - MVP" \
  -f description="Minimum viable product release" \
  -f due_date="2025-12-31"

# List milestones
glab api "projects/:fullpath/milestones" | jq '.[].title'
```

**Assign issues to milestones:**
```bash
glab issue update ISSUE_NUM --milestone "v1.0 - MVP"
```

---

## Workflow: Creating Issues from PRD

### Create issues

```bash
# For each phase in the PRD:
glab issue create \
  --title "Phase N: [Phase name]" \
  --description "$(cat /tmp/issue-body.md)" \
  --label "type::feature,priority::high,status::ready"

# With assignee (immediate mode)
glab issue create \
  --title "Phase N: [Phase name]" \
  --description "$(cat /tmp/issue-body.md)" \
  --label "type::feature,priority::high,status::ready" \
  --assignee @me

# With milestone
glab issue create \
  --title "Phase N: [Phase name]" \
  --description "$(cat /tmp/issue-body.md)" \
  --label "type::feature,priority::high,status::ready" \
  --milestone "v1.0 - MVP"
```

### Track progress

```bash
# Move issue to "In Progress" (update status label)
glab issue update ISSUE_NUM --unlabel "status::ready" --label "status::in-progress"

# Move issue to "Review"
glab issue update ISSUE_NUM --unlabel "status::in-progress" --label "status::review"

# Move issue to "Done"
glab issue update ISSUE_NUM --unlabel "status::review" --label "status::done"
```

**Note:** With scoped labels, you only need to set the new status label — GitLab automatically removes the old one in the same scope.

---

## Workflow: Starting an Issue

```bash
# List open issues
glab issue list --per-page 20

# View issue details
glab issue view ISSUE_NUM

# Assign to self
glab issue update ISSUE_NUM --assignee @me

# Update status
glab issue update ISSUE_NUM --label "status::in-progress"

# Add start comment
glab issue note ISSUE_NUM --message "🚧 Starting implementation on branch \`issue-ISSUE_NUM-feature-name\`"

# Create branch and push
git checkout -b issue-ISSUE_NUM-feature-name
git push -u origin issue-ISSUE_NUM-feature-name
```

---

## Workflow: Creating a Merge Request

```bash
# Create MR linked to issue
glab mr create \
  --title "feat: Description (Closes #ISSUE_NUM)" \
  --description "$(cat <<'EOF'
## Summary
[Brief description]

Closes #ISSUE_NUM

## Changes
- [Change 1]
- [Change 2]

## Testing
- ✅ Unit tests passing
- ✅ Security review completed

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)" \
  --target-branch main

# Auto-fill MR from commit messages
glab mr create --fill --target-branch main
```

**Auto-close syntax:** Including `Closes #123`, `Fixes #123`, or `Resolves #123` in the MR description will auto-close the issue when the MR is merged.

---

## Workflow: Completing Work

```bash
# Close issue (if not auto-closed via MR)
glab issue close ISSUE_NUM

# Update status label
glab issue update ISSUE_NUM --label "status::done"

# List remaining issues
glab issue list --label "status::ready"
```

---

## Workflow: Recovery / Abandon

```bash
# Comment with recovery info
glab issue note ISSUE_NUM --message "⚠️ Implementation abandoned. See recovery report: docs/recovery/YYYY-MM-DD-feature.md"

# Remove assignee
glab issue update ISSUE_NUM --unassign @me

# Add needs-replanning label
glab issue update ISSUE_NUM --label "needs-replanning"

# Move back to backlog
glab issue update ISSUE_NUM --label "status::backlog"
```

---

## Key Differences from GitHub

| Feature | GitHub | GitLab |
|---------|--------|--------|
| Board management | `gh project` CLI commands | Web UI (label-driven) |
| Column movement | `gh project item-edit` | Change status label |
| Scoped labels | Convention only | Native (`key::value`) |
| MR vs PR | Pull Request | Merge Request |
| Issue comment | `gh issue comment` | `glab issue note` |
| Issue edit | `gh issue edit --add-assignee` | `glab issue update --assignee` |
| Body from file | `--body-file path` | `--description "$(cat path)"` |
| Auto-close keywords | `Closes #N` | `Closes #N`, `Fixes #N`, `Resolves #N` |
| Target branch | `--base branch` | `--target-branch branch` |
| CI/CD | GitHub Actions | GitLab CI/CD (`.gitlab-ci.yml`) |

---

## CI/CD Integration Notes

GitLab CI/CD uses `.gitlab-ci.yml` in the project root. Common stages for this protocol:

```yaml
# Example .gitlab-ci.yml stages relevant to the protocol
stages:
  - test
  - security
  - review

test:
  stage: test
  script:
    - npm test        # or equivalent
    - npm run coverage

security:
  stage: security
  script:
    - npm audit
    # Add other security checks

# MR-specific jobs
merge_request_review:
  stage: review
  only:
    - merge_requests
  script:
    - echo "MR review checks"
```

---

## Troubleshooting

**"glab: command not found"**
- Install: `brew install glab` (macOS) or see [releases page](https://gitlab.com/gitlab-org/cli/-/releases)

**Authentication issues**
```bash
glab auth login
# For self-hosted: glab auth login --hostname gitlab.example.com
glab auth status
```

**"project not found" errors**
- Ensure you're in a git repo with a GitLab remote
- Check: `git remote get-url origin`

**Scoped labels not working**
- Scoped labels require `::` separator (not `:` or `-`)
- Example: `priority::high` (correct) vs `priority: high` (not scoped)
