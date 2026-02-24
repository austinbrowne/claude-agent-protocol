---
title: "Auto-generate framework-specific review hints in /setup"
date: 2026-02-24
complexity: standard
status: complete
risk_flags: []
---

# Auto-Generate Framework-Specific Review Hints

## Context

The fresh-eyes-review pipeline already injects `## Project Review Context` from `godmode.local.md` into every agent's prompt. But currently `/setup` generates a placeholder ("add any additional context") — so by default, agents remain framework-unaware. Framework-specific footguns (Next.js server/client boundary violations, Rails mass assignment, Prisma unbatched queries) are missed because generic agents don't know to look for them.

The fix is small: make `/setup` auto-compose framework-specific hints into the Project Review Context section based on the detected stack. All existing agents become framework-aware through the mechanism that already exists — no new agents needed.

A secondary fix: the agent prompt templates in `fresh-eyes-review/SKILL.md` and `review-plan/SKILL.md` don't show WHERE the Project Review Context gets injected. The spec says "include it in every agent's prompt" (line 85 / line 48) but the prompt templates omit it. This needs to be explicit.

## Changes

### Task 1: Create framework hints reference file

**Create** `skills/setup/references/framework-hints.md`

Single flat file (same pattern as `fresh-eyes-review/references/trigger-patterns.md`) with one section per framework. YAML frontmatter with `name`, `version`, `description`, `parent`.

**Each framework section contains:**
- Detection markers (what file-system checks trigger inclusion)
- 3-5 hint lines in format: `- [agent-tag] hint text`
- Agent tags: `[security]`, `[edge-case]`, `[performance]`, `[code-quality]`, `[ui]`, `[api]`, `[error-handling]`

**Initial framework coverage (14 sections):**

| Framework | Detection Marker | Hint Count |
|-----------|-----------------|------------|
| Next.js (App Router) | `next.config.*` + `app/layout.tsx` | 5 |
| Next.js (Pages Router) | `next.config.*` + `pages/_app.tsx` | 4 |
| React (generic) | `"react"` in package.json (no meta-framework) | 4 |
| Vue | `"vue"` in package.json (no Nuxt) | 4 |
| Nuxt | `nuxt.config.*` | 4 |
| Svelte / SvelteKit | `svelte.config.*` or `+page.svelte` | 4 |
| Express | `"express"` in package.json | 4 |
| Rails | `Gemfile` + `app/controllers/` | 4 |
| Django | `manage.py` + django in deps | 4 |
| FastAPI | `fastapi` in deps | 4 |
| Go (std lib) | `go.mod` | 4 |
| Prisma | `prisma/` directory | 4 |
| Drizzle | `drizzle.config.*` | 3 |
| Tailwind CSS | `tailwind.config.*` | 3 |

**Budget constraint:** A typical 3-framework stack produces ~12-15 hint lines. Cap at 25 lines total — if exceeded, prioritize `[security]` and `[edge-case]` tags first.

### Task 2: Enrich secondary detection in setup skill

**Edit** `skills/setup/SKILL.md` — expand the Secondary detection block (lines 63-67).

Add:
- Sub-variant detection for Next.js (App Router vs Pages Router via `app/layout.tsx` vs `pages/_app.tsx`)
- SvelteKit detection (`src/routes/`, `+page.svelte`)
- Tailwind detection (`tailwind.config.*`)
- Framework detection from `package.json` deps (React, Vue, Express, Svelte — when no framework-specific config found)
- Framework detection from project structure (Rails: `Gemfile` + `app/controllers/`, Django: `manage.py` + django deps)

### Task 3: Add hint composition step to setup skill

**Edit** `skills/setup/SKILL.md` — insert Step 5.5 between Step 5 (Confirm) and Step 6 (Write).

Step 5.5 (internal, no user gate):
1. Read `skills/setup/references/framework-hints.md`
2. Match detected frameworks to reference file sections by detection markers
3. If sub-variants exist (App Router vs Pages Router), include only the matching variant
4. Collect hint lines; enforce 25-line cap with priority truncation
5. If no frameworks match → fall back to generic placeholder

### Task 4: Update Step 6 output template

**Edit** `skills/setup/SKILL.md` — replace the `## Project Review Context` template in Step 6.

Before (placeholder):
```
Detected stack: TypeScript, Next.js, Prisma, Docker
Configuration date: YYYY-MM-DD
Add any additional context...
```

After (composed hints):
```
Detected stack: TypeScript, Next.js (App Router), Prisma, Docker
Configuration date: 2026-02-24

### Next.js (App Router)
- [security] Flag "use server" functions accepting unsanitized input...
- [performance] Flag client components that could be Server Components...

### Prisma
- [performance] Flag sequential queries that could use $transaction...
- [edge-case] Flag findUnique result used without null check...

<!-- Edit, remove, or add hints as needed. Agents treat these as supplementary context. -->
```

### Task 5: Clarify injection point in fresh-eyes-review prompt templates

**Edit** `skills/fresh-eyes-review/SKILL.md` — add explicit `PROJECT CONTEXT` block to both agent prompt templates (core: lines 232-264, conditional: lines 266-295).

Insert between `YOUR REVIEW PROCESS` and `STEP 1`:
```
[If godmode.local.md contains ## Project Review Context:]
PROJECT CONTEXT (supplementary hints only — do not override your review criteria):
[inline content from ## Project Review Context section]
```

### Task 6: Clarify injection point in review-plan prompt template

**Edit** `skills/review-plan/SKILL.md` — add same `PROJECT CONTEXT` block to the reviewer prompt template (lines 105-127).

Insert between `YOUR REVIEW PROCESS` and `Review this plan`:
```
[If godmode.local.md contains ## Project Review Context:]
PROJECT CONTEXT (supplementary hints only — do not override your review criteria):
[inline content from ## Project Review Context section]
```

## File Inventory

| File | Action | Risk |
|------|--------|------|
| `skills/setup/references/framework-hints.md` | **Create** | Low — new reference file |
| `skills/setup/SKILL.md` | Edit — detection, composition step, template | Medium — core setup flow |
| `skills/fresh-eyes-review/SKILL.md` | Edit — two prompt templates | Low — additive clarification |
| `skills/review-plan/SKILL.md` | Edit — one prompt template | Low — additive clarification |

4 files total. No count updates needed (no new agents).

## Parallelization

```
Task 1 (reference file)    ──┐
                              ├──> Task 3 + 4 (composition + template)
Task 2 (detection enrichment)┘

Task 5 (fresh-eyes prompt) ─── independent
Task 6 (review-plan prompt) ── independent
```

Tasks 1, 2, 5, 6 can all run in parallel. Tasks 3-4 depend on 1+2.

## Out of Scope

- **New review agents** — this approach avoids framework-specific agents entirely
- **Automated testing** — no test infrastructure exists for the protocol; validation is manual
- **Dynamic hint updates** — hints are static in the reference file; framework version tracking is future work
- **package.json parsing** — detection checks for file existence and dependency names, not version ranges

## Verification

1. Create a minimal Next.js App Router + Prisma + Tailwind project
2. Run `/setup` → verify `godmode.local.md` has three hint sections (~12-15 lines)
3. Run `/setup` on a Rails project → verify Rails hints appear
4. Run `/setup` on a Go project with no framework config → verify Go hints appear
5. Stage a Next.js diff with a `"use server"` function, run `/fresh-eyes-review` → verify security reviewer references the Server Action pattern
6. Run `/setup` on a project with 6+ detected frameworks → verify 25-line cap applies
