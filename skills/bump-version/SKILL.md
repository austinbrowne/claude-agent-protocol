---
name: bump-version
version: "1.0"
description: Bump plugin version on feature branch and marketplace pointer on main
referenced_by:
  - commands/ship.md
---

# Bump Version Skill

Bump version in plugin.json + marketplace.json on the feature branch, then update the marketplace pointer on main. Designed to run after shipping code changes.

---

## Mandatory Interaction Gates

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Version Number** | Step 2 | Suggested version / Custom | Wrong version deployed — UNACCEPTABLE |
| **Confirm Push** | Step 5 | Push both / Feature only / Abort | Pushed without consent — UNACCEPTABLE |

---

## When to Apply

- After committing and pushing code changes to a feature branch
- When releasing a new version of the plugin
- After `/ship` completes and you want to bump the marketplace version

---

## Process

### Step 1: Detect Context

1. **Current branch:** `git branch --show-current`
2. **Current version:** Read `.claude-plugin/plugin.json` → extract `version` field
3. **Marketplace version:** Read `.claude-plugin/marketplace.json` → extract `plugins[0].version`
4. **Feature branch:** If current branch is `main`, check `marketplace.json` → `plugins[0].source.ref` for the feature branch name. If not on main, use current branch as feature branch.
5. **Dirty check:** `git diff --quiet && git diff --staged --quiet` — if dirty, halt: "Working tree is dirty. Commit or stash first."

### Step 2: Ask Version — MANDATORY GATE

Calculate suggested next version by incrementing the patch number of the current version (e.g., `5.8.0-experimental` → `5.9.0-experimental`).

```
AskUserQuestion:
  question: "Current version: {current_version}. What should the new version be?"
  header: "Version"
  options:
    - label: "{suggested_version} (Recommended)"
      description: "Patch bump from current version"
    - label: "Minor bump ({minor_version})"
      description: "e.g. 5.8.0 → 6.0.0-experimental"
    - label: "Custom"
      description: "Enter a specific version number"
```

If "Custom": ask user for the version string.

### Step 3: Ask for Release Notes (Optional)

```
AskUserQuestion:
  question: "Add release notes to the marketplace description? (appended after existing text)"
  header: "Release notes"
  options:
    - label: "No release notes"
      description: "Just bump the version number"
    - label: "Add notes"
      description: "I'll describe what changed in this version"
```

If "Add notes": ask user for the description text. This gets appended to the marketplace `description` field.

### Step 4: Apply Changes

**4a. Feature branch updates:**

If not already on the feature branch, `git checkout {feature_branch}`.

1. **plugin.json:** Update `version` field to new version
2. **marketplace.json:** Update `plugins[0].version` to new version
3. **marketplace.json:** Update version prefix in `plugins[0].description` (replace `GODMODE v{old}` with `GODMODE v{new}`)
4. **marketplace.json:** If release notes provided, append to `plugins[0].description`

Stage and commit:
```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: bump version to {new_version}"
```

**4b. Main branch update:**

```bash
git checkout main
git pull --ff-only origin main
```

Copy marketplace.json from feature branch (ensures main's marketplace.json matches):
```bash
git show {feature_branch}:.claude-plugin/marketplace.json > .claude-plugin/marketplace.json
git add .claude-plugin/marketplace.json
git commit -m "chore: bump marketplace version to {new_version}"
```

### Step 5: Confirm Push — MANDATORY GATE

```
AskUserQuestion:
  question: "Version bumped to {new_version}. Ready to push?"
  header: "Push"
  options:
    - label: "Push both (Recommended)"
      description: "Push {feature_branch} and main to remote"
    - label: "Push feature branch only"
      description: "Push {feature_branch} only, I'll handle main"
    - label: "Don't push"
      description: "Keep commits local, I'll push manually"
```

**If "Push both":**
```bash
git checkout {feature_branch}
git push origin {feature_branch}
git checkout main
git push origin main
```

**If "Push feature branch only":**
```bash
git checkout {feature_branch}
git push origin {feature_branch}
```

**If "Don't push":** Skip pushing.

### Step 6: Return and Report

Switch back to the original branch:
```bash
git checkout {original_branch}
```

Report:
```
Version Bump Complete
━━━━━━━━━━━━━━━━━━━━
{old_version} → {new_version}

Feature branch ({feature_branch}): committed {and pushed}
Main branch: committed {and pushed}
```

---

## Notes

- **Main only carries marketplace.json.** Code changes live on the feature branch. Main's marketplace.json is the plugin registry pointer.
- **Feature branch is authoritative.** The marketplace.json on main is always copied from the feature branch to ensure consistency.
- **Safe to re-run.** If something goes wrong mid-way, fix the issue and re-run. The skill detects current state from plugin.json.
- **No code changes.** This skill only touches plugin.json and marketplace.json version/description fields.

---

## Integration Points

- **Input**: Current plugin version from plugin.json
- **Output**: Updated versions on feature branch + main, pushed to remote
- **Consumed by**: `/ship` workflow command (post-commit option)
