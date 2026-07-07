---
type: shared_config
purpose: 跨 agent/workflow/command 的命名路径契约。所有 agent/command 需要路径时先读取此文件。
last_updated: 2026-07-07
---

# 共享路径约定

> 此文件是项目中运行时路径字符串的**单一权威来源**。任何 agent/command/workflow 需要输入、输出、上下文或报告路径时，先读取此文件，并在自身文档中引用这里的命名 key，而不是复制中文目录字符串。修改路径时优先改此文件，再同步少量用户可见说明。

## 使用方式

1. **先按 key 找路径**：agent/command 文档应写“使用 `output.daily_feedback`”，只有在给用户展示最终位置时才展开为具体路径。
2. **目录创建责任就近**：谁写文件，谁确保父目录存在；只创建自己负责的输出目录。
3. **示例不等于权威**：命令文档里的路径示例只用于用户理解；运行时以本文件的 key 为准。
4. **废弃路径只读**：`deprecated.*` 只用于识别历史材料或迁移提示，不作为新输出位置。

## 命名路径

## 输入路径（agent 运行时读取）

| Key | 路径 | 说明 |
|-----|------|------|
| `input.journal_dir` | `日志/` | 日志根目录 |
| `input.daily_journal` | `日志/YYYY-MM-DD.md` | 独立日记文件 |
| `input.monthly_journal_glob_cn` | `日志/*YYYY*M月*.md` | 合并月日志中文月份模式 |
| `input.monthly_journal_glob_iso` | `日志/*YYYY-MM*.md` | 合并月日志 ISO 月份模式 |
| `input.daily_feedback` | `复盘/每日反馈/YYYY-MM-DD.md` | 上一条每日反馈，用于昨日闭环 |
| `context.core_profile` | `关于我/core-profile.md` | 核心画像 |
| `context.current` | `关于我/current.md` | 当前状态 |
| `standards.analysis` | `docs/analysis-standards.md` | 分析质量标准 |
| `standards.review_methodology` | `docs/methodology-review.md` | 复盘方法论 |
| `perspective.definition` | `perspectives/{视角名}.md` | 视角定义 |
| `analysis.monthly_perspective` | `关于我/Analysis/{视角}/YYYY-MM-{视角}.md` | 月度视角分析中间产物 |
| `analysis.yearly_perspective` | `关于我/Analysis/{视角}/[YEAR]-{视角}.md` | 年度综合回退读取的视角分析 |

## 输出路径（agent 运行时写入）

| Key | 路径 | 创建/写入责任 |
|-----|------|----------------|
| `output.daily_feedback` | `复盘/每日反馈/YYYY-MM-DD.md` | `daily-analyzer` 的调用方（`/daily-review` 或 `log` skill） |
| `output.coach_report` | `复盘/每日反馈/coach-report-YYYY-MM-DD.md` | `/journal-coach` |
| `output.weekly_report` | `复盘/每周复盘/YYYY-Www.md` | `weekly-synthesis` |
| `output.monthly_report` | `复盘/每月复盘/YYYY-MM.md` | `monthly-synthesis` |
| `output.yearly_report` | `复盘/年度回顾/YYYY-annual-review.md` | `yearly-synthesis` |
| `output.perspective_analysis` | `关于我/Analysis/{视角}/YYYY-MM-{视角}.md` | `monthly-processor` |

## 上下文文件（用户画像）

| Key | 路径 | 缺失时处理 |
|-----|------|------------|
| `context.core_profile` | `关于我/core-profile.md` | 标注“画像缺失”，继续使用日志证据 |
| `context.current` | `关于我/current.md` | 标注“当前状态缺失”，不读取旧路径 |

## 已废弃路径

以下路径已不再使用，agent 不需要搜索这些位置：

| Key | 旧路径 | 状态 |
|-----|--------|------|
| `deprecated.focus_personal` | `关于我/focus-personal.md` | 功能已并入 coach 视角分析 |
| `deprecated.context_dir` | `07 Context/` | 已迁移至 `关于我/` |
| `deprecated.legacy_journal_dir` | `06 Agenda/Journal/` | 已迁移至 `日志/` |
| `deprecated.methodology_journal_runtime` | `docs/methodology-journal.md` | 零运行时消费者；文件保留为方法论文档，但 agent 运行时不读取 |
