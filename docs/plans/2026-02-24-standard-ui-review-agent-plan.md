---
title: "Add UI Review Agent to Fresh Eyes Review Pipeline"
date: 2026-02-24
complexity: standard
status: complete
risk_flags: []
---

# Add UI Review Agent to Fresh Eyes Review Pipeline

## Problem

The review pipeline has 12 specialist agents covering security, code quality, performance, API contracts, concurrency, error handling, dependencies, testing, documentation, and edge cases. None review frontend/UI code for:

- **Accessibility (a11y)** — semantic HTML, ARIA attributes, keyboard navigation, focus management, screen reader support
- **Component quality** — prop drilling, component size, separation of logic and presentation
- **Responsive design** — breakpoints, flexible units, touch targets, viewport handling
- **UI performance** — unnecessary re-renders, heavy DOM, animation performance, image optimization
- **Form UX** — input types, validation feedback, error-input association, autocomplete attributes
- **Internationalization readiness** — hardcoded user-facing strings, RTL assumptions, locale-dependent formatting
- **Visual consistency** — design token usage, inconsistent styling approaches

The **spec-flow-reviewer** covers some UI concerns (loading states, empty states, accessibility) but it reviews **plans**, not **code diffs**. The closest diff-reviewing agents (code-quality, edge-case) are domain-agnostic — they miss UI-specific patterns.

Any project with a frontend component (React, Vue, Svelte, Angular, plain HTML/CSS) has a blind spot.

## Design Decisions

### Agent Classification: Conditional (not Core)

The UI reviewer should be a **conditional agent** — triggered by diff content, not run on every review. Rationale:
- Backend-only changes gain nothing from UI review
- Smart selection already handles this pattern for 7 other agents
- Keeps review pipeline fast for non-frontend work

### Model Tier: sonnet

Sonnet balances capability with cost/speed. Same tier as code-quality, edge-case, performance, and error-handling reviewers. The review domain is well-defined enough that opus is unnecessary.

### Subagent Type

Existing review agents map to built-in Claude Code subagent_types (`security-reviewer`, `code-quality-reviewer`, etc.). A `ui-reviewer` subagent_type does not exist yet. Two paths:

- **Immediate:** Use `general-purpose` subagent_type. Works today, has all tools (including Read which is the only one agents need). Agent behavior comes entirely from the inlined prompt.
- **Follow-up:** Register `ui-reviewer` as a native subagent_type in Claude Code configuration for naming consistency.

Recommend: start with `general-purpose`, register proper type later.

### Scope Boundaries

What the UI reviewer **covers** vs what other agents already cover:

| Concern | UI Reviewer | Other Agent |
|---------|-------------|-------------|
| Semantic HTML / ARIA | Yes | - |
| Keyboard navigation | Yes | - |
| Focus management | Yes | - |
| Component structure | Yes | Code quality (generic SOLID) |
| Responsive design | Yes | - |
| Render performance | Yes | Performance (DB/query focus) |
| Form validation UX | Yes | Edge case (null/boundary values) |
| Hardcoded strings (i18n) | Yes | - |
| Image optimization | Yes | - |
| CSS/animation perf | Yes | - |
| Design token consistency | Yes | - |
| Loading/error/empty states | Yes (in code) | Spec-flow (in plans) |

Overlap is minimal and complementary, not duplicative.

## Changes

### Task 1: Create agent definition — `agents/review/ui-reviewer.md`

New file following the established pattern (YAML frontmatter + Philosophy + When to Invoke + Review Process + Output Format + Examples).

**Review process checkpoints (8):**

1. **Semantic HTML and ARIA** — Verify meaningful element usage (`<button>` not `<div onClick>`), ARIA labels on interactive elements, ARIA roles where semantic elements aren't used, `aria-live` for dynamic content, `aria-hidden` for decorative elements. Flag `<div>` or `<span>` used as interactive controls without role/tabIndex/keyboard handlers.

2. **Keyboard navigation and focus** — All interactive elements reachable via Tab. Focus order follows visual layout. Focus visible (no `outline: none` without replacement). Focus trapped in modals/dialogs. Focus restored on close. Custom components handle Enter/Space/Escape. Flag click-only handlers without keyboard equivalents.

3. **Component structure** — Components under ~200 lines (flag over 300). Presentation separated from logic (hooks, utilities). Props explicit and typed. No prop drilling beyond 2 levels (use context/state management). Key prop on list-rendered items. Event handler cleanup in effects. Flag state in components that could be derived.

4. **Responsive design and layout** — Media queries or container queries for layout shifts. No fixed pixel widths on containers. Touch targets minimum 44x44px. Text uses relative units (`rem`/`em`). Images use responsive patterns (`srcset`, `sizes`, or CSS `object-fit`). Flag horizontal scroll on common viewport widths.

5. **UI performance** — Expensive computations memoized (`useMemo`/`useCallback` or framework equivalent). Lists virtualized when potentially large (>100 items). Images lazy-loaded below fold. Animations use `transform`/`opacity` (GPU-composited) not `top`/`left`/`width`. Flag re-renders caused by object/array literals in JSX props. Flag large inline SVGs that could be icons.

6. **Form UX and validation** — Inputs use correct `type` attribute (`email`, `tel`, `number`, etc.). Labels associated via `htmlFor`/`id` or wrapping. Error messages associated with inputs (`aria-describedby`). Validation feedback shown inline near the input, not just at form top. Submit buttons show loading state during async submission. Flag form patterns that prevent browser autofill.

7. **Internationalization readiness** — User-facing strings extracted to constants, i18n keys, or string tables — not inline in JSX. No text baked into images. Number/date/currency formatting uses locale-aware APIs (`Intl.*`). Layout doesn't break with longer translated strings (no fixed-width text containers). Flag string concatenation for sentences (breaks translation word order).

8. **Visual consistency** — Design tokens (CSS variables, theme values) used for colors, spacing, typography — not raw hex/px values. Consistent spacing patterns. Z-index values from a defined scale (not arbitrary numbers). Dark mode compatibility if theme system exists. Flag one-off color values or spacing that deviate from project patterns.

**Output format:**
```
UI REVIEW FINDINGS:

CRITICAL:
- [UI-001] [Category] Finding — file:line
  Evidence: code snippet (1-2 lines)
  Fix: specific remediation

HIGH/MEDIUM/LOW: [same format]

Recommendation: BLOCK | FIX_BEFORE_COMMIT | APPROVED
Confidence: HIGH | MEDIUM | LOW
```

### Task 2: Add trigger patterns — `skills/fresh-eyes-review/references/trigger-patterns.md`

Add a new `## UI Reviewer` section:

**File path patterns:**
- `component|page|view|layout|screen|modal|dialog|form|widget`

**File extension patterns (in diff):**
- `.tsx|.jsx|.vue|.svelte|.html|.css|.scss|.less`

**Diff content patterns:**
- `className|class=|style=|styled\(|css\`|<div|<span|<button|<input|<form|<select|<textarea|<img|<a\s|aria-|role=|tabIndex|onClick|onChange|onSubmit|useRef|useState|useEffect|ref=|v-model|v-bind|v-on|@click|\$emit`

**LOC threshold:** None (any frontend file change is sufficient)

### Task 3: Update conditional agent roster — `skills/fresh-eyes-review/SKILL.md`

1. Update frontmatter description: "11-agent" -> "12-agent" (or keep it generic, e.g., "multi-agent")
2. Add row to Conditional Agents table:

```
| 13 | UI Reviewer | sonnet | Frontend file patterns (.tsx/.jsx/.vue/.svelte/.css), UI component/DOM patterns |
```

3. Add agent definition reference to the execution pattern section:
```
- `agents/review/ui-reviewer.md` (if triggered)
```

4. Add trigger summary to the Step 2 trigger patterns table:

```
| UI | `className\|style=\|styled\|<div\|<button\|<input\|<form\|<img\|aria-\|role=\|tabIndex`, component/page/view/layout paths, .tsx/.jsx/.vue/.svelte/.css files |
```

### Task 4: Update guide — `guides/FRESH_EYES_REVIEW.md`

Add row to Conditional Agents table matching the SKILL.md update.

### Task 5: Update setup skill — `skills/setup/SKILL.md`

1. Add `UI Reviewer` to Step 4 agent selection options:
```
- label: "UI Reviewer"
  description: "Accessibility, responsive design, component quality, form UX, i18n readiness"
```

2. Update Frontend preset to include `ui-reviewer`:
```
### Frontend (React/Vue/Angular/Svelte detected)
Add: `testing-adequacy-reviewer`, `performance-reviewer`, `ui-reviewer`
```

3. Add to Available Review Agents Reference table.

### Task 6: Update reference counts

Files referencing agent counts:
- `CLAUDE.md` `PROJECT_CONVENTIONS.md`: "15 review agent definitions" -> "16 review agent definitions"
- `skills/fresh-eyes-review/SKILL.md` frontmatter: "11-agent" -> "12-agent"

## File Inventory

| File | Action | Risk |
|------|--------|------|
| `agents/review/ui-reviewer.md` | **Create** | Low — new file, no existing code affected |
| `skills/fresh-eyes-review/references/trigger-patterns.md` | Edit — add section | Low — additive |
| `skills/fresh-eyes-review/SKILL.md` | Edit — roster table, trigger table, agent refs | Medium — core review orchestration |
| `guides/FRESH_EYES_REVIEW.md` | Edit — conditional agents table | Low — documentation |
| `skills/setup/SKILL.md` | Edit — options, preset, reference table | Low — configuration |
| `guides/PROJECT_CONVENTIONS.md` | Edit — agent count | Low — documentation |

## Out of Scope

- **Registering `ui-reviewer` as a native Claude Code subagent_type** — follow-up task after initial integration works with `general-purpose`
- **WCAG compliance depth** — the agent flags common violations, not full WCAG 2.2 AA audit. That requires visual rendering access we don't have.
- **Visual regression** — diff-based text review cannot catch visual regressions. Note this limitation in the agent philosophy.
- **Framework-specific linting rules** — the agent reviews patterns, not lint violations (that's what eslint-plugin-jsx-a11y etc. are for). It should complement automated linting, not duplicate it.

## Testing Strategy

1. Create a test diff with intentional UI issues (div-as-button, missing alt text, inline styles, hardcoded strings, fixed-width containers)
2. Stage it, run `/fresh-eyes-review`
3. Verify UI Reviewer triggers and produces findings
4. Verify Supervisor consolidates UI findings correctly
5. Verify Adversarial Validator can verify/challenge UI claims
