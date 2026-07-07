---
description: 从选定视角并行处理日志，生成主题化月度综合复盘报告。支持 fast(3)/standard(6)/full(9) 三种模式及自定义视角
allowed-tools:
  - Task
  - Glob
  - Read
---

# 月度复盘命令

通过选定视角并行处理日志，综合为主题化最终报告。支持 fast(3核心视角)/standard(6生活视角,默认)/full(9全视角) 三种模式，也可自定义视角组合。

## 输入

月份标识来自：`$ARGUMENTS`

**默认值**：如果未提供参数，使用上一个完整月份（如当前为2月，则处理1月）。

**支持的格式**：
- `YYYY-MM`（如 "2026-01"）
- 月份名+年份（如 "2026年1月"、"Jan 2026"）
- 仅月份名表示当年（如 "1月"）

## 执行步骤

### 1. 确定目标月份

解析参数获取 `YYYY-MM` 格式。

如无参数：根据当前日期计算上一个完整月份。

### 2. 验证日志存在

使用 Glob 检查 `日志/` 目录中目标月份的日志文件（如 `日志/*YYYY*M月*.md`）。

如果未找到日志：报告错误并停止。

### 3. 创建输出目录

确保以下目录存在（用 Glob 检查，不存在则创建）：
- `关于我/Analysis/therapist/`
- `关于我/Analysis/coach/`
- `关于我/Analysis/strengths/`
- `关于我/Analysis/values-meaning/`
- `关于我/Analysis/relationships/`
- `关于我/Analysis/chronicle/`

### 4. 启动 Workflow

调用 Workflow 工具，`name: "monthly-review"`，传入月份和模式：

```
Workflow({ name: "monthly-review", args: { month: "YYYY-MM", mode: "standard|fast|full" } })
```

Workflow 负责：
- 按模式解析视角列表（fast: 3核心 / standard: 6生活 / full: 9全视角）
- 并行运行视角代理（复用 `monthly-processor`）
- 运行 `monthly-synthesis` 综合引擎
- 输出 `复盘/每月复盘/YYYY-MM.md`

**也支持自定义视角**：`args: { month: "YYYY-MM", perspectives: ["therapist", "coach"] }`

### 5. 等待 Workflow 完成

Workflow 会自动报告进度和最终结果。

### 6. 报告完成

综合完成后，报告：

```
[月份 年份]月度复盘完成！

视角分析已创建：
- 关于我/Analysis/therapist/YYYY-MM-therapist.md
- 关于我/Analysis/coach/YYYY-MM-coach.md
- 关于我/Analysis/strengths/YYYY-MM-strengths.md
- 关于我/Analysis/values-meaning/YYYY-MM-values-meaning.md
- 关于我/Analysis/relationships/YYYY-MM-relationships.md
- 关于我/Analysis/chronicle/YYYY-MM-chronicle.md

最终报告：复盘/每月复盘/YYYY-MM.md
```

## 错误处理

- 如果目标月份无日志："未找到 [月份] 的日志条目，无法生成复盘。"
- 如果某视角失败：记录失败的视角，继续处理其余视角，在最终输出中警告
- 如果综合失败：报告错误，说明视角文件仍已创建

## 备注

- 此命令编排已有代理——不直接处理日志
- monthly-processor 代理负责每个视角的分析
- monthly-synthesis 代理负责创建最终主题报告
- 所有视角分析文件均保留供将来参考
