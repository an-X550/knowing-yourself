# 知己

> 从日志中发现自己看不到的模式，把洞察变成行动，再用真实结果校准认识。

[![Version](https://img.shields.io/badge/版本-v1.9.8-green)](VERSION)
[![License](https://img.shields.io/badge/许可证-MIT-yellow)](LICENSE)

## 这是什么

知己是面向中文个人日志的 AI 复盘系统。它不以生成更多报告为目标，而是把记录、模式发现、低成本行动和后续验证收敛为一个可重复的闭环：

```text
记录 → 发现模式 → 形成行动 → 后续验证 → 沉淀认识
```

最小成功不是写出漂亮分析，而是形成一条用户自己不容易发现、并能由后续行为结果验证的洞察。

项目的运行真相是 `.claude/`：不同入口复用同一套路径、证据和输出契约，避免以多份报告掩盖没有行动或没有验证的问题。

## 读者与入口

本 README 面向维护者、潜在贡献者，以及希望理解项目边界的人。

- **首次使用或最终用户**：请从 [`zhiji-user/README.md`](zhiji-user/README.md) 开始。它包含环境准备、首次日志反馈、功能选择、隐私边界和常见问题。
- **维护者**：先阅读 [`AGENTS.md`](AGENTS.md) / [`CLAUDE.md`](CLAUDE.md)，再结合 [`PROJECT_STATUS.md`](PROJECT_STATUS.md) 确认当前事实、待验收项和已知问题。
- **产品逻辑**：只在 `.claude/` 维护；`zhiji-user/` 是从运行真相裁剪出的用户分发包，不承载主开发流程。

## 能力概览

| 能力 | 目的 | 权威使用说明 |
|------|------|--------------|
| 日志记录与日反馈 | 从当日记录中形成单个关键洞察和可验证行动 | [`zhiji-user/README.md`](zhiji-user/README.md) |
| 周、月、项目与年度复盘 | 基于沉淀证据校准更长时间尺度的趋势与选择 | [`zhiji-user/README.md`](zhiji-user/README.md) |
| 日志教练与人生设计 | 改进记录质量，或在长期方向冲突时做校准 | [`zhiji-user/README.md`](zhiji-user/README.md) |
| 主题思考与收藏吃灰库 | 经用户确认后沉淀可继续修正的认识和资料 | [`zhiji-user/README.md`](zhiji-user/README.md) |

共同边界是：AI 提供证据整理、假说与低成本实验；用户保留对自身经历、价值选择和重大决定的最终解释权。证据不足时，系统必须降低结论强度，而不是补完故事。

## 维护与分发

- `.claude/` 是唯一运行真相，包含 commands、agents、skills、workflows 与 shared 契约。
- `packaging/zhiji-user-overlay/` 保存只属于用户分发体验的变体源。
- `zhiji-user/` 是最终用户分发包；用户教程以其中的 README 为准。

维护者自己的长期真实使用默认留在主项目。刷新用户分发包时，在项目根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

导出与同步边界见 [`docs/zhiji-user-sync-workflow.md`](docs/zhiji-user-sync-workflow.md)。产品或公开文档变更前，应遵守 [`AGENTS.md`](AGENTS.md) / [`CLAUDE.md`](CLAUDE.md) 中的必要性、版本和验证规范。

## 项目结构

```text
.
|-- .claude/       # 唯一运行真相：commands、agents、skills、workflows、shared
|-- .codex/        # Codex 开发辅助配置
|-- docs/          # 方法论、说明、spec 与计划
|-- examples/      # 脱敏示例
|-- packaging/     # 用户版变体源、manifest 与同步说明
|-- perspectives/  # 分析视角定义
|-- scripts/       # 导出与维护脚本
|-- tests/         # 完整性与契约检查
|-- zhiji-user/    # 最终用户分发包
|-- README.md
|-- PROJECT_STATUS.md
|-- CHANGELOG.md
|-- AGENTS.md
|-- CLAUDE.md
|-- SETUP.md
|-- VERSION
`-- LICENSE
```

## 文档导航

- 当前版本、进度、待办和已知问题：[`PROJECT_STATUS.md`](PROJECT_STATUS.md)
- 发布级变化：[`CHANGELOG.md`](CHANGELOG.md)
- 开发与维护规范：[`AGENTS.md`](AGENTS.md) / [`CLAUDE.md`](CLAUDE.md)
- 用户版完整指南：[`zhiji-user/README.md`](zhiji-user/README.md)
- 用户版同步流程：[`docs/zhiji-user-sync-workflow.md`](docs/zhiji-user-sync-workflow.md)
- 第一性原理提醒：[`docs/first-principles.md`](docs/first-principles.md)
- 质量基线与待验收项：[`docs/quality-baseline-matrix.md`](docs/quality-baseline-matrix.md)
- 模型选择与 A/B/C 对比：[`docs/model-selection.md`](docs/model-selection.md)
- 主题思考端到端验收：[`docs/topic-thinking-acceptance.md`](docs/topic-thinking-acceptance.md)
- 视角说明：[`perspectives/README.md`](perspectives/README.md)
