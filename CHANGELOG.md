---
created: 2026-07-05
last_updated: 2026-07-08
---

# CHANGELOG - 改动记录

> 发布视角。这里只保留对用户或协作者重要的变化；详细过程记录已归档到 [docs/archive/changelog-detailed-2026-07-08.md](docs/archive/changelog-detailed-2026-07-08.md)。

## [2026-07-08 22:59] [重构] 复盘类命令默认切换到运行快路径 (v1.5.11 -> v1.5.12)

- **受影响文件**: `.claude/shared/prompt-rules.md`, `.claude/commands/daily-review.md`, `.claude/commands/weekly-review.md`, `.claude/commands/monthly-review.md`, `.claude/commands/life-design.md`, `.claude/skills/log.md`, `.claude/agents/daily-analyzer.md`, `.claude/agents/weekly-synthesis.md`, `.claude/agents/monthly-synthesis.md`, `.claude/agents/life-design-synthesis.md`, `.claude/agents/monthly-processor.md`, `.claude/workflows/weekly-review.js`, `.claude/workflows/monthly-review.js`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 为日反馈、周报、月报与 life-design 增加统一运行快路径：单日反馈默认优先复用已有结果；周/月/life-design 默认先消费日反馈、验证沉淀、方向锚点与视角证据包，只有证据冲突或引用缺失时才扩大到原始日志；同时修正周报复用 `monthly-processor` 时的周度输入边界。

## [2026-07-08 21:58] [重构] 拆分运行契约，降低非必要上下文读取 (v1.5.10 -> v1.5.11)

- **受影响文件**: `.claude/shared/contracts/*.md`, `.claude/shared/prompt-rules.md`, `.claude/agents/daily-analyzer.md`, `.claude/agents/weekly-synthesis.md`, `.claude/agents/monthly-synthesis.md`, `.claude/agents/project-synthesis.md`, `.claude/commands/daily-review.md`, `.claude/commands/weekly-review.md`, `.claude/skills/log.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将日反馈、复盘综合、证据验证拆成按任务读取的运行契约，避免高频日反馈读取完整通用分析标准，并修正周报旧结构描述；保留日反馈单洞察、复盘六问、方向锚点检查和验证沉淀等质量要求。

## [2026-07-08 21:39] [文档] 收敛模型推荐为用户提醒版 (v1.5.9 -> v1.5.10)

- **受影响文件**: `README.md`, `docs/model-selection.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将模型说明改写为更短的用户提醒版本，保留 Claude、GPT、DeepSeek 的明确推荐，同时补充 Kimi、GLM、Gemini 等其他模型的接入建议，降低阅读负担。

## [2026-07-08 21:28] [文档] 补充模型差异与功能调用建议 (v1.5.8 -> v1.5.9)

- **受影响文件**: `README.md`, `docs/model-selection.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 新增“不同模型调用本项目 skill 的差别”与“各功能更适合什么模型”的公开说明，给出日分析、周/月/年复盘、项目复盘与 life-design 的推荐模型和实际调用策略，降低首次选型和后续对比成本。

## [2026-07-08 21:15] [修复] 收紧日反馈契约，减少重复解释 (v1.5.7 -> v1.5.8)

- **受影响文件**: `.claude/agents/daily-analyzer.md`, `.claude/shared/prompt-rules.md`, `.claude/commands/daily-review.md`, `.claude/skills/log.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将单日日反馈默认收紧为“一个核心洞察 + 可选一句模式连接 + 一个原子动作”，同步把常规字数上限从 320 字降到 260 字，并明确禁止跨段重复解释，降低阅读摩擦，优先保障次日验证闭环。

## [2026-07-08 20:10] [文档] 收紧治理文档职责并切换 CHANGELOG 视角 (v1.5.6 -> v1.5.7)

- **受影响文件**: `CHANGELOG.md`, `PROJECT_STATUS.md`, `README.md`, `AGENTS.md`, `CLAUDE.md`, `docs/archive/README.md`, `VERSION`
- **改动摘要**: 将根目录 CHANGELOG 改为发布视角，只保留对用户或协作者重要的变化；同步收紧 README、PROJECT_STATUS 与 AGENTS/CLAUDE 的职责边界；把 frontmatter 规则真收口为“核心治理文档必须有 YAML frontmatter”。

## [2026-07-08 17:20] [修复] Stop hook 默认切换为 PowerShell 原生命令 (v1.5.5 -> v1.5.6)

- **受影响文件**: `.claude/settings.json`, `.claude/shared/prompt-rules.md`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 基于当前 Windows 环境验证结果，停止依赖 `bash -c` 作为默认 Stop hook，实现改为 PowerShell 原生命令，降低 WSL launcher 兼容性风险。

## [2026-07-08 16:55] [重构] 收紧运行契约与目录边界 (v1.5.4 -> v1.5.5)

- **受影响文件**: `.claude/shared/runtime-contracts.js`, `.claude/workflows/*.js`, `.claude/shared/paths.md`, `.claude/shared/prompt-rules.md`, `.claude/shared/banned-phrases.json`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 新增运行时共享契约，减少 workflow 与 skill 中对路径模板和禁用词规则的重复维护；同步收紧 `.claude/` 与 `docs/` 的边界。

## [2026-07-08 15:45] [修复] 日反馈升级为验证闭环入口 (v1.5.1 -> v1.5.2)

- **受影响文件**: `.claude/agents/daily-analyzer.md`, `.claude/commands/daily-review.md`, `.claude/skills/log.md`, `.claude/shared/paths.md`, `.claude/agents/weekly-synthesis.md`, `.claude/agents/monthly-synthesis.md`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: `/daily-review` 与日志粘贴入口开始检查上一条行动并沉淀到 `verified-patterns.md`；周报和月报优先消费验证结果，减少“只产生新建议、不追踪改变”的漂移。

## [2026-07-08 14:30] [功能] 新增人生设计低频校准链路 (v1.3.27 -> v1.4.0)

- **受影响文件**: `.claude/commands/life-design.md`, `.claude/agents/life-design-synthesis.md`, `.claude/commands/review.md`, `.claude/agents/monthly-synthesis.md`, `.claude/agents/yearly-synthesis.md`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 新增 `/life-design` 与 `life-design-synthesis`，把人生设计从一次性 prompt 收敛为证据优先、低频调用、可验证实验的长期方向校准入口。

## [2026-07-08 14:10] [功能] 项目复盘正式并入统一复盘体系 (v1.3.26 -> v1.3.27)

- **受影响文件**: `.claude/commands/project-review.md`, `.claude/workflows/project-review.js`, `.claude/agents/project-synthesis.md`, `.claude/shared/paths.md`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 新增 `/project-review` 与项目复盘专用综合链路，使周、月、项目三类复盘统一进入“复盘六问”协议。

## [2026-07-08 12:13] [重构] 统一周报与月报输出骨架 (v1.3.25 -> v1.3.26)

- **受影响文件**: `.claude/agents/monthly-synthesis.md`, `.claude/agents/weekly-synthesis.md`, `docs/methodology-review.md`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 周报和月报统一切换为“复盘六问一级标题 + 内层综合分析”的输出协议，降低不同复盘形态之间的认知切换成本。
