# Cleanup Scout

Find cleanup opportunities in a given area of code, ranked by impact.

## Arguments

- $ARGUMENTS: A topic, file path, directory, module, or area of code to scan for cleanup opportunities

## Instructions

You are a pragmatic code quality scout. Your job is to find actionable cleanup opportunities in the specified area and present them ranked by impact.

### Step 1: Identify the Scope

Determine what "$ARGUMENTS" refers to:

- If it's a **file path or glob pattern**: search those files directly.
- If it's a **directory or module name**: explore the directory structure and key files within it.
- If it's a **topic or concept** (e.g. "authentication", "billing", "API routes"): use Grep and Glob to find the relevant files and code related to that topic.

Read the relevant files thoroughly. You need to understand the code before you can identify cleanup opportunities.

### Step 2: Scan for Cleanup Opportunities

Systematically look for the following categories of cleanup. Do NOT fabricate issues — only report what you actually find in the code.

**Dead Code**
- Unused imports, variables, functions, methods, or classes
- Commented-out code blocks
- Unreachable code paths (e.g. after unconditional returns)
- Unused feature flags or config that reference removed features
- Deprecated methods still being called when replacements exist

**Test Gaps**
- Public functions/methods with no test coverage
- Critical code paths (error handling, edge cases) lacking tests
- Tests that are skipped/disabled without explanation
- Test files that exist but have minimal or superficial assertions
- Flaky test patterns (e.g. sleep-based timing, order-dependent tests)

**Easy Refactors**
- Duplicated code blocks that could be extracted into a shared helper
- Long methods/functions that do too many things (obvious split points)
- Deeply nested conditionals that could be flattened with early returns
- Magic numbers or hardcoded strings that should be constants
- Inconsistent naming that hurts readability
- Boolean parameters that make call sites hard to read

**Dependency & Import Cleanup**
- Unused dependencies in package manifests
- Circular dependencies
- Imports that pull in far more than what's used
- Outdated dependencies with known issues

**Type Safety & Correctness**
- `any` types (in TypeScript) or equivalent loose typing that could be tightened
- Missing null/nil checks on values that could be absent
- Unsafe type assertions or casts
- Inconsistent error handling patterns (some paths swallow errors, others propagate)

**Documentation & Readability**
- Outdated comments that contradict the code
- Complex logic with no explanation of intent
- TODO/FIXME/HACK comments that are stale or actionable now

### Step 3: Rank by Impact

Score each finding on these dimensions and use the composite to rank:

1. **Risk reduction** — Does fixing this prevent bugs or incidents? (highest weight)
2. **Developer velocity** — Does fixing this make the codebase easier to work in?
3. **Effort** — How quick is the fix? (lower effort = higher rank for similar impact)
4. **Blast radius** — How much of the codebase does this touch or affect?

Sort findings from most impactful to least impactful.

### Step 4: Present Findings

Output your findings in this format:

```
## Cleanup Opportunities: <area scanned>

<1-2 sentence summary of overall code health and what you found>

| # | Category | Finding | Effort | Impact |
|---|----------|---------|--------|--------|
| 1 | ...      | ...     | ...    | ...    |
| 2 | ...      | ...     | ...    | ...    |
...

### Details

#### 1. <Finding title>
**Category:** <category>
**Files:** <file paths>
**Effort:** S / M / L
**Impact:** High / Medium / Low

<Brief description of the issue and why it matters>

<Code snippet showing the problem, if helpful>

**Suggested fix:** <Concrete, actionable description of what to do>

---
(repeat for each finding)
```

Limit to the **top 10** most impactful findings. If there are more, mention how many additional items you found but omitted.

### Step 5: Ask What to Fix

After presenting findings, ask the user which cleanup items they'd like to tackle. Use the AskUserQuestion tool with the top findings as selectable options (multiSelect enabled) so they can pick one or more to action on.

### Important Guidelines

- **Only report real issues.** Do not invent problems. Every finding must reference specific code you read.
- **Be concrete.** Include file paths and line numbers. Show code snippets for non-obvious issues.
- **Be pragmatic.** A 2-line fix that prevents a bug class is more valuable than a large refactor that improves aesthetics.
- **Respect existing patterns.** If the codebase has a convention, don't flag code that follows it — even if you'd prefer a different style.
- **Don't suggest rewrites.** This is about incremental cleanup, not architecture overhauls.
