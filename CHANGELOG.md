---
created: 2026-07-05
last_updated: 2026-07-15
---

# CHANGELOG - 改动记录

> 发布视角。这里只保留对用户或协作者重要的变化；详细过程记录已归档到 [docs/archive/changelog-detailed-2026-07-08.md](docs/archive/changelog-detailed-2026-07-08.md)。

## [2026-07-15 17:40] [功能] 支持自然语言收录收藏吃灰库 (v1.6.18 -> v1.6.19)

- **受影响文件**: `.claude/skills/collection.md`, `.claude/settings.json`, `.claude/shared/paths.md`, 用户版 overlay 与分发包, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 用户明确说“收录到收藏吃灰库/某主题”并提供可提炼内容时，系统会按固定五段式保存个人收藏；普通聊天不会触发写入，链接不可读取时会要求提供原文或摘录。

## [2026-07-15 00:00] [修复] 同步 README 版本徽章 (v1.6.17 -> v1.6.18)

- **受影响文件**: `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 修正 README 仍显示 v1.6.16 的发布信息漂移，使公开版本徽章与当前发布状态一致。

## [2026-07-15 00:00] [修复] 强化第一性原理复核与输出质量边界 (v1.6.16 -> v1.6.17)

- **受影响文件**: `.claude/shared/contracts/first-principles-analysis.md`, 日反馈/复盘/主题思考契约, `AGENTS.md`, `CLAUDE.md`, 用户版 overlay 与分发边界测试
- **改动摘要**: 用户现在可明确要求“依据第一性原理分析”来复核或压缩既有内容；系统会区分事实、假设、约束与价值取舍，给出更直接的判断或最小验证，同时保持原有命令、路径、报告结构、隐私与确认写入边界不变。

## [2026-07-15 00:00] [修复] 修正用户版“关于我”文档边界 (v1.6.15 -> v1.6.16)

- **受影响文件**: `packaging/zhiji-user-boundaries.json`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将主项目与用户版都需要保留、但用途不同的 `关于我/README.md` 明确登记为有理由的 override，恢复分发边界完整性检查，同时不改变任何运行时文件。

## [2026-07-13 00:00] [修复] 恢复周复盘用户回应入口 (v1.6.14 -> v1.6.15)

- **受影响文件**: `.claude/agents/weekly-synthesis.md`, `.claude/commands/weekly-review.md`, `packaging/zhiji-user-overlay/`, `zhiji-user/`, `docs/quality-baseline-matrix.md`, `tests/review-workflow-contract.tests.ps1`, `tests/quality-baseline.tests.ps1`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 周报现在会在质量自检后固定保留 `## 用户回应区` 空模板，承接用户补充 AI 没提到的重要内容、偏差判断和下周硬约束；同时补充静态契约检查，避免“用户回应 AI 复盘”的机制只停留在方法论文档里。

## [2026-07-12 13:27] [文档] 明确用户版双仓库提交流程 (v1.6.13 -> v1.6.14)

- **受影响文件**: `docs/zhiji-user-sync-workflow.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 在用户版同步文档中补充主仓库与 `zhiji-user/` 分发仓库的最小提交、推送和分发前检查流程，明确主项目 push 不会自动更新 GitHub 用户分发仓库，减少后续发布遗漏。

## [2026-07-12 01:01] [修复] 区分主题思考短期入口与长期行动 (v1.6.12 -> v1.6.13)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`, `packaging/zhiji-user-overlay/`, `zhiji-user/`, `tests/topic-thinking-contract.tests.ps1`, `关于我/思考/信息过载、最优解幻觉与不确定性.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 修正主题思考行动卡默认按一周反馈设计的问题；现在行动卡只保留短期动作、长期锚点、触发场景和停止线，“值得保留的行动”统一为长期动作表，帮助主题文件在非定期查看场景下更容易阅读和执行。

## [2026-07-12 00:38] [修复] 为主题思考补齐编号化排版 (v1.6.11 -> v1.6.12)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`, `packaging/zhiji-user-overlay/`, `zhiji-user/`, `tests/topic-thinking-contract.tests.ps1`, `关于我/思考/信息过载、最优解幻觉与不确定性.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将主题思考文件进一步固定为 0-6 编号阅读路径，要求行动卡优先用表格呈现，下一步优先用编号步骤呈现；修复“只有 Markdown 标题但仍不够方便阅读和执行”的问题。

## [2026-07-12 00:24] [修复] 优化主题思考阅读结构与执行入口 (v1.6.10 -> v1.6.11)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`, `packaging/zhiji-user-overlay/`, `zhiji-user/`, `tests/topic-thinking-contract.tests.ps1`, `关于我/思考/信息过载、最优解幻觉与不确定性.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将主题思考从反问式六问改为“当前行动卡 + 六个陈述式板块”，包括当前问题、当前判断、依据来源与思考校正、值得保留的行动、下一次怎么做和我的观点演化路径；执行信息前置，减少长主题文件的阅读压力，并让行动层内容更容易直接使用。

## [2026-07-11 22:37] [修复] 按实际需要展开主题思考六问 (v1.6.9 -> v1.6.10)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`, `packaging/zhiji-user-overlay/`, `zhiji-user/`, `tests/topic-thinking-contract.tests.ps1`, `关于我/思考/信息过载、最优解幻觉与不确定性.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 修复主题思考被误写为六个平均长度栏目的问题；现在各部分按证据、问题复杂度和行动需要决定篇幅，并要求“保留”给出具体对象/条件/做法、“尝试”写到用户可直接执行，避免形式整齐却无法指导行动。

## [2026-07-11 22:20] [功能] 收敛主题思考为六问行动闭环 (v1.6.8 -> v1.6.9)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`, `packaging/zhiji-user-overlay/`, `zhiji-user/`, `tests/topic-thinking-contract.tests.ps1`, `关于我/思考/信息过载、最优解幻觉与不确定性.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 主题思考改用“困扰、理解、审查、保留、尝试、演化”六个用户问题，要求事实/推断/建议区分和有依据的反例审查，并将行动收敛为单一进行中实验，帮助用户保留思考痕迹并将其转化为可验证改变。

## [2026-07-11 20:20] [文档] 同步用户版说明与项目复盘 (v1.6.7 -> v1.6.8)

- **受影响文件**: `packaging/zhiji-user-overlay/README.md`, `zhiji-user/README.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 在用户版手册中补充当前版本、已通过的自动边界检查和仍需真实素材验证的质量边界；同步更新本地“知己项目”复盘，不改变产品行为。

## [2026-07-11 20:00] [文档] 同步最新功能的验收状态 (v1.6.6 -> v1.6.7)

- **受影响文件**: `PROJECT_STATUS.md`, `docs/quality-baseline-matrix.md`, `README.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 修正质量基线矩阵中已完成的自动测试仍被列为待办的状态漂移，并在项目状态中补齐月复盘与 life-design 的真实素材验收项，为现有质量基线和主题思考验收文档补充导航入口；不改变产品行为。

## [2026-07-11 17:33] [修复] 修正分析标准维护契约并收紧分发边界 (v1.6.5 -> v1.6.6)

- **受影响文件**: `docs/analysis-standards.md`, `packaging/zhiji-user-boundaries.json`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 修正分析标准中已过期的禁用词运行常量说明，并将分析质量标准纳入用户版 shared 边界检查；本次主动停止视角 prompt 的逐字同步，避免为低收益一致性增加维护成本，不改变任何命令入口、参数、报告路径或报告结构。

## [2026-07-11 17:28] [修复] 补充历史观点新鲜度规则 (v1.6.4 -> v1.6.5)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`, `.claude/shared/contracts/evidence-and-verification.md`, `packaging/zhiji-user-overlay/.claude/shared/contracts/`, `zhiji-user/.claude/shared/contracts/`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将“最近三个月优先”收敛为运行契约：历史主题召回按当前表达、最近 90 天证据、已验证长期模式和 90 天前未复核观点排序；旧观点进入复查状态而非自动失效，长期模式则结合最近支持、反例和情境变化判断是否仍适用。

## [2026-07-11 17:19] [重构] 批量收敛等价共享文件 (v1.6.3 -> v1.6.4)

- **受影响文件**: `packaging/zhiji-user-boundaries.json`, `packaging/zhiji-user-overlay/.claude/agents/`, `packaging/zhiji-user-overlay/.claude/commands/`, `packaging/zhiji-user-overlay/.claude/workflows/`, `packaging/zhiji-user-overlay/docs/methodology-journal.md`, `packaging/zhiji-user-overlay/examples/demo/sample-journal.md`, `packaging/zhiji-user-overlay/perspectives/README.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 在质量基线和分发边界测试保护下，将忽略行尾后已等价的一批低风险文件从 `override` 收敛为 byte-identical `shared`，包括部分 agent、command、workflow、方法论文档、示例与视角索引；这降低了用户版与主项目的双维护成本，不改变任何入口、参数、报告路径或报告结构。

## [2026-07-11 17:10] [重构] 回抽纯运行辅助共享文件 (v1.6.2 -> v1.6.3)

- **受影响文件**: `packaging/zhiji-user-boundaries.json`, `packaging/zhiji-user-overlay/.claude/shared/runtime-contracts.js`, `packaging/zhiji-user-overlay/.claude/workflows/shared.js`, `zhiji-user/.claude/shared/runtime-contracts.js`, `zhiji-user/.claude/workflows/shared.js`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将主项目与用户版行为已经一致的 `runtime-contracts.js` 和 workflow `shared.js` 从有理由 override 收敛为 byte-identical shared 文件，由边界测试自动保证后续不再分叉，降低摘要解析与运行镜像的双维护成本；不改变任何命令入口、参数、报告路径或输出结构。

## [2026-07-11 16:59] [文档] 建立质量基线验收矩阵 (v1.6.1 -> v1.6.2)

- **受影响文件**: `docs/quality-baseline-matrix.md`, `tests/quality-baseline.tests.ps1`, `tests/project-integrity.tests.ps1`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将四阶段优化方案的第一阶段落成可测试质量基线，覆盖日反馈、周/月复盘、项目复盘、年度复盘、人生设计和用户版分发的关键组件边界；项目完整性检查现在会同步执行质量基线测试，确保后续回抽共享能力或删除重复提示词前，入口、路径、摘要、降级和用户版边界保持不变。

## [2026-07-11 14:08] [修复] 收敛主题思考隐私与运行契约 (v1.6.0 -> v1.6.1)

- **受影响文件**: `.claude/agents/`, `.claude/workflows/shared.js`, `packaging/zhiji-user-overlay/`, `zhiji-user/`, `tests/topic-thinking-contract.tests.ps1`, `tests/review-workflow-contract.tests.ps1`, `tests/distribution-boundary.tests.ps1`, `tests/project-integrity.tests.ps1`, `docs/topic-thinking-acceptance.md`, `docs/zhiji-user-sync-workflow.md`, `packaging/zhiji-user-boundaries.json`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 修复用户版主题思考库动态目录未显式忽略的隐私风险，补充主题思考静态契约与非个人内容 walkthrough 记录；同时修复周/月/项目/年综合代理只返回“已创建”导致 workflow 无法提取聊天摘要的问题，并新增用户版分发边界清单与回归测试，明确 shared / override / user_only 的维护责任。

## [2026-07-11 13:14] [功能] 新增轻量主题思考库 (v1.5.26 -> v1.6.0)

- **受影响文件**: `.claude/shared/`, `AGENTS.md`, `CLAUDE.md`, `packaging/zhiji-user-overlay/`, `packaging/zhiji-user-manifest.json`, `zhiji-user/`, `tests/topic-thinking-contract.tests.ps1`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 用户现在可以主动与 AI 探讨任意长期问题，在确认归纳后按主题动态沉淀当前认识、依据、反例、未决问题与观点演化；后续相关提问通过轻量索引按需召回并透明说明来源，同时保持日志不自动摘录、未经确认不写入和当前表达优先等边界。

## [2026-07-11] [修复] 恢复主 README 版本徽章同步 (v1.5.25 -> v1.5.26)

- **受影响文件**: `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 修复 README 第一性原理重构时误删版本与许可证徽章的问题，恢复公开版本入口，并重新确保 README 徽章、项目状态与版本文件保持一致。

## [2026-07-11 11:58] [文档] 以第一性原理重构主项目与用户版说明 (v1.5.24 -> v1.5.25)

- **受影响文件**: `README.md`, `packaging/zhiji-user-overlay/README.md`, `zhiji-user/README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 重新以“发现模式、形成行动、后续验证”为主线组织项目说明；主 README 补齐产品全景、行为假说与干预实验、人机角色契约和维护导航，用户版 README 则收敛为纯最终用户手册，完整说明功能、首次使用、验证闭环、隐私与常见问题，并移除测试和分发维护内容。

## [2026-07-11 03:01] [修复] 修复主项目与用户版运行及分发冲突 (v1.5.23 -> v1.5.24)

- **受影响文件**: `.codex/hooks.json`, `.gitignore`, `packaging/zhiji-user-manifest.json`, `packaging/zhiji-user-overlay/`, `zhiji-user/`, `tests/project-integrity.tests.ps1`, `docs/zhiji-user-sync-workflow.md`, `docs/archive/changelog-detailed-2026-07-08.md`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 对主项目和用户版执行运行完整性审查，修复 Windows 下 Codex Stop Hook 依赖不可用 bash、用户版 Codex 自由日志路由落后于 Claude matcher、分发文档包含维护者绝对路径、年度输出目录缺失、画像隐私说明不准确，以及根 `.gitignore` 误吞用户版变体源的问题；新增完整性回归测试，确保 manifest 源受主仓库跟踪、导出结果无漂移且新环境目录与 Hook 契约完整。

## [2026-07-11] [配置] 新增功能必要性闸门 (v1.5.22 -> v1.5.23)

- **受影响文件**: `AGENTS.md`, `CLAUDE.md`, `PROJECT_STATUS.md`, `README.md`, `VERSION`, `docs/superpowers/specs/2026-07-11-feature-necessity-gate-design.md`, `docs/superpowers/plans/2026-07-11-feature-necessity-gate.md`
- **改动摘要**: 新增能力在进入 spec、plan 和代码前必须先通过当前问题证据、核心目标、最简方案和即时验证四项判断；任一项不成立时先停止实施、说明机会成本并劝阻，用户知情后再次坚持才允许继续。规则直接收敛在现有治理规范中，不新增 hook、agent、skill 或运行时契约。

## [2026-07-10 10:31] [功能] 支持非模板日志并按证据等级收敛日反馈 (v1.5.21 -> v1.5.22)

- **受影响文件**: `.claude/settings.json`, `.claude/shared/contracts/`, `.claude/shared/prompt-rules.md`, `.claude/skills/log.md`, `.claude/agents/daily-analyzer.md`, `.claude/agents/journal-quality-coach.md`, `.claude/commands/daily-review.md`, `.claude/commands/journal-coach.md`, `perspectives/journal-quality.md`, `tests/journal-input-contract.tests.ps1`, `packaging/zhiji-user-overlay/`, `zhiji-user/`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 自由叙事现在可通过“日志 / 日记 / 记录一下”等自然语言入口稳定进入存档与日反馈链路，并新增证据卡、A-D 输入等级和降级输出规则；同时收紧心理归因与验证写回，把单次干预失败从行为模式证伪中分离，并修复主项目日志教练误用日分析代理的问题。

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
