# Prompt Dedup Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce duplicated prompt instructions without changing command entrypoints, file paths, output filenames, report section structure, or review workflows.

**Architecture:** Add one shared prompt-rules document for cross-agent constraints, then shorten the highest-duplication agents so they reference shared rules instead of repeating them. Keep each agent's unique input, data loading, synthesis logic, output contract, and error behavior explicit.

**Tech Stack:** Markdown prompt files for Claude Code agents and shared project documentation.

## Global Constraints

- Do not add product features.
- Do not change command names, command arguments, workflow orchestration, output directories, output filenames, or report section structure.
- Keep `.claude/` as the only runtime truth.
- Keep all user-facing agent/command/workflow/perspective output in Simplified Chinese.
- Bump patch version only.

---

### Task 1: Shared Prompt Rules

**Files:**
- Create: `.claude/shared/prompt-rules.md`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`

**Interfaces:**
- Consumes: Existing `.claude/shared/paths.md` and `docs/analysis-standards.md` as authoritative references.
- Produces: A shared prompt rule document referenced by runtime agents.

- [x] **Step 1:** Create `.claude/shared/prompt-rules.md` with concise hard constraints for paths, evidence, output contracts, quality gates, and no-feature-change boundaries.
- [x] **Step 2:** Add the new shared file to README/PROJECT_STATUS shared configuration descriptions.
- [x] **Step 3:** Verify the new file has YAML frontmatter and no broken relative links.

### Task 2: High-Duplication Agent Refactor

**Files:**
- Modify: `.claude/agents/daily-analyzer.md`
- Modify: `.claude/agents/weekly-synthesis.md`
- Modify: `.claude/agents/monthly-synthesis.md`
- Modify: `.claude/agents/yearly-synthesis.md`

**Interfaces:**
- Consumes: `.claude/shared/prompt-rules.md`.
- Produces: Shorter agent prompts with the same runtime roles and output contracts.

- [x] **Step 1:** Replace repeated path-loading and quality-gate explanations with references to shared prompt rules.
- [x] **Step 2:** Preserve each agent's unique workflow, allowed tools, output format, and write/no-write contract.
- [x] **Step 3:** Verify each modified agent still references `paths.md` and `prompt-rules.md`.

### Task 3: Version, Changelog, and Verification

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: Existing version `1.3.12`.
- Produces: Version `1.3.13` and a changelog entry describing prompt deduplication.

- [x] **Step 1:** Bump `VERSION` to `1.3.13`.
- [x] **Step 2:** Update PROJECT_STATUS current version and last_updated date.
- [x] **Step 3:** Add a top CHANGELOG entry with affected files and summary.
- [x] **Step 4:** Run verification commands for version consistency, required references, and git diff review.
- [ ] **Step 5:** Commit using the latest CHANGELOG entry as the commit message.
