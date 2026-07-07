---
description: Analyze today's or yesterday's journal for pattern reflection, blind spot detection, and one actionable next step
allowed-tools:
  - Task
  - Glob
  - Read
  - Bash
  - Write
---

# Daily Review Command (日志反馈)

对单篇日志进行轻量反馈：昨日闭环、一个盲点、可选模式连接、一个明天能试的动作。不打分，不展开长报告。

## 输入

日期来自：`$ARGUMENTS`

**默认**：未提供参数时，分析昨天的日志。

**支持格式**：
- `YYYY-MM-DD`（如 `2026-07-05`）
- `today` / `今天` — 分析今天
- `yesterday` / `昨天` — 分析昨天

## 执行步骤

### 1. 确定目标日期

解析参数为 `YYYY-MM-DD`。无参数时使用昨天日期。

### 2. 确认日志存在

读取 `.claude/shared/paths.md`，按其中的日志路径约定查找目标日志：
- 独立日记文件
- 包含目标日期标题的合并月日志

找不到日志时，输出错误并停止，不生成反馈。

### 3. 启动反馈

使用 Task 工具调用 `subagent_type: daily-analyzer`：
```
"Analyze YYYY-MM-DD"
```


返回内容必须符合 `.claude/shared/prompt-rules.md` 的「日反馈输出契约」：可选昨日闭环 + 盲点反射 + 可选模式连接 + 一个原子行动和预测 + `💊` 追踪行。不得包含 D0-D6 自检文本。

### 4. 保存并展示反馈

1. **写入文件**：保存到 `paths.md` 中的每日反馈路径：`复盘/每日反馈/YYYY-MM-DD.md`
   - 先用 Bash `mkdir -p 复盘/每日反馈` 确保目录存在
   - 用 Write 写入文件（内容原样保存，不添加额外说明或自检行）
2. **展示给用户**：将同一份反馈文本展示在对话中

这样下一次日反馈可以读取上一条 `⚡ 明天试试` 的行动和预测，形成昨日闭环。


## 错误处理

- 无日志：`没有找到 [date] 的日志。先写/导入这天的日志，再运行 /daily-review。`
- 分析失败：用中文说明失败原因，不生成空反馈文件。
