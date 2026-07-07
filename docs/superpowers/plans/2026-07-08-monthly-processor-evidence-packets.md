---
created: 2026-07-08
status: 已完成
---

# Monthly Processor Evidence Packets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make monthly perspective outputs serve as evidence packets for synthesis instead of small standalone reports.

**Architecture:** Tighten the upstream monthly processor contract first, then align the two highest-risk narrative perspectives (`therapist`, `values-meaning`) to that contract. After that, scan the remaining perspectives for small-report language and apply only narrow wording/output constraints where they support phase 2.

**Tech Stack:** Markdown prompt files for Claude Code agents and perspectives.

## Global Constraints

- Do not repeat phase 1: leave `monthly-synthesis` theme compression unchanged unless verification finds a direct contradiction.
- Do not delete, merge, or retire perspectives in phase 2.
- Keep command names, workflow orchestration, output paths, and report skeleton unchanged.
- Keep all user-facing output in Simplified Chinese.
- Preserve evidence-date requirements and the distinction between life-content perspectives and methodology perspectives.

---

### Task 1: Tighten `monthly-processor` Contract

**Files:**
- Modify: `.claude/agents/monthly-processor.md`

**Interfaces:**
- Consumes: User input `Process [MONTH] as [PERSPECTIVE]`, paths from `.claude/shared/paths.md`, and perspective definitions from `perspectives/[perspective].md`.
- Produces: One intermediate Markdown evidence packet at the existing perspective output path.

- [ ] **Step 1:** Rename the role language from monthly report processing to monthly evidence packet processing.
- [ ] **Step 2:** Add a universal intermediate-product contract: source material for synthesis, not a standalone report.
- [ ] **Step 3:** Add common evidence packet requirements: dated evidence, confidence, counterexamples or evidence gaps, and synthesis handoff notes.
- [ ] **Step 4:** Add forbidden output behaviors: final conclusions, advice, next-month plans, cross-period comparison, and perspective-by-perspective report prose.

### Task 2: Convert `therapist` to a Psychological Evidence Packet

**Files:**
- Modify: `perspectives/therapist.md`

**Interfaces:**
- Consumes: Current-month journal entries and the monthly-processor evidence packet contract.
- Produces: Short psychological pattern candidates, emotional evidence tables, regulation data, risk/protection signals, and synthesis handoff notes.

- [ ] **Step 1:** Update the role to “心理证据提取者” and state that narrative paragraphs are support material only.
- [ ] **Step 2:** Replace long narrative sections with compact candidate findings and evidence tables.
- [ ] **Step 3:** Add confidence and evidence-boundary fields to prevent over-interpreting weak signals.
- [ ] **Step 4:** Keep clinical safety constraints: no diagnosis, no treatment advice, no cross-period comparison.

### Task 3: Convert `values-meaning` to a Meaning Evidence Packet

**Files:**
- Modify: `perspectives/values-meaning.md`

**Interfaces:**
- Consumes: Current-month journal entries, optional `关于我/core-profile.md`, and the monthly-processor evidence packet contract.
- Produces: Value-alignment evidence, meaning/emptiness signals, flow data, authenticity signals, and synthesis handoff notes.

- [ ] **Step 1:** Update the role to “意义证据提取者” and remove final-judgment framing.
- [ ] **Step 2:** Keep the value-alignment table but make it evidence-first and synthesis-oriented.
- [ ] **Step 3:** Replace broad prose sections with compact signal tables and candidate findings.
- [ ] **Step 4:** Remove or soften “意义商数” so it does not pre-write the final monthly interpretation.

### Task 4: Lightly Align Other Perspectives

**Files:**
- Inspect/modify as needed: `perspectives/chronicle.md`, `perspectives/coach.md`, `perspectives/relationships.md`, `perspectives/strengths.md`, `perspectives/growth-dimensions.md`, `perspectives/journal-quality.md`, `perspectives/review-coach.md`, `perspectives/README.md`

**Interfaces:**
- Consumes: Existing perspective definitions.
- Produces: Narrow wording changes that reinforce evidence/data-source responsibilities without deleting perspectives.

- [ ] **Step 1:** Scan for “报告/最终总结/建议/下月规划/对比”等抢综合职责的 wording.
- [ ] **Step 2:** Apply only local wording changes where a perspective might produce standalone report prose.
- [ ] **Step 3:** Preserve methodology perspectives' scoring and correction responsibilities.

### Task 5: Verify and Prepare for Phase 3

**Files:**
- Modify: `docs/specs/monthly-processor-evidence-packets.md`
- Modify: `docs/superpowers/plans/2026-07-08-monthly-processor-evidence-packets.md`

**Interfaces:**
- Consumes: Modified prompt files.
- Produces: Completed spec/plan status and evidence for the phase-3 perspective audit.

- [ ] **Step 1:** Run focused text scans for old “小报告” wording in modified files.
- [ ] **Step 2:** Review git diff to confirm no phase-1 files were unnecessarily changed.
- [ ] **Step 3:** Mark spec and plan complete only after verification evidence is available.
