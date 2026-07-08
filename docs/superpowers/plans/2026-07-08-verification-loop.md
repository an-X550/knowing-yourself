---
created: 2026-07-08
status: implemented
---

# Verification Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make daily feedback verify the previous action and persist validated behavior hypotheses.

**Architecture:** Keep `daily-analyzer` read-only. The command/skill callers save feedback and update `关于我/verified-patterns.md`. Weekly and monthly synthesis consume that file as evidence.

**Tech Stack:** Claude Code slash commands, sub-agents, Markdown contracts, YAML frontmatter.

## Global Constraints

- Do not add a new command in this phase.
- Keep daily feedback under the existing short format.
- Do not change weekly/monthly first-level six-question headings.
- Use `context.verified_patterns` from `.claude/shared/paths.md`.

---

### Task 1: Path Contract

**Files:**
- Modify: `.claude/shared/paths.md`

**Interfaces:**
- Produces: `context.verified_patterns` path key for agents, commands and skills.

- [x] Add `context.verified_patterns` pointing to `关于我/verified-patterns.md`.
- [x] Keep existing path keys unchanged.

### Task 2: Daily Feedback Contract

**Files:**
- Modify: `.claude/shared/prompt-rules.md`
- Modify: `.claude/agents/daily-analyzer.md`

**Interfaces:**
- Consumes: `input.daily_feedback`, `context.verified_patterns`.
- Produces: daily feedback text with prior-action verification when evidence exists.

- [x] Require previous `💊` extraction.
- [x] Require evidence-backed verification status.
- [x] Forbid date slips such as writing “明年” when the intended horizon is tomorrow.

### Task 3: Caller Persistence

**Files:**
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/skills/log.md`

**Interfaces:**
- Consumes: daily feedback output and `context.verified_patterns`.
- Produces: updated `关于我/verified-patterns.md`.

- [x] After saving daily feedback, update the pattern file.
- [x] Confirmed twice moves to confirmed patterns.
- [x] Clearly false moves to falsified hypotheses.
- [x] Evidence insufficient remains pending.

### Task 4: Periodic Review Consumption

**Files:**
- Modify: `.claude/agents/weekly-synthesis.md`
- Modify: `.claude/agents/monthly-synthesis.md`

**Interfaces:**
- Consumes: `context.verified_patterns`.
- Produces: weekly/monthly reports that prioritize validated behavior learning.

- [x] Read verified patterns with daily feedback.
- [x] Surface verified, falsified and repeated-not-done actions in evaluation/planning.

### Task 5: Documentation and Release State

**Files:**
- Modify: `docs/first-principles.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `README.md`
- Modify: `VERSION`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Produces: release record for v1.5.2.

- [x] Update current version to `1.5.2`.
- [x] Record verification loop as current priority.
- [x] Add changelog entry.
