# Zhiji User Feishu AI Deployment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Export the single-user Feishu daily-feedback runtime and provider-neutral deployment guidance into `zhiji-user` without exporting personal configuration or state.

**Architecture:** Share the deterministic runtime and config schema byte-for-byte. Keep standalone user guidance in the overlay, then regenerate the nested distribution repository through the existing manifest.

**Tech Stack:** PowerShell 5.1, JSON, Markdown, official `lark-cli`, Codex/Claude/DeepSeek-compatible analysis adapters.

## Global Constraints

- Never export credentials, open_id values, folder tokens, project IDs, runtime state, journals, reports, or personal validation IDs.
- Do not directly hand-edit generated `zhiji-user` files; edit the overlay and run the exporter.
- Keep Feishu and TickTick distribution deterministic and capability-limited.

---

### Task 1: Add distribution contract tests

**Files:**
- Modify: `tests/distribution-boundary.tests.ps1`

- [x] Assert the workflow and config example are shared.
- [x] Assert the standalone deployment files and README links exist.
- [x] Assert the workflow pins `gpt-5.4`, uses read-only mode and non-generating login preflight.
- [x] Run the boundary test and confirm it fails because the files are not exported yet.

### Task 2: Add overlay runtime and documentation

**Files:**
- Modify: `packaging/zhiji-user-boundaries.json`
- Create: `packaging/zhiji-user-overlay/.claude/workflows/local-feishu-daily-feedback.ps1`
- Create: `packaging/zhiji-user-overlay/.claude/shared/local-feishu-daily-feedback-config.example.json`
- Create: `packaging/zhiji-user-overlay/docs/local-feishu-daily-feedback-entry.md`
- Create: `packaging/zhiji-user-overlay/docs/feishu-ai-deployment.md`
- Modify: `packaging/zhiji-user-overlay/README.md`

- [x] Copy shared runtime files byte-for-byte from the main runtime.
- [x] Write standalone setup and provider-replacement instructions with explicit human authorization gates.
- [x] Add README navigation and the shortest usable phone workflow.
- [x] Run boundary test and confirm overlay classification passes up to generated-package drift.

### Task 3: Export and verify both repositories

**Files:**
- Generated: `zhiji-user/**`
- Modify: `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`

- [x] Run `scripts/export-zhiji-user.ps1`.
- [x] Run distribution boundary, local Feishu entry and project integrity tests.
- [x] Confirm no personal data is tracked in the nested repository.
- [x] Update version and governance records, then commit the main and nested repositories separately.
