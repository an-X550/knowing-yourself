---
type: runtime_contract
purpose: 开发态本地 skill 路由契约，限定开发辅助能力与用户运行时能力的边界
last_updated: 2026-07-09
---

# 开发态本地 Skill 路由契约

## 适用范围

本契约只适用于当前仓库的开发治理任务，例如：

- 讨论 skill / command / workflow / hook / settings 的设计
- 讨论分发策略、路由机制、开发规范或需求澄清方式
- 压力测试方案、拷问真实需求、挑战当前假设

它**不**适用于普通用户的日志分析、复盘、人生设计或报告生成请求。

## developer_mode 判定

满足以下任一条件即可进入 `developer_mode`：

1. 用户显式点名 `grill-me`
2. 用户明确说明“作为开发”“开发态”“优化项目”“分发策略”“skill 调用”“hook / settings 路由”等项目内部议题
3. 当前讨论对象同时命中：
   - 项目内部能力词：`skill`、`command`、`workflow`、`hook`、`settings`、`分发`、`路由`
   - 压力测试词：`第一性原理`、`真正的需求`、`压力测试`、`拷问`、`挑战假设`、`不要顺着我说`、`验证`

## grill-me 触发规则

### 显式触发

如果用户明确提到 `grill-me`，必须：

1. 读取 `.claude/skills/grill-me/SKILL.md`
2. 说明“正在按本地 skill grill-me 的协议进行需求 / 方案压力测试”
3. 按 skill 要求一次只问一个问题

### 隐式触发

如果用户没有点名 `grill-me`，但当前已进入 `developer_mode` 且目标是做需求澄清、方案拷问或决策树压力测试，则应主动切换到 `grill-me` 协议，并明确说明原因。

### 禁止触发

以下场景不得自动触发 `grill-me`：

- 普通日志粘贴
- `/daily-review`、`/weekly-review`、`/monthly-review`、`/project-review`、`/yearly-review`、`/life-design`
- 面向终端用户的自然语言复盘请求
- 用户明确要求“直接给结论”“不要追问”

## 用户可见说明

命中 `grill-me` 时，必须显式说明它是**开发辅助 skill**，而不是用户运行时入口。推荐表述：

```text
使用本地 skill grill-me 做开发态需求校准：这次会按逐问逐答的方式压力测试当前方案。
```

未命中时，不要向用户暴露 `grill-me` 的存在。
