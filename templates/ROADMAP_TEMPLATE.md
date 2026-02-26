# Roadmap Template

Use this template when generating roadmaps via `/roadmap`. Select the appropriate tier based on product maturity and planning horizon.

---

## Tier Selection Guide

| Tier | When to Use | Indicators |
|------|-------------|------------|
| **Minimal** | Early-stage product, short horizon, quick alignment | ≤ 3 months, small team, vision still forming |
| **Standard** | Growing product, multi-month planning, team alignment | 3-12 months, multiple stakeholders, strategic themes emerging |

---

## Minimal Roadmap

```markdown
---
type: roadmap
title: "[Product Name] Roadmap"
date: YYYY-MM-DD
status: active  # options: active, archived
product: "[product-name]"
tier: minimal
---

# [Product Name] Roadmap

**Vision:** [one-sentence vision statement]
**Horizon:** [time range]
**Last Updated:** [date]

## Now (Current Focus)

### [Epic Name]
- **Problem:** [what user problem this solves]
- **Priority:** Must Have / Should Have / Could Have
- **Success Metric:** [how we know this worked]

### [Epic Name]
- **Problem:** ...
- **Priority:** ...
- **Success Metric:** ...

## Next (Up Next)

### [Epic Name]
- **Problem:** ...
- **Priority:** ...
- **Success Metric:** ...

## Later (Future)

### [Epic Name]
- **Problem:** ...
- **Priority:** ...
- **Success Metric:** ...

## Open Questions
- [ ] [Question that needs answering before committing]
- [ ] ...

## Out of Scope
- [Explicitly excluded item and why]
- ...
```

---

## Standard Roadmap

```markdown
---
type: roadmap
title: "[Product Name] Roadmap"
date: YYYY-MM-DD
status: active  # options: active, archived
product: "[product-name]"
tier: standard
---

# [Product Name] Roadmap

**Vision:** [one-sentence vision statement]
**Horizon:** [time range]
**Last Updated:** [date]

## Strategic Themes

| # | Theme | Description | Priority |
|---|-------|-------------|----------|
| 1 | [Theme Name] | [one-line description] | Must Have |
| 2 | [Theme Name] | [one-line description] | Should Have |
| 3 | [Theme Name] | [one-line description] | Could Have |

## Now (Current Quarter / Month 1-3)

### [Epic Name]
- **Theme:** [parent theme]
- **Problem:** [what user problem this solves]
- **Hypothesis:** If we [action], then [persona] will [outcome], evidenced by [metric]
- **Success Metric:** [measurable outcome]
- **Priority:** Must Have
- **Stories:** (see backlog)

### [Epic Name]
- **Theme:** ...
- **Problem:** ...
- **Hypothesis:** ...
- **Success Metric:** ...
- **Priority:** ...
- **Stories:** (see backlog)

## Next (Month 3-6)

### [Epic Name]
- **Theme:** ...
- **Problem:** ...
- **Hypothesis:** ...
- **Success Metric:** ...
- **Priority:** ...

## Later (Month 6+)

### [Epic Name]
- **Theme:** ...
- **Problem:** ...
- **Hypothesis:** ...
- **Success Metric:** ...
- **Priority:** ...

## Success Metrics Summary

| Metric | Current Baseline | Target | Timeline |
|--------|-----------------|--------|----------|
| [metric name] | [current value or "unknown"] | [target value] | [by when] |

## Open Questions & Risks
- [ ] [Question or risk that could affect priorities]
- [ ] ...

## Decisions Made
- [Date] — [Decision and rationale]
- ...

## Out of Scope
- [Explicitly excluded item and why]
- ...
```

---

## Example (Minimal Tier)

```markdown
---
type: roadmap
title: "TaskFlow Roadmap"
date: 2026-02-25
status: active
product: "taskflow"
tier: minimal
---

# TaskFlow Roadmap

**Vision:** Help busy teams capture and organize work in seconds, not spreadsheets.
**Horizon:** Q1 2026 (3 months)
**Last Updated:** 2026-02-25

## Now (Current Focus)

### Shared Lists Foundation
- **Problem:** Teams can't collaborate on task lists; each person uses their own tool.
- **Priority:** Must Have
- **Success Metric:** 50% of users create a shared list within first week.

### Mobile App MVP
- **Problem:** Users can't access tasks on the go; desktop-only limits adoption.
- **Priority:** Must Have
- **Success Metric:** Mobile app reaches 1,000 downloads in Q1.

## Next (Up Next)

### Recurring Tasks
- **Problem:** Users repeat the same task setup weekly; wastes time.
- **Priority:** Should Have
- **Success Metric:** 30% of power users enable recurring tasks.

## Later (Future)

### Slack Integration
- **Problem:** Task notifications bury in email; users miss deadlines.
- **Priority:** Could Have
- **Success Metric:** Integrate with 3 leading communication platforms.

## Open Questions
- [ ] Should we support task templates in the first release?
- [ ] What's the minimum viable Slack integration scope?

## Out of Scope
- Gantt charts (visual planning tool later, not now)
- Custom workflows (MVP supports basic flow only)
```
