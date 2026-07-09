# 知己

> AI 日志分析与复盘技能：用更低摩擦的方式，把日记变成可验证的行动改变。

[![Version](https://img.shields.io/badge/版本-v1.5.18-green)](VERSION)
[![License](https://img.shields.io/badge/许可证-MIT-yellow)](LICENSE)

**知己** 是一个基于 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 的中文日志分析与复盘 skill。它围绕日、周、月、项目、年与人生设计六类节奏工作，帮助用户发现模式、形成行动、继续验证。

高频命令默认优先复用已生成的反馈、验证沉淀与视角证据包，只有证据冲突或引用缺失时才扩大读取范围。

## 快速开始

1. 写日志，推荐按六步法记录：回忆事实、筛选重点、评估结果、洞察思考、行为改进、分享讨论。
2. 将日志粘贴到 Claude Code。
3. 运行命令获取反馈：

```bash
/daily-review
/weekly-review
/monthly-review
/project-review
/life-design
/review
```

没有现成日志时，可先使用 [`examples/demo/sample-journal.md`](examples/demo/sample-journal.md) 试跑；安装与初始化说明见 [`SETUP.md`](SETUP.md)。

## 主要入口

| 入口 | 用途 | 备注 |
|------|------|------|
| `/review` | 统一入口 | 自动判断更适合日、周、月、项目、年或人生设计哪类分析 |
| `/daily-review` | 单日日志即时反馈 | 最短闭环，默认优先展示已生成反馈 |
| `/weekly-review` | 周度综合复盘 | 输出遵守复盘六问协议 |
| `/monthly-review` | 月度深度复盘 | 支持 `fast` / `standard` / `full` |
| `/project-review` | 项目或版本复盘 | 项目场景专用入口 |
| `/life-design` | 低频方向校准 | 用于重大迷茫、长期冲突或方向异常 |
| `/journal-coach` | 多日趋势反馈 | 适合观察最近几天的连续模式 |

## 模型建议

- 本项目核心 agent 默认继承调用方模型，因此不同模型会直接影响输出风格与稳定性。
- `Claude`：更适合 `/monthly-review`、`/yearly-review`、`/life-design` 这类最终留档任务。
- `GPT`：更适合 `/project-review`、`/weekly-review`、`/monthly-review` 这类结构化复盘任务。
- `DeepSeek`：更适合 `/daily-review`、`/journal-coach` 或草稿版复盘这类高频任务。
- `Kimi`、`GLM`、`Gemini` 等其他模型也可以接入，建议先用同一批日志做一次对比测试，再决定是否作为默认模型。
- 完整的模型差异说明、各功能推荐与 A/B/C 对比方法见 [`docs/model-selection.md`](docs/model-selection.md)。

## 文档地图

- 使用与初始化：[`SETUP.md`](SETUP.md)
- 当前版本、进度、待办与已知问题：[`PROJECT_STATUS.md`](PROJECT_STATUS.md)
- 发布级改动记录：[`CHANGELOG.md`](CHANGELOG.md)
- 模型差异与功能调用建议：[`docs/model-selection.md`](docs/model-selection.md)
- 快路径验收与执行保险丝：[`docs/daily-review-fast-path-acceptance.md`](docs/daily-review-fast-path-acceptance.md)、[`docs/review-fast-path-acceptance.md`](docs/review-fast-path-acceptance.md)
- 当前内测行动方案：[`docs/superpowers/plans/2026-07-09-beta-pilot-plan.md`](docs/superpowers/plans/2026-07-09-beta-pilot-plan.md)
- 方法论与质量标准：[`docs/`](docs/)
- 视角说明：[`perspectives/README.md`](perspectives/README.md)
- 开发规范：[`AGENTS.md`](AGENTS.md) / [`CLAUDE.md`](CLAUDE.md)
- 开发态本地 skill 路由契约：[`.claude/shared/contracts/developer-skill-routing.md`](.claude/shared/contracts/developer-skill-routing.md)

## 项目结构

```text
.
|-- .claude/
|-- .codex/
|-- docs/
|-- perspectives/
|-- examples/
|-- .github/
|-- README.md
|-- AGENTS.md
|-- CLAUDE.md
|-- PROJECT_STATUS.md
|-- CHANGELOG.md
|-- .editorconfig
|-- SETUP.md
|-- VERSION
`-- LICENSE
```

## 边界说明

- `.claude/` 是唯一运行真相；产品逻辑只维护在这里。
- `README.md` 只保留项目入口信息；更细规则以 `AGENTS.md` / `CLAUDE.md`、`.claude/shared/` 与 `.claude/shared/contracts/` 共享契约为准。
- `PROJECT_STATUS.md` 是当前事实面板；`CHANGELOG.md` 是发布级变化历史。
- `.claude/skills/grill-me/` 是开发期需求校准工具，不属于面向用户的运行时入口。
