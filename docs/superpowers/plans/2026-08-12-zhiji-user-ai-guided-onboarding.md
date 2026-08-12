# Zhiji User AI-Guided Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the distribution README sufficient for a new user to understand the product, obtain first value, delegate optional setup to AI, complete unavoidable human actions safely, and continue daily use.

**Architecture:** Keep onboarding information layered: README for product discovery and copyable user actions; `docs/result-distribution-setup.md` for the AI execution contract and detailed external-service gates; `.gitignore` for runtime configuration protection. Reuse the existing export process and distribution runtime without adding an installer.

**Tech Stack:** Markdown, PowerShell contract tests, existing user-package export script, Git version governance.

## Global Constraints

- Local logging and review must remain usable without Feishu or TickTick.
- AI automates safe steps and pauses for one human-only official action at a time.
- Secrets never enter chat, project files, commands, reports, configuration, or state.
- Only non-sensitive target identifiers such as Feishu folder tokens and TickTick `project_id` may be saved in ignored local configuration.
- Feishu and TickTick are configured and verified independently.
- Do not add a custom installer, new external dependency, or new distribution behavior.

---

### Task 1: Make onboarding user- and AI-executable

**Files:**
- Modify: `tests/result-distribution-setup.tests.ps1`
- Modify: `packaging/zhiji-user-overlay/README.md`
- Modify: `docs/result-distribution-setup.md`
- Modify: `packaging/zhiji-user-overlay/docs/result-distribution-setup.md`
- Modify: `packaging/zhiji-user-overlay/.gitignore`
- Generate: `zhiji-user/README.md`
- Generate: `zhiji-user/docs/result-distribution-setup.md`
- Generate: `zhiji-user/.gitignore`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`
- Modify: `docs/specs/evolution-roadmap.md`

**Interfaces:**
- Consumes: existing `docs/result-distribution-setup.md`, config example, export manifest, and result-distribution contract.
- Produces: copyable AI onboarding prompt, explicit human-action boundaries, independent success criteria, and ignored runtime distribution files.

- [x] **Step 1: Add failing assertions for usability and safety gaps**

Require the managed README and setup guide to state that local use works without external services, external setup is not zero-configuration, the AI must automate safe steps and pause on official authorization, and runtime distribution JSON files are ignored.

- [x] **Step 2: Verify RED**

Run `powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-setup.tests.ps1` and confirm failures are caused by missing onboarding text and ignore rules.

- [x] **Step 3: Implement the minimum complete user path**

Add a capability map, first-local-result path, copyable AI setup prompt, human-only Feishu/TickTick actions, identifier/secret boundary, daily prompts, and independent success criteria. Keep detailed mechanics in the setup guide.

- [x] **Step 4: Export and verify GREEN**

Run `powershell -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1`, then run the targeted setup and project-integrity tests. Expected: both PASS and managed files match.

- [x] **Step 5: Synchronize release facts**

Increment patch version, update the root README's user-distribution note, record the corrected user-package readiness fact in `PROJECT_STATUS.md`, prepend one CHANGELOG entry, and synchronize current-version references.

- [x] **Step 6: Run full verification and commit**

Run all `tests/*.tests.ps1`, version consistency, relative-link checks, and `git diff --check`. Stage only task files, preserve unrelated untracked content, and commit using the latest CHANGELOG title. Do not push.
