---
description: 从6个视角并行处理日志，生成主题化月度综合复盘报告
allowed-tools:
  - Task
  - Glob
  - Read
---

# 月度复盘命令

通过6个视角并行处理日志，综合为主题化最终报告。

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

### 4. 并行启动6个视角子代理

使用 Task 工具，`subagent_type: monthly-processor`，**在一条消息中启动全部6个**（并行执行）：

```
1. "Process YYYY-MM as therapist"
2. "Process YYYY-MM as coach"
3. "Process YYYY-MM as strengths"
4. "Process YYYY-MM as values-meaning"
5. "Process YYYY-MM as relationships"
6. "Process YYYY-MM as chronicle"
```

**关键**：在一条消息中用6个独立的 Task 工具调用启动全部6个，最大化并行度。

### 5. 等待所有视角完成

全部6个子代理必须完成才能继续。

### 6. 启动综合子代理

使用 Task 工具，`subagent_type: monthly-synthesis`：

```
"Synthesize YYYY-MM"
```

### 7. 报告完成

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
