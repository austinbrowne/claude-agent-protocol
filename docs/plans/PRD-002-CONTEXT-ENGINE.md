# PRD-002: Context Engine

**Product Name:** Context Engine (Codebase Brain)
**Version:** 1.0
**Status:** Draft
**Author:** Product Team
**Date:** December 2025
**Implementation:** Claude Code with human oversight

---

## 0. Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | Dec 2025 | Product Team | Initial draft |
| 1.0 | Dec 2025 | Product Team | Complete PRD for implementation |

**Reviewers:** Engineering Lead, ML/AI, Product
**Approval Status:** Pending

---

## 1. Executive Summary

### 1.1 Problem Statement

AI coding assistants suffer from critical context limitations:
- **26% of productivity** lost to "gathering project context" (2024 State of Developer Productivity)
- **Model accuracy drops** after 32K tokens (Stanford/Berkeley research)
- **Session amnesia**: AI forgets everything between conversations
- **Missing "why"**: Tools explain what code does, not why decisions were made
- **3-6 months** to onboard a developer to full productivity

**The gap:** Every AI tool rebuilds context from scratch. Nobody provides a **persistent layer** that remembers decisions, history, and institutional knowledge.

### 1.2 Solution

Context Engine is the **long-term memory layer** for AI-assisted development:
1. **Semantic Code Index** — Full codebase understanding with embeddings
2. **Decision Memory** — Captures why things were built, not just what
3. **Session Continuity** — Remembers past conversations and explorations
4. **Knowledge Graph** — Maps who knows what, expertise topology
5. **Context API** — Feeds any AI tool (Claude Code, Cursor, Copilot)

### 1.3 Target Users

| Segment | Role | Pain Point |
|---------|------|------------|
| **Primary** | Developers using AI tools | "My AI assistant forgets everything" |
| **Secondary** | Engineering Leads | "New devs take 6 months to ramp up" |
| **Tertiary** | Platform Teams | "We need a unified context layer" |

### 1.4 Success Metrics

| Metric | Target | Timeframe |
|--------|--------|-----------|
| Indexed repositories | 500 | Month 4 |
| Daily active users | 1,000 | Month 6 |
| Context queries/day | 10,000 | Month 6 |
| Developer onboarding time reduction | 40% | Month 9 |
| MRR | $30K | Month 9 |

---

## 2. Problem Deep Dive

### 2.1 The Context Crisis

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE CONTEXT GAP                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Enterprise Monorepo:     │  AI Context Window:                 │
│  ┌─────────────────────┐  │  ┌─────────────────────┐           │
│  │                     │  │  │                     │           │
│  │   5,000+ files      │  │  │   32K tokens        │           │
│  │   2M+ lines         │  │  │   (effective)       │           │
│  │   10M+ tokens       │  │  │                     │           │
│  │                     │  │  │   Lost-in-middle    │           │
│  │   + decisions       │  │  │   after 32K         │           │
│  │   + history         │  │  │                     │           │
│  │   + tribal knowledge│  │  │   No persistence    │           │
│  │                     │  │  │                     │           │
│  └─────────────────────┘  │  └─────────────────────┘           │
│                           │                                     │
│         10M tokens        │         32K tokens                  │
│                           │                                     │
│              ════════ 300x GAP ════════                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 What Gets Lost

| Knowledge Type | Example | Current State |
|----------------|---------|---------------|
| **Architectural Decisions** | "Why Postgres over MongoDB?" | Lost when author leaves |
| **Rejected Alternatives** | "We tried X but it failed because..." | Never documented |
| **Tribal Knowledge** | "Ask Sarah about payments" | In people's heads |
| **Business Context** | "This feature was for client X" | Scattered in tickets |
| **Session History** | "Yesterday we explored approach A" | Forgotten |
| **Cross-Repo Context** | "This depends on the auth service" | Manual lookup |

### 2.3 User Research Findings

From industry research:
- 26% of productivity lost to context gathering (2024 Productivity Report)
- 23 minutes to recover focus after context switch (UC Irvine)
- 3-6 months to onboard to large codebase (DX Newsletter)
- 46% don't trust AI output accuracy (Stack Overflow 2024)
- Model accuracy drops significantly after 32K tokens (Stanford/Berkeley)

### 2.4 Jobs to Be Done

| Job | Current Solution | Pain Level |
|-----|------------------|------------|
| "Understand why code was written this way" | Read git blame, ask around | High |
| "Remember what I explored yesterday" | Manual notes, lost context | High |
| "Find who knows about this subsystem" | Ask in Slack, hope for answer | Medium |
| "Get AI to understand my whole codebase" | Copy-paste context, pray | Critical |
| "Onboard new developers faster" | Pair programming, slow ramp | High |

---

## 3. Solution Overview

### 3.1 Product Vision

**Context Engine** is the "institutional memory" for software teams — a persistent knowledge layer that makes every AI tool smarter and every developer faster.

### 3.2 Core Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       CONTEXT ENGINE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  INGESTION LAYER                          │  │
│  │                                                           │  │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐ │  │
│  │  │ Git Repo  │ │ Tickets   │ │ Docs      │ │ Slack     │ │  │
│  │  │ Indexer   │ │ Importer  │ │ Crawler   │ │ Connector │ │  │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  KNOWLEDGE STORE                          │  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │              SEMANTIC CODE INDEX                     │ │  │
│  │  │  • File embeddings (what code does)                  │ │  │
│  │  │  • Function signatures (API surface)                 │ │  │
│  │  │  • Dependency graph (what connects to what)          │ │  │
│  │  │  • Symbol index (where things are defined)           │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │              DECISION MEMORY                         │ │  │
│  │  │  • ADRs (architectural decisions)                    │ │  │
│  │  │  • PRD links (why features exist)                    │ │  │
│  │  │  • Rejected alternatives (what didn't work)          │ │  │
│  │  │  • Trade-off rationale (why this over that)          │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │              SESSION MEMORY                          │ │  │
│  │  │  • Past Q&A (what was asked before)                  │ │  │
│  │  │  • Exploration history (paths tried)                 │ │  │
│  │  │  • User decisions (what was chosen)                  │ │  │
│  │  │  • Context used (what files were relevant)           │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │              KNOWLEDGE GRAPH                         │ │  │
│  │  │  • People → Expertise mapping                        │ │  │
│  │  │  • Code → Owner mapping                              │ │  │
│  │  │  • Concept → Location mapping                        │ │  │
│  │  │  • Feature → Business context mapping                │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  QUERY ENGINE                             │  │
│  │                                                           │  │
│  │  • Natural language queries ("why did we use Redis?")    │  │
│  │  • Code queries ("find auth implementations")            │  │
│  │  • Impact queries ("what breaks if I change X?")         │  │
│  │  • Expert queries ("who knows about payments?")          │  │
│  │  • Context packaging (for AI tool consumption)           │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  CONTEXT API                              │  │
│  │                                                           │  │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐ │  │
│  │  │ Claude    │ │ Cursor    │ │ Copilot   │ │ Custom    │ │  │
│  │  │ Code      │ │           │ │           │ │ Tools     │ │  │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 Key Differentiators

| Feature | Context Engine | Sourcegraph Cody | Swimm | GitLoop |
|---------|---------------|------------------|-------|---------|
| Semantic code index | ✅ | ✅ | ❌ | ✅ |
| Decision memory | ✅ | ❌ | ⚠️ (manual) | ❌ |
| Session persistence | ✅ | ❌ | ❌ | ❌ |
| Knowledge graph | ✅ | ❌ | ❌ | ❌ |
| Multi-tool API | ✅ | ❌ | ❌ | ❌ |
| Business context | ✅ | ❌ | ⚠️ | ❌ |

---

## 4. Detailed Requirements

### 4.1 Feature: Semantic Code Index

**Purpose:** Understand what every piece of code does and how it connects.

#### 4.1.1 Indexing Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| **File Embeddings** | Semantic understanding of file purpose | text-embedding-3-large |
| **Function Index** | Searchable function signatures | AST parsing + embeddings |
| **Dependency Graph** | Import/export relationships | Static analysis |
| **Symbol Table** | Where everything is defined | LSP-style indexing |
| **Call Graph** | What calls what | Static + dynamic analysis |

#### 4.1.2 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| IDX-001 | Index all source files with embeddings | P0 |
| IDX-002 | Parse function signatures for all languages | P0 |
| IDX-003 | Build dependency graph (imports/exports) | P0 |
| IDX-004 | Create symbol table (definitions/references) | P0 |
| IDX-005 | Support incremental indexing (only changed files) | P0 |
| IDX-006 | Index multiple repositories (monorepo support) | P1 |
| IDX-007 | Support TypeScript, Python, Go, Rust, Java | P0 |
| IDX-008 | Index test files separately for coverage mapping | P1 |
| IDX-009 | Refresh index on git push (webhook) | P1 |

#### 4.1.3 Data Schema

```typescript
interface FileIndex {
  file_path: string;
  repo_id: string;
  language: string;
  embedding: number[]; // 1536 dimensions
  summary: string; // LLM-generated summary
  last_indexed: string;
  content_hash: string;
  size_lines: number;
  symbols: Symbol[];
  imports: Import[];
  exports: Export[];
}

interface Symbol {
  name: string;
  kind: "function" | "class" | "variable" | "type" | "constant";
  start_line: number;
  end_line: number;
  signature: string;
  embedding: number[];
  documentation: string | null;
  visibility: "public" | "private" | "internal";
}

interface Import {
  source: string;
  symbols: string[];
  is_external: boolean;
}

interface Export {
  name: string;
  kind: string;
  is_default: boolean;
}

interface DependencyEdge {
  from_file: string;
  to_file: string;
  import_type: "static" | "dynamic";
  symbols: string[];
}
```

---

### 4.2 Feature: Decision Memory

**Purpose:** Capture and retrieve the "why" behind code, not just the "what".

#### 4.2.1 Decision Types

| Type | Source | Example |
|------|--------|---------|
| **ADR** | docs/adr/*.md | "We chose PostgreSQL because..." |
| **PRD Link** | docs/prds/*.md | "This feature was built for..." |
| **Commit Rationale** | Git commit messages | "Refactored to fix N+1 query" |
| **PR Discussion** | GitHub/GitLab PRs | "We considered X but chose Y" |
| **Code Comments** | Source files | "// HACK: Workaround for bug #123" |
| **Ticket Context** | Jira/Linear/GitHub Issues | "Customer X requested this" |

#### 4.2.2 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| DEC-001 | Parse and index ADR files | P0 |
| DEC-002 | Link PRDs to implementing code | P0 |
| DEC-003 | Extract rationale from commit messages | P1 |
| DEC-004 | Import PR discussions (GitHub/GitLab) | P1 |
| DEC-005 | Parse code comments for decision signals | P1 |
| DEC-006 | Link tickets to code changes | P2 |
| DEC-007 | Answer "why was X built this way?" queries | P0 |
| DEC-008 | Surface rejected alternatives | P1 |
| DEC-009 | Track decision evolution over time | P2 |

#### 4.2.3 Data Schema

```typescript
interface Decision {
  id: string;
  type: "adr" | "prd" | "commit" | "pr" | "comment" | "ticket";
  title: string;
  summary: string;
  rationale: string;
  alternatives_considered: Alternative[];
  date: string;
  authors: string[];
  status: "accepted" | "superseded" | "deprecated";
  linked_code: CodeReference[];
  linked_decisions: string[]; // Related decision IDs
  embedding: number[];
  source_url: string | null;
  source_file: string | null;
}

interface Alternative {
  description: string;
  rejected_reason: string;
}

interface CodeReference {
  file_path: string;
  start_line: number | null;
  end_line: number | null;
  symbol_name: string | null;
  relationship: "implements" | "affected_by" | "related";
}
```

---

### 4.3 Feature: Session Memory

**Purpose:** Remember past conversations, explorations, and decisions across sessions.

#### 4.3.1 What Gets Remembered

| Item | Example | Retention |
|------|---------|-----------|
| **Questions Asked** | "How does auth work?" | 90 days |
| **Answers Given** | Context + response | 90 days |
| **Files Explored** | List of files read | 30 days |
| **Paths Tried** | "Tried approach A, failed" | 90 days |
| **Decisions Made** | "User chose option B" | Permanent |
| **Context Used** | Files included in context | 30 days |

#### 4.3.2 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| SES-001 | Store Q&A pairs with embeddings | P0 |
| SES-002 | Track files accessed per session | P0 |
| SES-003 | Record user decisions and choices | P0 |
| SES-004 | Surface relevant past sessions for new queries | P0 |
| SES-005 | Allow users to bookmark important sessions | P1 |
| SES-006 | Support session search by topic | P1 |
| SES-007 | Auto-summarize long sessions | P1 |
| SES-008 | Share sessions with team members | P2 |
| SES-009 | Privacy controls (personal vs team sessions) | P1 |

#### 4.3.3 Data Schema

```typescript
interface Session {
  id: string;
  user_id: string;
  project_id: string;
  started_at: string;
  ended_at: string | null;
  summary: string | null; // Auto-generated
  interactions: Interaction[];
  files_accessed: string[];
  decisions_made: SessionDecision[];
  is_bookmarked: boolean;
  visibility: "private" | "team";
  tags: string[];
}

interface Interaction {
  id: string;
  timestamp: string;
  query: string;
  query_embedding: number[];
  response: string;
  context_used: ContextChunk[];
  feedback: "helpful" | "not_helpful" | null;
  follow_up_queries: string[];
}

interface SessionDecision {
  timestamp: string;
  description: string;
  options_presented: string[];
  option_chosen: string;
  rationale: string | null;
}

interface ContextChunk {
  source_type: "code" | "decision" | "session" | "doc";
  source_id: string;
  content_preview: string;
  relevance_score: number;
}
```

---

### 4.4 Feature: Knowledge Graph

**Purpose:** Map relationships between people, code, concepts, and business context.

#### 4.4.1 Graph Entities

| Entity | Attributes | Relationships |
|--------|------------|---------------|
| **Person** | name, email, role | OWNS, EXPERT_IN, AUTHORED |
| **Code** | file, function, module | DEPENDS_ON, CALLS, IMPLEMENTS |
| **Concept** | name, description | RELATED_TO, PART_OF |
| **Feature** | name, PRD | IMPLEMENTED_BY, REQUESTED_BY |
| **Team** | name, members | OWNS, RESPONSIBLE_FOR |

#### 4.4.2 Graph Relationships

```
┌─────────────────────────────────────────────────────────────────┐
│                    KNOWLEDGE GRAPH                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────┐                           ┌─────────┐            │
│   │  Sarah  │──────EXPERT_IN───────────▶│ Payments │           │
│   │ (Person)│                           │(Concept) │           │
│   └────┬────┘                           └────┬─────┘           │
│        │                                     │                  │
│        │ AUTHORED                    IMPLEMENTED_BY             │
│        │                                     │                  │
│        ▼                                     ▼                  │
│   ┌─────────┐                           ┌─────────┐            │
│   │ PR #234 │──────IMPLEMENTS──────────▶│ Stripe  │            │
│   │ (Change)│                           │ Module  │            │
│   └─────────┘                           │ (Code)  │            │
│                                         └────┬────┘            │
│                                              │                  │
│                                        DEPENDS_ON               │
│                                              │                  │
│                                              ▼                  │
│                                         ┌─────────┐            │
│   ┌─────────┐                           │  Auth   │            │
│   │  PRD    │───────REQUESTED──────────▶│ Service │            │
│   │  #45    │                           │ (Code)  │            │
│   │(Feature)│                           └─────────┘            │
│   └─────────┘                                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### 4.4.3 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| KG-001 | Build code ownership graph from git history | P0 |
| KG-002 | Identify expertise from commit patterns | P0 |
| KG-003 | Link code to concepts (auto-tagging) | P1 |
| KG-004 | Link features to implementing code | P1 |
| KG-005 | Answer "who knows about X?" queries | P0 |
| KG-006 | Answer "what depends on X?" queries | P0 |
| KG-007 | Visualize graph relationships | P2 |
| KG-008 | Support manual relationship editing | P2 |
| KG-009 | Detect knowledge silos (bus factor) | P2 |

#### 4.4.4 Data Schema

```typescript
interface GraphNode {
  id: string;
  type: "person" | "code" | "concept" | "feature" | "team";
  name: string;
  attributes: Record<string, any>;
  embedding: number[];
}

interface GraphEdge {
  id: string;
  from_node: string;
  to_node: string;
  relationship: string;
  weight: number;
  metadata: Record<string, any>;
  created_at: string;
  source: "inferred" | "manual" | "imported";
}

// Derived from git history
interface ExpertiseScore {
  person_id: string;
  concept_id: string;
  score: number; // 0-100
  evidence: {
    commits: number;
    lines_changed: number;
    recency_days: number;
    pr_reviews: number;
  };
}
```

---

### 4.5 Feature: Context API

**Purpose:** Provide context to any AI tool in a standardized format.

#### 4.5.1 API Design Principles

1. **Query-based**: Ask for context, get relevant chunks
2. **Budgeted**: Specify token budget, get optimized context
3. **Ranked**: Results ordered by relevance
4. **Typed**: Know what kind of context you're getting
5. **Cached**: Fast responses for repeated queries

#### 4.5.2 API Endpoints

```
POST /api/v1/context/query
  Purpose: Get relevant context for a natural language query

  Request:
    {
      "project_id": "uuid",
      "query": "How does authentication work in this codebase?",
      "token_budget": 8000,
      "include": ["code", "decisions", "sessions"],
      "filters": {
        "file_patterns": ["src/auth/**"],
        "languages": ["typescript"],
        "recency_days": 90
      },
      "session_id": "uuid" // Optional: include session context
    }

  Response:
    {
      "query_id": "uuid",
      "chunks": [
        {
          "type": "code",
          "source": "src/auth/middleware.ts",
          "content": "export function authenticate(req, res, next) {...}",
          "relevance_score": 0.95,
          "tokens": 450,
          "metadata": {
            "function_name": "authenticate",
            "last_modified": "2025-11-15",
            "author": "sarah@example.com"
          }
        },
        {
          "type": "decision",
          "source": "docs/adr/003-jwt-auth.md",
          "content": "We chose JWT over session-based auth because...",
          "relevance_score": 0.89,
          "tokens": 320,
          "metadata": {
            "decision_date": "2025-06-01",
            "status": "accepted"
          }
        },
        {
          "type": "session",
          "source": "session-abc123",
          "content": "Previous discussion: Auth flow was refactored to...",
          "relevance_score": 0.75,
          "tokens": 200,
          "metadata": {
            "session_date": "2025-11-28",
            "user": "current_user"
          }
        }
      ],
      "total_tokens": 970,
      "truncated": false,
      "suggestions": [
        "Ask: 'What are the security considerations for auth?'",
        "Related: See also the rate limiting implementation"
      ]
    }

GET /api/v1/context/file/:path
  Purpose: Get context for a specific file

  Response:
    {
      "file": "src/auth/middleware.ts",
      "summary": "JWT authentication middleware...",
      "symbols": [...],
      "dependencies": [...],
      "dependents": [...],
      "related_decisions": [...],
      "recent_sessions": [...],
      "experts": ["sarah@example.com"],
      "test_coverage": 85
    }

GET /api/v1/context/impact
  Purpose: Understand impact of a potential change

  Request:
    {
      "file": "src/auth/middleware.ts",
      "change_description": "Add rate limiting to authenticate function"
    }

  Response:
    {
      "affected_files": [...],
      "affected_tests": [...],
      "dependent_features": [...],
      "experts_to_consult": [...],
      "risk_assessment": "medium",
      "suggestions": [...]
    }

GET /api/v1/context/expert
  Purpose: Find who knows about something

  Request:
    {
      "topic": "payment processing"
    }

  Response:
    {
      "experts": [
        {
          "person": "sarah@example.com",
          "expertise_score": 92,
          "evidence": "234 commits, 15 PRs reviewed",
          "last_active": "2025-12-01"
        }
      ]
    }

POST /api/v1/context/remember
  Purpose: Store a new piece of context

  Request:
    {
      "type": "decision",
      "content": "We decided to use Redis for caching because...",
      "linked_files": ["src/cache/redis.ts"],
      "tags": ["caching", "architecture"]
    }
```

#### 4.5.3 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| API-001 | Natural language context queries | P0 |
| API-002 | Token budget optimization | P0 |
| API-003 | File-specific context retrieval | P0 |
| API-004 | Impact analysis queries | P1 |
| API-005 | Expert finding queries | P1 |
| API-006 | Context storage (remember) | P0 |
| API-007 | Session context integration | P0 |
| API-008 | Rate limiting and authentication | P0 |
| API-009 | Webhook notifications for index updates | P2 |

---

### 4.6 Feature: Integrations

**Purpose:** Connect Context Engine to existing developer workflows.

#### 4.6.1 Integration Types

| Integration | Purpose | Priority |
|-------------|---------|----------|
| **VS Code Extension** | Query context from IDE | P0 |
| **Claude Code MCP** | Native Claude Code integration | P0 |
| **GitHub App** | Index repos, PR context | P1 |
| **Slack Bot** | Ask questions in Slack | P2 |
| **CLI Tool** | Command-line queries | P1 |

#### 4.6.2 VS Code Extension Features

- Inline "Why?" hover on code
- "Ask about this" context menu
- Session history sidebar
- Expert finder command
- Decision memory search

#### 4.6.3 Claude Code MCP Server

```typescript
// MCP Server Definition
{
  "name": "context-engine",
  "version": "1.0.0",
  "tools": [
    {
      "name": "query_context",
      "description": "Get relevant context for a question about the codebase",
      "parameters": {
        "query": "string",
        "token_budget": "number"
      }
    },
    {
      "name": "get_file_context",
      "description": "Get detailed context for a specific file",
      "parameters": {
        "file_path": "string"
      }
    },
    {
      "name": "find_expert",
      "description": "Find who knows about a topic",
      "parameters": {
        "topic": "string"
      }
    },
    {
      "name": "remember_decision",
      "description": "Store a decision or piece of context",
      "parameters": {
        "content": "string",
        "type": "string"
      }
    }
  ]
}
```

---

## 5. Technical Architecture

### 5.1 System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      INFRASTRUCTURE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    API GATEWAY                            │  │
│  │                    (Kong / AWS ALB)                       │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│          ┌───────────────────┼───────────────────┐              │
│          │                   │                   │              │
│          ▼                   ▼                   ▼              │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │  Query API    │  │  Ingestion    │  │  Real-time    │       │
│  │  Service      │  │  Service      │  │  Service      │       │
│  │  (Node.js)    │  │  (Python)     │  │  (Node.js)    │       │
│  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘       │
│          │                   │                   │              │
│          └───────────────────┼───────────────────┘              │
│                              │                                  │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    MESSAGE QUEUE                          │  │
│  │                    (Redis / SQS)                          │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│          ┌───────────────────┼───────────────────┐              │
│          │                   │                   │              │
│          ▼                   ▼                   ▼              │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │  Embedding    │  │  Graph        │  │  Index        │       │
│  │  Worker       │  │  Worker       │  │  Worker       │       │
│  │  (Python)     │  │  (Python)     │  │  (Node.js)    │       │
│  └───────────────┘  └───────────────┘  └───────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA STORES                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ PostgreSQL  │  │  Pinecone   │  │   Neo4j     │             │
│  │             │  │  (Vectors)  │  │  (Graph)    │             │
│  │ • Users     │  │             │  │             │             │
│  │ • Projects  │  │ • Embeddings│  │ • Knowledge │             │
│  │ • Sessions  │  │ • Semantic  │  │   Graph     │             │
│  │ • Decisions │  │   Search    │  │ • Relations │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐                              │
│  │   Redis     │  │     S3      │                              │
│  │             │  │             │                              │
│  │ • Cache     │  │ • Raw files │                              │
│  │ • Sessions  │  │ • Reports   │                              │
│  │ • Queues    │  │ • Backups   │                              │
│  └─────────────┘  └─────────────┘                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Technology Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **API** | Node.js + Fastify | Performance, TypeScript |
| **Ingestion** | Python | ML libraries, embedding models |
| **Vector DB** | Pinecone | Managed, scalable, fast |
| **Graph DB** | Neo4j | Native graph queries |
| **Relational DB** | PostgreSQL | Structured data, JSONB |
| **Cache** | Redis | Fast lookups, sessions |
| **Queue** | Redis / SQS | Job processing |
| **Embeddings** | OpenAI text-embedding-3-large | Quality, cost balance |
| **LLM** | Claude API | Summaries, queries |
| **AST Parsing** | Tree-sitter | Multi-language support |

### 5.3 Data Model (PostgreSQL)

```sql
-- Organizations
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  plan VARCHAR(50) DEFAULT 'free',
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Users
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255),
  org_id UUID REFERENCES organizations(id),
  role VARCHAR(50) DEFAULT 'member',
  preferences JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Projects (repositories)
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID REFERENCES organizations(id),
  name VARCHAR(255) NOT NULL,
  repo_url VARCHAR(500),
  default_branch VARCHAR(100) DEFAULT 'main',
  index_status VARCHAR(50) DEFAULT 'pending',
  last_indexed_at TIMESTAMP,
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);

-- File Index
CREATE TABLE file_index (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  file_path VARCHAR(500) NOT NULL,
  language VARCHAR(50),
  content_hash VARCHAR(64),
  summary TEXT,
  size_lines INTEGER,
  symbols JSONB,
  imports JSONB,
  exports JSONB,
  last_indexed_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(project_id, file_path)
);

-- Decisions
CREATE TABLE decisions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  summary TEXT,
  rationale TEXT,
  alternatives JSONB,
  status VARCHAR(50) DEFAULT 'accepted',
  authors JSONB,
  linked_code JSONB,
  source_url VARCHAR(500),
  source_file VARCHAR(500),
  decision_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Sessions
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  project_id UUID REFERENCES projects(id),
  started_at TIMESTAMP DEFAULT NOW(),
  ended_at TIMESTAMP,
  summary TEXT,
  files_accessed JSONB,
  decisions_made JSONB,
  is_bookmarked BOOLEAN DEFAULT FALSE,
  visibility VARCHAR(20) DEFAULT 'private',
  tags JSONB DEFAULT '[]'
);

-- Interactions (within sessions)
CREATE TABLE interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  timestamp TIMESTAMP DEFAULT NOW(),
  query TEXT NOT NULL,
  response TEXT,
  context_used JSONB,
  feedback VARCHAR(20),
  tokens_used INTEGER
);

-- Graph Nodes (stored in PostgreSQL, synced to Neo4j)
CREATE TABLE graph_nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  name VARCHAR(255) NOT NULL,
  attributes JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Graph Edges
CREATE TABLE graph_edges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  from_node UUID REFERENCES graph_nodes(id),
  to_node UUID REFERENCES graph_nodes(id),
  relationship VARCHAR(100) NOT NULL,
  weight NUMERIC(5,2) DEFAULT 1.0,
  metadata JSONB DEFAULT '{}',
  source VARCHAR(50) DEFAULT 'inferred',
  created_at TIMESTAMP DEFAULT NOW()
);

-- API Keys
CREATE TABLE api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  org_id UUID REFERENCES organizations(id),
  name VARCHAR(255),
  key_hash VARCHAR(64) NOT NULL,
  last_used_at TIMESTAMP,
  expires_at TIMESTAMP,
  scopes JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_file_index_project ON file_index(project_id);
CREATE INDEX idx_file_index_path ON file_index(file_path);
CREATE INDEX idx_decisions_project ON decisions(project_id);
CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_project ON sessions(project_id);
CREATE INDEX idx_interactions_session ON interactions(session_id);
CREATE INDEX idx_graph_nodes_project ON graph_nodes(project_id);
CREATE INDEX idx_graph_edges_from ON graph_edges(from_node);
CREATE INDEX idx_graph_edges_to ON graph_edges(to_node);
```

---

## 6. Implementation Plan

### 6.1 Phase 1: Core Indexing (Weeks 1-4)

**Objective:** Build the foundational code indexing pipeline.

#### Week 1: Project Setup
- [ ] Initialize monorepo structure (Turborepo)
- [ ] Set up Node.js API service
- [ ] Set up Python ingestion service
- [ ] Configure PostgreSQL database
- [ ] Set up Pinecone vector index
- [ ] Configure CI/CD pipeline

#### Week 2: File Indexing
- [ ] Implement git repository cloning
- [ ] Build Tree-sitter parsing for TypeScript
- [ ] Extract symbols (functions, classes, types)
- [ ] Build import/export analysis
- [ ] Generate file embeddings
- [ ] Store in Pinecone + PostgreSQL

#### Week 3: Semantic Search
- [ ] Implement embedding-based search
- [ ] Build query API endpoint
- [ ] Add relevance ranking
- [ ] Implement token budgeting
- [ ] Add result caching

#### Week 4: Multi-Language Support
- [ ] Add Python parser
- [ ] Add Go parser
- [ ] Add JavaScript parser
- [ ] Normalize symbol extraction across languages
- [ ] Write integration tests

**Deliverable:** API that indexes repos and answers code queries

### 6.2 Phase 2: Decision Memory (Weeks 5-7)

**Objective:** Capture and query architectural decisions.

#### Week 5: ADR/PRD Parsing
- [ ] Build ADR file parser
- [ ] Build PRD file parser
- [ ] Extract decision metadata
- [ ] Generate decision embeddings
- [ ] Link decisions to code files

#### Week 6: Git History Analysis
- [ ] Parse commit messages for decisions
- [ ] Extract PR discussion context (GitHub API)
- [ ] Identify decision signals in code comments
- [ ] Build decision timeline

#### Week 7: Decision Queries
- [ ] Implement "why was this built?" queries
- [ ] Surface rejected alternatives
- [ ] Link related decisions
- [ ] Build decision API endpoints

**Deliverable:** "Why?" queries return decision context

### 6.3 Phase 3: Session Memory (Weeks 8-10)

**Objective:** Remember past conversations across sessions.

#### Week 8: Session Storage
- [ ] Design session data model
- [ ] Implement session creation/update
- [ ] Store interactions with embeddings
- [ ] Track files accessed

#### Week 9: Session Retrieval
- [ ] Find relevant past sessions for new queries
- [ ] Merge session context with code context
- [ ] Implement session search
- [ ] Add session bookmarking

#### Week 10: Session Continuity
- [ ] Auto-summarize sessions
- [ ] Implement "continue from yesterday" feature
- [ ] Add session sharing
- [ ] Privacy controls

**Deliverable:** AI remembers past conversations

### 6.4 Phase 4: Knowledge Graph (Weeks 11-13)

**Objective:** Map people, code, and concepts.

#### Week 11: Graph Infrastructure
- [ ] Set up Neo4j
- [ ] Define graph schema
- [ ] Build sync from PostgreSQL
- [ ] Implement basic queries

#### Week 12: Expertise Mining
- [ ] Analyze git history for ownership
- [ ] Calculate expertise scores
- [ ] Build "who knows about X?" queries
- [ ] Surface knowledge silos

#### Week 13: Concept Mapping
- [ ] Auto-tag code with concepts
- [ ] Link features to code
- [ ] Build dependency impact queries
- [ ] Visualize graph (optional)

**Deliverable:** Find experts, understand impact

### 6.5 Phase 5: Integrations (Weeks 14-16)

**Objective:** Connect to developer tools.

#### Week 14: VS Code Extension
- [ ] Scaffold extension
- [ ] Implement inline queries
- [ ] Add context menu actions
- [ ] Build sidebar panel

#### Week 15: Claude Code MCP
- [ ] Build MCP server
- [ ] Implement tool definitions
- [ ] Test with Claude Code
- [ ] Documentation

#### Week 16: Polish & Launch
- [ ] Performance optimization
- [ ] Documentation
- [ ] Landing page
- [ ] Beta launch

**Deliverable:** Full product ready for beta users

---

## 7. Testing Strategy

### 7.1 Test Categories

| Category | Coverage | Tools |
|----------|----------|-------|
| **Unit Tests** | 80% | Vitest (Node), pytest (Python) |
| **Integration Tests** | Critical paths | Docker Compose |
| **E2E Tests** | Key workflows | Playwright |
| **Load Tests** | Query performance | k6 |
| **Embedding Quality** | Relevance scoring | Custom benchmarks |

### 7.2 Test Scenarios

#### Indexing Tests
- [ ] TypeScript repo indexed correctly
- [ ] Python repo indexed correctly
- [ ] Incremental indexing works
- [ ] Large repo (100K+ files) performance acceptable

#### Query Tests
- [ ] Code queries return relevant results
- [ ] Decision queries find ADRs
- [ ] Session context improves results
- [ ] Token budgets respected

#### Integration Tests
- [ ] GitHub webhook triggers reindex
- [ ] VS Code extension queries work
- [ ] MCP server responds correctly

### 7.3 Test Repositories

Create test repositories:
- `test-repo-typescript/` - Standard TS project with ADRs
- `test-repo-python/` - Python project with PRDs
- `test-repo-monorepo/` - Multi-package monorepo
- `test-repo-large/` - 50K+ files for performance testing

---

## 8. Security Considerations

### 8.1 Data Classification

| Data Type | Sensitivity | Handling |
|-----------|-------------|----------|
| Source code | High | Encrypted, access-controlled |
| Embeddings | Medium | Derived data, not reversible |
| Decisions | Medium | Encrypted at rest |
| Sessions | Medium | User-owned, privacy controls |
| Graph data | Low | Metadata only |

### 8.2 Access Control

- OAuth 2.0 for user authentication
- API keys for programmatic access
- Project-level permissions
- Team visibility controls for sessions
- Audit logging for all access

### 8.3 Compliance

- SOC 2 Type II architecture
- GDPR-compliant (data deletion, export)
- No PII in embeddings
- Customer data isolation

---

## 9. Success Metrics & KPIs

### 9.1 Product Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| **Time to First Query** | Sign up → first successful query | <10 min |
| **Query Relevance** | User feedback on results | >80% helpful |
| **Session Continuity** | % queries with relevant past context | >50% |
| **Onboarding Acceleration** | Time to first meaningful contribution | -40% |

### 9.2 Business Metrics

| Metric | Target (Month 6) | Target (Month 12) |
|--------|------------------|-------------------|
| **Indexed Repos** | 500 | 5,000 |
| **Daily Active Users** | 500 | 5,000 |
| **Queries/Day** | 5,000 | 50,000 |
| **MRR** | $15K | $100K |
| **Churn Rate** | <8% | <5% |

---

## 10. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Embedding costs too high | High | High | Cache aggressively, use smaller models for initial filter |
| Sourcegraph adds these features | High | High | Move fast, focus on decisions/sessions (their gap) |
| Enterprise won't share code | Medium | High | On-premise option, SOC 2 certification |
| Query latency too slow | Medium | High | Aggressive caching, query optimization |
| Knowledge graph complexity | Medium | Medium | Start simple, iterate based on usage |

---

## 11. Open Questions

| Question | Owner | Due Date |
|----------|-------|----------|
| On-premise deployment priority? | Product | Week 2 |
| Which vector DB (Pinecone vs Weaviate)? | Engineering | Week 1 |
| Neo4j vs PostgreSQL for graph? | Engineering | Week 1 |
| Pricing model (per-seat vs per-repo)? | Product | Week 4 |
| Enterprise SSO priority? | Product | Week 8 |

---

## 12. Appendix

### A. Embedding Strategy

Use tiered embedding approach:
1. **Fast filter**: Smaller model (text-embedding-3-small) for initial retrieval
2. **Re-rank**: Larger model (text-embedding-3-large) for top candidates
3. **Cache**: Store embeddings, recompute only on file change

### B. Token Budget Algorithm

```python
def allocate_budget(query: str, budget: int, sources: List[str]) -> List[Chunk]:
    """
    Allocate token budget across context sources.

    Strategy:
    1. Reserve 20% for decisions (high value, low volume)
    2. Reserve 10% for session context (personalization)
    3. Allocate remaining 70% to code (primary source)
    4. Within each category, rank by relevance score
    5. Fill until budget exhausted
    """
    decision_budget = int(budget * 0.20)
    session_budget = int(budget * 0.10)
    code_budget = budget - decision_budget - session_budget

    chunks = []
    chunks.extend(get_decisions(query, decision_budget))
    chunks.extend(get_sessions(query, session_budget))
    chunks.extend(get_code(query, code_budget))

    return sorted(chunks, key=lambda c: c.relevance_score, reverse=True)
```

### C. Competitive Feature Matrix

See `docs/PIVOT_DECISION_FRAMEWORK.md` for detailed competitive analysis.

---

**Status:** READY_FOR_REVIEW
**Confidence:** MEDIUM_CONFIDENCE
**Next Step:** Architecture review and technology decisions
