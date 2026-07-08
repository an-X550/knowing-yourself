# Daily Review Compression Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tighten `daily-review` output so it preserves one sharp insight and one actionable next step while reducing repetitive explanation and overall reading friction.

**Architecture:** Keep the existing `daily-analyzer` / `/daily-review` / `log` flow intact and change only the shared contract plus the analyzer wording rules. Treat this as a prompt-contract behavior update, then sync versioning and release notes required by the repo rules.

**Tech Stack:** Markdown prompt specs, shared runtime contract docs, semantic versioning, changelog governance

## Global Constraints

- Do not change command names, parameter formats, output paths, file names, or workflow orchestration.
- Keep the visible structure: title, optional yesterday loop, blind spot, optional pattern link, one action, one `💊` line.
- Enforce one core insight, one pattern link sentence, one action, and a tighter word budget.
- Remove repeated explanation without softening evidence quality.
- Record the behavior change in `CHANGELOG.md` and bump `VERSION`.

---

### Task 1: Tighten the shared daily feedback contract

**Files:**
- Modify: `.claude/shared/prompt-rules.md`

**Interfaces:**
- Consumes: Existing "日反馈输出契约"
- Produces: Updated global constraints consumed by `daily-analyzer`, `/daily-review`, and `log`

- [ ] **Step 1: Update the contract language**
- [ ] **Step 2: Add explicit anti-repetition constraints**
- [ ] **Step 3: Reduce the standard word budget**

### Task 2: Tighten the analyzer prompt

**Files:**
- Modify: `.claude/agents/daily-analyzer.md`

**Interfaces:**
- Consumes: Shared contract from `.claude/shared/prompt-rules.md`
- Produces: New analyzer behavior that selects one core insight and compresses supporting explanation

- [ ] **Step 1: Rewrite the generation guidance around one insight**
- [ ] **Step 2: Rewrite output format notes with shorter limits**
- [ ] **Step 3: Add a return-time compression checklist**

### Task 3: Sync command-level wording

**Files:**
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/skills/log.md`

**Interfaces:**
- Consumes: Updated shared contract and analyzer behavior
- Produces: Entry-point docs that describe the tighter lightweight output consistently

- [ ] **Step 1: Update `/daily-review` wording**
- [ ] **Step 2: Update `log` skill wording if needed**

### Task 4: Record the behavior change

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: Repo governance rules from `AGENTS.md`
- Produces: Bumped version and release-grade changelog entry

- [ ] **Step 1: Bump patch version**
- [ ] **Step 2: Sync `PROJECT_STATUS.md` version**
- [ ] **Step 3: Add a `[修复]` changelog entry describing the tighter daily feedback contract**

### Task 5: Verify consistency

**Files:**
- Verify: `.claude/agents/daily-analyzer.md`
- Verify: `.claude/shared/prompt-rules.md`
- Verify: `.claude/commands/daily-review.md`
- Verify: `.claude/skills/log.md`
- Verify: `VERSION`
- Verify: `PROJECT_STATUS.md`
- Verify: `CHANGELOG.md`

**Interfaces:**
- Consumes: All updated files
- Produces: Confidence that wording, limits, and version docs agree

- [ ] **Step 1: Re-read modified daily-review files**
- [ ] **Step 2: Confirm one version value everywhere**
- [ ] **Step 3: Confirm the contract now states one insight and tighter limits**
