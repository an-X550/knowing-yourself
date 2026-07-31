# User README First Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让最终用户在用户版 README 首屏完成一次可验证的日反馈闭环，并将低频能力改为按需阅读。

**Architecture:** 编辑 overlay README 作为唯一分发源，运行导出脚本更新 `zhiji-user/README.md`。重构保留隐私、证据和用户决定权边界，但合并重复的首次行动、功能与安全说明。

**Tech Stack:** Markdown、PowerShell、Git。

## Global Constraints

- 不改变命令、输出目录、隐私行为、提示词契约或产品功能。
- `packaging/zhiji-user-overlay/README.md` 是源文件，`zhiji-user/README.md` 必须由导出脚本生成。
- 用户版、overlay 与根 `VERSION` 版本说明必须一致。
- 发布级文档更新须递增修订版本，并同步 `PROJECT_STATUS.md` 与 `CHANGELOG.md`。

---

### Task 1: 重构用户版说明并同步分发包

**Files:**
- Modify: `packaging/zhiji-user-overlay/README.md`
- Generated: `zhiji-user/README.md`
- Modify: `VERSION`, `PROJECT_STATUS.md`, `CHANGELOG.md`

**Interfaces:**
- Consumes: 用户版现有功能、隐私和目录事实；`scripts/export-zhiji-user.ps1`。
- Produces: 首次闭环优先的用户 README，以及同步的分发包。

- [ ] **Step 1: 将首次闭环放在首屏**

把 overlay README 重组为：定位与边界、开始前需要什么、一次可复制的日志请求、下次记录结果、日志如何写、其他能力、安全与隐私、结果目录、FAQ。首屏必须包含：

```text
分析这篇日志。请只给我一个最关键的洞察、一个可验证的小实验，并说明下次应该记录什么。
```

- [ ] **Step 2: 合并重复说明**

用一张“目的 / 自然语言 / 命令”表替代八个功能小节和命令对照表；将行为假说、AI 角色与重复 FAQ 收敛为一个“安全使用与验证”章节。年度回顾、人生设计、主题思考与收藏吃灰库只说明适用条件与一个自然语言示例。

- [ ] **Step 3: 更新版本与发布事实**

将 `VERSION` 从 `1.9.6` 递增为 `1.9.7`，同步根 README 徽章、PROJECT_STATUS 当前版本，以及 overlay 和导出用户 README 中的当前版本。向 CHANGELOG 顶部加入 `[文档]` 条目，说明首次闭环前置与重复内容收敛。

- [ ] **Step 4: 导出并验证**

运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
& .\tests\project-integrity.tests.ps1
& .\tests\distribution-boundary.tests.ps1
```

再检查：overlay 与导出 README byte-identical、两份 README 的相对链接均存在、所有版本显示为 `1.9.7`。预期全部命令退出码为 0。

- [ ] **Step 5: 提交**

运行 `git diff --check` 与 `git status --short`，确认仅包含本任务的 README、分发和发布记录；随后执行：

```powershell
git add packaging/zhiji-user-overlay/README.md zhiji-user/README.md README.md VERSION PROJECT_STATUS.md CHANGELOG.md docs/superpowers/plans/2026-08-01-user-readme-first-loop.md
git commit -m "docs: prioritize first loop in user README"
```
