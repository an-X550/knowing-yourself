# Workflow Shared Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce drift across weekly, monthly, and yearly workflows by centralizing shared summary quality gates, report path templates, and perspective registry.

**Architecture:** Add `.claude/workflows/shared.js` as the runtime workflow helper module. Existing workflow entry files keep their public names, args, phases, agent types, and output filenames, but import shared functions/constants for repeated logic.

**Tech Stack:** Claude workflow JavaScript modules, Markdown, JSON.

## Global Constraints

- Do not change slash command names, workflow names, args, agent types, report filenames, or report chapter structures.
- Keep `.claude/shared/banned-phrases.json` as the machine-readable banned phrase mirror; verify it against workflow runtime constants.
- Keep `.claude/shared/paths.md` as the human/agent path contract; workflow helper path templates must match its output keys.

---

### Task 1: Add Workflow Shared Helper

**Files:**
- Create: `.claude/workflows/shared.js`

**Interfaces:**
- Produces: `PATH_TEMPLATES`, `PERSPECTIVE_REGISTRY`, `MODES`, `extractChatSummary`, `validateChatSummary`, `formatAnalyses`, `resolvePerspectives`, `estimateTime`, `buildSynthesisPrompt`.

- [ ] Add report path templates matching `paths.md` output keys.
- [ ] Add one perspective registry shared by weekly/monthly workflows.
- [ ] Add one summary extractor and quality gate shared by all three workflows.
- [ ] Add prompt builder that references shared contracts rather than spelling every rule inline.

### Task 2: Refactor Workflow Entrypoints

**Files:**
- Modify: `.claude/workflows/weekly-review.js`
- Modify: `.claude/workflows/monthly-review.js`
- Modify: `.claude/workflows/yearly-review.js`

**Interfaces:**
- Consumes: helper exports from Task 1.
- Preserves: workflow names, args, agent types, minimum successful perspective checks, report paths.

- [ ] Replace local core perspective array in weekly workflow with shared registry filtering.
- [ ] Replace monthly local registry, modes, and helper functions with imports.
- [ ] Replace three duplicated summary gates with `validateChatSummary`.
- [ ] Replace report path string construction with `renderPath`.

### Task 3: Docs, Verification, Commit

**Files:**
- Modify: `.claude/shared/prompt-rules.md`
- Modify: `.claude/shared/banned-phrases.json`
- Modify: `.claude/commands/commit.md`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `VERSION`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Produces: version `1.3.18`, changelog entry, validation evidence, local commit.

- [ ] Document workflow helper as runtime consumer of banned phrase and path mirrors.
- [ ] Update commit validation description to compare JSON with `.claude/workflows/shared.js`.
- [ ] Run JS syntax/import checks, JSON checks, banned phrase drift check, version checks, markdown link check, and git diff check.
- [ ] Commit locally with the latest CHANGELOG title.
