---
created: 2026-07-31
status: approved-design
scope: codex-natural-language-routing
---

# Codex 自然语言复盘路由设计

## 目标

让以 Codex 为日常入口的用户直接使用自然语言生成周报、月报和项目复盘，同时复用 `.claude/` 中现有的复盘质量契约、分析说明和输出路径。迁移不重写 Claude 专属工作流，也不降低证据、行动与验证质量。

## 问题证据

- 当前真实使用入口是 Codex；Claude slash command 是早期开发遗留，无法形成日常运行闭环。
- 项目质量核心已集中在 `.claude/shared/contracts/`、综合代理说明与既有输出路径；这些均为可复用 Markdown 契约。
- Claude 的 `Workflow` / `Task` 调度无法由当前 Codex 环境直接调用，因此不能把 Claude 命令作为 Codex 的运行依赖。

## 方案选择

采用 AGENTS 路由桥接：Codex 识别自然语言意图，读取并执行现有 `.claude/` 契约。产品逻辑继续以 `.claude/` 为唯一真相。

不采用：

- Codex 专用 skill / command 副本：会在 `.codex/` 产生第二份产品逻辑并造成漂移。
- 独立 Node/Python 复盘引擎：要重写多视角调度、上下文消费和报告生成，超出高性价比范围。

## 路由设计

### 自然语言意图

| 用户表达示例 | 路由类型 | 复用的既有定义 | 输出 |
|---|---|---|---|
| `生成 2026-W28 周报`、`本周复盘` | 周报 | `weekly-review.md`、`weekly-synthesis.md`、`review-synthesis.md` | `output.weekly_report` |
| `生成 2026 年 6 月月报`、`六月复盘` | 月报 | `monthly-review.md`、`monthly-synthesis.md`、`review-synthesis.md` | `output.monthly_report` |
| `对 X 做项目复盘`、`X 优化验收` | 项目复盘 | `project-review.md`、`project-synthesis.md`、`review-synthesis.md` | `output.project_report` |

不明确周期、项目主题或输入范围时，只追问一个会改变报告对象的问题；其余信息不足按既有“部分复盘 / 证据不足”规则降级。

### 执行边界

1. Codex 先读取路由契约与 `paths.md`，再按类型读取既有命令、综合代理和共享证据契约。
2. Codex 直接执行综合工作，不调用不存在的 Claude `Workflow` / `Task` 工具。
3. 不假装已并行运行视角：已有视角证据包可用时消费；缺少时按既有代理定义补充所需证据，或明确标注部分复盘。
4. 保留 YAML frontmatter、聊天摘要、复盘六问、硬质量门、质量自检异常披露，以及周报用户回应区。
5. Claude slash command 仅作为历史兼容入口；不再是 Codex 运行所需依赖。

### 运行真相与可见入口

新增路由契约置于 `.claude/shared/contracts/`，使产品逻辑仍集中于 `.claude/`。`AGENTS.md` 与 `CLAUDE.md` 只保留一段短的 Codex 路由入口，二者必须逐字一致。`.codex/` 不承载复盘提示词、路径或行为规则。

## 验收

首次迁移使用 `2026-W28`、`2026-06` 和“复盘生成质量优化”项目材料。每份 Codex 生成报告与现有真实报告按四项比较：

1. 是否产生会改变评价、取舍或行动的判断；
2. 重要判断是否可追溯到日期、原文或视角证据；
3. 是否减少不改变判断的重复与格式填充；
4. 后续行动是否可观察、可检查。

保留迁移必须满足：不降低证据可追溯性与行动可验证性；不增加默认模型调用、默认原始日志读取量、视角数或第二套产品逻辑。静态测试必须确认路由契约、AGENTS/CLAUDE 同步、输出路径与用户版共享边界。

## 不在范围

- 全面迁移或删除 Claude 兼容文件。
- 新增报告类型、视角、评分体系、自动化服务或独立执行引擎。
- 为自然语言入口增加多轮表单式澄清。
