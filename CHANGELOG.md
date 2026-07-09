---
created: 2026-07-05
last_updated: 2026-07-09
---

# CHANGELOG - 改动记录

> 发布视角。这里只保留对用户或协作者重要的变化；详细过程记录已归档到 [docs/archive/changelog-detailed-2026-07-08.md](docs/archive/changelog-detailed-2026-07-08.md)。

## [2026-07-09 22:06] [文档] 明确主项目与用户版的使用分工 (v1.5.20 -> v1.5.21)

- **受影响文件**: `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`, `packaging/zhiji-user-overlay/README.md`, `zhiji-user/README.md`
- **改动摘要**: 明确“维护者自己的日常真实使用留在主项目，`zhiji-user/` 主要用于分发前 smoke test 与用户视角验收”的分工，减少把用户版误当成主工作台带来的边界混淆。

## [2026-07-09 21:57] [功能] 建立用户版导出与同步单一来源 (v1.5.19 -> v1.5.20)

- **受影响文件**: `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`, `docs/zhiji-user-sync-workflow.md`, `packaging/zhiji-user-manifest.json`, `packaging/zhiji-user-overlay/`, `scripts/export-zhiji-user.ps1`, `zhiji-user/`
- **改动摘要**: 为 `zhiji-user/` 建立由 `packaging/zhiji-user-overlay/`、manifest 与导出脚本组成的单点维护链路，同时补充同步流程说明、用户版 smoke check 与更完整的用户 README/示例/隐私保护脚本，避免主仓库与用户版双向手改后持续漂移。

## [2026-07-09 14:38] [功能] 新增用户版分发包目录 (v1.5.18 -> v1.5.19)

- **受影响文件**: `zhiji-user/`, `README.md`, `PROJECT_STATUS.md`, `AGENTS.md`, `CLAUDE.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 新增 `zhiji-user/` 作为面向 3-5 人小范围内测的用户版分发包，只保留运行所需的 `.claude/` 子集、必要分析文档、示例、用户版 README/SETUP 与许可证；移除提交、导入、开发态 `grill-me`、治理文档和个人数据入口，让内测用户可以直接按使用说明试跑日志分析而不接触开发仓库结构。

## [2026-07-09 13:38] [文档] 新增外部内测行动方案并收紧试用判断 (v1.5.17 -> v1.5.18)

- **受影响文件**: `docs/superpowers/plans/2026-07-09-beta-pilot-plan.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将基于第一性原理与 `grill-me` 连续追问得出的结论固化为一份可执行的 3-5 人内测行动方案，明确第一轮试用优先验证“今天日志”入口的准确性、有用性与后续验证痕迹，并同步公开文档与项目状态，避免继续把“分发形式”误当成当前主问题。

## [2026-07-09 12:32] [修复] 为中文治理文档补齐 UTF-8 开发护栏 (v1.5.16 -> v1.5.17)

- **受影响文件**: `.editorconfig`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 确认 `PROJECT_STATUS.md` 等治理文档本身没有编码损坏，根因是 Windows 终端/脚本输出链路会制造乱码假象；因此新增 `.editorconfig` 并把“中文 Markdown 必须按 UTF-8 读写”的规则写入开发规范，降低后续误判和重复修复成本。

## [2026-07-09 12:05] [修复] 固化 grill-me 的开发态路由边界 (v1.5.15 -> v1.5.16)

- **受影响文件**: `.claude/settings.json`, `.claude/shared/prompt-rules.md`, `.claude/shared/contracts/developer-skill-routing.md`, `.claude/skills/grill-me/SKILL.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将 `grill-me` 明确收敛为当前仓库的开发辅助 skill：显式点名时通过 hook 必触发，命中高置信开发语义时允许自动路由，并要求触发后说明“这是开发态需求校准”；同时补上共享契约与公开边界说明，避免该模式泄漏到面向用户的运行时入口。

## [2026-07-09 11:13] [文档] 在第一性原理提醒中加入开发前闸门 (v1.5.14 -> v1.5.15)

- **受影响文件**: `docs/first-principles.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 为开发者纪律补充“开发前闸门”提醒，把 3 分钟判断卡、生活基本盘检查、真实需求证据与开发时段封顶写入第一性原理文档，帮助在高反馈开发循环里先回到真实目的与需求验证。

## [2026-07-09 10:57] [修复] 为复盘快路径补齐验收说明与执行保险丝 (v1.5.13 -> v1.5.14)

- **受影响文件**: `.claude/shared/prompt-rules.md`, `.claude/skills/log.md`, `.claude/commands/daily-review.md`, `.claude/commands/weekly-review.md`, `.claude/commands/monthly-review.md`, `.claude/commands/life-design.md`, `docs/daily-review-fast-path-acceptance.md`, `docs/review-fast-path-acceptance.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 新增日分析与周/月/life-design 的快路径验收说明，并把“执行前检查”“偏离后回退到最小读取集合”的规则写进共享提示词和命令入口，降低优化方案已存在但实际执行时没有命中的漂移风险。

## [2026-07-09 10:36] [修复] 将 grill-me skill 迁移到运行真相目录并补齐可发现描述 (v1.5.12 -> v1.5.13)

- **受影响文件**: `.claude/skills/grill-me/SKILL.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将新增的 `grill-me` skill 从仓库根目录迁移到 `.claude/skills/` 运行真相目录，确保运行时可按既有边界加载；同时把 skill 的描述改为符合发现规范的 `Use when...` 触发式写法，降低后续检索遗漏风险。

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
