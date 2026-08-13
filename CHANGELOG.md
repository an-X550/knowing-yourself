---
created: 2026-07-05
last_updated: 2026-08-13
---

# CHANGELOG - 改动记录

## [2026-08-13 16:58] [修复] 同步项目状态版本事实 (v1.21.0 -> v1.21.0)

- **受影响文件**: `PROJECT_STATUS.md`
- **改动摘要**: 将项目状态中的当前版本从 1.20.0 同步为 `VERSION` 已发布的 1.21.0；本次只纠正治理事实，不改变产品行为。

## [2026-08-13 16:40] [功能] 在飞书日反馈中加入无状态追问 (v1.20.0 -> v1.21.0)

- **受影响文件**: `.claude/workflows/local-feishu-daily-feedback.ps1`、用户版镜像、飞书入口回归测试、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 每份飞书日反馈现在明确提示可发送“追问：…”、“为什么？”或“关于刚才，展开说说”，也可按日期追问旧反馈。追问只读取一份每日反馈及可选同日日志，绝不改写日志或反馈、不创建任务、不分发、不保存聊天记录；普通闲聊不会调用模型。

## [2026-08-13 16:25] [功能] 将 Windows 客户端收敛为任务型入口 (v1.19.0 -> v1.20.0)

- **受影响文件**: Windows 客户端开始页、导航、日志/复盘/项目/设置页面、样式、测试与客户端说明，以及根 `PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 新增只基于本地数据、规则透明的“建议下一步”，一级导航收敛为开始、日志、复盘、项目、设置；日志和复盘历史分别回归所属任务，项目复盘自动携带项目上下文。未配置 AI 时主操作只保存日志，不再呈现不可完成的生成动作；E2E 会先自动构建 Electron 入口，避免干净目录直接启动失败。Electron 主链路已验证，陌生用户 10 秒理解测试仍保留为人工发布门。

## [2026-08-13 16:20] [功能] 支持弹性飞书日志入口与常用日期栏目格式 (v1.18.1 -> v1.19.0)

- **受影响文件**: `.claude/workflows/local-feishu-daily-feedback.ps1`、用户版镜像、飞书入口回归测试、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 飞书智能体现在可直接接收带明确日期的“幸福日志 / 日记 / 复盘”文本，或“日期 + 至少两个栏目”的结构化日志，不再强制要求 `日志：` 前缀；支持常见数字和中文日期，缺少年份按接收年份处理。栏目仅作为原文定位线索，分析仍坚持一条有证据的洞察、一个行动和一个可观察验证，普通聊天不会自动入库。

## [2026-08-13 15:30] [修复] 修正飞书日志日期归档与滴答分发启动失败 (v1.18.0 -> v1.18.1)

- **受影响文件**: `.claude/workflows/local-feishu-daily-feedback.ps1`、用户版镜像、日期与分发回归测试、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 本地飞书入口现在识别 `幸福日志 M.D` 并按正文日期归档，而非静默使用消息接收日；滴答隔离任务移除了与 sandbox 互斥的启动参数，使任务创建能实际发起，同时在后续失败时保留真实外部诊断，避免只显示笼统的 `remote_failed`。

## [2026-08-13 14:55] [功能] 补齐 Windows 客户端本地数据掌控闭环 (v1.17.0 -> v1.18.0)

- **受影响文件**: Windows 客户端数据目录、个人背景、备份校验、设置、今天/复盘交互、测试与客户端说明，以及根 `PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 普通用户现在可看见并打开真实本地数据目录，在固定 Markdown 文件中管理可导出恢复的个人背景；备份在预览与正式切换前验证业务 Schema 和关系，API Key 继续排除。日反馈和周期复盘可原位阅读，未配置 AI 仍可保存日志；目录迁移、合并恢复和个人背景注入 AI 继续暂缓。

## [2026-08-13 12:45] [功能] 交付本地优先 Windows 桌面客户端 MVP (v1.16.1 -> v1.17.0)

- **受影响文件**: `apps/zhiji-desktop/`, `README.md`, `PROJECT_STATUS.md`, `VERSION`, `.gitignore`, `docs/superpowers/`
- **改动摘要**: 新增面向非 CLI 用户的 Electron + React + TypeScript Windows 客户端，以交互原型为基线提供今天、复盘、项目、历史和设置五页；日志、复盘和项目继续保存在本地，支持用户自己的 OpenAI 兼容 API Key、Windows 安全凭据与带清单/哈希校验的 ZIP 备份和空目录恢复。23 个测试文件、48 项测试、真实 Electron E2E、类型检查、生产依赖 0 漏洞和现有 CLI/Skill/Agent 回归均已通过；x64 安装包已生成但未执行安装，Windows 10、升级/卸载、签名和自动更新仍明确暂缓。

## [2026-08-13 12:30] [文档] 同步用户版离线 HTML 浏览入口 (v1.16.0 -> v1.16.1)

- **受影响文件**: `README.md`, `PROJECT_STATUS.md`, `VERSION`, `packaging/zhiji-user-manifest.json`, `packaging/zhiji-user-boundaries.json`, `packaging/zhiji-user-overlay/*.html`, `packaging/zhiji-user-overlay/README.md`, `zhiji-user/*.html`, `zhiji-user/README.md`
- **改动摘要**: 将用户上手、详细使用说明与飞书/手机记录入口/滴答设置收敛为导出受控的离线 HTML 页面；主项目与用户版 README 均优先链接浏览器入口，避免后续导出覆盖、内容偏移或 Markdown 阅读体验不一致。

## [2026-08-12 23:52] [功能] 向用户版同步飞书每日反馈与通用 AI 部署入口 (v1.15.5 -> v1.16.0)

- **受影响文件**: 用户版边界与 overlay、飞书监听工作流、配置示例、用户 README、飞书与滴答部署说明、分发边界测试、设计与计划、主 `README.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 用户分发版现可导出与主项目逐字一致的单用户飞书每日反馈监听代码和无敏感配置示例，并提供可交给执行型 AI 的飞书、滴答、Codex、Claude、DeepSeek 部署指令。个人 open_id、目录 token、清单 ID、凭证、运行状态、UU 远程偏好和真实验收标识均不进入分发包；AI 后端只替换日志分析适配器，确定性本地落盘与受限远端分发保持不变。

## [2026-08-12 23:45] [文档] 以使用者任务重写主项目 README (v1.15.4 -> v1.15.5)

- **受影响文件**: 主 `README.md`、`VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`
- **改动摘要**: 主 README 改为项目的真实入口：先帮助陌生读者判断问题匹配、适用边界、最短开始路径和结果预期，再提供隐私、手机入口与协作导航；不再把维护者说明作为主体，也未修改 `zhiji-user/README.md`。

## [2026-08-12 23:19] [文档] 统一个人飞书入口与可替换 AI 部署说明 (v1.15.3 -> v1.15.4)

- **受影响文件**: 个人飞书部署手册、本地飞书入口说明、结果分发设置、主 `README.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 将当前 Windows 环境、GPT-5.4 日分析、无模型启动预检、UU 远程维护、飞书文档与滴答行动部署、14 天观察门和云服务器备选统一为主项目权威文档；新增可交给任意执行型 AI 的部署指令，并把可替换边界收敛为“只替换日志分析适配器，保留确定性落盘与受限分发”。本次不修改或同步 `zhiji-user/`。

## [2026-08-12 17:38] [修复] 校正文档状态、版本时间线与敏感标识漂移 (v1.15.2 -> v1.15.3)

- **受影响文件**: 正式规格、产品路线图、验收进度、`CHANGELOG.md`、`VERSION`、`PROJECT_STATUS.md`、主/用户版 README
- **改动摘要**: 将已于 v1.5.5 落地的目录边界规格和已完成的审计清理规格改为完成状态；把路线图从 v1.3.24 的 Claude Code 单入口快照更新为当前 Codex/Claude 兼容、用户版与可选外部分发边界；纠正四来源滴答适配的错误时间戳，并从受控进度文档移除飞书根 token 与滴答任务 ID，只保留可验证事实。根目录临时验收文件的迁移涉及删除或移动，留待维护者确认。

## [2026-08-12 17:36] [修复] 将纯提醒默认路由收敛到滴答清单 (v1.15.1 -> v1.15.2)

- **受影响文件**: 执行规范、结果分发契约、用户说明、提醒实施计划、项目状态、回归测试、短设计、`VERSION`
- **改动摘要**: 基于 Codex 多轮定时派发未送达和滴答原生重复任务已成功创建的实际证据，一次性与周期性纯提醒现默认使用滴答清单；只有用户明确指定时才使用 Codex 定时任务，需要自动执行工作的请求单独评估。现有 Codex 周提醒已暂停以避免重复，滴答周复盘任务保留至 2026-08-16 19:00 验证首次真实通知；未新增调度器、服务或后台重试。

## [2026-08-12 17:15] [修复] 补齐滴答适配验收与运行边界 (v1.15.0 -> v1.15.1)

- **受影响文件**: 结果分发契约与配置、滴答设置说明、四来源适配设计、端到端模拟验收夹具与测试、用户版 overlay/导出包、`VERSION`、`PROJECT_STATUS.md`、`README.md`
- **改动摘要**: 补齐候选修改不改报告、“仅本地”不追溯、只拦截明显直接冲突、理由按真实取舍显示和旧状态兼容规则；首次设置固定保存“知己行动”清单 ID，正式分发不再查清单。以不写远端的端到端模拟覆盖四来源和关键失败边界，并完成一次官方 MCP 脱敏任务冒烟测试；测试通过后即可正式使用，不再等待人为累计 3+1+1 次真实样本。

## [2026-08-12 16:48] [功能] 收敛滴答清单四来源最小适配 (v1.14.2 -> v1.15.0)

- **受影响文件**: 结果分发契约、日反馈/周复盘/月复盘/主题思考入口、Codex 自然语言路由、分发配置与设置说明、用户版 overlay/导出包、回归测试、`VERSION`、`PROJECT_STATUS.md`、`README.md`
- **改动摘要**: 滴答清单现只承担执行入口和提醒：每日反馈的唯一合格行动自动创建，周/月复盘在最终整组确认后创建，已确认主题思考可随保存确认创建或“只保存主题”；任务只含 SMART 化标题与截止时间，按标题加精确截止时间跨来源防重。项目/年度/人生设计不再产生滴答任务，完成判断仍只读取后续日志，不增加双向同步、后台重试、模糊去重或复杂调度。

## [2026-08-12 15:46] [修复] 将仅本地收敛为单次请求选择 (v1.14.1 -> v1.14.2)

- **受影响文件**: 结果分发契约、各报告与沉淀入口、用户版说明、回归测试、`VERSION`、`PROJECT_STATUS.md`、`README.md`
- **改动摘要**: 移除写入 Markdown frontmatter 的持久化 `distribution: local_only` 机制；用户在本次生成请求中明确说“仅本地”时，报告仍正常写入和复读，但本轮同时跳过飞书与滴答，不新增配置、状态或永久标记，后续请求恢复正常分发规则。

## [2026-08-12 14:42] [修复] 校正飞书历史与授权恢复事实 (v1.14.0 -> v1.14.1)

- **受影响文件**: 飞书设置说明、`PROJECT_STATUS.md`、用户版文档、回归测试、`VERSION`、`README.md`
- **改动摘要**: 历史 60 项已从“等待确认”修正为完成同步；明确日常 bot 写入不要求逐次用户授权，只有自动授予权限失败或专用用户实际不可见时才恢复授权，并复用已有 document token 补权限而不重复导入。真实非 Markdown 收藏附件与三次真实新写入继续保留为观察门，不制造测试内容。

## [2026-08-12 13:35] [功能] 扩展知己飞书沉淀白名单 (v1.13.0 -> v1.14.0)

- **受影响文件**: 结果分发契约与配置示例、收藏入口、共享路径、飞书设置说明、用户版 overlay 与导出包、回归测试、`VERSION`、`PROJECT_STATUS.md`、`README.md`
- **改动摘要**: 复用官方 `lark-cli` 将新生成的正式复盘、人生设计、已确认主题思考和明确收录的收藏/附件路由到固定“知己”目录；不开发上传器或同步系统，不扫描电脑，不扩大滴答边界。真实目录已创建并授予专用用户完整访问权限；历史内容继续保留人工确认门。

## [2026-08-12 02:44] [功能] 建立可选的结果分发闭环 (v1.12.2 -> v1.13.0)

- **受影响文件**: 结果分发契约与默认关闭配置、日反馈和周期复盘入口、飞书/滴答设置说明、用户版 overlay 与导出包、回归测试、`VERSION`、`PROJECT_STATUS.md`、`README.md`
- **改动摘要**: 新报告成功落盘并复读后，可选地把完整报告副本分发到飞书、把报告中已有的合格行动分发到滴答/TickTick；本地文件保持权威，两渠道独立失败并按内容哈希防重复。能力默认关闭，已完成离线契约、飞书一次性导入、滴答最小创建闭环与分发隔离验收。

## [2026-08-01 13:26] [文档] 明确闭环提醒的触发与边界 (v1.12.1 -> v1.12.2)

- **受影响文件**: `README.md`, `zhiji-user/README.md`, `tests/project-integrity.tests.ps1`
- **改动摘要**: 明确自然语言手动检查、日反馈后单次检查和无后台催办边界，减少对提醒时机的错误预期。

## [2026-08-01 13:09] [文档] 同步闭环提醒的用户入口说明 (v1.12.0 -> v1.12.1)

- **受影响文件**: `README.md`, `zhiji-user/README.md`, `docs/daily-review-fast-path-acceptance.md`
- **改动摘要**: 补齐自然语言检查、日反馈后单条提醒及其“不自动写入个人内容”的用户说明，并修正用户版版本事实。

## [2026-08-01 00:00] [功能] 在日反馈后投递低噪声闭环提醒 (v1.11.1 -> v1.12.0)

- **受影响文件**: 日反馈与日志入口、闭环检查器、提醒投递契约与路径、用户版 overlay 与导出包、回归测试、`VERSION`、`PROJECT_STATUS.md`、`README.md`
- **改动摘要**: 成功生成新日反馈并完成验证沉淀后，系统现在可投递至多一条高优先级提醒；同一事项在 7 天内不会重复催办。提醒状态可安全丢弃，不自动更新个人内容、生成报告或启动后台定时任务。

## [2026-08-01 00:00] [修复] 接通闭环缺口检查的自然语言入口 (v1.11.0 -> v1.11.1)

- **受影响文件**: `AGENTS.md`、`CLAUDE.md`、闭环检查器、用户版 overlay 与导出包、回归测试、`VERSION`、`PROJECT_STATUS.md`、`README.md`
- **改动摘要**: “下一步、遗漏、该更新什么、是否该复盘”等自然语言现在明确进入闭环缺口检查；`current.md` 仅在最近 14 天出现足够且晚于其 `last_updated` 的实质新反馈时提醒更新，不再因文件本身较旧而催办。

## [2026-08-01 00:00] [功能] 建立证据驱动的闭环缺口检查 (v1.10.0 -> v1.11.0)

- **受影响文件**: 复盘路由与检查器、用户版 overlay 与导出包、契约测试、`VERSION`、`PROJECT_STATUS.md`、`README.md`、`CHANGELOG.md`
- **改动摘要**: 手动复盘检查现统一以新增证据与下游沉淀缺口判断日反馈、周期复盘、当前上下文、日志质量和人生设计的下一步；不再依赖固定口令或单纯文件年龄，每次仅返回一条手动建议，不自动写内容或创建后台提醒。

## [2026-08-01 00:00] [功能] 接入手动复盘时机检查 (v1.9.10 -> v1.10.0)

- **受影响文件**: `.claude/commands/review.md`、`.claude/agents/review-readiness-checker.md`、Codex 自然语言路由契约、用户版 overlay 与导出包、回归测试、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 现在可直接用自然语言询问当前是否有该补齐、更新或复盘的下一步，或使用无参数 `/review`；系统只返回一条最高优先级建议，不生成报告、不写入文件、不创建后台提醒。明确日期、周期、项目或人生设计请求仍直达原有分析入口。

## [2026-08-01 00:00] [文档] 补全双 README 的读者行动路径 (v1.9.9 -> v1.9.10)

- **受影响文件**: 主/用户版 README、用户版 overlay、`VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`
- **改动摘要**: 主 README 现提供维护者的源文件、验证与分发路径；用户版补齐完整目录获取与打开步骤，明确首次应从日反馈开始，并修正版本事实。

## [2026-08-01 00:00] [文档] 补全用户版 README 的产品认知链路 (v1.9.8 -> v1.9.9)

- **受影响文件**: 用户版 README 源与分发包、`README.md`、`VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`
- **改动摘要**: 用户版说明现先解释知己是什么、适合谁、与普通总结的区别及为何采用“假说—行动—验证”闭环，再进入功能选择和首次使用，降低首次用户的理解门槛。

## [2026-08-01 00:00] [文档] 重建用户版 README 的选择链路 (v1.9.7 -> v1.9.8)

- **受影响文件**: 用户版 README 源与分发包、`README.md`、`VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`
- **改动摘要**: 用户版说明现按“当前情境→适合能力→预期结果→直接请求”组织，并解释日反馈、行动与验证的因果关系，使首次用户能理解可用功能、当前选择与后续记录的原因。

## [2026-08-01 00:00] [文档] 用户版 README 前置首次闭环 (v1.9.6 -> v1.9.7)

- **受影响文件**: 用户版 README 源与分发包、`README.md`、`VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`
- **改动摘要**: 最终用户现在可在说明开头直接完成一次日志、洞察、小实验与后续记录的闭环；低频能力、命令和安全边界改为按需阅读，减少首次使用的信息负担。

## [2026-08-01 00:00] [文档] 根 README 聚焦维护者入口 (v1.9.5 -> v1.9.6)

- **受影响文件**: `README.md`、`VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`
- **改动摘要**: 根 README 现明确分流维护者与最终用户：维护者可直接定位运行真相、分发流程和治理文档，完整使用教程统一以 `zhiji-user/README.md` 为准，减少双 README 的重复维护与说明漂移。

## [2026-08-01 00:00] [修复] 校正主题思考说明与运行边界 (v1.9.4 -> v1.9.5)

- **受影响文件**: 主/用户版 README、overlay、`VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`
- **改动摘要**: README 现在准确区分首次讨论与确认后结构，并移除行动卡固定字段，避免用户误以为首次必走 0–6 或每次必须填满动作模板。

## [2026-08-01 00:00] [修复] 同步用户版主题更新说明 (v1.9.3 -> v1.9.4)

- **受影响文件**: 用户版 README、overlay README、`VERSION`、`PROJECT_STATUS.md`、主 README、`CHANGELOG.md`
- **改动摘要**: 用户版现在准确标注对应版本，并说明确认后新认知会先判断影响、再重组受影响论证；分发边界检查不再出现 README 漂移。

## [2026-08-01 00:00] [修复] 主题更新改为整篇论证重组 (v1.9.2 -> v1.9.3)

- **受影响文件**: 确认后主题沉淀契约、主/用户版镜像、主题契约回归测试、主题说明、真实样本脱敏回放与发布状态文件
- **改动摘要**: 用户确认新认知后，契约要求先判定它对当前判断的影响，再重组受影响论证并检查依据、重复、边界和行动/转向，以避免把内容机械追加到某个章节。篇幅按理解所需决定，未增加填写、确认、重生成或入口。

## [2026-08-01 00:00] [修复] 修正默认上下文优化计划的归档链接 (v1.9.1 -> v1.9.2)

- **受影响文件**: 默认上下文优化计划、`VERSION`、`PROJECT_STATUS.md`、`README.md`、`CHANGELOG.md`
- **改动摘要**: 已执行计划现在可从其所在目录正确打开历史决策归档；不影响运行逻辑、用户入口或报告输出。

## [2026-07-31 00:00] [重构] 默认开发治理改为按需加载 (v1.9.0 -> v1.9.1)

- **受影响文件**: `AGENTS.md`、`CLAUDE.md`、`docs/development-governance.md`、`PROJECT_STATUS.md`、历史决策归档、完整性测试与发布状态文件
- **改动摘要**: 每次会话默认只读取入口规则和当前事实；版本、发布、同步、目录、回退等低频开发细则仅在修改文件时加载。默认治理输入从 32,073 字节降至 12,804 字节，日志、复盘与自然语言入口运行能力不变。

## [2026-07-31 00:00] [功能] Codex 支持自然语言生成周报、月报和项目复盘 (v1.8.11 -> v1.9.0)

- **受影响文件**: Codex 路由共享契约、主/用户版入口与 README、分发边界、复盘质量契约、回归测试与发布状态文件
- **改动摘要**: 现在可直接说“生成 2026-W28 周报”“生成 2026 年 6 月月报”或“对 X 做项目复盘”。Codex 直接复用既有 `.claude/` 综合规则，不依赖 Claude Workflow/Task；Claude slash command 继续作为兼容入口。真实周/月/项目材料验收确认未增加默认调用或视角，并保留证据与行动质量门。

## [2026-07-31 00:00] [修复] 补齐项目复盘锚点检查与质量底线回归 (v1.8.10 -> v1.8.11)

- **受影响文件**: 项目复盘综合代理、复盘契约测试、用户版镜像与发布状态文件
- **改动摘要**: 项目复盘现在会读取可用方向锚点并按统一状态检查缺席项；回归测试改为验证证据、反例、锚点和行动等质量底线，避免只绑定提示词措辞。

## [2026-07-31 00:00] [优化] 复盘改为判断驱动的自适应深度 (v1.8.9 -> v1.8.10)

- **受影响文件**: 复盘综合契约、周/月/项目综合代理、质量基线测试、用户版镜像、README 与发布状态文件
- **改动摘要**: 周报、月报和项目复盘继续使用复盘六问作导航，但只展开会改变评价、重来选择或后续行动的判断；证据、边界、方向缺席和行动检查仍为不可省略的质量门槛。

## [2026-07-31 00:00] [文档] 同步日反馈与主题思考的当前运行边界 (v1.8.8 -> v1.8.9)

- **受影响文件**: `README.md`、`PROJECT_STATUS.md`、`CHANGELOG.md`、`VERSION`、日反馈优化归档
- **改动摘要**: README 现与运行契约一致：日反馈动作不超过 5 分钟；主题首次讨论先形成可确认主线，确认沉淀后才按用途选择 0–6 或短结构。日反馈真实运行验证也统一为连续 5 次。

## [2026-07-31 00:00] [修复] 消除日反馈预测模板与契约的矛盾 (v1.8.7 -> v1.8.8)

- **受影响文件**: `.claude/shared/contracts/daily-feedback.md`、`.claude/agents/daily-analyzer.md`、用户版镜像、日反馈回归测试、`README.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 输出模板不再将“下一篇日志出现什么”当作预测结果，统一为观察真实行为、结果或情境变化；新增负向回归会拦截旧模板回流，并确认主项目与用户版副本一致。

## [2026-07-31 00:00] [修复] 收紧日反馈预测对象并限定篇幅伸缩 (v1.8.6 -> v1.8.7)

- **受影响文件**: `.claude/shared/contracts/daily-feedback.md`、`.claude/agents/daily-analyzer.md`、用户版镜像、日反馈回归测试、`README.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 日反馈现在以真实行为、结果或情境变化验证预测，日志文字仅作为证据；只有昨日闭环复杂或存在直接证据冲突时，才可在既有 320 字上限内增加必要说明，避免简短反馈退化为长篇分析。

## [2026-07-31 00:00] [修复] 纳入用户版技能识别入口 (v1.8.5 -> v1.8.6)

- **受影响文件**: `zhiji-user/SKILL.md`、`README.md`、`PROJECT_STATUS.md`、`CHANGELOG.md`、`VERSION`
- **改动摘要**: 将 manifest 已声明、但此前未被仓库跟踪的用户版 `SKILL.md` 纳入分发包，确保安装环境能够识别知己的使用范围与入口。

## [2026-07-31 00:00] [文档] 同步主题替代结构的验收边界 (v1.8.4 -> v1.8.5)

- **受影响文件**: `docs/topic-thinking-acceptance.md`、`README.md`、`PROJECT_STATUS.md`、`CHANGELOG.md`、`VERSION`
- **改动摘要**: 验收矩阵现在与确认沉淀契约一致：地图、准则、对照和边界主题在用户确认后可直接采用更短结构，仍必须保留证据校正与行动验证或等待条件。

## [2026-07-31 00:00] [修复] 恢复主题首稿与沉淀的轻量边界 (v1.8.3 -> v1.8.4)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`、`topic-thinking-persistence.md` 路由、用户版镜像、主题契约测试与首稿回放记录
- **改动摘要**: 首次讨论再次只读取首稿规则，确认沉淀后才读取 0–6、维护与全量审查；保留“已有结论或等待条件即结束”的规则，避免为完整感增加补材料或额外轮次。

## [2026-07-31 00:00] [修复] 主题首稿在结论闭环后直接结束 (v1.8.2 -> v1.8.3)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`、用户版镜像、主题契约测试与首稿回放审计
- **改动摘要**: 首稿已有可执行结论或等待条件时不再为完整感要求补背景、逐项展开或再来一轮；继续讨论只保留为会改变当前判断的可选入口。三条固定脱敏输入各一次回放均保持依据、判断与行动/等待的闭环。

## [2026-07-31 00:00] [回退] 撤回未经质量证明的主题契约拆分 (v1.8.3 -> v1.8.2)

- **受影响文件**: `topic-thinking.md`、提示规则、主题契约测试与用户版生成副本
- **改动摘要**: 1.8.3 曾声称首稿质量已由盲测验证，但缺少可复查原始证据；补齐的独立盲评中候选在复杂现实选择退步（12/14，基线为 14/14）。因此撤回该候选运行行为，不发布 1.8.4。

## [2026-07-31 00:00] [修复] 分离主题首稿与确认沉淀契约 (v1.8.2 -> v1.8.3)

- **受影响文件**: `topic-thinking.md`、`topic-thinking-persistence.md`、提示规则、分发边界、测试与用户版生成副本
- **改动摘要**: 首次讨论仅读取首稿契约；确认后才读取沉淀、行动验证和全量维护规则。三例独立匿名盲测中候选均优于基线且逐项不退步。

> 发布视角。这里只保留对用户或协作者重要的变化；详细过程记录已归档到 [docs/archive/changelog-detailed-2026-07-08.md](docs/archive/changelog-detailed-2026-07-08.md)。

## [2026-07-31 00:00] [修复] 主题首次讨论改为逻辑链，确认后再选沉淀结构 (v1.8.1 -> v1.8.2)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`、`packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md`、主题模板、用户版生成副本、`tests/topic-thinking-contract.tests.ps1`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 首次讨论现在先输出“问题→事实/约束→判断→下一步”的标题与正文链，不再预填 0–6；用户确认后按主题用途选择行动型 0–6 或地图、准则、对照、边界等短结构。写入确认、证据降级、路径安全和行动验证边界保持不变。

## [2026-07-21 00:00] [修复] 为用户版补充 WorkBuddy 技能识别入口 (v1.8.0 -> v1.8.1)

- **受影响文件**: `packaging/zhiji-user-overlay/SKILL.md`、`packaging/zhiji-user-manifest.json`、`packaging/zhiji-user-boundaries.json`、`zhiji-user/SKILL.md`、`tests/distribution-boundary.tests.ps1`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 用户版根目录现在包含供 WorkBuddy 识别的 `SKILL.md`；该文件只提供技能元信息、触发范围和运行导航，不改变既有知己入口或运行逻辑，且会随用户版导出稳定保留。

## [2026-07-19 00:00] [功能] 主题思考支持受控的自定义结构 (v1.7.6 -> v1.8.0)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`、用户版契约与主题模板副本、`README.md`、`docs/topic-thinking-acceptance.md`、`tests/topic-thinking-contract.tests.ps1`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 主题默认仍使用 0–6 闭环结构；仅在标准结构会制造重复或遮蔽调用入口、替代结构能更直接服务判断/行动/验证且用户明确确认时，允许采用带 `format` 和 `semantic_role` 标识的自定义结构，同时保留范围转向、证据校正与验证边界。

## [2026-07-19 00:00] [修复] 修正主题契约与新主题模板的结构漂移 (v1.7.5 -> v1.7.6)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`、用户版契约与主题模板副本、`tests/topic-thinking-contract.tests.ps1`、`PROJECT_STATUS.md`、`README.md`、`VERSION`
- **改动摘要**: 统一第 5 节名称，允许无长期行动时声明等待条件而非虚构表格，并让测试验证契约、模板与用户版副本一致。

## [2026-07-19 00:00] [修复] 增加全量主题语义审查验收模板 (v1.7.4 -> v1.7.5)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`、用户版契约副本、`tests/topic-thinking-contract.tests.ps1`、`PROJECT_STATUS.md`、`README.md`、`VERSION`
- **改动摘要**: 全量审查必须按统一模板证明范围、逐篇六维问题与正文位置、决策和文件修改、跨主题映射及压缩后复核，缺项不得宣称完成。

## [2026-07-19 00:00] [修复] 明确主题语义审查的交付边界 (v1.7.3 -> v1.7.4)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`、用户版契约副本、`tests/topic-thinking-contract.tests.ps1`、`PROJECT_STATUS.md`、`README.md`、`VERSION`
- **改动摘要**: 明确行动卡、实验周期和格式整理不能代替语义审查；全量交付必须包含逐篇问题与决策、正文修改、主从映射及压缩后复核。

## [2026-07-19 00:00] [修复] 同步主题第 5 节的行动验证契约 (v1.7.2 -> v1.7.3)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`、用户版契约副本、`tests/topic-thinking-contract.tests.ps1`、`PROJECT_STATUS.md`、`README.md`、`VERSION`
- **改动摘要**: 第 5 节统一为“行动验证与复查”：进行中实验保留步骤和期限，已结束实验只保留验证、停止和转向条件，避免正文与运行契约冲突。

## [2026-07-19 00:00] [修复] 修正主题思考全量优化的状态表述 (v1.7.1 -> v1.7.2)

- **受影响文件**: `PROJECT_STATUS.md`、`README.md`、`VERSION`
- **改动摘要**: 更正此前将行动卡与过期实验整理表述为“全量内容质量优化已完成”的状态漂移；默认语义审查契约已就位，但 24 份主题的重复、冲突、证据和跨主题重叠仍需按既有计划逐篇落实为实际文件修改。

## [2026-07-19 00:00] [修复] 补强全量主题的语义质量审查契约 (v1.7.0 -> v1.7.1)

- **受影响文件**: 主题思考共享契约、用户版运行副本、静态契约测试、`README.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 修正“只整理行动卡和实验周期就算完成质量审查”的缺口；现在全量审查必须覆盖主题内重复、跨主题重叠、过期冲突、证据质量、行动质量与篇幅价值，并将每项决策落实为实际文件修改，审查记录不能替代优化。

## [2026-07-19 00:00] [功能] 主题思考默认合并审查与全量质量复核 (v1.6.21 -> v1.7.0)

- **受影响文件**: 主题思考共享契约、用户版主题模板、静态契约测试、`关于我/思考/` 私有主题与审查记录、`README.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 主题创建和更新现在默认按第一性原理审查候选信息，并以保留、修正、替换、合并、归档或不写入处理，避免无判断追加；行动可完成、停止或被替代。全部 24 份现有主题已逐篇审查并收敛当前行动入口。

## [2026-07-19 00:00] [修复] 同步主题行动卡的运行契约 (v1.6.20 -> v1.6.21)

- **受影响文件**: 主题思考共享契约、用户版运行副本、静态契约测试、`README.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 删除契约中仍把短期动作、长期动作、触发、停止与复查写成固定字段的旧表述；现在与模板、测试和已复核主题一致，行动卡只保留按需增减的最小必要行动及其触发和观察/停止条件。

## [2026-07-19 00:00] [修复] 主题思考改为自适应质量边界 (v1.6.19 -> v1.6.20)

- **受影响文件**: 主题思考共享契约、用户版主题模板、静态契约测试、`关于我/思考/` 私有主题文件、`README.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 主题内容现在仅在影响判断、行动或验证时展开；行动没有固定数量，只有直接回应问题、用户可控、具备触发与可观察结果时才保留。无合格行动可明确不行动；现有 24 份主题的行动层已逐篇压缩为最小可验证入口。

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
