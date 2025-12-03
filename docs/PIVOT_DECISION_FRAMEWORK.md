# Pivot Decision Framework: Code Archaeologist vs Context Engine

**Date:** December 2025
**Purpose:** Rigorous comparison of two pivot opportunities for GODMODE protocol

---

## Executive Summary

| Dimension | Code Archaeologist | Context Engine | Winner |
|-----------|-------------------|----------------|--------|
| Market Timing | Urgent (2024 problem) | Perennial | Archaeologist |
| TAM | $2-5B (debt remediation) | $10-20B (dev productivity) | Context Engine |
| Differentiation | High (novel angle) | Medium (gaps in crowded space) | Archaeologist |
| Technical Moat | Low (features copyable) | High (data network effects) | Context Engine |
| Time to MVP | 2-3 months | 4-6 months | Archaeologist |
| Revenue Model | Project-based + recurring | Pure recurring | Context Engine |
| Competitive Risk | Medium | High | Archaeologist |
| Strategic Value | Acquisition target | Platform play | Context Engine |

**Recommendation:** Start with **Code Archaeologist** (faster validation, urgent pain), build toward **Context Engine** (larger opportunity, stronger moat).

---

## Decision Framework Criteria

### 1. Market Opportunity

#### Code Archaeologist

| Factor | Assessment | Score |
|--------|------------|-------|
| **Problem Urgency** | Crisis emerged 2024, getting worse monthly | 9/10 |
| **Problem Awareness** | Growing (62% cite tech debt as #1 frustration) | 7/10 |
| **Willingness to Pay** | High for enterprises with accumulated debt | 8/10 |
| **Market Size** | $2-5B (tech debt remediation services) | 6/10 |
| **Growth Rate** | Explosive (10x code duplication since 2022) | 9/10 |

**Market Score: 39/50**

#### Context Engine

| Factor | Assessment | Score |
|--------|------------|-------|
| **Problem Urgency** | Perennial pain, not crisis | 6/10 |
| **Problem Awareness** | Very high (26% productivity loss known) | 9/10 |
| **Willingness to Pay** | Medium (many free alternatives) | 6/10 |
| **Market Size** | $10-20B (developer productivity tools) | 9/10 |
| **Growth Rate** | Steady (grows with dev population) | 6/10 |

**Market Score: 36/50**

---

### 2. Competitive Landscape

#### Code Archaeologist

| Competitor | Overlap | Threat Level |
|------------|---------|--------------|
| SonarQube | Code quality, not AI-specific | Low |
| Snyk | Security scanning, not cleanup | Low |
| CodeClimate | Tech debt metrics, not remediation | Medium |
| Stepsize | Debt tracking, not AI-specific | Medium |
| **Nobody** | AI code attribution + cleanup | **Gap exists** |

**Competitive Advantage:** First mover in "AI code cleanup" specifically
**Risk:** Large players could add features quickly
**Competitive Score: 8/10**

#### Context Engine

| Competitor | Overlap | Threat Level |
|------------|---------|--------------|
| Sourcegraph Cody | Code indexing, search | High |
| Swimm | Documentation sync | Medium |
| CodeSee | Dependency visualization | Medium |
| GitLoop | Codebase chat | Medium |
| Greptile | Codebase understanding API | High |
| Cursor | Built-in context | High |

**Competitive Advantage:** Decision memory + session persistence (gaps)
**Risk:** Incumbents could add these features
**Competitive Score: 5/10**

---

### 3. Technical Feasibility

#### Code Archaeologist

| Component | Complexity | Existing Tech |
|-----------|------------|---------------|
| AI code detection | Medium | Git blame + heuristics + ML |
| Duplication finder | Low | Existing tools (jscpd, etc.) |
| Dead code detection | Medium | Static analysis exists |
| Safe refactoring | High | Tree-sitter + Claude |
| Dashboard | Low | Standard web stack |

**Technical Risk:** Medium - mostly combining existing capabilities
**Time to MVP:** 2-3 months
**Technical Score: 7/10**

#### Context Engine

| Component | Complexity | Existing Tech |
|-----------|------------|---------------|
| Semantic code index | High | Embeddings + vector DB |
| Decision memory | High | Custom knowledge graph |
| Session persistence | Medium | Standard DB + retrieval |
| Cross-tool API | Medium | REST/GraphQL standard |
| Knowledge extraction | High | NLP + LLM orchestration |

**Technical Risk:** High - requires novel knowledge graph architecture
**Time to MVP:** 4-6 months
**Technical Score: 5/10**

---

### 4. Defensibility & Moat

#### Code Archaeologist

| Moat Type | Strength | Durability |
|-----------|----------|------------|
| **Brand** | "The AI debt cleanup company" | Medium |
| **Data** | Minimal - each cleanup is independent | Low |
| **Network** | None | None |
| **Switching Cost** | Low - can use once and leave | Low |
| **Technical** | Features easily copied | Low |

**Moat Score: 3/10**

#### Context Engine

| Moat Type | Strength | Durability |
|-----------|----------|------------|
| **Brand** | "The codebase memory layer" | Medium |
| **Data** | High - accumulated Q&A, decisions | High |
| **Network** | Medium - more users = better answers | Medium |
| **Switching Cost** | High - decision history is valuable | High |
| **Technical** | Knowledge graph is hard to replicate | Medium |

**Moat Score: 7/10**

---

### 5. Business Model & Unit Economics

#### Code Archaeologist

| Metric | Estimate | Notes |
|--------|----------|-------|
| **Pricing Model** | Per-repo scan + subscription | Hybrid |
| **Initial Scan** | $500-5,000/repo | Based on size |
| **Monitoring** | $99-499/mo/repo | Ongoing |
| **Gross Margin** | 60-70% | LLM costs for analysis |
| **CAC** | High | Enterprise sales motion |
| **LTV** | Medium | Churn after cleanup |

**Revenue Predictability:** Medium (project + recurring mix)
**Business Model Score: 6/10**

#### Context Engine

| Metric | Estimate | Notes |
|--------|----------|-------|
| **Pricing Model** | Per-seat subscription | Pure SaaS |
| **Team Tier** | $29/dev/mo | |
| **Enterprise** | Custom ($50-100/dev/mo) | |
| **Gross Margin** | 70-80% | Lower LLM costs (indexing amortized) |
| **CAC** | Medium | PLG possible |
| **LTV** | High | Sticky due to data |

**Revenue Predictability:** High (pure recurring)
**Business Model Score: 8/10**

---

### 6. Strategic Fit with GODMODE

#### Code Archaeologist

| Protocol Asset | Usage |
|----------------|-------|
| Security Checklist | Audit existing AI code for vulnerabilities |
| Code Review Checklist | Grade code quality of AI-generated sections |
| Fresh Eyes Review | Apply retroactively to orphaned code |
| ADR Template | Reconstruct missing decisions |

**Fit Score: 7/10** - Protocol becomes remediation playbook

#### Context Engine

| Protocol Asset | Usage |
|----------------|-------|
| PRD Template | Business context capture schema |
| ADR Template | Decision memory structure |
| CODEBASE_MAP.md | Initial knowledge graph seed |
| Communication Protocol | Status indicators for context state |

**Fit Score: 8/10** - Protocol defines what context to capture

---

### 7. Go-to-Market Strategy

#### Code Archaeologist

| Phase | Strategy | Timeline |
|-------|----------|----------|
| **Awareness** | Content: "Your codebase has AI debt" audits | Month 1-2 |
| **Acquisition** | Free scan tool, paid remediation | Month 3-4 |
| **Activation** | Show debt metrics, pain quantification | Month 3-4 |
| **Revenue** | Enterprise sales, per-repo pricing | Month 5+ |
| **Expansion** | Monitoring subscriptions | Month 6+ |

**GTM Complexity:** Medium
**GTM Score: 7/10**

#### Context Engine

| Phase | Strategy | Timeline |
|-------|----------|----------|
| **Awareness** | Content: "Why does your AI forget everything?" | Month 1-3 |
| **Acquisition** | Free tier, VS Code extension | Month 4-6 |
| **Activation** | "Ask your codebase" demo moments | Month 4-6 |
| **Revenue** | Seat-based upgrades | Month 7+ |
| **Expansion** | Enterprise, cross-repo, SSO | Month 9+ |

**GTM Complexity:** High (PLG requires polish)
**GTM Score: 5/10**

---

### 8. Risk Assessment

#### Code Archaeologist

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Market too small | Medium | High | Pivot to Context Engine |
| Feature copied by SonarQube | Medium | High | Move fast, build brand |
| Enterprises solve internally | Low | Medium | Offer expertise, not just tool |
| AI debt decreases as tools improve | Medium | High | Capture market now |

**Overall Risk: Medium**

#### Context Engine

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Sourcegraph adds features | High | High | Focus on decisions/memory gap |
| Cursor builds native persistence | High | High | Be tool-agnostic layer |
| Technical complexity delays MVP | Medium | Medium | Start with simpler indexing |
| Enterprises won't share data | Medium | Medium | On-prem option |

**Overall Risk: High**

---

## Weighted Scoring Matrix

| Criterion | Weight | Archaeologist | Context Engine |
|-----------|--------|---------------|----------------|
| Market Opportunity | 20% | 39/50 (7.8) | 36/50 (7.2) |
| Competitive Position | 20% | 8/10 | 5/10 |
| Technical Feasibility | 15% | 7/10 | 5/10 |
| Defensibility/Moat | 15% | 3/10 | 7/10 |
| Business Model | 15% | 6/10 | 8/10 |
| Strategic Fit | 10% | 7/10 | 8/10 |
| GTM Strategy | 5% | 7/10 | 5/10 |

### Weighted Scores

**Code Archaeologist:**
- (0.20 × 7.8) + (0.20 × 8) + (0.15 × 7) + (0.15 × 3) + (0.15 × 6) + (0.10 × 7) + (0.05 × 7)
- = 1.56 + 1.60 + 1.05 + 0.45 + 0.90 + 0.70 + 0.35
- = **6.61/10**

**Context Engine:**
- (0.20 × 7.2) + (0.20 × 5) + (0.15 × 5) + (0.15 × 7) + (0.15 × 8) + (0.10 × 8) + (0.05 × 5)
- = 1.44 + 1.00 + 0.75 + 1.05 + 1.20 + 0.80 + 0.25
- = **6.49/10**

**Result: Very close.** Archaeologist wins slightly on near-term execution; Context Engine wins on long-term value.

---

## Scenario Analysis

### Scenario A: Archaeologist Succeeds

```
Year 1: Launch debt scanner, 50 enterprise customers, $500K ARR
Year 2: Monitoring subscriptions, 200 customers, $2M ARR
Year 3: Acqui-hired by Snyk/SonarQube for $15-30M
```

**Outcome:** Good exit, limited upside

### Scenario B: Context Engine Succeeds

```
Year 1: MVP launch, 500 free users, $100K ARR
Year 2: Enterprise tier, 2,000 users, $1M ARR
Year 3: Platform adoption, 10,000 users, $5M ARR
Year 4: Series A, expand to become "dev memory platform", $20M+ ARR
```

**Outcome:** Larger potential, but higher risk path

### Scenario C: Archaeologist → Context Engine

```
Year 1: Launch Archaeologist, prove value, $500K ARR
Year 2: Add context features (decision capture, session memory)
Year 3: Position shift: "From cleanup to prevention"
Year 4: Full Context Engine with debt prevention built-in
```

**Outcome:** De-risked path to larger opportunity

---

## Recommendation: Sequenced Approach

### Phase 1: Code Archaeologist (Months 1-6)

**Why start here:**
1. Faster to MVP (2-3 months)
2. Urgent pain point (customers seeking solutions NOW)
3. Clear differentiation (nobody else doing this)
4. Validates willingness to pay
5. Generates revenue while building bigger vision

**Deliverables:**
- AI code detection scanner
- Duplication/dead code mapper
- Remediation recommendations
- Basic dashboard

### Phase 2: Add Context Capture (Months 6-12)

**Expand Archaeologist with:**
- Decision documentation (why was this code written?)
- Knowledge extraction from cleanup process
- Session memory for ongoing work

**This creates:**
- Stickier product (not just cleanup, but prevention)
- Data asset (learnings from cleanups)
- Bridge to Context Engine

### Phase 3: Full Context Engine (Months 12-18)

**Pivot positioning from:**
- "Clean up AI debt" → "Prevent AI debt + understand your codebase"

**Add:**
- Full semantic indexing
- Cross-tool API
- Enterprise knowledge graph

---

## Decision Criteria

**Choose Archaeologist-first if:**
- [x] Want faster market validation
- [x] Have limited runway (<12 months)
- [x] Prefer lower technical risk
- [x] Want clearer differentiation

**Choose Context Engine-first if:**
- [ ] Have longer runway (18+ months)
- [ ] Want to build platform company
- [ ] Have strong technical team for knowledge graph
- [ ] Willing to compete with Sourcegraph/Cursor

---

## Final Verdict

**Start with Code Archaeologist**, but design it with Context Engine in mind.

The Archaeologist gives you:
- Near-term revenue and validation
- Customer relationships with enterprises who have AI debt
- Data about what context is missing (inputs for Context Engine)
- A story: "We cleaned up your mess, now let's prevent the next one"

The Context Engine becomes the **expansion path**, not the starting point.

---

**Status:** READY_FOR_REVIEW
**Confidence:** MEDIUM_CONFIDENCE
**Next Step:** Decide on approach and begin MVP spec
