# Workflow Reference

## 7 Workflow Commands

Use workflow commands as entry points. Each workflow offers sub-step selection via `AskUserQuestion` and chains to the next workflow after completion.

| Command | Purpose |
|---------|---------|
| `/explore` | Reconnaissance & ideation — codebase exploration + brainstorming |
| `/plan` | Planning & requirements — plan generation, deepen, review, issues, ADR |
| `/implement` | Implementation — start issue, tests, validation, security, recovery |
| `/review` | Code review — fresh eyes review (full/lite), protocol compliance |
| `/learn` | Knowledge capture — save solved problems as reusable solution docs |
| `/ship` | Ship — commit/PR, finalize, refactor |
| `/loop` | Autonomous loop — iterates plan tasks with Task subagent context rotation |

### Quick Workflows

**Full feature:**
`/explore` → `/plan` → `/implement` → `/review` → `/learn` → `/ship`

**Bug fix:**
`/explore` → `/implement` → `/review` → `/learn` → `/ship`

**Quick fix:**
`/implement` → `/review` → `/ship`

**Just review:**
`/review` → `/ship`

**Autonomous:**
`/loop <description>` — plan, implement each task, review, commit (all local)
`/loop --plan docs/plans/my-plan.md` — iterate through existing plan tasks
`/loop --issue 42` — enhance if needed, plan, implement, review

### Individual Skills (Also User-Invocable)

Each workflow loads skills from `skills/*/SKILL.md`. Skills are also directly invocable as slash commands:

**Planning skills:** `explore`, `brainstorm`, `generate-plan`, `deepen-plan`, `review-plan`, `create-adr`, `create-issues`

**Issue skills:** `file-issues`, `file-issue`, `enhance-issue`

**Execution skills:** `start-issue`, `team-implement`, `triage-issues`, `generate-tests`, `run-validation`, `security-review`, `recovery`, `refactor`

**Review skills:** `fresh-eyes-review`, `review-protocol`, `document-review`

**Shipping skills:** `commit-and-pr`, `finalize`

**Knowledge skills:** `capture-learning`, `todos`

**Configuration skills:** `setup`

---

## Plans vs Enhanced Issues

**Enhanced issue** = **what** to build. Requirements, acceptance criteria, scope, affected files. Sufficient for implementation when the approach is obvious. Most work falls here.

**Plan** = **how** to build it. Technical approach, architecture decisions, tradeoffs, decomposition. Only needed when multiple valid approaches exist, architectural implications need review, or the work needs formal decomposition.

| Complexity | What You Need | Path |
|-----------|--------------|------|
| Bug / small fix | Issue only | `file-issue` → `start-issue` |
| Medium feature | Enhanced issue | `file-issue` → `enhance-issue` → `start-issue` |
| Complex feature | Plan (implements directly) | `/plan` → `team-implement` |
| Large multi-issue epic | Plan + issues | `/plan` → `create-issues` → `start-issue` each |

## Full Protocol (Complex Tasks)
For comprehensive guidance, see `AI_CODING_AGENT_GODMODE.md`
