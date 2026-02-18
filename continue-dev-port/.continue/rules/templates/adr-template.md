---
alwaysApply: false
description: "Architecture Decision Record template — referenced by /create-adr"
globs:
---

# Architecture Decision Record (ADR)

**Purpose:** Document significant architectural and design decisions with context and rationale.

**Key Insight:** 70% of technical debt comes from forgotten context. ADRs prevent "why did we build it this way?" 6 months later.

---

## ADR Template

Copy this template to `docs/adr/NNNN-title-in-kebab-case.md` (e.g., `docs/adr/0001-use-postgresql-for-database.md`)

---

# ADR-NNNN: [Short Title]

**Date:** YYYY-MM-DD

**Status:** `Proposed` | `Accepted` | `Deprecated` | `Superseded by ADR-XXXX`

**Deciders:** [Names or roles of people involved]

**Technical Story:** [Link to issue/ticket if applicable]

---

## Context

**What is the problem we're trying to solve?**

Describe the architectural or design issue you're addressing, including:
- What forces are at play (technical, political, business)
- Why is this decision necessary now?
- What constraints exist (time, resources, existing systems)
- What's the current state?

*Be specific. Include code examples, metrics, or user pain points if relevant.*

---

## Decision

**What are we doing?**

Clearly state the decision in active voice:
- "We will use PostgreSQL as our primary database"
- "We will implement event-driven architecture using Kafka"
- "We will adopt microservices for the checkout flow"

Keep this section concise (1-3 paragraphs).

---

## Consequences

**What happens as a result of this decision?**

### Positive Consequences
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

### Negative Consequences
- [Tradeoff 1]
- [Tradeoff 2]
- [Risk 1]

### Neutral Consequences
- [Impact 1]
- [Impact 2]

*Be honest about tradeoffs. Every decision has downsides.*

---

## Alternatives Considered

### Option 1: [Alternative Name]

**Pros:**
- [Pro 1]
- [Pro 2]

**Cons:**
- [Con 1]
- [Con 2]

**Why rejected:**
[Specific reason]

---

### Option 2: [Alternative Name]

**Pros:**
- [Pro 1]

**Cons:**
- [Con 1]

**Why rejected:**
[Specific reason]

---

### Option 3: Do Nothing

**Pros:**
- No change, no risk

**Cons:**
- [Why status quo is unacceptable]

**Why rejected:**
[Specific reason]

---

## Implementation Notes

**How will this decision be implemented?**

- Migration plan (if applicable)
- Rollout strategy (feature flags, phased rollout, etc.)
- Estimated effort
- Team training needed
- Documentation to update

---

## Success Metrics

**How will we know if this decision was successful?**

| Metric | Baseline | Target | Measurement Method |
|--------|----------|--------|--------------------|
| [Metric 1] | [Current value] | [Target value] | [How to measure] |
| [Metric 2] | [Current value] | [Target value] | [How to measure] |

**Review Date:** [When should we evaluate this decision? 3 months, 6 months, 1 year?]

---

## References

- [Link to related ADRs]
- [Link to design docs]
- [Link to research/blog posts]
- [Link to benchmarks/data]

---

## Notes

[Any additional context, discussion summaries, or future considerations]

---

# Example ADRs

## Example 1: Database Selection

---

# ADR-0001: Use PostgreSQL for Primary Database

**Date:** 2025-11-29

**Status:** Accepted

**Deciders:** Engineering Team, CTO

**Technical Story:** [PROJ-123](https://linear.app/project/PROJ-123)

---

## Context

We're building a new SaaS application that will handle customer data, transactions, and analytics. We need to choose a primary database that will:

- Scale to 100k+ users in first year
- Support complex queries for analytics dashboard
- Provide ACID guarantees for financial transactions
- Integrate well with our Python/Django stack
- Fit within startup budget constraints

**Current state:** Using SQLite for prototyping, but it can't handle production load.

**Constraints:**
- Small team (3 engineers), limited ops experience
- Need managed service (can't manage database cluster)
- Must support JSON data for flexible user metadata
- Compliance requires audit logs and point-in-time recovery

---

## Decision

**We will use PostgreSQL (managed via AWS RDS) as our primary database.**

Specifically:
- PostgreSQL 16 on AWS RDS
- Multi-AZ deployment for high availability
- Automated backups with 7-day retention
- Django ORM for database access

---

## Consequences

### Positive Consequences
- **ACID guarantees:** Financial transactions are safe
- **JSON support:** JSONB columns for flexible metadata
- **Mature ecosystem:** Django ORM, pgAdmin, extensive documentation
- **Scaling path:** Read replicas, connection pooling, partitioning available
- **Full-text search:** Built-in, no need for separate search engine initially
- **Managed service:** AWS handles backups, patching, monitoring

### Negative Consequences
- **Cost:** ~$200/month for RDS (vs $0 for SQLite)
- **Vendor lock-in:** Tied to AWS ecosystem
- **Complex queries can be slow:** May need caching layer (Redis) later
- **Schema migrations risky:** Downtime on large table alterations

### Neutral Consequences
- **Learning curve:** Team needs to learn PostgreSQL-specific features (JSONB, window functions)
- **Ops overhead:** Still need to monitor performance, optimize queries

---

## Alternatives Considered

### Option 1: MySQL

**Pros:**
- More widespread adoption
- Slightly better performance for simple queries
- Compatible with Aurora (serverless option)

**Cons:**
- Weaker JSON support than PostgreSQL
- Less robust ACID guarantees (depending on storage engine)
- Fewer advanced features (window functions, CTEs)

**Why rejected:**
PostgreSQL's JSON support and advanced SQL features are valuable for our analytics use case. Team also has more PostgreSQL experience.

---

### Option 2: MongoDB

**Pros:**
- Flexible schema (NoSQL)
- Horizontal scaling built-in
- Fast for simple document lookups
- Native JSON storage

**Cons:**
- No ACID transactions across collections (in older versions)
- Complex queries harder to write
- Less mature ecosystem for Python
- Not ideal for financial transactions

**Why rejected:**
We need ACID guarantees for transactions. The flexibility of NoSQL isn't worth the tradeoffs for our use case.

---

### Option 3: DynamoDB

**Pros:**
- Fully managed, serverless
- Scales automatically
- Pay-per-use pricing (potentially cheaper)
- No server maintenance

**Cons:**
- No complex queries (joins, aggregations)
- Would need separate data warehouse for analytics
- Difficult to change data model after launch
- Team has no DynamoDB experience

**Why rejected:**
Analytics dashboard requires complex queries (joins across users, transactions, subscriptions). DynamoDB would force us to denormalize heavily or add a separate data warehouse, increasing complexity.

---

## Implementation Notes

**Migration Plan:**
1. Week 1: Set up RDS instance in staging
2. Week 2: Migrate SQLite data to PostgreSQL, test in staging
3. Week 3: Update Django settings for production
4. Week 4: Production cutover (estimated 1 hour downtime for final data sync)

**Rollout Strategy:**
- Use Django migrations for schema changes
- Set up connection pooling (pgBouncer) if needed
- Configure automated backups and monitoring (CloudWatch)

**Estimated Effort:** 2 weeks

**Team Training:**
- PostgreSQL performance tuning workshop (4 hours)
- Document common query patterns in wiki

**Documentation to Update:**
- Deployment guide
- Database schema documentation
- Backup/restore procedures

---

## Success Metrics

| Metric | Baseline | Target | Measurement Method |
|--------|----------|--------|--------------------|
| Query response time (P95) | N/A | <100ms | CloudWatch metrics |
| Database uptime | N/A | 99.9% | AWS RDS dashboard |
| Zero data loss incidents | N/A | 0 incidents | Manual tracking |
| Developer satisfaction | N/A | 4/5 | Quarterly survey |

**Review Date:** 6 months (May 2026)

---

## References

- [PostgreSQL vs MySQL Comparison](https://www.2ndquadrant.com/en/postgresql-vs-mysql/)
- [Django Database Optimization Guide](https://docs.djangoproject.com/en/stable/topics/db/optimization/)
- [AWS RDS Pricing](https://aws.amazon.com/rds/postgresql/pricing/)
- Internal: [Database Schema Design Doc](docs/database-schema.md)

---

## Example 2: Frontend Framework

---

# ADR-0002: Use React with TypeScript for Frontend

**Date:** 2025-11-29

**Status:** Accepted

**Deciders:** Frontend Team Lead, Engineering Manager

**Technical Story:** [PROJ-456](https://linear.app/project/PROJ-456)

---

## Context

We're rebuilding our web application frontend. Current jQuery-based UI is hard to maintain and doesn't support modern features (real-time updates, complex state management).

**Requirements:**
- Component reusability across 10+ pages
- Real-time data updates (WebSocket integration)
- Mobile-responsive
- Type safety to prevent bugs
- Large ecosystem for UI components
- Team has mixed JS framework experience (React, Vue, Angular)

**Current state:** jQuery spaghetti code, no component architecture, frequent bugs from undefined properties.

**Constraints:**
- 4-month deadline for rewrite
- 2 frontend engineers (one mid-level, one senior)
- Need to hire 2 more engineers (easier with popular framework)

---

## Decision

**We will use React 18 with TypeScript and Vite for our frontend.**

Tech stack:
- React 18 (UI framework)
- TypeScript 5.3 (type safety)
- Vite (build tool)
- TanStack Query (data fetching)
- Tailwind CSS (styling)
- Vitest + React Testing Library (testing)

---

## Consequences

### Positive Consequences
- **Type safety:** TypeScript catches bugs at compile time (45% fewer runtime errors per MS research)
- **Large ecosystem:** Huge component library ecosystem (shadcn/ui, Material-UI, Ant Design)
- **Hiring:** Easy to find React developers
- **Performance:** React 18 concurrent features improve UX
- **Developer experience:** Hot module replacement, fast builds with Vite
- **Community:** Massive community, easy to find solutions

### Negative Consequences
- **Bundle size:** React is larger than Vue/Svelte (45KB min+gzip)
- **Learning curve:** TypeScript + React hooks steep for junior devs
- **Boilerplate:** More verbose than Vue single-file components
- **Over-engineering risk:** Easy to over-complicate with too many libraries

### Neutral Consequences
- **Opinionated routing:** Need to choose routing library (we chose React Router)
- **State management:** Multiple options (Context, Zustand, Redux) - we chose Context + TanStack Query

---

## Alternatives Considered

### Option 1: Vue 3 + TypeScript

**Pros:**
- Simpler learning curve than React
- Better TypeScript integration out-of-the-box
- Smaller bundle size
- Single-file components easier to understand

**Cons:**
- Smaller ecosystem than React
- Harder to hire Vue developers
- Less momentum in 2025 (React still dominates)

**Why rejected:**
Hiring is a major concern. React's ecosystem and hiring pool outweigh Vue's simplicity advantages.

---

### Option 2: Svelte

**Pros:**
- Smallest bundle size (10KB!)
- No virtual DOM (better performance)
- Most loved framework (Stack Overflow survey)
- Compile-time optimization

**Cons:**
- Very small ecosystem (few component libraries)
- Much harder to hire Svelte developers
- Less mature tooling
- Risk: Framework could lose momentum

**Why rejected:**
Too risky for a startup. Hiring Svelte developers would be nearly impossible. Ecosystem too immature.

---

### Option 3: Angular

**Pros:**
- Batteries-included (routing, forms, HTTP built-in)
- Strong TypeScript support (Angular is TS-first)
- Good for large enterprise apps

**Cons:**
- Steep learning curve (RxJS, dependency injection)
- Verbose and opinionated
- Declining popularity (Google doesn't promote as much)
- Team has no Angular experience

**Why rejected:**
Too complex for our team size and timeline. React is more pragmatic.

---

## Implementation Notes

**Migration Plan:**
1. Month 1: Set up React+TS+Vite boilerplate, migrate 2 simple pages
2. Month 2: Migrate 5 core pages (dashboard, settings, etc.)
3. Month 3: Migrate remaining pages, add tests
4. Month 4: Polish, performance optimization, cutover

**Rollout Strategy:**
- Feature flag to toggle between old/new UI
- Gradual rollout: 10% -> 25% -> 50% -> 100% of users
- Monitor error rates, performance metrics

**Estimated Effort:** 4 months (2 engineers full-time)

**Team Training:**
- React hooks workshop (1 day)
- TypeScript best practices (1 day)
- Internal component library setup

---

## Success Metrics

| Metric | Baseline (jQuery) | Target (React) | Measurement Method |
|--------|-------------------|----------------|--------------------|
| Page load time (P95) | 3.2s | <2s | Lighthouse CI |
| Bug rate | 12 bugs/month | <6 bugs/month | Linear tracking |
| Developer velocity | 2 features/sprint | 3 features/sprint | Sprint tracking |
| Time to hire frontend dev | 90 days | <60 days | HR metrics |

**Review Date:** 1 year (November 2026)

---

## References

- [State of JS 2024](https://stateofjs.com/)
- [React 18 Announcement](https://react.dev/blog/2022/03/29/react-v18)
- [TypeScript Benefits Research (Microsoft)](https://www.microsoft.com/en-us/research/publication/to-type-or-not-to-type-quantifying-detectable-bugs-in-javascript/)
- Internal: [Component Library Design System](docs/design-system.md)

---

## When to Create an ADR

Create an ADR for decisions that:

- **Are hard to reverse:** Database choice, frontend framework, cloud provider
- **Have significant impact:** Affect multiple teams, long-term architecture
- **Involve tradeoffs:** Where alternatives existed and you chose one
- **Will be questioned later:** "Why didn't we use X instead?"

**Don't create ADRs for:**
- Trivial choices (CSS framework, icon library)
- Decisions that are easily reversible
- Implementation details (which specific package for form validation)

---

## ADR Workflow

1. **Propose:** Create ADR with status `Proposed`, circulate for feedback
2. **Discuss:** Team reviews, suggests alternatives, challenges assumptions
3. **Decide:** Team makes final decision, update status to `Accepted`
4. **Implement:** Build according to ADR
5. **Review:** After review date, update ADR or create superseding ADR

---

## Maintaining ADRs

- **Never delete ADRs:** They are historical record
- **Update status only:** Deprecated, Superseded by ADR-XXXX
- **Link ADRs:** Reference related ADRs in "References" section
- **Review periodically:** Set review dates, create new ADR if decision changes

---

**Last Updated:** November 2025
**Based on:** Michael Nygard's ADR template, MADR, AWS Well-Architected Framework
**See Also:** [ADR GitHub Organization](https://adr.github.io)
