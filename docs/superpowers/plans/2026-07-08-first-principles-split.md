---
created: 2026-07-08
type: implementation_plan
topic: first-principles-split
---

# First Principles Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore `docs/first-principles.md` as a human-facing reminder document and move AI runtime guidance into `.claude/shared/ai-operating-principles.md`.

**Architecture:** Human philosophy stays in `docs/`. AI operational rules live under `.claude/shared/`, alongside prompt and path contracts. Project metadata and loading rules are updated to reference the new split.

**Tech Stack:** Markdown, YAML frontmatter, Claude Code project conventions.

## Global Constraints

- Keep `AGENTS.md` and `CLAUDE.md` byte-for-byte synchronized.
- Bump patch version because this changes public docs and AI context-loading rules.
- Add one CHANGELOG entry after validation.
- Do not move personal data directories.

---

### Task 1: Split Principle Responsibilities

**Files:**
- Modify: `docs/first-principles.md`
- Create: `.claude/shared/ai-operating-principles.md`

**Interfaces:**
- Consumes: Existing first-principles content and `.claude/shared/prompt-rules.md` conventions.
- Produces: One human reminder and one AI runtime contract.

- [ ] Replace `docs/first-principles.md` with a shorter human-facing reminder.
- [ ] Add `.claude/shared/ai-operating-principles.md` with concrete AI operating rules.

### Task 2: Update Loading Rules And Public References

**Files:**
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: New `.claude/shared/ai-operating-principles.md`.
- Produces: Updated context-loading and documentation links.

- [ ] Change default AI context loading from `docs/first-principles.md` to `.claude/shared/ai-operating-principles.md`.
- [ ] Keep `docs/first-principles.md` described as a human reminder document.
- [ ] Mirror the same edits in `AGENTS.md` and `CLAUDE.md`.

### Task 3: Sync Release Metadata

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: Current version `1.5.2`.
- Produces: Version `1.5.3` and one changelog record.

- [ ] Bump `VERSION` to `1.5.3`.
- [ ] Update `PROJECT_STATUS.md` version and key decision record.
- [ ] Add a `[文档]` CHANGELOG entry.

### Task 4: Validate

**Files:**
- Read: affected Markdown files

**Interfaces:**
- Consumes: Updated documents.
- Produces: Validation evidence.

- [ ] Confirm `AGENTS.md` and `CLAUDE.md` are synchronized.
- [ ] Confirm README badge, `VERSION`, and `PROJECT_STATUS.md` version match.
- [ ] Confirm links to the new AI operating principles file resolve.
