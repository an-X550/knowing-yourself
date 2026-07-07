---
type: shared_config
purpose: 跨 agent/workflow/command 的路径约定。所有 agent 启动时读取此文件。
last_updated: 2026-07-07
---

# 共享路径约定

> 此文件是项目中所有路径字符串的**单一权威来源**。任何 agent/workflow/command 需要使用路径时，读取此文件而非硬编码。修改路径时只需改此文件。

## 输入路径（agent 运行时读取）

- 核心画像: `关于我/core-profile.md`
- 当前状态: `关于我/current.md`
- 分析质量标准: `docs/analysis-standards.md`
- 复盘方法论: `docs/methodology-review.md`
- 日志写法: `docs/methodology-journal.md`
- 每日反馈: `复盘/每日反馈/YYYY-MM-DD.md`
- 视角定义: `perspectives/{视角名}.md`
- 月度视角分析（中间产物）: `关于我/Analysis/{视角}/YYYY-MM-{视角}.md`
- 年度视角分析（yearly-synthesis 回退用）: `关于我/Analysis/{视角}/[YEAR]-{视角}.md`

## 输出路径（agent 运行时写入）

- 每日反馈: `复盘/每日反馈/YYYY-MM-DD.md`
- 周度报告: `复盘/每周复盘/YYYY-Www.md`
- 月度报告: `复盘/每月复盘/YYYY-MM.md`
- 年度报告: `复盘/年度回顾/YYYY-annual-review.md`
- 视角分析中间产物: `关于我/Analysis/{视角}/YYYY-MM-{视角}.md`

## 上下文文件（用户画像）

- 核心画像: `关于我/core-profile.md`
- 当前状态: `关于我/current.md`

## 已废弃路径

以下路径已不再使用，agent 不需要搜索这些位置：

- `关于我/focus-personal.md` — 功能已并入 coach 视角分析
- `07 Context/` 目录 — 已迁移至 `关于我/`
- `06 Agenda/Journal/` — 已迁移至 `日志/`
