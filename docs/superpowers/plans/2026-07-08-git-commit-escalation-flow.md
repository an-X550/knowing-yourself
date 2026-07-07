# Git Commit Escalation Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align the commit command, project rules, and user-facing prompts so restricted environments request escalation before Git metadata writes instead of failing first.

**Architecture:** Keep `/提交` as a two-stage flow: sandbox-safe validation first, then a Git write stage that is explicitly documented as requiring escalation in managed sandboxes. Update mirrored governance files and the Stop reminder so the system consistently describes that behavior across command docs, project rules, and README.

**Tech Stack:** Markdown command/rule documents, JSON hook configuration, and Git-based project metadata files.

## Global Constraints

- Do not change the command name `/提交`.
- Do not change push behavior: local commit only, user still runs `git push` manually.
- Keep `AGENTS.md` and `CLAUDE.md` in sync.
- Keep all user-facing content in Simplified Chinese.
- Bump patch version only.

---

### Task 1: Redefine `/提交` as a Two-Stage Flow

**Files:**
- Modify: `.claude/commands/commit.md`

**Interfaces:**
- Consumes: Existing `/提交` flow, CHANGELOG-derived commit message rules, and sandbox escalation constraints from the current environment.
- Produces: A command definition that treats Git metadata writes as an escalation boundary in restricted environments.

- [ ] **Step 1:** Update the command overview to state that validation runs first and Git writes may require one escalation approval in restricted environments.
- [ ] **Step 2:** Rewrite the Git execution step so it explicitly requests escalation before `git add` / `git commit` when the environment restricts `.git` writes.
- [ ] **Step 3:** Expand error handling so `.git/index.lock` permission-denied cases are described as environment write restrictions, not repository corruption.

### Task 2: Sync Governance and User Prompts

**Files:**
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Modify: `.claude/settings.json`
- Modify: `README.md`

**Interfaces:**
- Consumes: The updated `/提交` semantics from Task 1.
- Produces: Consistent wording across internal rules, hook reminders, and public command documentation.

- [ ] **Step 1:** Update `AGENTS.md` and `CLAUDE.md` so “自动提交” becomes “自动准备并发起提交流程；受限环境下 Git 写入可能等待提权批准”.
- [ ] **Step 2:** Adjust the Stop hook reminder text in `.claude/settings.json` to mention that local commit may be waiting for escalation approval.
- [ ] **Step 3:** Update the README version badge and `/提交` description so external docs match the new flow.

### Task 3: Release Metadata and Verification

**Files:**
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`
- Modify: `docs/specs/git-commit-escalation-flow.md`

**Interfaces:**
- Consumes: Current version `1.3.19` and the changed command/rule wording.
- Produces: Version `1.3.20`, synchronized status records, and a completed spec file.

- [ ] **Step 1:** Update versioned project metadata and add a changelog entry describing the Git commit flow optimization.
- [ ] **Step 2:** Mark the spec complete once edits are done.
- [ ] **Step 3:** Run focused verification for version consistency, mirror sync, and updated `/提交` wording before local commit.
