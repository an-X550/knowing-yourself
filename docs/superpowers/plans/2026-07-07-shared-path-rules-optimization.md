# Shared Path Rules Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Strengthen shared path, prompt, banned phrase, and hook configuration contracts so agents hardcode less and drift less.

**Architecture:** Keep `.claude/shared/paths.md` as the path contract, `.claude/shared/prompt-rules.md` as the cross-agent behavior contract, `.claude/shared/banned-phrases.json` as the machine-readable banned phrase mirror, and `.claude/settings.json` as a thin hook router. Do not change command names, output paths, report filenames, or workflow orchestration.

**Tech Stack:** Markdown, JSON, Claude Code settings hooks, existing workflow JavaScript.

## Global Constraints

- Do not change command entry points, parameters, output paths, report filenames, report chapter structure, or workflow orchestration.
- `.claude/` remains the only runtime truth for product logic.
- `AGENTS.md` and `CLAUDE.md` remain mirrored only when one of them changes.
- Version changes are patch-level because this is a configuration/documentation contract optimization.

---

### Task 1: Strengthen Shared Contracts

**Files:**
- Modify: `.claude/shared/paths.md`
- Modify: `.claude/shared/prompt-rules.md`
- Modify: `.claude/shared/banned-phrases.json`
- Modify: `.claude/settings.json`

**Interfaces:**
- Consumes: existing agent/command/workflow references to shared files.
- Produces: clearer named path keys, hook ownership rules, banned phrase sync rules.

- [ ] Add named path keys and creation responsibility to `paths.md`.
- [ ] Add shared-file reading order, hook routing contract, and banned phrase sync contract to `prompt-rules.md`.
- [ ] Preserve `common` and `yearly_extra` arrays in `banned-phrases.json` while adding metadata fields.
- [ ] Reformat `settings.json` and keep it as hook routing only.

### Task 2: Light Consumer Synchronization

**Files:**
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/skills/log.md`
- Modify: `.claude/commands/weekly-review.md`
- Modify: `.claude/commands/monthly-review.md`
- Modify: `.claude/commands/commit.md`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`

**Interfaces:**
- Consumes: path keys and shared prompt rules from Task 1.
- Produces: fewer repeated literal path instructions in command docs.

- [ ] Update daily/log docs to reference `paths.md` output keys instead of repeating mkdir paths.
- [ ] Update weekly/monthly docs to describe outputs via shared path contract.
- [ ] Update commit validation docs to use `.claude/agents` and shared banned phrase validation.
- [ ] Update README/PROJECT_STATUS version and shared configuration descriptions.

### Task 3: Verification, Changelog, Commit

**Files:**
- Modify: `VERSION`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: latest version and changed file list.
- Produces: release metadata and local git commit.

- [ ] Bump version from `1.3.16` to `1.3.17`.
- [ ] Add a CHANGELOG entry describing shared path/rule optimization.
- [ ] Verify JSON parsing, version consistency, shared file consumers, banned phrase array consistency, and markdown links.
- [ ] Run local git add/commit using the latest CHANGELOG title.
