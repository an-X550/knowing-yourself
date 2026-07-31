# Root README Audience Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将根 README 收敛为维护者与潜在贡献者入口，并将最终用户教程明确分流至 `zhiji-user/README.md`。

**Architecture:** 只修改根目录 `README.md` 的信息架构与文案；不改产品逻辑、路径、用户版或分发流程。根 README 保留定位、能力概览、维护/分发入口与文档导航，详细最终用户操作只保留在用户版 README。

**Tech Stack:** Markdown、PowerShell、Git。

## Global Constraints

- 仅修改 `README.md`；不改变命令、路径、分发边界或 `zhiji-user/README.md`。
- `.claude/` 是唯一运行真相；根 README 的首要读者是维护者与潜在贡献者。
- 所有本地 Markdown 链接必须存在，版本徽章必须与 `VERSION` 一致。
- 内容使用 UTF-8 简体中文；不新增用户入口或产品功能。

---

### Task 1: 重写根 README 的读者分流与维护者入口

**Files:**
- Modify: `README.md`
- Reference: `docs/superpowers/specs/2026-08-01-root-readme-audience-split-design.md`
- Reference: `zhiji-user/README.md`

**Interfaces:**
- Consumes: 根 README 现有版本徽章、用户版导出命令、维护文档链接。
- Produces: 一个面向维护者的根 README；最终用户可通过 `zhiji-user/README.md` 获得完整教程。

- [ ] **Step 1: 以维护者入口重组 README**

将 `README.md` 重写为以下章节顺序：

```markdown
# 知己

> 从日志中发现自己看不到的模式，把洞察变成行动，再用真实结果校准认识。

## 这是什么
## 读者与入口
## 能力概览
## 维护与分发
## 项目结构
## 文档导航
```

保留版本和许可证徽章；在“读者与入口”中明确：最终用户应从 `zhiji-user/README.md` 开始，根 README 不再承载完整使用教程。

- [ ] **Step 2: 删除重复的最终用户教程**

从根 README 移除以下长篇内容，不以同等篇幅替换：

```text
核心机制：假说、实验与验证
人机角色契约
主题思考：让观点持续演化
快速开始中的日志示例
入口选择表
模型建议
```

用一段“能力概览”替代，涵盖日志反馈、复盘、人生设计、主题思考、收藏吃灰库，并链接用户版 README 获取操作方式与边界。

- [ ] **Step 3: 保留维护和分发信息**

保留并校正以下内容：

```markdown
- `.claude/` 是唯一运行真相。
- `packaging/zhiji-user-overlay/` 保存用户分发体验的变体源。
- `zhiji-user/` 是最终用户分发包。
- 运行 `scripts/export-zhiji-user.ps1` 刷新用户版。
```

在“文档导航”保留 `PROJECT_STATUS.md`、`CHANGELOG.md`、`AGENTS.md`、`CLAUDE.md`、用户版同步流程与质量基线文档链接。

- [ ] **Step 4: 验证 Markdown 引用与版本事实**

在项目根目录运行：

```powershell
$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$readme = Get-Content -Raw -Encoding utf8 'README.md'
$version = (Get-Content -Raw -Encoding utf8 'VERSION').Trim()
if ($readme -notmatch "v$([regex]::Escape($version))") { throw 'README version badge does not match VERSION' }
$targets = [regex]::Matches($readme, '\]\(([^)#]+)(?:#[^)]+)?\)') |
  ForEach-Object { $_.Groups[1].Value } |
  Where-Object { $_ -notmatch '^(https?:|mailto:)' } |
  Select-Object -Unique
$missing = $targets | Where-Object { -not (Test-Path -LiteralPath (Join-Path (Get-Location) $_)) }
if ($missing) { throw "Missing README links: $($missing -join ', ')" }
Write-Output "README verification passed: $($targets.Count) local targets; version $version"
```

Expected: `README verification passed`，且退出码为 0。

- [ ] **Step 5: 检查变更范围并提交**

运行：

```powershell
git diff --check
git diff -- README.md
git status --short
```

Expected: 无空白错误；仅 `README.md` 为本任务的实施改动。确认后提交：

```powershell
git add README.md
git commit -m "docs: focus root README on maintainers"
```
