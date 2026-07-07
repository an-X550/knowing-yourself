---
description: Analyze today's or yesterday's journal for pattern reflection, blind spot detection, and one actionable next step
allowed-tools:
  - Task
  - Glob
  - Read
---

# Daily Review Command (日志反馈)

对单篇日志进行轻量反馈——镜像反射、模式连接、给一个明天能试的动作。不打分。

## Input

Date from: `$ARGUMENTS`

**Default**: If no argument provided, use yesterday's date.

**Accepted formats**:
- `YYYY-MM-DD` (e.g., "2026-07-05")
- `today` / `今天` — analyze today's journal
- `yesterday` / `昨天` — analyze yesterday's journal

## Execution Steps

### 1. Determine Target Date

Parse arguments to get `YYYY-MM-DD` format.
If no arguments: use yesterday's date.

### 2. Verify Journal Exists

Check for journal file in `日志/`.

If no journal found, report error and stop.

### 3. Launch Feedback

Use the Task tool with `subagent_type: daily-analyzer`:
```
"Analyze YYYY-MM-DD"
```


This returns a concise Chinese feedback with: yesterday check + mirror reflection + pattern connection + atomic action with prediction + tracking row.

### 4. Save and Display Feedback

1. **Write to file**: Save the feedback text to `复盘/每日反馈/YYYY-MM-DD.md`
   - 先用 Bash `mkdir -p 复盘/每日反馈` 确保目录存在
   - 用 Write 写入文件（内容原样保存，包含自检行）
2. **Display in chat**: 将 feedback 文本展示给用户

This ensures every daily feedback is persisted, so the next day's analysis can read yesterday's commitment for the 昨日检查 step.


## Error Handling

- No journal file: "No journal entry found for [date]. Write your journal first!"
- Analysis failure: Report error
