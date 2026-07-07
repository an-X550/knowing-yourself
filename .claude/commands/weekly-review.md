---
description: Generate a simplified monthly-style weekly review in Chinese using 3 core life perspectives.
allowed-tools:
  - Task
  - Glob
  - Read
---

# Weekly Review Command

生成中文周度认知复盘报告。复用月度的复盘六问框架，用3个核心生活视角综合分析一周日志，输出一份简化的周度复盘报告。

周志是小的月志——四周的周志分析天然累积为月志的素材基础。

## Input

Week identifier from: `$ARGUMENTS`

**默认**：不提供参数时使用上周（最后一个完整 ISO 周），直接执行不询问。

**支持的格式**：
- `YYYY-Www`（e.g., "2026-W27" → 自动计算日期范围 6/29-7/5）
- `last week` / `this week`
- `--ask` — 弹出交互确认（不指定时直接执行）

## Execution Steps

### 1. 确定目标周

解析参数得到 `YYYY-Www` 格式和对应的7天日期范围（M月D日-M月D日）。
无参数时计算上一个完整 ISO 周。

### 2. 验证日志存在

扫描7天的日志文件。至少需要3天日志。
按顺序检查以下路径：
1. `日志/YYYY-MM-DD.md`
2. 合并月志文件（如 `日志/*月日志.md`，按日期头定位）

少于3天日志时警告但仍继续。

### 3. 启动 Workflow

调用 Workflow，传递目标周：

```
Workflow({ name: "weekly-review", args: { week: "YYYY-Www" } })
```

Workflow 负责：
- 并行运行3个核心生活视角代理（实际发生的事 + 目标与时间 + 情绪与心理）
- 代理复用 `monthly-processor`，传入周标识（含日期范围）
- 运行 `weekly-synthesis` 综合引擎
- 输出 `复盘/每周复盘/YYYY-Www.md`（标题含日期范围）

### 4. 报告完成

```
周度复盘 [YYYY-Www]（M月D日-M月D日）完成！

视角：实际发生的事、目标与时间、情绪与心理（共3个）
报告：复盘/每周复盘/YYYY-Www.md（5段简化复盘 + 质量自检）
```

## 报告结构

周度报告是月度报告的简化版（7章→5段），省略认知修正（累积到月度）：

| 章 | 内容 | 深度 |
|----|------|------|
| 本周概览 | 最值得注意的发现 | 一段话 |
| ① 本周目标 vs 实际 | 目标偏差对照 | 简单对照 |
| ② 关键事件与感受 | 客观事件 + 情绪轨迹 | 2-3件事 |
| ③ 亮点与障碍 | 1-2亮点 + 1障碍（3Why） | 轻量归因 |
| ④ 自我评价偏差 | 用户说的 vs 数据显示的 | 简化交叉验证 |
| ⑤ 下周调整 | 2-3条具体行动 + 检查方式 | 可执行 |

## Error Handling

- 少于3天日志：警告但继续
- 无日志：`"No journal entries found for [week]. Cannot generate review."`
- 视角失败：标注失败视角，用剩余视角继续
- 综合失败：报告错误
- 少于2个视角成功：终止，报告错误

## Notes

- 周度固定使用3个核心生活视角，无需用户选择模式
- 报告是月志的简化版——同框架、同质量标准、更轻更快
- 4份周志报告自然累积为月志综合的素材
- 唯一输出：`复盘/每周复盘/YYYY-Www.md`
