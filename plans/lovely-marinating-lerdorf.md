# Plan: Code-Level AI Detection Patterns

## Overview

Add heuristic-based detection of AI-generated code by analyzing the source code itself, independent of git history. This catches AI code even when commit markers are missing (squashed commits, rebases, stripped co-author tags).

## Research Summary

From academic research on AI code detection:

| Pattern Category | Confidence | Detection Method |
|-----------------|------------|------------------|
| Comment patterns (over-commenting, explanatory style) | HIGH | AST + text analysis |
| Naming conventions (verbose, no abbreviations) | HIGH | AST identifier analysis |
| Code structure (longer functions, perfect formatting) | MEDIUM-HIGH | AST metrics |
| Error handling (excessive try-catch, null checks) | MEDIUM | AST pattern matching |
| Low perplexity / predictability | MEDIUM | Statistical analysis |
| Lack of typos in strings/comments | MEDIUM | Text analysis |

**Key insight**: No single pattern is definitive, but combining multiple signals produces reliable detection.

## Architecture

### New Module: `packages/core/src/analyzers/code-patterns.ts`

```
packages/core/src/
├── analyzers/
│   ├── code-patterns/
│   │   ├── index.ts              # Main CodePatternAnalyzer class
│   │   ├── types.ts              # Pattern-specific types
│   │   ├── detectors/
│   │   │   ├── comment-detector.ts    # Over-commenting, explanatory style
│   │   │   ├── naming-detector.ts     # Verbose names, no abbreviations
│   │   │   ├── structure-detector.ts  # Function length, complexity
│   │   │   ├── defensive-detector.ts  # Excessive error handling
│   │   │   └── style-detector.ts      # Formatting consistency
│   │   └── scoring.ts            # Combine signals into confidence score
```

### Detection Signals

#### 1. Comment Analysis (weight: 25%)
- **Comment-to-code ratio** - AI tends to over-comment (>30% = suspicious)
- **Explanatory comments** - Comments that describe "what" not "why"
- **JSDoc completeness** - AI always adds full JSDoc vs humans skip params
- **No typos/informal language** - Humans write "TODO: fix this shit"

#### 2. Naming Analysis (weight: 25%)
- **Average identifier length** - AI uses longer names (>15 chars avg = suspicious)
- **Abbreviation ratio** - Humans use `idx`, `val`, `tmp`; AI uses `index`, `value`, `temporary`
- **Naming consistency** - AI is 100% consistent; humans vary

#### 3. Structure Analysis (weight: 20%)
- **Function length** - AI functions ~10-15% longer
- **Cyclomatic complexity consistency** - AI has predictable complexity
- **Nesting depth patterns** - AI avoids deep nesting more consistently

#### 4. Defensive Coding (weight: 20%)
- **Try-catch density** - AI wraps more code in try-catch
- **Null check density** - AI checks nulls that can't be null
- **Type guard frequency** - Excessive runtime type checking

#### 5. Style Consistency (weight: 10%)
- **Perfect formatting** - No inconsistencies in spacing/indentation
- **Import organization** - AI perfectly groups/sorts imports
- **Consistent patterns** - Same problem solved identically across files

### Scoring Algorithm

```typescript
interface CodePatternSignal {
  name: string;
  weight: number;
  score: number;      // 0-100 (0 = human-like, 100 = AI-like)
  evidence: string[]; // Specific examples found
}

function calculateAILikelihood(signals: CodePatternSignal[]): number {
  // Weighted average of all signals
  const totalWeight = signals.reduce((sum, s) => sum + s.weight, 0);
  const weightedScore = signals.reduce((sum, s) => sum + s.score * s.weight, 0);
  return weightedScore / totalWeight;
}
```

### Output Format

```typescript
interface CodePatternReport {
  overallAILikelihood: number;  // 0-100
  confidence: "low" | "medium" | "high";
  files: FilePatternAnalysis[];
  signals: CodePatternSignal[];
}

interface FilePatternAnalysis {
  filePath: string;
  aiLikelihood: number;
  topSignals: CodePatternSignal[];
  recommendation: string | null;
}
```

## Implementation Plan

### Phase 1: Core Infrastructure
1. Create `code-patterns/types.ts` with interfaces
2. Create `code-patterns/index.ts` with `CodePatternAnalyzer` class
3. Create `scoring.ts` with weighted scoring algorithm

### Phase 2: Detectors (can be done incrementally)
4. `comment-detector.ts` - Parse comments, calculate ratios, detect patterns
5. `naming-detector.ts` - Extract identifiers, measure lengths, find abbreviations
6. `structure-detector.ts` - Function metrics, complexity, nesting
7. `defensive-detector.ts` - Count try-catch, null checks, type guards
8. `style-detector.ts` - Formatting consistency, import organization

### Phase 3: Integration
9. Add `CodePatternReport` to `ScanResult` in `types.ts`
10. Add `includeCodePatterns` option to `ScanOptions`
11. Integrate into `Scanner` class
12. Add CLI flag `--code-patterns` / `--no-code-patterns`
13. Update CLI output to show code pattern results

### Phase 4: Testing
14. Unit tests for each detector
15. Integration tests with known AI/human code samples
16. Calibration against this repo (known 100% AI)

## Key Files to Modify

- `packages/core/src/types.ts` - Add CodePatternReport to ScanResult
- `packages/core/src/scanner.ts` - Integrate CodePatternAnalyzer
- `packages/core/src/index.ts` - Export new analyzer
- `packages/cli/src/index.ts` - Add CLI options and output

## Key Files to Create

- `packages/core/src/analyzers/code-patterns/index.ts`
- `packages/core/src/analyzers/code-patterns/types.ts`
- `packages/core/src/analyzers/code-patterns/scoring.ts`
- `packages/core/src/analyzers/code-patterns/detectors/comment-detector.ts`
- `packages/core/src/analyzers/code-patterns/detectors/naming-detector.ts`
- `packages/core/src/analyzers/code-patterns/detectors/structure-detector.ts`
- `packages/core/src/analyzers/code-patterns/detectors/defensive-detector.ts`
- `packages/core/src/analyzers/code-patterns/detectors/style-detector.ts`
- `packages/core/src/analyzers/code-patterns/__tests__/` - Test files

## Dependencies

- **tree-sitter** (already installed) - For AST parsing
- **tree-sitter-typescript** (already installed) - TypeScript/JavaScript parsing

No new dependencies required.

## Confidence Levels

Based on research, expected accuracy:
- **High confidence (>80%)**: When multiple strong signals align (comment patterns + naming + structure)
- **Medium confidence (60-80%)**: Some signals present but not conclusive
- **Low confidence (<60%)**: Insufficient signals or mixed signals

## Integration with Git History Detection

**Approach**: Both metrics available independently, with a weighted combined score as default.

### Report Structure

```typescript
interface CombinedAIReport {
  // Independent metrics (both always shown)
  gitHistoryAttribution: {
    aiPercentage: number;      // From commit analysis
    confidence: number;        // Based on co-author tags vs patterns
    method: "co-author" | "commit-pattern" | "none";
  };

  codePatternAnalysis: {
    aiLikelihood: number;      // 0-100 from heuristics
    confidence: "low" | "medium" | "high";
    topSignals: CodePatternSignal[];
  };

  // Combined score (weighted default)
  combined: {
    aiScore: number;           // Weighted: 70% git + 30% code patterns
    confidence: number;        // Lower of the two confidences
    recommendation: string;    // Human-readable summary
  };
}
```

### CLI Output (Example)

```
AI Attribution Analysis
═══════════════════════════════════════════════

Git History Analysis:
  AI-attributed commits: 100% (4/4 commits)
  Detection method: Co-author tags (95% confidence)
  Tools detected: Claude

Code Pattern Analysis:
  AI likelihood: 87% (high confidence)
  Top signals:
    • Comment density: 34% (typical AI: >30%)
    • Avg identifier length: 18 chars (typical AI: >15)
    • Defensive coding score: 72/100
    • No abbreviations in 94% of identifiers

Combined Score: 96% AI-generated
  (weighted: 70% git history + 30% code patterns)
```

### Future UI Considerations

- Side-by-side comparison of both scores
- Drill-down into specific signals
- File-level heatmap showing both metrics
- Trend over time (are new commits more/less AI-heavy?)

## Limitations

1. **Not definitive** - Heuristics can be fooled by disciplined humans or modified AI output
2. **Language-specific** - Initial implementation for TypeScript/JavaScript only
3. **Training bias** - Patterns based on current AI tools; may need updates as tools evolve
4. **False positives** - Very clean human code may score as AI-like

## Success Criteria

1. Correctly identifies this repo as ~100% AI-generated via code patterns alone
2. Reasonable false positive rate on known human-written code (<20%)
3. Both metrics clearly available in output
4. Combined score provides sensible default interpretation
