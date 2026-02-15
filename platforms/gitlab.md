# GitLab Platform Reference

**CLI Tool:** `glab` (GitLab CLI)
**Terminology:** Merge Request (MR), GitLab Boards, GitLab CI/CD
**Docs:** https://gitlab.com/gitlab-org/cli/-/blob/main/docs/source/index.md

---

## Prerequisites

```bash
# Verify installation and auth
glab auth status

# Login if needed
glab auth login

# For self-hosted GitLab instances
glab auth login --hostname gitlab.example.com
```

---

## Issue Commands

```bash
# List open issues
glab issue list --per-page 20

# View issue details
glab issue view ISSUE_NUM

# Create issue
glab issue create \
  --title "Phase N: Feature name" \
  --description "$(cat /tmp/issue-body.md)" \
  --label "type::feature,priority::high"

# Create issue with assignee (immediate mode)
glab issue create \
  --title "Phase N: Feature name" \
  --description "$(cat /tmp/issue-body.md)" \
  --label "type::feature" \
  --assignee @me

# Edit issue - assign (use glab API or web)
glab api -X PUT "projects/:fullpath/issues/ISSUE_NUM" -f assignee_ids[]=USER_ID

# Add a note/comment to issue
glab issue note ISSUE_NUM --message "Comment text here"

# Close issue
glab issue close ISSUE_NUM

# Reopen issue
glab issue reopen ISSUE_NUM

# Add label to existing issue
glab issue update ISSUE_NUM --label "needs-replanning"

# Remove assignee
glab issue update ISSUE_NUM --unassign @me
```

**Note:** `glab issue update` covers edit operations. Some advanced edits may require `glab api`.

---

## Merge Request Commands

```bash
# Create MR
glab mr create \
  --title "feat: Description (Closes #ISSUE_NUM)" \
  --description "$(cat <<'EOF'
MR body content here
EOF
)" \
  --target-branch TARGET_BRANCH

# Create MR and auto-fill from commits
glab mr create --fill --target-branch TARGET_BRANCH

# View MR
glab mr view MR_NUM

# List MRs
glab mr list
```

**Auto-close syntax:** Include `Closes #123` in MR description to auto-close the issue on merge. GitLab also supports `Fixes #123` and `Resolves #123`.

**URL format:** `https://gitlab.com/OWNER/REPO/-/merge_requests/MR_NUM`

---

## Label Commands

GitLab supports **scoped labels** natively (e.g., `priority::high` — only one `priority::` label can be active at a time).

```bash
# Create label
glab label create "label-name" --description "Description" --color "#HEX"

# Common labels (using GitLab scoped label convention)
glab label create "type::feature" --description "New feature" --color "#0E8A16"
glab label create "type::bug" --description "Bug fix" --color "#D93F0B"
glab label create "priority::high" --description "High priority" --color "#B60205"
glab label create "priority::medium" --description "Medium priority" --color "#FBCA04"
glab label create "status::ready" --description "Ready for development" --color "#0075CA"
glab label create "status::blocked" --description "Blocked by dependency" --color "#D93F0B"
glab label create "security-sensitive" --description "Requires security review" --color "#B60205"
```

**Scoped labels:** Use `::` separator (e.g., `priority::high`). GitLab automatically enforces that only one label per scope is active — assigning `priority::low` removes `priority::high`.

---

## Board & Project Management

GitLab uses **Issue Boards** and **Milestones** instead of GitHub Projects.

```bash
# Milestones (closest equivalent to project tracking)
glab api "projects/:fullpath/milestones" | jq '.[].title'

# Create milestone
glab api -X POST "projects/:fullpath/milestones" \
  -f title="Sprint 1" -f description="First sprint" -f due_date="2025-12-31"

# Assign issue to milestone
glab issue update ISSUE_NUM --milestone "Sprint 1"
```

**Issue Boards** are configured via the GitLab web UI — they map label lists to columns. No CLI equivalent exists for board management.

**Board columns (label-based):** Create labels like `status::backlog`, `status::ready`, `status::in-progress`, `status::review`, `status::done`, then configure a board to show lists for each.

For full project integration workflow, see `guides/GITLAB_PROJECT_INTEGRATION.md`.

---

## Repository Commands

```bash
# View repo info
glab repo view

# Clone repo
glab repo clone OWNER/REPO
```

---

## Key Differences from GitHub

| Feature | GitHub (`gh`) | GitLab (`glab`) |
|---------|--------------|-----------------|
| Code review | `gh pr create` | `glab mr create` |
| Issue comments | `gh issue comment` | `glab issue note` |
| Issue edit | `gh issue edit --add-assignee` | `glab issue update --assignee` |
| Body from file | `--body-file path` | `--description "$(cat path)"` |
| Project boards | `gh project` commands | Web UI + labels |
| Scoped labels | Manual convention | Native (`key::value`) |
| CI config | `.github/workflows/` | `.gitlab-ci.yml` |
| Target branch flag | `--base branch` | `--target-branch branch` |
