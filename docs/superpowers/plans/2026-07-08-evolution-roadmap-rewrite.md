---
created: 2026-07-08
last_updated: 2026-07-08
status: 进行中
type: 实施计划
---

# Evolution Roadmap Rewrite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 `docs/specs/evolution-roadmap.md` 改写为兼具外部展示与内部决策的双层路线图，并同步版本与状态文档。

**Architecture:** 先重写路线图主文档的结构与论证顺序，再同步 `VERSION`、`PROJECT_STATUS.md` 与 `CHANGELOG.md`，确保路线判断、项目状态和版本记录保持一致。整体改写遵循“先验证闭环，再扩形态”的第一性原理，不引入未被现状支撑的新承诺。

**Tech Stack:** Markdown, YAML frontmatter, SemVer, PowerShell 验证命令

## Global Constraints

- 所有 Markdown 文件使用 YAML frontmatter。
- 中文内容文件用中文；配置字段和文件名用英文。
- 路线图文档的第一优先级受众是潜在协作者 / 面试官。
- 文档必须兼顾外部展示与内部决策，但主结论需先于路径细节。
- 本轮只做文档改写与版本同步，不扩展为产品实现计划。

---

### Task 1: 重写路线图主文档

**Files:**
- Modify: `docs/specs/evolution-roadmap.md`

**Interfaces:**
- Consumes: `docs/first-principles.md`, `PROJECT_STATUS.md`, `docs/superpowers/specs/2026-07-08-evolution-roadmap-design.md`
- Produces: 一份双层结构的路线图文档，包含战略摘要、当前判断、升级门槛、近 12 周动作、A/B/C 附录路径

- [ ] **Step 1: 读取并整理当前事实**

确认以下事实将作为文档输入：

```text
- 当前版本来自 VERSION
- 当前项目形态与模块状态来自 PROJECT_STATUS.md
- 路线图结构与受众来自 2026-07-08-evolution-roadmap-design.md
```

- [ ] **Step 2: 重写文档骨架**

将旧文档骨架改为：

```markdown
# 产品进化路线图

## 战略摘要
## 当前基点
## 当前判断：为什么现在优先路径 A
## 升级门槛：何时进入 B，何时再评估 C
## 近 12 周动作
## 附录：路径 A / B / C 展开
## 不推荐的形态
## 关键决策记录
## 当前状态
```

- [ ] **Step 3: 用最新事实替换旧数据和旧判断**

至少同步以下内容：

```markdown
- 当前版本更新为根目录 VERSION 的实际值
- 数据改为当前日志、日反馈、月报、已验证行为改变的最新数值
- 将“先验证闭环，再扩形态”写成显式结论
- 将 B、C 写成有前提条件的后续选项，而不是平行主路线
```

- [ ] **Step 4: 强化展示与决策双重可读性**

确保文案满足：

```markdown
- 开头 1 分钟可读懂主结论
- 中段能看见升级门槛和取舍纪律
- 后段保留 A/B/C 的展开说明，供深入阅读
```

- [ ] **Step 5: 人工检查 Markdown 结构**

检查：

```text
- frontmatter 完整
- 标题层级连续
- 内链 ../first-principles.md 可用
- 没有过时版本号和旧阶段结论残留
```

### Task 2: 同步版本与项目状态

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`

**Interfaces:**
- Consumes: `docs/specs/evolution-roadmap.md` 的新判断
- Produces: 新补丁版本号，以及与路线图一致的项目状态记录

- [ ] **Step 1: 递增补丁版本**

按语义化版本执行：

```text
如果当前 VERSION 是 1.3.24，则更新为 1.3.25
```

- [ ] **Step 2: 同步 PROJECT_STATUS 的事实项**

仅更新受本次影响的事实，例如：

```markdown
- **当前版本**
- 待办事项中对“未来优化方向”的表达
- 关键决策记录中新增一次路线图改写决策
```

- [ ] **Step 3: 校验版本一致性**

核对：

```text
VERSION == PROJECT_STATUS.md 的 **当前版本**
```

### Task 3: 追加变更记录并做只读验证

**Files:**
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: Task 1 和 Task 2 的最终改动
- Produces: 一条符合仓库格式的 `[文档]` 或 `[修复]` 记录

- [ ] **Step 1: 在 CHANGELOG 顶部追加记录**

记录格式必须为：

```markdown
## [YYYY-MM-DD HH:MM] [文档] 改动简述 (v旧 → v新)

- **受影响文件**: 文件路径列表
- **改动摘要**: 简要描述做了什么
```

- [ ] **Step 2: 运行只读验证命令**

运行以下命令并检查结果：

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Get-Content -Raw -Encoding utf8 'VERSION'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Select-String -Path 'PROJECT_STATUS.md' -Pattern '\*\*当前版本\*\*'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Select-String -Path 'docs/specs/evolution-roadmap.md' -Pattern '战略摘要|升级门槛|近 12 周动作'
```

Expected:

```text
- VERSION 输出新版本号
- PROJECT_STATUS.md 命中新版本号行
- evolution-roadmap.md 命中新结构标题
```

- [ ] **Step 3: 汇总验证结果**

最终汇报应说明：

```text
- 路线图已按双层结构改写
- 版本与状态文件已同步
- 已完成的验证命令及其结果
```

## Self-Review

1. Spec coverage: 已覆盖设计文档中的目标受众、双层结构、升级门槛、近 12 周动作和同步文件要求。
2. Placeholder scan: 无 TBD、TODO、“稍后实现”类占位表述。
3. Type consistency: 本计划为文档任务，无函数签名依赖；文件路径前后一致。
