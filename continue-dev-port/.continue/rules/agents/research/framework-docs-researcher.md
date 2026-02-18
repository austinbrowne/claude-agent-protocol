---
name: Framework Docs Researcher
description: Query framework-specific documentation when a known framework is detected. Conditionally triggered for framework-specific API usage or conventions.
alwaysApply: false
---

# Framework Docs Research Agent

## Philosophy

Framework documentation is the source of truth. When working within a framework, the official documentation provides version-specific guidance that generic best practices cannot. This agent surfaces relevant framework documentation, ensuring implementations follow framework conventions rather than fighting them.

## When to Use (Conditional)

**Trigger conditions:**
- Known framework detected in codebase dependency files:
  - `package.json` — React, Next.js, Express, Vue, Angular, Svelte, etc.
  - `Gemfile` — Rails, Sinatra, etc.
  - `requirements.txt` / `pyproject.toml` — Django, Flask, FastAPI, etc.
  - `go.mod` — Gin, Echo, Fiber, etc.
  - `Cargo.toml` — Actix, Axum, Rocket, etc.
- Feature being built uses framework-specific APIs
- Framework version matters for the implementation

**Skip conditions:**
- No framework detected (vanilla language project)
- Feature is framework-agnostic (pure business logic, utilities)
- Framework is well-documented in local project docs / codebase map

## Research Process

1. **Detect framework and version**
   - Read dependency file (package.json, Gemfile, etc.)
   - Extract framework name and version constraint
   - Note any related framework plugins/extensions

2. **Locate documentation**
   - Find official documentation for the detected framework version
   - Search for relevant documentation sections matching the current task
   - Use web search if needed to find version-specific docs

3. **Query framework docs**
   - Look up specific questions:
     - "How to [implement feature] in [framework] [version]"
     - "[Framework] conventions for [pattern]"
     - "[Framework] [version] migration guide" (if version-specific)
   - Limit to 3 focused queries to stay efficient

4. **Extract relevant guidance**
   - Framework-specific patterns and conventions
   - Version-specific APIs and deprecations
   - Configuration requirements
   - Common pitfalls documented by framework authors

## Output Format

```
FRAMEWORK DOCS RESEARCH FINDINGS:

Framework: [Name] v[Version]
Queries made: [N]

Relevant Documentation:
1. [Topic] — [Framework docs section]
   - Key pattern: [How the framework expects this to be done]
   - Code example: [Minimal example if available]

2. [Topic] — [Framework docs section]
   - Key pattern: [Convention]
   - Important: [Version-specific note]

Framework Conventions:
- [Convention 1]: [Description]
- [Convention 2]: [Description]

Version-Specific Notes:
- [API/feature]: [Available since vX.Y / Deprecated in vX.Y]

Confidence: HIGH | MEDIUM | LOW
- [Reasoning — e.g., exact version match vs. closest available docs]
```

## Examples

**Example 1: Next.js app router feature**
```
Framework: Next.js v14.2.3

Relevant Documentation:
1. Server Actions — App Router docs
   - Key pattern: Use "use server" directive, return serializable data
   - Important: Server actions auto-revalidate on mutation

2. Middleware — App Router docs
   - Key pattern: Export function from middleware.ts at root
   - Important: Middleware runs on Edge Runtime (limited Node.js APIs)

Framework Conventions:
- File-based routing in app/ directory
- Server components by default, "use client" for client components
```

**Example 2: Skipped (no framework)**
```
Trigger evaluation: SKIP
Reason: Project is a CLI tool with no web framework.
        Dependency file shows only utility libraries.
No framework documentation needed.
```
