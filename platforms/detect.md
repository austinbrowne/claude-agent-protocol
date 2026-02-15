# Platform Detection

**Purpose:** Determine the git hosting platform for this repository. Run this once per session, then use the result for all platform-dependent commands.

---

## Detection Steps

### Step 1: Check git remote URL

```bash
git remote get-url origin 2>/dev/null
```

**Match rules:**
- Contains `github.com` → **GitHub** → Read `platforms/github.md`
- Contains `gitlab.com` or `gitlab` → **GitLab** → Read `platforms/gitlab.md`
- Other / no remote → Go to Step 2

### Step 2: Check directory markers

```bash
ls -d .github/ .gitlab-ci.yml 2>/dev/null
```

- `.github/` directory exists → **GitHub**
- `.gitlab-ci.yml` exists → **GitLab**
- Both or neither → Go to Step 3

### Step 3: Ask the user

```
Which platform is this repository hosted on?
1. GitHub
2. GitLab
3. Other (specify)
```

---

## After Detection

1. Read the corresponding platform file (`platforms/github.md` or `platforms/gitlab.md`)
2. Use that file's CLI syntax and terminology for the rest of the session
3. Do NOT re-detect on every command — the platform won't change mid-session

## Terminology Quick Reference

| Concept | GitHub | GitLab |
|---------|--------|--------|
| Code review unit | Pull Request (PR) | Merge Request (MR) |
| CLI tool | `gh` | `glab` |
| Auto-close keyword | `Closes #123` | `Closes #123` |
| User self-reference | `@me` | `@me` |
| Project boards | GitHub Projects | GitLab Boards |
| CI config | `.github/workflows/` | `.gitlab-ci.yml` |
