# 复盘快路径优化 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tighten daily, weekly, monthly, and life-design runtime paths so they skip development-governance context while keeping evidence quality and report structure intact.

**Architecture:** The change stays inside prompt and workflow layers. Commands and shared rules define fast-path boundaries; synthesis agents switch to layered reading; workflow prompts stop encouraging unconditional raw-log rereads.

**Tech Stack:** Markdown runtime prompts, Claude workflows in JavaScript, repo governance docs.

## Global Constraints

- Do not change command names, output paths, or report一级标题结构.
- Preserve evidence discipline, verification-loop behavior, and direction-anchor checks.
- Prefer prompt/runtime-contract edits over new files or new agents.
- Version, status, changelog, and README badge must stay consistent if behavior changes.

---

### Task 1: Define Shared Fast-Path Rules

**Files:**
- Modify: `.claude/shared/prompt-rules.md`
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/skills/log.md`

**Interfaces:**
- Consumes: existing path keys and daily feedback contracts
- Produces: shared runtime rule that review-style commands skip development-governance context by default

- [ ] Add a shared rule that review commands default to runtime fast paths and do not load governance files unless editing product files.
- [ ] Update `daily-review.md` to prefer existing feedback output unless the user explicitly requests a rerun.
- [ ] Keep `log.md` aligned so pasted single-day journals still reuse the same daily-analysis contract instead of a parallel flow.

### Task 2: Tighten Daily Analyzer Inputs

**Files:**
- Modify: `.claude/agents/daily-analyzer.md`

**Interfaces:**
- Consumes: `paths.md`, `daily-feedback.md`, `evidence-and-verification.md`, target journal, previous daily feedback, `verified-patterns.md`
- Produces: explicit daily fast-path behavior with no default monthly-report reread

- [ ] Remove default monthly-report rereads from the daily analyzer instructions.
- [ ] State the minimal required inputs and the evidence-first boundary for single-day analysis.
- [ ] Preserve the existing output format and D0-D6 quality gate references.

### Task 3: Tighten Weekly and Monthly Synthesis Layers

**Files:**
- Modify: `.claude/agents/weekly-synthesis.md`
- Modify: `.claude/agents/monthly-synthesis.md`
- Modify: `.claude/workflows/weekly-review.js`
- Modify: `.claude/workflows/monthly-review.js`
- Modify: `.claude/agents/monthly-processor.md`

**Interfaces:**
- Consumes: perspective analyses, daily feedback, verified patterns, current context, prior reports
- Produces: layered-read synthesis prompts that only sample raw logs on conflict or missing evidence

- [ ] Update `weekly-synthesis.md` so default input priority is daily feedback, verified patterns, current context, and passed analyses before raw logs.
- [ ] Update `monthly-synthesis.md` so passed analyses remain the primary source and raw logs become conditional.
- [ ] Adjust workflow `extraInstruction` strings to match the new layered-read policy.
- [ ] Resolve the `Process week ...` ambiguity in `monthly-processor.md` so weekly reuse no longer conflicts with month-only wording.

### Task 4: Tighten Life Design Modes

**Files:**
- Modify: `.claude/agents/life-design-synthesis.md`
- Modify: `.claude/commands/life-design.md`

**Interfaces:**
- Consumes: mode-specific evidence sources and existing long-form report structure
- Produces: explicit per-mode read priorities with `quick` and `standard` favoring summaries before raw journals

- [ ] Rewrite the evidence collection section to distinguish `quick`, `standard`, `full`, and `odyssey` read priorities.
- [ ] Preserve the current report structure and validation requirements.
- [ ] Reflect the faster mode expectations in the command doc without changing the public command surface.

### Task 5: Sync Release Metadata and Verify

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: repo versioning and release-record rules
- Produces: version-consistent release metadata for the fast-path behavior change

- [ ] Bump the patch version.
- [ ] Update `PROJECT_STATUS.md` with the new version and the runtime fast-path decision.
- [ ] Add one release-grade changelog entry describing the optimization.
- [ ] Update the README version badge.
- [ ] Run verification commands for JS syntax, version consistency, and targeted content checks.
