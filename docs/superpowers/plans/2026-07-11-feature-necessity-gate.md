# 新功能必要性闸门 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有开发治理规范中加入一个先于 spec、plan 和代码的新功能必要性闸门，不增加运行时组件。

**Architecture:** `AGENTS.md` / `CLAUDE.md` 继续作为唯一开发规范，两份文件逐字同步；新规则直接插入现有“工作流控制”，由所有开发任务自然消费。发布层只同步版本、状态、CHANGELOG 和 README 徽章，不修改 `.claude/` 运行链路或用户版。

**Tech Stack:** 中文 Markdown、YAML frontmatter、PowerShell 验证、Git。

## Global Constraints

- 只覆盖新增 command、agent、workflow、skill、hook、配置行为、报告形态和用户入口。
- bug、安全、兼容性、测试补齐、文档纠错和删除冗余不受闸门阻挡。
- 四项必要性标准必须同时成立；任一项失败时首次请求停止实施。
- 用户阅读并明确复述风险后再次坚持，才允许继续。
- 不新增 hook、agent、skill、runtime contract 或测试框架。
- `AGENTS.md` 与 `CLAUDE.md` 必须逐字同步。
- 版本从 `1.5.22` 递增到 `1.5.23`；README 只改版本徽章。

---

### Task 1: 在唯一开发规范中加入必要性闸门

**Files:**
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`

**Interfaces:**
- Consumes: 新增能力开发请求
- Produces: 在 Spec-Before-Code 之前执行的“必要性结论 -> 继续或劝阻”治理流程

- [ ] **Step 1: 运行缺失规则检查并确认红灯**

Run:

```powershell
$required = @('### 新功能必要性闸门','当前、具体的问题证据','明确复述风险并再次要求继续')
$content = Get-Content -LiteralPath AGENTS.md -Raw -Encoding UTF8
$missing = @($required | Where-Object { $content -notmatch [regex]::Escape($_) })
if ($missing.Count -gt 0) { Write-Host "FAIL missing gate rules: $($missing -join ', ')"; exit 1 }
Write-Host 'PASS feature necessity gate exists'
```

Expected: exit 1，输出三项缺失规则。

- [ ] **Step 2: 在 AGENTS.md 的工作流控制中加入完整规则**

在 `## 六、工作流控制` 之后、`### Superpowers 集成` 之前插入：

```markdown
### 新功能必要性闸门

新增 command、agent、workflow、skill、hook、配置行为、报告形态或用户入口时，必须在 spec、plan 和代码之前先判断是否值得做。用户说“直接改”“不用规划”或“立即实现”不能跳过本闸门。

只有以下四项同时成立，才进入后续开发流程：

1. 有当前、具体的问题证据，不是“未来可能需要”。
2. 直接服务项目核心目标或明确的面试叙事目标。
3. 现有能力、流程调整或删除复杂度无法更简单地解决。
4. 实现后能立即验证是否解决了问题。

任一项不成立时：

1. 停止实施，不创建 spec、plan 或代码。
2. 说明缺失的证据、继续开发的机会成本和更简单的替代方案。
3. 明确劝阻用户现在不要新增该功能。
4. 只有用户读完理由、明确复述风险并再次要求继续，才允许覆盖本次劝阻并进入现有开发流程。

本闸门不阻挡 bug 修复、安全修复、兼容性修复、测试补齐、文档纠错和删除冗余。任务同时包含维护与新增能力时，只拦截新增部分，不阻塞可独立完成的维护部分。
```

- [ ] **Step 3: 将 AGENTS.md 完整复制为 CLAUDE.md**

使用 UTF-8 读取 `AGENTS.md` 并以相同字节内容覆盖 `CLAUDE.md`，不得手工维护第二套措辞。执行后以 SHA-256 验证：

```powershell
$agents = (Get-FileHash -LiteralPath AGENTS.md -Algorithm SHA256).Hash
$claude = (Get-FileHash -LiteralPath CLAUDE.md -Algorithm SHA256).Hash
if ($agents -ne $claude) { throw 'AGENTS.md and CLAUDE.md drifted' }
```

- [ ] **Step 4: 运行治理规则检查并确认绿灯**

Run:

```powershell
$required = @(
  '### 新功能必要性闸门',
  '当前、具体的问题证据',
  '项目核心目标或明确的面试叙事目标',
  '删除复杂度无法更简单地解决',
  '实现后能立即验证',
  '停止实施，不创建 spec、plan 或代码',
  '明确复述风险并再次要求继续',
  'bug 修复、安全修复、兼容性修复、测试补齐、文档纠错和删除冗余'
)
$agentsContent = Get-Content -LiteralPath AGENTS.md -Raw -Encoding UTF8
$missing = @($required | Where-Object { $agentsContent -notmatch [regex]::Escape($_) })
if ($missing.Count -gt 0) { throw "Missing gate rules: $($missing -join ', ')" }
if ((Get-FileHash AGENTS.md).Hash -ne (Get-FileHash CLAUDE.md).Hash) { throw 'Governance files differ' }
Write-Host 'PASS feature necessity gate contract'
```

Expected: `PASS feature necessity gate contract`，exit 0。

---

### Task 2: 同步发布状态并完成验证

**Files:**
- Modify: `VERSION`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/superpowers/specs/2026-07-11-feature-necessity-gate-design.md`
- Create: `docs/superpowers/plans/2026-07-11-feature-necessity-gate.md`

**Interfaces:**
- Consumes: Task 1 已落地的治理规则
- Produces: v1.5.23 发布事实、关键决策和可追踪变更记录

- [ ] **Step 1: 更新版本与 README 徽章**

将 `VERSION` 从：

```text
1.5.22
```

改为：

```text
1.5.23
```

将 README 徽章中的 `版本-v1.5.22-green` 改为 `版本-v1.5.23-green`，不修改 README 其他内容。

- [ ] **Step 2: 更新 PROJECT_STATUS 当前事实**

将 frontmatter `last_updated` 改为 `2026-07-11`，当前版本改为 `1.5.23`。在“关键决策记录”表格顶部新增：

```markdown
| 2026-07-11 | 新增能力必须先通过四项必要性闸门 | 最近一次推测性功能经历完整回退，说明仅有开发前提醒不足；今后缺少当前证据、核心目标、最简方案或即时验证路径时先停止并劝阻 |
```

不新增进度模块或待办，因为这是长期治理规则，不是独立产品能力。

- [ ] **Step 3: 在 CHANGELOG 顶部追加发布记录**

将 frontmatter `last_updated` 改为 `2026-07-11`，在标题说明之后新增：

```markdown
## [2026-07-11] [配置] 新增功能必要性闸门 (v1.5.22 -> v1.5.23)

- **受影响文件**: `AGENTS.md`, `CLAUDE.md`, `PROJECT_STATUS.md`, `README.md`, `VERSION`, `docs/superpowers/specs/2026-07-11-feature-necessity-gate-design.md`, `docs/superpowers/plans/2026-07-11-feature-necessity-gate.md`
- **改动摘要**: 新增能力在进入 spec、plan 和代码前必须先通过当前问题证据、核心目标、最简方案和即时验证四项判断；任一项不成立时先停止实施、说明机会成本并劝阻，用户知情后再次坚持才允许继续。规则直接收敛在现有治理规范中，不新增 hook、agent、skill 或运行时契约。
```

- [ ] **Step 4: 运行完整同步验证**

Run:

```powershell
$version = (Get-Content -LiteralPath VERSION -Raw -Encoding UTF8).Trim()
$status = Get-Content -LiteralPath PROJECT_STATUS.md -Raw -Encoding UTF8
$readme = Get-Content -LiteralPath README.md -Raw -Encoding UTF8
if ($status -notmatch [regex]::Escape("**当前版本**：$version")) { throw 'PROJECT_STATUS version mismatch' }
if ($readme -notmatch [regex]::Escape("版本-v$version")) { throw 'README badge mismatch' }
if ((Get-FileHash AGENTS.md).Hash -ne (Get-FileHash CLAUDE.md).Hash) { throw 'Governance files differ' }
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
if ($LASTEXITCODE -ne 0) { throw 'Regression tests failed' }
git diff --check
```

Expected: 回归脚本输出 `PASS: journal input contract regression checks`，所有命令 exit 0。

- [ ] **Step 5: 审查并本地提交**

只暂存本计划列出的文件，确认 `.claude/`、overlay 和 `zhiji-user/` 没有变化。提交信息使用 CHANGELOG 最新条目：

```text
[配置] 新增功能必要性闸门 (v1.5.22 -> v1.5.23)
```

不执行 `git push`。
