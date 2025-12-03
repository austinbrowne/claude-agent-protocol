# PRD-001: Code Archaeologist

**Product Name:** Code Archaeologist
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

**Reviewers:** Engineering Lead, Security, Product
**Approval Status:** Pending

---

## 1. Executive Summary

### 1.1 Problem Statement

AI coding assistants have created an unprecedented wave of technical debt:
- **10x increase** in duplicated code blocks since 2022 (GitClear)
- **322% more** privilege escalation vulnerabilities in AI code (Apiiro)
- **Code churn doubled** between 2021-2024 (MIT Sloan)
- Teams maintain "code nobody wrote" — knowledge debt snowballing

**The gap:** Tools exist to generate AI code and review new code, but nothing helps teams **clean up the AI mess they've already accumulated**.

### 1.2 Solution

Code Archaeologist is a developer tool that:
1. **Detects** AI-generated code vs human-written code
2. **Maps** duplications, dead code, and understanding gaps
3. **Recommends** safe consolidation and cleanup actions
4. **Tracks** debt reduction progress over time

### 1.3 Target Users

| Segment | Role | Pain Point |
|---------|------|------------|
| **Primary** | Engineering Leads | "Our codebase is a mess after 12 months of Copilot" |
| **Secondary** | Platform/DevOps | "Tech debt metrics are spiking, we need to quantify it" |
| **Tertiary** | Individual Developers | "I inherited AI-generated spaghetti code" |

### 1.4 Success Metrics

| Metric | Target | Timeframe |
|--------|--------|-----------|
| Repos scanned | 100 | Month 3 |
| Duplicate code identified | 50K+ lines | Month 3 |
| User satisfaction (NPS) | >40 | Month 6 |
| Paying customers | 20 | Month 6 |
| MRR | $10K | Month 6 |

---

## 2. Problem Deep Dive

### 2.1 Root Cause Analysis

```
AI Code Generation (2022-2024)
         │
         ▼
┌─────────────────────────────────────┐
│  Developers accept AI suggestions   │
│  without full understanding         │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Code duplicated instead of reused  │
│  (Copy-paste > refactoring)         │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  No documentation of intent         │
│  Original authors don't understand  │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Technical debt compounds           │
│  Maintenance costs explode          │
└─────────────────────────────────────┘
```

### 2.2 User Research Findings

From industry research:
- 62% of developers cite tech debt as #1 frustration (Stack Overflow 2024)
- Average cost: $361,000 per 100,000 lines of code (IDC)
- "Moved" code (refactoring signal) dropped from 24.8% → 9.5% (GitClear)
- Developers spend more time debugging AI code than benefiting from speed (Harness 2025)

### 2.3 Jobs to Be Done

| Job | Current Solution | Pain Level |
|-----|------------------|------------|
| "Understand how much AI code we have" | Manual guess | High |
| "Find duplicate implementations" | grep + manual review | High |
| "Know what's safe to delete" | Fear-based avoidance | Critical |
| "Track debt reduction progress" | Spreadsheets | Medium |
| "Prioritize what to fix first" | Gut feeling | High |

---

## 3. Solution Overview

### 3.1 Product Vision

**Code Archaeologist** is the "tech debt MRI" for codebases polluted by AI-generated code. It scans, diagnoses, and guides remediation.

### 3.2 Core Capabilities

```
┌─────────────────────────────────────────────────────────────────┐
│                      CODE ARCHAEOLOGIST                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    SCAN ENGINE                            │  │
│  │                                                           │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │  │
│  │  │ AI Code     │  │ Duplication │  │ Dead Code   │       │  │
│  │  │ Detector    │  │ Finder      │  │ Analyzer    │       │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘       │  │
│  │                                                           │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │  │
│  │  │ Gap         │  │ Complexity  │  │ Security    │       │  │
│  │  │ Finder      │  │ Scorer      │  │ Scanner     │       │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘       │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  ANALYSIS ENGINE                          │  │
│  │                                                           │  │
│  │  • Cluster similar code blocks                            │  │
│  │  • Score remediation priority                             │  │
│  │  • Identify safe deletion candidates                      │  │
│  │  • Generate consolidation recommendations                 │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  OUTPUT LAYER                             │  │
│  │                                                           │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │  │
│  │  │ Dashboard   │  │ Reports     │  │ PR          │       │  │
│  │  │ (Web)       │  │ (JSON/PDF)  │  │ Suggestions │       │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘       │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 Key Differentiators

| Feature | Code Archaeologist | SonarQube | Snyk | CodeClimate |
|---------|-------------------|-----------|------|-------------|
| AI code attribution | ✅ | ❌ | ❌ | ❌ |
| AI-specific debt patterns | ✅ | ❌ | ❌ | ❌ |
| Safe deletion guidance | ✅ | ❌ | ❌ | ❌ |
| Knowledge recovery | ✅ | ❌ | ❌ | ❌ |
| Debt burndown tracking | ✅ | ⚠️ | ❌ | ✅ |

---

## 4. Detailed Requirements

### 4.1 Feature: AI Code Attribution

**Purpose:** Identify which code was likely AI-generated vs human-written.

#### 4.1.1 Detection Methods

| Method | Signal | Confidence |
|--------|--------|------------|
| **Git blame analysis** | Commits with AI co-author tags | High |
| **Commit message patterns** | "Generated by", "Copilot", "Claude" | High |
| **Code style heuristics** | Verbose variable names, comment patterns | Medium |
| **Timing analysis** | Burst commits, unusual hours | Low |
| **AST pattern matching** | Known AI code patterns | Medium |

#### 4.1.2 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| AI-001 | Scan git history for AI co-author tags | P0 |
| AI-002 | Parse commit messages for AI tool mentions | P0 |
| AI-003 | Apply heuristic scoring to code blocks | P1 |
| AI-004 | Generate attribution confidence scores (0-100) | P0 |
| AI-005 | Support manual override of attribution | P1 |
| AI-006 | Track attribution over time (when was AI code added) | P1 |

#### 4.1.3 Output Schema

```typescript
interface AIAttribution {
  file_path: string;
  total_lines: number;
  ai_generated_lines: number;
  human_written_lines: number;
  unknown_lines: number;
  confidence_score: number; // 0-100
  detection_methods: DetectionMethod[];
  first_ai_commit: string | null;
  ai_tools_detected: string[]; // ["copilot", "claude", "cursor"]
  blocks: AICodeBlock[];
}

interface AICodeBlock {
  start_line: number;
  end_line: number;
  attribution: "ai" | "human" | "unknown";
  confidence: number;
  commit_sha: string;
  author: string;
  date: string;
  detection_signals: string[];
}
```

---

### 4.2 Feature: Duplication Mapper

**Purpose:** Find duplicated code blocks, especially AI-generated copy-paste patterns.

#### 4.2.1 Detection Approach

```
Step 1: Parse all files into AST
         │
         ▼
Step 2: Normalize code (remove whitespace, rename variables)
         │
         ▼
Step 3: Hash normalized blocks (function-level, block-level)
         │
         ▼
Step 4: Find hash collisions (exact duplicates)
         │
         ▼
Step 5: Run similarity scoring (near-duplicates, 80%+ similar)
         │
         ▼
Step 6: Cluster duplicates into "duplication families"
         │
         ▼
Step 7: Identify canonical version (most tested, most documented)
```

#### 4.2.2 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| DUP-001 | Detect exact duplicate functions | P0 |
| DUP-002 | Detect near-duplicate functions (>80% similarity) | P0 |
| DUP-003 | Detect duplicate code blocks within functions | P1 |
| DUP-004 | Cluster duplicates into families | P0 |
| DUP-005 | Identify canonical version per family | P1 |
| DUP-006 | Calculate lines of code saveable by consolidation | P0 |
| DUP-007 | Support language-specific parsing (TS, Python, Go, Rust) | P0 |
| DUP-008 | Ignore intentional duplicates (test fixtures, etc.) | P1 |

#### 4.2.3 Output Schema

```typescript
interface DuplicationReport {
  total_duplicated_lines: number;
  total_duplication_families: number;
  potential_lines_saved: number;
  families: DuplicationFamily[];
}

interface DuplicationFamily {
  id: string;
  canonical_location: CodeLocation;
  duplicates: Duplicate[];
  total_instances: number;
  total_lines: number;
  consolidation_difficulty: "easy" | "moderate" | "hard";
  ai_attribution_percentage: number;
}

interface Duplicate {
  location: CodeLocation;
  similarity_score: number; // 0-100
  is_exact: boolean;
  differences: string[];
  ai_attributed: boolean;
  last_modified: string;
  test_coverage: number;
}

interface CodeLocation {
  file_path: string;
  start_line: number;
  end_line: number;
  function_name: string | null;
}
```

---

### 4.3 Feature: Dead Code Analyzer

**Purpose:** Identify code that is never executed or imported.

#### 4.3.1 Detection Methods

| Method | Detects | Accuracy |
|--------|---------|----------|
| **Import analysis** | Unused imports | High |
| **Export analysis** | Unexported functions | High |
| **Call graph analysis** | Unreachable functions | High |
| **Runtime coverage** | Never-executed branches | Requires tests |
| **Dependency tree** | Unused dependencies | High |

#### 4.3.2 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| DEAD-001 | Identify unused imports | P0 |
| DEAD-002 | Identify unexported private functions | P0 |
| DEAD-003 | Build call graph to find unreachable code | P0 |
| DEAD-004 | Integrate with coverage reports for runtime analysis | P1 |
| DEAD-005 | Identify unused dependencies in package.json/requirements.txt | P0 |
| DEAD-006 | Calculate safe deletion candidates with confidence | P0 |
| DEAD-007 | Warn about potential false positives (reflection, dynamic imports) | P1 |

#### 4.3.3 Output Schema

```typescript
interface DeadCodeReport {
  total_dead_lines: number;
  safe_to_delete_lines: number;
  needs_verification_lines: number;
  dead_code_items: DeadCodeItem[];
}

interface DeadCodeItem {
  type: "unused_import" | "unreachable_function" | "dead_branch" |
        "unused_variable" | "unused_dependency";
  location: CodeLocation;
  name: string;
  confidence: number; // 0-100
  safe_to_delete: boolean;
  reason: string;
  potential_false_positive_reasons: string[];
  ai_attributed: boolean;
  last_modified: string;
}
```

---

### 4.4 Feature: Understanding Gap Finder

**Purpose:** Identify code that lacks documentation, tests, or clear intent.

#### 4.4.1 Gap Categories

| Gap Type | Indicator | Risk Level |
|----------|-----------|------------|
| **No documentation** | No JSDoc/docstring | Medium |
| **No tests** | 0% coverage | High |
| **No comments** | Complex logic without explanation | Medium |
| **Orphaned code** | No clear ownership | High |
| **Magic numbers** | Hardcoded values without explanation | Low |
| **Complex conditionals** | High cyclomatic complexity | Medium |

#### 4.4.2 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| GAP-001 | Identify functions without documentation | P0 |
| GAP-002 | Identify functions without test coverage | P0 |
| GAP-003 | Identify files with no recent commits (orphaned) | P1 |
| GAP-004 | Calculate complexity scores (cyclomatic, cognitive) | P1 |
| GAP-005 | Find magic numbers and hardcoded strings | P2 |
| GAP-006 | Prioritize gaps by business criticality (call frequency) | P1 |

#### 4.4.3 Output Schema

```typescript
interface UnderstandingGapReport {
  total_gap_score: number; // 0-100 (100 = fully documented)
  critical_gaps: number;
  files_without_tests: number;
  functions_without_docs: number;
  gaps: UnderstandingGap[];
}

interface UnderstandingGap {
  type: "no_docs" | "no_tests" | "no_comments" | "orphaned" |
        "magic_numbers" | "high_complexity";
  location: CodeLocation;
  severity: "critical" | "high" | "medium" | "low";
  business_impact: number; // Based on call frequency
  ai_attributed: boolean;
  recommendation: string;
  estimated_fix_time_minutes: number;
}
```

---

### 4.5 Feature: Safe Consolidation Assistant

**Purpose:** Generate actionable remediation recommendations.

#### 4.5.1 Recommendation Types

| Type | Input | Output |
|------|-------|--------|
| **Merge duplicates** | Duplication family | Refactoring plan + PR |
| **Delete dead code** | Dead code item | Deletion PR |
| **Add documentation** | Understanding gap | Generated docs |
| **Extract constants** | Magic numbers | Refactoring PR |
| **Split complex functions** | High complexity | Refactoring plan |

#### 4.5.2 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| REC-001 | Generate merge recommendations for duplicate families | P0 |
| REC-002 | Generate safe deletion commands for dead code | P0 |
| REC-003 | Generate documentation stubs for undocumented functions | P1 |
| REC-004 | Estimate risk level for each recommendation | P0 |
| REC-005 | Generate git patch files for recommended changes | P1 |
| REC-006 | Support "dry run" mode to preview changes | P0 |
| REC-007 | Integrate with GitHub/GitLab to create PRs | P2 |

#### 4.5.3 Output Schema

```typescript
interface RemediationPlan {
  total_recommendations: number;
  estimated_lines_saved: number;
  estimated_hours_saved: number;
  recommendations: Recommendation[];
}

interface Recommendation {
  id: string;
  type: "merge_duplicates" | "delete_dead" | "add_docs" |
        "extract_constants" | "split_function";
  title: string;
  description: string;
  risk_level: "low" | "medium" | "high";
  confidence: number;
  affected_files: string[];
  lines_affected: number;
  estimated_savings: {
    lines: number;
    maintenance_hours_per_year: number;
  };
  steps: RemediationStep[];
  patch: string | null; // Git patch format
  requires_tests: boolean;
  breaking_change: boolean;
}

interface RemediationStep {
  order: number;
  action: string;
  file: string;
  details: string;
}
```

---

### 4.6 Feature: Debt Dashboard

**Purpose:** Visualize and track technical debt metrics over time.

#### 4.6.1 Dashboard Views

| View | Purpose | Key Metrics |
|------|---------|-------------|
| **Overview** | High-level health | Total debt score, trend |
| **AI Attribution** | AI code breakdown | % AI, by date, by tool |
| **Duplication** | Duplicate code map | Families, lines saveable |
| **Dead Code** | Unused code list | Lines, safe to delete |
| **Gaps** | Understanding gaps | Coverage, docs, complexity |
| **Progress** | Burndown tracking | Debt reduced over time |

#### 4.6.2 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| DASH-001 | Display overall debt score (0-100) | P0 |
| DASH-002 | Show AI attribution breakdown | P0 |
| DASH-003 | List duplication families with drill-down | P0 |
| DASH-004 | Show dead code candidates | P0 |
| DASH-005 | Display understanding gaps prioritized by severity | P1 |
| DASH-006 | Track debt score over time (burndown chart) | P1 |
| DASH-007 | Compare before/after remediation | P1 |
| DASH-008 | Export reports as JSON, PDF, CSV | P1 |
| DASH-009 | Set debt reduction goals and track progress | P2 |

---

## 5. Technical Architecture

### 5.1 System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                            │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   CLI       │  │  Web UI     │  │  VS Code    │             │
│  │   Tool      │  │  Dashboard  │  │  Extension  │             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
└─────────┼────────────────┼────────────────┼─────────────────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                         API LAYER                               │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    REST API (Node.js)                     │  │
│  │                                                           │  │
│  │  POST /api/scans              - Start new scan            │  │
│  │  GET  /api/scans/:id          - Get scan results          │  │
│  │  GET  /api/scans/:id/report   - Get formatted report      │  │
│  │  GET  /api/projects           - List projects             │  │
│  │  POST /api/recommendations    - Generate recommendations  │  │
│  │  GET  /api/metrics/:project   - Get debt metrics          │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                       SCAN ENGINE                               │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ Git         │  │ AST         │  │ Similarity  │             │
│  │ Analyzer    │  │ Parser      │  │ Engine      │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ Call Graph  │  │ Coverage    │  │ LLM         │             │
│  │ Builder     │  │ Analyzer    │  │ Analyzer    │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ PostgreSQL  │  │ Redis       │  │ S3/Blob     │             │
│  │ (Projects,  │  │ (Cache,     │  │ (Reports,   │             │
│  │  Scans,     │  │  Jobs)      │  │  Patches)   │             │
│  │  Metrics)   │  │             │  │             │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Technology Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **CLI** | Node.js + Commander.js | Cross-platform, npm distribution |
| **API** | Node.js + Fastify | Performance, TypeScript support |
| **Web UI** | Next.js 14 + Tailwind | Modern React, SSR, fast iteration |
| **Database** | PostgreSQL 15 | Relational data, JSONB for flexibility |
| **Cache** | Redis | Job queues, caching |
| **Storage** | S3-compatible | Reports, patches |
| **AST Parsing** | Tree-sitter | Multi-language, fast |
| **Git Analysis** | simple-git + libgit2 | Robust git operations |
| **LLM** | Claude API | Knowledge recovery, smart analysis |

### 5.3 Data Model

```sql
-- Projects
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  repo_url VARCHAR(500),
  default_branch VARCHAR(100) DEFAULT 'main',
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Scans
CREATE TABLE scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  status VARCHAR(50) DEFAULT 'pending', -- pending, running, completed, failed
  commit_sha VARCHAR(40),
  branch VARCHAR(255),
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  summary JSONB, -- High-level metrics
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- AI Attribution Results
CREATE TABLE ai_attributions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_id UUID REFERENCES scans(id) ON DELETE CASCADE,
  file_path VARCHAR(500) NOT NULL,
  total_lines INTEGER,
  ai_lines INTEGER,
  human_lines INTEGER,
  unknown_lines INTEGER,
  confidence_score NUMERIC(5,2),
  blocks JSONB, -- Array of AICodeBlock
  created_at TIMESTAMP DEFAULT NOW()
);

-- Duplication Families
CREATE TABLE duplication_families (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_id UUID REFERENCES scans(id) ON DELETE CASCADE,
  canonical_file VARCHAR(500),
  canonical_start_line INTEGER,
  canonical_end_line INTEGER,
  total_instances INTEGER,
  total_lines INTEGER,
  consolidation_difficulty VARCHAR(20),
  ai_percentage NUMERIC(5,2),
  duplicates JSONB, -- Array of Duplicate
  created_at TIMESTAMP DEFAULT NOW()
);

-- Dead Code Items
CREATE TABLE dead_code_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_id UUID REFERENCES scans(id) ON DELETE CASCADE,
  type VARCHAR(50),
  file_path VARCHAR(500),
  start_line INTEGER,
  end_line INTEGER,
  name VARCHAR(255),
  confidence NUMERIC(5,2),
  safe_to_delete BOOLEAN,
  reason TEXT,
  ai_attributed BOOLEAN,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Understanding Gaps
CREATE TABLE understanding_gaps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_id UUID REFERENCES scans(id) ON DELETE CASCADE,
  type VARCHAR(50),
  file_path VARCHAR(500),
  start_line INTEGER,
  end_line INTEGER,
  severity VARCHAR(20),
  business_impact NUMERIC(5,2),
  ai_attributed BOOLEAN,
  recommendation TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Recommendations
CREATE TABLE recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_id UUID REFERENCES scans(id) ON DELETE CASCADE,
  type VARCHAR(50),
  title VARCHAR(255),
  description TEXT,
  risk_level VARCHAR(20),
  confidence NUMERIC(5,2),
  affected_files JSONB,
  lines_affected INTEGER,
  estimated_savings JSONB,
  steps JSONB,
  patch TEXT,
  status VARCHAR(50) DEFAULT 'pending', -- pending, applied, skipped
  created_at TIMESTAMP DEFAULT NOW()
);

-- Metrics (time-series for tracking)
CREATE TABLE debt_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  scan_id UUID REFERENCES scans(id) ON DELETE CASCADE,
  recorded_at TIMESTAMP DEFAULT NOW(),
  total_lines INTEGER,
  ai_lines INTEGER,
  duplicated_lines INTEGER,
  dead_lines INTEGER,
  gap_score NUMERIC(5,2),
  overall_debt_score NUMERIC(5,2)
);

-- Indexes
CREATE INDEX idx_scans_project ON scans(project_id);
CREATE INDEX idx_scans_status ON scans(status);
CREATE INDEX idx_metrics_project ON debt_metrics(project_id);
CREATE INDEX idx_metrics_recorded ON debt_metrics(recorded_at);
```

### 5.4 API Endpoints

#### Scan Management

```
POST /api/v1/scans
  Request:
    {
      "project_id": "uuid",
      "repo_path": "/path/to/repo",  // For CLI
      "branch": "main",
      "options": {
        "include_ai_attribution": true,
        "include_duplication": true,
        "include_dead_code": true,
        "include_gaps": true,
        "languages": ["typescript", "python"],
        "exclude_paths": ["node_modules", "dist"]
      }
    }
  Response:
    {
      "scan_id": "uuid",
      "status": "pending",
      "estimated_duration_seconds": 120
    }

GET /api/v1/scans/:id
  Response:
    {
      "id": "uuid",
      "status": "completed",
      "summary": {
        "total_lines": 50000,
        "ai_lines": 23000,
        "ai_percentage": 46,
        "duplicated_lines": 8500,
        "dead_lines": 3200,
        "gap_score": 65,
        "overall_debt_score": 42
      },
      "completed_at": "2025-12-03T10:30:00Z"
    }

GET /api/v1/scans/:id/ai-attribution
  Response:
    {
      "total_files": 234,
      "files": [AIAttribution, ...]
    }

GET /api/v1/scans/:id/duplications
  Response:
    {
      "total_families": 45,
      "total_duplicated_lines": 8500,
      "families": [DuplicationFamily, ...]
    }

GET /api/v1/scans/:id/dead-code
  Response:
    {
      "total_items": 156,
      "safe_to_delete_lines": 2800,
      "items": [DeadCodeItem, ...]
    }

GET /api/v1/scans/:id/gaps
  Response:
    {
      "gap_score": 65,
      "critical_gaps": 12,
      "gaps": [UnderstandingGap, ...]
    }

GET /api/v1/scans/:id/recommendations
  Response:
    {
      "total": 89,
      "estimated_lines_saved": 11500,
      "recommendations": [Recommendation, ...]
    }

POST /api/v1/recommendations/:id/apply
  Request:
    {
      "dry_run": false
    }
  Response:
    {
      "success": true,
      "patch_applied": true,
      "files_modified": ["src/utils.ts", "src/helpers.ts"]
    }
```

#### Project Management

```
GET /api/v1/projects
POST /api/v1/projects
GET /api/v1/projects/:id
GET /api/v1/projects/:id/metrics
GET /api/v1/projects/:id/history
```

---

## 6. Implementation Plan

### 6.1 Phase 1: Core Scanner (Weeks 1-4)

**Objective:** Build CLI tool that scans repos and produces JSON report.

#### Week 1: Project Setup
- [ ] Initialize Node.js project with TypeScript
- [ ] Set up CLI framework (Commander.js)
- [ ] Create project structure
- [ ] Set up testing framework (Vitest)
- [ ] Configure linting and formatting

#### Week 2: Git Analysis
- [ ] Implement git history reader
- [ ] Parse commit messages for AI tool mentions
- [ ] Extract AI co-author tags
- [ ] Build file-level attribution map
- [ ] Write unit tests

#### Week 3: AST Analysis
- [ ] Integrate Tree-sitter for TypeScript/Python
- [ ] Implement code normalization
- [ ] Build similarity hashing
- [ ] Detect duplicate functions
- [ ] Write integration tests

#### Week 4: Dead Code & Gaps
- [ ] Implement import analysis
- [ ] Build call graph
- [ ] Detect unused exports
- [ ] Calculate complexity scores
- [ ] Find documentation gaps
- [ ] Generate JSON report

**Deliverable:** `archaeologist scan /path/to/repo --output report.json`

### 6.2 Phase 2: Recommendations Engine (Weeks 5-6)

**Objective:** Generate actionable remediation recommendations.

#### Week 5: Recommendation Generation
- [ ] Implement duplication merge recommendations
- [ ] Implement dead code deletion recommendations
- [ ] Calculate risk scores
- [ ] Generate patch files
- [ ] Add dry-run mode

#### Week 6: LLM Integration
- [ ] Integrate Claude API for knowledge recovery
- [ ] Generate documentation stubs
- [ ] Improve recommendation quality
- [ ] Add natural language summaries

**Deliverable:** `archaeologist recommend report.json --output plan.json`

### 6.3 Phase 3: Web Dashboard (Weeks 7-10)

**Objective:** Build web UI for visualization and tracking.

#### Week 7: API Server
- [ ] Set up Fastify server
- [ ] Implement PostgreSQL schema
- [ ] Build scan management endpoints
- [ ] Add authentication (API keys)

#### Week 8: Dashboard UI - Basics
- [ ] Set up Next.js project
- [ ] Build overview page
- [ ] Implement AI attribution view
- [ ] Add duplication explorer

#### Week 9: Dashboard UI - Advanced
- [ ] Build dead code view
- [ ] Implement gaps view
- [ ] Add recommendation interface
- [ ] Create export functionality

#### Week 10: Polish & Launch
- [ ] Add metrics tracking over time
- [ ] Build burndown charts
- [ ] Performance optimization
- [ ] Documentation

**Deliverable:** Hosted dashboard at app.codearchaeologist.dev

### 6.4 Phase 4: Integrations (Weeks 11-12)

**Objective:** Integrate with developer workflows.

#### Week 11: GitHub Integration
- [ ] GitHub App for repo access
- [ ] Webhook for PR analysis
- [ ] PR comments with findings
- [ ] GitHub Action for CI

#### Week 12: VS Code Extension
- [ ] Basic extension scaffold
- [ ] Inline debt highlighting
- [ ] Quick-fix suggestions
- [ ] Dashboard link

**Deliverable:** GitHub Action + VS Code Extension

---

## 7. Testing Strategy

### 7.1 Test Categories

| Category | Coverage Target | Tools |
|----------|-----------------|-------|
| **Unit Tests** | 80% | Vitest |
| **Integration Tests** | Critical paths | Vitest + Docker |
| **E2E Tests** | Happy paths | Playwright |
| **Performance Tests** | Scan time <5min for 100K LOC | k6 |

### 7.2 Test Scenarios

#### AI Attribution Tests
- [ ] Repo with AI co-author tags detected correctly
- [ ] Repo without AI markers returns "unknown"
- [ ] Commit message patterns detected
- [ ] Large repo performance acceptable

#### Duplication Tests
- [ ] Exact duplicates found
- [ ] Near-duplicates (>80%) found
- [ ] Intentional duplicates (test fixtures) excluded
- [ ] Cross-file duplicates detected

#### Dead Code Tests
- [ ] Unused imports detected
- [ ] Unreachable functions detected
- [ ] False positives (dynamic imports) warned
- [ ] Unused dependencies detected

### 7.3 Test Data

Create test repositories:
- `test-repo-ai-heavy/` - 50% AI-generated code with markers
- `test-repo-duplicates/` - Intentional duplication patterns
- `test-repo-dead-code/` - Known dead code scenarios
- `test-repo-clean/` - Well-maintained repo (baseline)

---

## 8. Security Considerations

### 8.1 Data Handling

| Data Type | Handling | Storage |
|-----------|----------|---------|
| Source code | Never stored permanently | In-memory during scan |
| Git history | Metadata only | Encrypted at rest |
| Reports | Project-owned | Encrypted, access-controlled |
| API keys | Hashed | Secure vault |

### 8.2 Access Control

- API key authentication for CLI
- OAuth for dashboard
- Project-level permissions
- Audit logging for all actions

### 8.3 Compliance

- SOC 2 Type II ready architecture
- GDPR-compliant data handling
- No PII in reports by default

---

## 9. Success Metrics & KPIs

### 9.1 Product Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| **Time to First Scan** | Registration → first scan complete | <5 min |
| **Scan Accuracy** | Verified findings / total findings | >90% |
| **Recommendation Adoption** | Applied recommendations / total | >30% |
| **Debt Reduction** | % debt score improvement | >20% in 30 days |

### 9.2 Business Metrics

| Metric | Target (Month 6) | Target (Month 12) |
|--------|------------------|-------------------|
| **Repos Scanned** | 500 | 5,000 |
| **Paying Customers** | 20 | 100 |
| **MRR** | $10K | $50K |
| **Churn Rate** | <5% | <3% |

---

## 10. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| False positives erode trust | High | High | Conservative confidence thresholds, easy override |
| Large repo performance | Medium | High | Incremental scanning, caching |
| Language support gaps | Medium | Medium | Start with TS/Python, add based on demand |
| Competitors copy features | Medium | Medium | Move fast, build brand |
| AI attribution inaccurate | Medium | High | Multiple signals, user feedback loop |

---

## 11. Open Questions

| Question | Owner | Due Date |
|----------|-------|----------|
| Should we support self-hosted? | Product | Week 2 |
| Pricing tiers and limits? | Product | Week 4 |
| Which languages to prioritize after TS/Python? | Engineering | Week 6 |
| Partnership with AI coding tools? | Business | Month 3 |

---

## 12. Appendix

### A. Competitive Analysis

See `docs/PIVOT_DECISION_FRAMEWORK.md` for detailed competitive analysis.

### B. User Interview Summary

(To be added after customer discovery)

### C. Technical Spike Results

(To be added during implementation)

---

**Status:** READY_FOR_REVIEW
**Confidence:** HIGH_CONFIDENCE
**Next Step:** Engineering review and sprint planning
