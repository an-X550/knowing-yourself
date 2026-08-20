# WorkBuddy 飞书运行入口 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为飞书智能体提供唯一、受限且可验证的 WorkBuddy 本地运行入口，使其准确调用知己现有能力而不复制业务模板。

**Architecture:** 新增 Markdown 入口契约，按消息意图引用现有 `.claude/` 命令、agent 和共享契约，并逐项限定读取、写入、确认与“仅本地”规则。飞书固定提示词只定位项目和入口契约。PowerShell 回归测试读取这两份 Markdown，断言关键边界和引用。

**Tech Stack:** Markdown 运行契约、PowerShell 5.1 静态回归测试、Git。

## Global Constraints

- `.claude/` 是唯一运行真相；不得复制日反馈、周报或月报模板。
- 所有运行结果默认仅本地，禁止入口触发飞书文档或滴答分发。
- 日记只经 `log.md` 持久化，不能直接以 `daily-analyzer` 替代入口。
- `core-profile.md`、`current.md` 永不在飞书入口白名单中；主题首次讨论零写入，确认后才可沉淀。
- 不将开发、Git、配置、部署或任意 shell 执行暴露给飞书消息。

---

### Task 1: 建立会先失败的入口契约回归测试

**Files:**
- Create: `tests/workbuddy-feishu-entry-contract.tests.ps1`
- Read: `.claude/shared/paths.md`、`.claude/shared/contracts/codex-natural-language-routing.md`

**Interfaces:**
- Consumes: 入口契约和固定提示词。
- Produces: `PASS: WorkBuddy Feishu runtime entry contract checks` 或逐项失败列表。

- [ ] **Step 1: 写失败测试**

用 `Test-Path`、`Get-Content -Raw` 和 `Select-String` 断言入口引用 `log.md`、`daily-analyzer.md`、`仅本地`、`core-profile.md`、`确认沉淀`，且不含 `📋 M月D日 日志反馈` 模板；断言提示词引用入口、禁止自行分析和开发类动作。

- [ ] **Step 2: 运行测试确认失败**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\workbuddy-feishu-entry-contract.tests.ps1`

Expected: FAIL，原因是入口契约与提示词尚不存在。

### Task 2: 实现唯一的 WorkBuddy 飞书运行入口契约

**Files:**
- Create: `.claude/workflows/workbuddy-feishu-entry.md`
- Test: `tests/workbuddy-feishu-entry-contract.tests.ps1`

**Interfaces:**
- Consumes: 飞书原始消息及既有 `paths.md`、`log.md`、自然语言复盘路由和主题思考契约。
- Produces: 一个经路由的既有运行请求、已复读的本地结果或一个澄清问题。

- [ ] **Step 1: 写最小入口契约**

声明专用飞书智能体只处理个人运行请求；先读取 `paths.md`；按日记默认、周、月、项目、主题首次、确认沉淀、复盘时机和显式年度/人生设计/日志质量映射到存在的权威文件；每项列明允许写入和禁止写入；所有请求附带“仅本地”；含糊意图只问一题；结果写入后复读验证。

- [ ] **Step 2: 明确慢变量与主题确认门**

入口必须写明：不得直接写入 `context.core_profile` 或 `context.current`；周/月/项目复盘只提出拟议变更及证据，等待明确确认；主题首次讨论禁止写入，只有 `确认沉淀：<主题>` 才读取持久化契约。

- [ ] **Step 3: 运行测试确认通过**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\workbuddy-feishu-entry-contract.tests.ps1`

Expected: `PASS: WorkBuddy Feishu runtime entry contract checks`。

### Task 3: 提供飞书智能体固定提示词

**Files:**
- Create: `docs/workbuddy-feishu-agent-prompt.md`
- Modify: `tests/workbuddy-feishu-entry-contract.tests.ps1`

**Interfaces:**
- Consumes: 用户在飞书智能体中配置的一段持久系统提示词。
- Produces: 每个请求均以项目根目录和入口契约为起点，而非由飞书智能体自行分析或写文件。

- [ ] **Step 1: 写可复制的固定提示词**

给出单段代码块，要求智能体进入用户配置的本机项目根目录，读取 `.claude/workflows/workbuddy-feishu-entry.md` 并原样执行；禁止自行替代模板、猜测写入成功、处理开发或系统命令。

- [ ] **Step 2: 扩展测试并验证通过**

断言提示词引用入口契约、禁止自行分析与开发类动作；重跑同一测试。

### Task 4: 同步产品事实、完整验证与本地提交

**Files:**
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`
- Test: `tests/workbuddy-feishu-entry-contract.tests.ps1`、`tests/local-feishu-daily-feedback-entry.tests.ps1`

- [ ] **Step 1: 更新事实**

README 链接固定提示词说明；项目状态登记 WorkBuddy 飞书入口已实现、待一次真实人工验收；版本 `1.27.3` 升至 `1.27.4`；CHANGELOG 顶部追加 `[配置]` 记录。

- [ ] **Step 2: 执行完整验证**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\workbuddy-feishu-entry-contract.tests.ps1`; `powershell -NoProfile -ExecutionPolicy Bypass -File tests\local-feishu-daily-feedback-entry.tests.ps1`; `git diff --check`.

Expected: 两项测试均 PASS，`git diff --check` 无输出。

- [ ] **Step 3: 仅暂存本任务文件并提交**

暂存入口契约、提示词、测试、设计、计划与四份同步文件；提交信息为 `[配置] 新增 WorkBuddy 飞书运行入口契约`。

## 自审

- 规格中的三项交付物分别由任务 2、3 和 1 实现，项目事实由任务 4 同步。
- 所有写入规则、主题确认门、仅本地和模板不复制均有测试断言。
- 没有占位符、未定义接口或额外依赖；契约只引用现有文件。
