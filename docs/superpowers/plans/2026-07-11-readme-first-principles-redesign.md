# README First-Principles Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the main and distributed-user READMEs so the main repository presents the complete product and maintenance model while the user package provides a complete, non-technical guide centered on action and verification.

**Architecture:** `README.md` remains the main-project product and maintainer entry point. `packaging/zhiji-user-overlay/README.md` is the only edited source for the user guide, and `scripts/export-zhiji-user.ps1` synchronizes it to `zhiji-user/README.md`. Public-document changes are released as patch version `1.5.25` with synchronized status and changelog metadata.

**Tech Stack:** Markdown, YAML frontmatter, PowerShell, Git

## Global Constraints

- Use simplified Chinese and explain product value before commands, paths, or implementation.
- Present the value loop as `发现模式 → 形成行动 → 后续验证 → 沉淀认识`.
- Explicitly distinguish behavior hypotheses from one-off intervention experiments.
- State that AI generates evidence-based hypotheses; the user retains judgment and decision authority.
- Do not claim AI can diagnose psychology, infer certainty from one journal entry, or replace professional care.
- The user README must not contain smoke testing, beta-feedback collection, export workflow, parent-repository maintenance, or maintainer-only guidance.
- Edit `packaging/zhiji-user-overlay/README.md`, then export; do not hand-edit `zhiji-user/README.md`.
- Preserve valid relative links and use UTF-8 for all Chinese Markdown.

---

### Task 1: Rewrite the main-project README

**Files:**
- Modify: `README.md`
- Reference: `docs/first-principles.md`
- Reference: `PROJECT_STATUS.md`
- Reference: `docs/superpowers/specs/2026-07-11-readme-first-principles-redesign.md`

**Interfaces:**
- Consumes: current command names, project boundaries, model guidance, and document ownership from the referenced files.
- Produces: the complete public entry point for maintainers, contributors, and product readers.

- [ ] **Step 1: Replace the opening with the product thesis**

Write an opening that includes the one-sentence positioning, the minimum success definition, and this exact loop:

```text
记录 → 发现模式 → 形成行动 → 后续验证 → 沉淀认识
```

Explain the three underlying user problems: cross-time blind spots, forgetting prior insights, and biased self-narratives. Include the atomic value formula from `docs/first-principles.md` without turning the README into a methodology essay.

- [ ] **Step 2: Add the verification model and human–AI contract**

Add a concrete example containing these five labels:

```text
观察
行为假说
干预实验
实验结果
当前结论
```

The example must show that a failed experiment does not automatically disprove a behavior hypothesis. Follow it with a table covering `AI 负责`, `用户负责`, and `AI 不负责`.

- [ ] **Step 3: Add the complete capability map**

Document every current user-facing capability and its best-use scenario:

```text
自然语言日志录入
/review
/daily-review
/journal-coach
/weekly-review
/monthly-review
/project-review
/yearly-review
/life-design
```

Explain evidence-aware degradation for short or low-evidence input, the review-six-questions structure for week/month/project reviews, and the role of verified-pattern accumulation.

- [ ] **Step 4: Restore project and maintainer navigation**

Include quick start, model guidance, the command → agent → perspective architecture, `.claude/` as runtime truth, the `packaging/zhiji-user-overlay/` → `zhiji-user/` export boundary, the feature-necessity gate, the project tree, and links to `SETUP.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `AGENTS.md`, `docs/model-selection.md`, and the user package.

- [ ] **Step 5: Check the main README against forbidden framing**

Run:

```powershell
Select-String -Path README.md -Encoding utf8 -Pattern '看穿你','替你决定','确定是因为'
```

Expected: no matches. Manually confirm the README leads with verified behavior change rather than report generation.

### Task 2: Rewrite and export the final-user README

**Files:**
- Modify: `packaging/zhiji-user-overlay/README.md`
- Generated: `zhiji-user/README.md`
- Reference: `examples/demo/sample-journal.md`
- Reference: `scripts/protect-private-data.ps1`
- Reference: `packaging/zhiji-user-overlay/scripts/protect-private-data.ps1`

**Interfaces:**
- Consumes: the same stable product thesis as Task 1, expressed without project-governance details.
- Produces: a standalone end-user guide; its exported copy must be byte-identical to the overlay source.

- [ ] **Step 1: Write the user-centered opening and prerequisites**

Explain what Zhiji helps with, what it does not promise, and the minimum prerequisites: a supported AI coding/workspace client capable of opening the folder and reading project instructions. Link installation or environment setup only if a valid user-facing document exists; otherwise give concise client-agnostic steps in the README itself.

- [ ] **Step 2: Write the shortest first-use flow**

Use this sequence:

```text
打开目录 → 写下或粘贴日志 → 用自然语言请求分析 → 读一个关键洞察 → 选择一个小实验 → 在后续日志记录结果
```

Include ready-to-copy natural-language prompts. State that templates are optional and that `日志：`, `日记：`, or `记录一下：` reliably routes free-form journals.

- [ ] **Step 3: Document all user-facing capabilities by scenario**

For each current capability, provide: when to use it, what it produces, a natural-language request, and the corresponding slash command. Cover single-day feedback, journal coaching, week/month/project/year reviews, life design, and the unified `/review` entry.

- [ ] **Step 4: Explain the verification loop with a relatable example**

Define observation, behavior hypothesis, intervention experiment, and verification status in ordinary language. Show how later journals update a hypothesis to `待验证`, `有支持证据`, `出现反例`, or `已证伪`, while a single failed action remains only an experiment result.

- [ ] **Step 5: Add the explicit human–AI agreement**

State that AI extracts evidence, flags uncertainty, proposes hypotheses, suggests small experiments, and tracks patterns. State that the user supplies honest records, decides what to adopt, records execution or non-execution, supplies counterexamples, and retains final authority. Include safety language for medical, psychological, legal, and financial decisions.

- [ ] **Step 6: Add output, privacy, evidence, and troubleshooting guidance**

Explain `日志/`, `复盘/每日反馈/`, `复盘/每周复盘/`, `复盘/每月复盘/`, `复盘/项目复盘/`, `复盘/年度回顾/`, `复盘/人生设计/`, and `关于我/`. Preserve the accurate `skip-worktree` privacy command and explain its limits. Explain what users should do when evidence is insufficient, files are not found, or a command is unnecessary.

- [ ] **Step 7: Remove developer-only content**

Run:

```powershell
Select-String -Path 'packaging/zhiji-user-overlay/README.md' -Encoding utf8 -Pattern 'smoke','冒烟','内测反馈','上级项目','导出流程','export-zhiji-user','如果你是维护者'
```

Expected: no matches.

- [ ] **Step 8: Export the user package**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

Expected: exit code `0` and output beginning with `zhiji-user export complete:`.

- [ ] **Step 9: Verify source and exported README match**

Run:

```powershell
$source = (Get-FileHash -Algorithm SHA256 'packaging/zhiji-user-overlay/README.md').Hash
$target = (Get-FileHash -Algorithm SHA256 'zhiji-user/README.md').Hash
if ($source -ne $target) { throw 'user README export drift' }
```

Expected: exit code `0` with no output.

### Task 3: Synchronize release documentation and version

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: completed README changes from Tasks 1–2.
- Produces: a consistent public release record at version `1.5.25`.

- [ ] **Step 1: Increment the patch version**

Change `VERSION` from `1.5.24` to `1.5.25`. Change `PROJECT_STATUS.md` `**当前版本**` to `1.5.25`; keep `last_updated: 2026-07-11`.

- [ ] **Step 2: Update the documentation-governance progress fact**

In `PROJECT_STATUS.md`, mark the README-focused part of governance consolidation complete without claiming unrelated archive or governance work is finished. The status text must say that the main README now serves product/maintainer navigation and the user README is a pure end-user guide.

- [ ] **Step 3: Add the release-level changelog entry**

Insert this entry at the top of the release timeline, using the actual completion time:

```markdown
## [2026-07-11 HH:MM] [文档] 以第一性原理重构主项目与用户版说明 (v1.5.24 -> v1.5.25)

- **受影响文件**: `README.md`, `packaging/zhiji-user-overlay/README.md`, `zhiji-user/README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 重新以“发现模式、形成行动、后续验证”为主线组织项目说明；主 README 补齐产品全景、行为假说与干预实验、人机角色契约和维护导航，用户版 README 则收敛为纯最终用户手册，完整说明功能、首次使用、验证闭环、隐私与常见问题，并移除测试和分发维护内容。
```

### Task 4: Verify and locally commit the release

**Files:**
- Verify: all modified Markdown and release metadata
- Test: `tests/project-integrity.tests.ps1`

**Interfaces:**
- Consumes: all deliverables from Tasks 1–3.
- Produces: verified working tree and one local release commit; pushing remains the user's responsibility.

- [ ] **Step 1: Run repository integrity checks**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: `PASS: project integrity checks`.

- [ ] **Step 2: Check Markdown relative links in the changed READMEs**

Extract inline Markdown link targets from `README.md` and `packaging/zhiji-user-overlay/README.md`, ignore `http`, `https`, anchors, and images, resolve each target against its containing file, and fail if any target does not exist. Expected: zero missing targets.

- [ ] **Step 3: Check required and forbidden concepts**

Run UTF-8 searches confirming both READMEs contain `行为假说`, `干预实验`, `验证`, `AI`, and `用户`; confirm the user README contains none of the developer-only terms listed in Task 2 Step 7. Expected: all required concepts found and no forbidden concepts found.

- [ ] **Step 4: Check version consistency and whitespace**

Run:

```powershell
$version = (Get-Content -Raw -Encoding utf8 VERSION).Trim()
$statusVersion = [regex]::Match((Get-Content -Raw -Encoding utf8 PROJECT_STATUS.md), '当前版本\*\*[：:]\s*([\d.]+)').Groups[1].Value
if ($version -ne '1.5.25' -or $statusVersion -ne $version) { throw 'version mismatch' }
git diff --check
```

Expected: exit code `0`, with no mismatch or whitespace errors.

- [ ] **Step 5: Review the final diff**

Run:

```powershell
git diff --stat
git diff -- README.md packaging/zhiji-user-overlay/README.md zhiji-user/README.md PROJECT_STATUS.md CHANGELOG.md VERSION
```

Expected: only scoped documentation, generated user README, version, status, and changelog changes; no unrelated user edits.

- [ ] **Step 6: Create the local commit**

Use the project `/提交` flow: stage the scoped files, derive the commit subject from the newest CHANGELOG entry, commit locally, and verify with `git log -1 --oneline`. Do not push.
