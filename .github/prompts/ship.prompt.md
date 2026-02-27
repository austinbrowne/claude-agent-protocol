---
description: "Commit and create PR — with review verification and conventional commit messages"
agent: agent
tools: ['changes', 'runInTerminal', 'githubRepo', 'editFiles']
argument-hint: "commit message (optional)"
---

Ship the current changes:

1. **Verify review status** — check if a fresh-eyes review was completed. If not, recommend running `/review` first.
2. **Stage changes** — `git add` specific files (never `git add .` or `git add -A`)
3. **Create commit** — use conventional commit format (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`)
4. **Push** — push to the current branch
5. **Create PR** (if requested) — with summary, test plan, and review notes

NEVER commit secrets, .env files, or API keys. Warn if sensitive files are staged.
