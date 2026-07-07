# Monthly Synthesis Theme Compression Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make monthly reports read like 2-3 evidence-backed themes instead of a stitched sequence of perspective sections.

**Architecture:** Tighten the `monthly-synthesis` prompt so the synthesis agent must cluster overlapping findings into a few main themes before drafting the report. Keep the workflow and upstream perspective outputs largely unchanged in phase 1 so we can verify improvement from the synthesis layer alone.

**Tech Stack:** Claude Code workflow JavaScript and Markdown prompt files for agents.

## Global Constraints

- Do not change command names, command arguments, workflow orchestration order, output paths, output filenames, or report section skeleton.
- Phase 1 only changes the monthly synthesis layer; do not modify `monthly-processor` or `perspectives/*.md`.
- Keep all user-facing output in Simplified Chinese.
- Keep evidence rules, path rules, and output contracts aligned with `.claude/shared/prompt-rules.md`.
- Bump patch version only if runtime behavior changes.

---

### Task 1: Tighten Monthly Synthesis Prompt

**Files:**
- Modify: `.claude/agents/monthly-synthesis.md`

**Interfaces:**
- Consumes: Combined perspective analyses produced by `monthly-review.js`, `.claude/shared/prompt-rules.md`, `.claude/shared/paths.md`, and the previous monthly report when present.
- Produces: A synthesis prompt that clusters findings into 2-3 themes with evidence, counter-signals, and verification hooks.

- [ ] **Step 1:** Add an explicit pre-writing workflow: extract candidate findings, merge overlapping findings into themes, drop weak single-perspective fragments, then map themes into the existing report skeleton.
- [ ] **Step 2:** Require each retained theme to include supporting perspectives, dated evidence, and either a counterexample or an explicit “证据不足” note.
- [ ] **Step 3:** Add anti-collage rules that forbid drafting the report by walking perspective-by-perspective or copying large perspective-specific summaries.
- [ ] **Step 4:** Preserve the existing frontmatter, chapter skeleton, error handling, and “do not read full report back” output contract.

### Task 2: Reinforce Workflow Handoff

**Files:**
- Modify: `.claude/workflows/monthly-review.js`

**Interfaces:**
- Consumes: `buildSynthesisPrompt()` in `.claude/workflows/shared.js` and the synthesis agent prompt.
- Produces: A slightly stronger handoff instruction that tells the synthesis agent to treat analyses as source material, not prewritten sections.

- [ ] **Step 1:** Review the current `extraInstruction` string and keep it minimal.
- [ ] **Step 2:** If needed, add one short sentence reinforcing “按主题综合，不按视角顺序展开”.
- [ ] **Step 3:** Avoid duplicating detailed synthesis logic in the workflow; the agent prompt remains the source of truth.

### Task 3: Regression Check and Release Hygiene

**Files:**
- Modify: `VERSION`
- Modify: `CHANGELOG.md`
- Modify: `PROJECT_STATUS.md`

**Interfaces:**
- Consumes: Current runtime version `1.3.18` and the updated synthesis prompt.
- Produces: Patch version bump, a top changelog entry, and project status notes reflecting the improved monthly synthesis behavior.

- [ ] **Step 1:** Re-read one existing monthly report sample and verify the new prompt addresses the observed collage pattern.
- [ ] **Step 2:** Update `VERSION`, `PROJECT_STATUS.md`, and `CHANGELOG.md` after code edits are complete.
- [ ] **Step 3:** Run focused verification on modified files, version consistency, and references to synthesis rules before committing.
- [ ] **Step 4:** Commit using the latest changelog entry as the commit message.
