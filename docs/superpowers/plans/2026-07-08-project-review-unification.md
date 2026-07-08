---
created: 2026-07-08
status: 已完成
---

# Project Review Unification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a complete project-review command chain that reuses the unified six-question review protocol across weekly, monthly, and project retrospectives.

**Architecture:** Extend shared path/runtime helpers first, then add a single-synthesis project workflow and agent, then wire command routing and sync user-facing docs/version records.

**Tech Stack:** Markdown command/agent definitions, Claude workflow JavaScript helpers, repository documentation.

## Global Constraints

- Preserve the current weekly/monthly “六问一级标题 + 内层综合分析” behavior.
- Do not introduce a separate project-specific multi-perspective processor chain in this round.
- Keep all user-facing output in Simplified Chinese.
- New project reports must write to a dedicated project-review output path.

---

### Task 1: Extend Shared Contracts

**Files:**
- Modify: `.claude/shared/paths.md`
- Modify: `.claude/workflows/shared.js`

**Interfaces:**
- Consumes: Existing named path keys and workflow helper conventions.
- Produces: `output.project_report`, `PATH_TEMPLATES.projectReport`, and a reusable project slug helper.

- [x] Add a project review output path key in `paths.md`.
- [x] Add a project report template in `shared.js`.
- [x] Add a helper that sanitizes project names for filenames.

### Task 2: Add Project Review Runtime Chain

**Files:**
- Create: `.claude/commands/project-review.md`
- Create: `.claude/workflows/project-review.js`
- Create: `.claude/agents/project-synthesis.md`
- Modify: `.claude/commands/review.md`

**Interfaces:**
- Consumes: User arguments, current conversation project materials, shared review methodology.
- Produces: One project review report using the unified six-question shell.

- [x] Add `/project-review` command documentation and invocation contract.
- [x] Add `project-review.js` workflow with gather/synthesize phases.
- [x] Add `project-synthesis.md` agent with fixed six-question output.
- [x] Update `/review` routing rules to recognize project retrospectives.

### Task 3: Sync Documentation and Release State

**Files:**
- Modify: `docs/methodology-review.md`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`

**Interfaces:**
- Consumes: New command/agent/workflow/path facts.
- Produces: Updated public docs and release metadata.

- [x] Document the project-review-specific template and command skeleton.
- [x] Update README command table and lifecycle overview.
- [x] Update PROJECT_STATUS counts, progress, and decisions.
- [x] Bump patch version and record one changelog entry.
