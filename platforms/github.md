# GitHub Platform Reference

**CLI Tool:** `gh` (GitHub CLI)
**Terminology:** Pull Request (PR), GitHub Projects, GitHub Actions
**Docs:** https://cli.github.com/manual/

---

## Prerequisites

```bash
# Verify installation and auth
gh auth status

# Login if needed
gh auth login

# Enable project scope (needed for GitHub Projects)
gh auth refresh -s project --hostname github.com
```

---

## Issue Commands

```bash
# List open issues
gh issue list --state open --limit 20

# View issue details (JSON for parsing)
gh issue view ISSUE_NUM --json title,body,labels,assignees,state

# View issue with project info
gh issue view ISSUE_NUM --json title,body,labels,projectItems

# Create issue
gh issue create \
  --title "Phase N: Feature name" \
  --body-file /tmp/issue-body.md \
  --label "type: feature,priority: high" \
  --project "Project Name"

# Create issue with assignee (immediate mode)
gh issue create \
  --title "Phase N: Feature name" \
  --body-file /tmp/issue-body.md \
  --label "type: feature" \
  --assignee @me

# Edit issue - assign
gh issue edit ISSUE_NUM --add-assignee @me

# Edit issue - remove assignee
gh issue edit ISSUE_NUM --remove-assignee @me

# Edit issue - add label
gh issue edit ISSUE_NUM --add-label "needs-replanning"

# Edit issue - append to body
gh issue edit ISSUE_NUM --add-body "Additional content here"

# Comment on issue
gh issue comment ISSUE_NUM --body "Comment text here"

# Close issue with comment
gh issue close ISSUE_NUM --comment "Closed: reason here"
```

---

## Pull Request Commands

```bash
# Create PR
gh pr create \
  --title "feat: Description (Closes #ISSUE_NUM)" \
  --body "$(cat <<'EOF'
PR body content here
EOF
)" \
  --base TARGET_BRANCH

# View PR
gh pr view PR_NUM
```

**Auto-close syntax:** Include `Closes #123` in PR title or body to auto-close the issue on merge.

**URL format:** `https://github.com/OWNER/REPO/pull/PR_NUM`

---

## Label Commands

```bash
# Create label
gh label create "label-name" --description "Description" --color "HEX"

# Common labels
gh label create "type: feature" --description "New feature" --color "0E8A16"
gh label create "type: bug" --description "Bug fix" --color "D93F0B"
gh label create "priority: high" --description "High priority" --color "B60205"
gh label create "priority: medium" --description "Medium priority" --color "FBCA04"
gh label create "status: ready" --description "Ready for development" --color "0075CA"
gh label create "status: blocked" --description "Blocked by dependency" --color "D93F0B"
gh label create "security-sensitive" --description "Requires security review" --color "B60205"
```

---

## Project Commands (GitHub Projects)

```bash
# List projects
gh project list --owner OWNER

# Create project
gh project create --owner OWNER --title "Project Name"

# View project
gh project view PROJECT_NUM --owner OWNER

# List project items
gh project item-list PROJECT_NUM --owner OWNER
gh project item-list PROJECT_NUM --owner OWNER --format json

# Edit project item status
gh project item-edit --project-id PROJECT_ID --id ITEM_ID --field-id FIELD_ID --value "In Progress"
```

**Board columns:** Backlog → Ready → In Progress → Review → Done

For full project integration workflow, see `guides/GITHUB_PROJECT_INTEGRATION.md`.

---

## Repository Commands

```bash
# View repo info
gh repo view

# View repo with project info
gh repo view --json projectsV2
```
