---
name: bump-version
description: "Bump plugin version on feature branch and marketplace pointer on main"
---

# Bump Version Skill

Bump version in plugin.json + marketplace.json on the feature branch, then update the marketplace pointer on main. Designed to run after shipping code changes.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory interaction gates. You MUST pause at each gate and WAIT for user input. NEVER skip them. NEVER proceed without user response.**

| Gate | Location | Options | What Happens If Skipped |
|------|----------|---------|------------------------|
| **Version Number** | Step 2 | Suggested version / Custom | Wrong version deployed -- UNACCEPTABLE |
| **Confirm Push** | Step 5 | Push both / Feature only / Abort | Pushed without consent -- UNACCEPTABLE |

---

## When to Apply

- After committing and pushing code changes to a feature branch
- When releasing a new version of the plugin
- After `/ship` completes and you want to bump the marketplace version

---

## Process

### Step 1: Detect Context

1. **Current branch:** Run `git branch --show-current`
2. **Current version:** Read `.claude-plugin/plugin.json` and extract the `version` field
3. **Marketplace version:** Read `.claude-plugin/marketplace.json` and extract `plugins[0].version`
4. **Feature branch:** If current branch is `main`, check `marketplace.json` -> `plugins[0].source.ref` for the feature branch name. If not on main, use current branch as feature branch.
5. **Dirty check:** Run `git diff --quiet && git diff --staged --quiet` -- if dirty, halt: "Working tree is dirty. Commit or stash first."

Note: Adjust commands for PowerShell on Windows (e.g., `git diff --quiet` works the same, but other shell commands may differ).

### Step 2: Ask Version -- MANDATORY GATE

Calculate suggested next version by incrementing the patch number of the current version (e.g., `5.8.0-experimental` -> `5.9.0-experimental`).

Present options:

1. **{suggested_version} (Recommended)** -- Patch bump from current version
2. **Minor bump ({minor_version})** -- e.g. 5.8.0 -> 6.0.0-experimental
3. **Custom** -- Enter a specific version number

**WAIT** for user response before continuing.

If "Custom": ask user for the version string.

### Step 3: Ask for Release Notes (Optional)

Present options:

1. **No release notes** -- Just bump the version number
2. **Add notes** -- I'll describe what changed in this version

**WAIT** for user response before continuing.

If "Add notes": ask user for the description text. This gets appended to the marketplace `description` field.

### Step 4: Apply Changes

**4a. Feature branch updates:**

If not already on the feature branch, run `git checkout {feature_branch}`.

1. **plugin.json:** Update `version` field to new version
2. **marketplace.json:** Update `plugins[0].version` to new version
3. **marketplace.json:** Update version prefix in `plugins[0].description` (replace `GODMODE v{old}` with `GODMODE v{new}`)
4. **marketplace.json:** If release notes provided, append to `plugins[0].description`

Stage and commit:
```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: bump version to {new_version}"
```

Note: Adjust commands for PowerShell on Windows (e.g., `git add` and `git commit` work the same across platforms).

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

Note: The `>` redirect syntax works in bash/zsh. On PowerShell, use: `git show {feature_branch}:.claude-plugin/marketplace.json | Out-File -Encoding utf8 .claude-plugin/marketplace.json`

### Step 5: Confirm Push -- MANDATORY GATE

Present options:

1. **Push both (Recommended)** -- Push {feature_branch} and main to remote
2. **Push feature branch only** -- Push {feature_branch} only, I'll handle main
3. **Don't push** -- Keep commits local, I'll push manually

**WAIT** for user response before continuing.

**If "Push both":**
```bash
git checkout {feature_branch}
git push origin {feature_branch}
git checkout main
git push origin main
```

Note: Use `gh` for GitHub repositories. Use `glab` for GitLab repositories (push commands are the same for both, but PR/MR creation differs).

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
---------------------
{old_version} -> {new_version}

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
