---
created: 2026-07-08
last_updated: 2026-07-08
status: complete
---

# Direction Anchor Calibration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add direction-anchor and absence-check calibration to weekly and monthly review synthesis without adding commands.

**Architecture:** Keep the existing six-question report shell. Add direction-anchor reading and absence-check requirements inside `weekly-synthesis` and `monthly-synthesis`, then document the calibrated response-review template in the review methodology.

**Tech Stack:** Claude Code agents, Markdown prompt contracts, YAML frontmatter, semantic versioning.

## Global Constraints

- Do not add a new command.
- Do not replace the six-question一级标题.
- Prefer `context.current`, previous report planning sections, `context.core_profile`, then explicit journal goals as direction-anchor sources.
- Absence checks must not treat missing evidence as failure by default.

---

### Task 1: Update Synthesis Agents

**Files:**
- Modify: `.claude/agents/weekly-synthesis.md`
- Modify: `.claude/agents/monthly-synthesis.md`

**Interfaces:**
- Consumes: `context.current`, `context.core_profile`, previous weekly/monthly reports, original journals.
- Produces: weekly/monthly reports with direction-anchor and absence-check slots inside existing six questions.

- [ ] Add direction-anchor source loading to both agents.
- [ ] Add absence status taxonomy: `有推进`, `缺席-未执行`, `缺席-未记录`, `目标变化`, `证据不足`.
- [ ] Add report insertion points under goal review, result evaluation, and planning.

### Task 2: Update Review Methodology

**Files:**
- Modify: `docs/methodology-review.md`

**Interfaces:**
- Consumes: current six-question methodology.
- Produces: documented direction calibration principle and response-review template.

- [ ] Add the principle that reviews check important absences as well as visible events.
- [ ] Add the calibrated response-review template.
- [ ] Keep existing six-question protocol unchanged.

### Task 3: Sync Project Metadata

**Files:**
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `VERSION`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: semantic versioning rules.
- Produces: version `1.5.1` and a changelog entry for the protocol update.

- [ ] Bump patch version from `1.5.0` to `1.5.1`.
- [ ] Mention direction-anchor absence checks in README and project status.
- [ ] Add a single changelog record.

### Task 4: Verify

**Files:**
- Read-only verification across Markdown files.

**Interfaces:**
- Consumes: updated documentation and prompt contracts.
- Produces: confirmation that version strings and relative links are consistent.

- [ ] Search for stale `v1.5.0` / `1.5.0` references.
- [ ] Check relative Markdown links in touched public docs.
- [ ] Inspect git diff before committing.
