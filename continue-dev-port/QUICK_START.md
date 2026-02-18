# GODMODE Quick Start

## Installation

1. **Copy** the `.continue/` directory to your project root (or `~/.continue/` for global):
   ```bash
   cp -r /path/to/continue-dev-port/.continue .continue/
   ```

2. **Configure your model** in `.continue/config.yaml`:
   ```yaml
   models:
     - name: Claude
       provider: anthropic
       model: claude-sonnet-4-20250514
   ```

3. **Verify** -- type `/` in the continue.dev chat panel. You should see `implement`, `plan`, `review`, `ship`, `learn`, and `loop`.

---

## Your First Workflow: Implementing an Issue

```
1. /implement                    # Opens implementation hub
2. Select "Start issue"          # Enter issue number when prompted
3. [Model researches codebase, assesses complexity, implements]
4. Select "Generate tests"       # When implementation completes
5. /review                       # Fresh eyes multi-persona review
6. Fix any CRITICAL/HIGH issues
7. /ship                         # Commit and create PR
```

---

## Common Workflow Recipes

| Recipe | Commands |
|--------|----------|
| **Full feature** | `/plan` -> `/implement` -> `/review` -> `/learn` -> `/ship` |
| **Bug fix** | `/explore` -> `/implement` -> `/review` -> `/learn` -> `/ship` |
| **Quick fix** | `/implement` -> `/review` -> `/ship` |
| **Just review** | `/review` -> `/ship` |
| **Autonomous** | `/loop add user authentication` or `/loop --issue 42` |

---

## Available Commands

### Workflows (entry points)

| Command | Purpose |
|---------|---------|
| `/implement` | Start issues, plan implementation, triage, tests, validation, security |
| `/plan` | Generate/deepen/review plans, create issues, ADRs |
| `/review` | Fresh eyes code review, protocol compliance |
| `/ship` | Commit, create PR, finalize, refactor |
| `/learn` | Capture solved problems as reusable docs |
| `/loop` | Autonomous plan-implement-review loop |

### Skills (directly invokable)

**Planning:** `/explore`, `/brainstorm`, `/generate-plan`, `/deepen-plan`, `/review-plan`, `/create-adr`, `/create-issues`

**Issues:** `/file-issues`, `/file-issue`, `/enhance-issue`

**Execution:** `/start-issue`, `/team-implement`, `/triage-issues`, `/generate-tests`, `/run-validation`, `/security-review`, `/recovery`, `/refactor`

**Review:** `/fresh-eyes-review`, `/review-protocol`, `/document-review`

**Shipping:** `/commit-and-pr`, `/finalize`, `/bump-version`

**Knowledge:** `/learn`, `/todos`

**Config:** `/setup`

---

## Autonomous Loop

```
/loop add user authentication         # Plan + implement + review from description
/loop --plan docs/plans/my-plan.md    # Iterate tasks from existing plan
/loop --issue 42                      # Enhance issue, plan, implement, review
```

The loop runs in a single context window. For large plans, break them into smaller batches or start a new chat between major tasks.

---

## Tips

- **Workflows present numbered menus.** Wait for the menu, type a number, and the model proceeds to that step. Do not skip ahead.
- **Rules auto-load.** Core safety rules (blind spots, security, edge cases) are injected into every conversation via `alwaysApply: true` frontmatter.
- **Cross-platform.** Shell commands auto-detect your OS. Both bash and PowerShell are supported.
- **GitHub and GitLab.** The protocol detects which CLI is available (`gh` or `glab`) and adapts commands accordingly.
- **Knowledge compounds.** Run `/learn` after solving tricky problems. Future `/implement` and `/explore` runs search `docs/solutions/` automatically.
- **No parallel agents.** Unlike Claude Code, review/research agents run sequentially in the same context. Same analysis, no parallelism.
- **Context growth on large tasks.** There is no subagent context rotation. Start a new chat if the conversation gets very long.

---

**Full documentation:** See `README.md`
**Protocol version:** 1.0.0 (continue.dev port)
