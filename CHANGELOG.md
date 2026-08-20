---
created: 2026-07-05
last_updated: 2026-08-20
---

# CHANGELOG - 改动记录

## [2026-08-20 23:12] [破坏性变更] 从桌面端移除主题思考，收敛复盘主链路（v1.28.3 -> v2.0.0）

- **受影响文件**: `apps/zhiji-desktop/` 的主题导航、页面、复盘页跳转按钮、IPC/Preload API、主题服务/仓储/会话 checkpoint、提示词、DSH 主题工具与对应测试；桌面架构、兼容矩阵、DSH 接入说明；`docs/specs/2026-08-20-deepseek-harness-agent-architecture.md`、`PROJECT_STATUS.md`、`PROGRESS.md`、`README.md`、`VERSION`
- **改动摘要**: 依据第一性原理，主题思考只是“与 AI 讨论后沉淀认识”的辅助便利，不是日志—日反馈—周/月复盘主链路。为降低运行时、IPC、测试和数据生命周期维护成本，桌面端不再提供主题入口、主题会话或主题 DSH 工具；日志、每日反馈、周/月/项目/年度复盘、验证模式和 Agent 主链路保留。已有用户 `topics/` 与 `runtime/topic-sessions/` 数据不主动删除，Skill/CLI 侧主题契约和 WorkBuddy 路由不变；D2 主题会话迁移取消。

## [2026-08-20 22:45] [修复] 主题思考确认防止过期提案覆盖新认识（v1.28.2 -> v1.28.3）

- **受影响文件**: `apps/zhiji-desktop/src/main-process/application/topic-thinking.ts`、`apps/zhiji-desktop/src/main-process/infrastructure/topics/topic-repository.ts`、`apps/zhiji-desktop/src/shared/schemas/domain.ts`、主题单测与集成测试、`PROJECT_STATUS.md`、`PROGRESS.md`、`VERSION`、`README.md`
- **改动摘要**: 主题思考继续保留原有独立入口和“讨论—归纳—用户确认—沉淀”闭环，不为尚无真实收益证据的 DSH 迁移复制第二套流程。提案现在记录生成时的主题版本，确认写入在仓储串行队列内做条件检查；若主题已被其他窗口更新，旧提案会被拒绝而不会覆盖新认识。按别名更新时也会写回规范主题文件。主题内容、旧 checkpoint 和每日/周/月复盘入口均不变。

## [2026-08-20 22:20] [修复] Agent 缺少 API Key 时提供设置恢复入口（v1.28.1 -> v1.28.2）

- **受影响文件**: `apps/zhiji-desktop/src/renderer/pages/agent-page.tsx`、`apps/zhiji-desktop/tests/unit/agent-page.test.tsx`、`apps/zhiji-desktop/docs/dsh-integration-notes.md`、`PROGRESS.md`、`PROJECT_STATUS.md`、`VERSION`、`README.md`
- **改动摘要**: Agent 仍由 Main Process 负责密钥读取和错误映射；当模型明确返回缺少 API Key 时，页面显示“打开设置”恢复动作，用户无需离开 Agent 页面自行寻找配置入口。未改变密钥存储、日志/复盘确认门或任何正式数据写入路径。

## [2026-08-20 21:06] [修复] 修复桌面端 DSH 主进程启动崩溃（v1.28.0 -> v1.28.1）

- **受影响文件**: `apps/zhiji-desktop/vite.main.config.ts`、`apps/zhiji-desktop/forge.config.ts`、`apps/zhiji-desktop/src/main-process/agent/utility.ts`、`apps/zhiji-desktop/e2e/desktop.spec.ts`、`VERSION`、`README.md`、`PROJECT_STATUS.md`
- **改动摘要**: DSH 发布包不再被 Vite 内联到主进程和 Utility Process bundle；生产 asar 同时带入 DSH 运行时及 Windows FFI 依赖，保留包自己的 `package.json` 相对解析，并按 Electron Utility Process 契约从 `process.parentPort` 接收端口，使开发启动、打包启动和 Agent 会话创建都能正常工作。此前启动时会因找不到 `../package.json`、外置的 `@deepseek-ai/dsh-session`，或错误读取 `electron.parentPort` 直接退出，桌面日志闭环和 Agent 均无法使用。

## [2026-08-20] [功能] 接入 DSH Agent 会话持久化与备份生命周期（v1.27.18 -> v1.28.0）

- **受影响文件**: `apps/zhiji-desktop/` 的 DSH JSONL 会话持久化、重启列表/resume 协议、数据目录备份校验与回归测试；桌面架构、Skill 兼容矩阵、DSH 接入说明；`docs/specs/2026-08-20-deepseek-harness-agent-architecture.md`、`PROJECT_STATUS.md`、`PROGRESS.md`、`VERSION`、`README.md`
- **改动摘要**: Agent 会话现在由官方 `@deepseek-ai/dsh-session-persistence-jsonl@0.1.0-rc.8` 写入知己数据根的 `agent/sessions/`，重启后可列出并由 DSH `AgentRegistry.resume` 继续；数据目录迁移会递归带走会话，备份导出/恢复按 DSH 事件协议校验，损坏会话明确拒绝而不静默清空。每日分析、周复盘、月复盘、主题和项目的既有专业入口继续保留；主题旧 checkpoint 暂不强迁移，待 DSH 覆盖提案/差异/确认闭环并有真实使用证据后作为 D2 单独实施。

## [2026-08-20] [功能] 接入桌面端 DSH Agent 阶段 C 正式工作流桥 (v1.27.17 -> v1.27.18)

- **受影响文件**: `apps/zhiji-desktop/` 的 Agent 工具协议、Main Process 分发器、日志/复盘用例取消桥、Agent 确认 IPC、Agent 页面与测试；桌面架构/兼容矩阵/DSH 接入说明；`PROJECT_STATUS.md`、`PROGRESS.md`、`VERSION`、`README.md`
- **改动摘要**: Agent 可在用户明确要求时复用既有日志创建/更新和每日反馈服务；周/月/项目及洞察复盘先返回既有材料预览，Main Process 以按会话绑定的一次性确认令牌等待页面按钮确认后才生成正式内容。取消会从 DSH 工具信号传到既有 `ReviewTaskManager`，结果只以脱敏摘要和既有页面导航卡返回，未开放 Shell、任意文件、任意 URL 或绕过确认的写入捷径。

## [2026-08-20] [功能] 完成桌面端 DSH Agent 阶段 B 只读领域工具桥 (v1.27.16 -> v1.27.17)

- **受影响文件**: `apps/zhiji-desktop/` 的 DSH 工具运行时、Main Process 分发器、模型工具调用流、Agent 页面、测试与架构文档；`PROJECT_STATUS.md`、`PROGRESS.md`、`VERSION`
- **改动摘要**: DSH 现在可经 Main Process 的严格 Zod 工具桥读取脱敏日志、复盘、项目、已确认主题与验证模式，复用受控搜索/读源，并以安全的数据事件请求既有页面导航和结果卡。未把每日反馈、周/月/项目复盘等正式工作流迁入或改写为聊天；它们继续使用既有证据、预览确认、取消与仓储写入链路。补齐 OpenAI 兼容流中工具调用后续分片省略 call ID 的解析，确保真实工具参数完整。

## [2026-08-20] [功能] 完成桌面端 DSH Agent 阶段 A 会话桥 (v1.27.15 -> v1.27.16)

- **受影响文件**: `apps/zhiji-desktop/` 的 DSH 运行时、Main/Preload/IPC 契约、Agent 页面、测试与架构文档；`PROJECT_STATUS.md`、`PROGRESS.md`、`VERSION`
- **改动摘要**: 新增独立 Electron Utility Process 中的最小 DeepSeek Harness Agent loop、结构化 MessagePort 会话协议与 Main Process 模型流代理；API Key 继续只由 Main Process 解密使用。桌面端新增“知己 Agent”会话页，支持流式消息、停止和中文崩溃降级。每日反馈、周/月/项目复盘、主题和项目仍由既有页面与应用服务负责，未迁移或绕过既有校验、确认和正式写入链路；下一阶段才会以受控只读工具复用这些能力。

## [2026-08-20] [文档] 用户版接入 WorkBuddy 飞书智能体部署路径 (v1.27.14 -> v1.27.15)

- **受影响文件**: `zhiji-user/` 导出源、WorkBuddy 运行入口、用户版 README/离线说明、`README.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 用户版现在包含与主项目一致的 WorkBuddy 多通道运行入口，并提供一份可直接交给 AI 执行的部署说明：用户自行完成 WorkBuddy、飞书智能体、飞书应用和滴答 MCP 的官方授权，AI 负责受限的本地配置与脱敏验收。文档明确 WorkBuddy 助理目录不能替代知己工作空间、本地 Markdown 是权威记录，以及滴答只允许唯一创建任务工具；旧本地飞书监听不再是新用户推荐路径。

## [2026-08-20] [修复] 建立 DSH Agent 阶段 0 可判基线 (v1.27.13 -> v1.27.14)

- **受影响文件**: `apps/zhiji-desktop/tests/unit/reviews-page.test.tsx`、`apps/zhiji-desktop/docs/dsh-integration-notes.md`、`PROGRESS.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 修复周复盘页面测试把运行日期写死造成的失败，改为验证同一默认范围函数计算出的相对日期，产品日期行为不变。同步核验 DSH `0.1.0-rc.8` 源码构建、npm 发布包、会话/工具/取消扩展点及 Utility Process 接入边界；阶段 A 可在不依赖本地源码路径的前提下开始，当前未引入 DSH 运行时代码或改变既有产品入口。

## [2026-08-20] [重构] 移除外部课程化方法论与重复分析约束 (v1.27.12 -> v1.27.13)

- **受影响文件**: 日志质量与复盘运行规则、方法论说明、路径契约、用户版导出、状态与版本文档
- **改动摘要**: 日反馈、周/月/项目复盘现在只保留会影响证据、判断、行动或验证的规则；移除“问问大象”来源、学生场景、课程化评分、固定追问深度和重复说明。日志质量检查改用中立观察点，外部分享不再构成质量门；综合复盘不再把方法论文档作为运行时回退输入。

## [2026-08-20] [修复] 收敛 WorkBuddy 单日日志执行与 Markdown 边界 (v1.27.11 -> v1.27.12)

- **受影响文件**: WorkBuddy 运行入口、固定提示词、回归测试、状态与版本文档
- **改动摘要**: 首次真实验收显示约 8 分钟的大部分耗时来自代理逐项猜路径、重复读取配置和浏览完整状态，而不是飞书或滴答调用。现在单日日志必须按已知路径最小并行读取、禁止目录枚举和无关状态探索；本地日志、反馈和报告固定为 UTF-8 Markdown，飞书导入产生的在线文档明确仅是远端副本，不能替代或改写本地文件。

## [2026-08-20] [文档] WorkBuddy 每日日志默认分发通过真实验收 (v1.27.10 -> v1.27.11)

- **受影响文件**: `PROJECT_STATUS.md`、README 与版本文档
- **改动摘要**: 带 `[知己]` 的脱敏日志已真实完成原文、每日反馈和验证沉淀的写入复读，随后通过既有 lark-cli 绝对路径成功生成飞书文档，并由 WorkBuddy 唯一暴露的滴答创建工具生成恰好 1 项任务；两渠道结果已独立写入既有幂等状态。用户决定省略重复外部写入与“仅本地”人工复测，对应语义继续由已通过的自动化回归覆盖；周复盘和主题路由仍保留为待验收事实。

## [2026-08-20] [修复] WorkBuddy 远程助理改用项目绝对路径 (v1.27.9 -> v1.27.10)

- **受影响文件**: WorkBuddy 固定提示词与入口契约、飞书兼容跳转、运行规格与测试、README、版本与状态文档
- **改动摘要**: 脱敏实测发现 WorkBuddy 远程助理固定运行在专属文件夹，且模型拿不到可靠的来源通道字段，原先要求绑定项目目录或猜测通道的部署前提不可实现，导致日志分析被误写到平台 memory。现在以简短 `[知己]` 作为跨平台触发信号，所有业务引用和写入均从一次配置的项目绝对路径解析；平台 memory 明确不得替代日志、反馈、状态或成功证据，历史飞书文件只保留单一跳转。

## [2026-08-20] [修复] WorkBuddy 滴答 MCP 收窄为真实 create-only (v1.27.8 -> v1.27.9)

- **受影响文件**: 结果分发契约、WorkBuddy 入口与提示词、分发设置及用户版镜像、规格、回归测试、版本与状态文档
- **改动摘要**: 真实运行审计发现 dida365 MCP 默认向模型暴露 50 项创建、查询、更新、完成和删除工具，提示词中的“只调用创建”并未收窄权限。现在明确使用 WorkBuddy `disabledTools` 禁用其他 49 项，重连后只允许 `dida365_create_task`；其他 Agent 平台也必须只暴露一个等价创建适配器，无法证明时停止该渠道且不回退 Codex。

## [2026-08-20] [修复] WorkBuddy 已启用分发配置恢复默认执行 (v1.27.7 -> v1.27.8)

- **受影响文件**: WorkBuddy 运行规格与回归测试、飞书/滴答分发设置、用户版镜像、版本与状态文档
- **改动摘要**: 修正多通道入口仍要求每次消息显式授权、导致既有飞书沉淀和滴答同步继续断链的问题。用户主动启用的本地分发配置现在作为持续授权，新结果写入并复读成功后默认分发；“仅本地”保留为单次退出。飞书固定使用本地 `lark_cli_path`，滴答由 WorkBuddy 的 create-only 官方 MCP 承担，缺失时不回退 Codex，两个渠道独立失败。

## [2026-08-20] [文档] 确认桌面端 DeepSeek Harness Agent 架构 (v1.27.6 -> v1.27.7)

- **受影响文件**: `docs/specs/2026-08-20-deepseek-harness-agent-architecture.md`、`PROJECT_STATUS.md`、`README.md`、`VERSION`、`CHANGELOG.md`
- **改动摘要**: 依据第一性原理确认桌面端的 Agent 升级方向：保留现有 React 专业页面、领域服务、LangGraph 和本地安全边界，由独立 Electron Utility Process 中的 DSH 负责会话与工具编排；正式规格同时记录不可原样保留的模型调用、Skill 运行方式和主题临时会话，以及后续实施阶段与验收条件，避免未来任务重新争论架构或误把 DSH Web UI 当成产品主体。

## [2026-08-20] [配置] WorkBuddy 入口改为多通道与显式分发授权 (v1.27.5 -> v1.27.6)

- **受影响文件**: WorkBuddy 运行入口、固定提示词、兼容跳转、回归测试、入口与状态文档
- **改动摘要**: 将飞书专用入口重构为 WorkBuddy 多通道消息入口，飞书、微信等不再被视为产品边界。默认仅本地仍用于防止副作用误触发，但不再永久禁止分发：用户本次明确指定目标后，才在本地写入复读成功后委托既有结果分发契约处理允许来源、配置、幂等与确认门；消息来源本身不构成同步授权。

## [2026-08-20] [文档] 固定 lark-cli 本机路径与受限环境发现方式 (v1.27.4 -> v1.27.5)

- **受影响文件**: `docs/personal-feishu-deployment.md`、`README.md`、`PROJECT_STATUS.md`、`VERSION`、`CHANGELOG.md`
- **改动摘要**: 个人飞书部署说明现在记录已复验的 `lark-cli` 1.0.86 绝对路径和 npm shim，并要求脚本与 WorkBuddy 读取本地配置后直接调用 `.exe`；同时说明受限 Agent 沙箱可能把已存在的 CLI 误报为缺失，只有绝对路径确实不存在时才执行官方重装。

## [2026-08-20] [配置] 新增 WorkBuddy 飞书运行入口契约 (v1.27.3 -> v1.27.4)

- **受影响文件**: `.claude/workflows/workbuddy-feishu-entry.md`、`docs/workbuddy-feishu-agent-prompt.md`、回归测试、入口与状态文档
- **改动摘要**: 飞书智能体现在可通过固定提示词进入唯一的 WorkBuddy 本地运行入口：日志走 `log` 编排而非只读分析器，周/月/项目复盘和主题思考严格复用既有契约。入口默认仅本地、写入后复读校验；核心画像和当前状态只可提出拟议变更，主题必须显式确认后才能沉淀，避免模板漂移与高权限误写。

## [2026-08-20 00:00] [配置] 禁用 Superpowers 自动工作流约束 (v1.27.2 -> v1.27.3)

- **受影响文件**: `AGENTS.md`、`CLAUDE.md`、`docs/development-governance.md`、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 将开发规范中自动评估、调用和复用 Superpowers 的规则整体注释，后续项目开发只遵循仓库自身流程；相关文本保留，便于需要时恢复。

## [2026-08-15 11:56] [修复] 模板编辑弹窗每敲一字焦点跳转卡住 + 安装打包分发文档 (v1.27.0 -> v1.27.1)

- **受影响文件**: `apps/zhiji-desktop/src/renderer/components/modal.tsx`、`docs/install-package-distribute.md`（新增）、`README.md`、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 修复模板编辑弹窗焦点 bug——`Modal` 的 `useEffect` 依赖内联 `onClose` 引用导致每次渲染都重跑，且 `querySelector('input,button,select,textarea')` 命中 header 的关闭键，导致每敲一个字焦点就跳到关闭按钮、输入框失焦卡住。改为 `onClose` 存 ref（effect 只在 open 变化时执行）+ 只聚焦 input/textarea/select。新增 `docs/install-package-distribute.md`：安装（安装版/免安装版）、打包（npm run make/package + 本机两个环境坑）、分发（要发哪些文件、更新机制、代码签名现状）、文件职责清单（数据目录/userData/源码结构）。README 补充 v1.27.0 三个新功能说明与文档链接。验收门：typecheck 通过；projects/settings/today 等弹窗相关单测全过。

## [2026-08-15 03:10] [功能] 桌面端自定义存储位置、日志模板系统、版本管理 (v1.26.2 -> v1.27.0)

- **受影响文件**: `apps/zhiji-desktop/src/main-process/infrastructure/data-directory/{data-root-config,data-root-holder}.ts`（新增）、`infrastructure/templates/template-repository.ts`（新增）、`bootstrap.ts`、`main.ts`、`ipc/register-handlers.ts`、`shared/schemas/{domain,ipc}.ts`、`shared/contracts/desktop-api.ts`、`preload.ts`、`renderer/pages/{today-page,settings-page}.tsx`、`package.json`（版本 1.0.0→1.27.0）、`VERSION`、`PROJECT_STATUS.md`、各页面测试 mock
- **改动摘要**: 三个新需求落地。① 自定义存储位置：新增 `DataRootConfig`（读写 `<userData>/zhiji-config.json`，存 dataRoot 与 updateUrl）与 `DataRootHolder`（运行期持有 + changeLocation 迁移）；bootstrap 改为 async 读配置；设置页"本地数据"卡片新增"更改存储位置"按钮，弹出系统文件夹选择器，确认后复制现有数据到新位置并提示重启；目标必须为空目录避免覆盖。② 日志模板：新增 `TemplateRepository` 读写 `<dataRoot>/templates/*.md`；日志页日志内容上方新增"从模板开始"下拉，选择即追加模板正文；设置页新增"日志模板"卡片，支持新建/编辑/删除模板（名称+正文）。③ 版本管理：package.json 版本同步 VERSION（1.27.0）；设置页新增"关于"卡片显示版本号与发布地址输入框，"检查更新"打开配置的 URL 获取最新安装包；用 `npm run make` 产出 Squirrel Windows 安装包到 `out/make/`。验收门：typecheck 通过；lint 0 error；受影响页面单测全过；集成测试抽样全过。

## [2026-08-15 01:40] [重构] 桌面端后端清理：重复定义归一、死代码删除、错误体系统一、竞态与超时修复 (v1.26.1 -> v1.26.2)

- **受影响文件**: `apps/zhiji-desktop/src/main-process/infrastructure/ai/provider-port.ts`（新增）、`prompts/parse-fenced-json.ts`（新增）、`application/preview-token-store.ts`（新增）、`application/{generate-daily-review,generate-periodic-review,generate-insight-review,topic-thinking,verified-patterns}.ts`、`skill-runtime/{daily-runtime,periodic-runtime,daily-grade-review}.ts`、`prompts/{daily-review-v1,journal-coach-v2,verified-patterns-v1,periodic-review-v1,topic-thinking-v1}.ts`、`infrastructure/ai/openai-compatible-provider.ts`、`infrastructure/transfer/{data-transfer-service,business-archive-validator,archive-manifest}.ts`、`infrastructure/markdown/project-repository.ts`、`infrastructure/patterns/verified-pattern-repository.ts`、`infrastructure/topics/topic-repository.ts`、`infrastructure/data-directory/data-directory-service.ts`、`ipc/register-handlers.ts`、`shared/errors/app-error.ts`、`apps/zhiji-desktop/docs/architecture.md`、`VERSION`、`PROJECT_STATUS.md`；删除 `domain/{token-budget,date-periods,project-materials}.ts` 及其三个测试文件
- **改动摘要**: 按 spec 阶段 4 执行（无契约与行为变化）。归一：`ProviderPort` 8 处逐字重复→`infrastructure/ai/provider-port.ts`（stream 可选）；fenced-JSON 解析 6 份拷贝→`prompts/parse-fenced-json.ts`；预览令牌 TTL/剪枝/摘要 2 套→`application/preview-token-store.ts`。删除 3 个零生产引用死文件。错误体系：transfer/validator/runtime/repository 共 15 处裸 `throw new Error` → AppError（IMPORT_REJECTED/INVALID_INPUT/UNKNOWN）；新增 `CANCELLED` 错误码。AI 层：请求加 60s 超时（AbortSignal.any 合并调用方信号）；修复「取消被误报为 NETWORK_TIMEOUT」死分支；流式读取中段错误同样归类。竞态：project/pattern 仓储读-改-写接入串行写队列（唯一性检查与落盘不再可被插入）。IPC：7 处「取公开配置注入 model」样板下沉为 `withModel()`。

## [2026-08-15 00:50] [修复] 桌面端外观手动切换 + Markdown 行内渲染 (v1.26.0 -> v1.26.1)

- **受影响文件**: `apps/zhiji-desktop/src/renderer/utils/theme.ts`（新增）、`src/renderer.tsx`、`src/index.css`、`src/renderer/components/markdown-document.tsx`、`src/renderer/pages/settings-page.tsx`、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 修复两个真实使用反馈。① 暗色模式此前只能跟随系统：新增设置页「外观」卡片（跟随系统/浅色/深色三段切换），偏好存 localStorage，暗色令牌改由 `<html data-theme>` 驱动并监听系统切换，jsdom 环境兜底。② 主题讨论 AI 回复中的 `**加粗**`、`1. 有序列表`、`` `代码` `` 以纯文本裸露：MarkdownDocument 新增行内渲染（加粗/斜体/行内代码）与有序列表块，表格单元格同步支持行内样式，不解析 HTML 的安全边界不变。验收门：`npm test` 54 files / 308 tests 全过；`tsc --noEmit` 通过；已重新打包 exe。

## [2026-08-14 23:50] [功能] 桌面端苹果风重设计：设计令牌系统、暗色模式、AI 流式输出与阶段进度、确认弹窗统一 (v1.25.0 -> v1.26.0)

- **受影响文件**: `apps/zhiji-desktop/src/index.css`（整体重写）、`src/renderer/components/confirm-dialog.tsx`（新增）、`src/renderer/domain/history-items.ts`、`features/history/history-filter.tsx`、`history-reader.tsx`、`hooks/use-app-data.ts`、`app/app.tsx`、`pages/today-page.tsx`、`reviews-page.tsx`、`topics-page.tsx`、`projects-page.tsx`、`settings-page.tsx`、`src/shared/contracts/desktop-api.ts`、`src/preload.ts`、`src/main-process/application/topic-thinking.ts`、`domain/review-task.ts`、`ipc/register-handlers.ts`、`tests/unit/{app,today-page,reviews-page,topics-page,settings-page,projects-page}.test.tsx`、`docs/specs/desktop-apple-redesign-and-architecture-cleanup.md`（新增）、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 按 `docs/specs/desktop-apple-redesign-and-architecture-cleanup.md`（用户确认范围：前端优先 + AI 流式 + 暗色模式）执行。设计系统：index.css 重写为苹果设计令牌（字阶对齐 HIG 六档、4pt 间距网格、3 档圆角、双层环境光阴影、弹簧曲线动效、真毛玻璃 topbar、0.5px 细分割线），正文 14px→15px，消灭 settings 段 5 个死变量引用与棕色残留；`prefers-color-scheme` 暗色令牌全套。缺陷修复：补齐主题思考页 10 个零定义 class（聊天消息、搜索结果、主题库等此前裸渲染）。体验：主题讨论 AI 回复逐字流式呈现（provider stream → `topics:stream` IPC → 渲染增量 + 光标）；复盘生成显示真实阶段进度（ReviewTaskManager 阶段 → `reviews:task-phase` → 中文阶段文案）；全局消灭 `window.confirm` 与三处内联确认块，统一 ConfirmDialog 弹窗；labels 字典三处重复归一；hasApiKey 派生归一；日反馈结果从提示条改为卡片式 Markdown 呈现；项目指标卡语义修正。验收门：`npm test` 54 files / 308 tests 全过；`tsc --noEmit` 通过；lint 0 error。非目标（spec 已登记）：后端去重与死代码清理、LangGraph 简化延后另批。视觉走查与 3–5 人 10 秒理解测试仍待人工完成。

## [2026-08-14 21:30] [功能] 桌面端全面审计优化落地：意图路由删除、错误中文化、主题思考 v2、契约与依赖清理、台账治理同步 (v1.24.8 -> v1.25.0)

- **受影响文件**: `apps/zhiji-desktop/src/**`（start-page/navigation/intent 链路删除、`shared/errors/app-error.ts`、`infrastructure/ai|web`、`prompts/topic-thinking-v1.ts`、`application/topic-thinking.ts`、`renderer.tsx`、`shared/schemas/domain.ts`、`shared/contracts/desktop-api.ts`、`renderer/hooks/use-app-data.ts`、`renderer/domain/next-step.ts`、`main-process/application/generate-daily-review.ts`、`shared/domain/daily-freshness.ts`（新增）、`infrastructure/ai/provider-config.ts`、`infrastructure/data-directory/data-directory-service.ts`、`package.json`、`package-lock.json`）、`apps/zhiji-desktop/tests/**`（新增 `daily-freshness.test.ts`，删除意图路由用例）、`apps/zhiji-desktop/docs/architecture.md`、`docs/skill-compatibility-matrix.md`、`docs/contract-prompt-mapping.md`、`.claude/agents/yearly-synthesis.md`、`docs/2026-08-14-desktop-product-tech-audit.md`（新增）、`docs/2026-08-14-desktop-optimization-plan.md`（新增）、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 按 2026-08-14 全面审计与优化方案执行 P0+P1。S1 首页意图路由整体删除（用户拍板）：输入框/出发/前往、`intent.resolve` IPC、服务与提示词及测试一并移除，台账登记下线。S2/S4 错误码中文化与裸 Error 收敛（appError 工厂带中文默认文案，用户不再看到 `RATE_LIMITED` 类裸码），网络层加固（SSE 帧级容错、fetch 超时、会话上限）。S3 主题思考改造 `topic-thinking-v1`→`v2`：日反馈/复盘页可携上下文摘录跳转探讨，update 模式合并式重组整篇论证，提案持久化到会话 checkpoint（重启后可确认），Markdown 渲染生效。S5 契约层类型归位：三个类型移入 `shared/schemas/domain.ts` 消除 shared/renderer 对 main-process 的反向依赖，transfer/preview/topics 匿名返回类型改命名 schema（preview/previewInsight 重复合并）。S6 日反馈新鲜度逻辑抽至 `shared/domain/daily-freshness.ts`，前后端同引用，双端对照单测先红后绿。S7 移除五个未使用依赖与 react-query 死接线（lock 同步）。S8 台账登记：D1 双轨数据互不可消费（已知差异）、D3 月报额外一级标题（有意差异）、D4 月报视角证据包层（设计性差异不实现）、D5 补本地飞书入口与收藏吃灰库两条有意排除行、D2 复盘消费规则缺失（仅登记，实现需另过必要性闸门）、D6 修正 yearly 输出文件名为 `YYYY-annual-review.md`；architecture.md 同步实测测试数（54 文件 / 308 测试）与依赖清理事实。验收门：`npm test` 54 files / 308 tests 全过；`tsc --noEmit` 通过；lint 0 error / 5 既有 warning。README 入口描述仍准确（六入口）未改；AGENTS/CLAUDE 未提及意图路由未改。

## [2026-08-14] [修复] 桌面端入口描述修正与主题思考发布验证 (v1.24.7 -> v1.24.8)

- **受影响文件**: `README.md`、`apps/zhiji-desktop/README.md`、`docs/2026-08-14-desktop-skill-output-quality-audit.md`（新增）、`docs/2026-08-14-topic-thinking-release-task-brief.md`（新增）、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 修正两份 README 的入口描述（五个→六个，补主题思考），消除与实际导航不符的误导；附产品与 Skill 差异审计报告（输出质量、后端提示词对齐现状、主题思考缺失误判的根因分析）。无代码与提示词变化；重新打包使既有主题思考功能（提交 7908a4c）进入用户可用构建。

## [2026-08-14] [功能] 桌面端洞察三链路契约审计与判据漂移修复（阶段 C） (v1.24.6 -> v1.24.7)

- **受影响文件**: `apps/zhiji-desktop/src/main-process/prompts/insight-review-prompts.ts`、`prompts/journal-coach-v2.ts`、`tests/integration/generate-insight-review.test.ts`、`apps/zhiji-desktop/docs/skill-compatibility-matrix.md`、`contract-prompt-mapping.md`、`architecture.md`、`docs/2026-08-14-insight-contract-audit.md`（新增）、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 按路线图阶段 C 完成 coach/yearly/life-design 三链路只读对照审计（报告见 `docs/2026-08-14-insight-contract-audit.md`）：无结构漂移；4 项判据漂移立项修复，4 项设计性差异与 1 项已知差异只登记。修复：① coach 六步法命名对齐方法论权威（回忆事实、筛选重点、评估结果、洞察思考、行为改进、分享讨论），directionWarning 补四类方向信号枚举与「单日情绪低落或普通任务压力不触发」排除，提示词版本 `journal-coach-v2`→`v3`；② yearly 补升级提醒触发条件（长期方向冲突/重复卡点/工作观人生观冲突/无法局部优化），措辞指向复盘页方向校准入口、不出现命令字样，`yearly-review-v1`→`v2`；③ life-design 补「下次如何验证」要求，`life-design-v1`→`v2`。设计性差异登记：yearly <6 份硬拦截（Skill 警告继续）、yearly 输出简洁五要素（Skill 13 节长报告）、life-design 仅 quick 模式；已知差异登记：coach patterns 未单列六步法环节维度。新增 yearly 链路集成测试（6 份月报门槛 + 升级提醒契约断言）。验收门：`npm test` 52 files / 268 tests 全过；`npm run typecheck` 通过；`npm run lint` 0 error / 5 既有 warning。原 Skill 系统 `.claude/` 零改动。

## [2026-08-14] [功能] 桌面端月报深度落地：主主题归并与方向校准升级提醒（阶段 B） (v1.24.5 -> v1.24.6)

- **受影响文件**: `apps/zhiji-desktop/src/main-process/prompts/periodic-review-v1.ts`、`skill-runtime/periodic-runtime.ts`、`compatibility/periodic-review-v1.ts`、`tests/unit/periodic-review-v1.test.ts`、`tests/unit/periodic-runtime.test.ts`、`apps/zhiji-desktop/docs/skill-compatibility-matrix.md`、`contract-prompt-mapping.md`、`architecture.md`、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 按 `review-synthesis.md`「月报深度」四条补齐桌面端月报（提示词版本 `periodic-review-v3`→`v4`，快照 `desktop-periodic-review-v2`→`v3`，deferred 项移入 supports）：月报在写报告前归并 2-3 个主主题（主题名/支持视角/关键证据/反例或证据不足/对重来或下月规划的意义），渲染新增「主主题」节；下月规划含目标+手段+检查点+假说；触发条件（长期方向冲突/重复卡点/工作观人生观冲突/只能局部修补）满足时输出一条基于证据的升级提醒，措辞按桌面语境改写为指向复盘页的“方向校准”，不出现命令字样、不自动生成报告。主主题少于 2 条时代码强制注入证据不足披露（不硬凑）。周报与项目复盘渲染零变化（回归断言）。验收门：`npm test` 52 files / 267 tests 全过；`npm run typecheck` 通过；`npm run lint` 0 error / 5 既有 warning。原 Skill 系统 `.claude/` 零改动。

## [2026-08-14] [功能] 桌面端 R2 证据分级修复：D 级判级语义复核（阶段 A） (v1.24.4 -> v1.24.5)

- **受影响文件**: `apps/zhiji-desktop/src/main-process/skill-runtime/daily-grade-review.ts`（新增）、`daily-runtime.ts`、`compatibility/daily-feedback-v1.ts`、`tests/unit/daily-evidence-gold.test.ts`（新增）、`tests/unit/daily-runtime.test.ts`、`tests/integration/generate-daily-review.test.ts`、`apps/zhiji-desktop/docs/skill-compatibility-matrix.md`、`contract-prompt-mapping.md`、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 按 `docs/2026-08-14-r2-grading-fix-task-brief.md` 修复证据分级分歧 3/5 中的 D 级误熔断（S2 形态：短小第一人称评价被正则判 D，用户得不到反馈）。正则前置门不变，A/B/C 快路径零变化；仅正则判 D 时经既有 ProviderPort 追加至多一次 zod strict 约束的语义复核短调用，确认本人经历则保守升至 C（镜像反射级，不跳 A/B），失败、超时或输出无效回落原 D 补证。契约变更（用户拍板放行）：冻结项“D 级降级不调用模型”改为“反馈生成不调用模型；判级阶段允许至多一次复核短调用”。兼容快照 `desktop-daily-feedback-v2`→`v3` 增记该行为；A/B/C 级差（只影响反馈深度）登记为已知差异不修。新增金样本回归集 10 条（基线 5 + 新增 5，真实日志脱敏，含 2 条短评价、2 条疑问式解释、1 条模板日志）。验收门：`npm test` 52 files / 258 tests 全过；`npm run typecheck` 通过；`npm run lint` 0 error / 5 既有 warning。原 Skill 系统 `.claude/` 零改动。

## [2026-08-14] [功能] 桌面端与 Skill 契约对齐（R3/R6 同构、R5 上限、R1 对照表、R2 证据） (v1.24.3 -> v1.24.4)

- **受影响文件**: `apps/zhiji-desktop/src/main-process/prompts/periodic-review-v1.ts`、`periodic-runtime.ts`、`compatibility/periodic-review-v1.ts`、`prompts/daily-review-v1.ts`、`compatibility/daily-feedback-v1.ts`、`tests/**`、`apps/zhiji-desktop/docs/contract-prompt-mapping.md`、`skill-compatibility-matrix.md`、`architecture.md`、`docs/2026-08-14-r2-evidence-grading-comparison.md`、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 按契约审计任务书完成四项。R3/R6 选项 A：周期复盘提示词版本 `periodic-review-v2`→`v3`，补齐六问一级标题、聊天摘要、方向锚点五态缺席检查，新增 `applyPeriodicQualityGates` 在代码层强制注入 B/C 降级标注与空锚点披露，快照升级 `desktop-periodic-review-v2`；周报深度（3Why 与目标/手段/检查三要素）随主线完成，月报主主题归并延后。R5：日反馈提示词补“常规 260 字、例外≤320 字”上限并递增 `daily-review-v3`，快照 `desktop-daily-feedback-v2`，不加长度硬校验。R1：新增契约-提示词对照表与 6 项漂移防护断言测试。R2：5 条真实非模板日志脱敏对照，发现分歧 3/5（含 1 条 D 级误熔断、1 条跨 2 级），按任务书另行立项、本轮不改代码。验收门：`npm test` 50 files / 237 tests 全过；`npm run typecheck` 通过；`npm run lint` 0 error / 5 既有 warning。提交：`60acdf3`、`305b219`、`46be443` 及 R2 证据文档。原 Skill 系统 `.claude/` 零改动。

## [2026-08-14] [功能] 桌面端受控 Skill Runtime 完成 P1-P4 四个切片并合并入 main

- **受影响文件**: `apps/zhiji-desktop/**`（周期复盘 Runtime、验证模式仓储与服务、主题思考仓储/会话 checkpoint/受控联网、意图路由、对应 IPC/UI/测试）、`apps/zhiji-desktop/docs/skill-compatibility-matrix.md`、`PROJECT_STATUS.md`、`PROGRESS.md`、主仓库 `docs/desktop-skill-runtime-handoff.md`
- **改动摘要**: 在隔离工作树 `codex/desktop-daily-skill-runtime` 按 TDD 完成：P0/P2 周期复盘（LangGraph Runtime、A-D 证据分级、D 级补证不调模型、下游沉淀优先材料组装、预览确认、原子保存，提交 `49f2013`）；P1 受确认验证模式（模型只提候选、确认才写 JSON 快照、拒绝无持久化，提交 `fb3a326`）；P3 主题思考与受控联网（讨论—展示差异—确认—沉淀、文件型 checkpoint 重启恢复、联网仅用户显式触发且 sourceId 绑定搜索会话，提交 `7908a4c`）；P4 意图路由（确定性匹配优先、模型只能选固定枚举、Zod 失败回退澄清，提交 `a9fcf78`）。验收门：`npm test` 50 files / 229 tests 全过；`npm run typecheck` 通过；`npm run lint` 0 error / 5 既有 warning；`npm run package` Windows x64 成功。原 Skill 系统零改动；BLOCKED.md：无。2026-08-14 用户验收后以 `--no-ff` 合并入 `main`，未推送。

## [2026-08-14 02:50] [修复] 收敛飞书日反馈追问入口并恢复运行时提示 (v1.24.2 -> v1.24.3)

- **受影响文件**: 飞书日反馈监听 workflow、用户分发副本、入口回归测试、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 每份飞书日反馈现在仅提示一个可复制的追问格式：`追问：你的问题`（例如 `追问：展开讲讲`）。路由不再猜测裸“为什么？”等普通文本，避免与日志入口混淆；重启监听后，新格式会由无状态追问链路处理。

## [2026-08-14 00:40] [修复] 对齐桌面端反馈契约并安全渲染 Markdown (v1.24.1 -> v1.24.2)

- **受影响文件**: Windows 客户端日反馈与日志质量生成契约、前端文档渲染、相关测试与说明、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 明确桌面端通过 Main Process 的结构化 Schema 实现 Skill 等价行为而非运行 Claude Skill；每日反馈恢复昨日闭环、单一盲点、可选历史连接、五分钟原子行动、可观察预测和认知追踪，日志质量检查恢复 A-D 分析就绪度、六步法、重复模式及一项优先改进。结果页和历史页现在安全渲染标题、引用、列表与表格，不再向用户裸显 Markdown 符号，也不会执行日志中的 HTML。

## [2026-08-13 23:42] [修复] 兼容 DeepSeek 每日反馈结构化输出 (v1.24.0 -> v1.24.1)

- **受影响文件**: Windows 客户端 OpenAI 兼容 Provider、AI 配置适配器、每日反馈提示词与解析、错误提示、测试、客户端说明、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 正式生成每日反馈时启用 OpenAI 兼容的 JSON Object 模式，并向模型提供精确字段契约；解析层允许 DeepSeek 常见的 JSON 代码块包装，但仍对内部字段执行严格 Schema 校验。格式确实无效时改为可执行提示，不记录模型原文或用户日志。32 个测试文件、126 项测试、类型检查、Lint（0 error）、Electron E2E 与 Windows x64 打包通过。

## [2026-08-13 19:35] [功能] 对齐 Windows 客户端核心 Skill 闭环 (v1.23.0 -> v1.24.0)

- **受影响文件**: Windows 客户端每日/周期/深度分析服务、领域与 IPC 契约、复盘与设置页面、首页建议、历史记录、测试、设计计划、客户端说明、产品审计、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 每日反馈现在显式呈现上一行动的完成状态与证据；个人背景仅在用户开启授权后进入每日、周期和深度分析。复盘页在不新增一级导航的前提下，以默认折叠的“更多洞察”加入日志质量检查、年度回顾和快速方向校准，全部复用材料预览、确认生成、本地 Markdown、历史查看与安全删除链路；首页只在高频闭环完成且材料达标时给出一个月度、年度或日志质量建议。32 个测试文件、124 项测试、类型检查、Lint（0 error）、真实 Electron E2E 与 Windows x64 打包通过。

## [2026-08-13 18:56] [功能] 补齐 Windows 客户端安全数据生命周期 (v1.22.2 -> v1.23.0)

- **受影响文件**: Windows 客户端日志、复盘、项目、设置、IPC、仓储、样式与测试，设计计划、客户端说明、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 日志与复盘现在可逐条移入 Windows 回收站且不级联删除来源；项目名全局唯一并支持重命名、归档、恢复及无关联日志时安全删除；设置可清除当前服务商 API Key。所有原生下拉统一视觉但保留系统键盘与无障碍行为，未引入新依赖或批量删除能力。

## [2026-08-13 18:27] [修复] 打通 AI 配置状态与历史日志日反馈入口 (v1.22.1 -> v1.22.2)

- **受影响文件**: Windows 客户端设置页、日志历史阅读器、相关回归测试、客户端说明、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: AI 连接测试通过后会立即安全保存当前服务商、模型和 Key，并刷新首页配置状态；过去日志详情新增“生成这一天的反馈”，复用现有按日期聚合分析能力，无需复制日志或进入新页面。

## [2026-08-13 18:09] [修复] 恢复周期复盘材料预览与生成 (v1.22.0 -> v1.22.1)

- **受影响文件**: `apps/zhiji-desktop/src/shared/schemas/ipc.ts`、桌面 API 与 IPC handler、周期复盘测试、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 修复带日期范围校验的 Zod Schema 被运行时 `.omit()` / `.required()` 变形而导致周报、月报、项目复盘无法预览或生成的问题；改用预览与生成两个显式契约，并统一覆盖三种复盘类型。

## [2026-08-13 17:42] [功能] 补齐日志完整性与历史补写闭环 (v1.21.0 -> v1.22.0)

- **受影响文件**: `apps/zhiji-desktop/src/`、客户端测试、`apps/zhiji-desktop/README.md`、`VERSION`、`PROJECT_STATUS.md`
- **改动摘要**: 同日多条日志改为独立文件且不再互相覆盖；用户可选择今天或过去日期补写，并从历史中显式编辑指定记录。旧日期文件保持可读，更新带并发冲突保护；日反馈按当天全部日志和来源版本判断新鲜度，项目复盘材料收紧为项目与日期交集，备份拒绝重复日志 ID。

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
## [2026-08-20] [配置] 本地飞书日反馈入口弃案并保留恢复实现 (v1.27.1 -> v1.27.2)

- **受影响文件**: `.claude/workflows/local-feishu-daily-feedback.ps1`、用户版镜像、入口说明、`README.md`、`PROJECT_STATUS.md`、`VERSION`
- **改动摘要**: 因本地前台监听、Codex 额度依赖和固定前缀路由造成的实际使用摩擦，日常飞书交互改由 WorkBuddy 工作区代理承担。原实现、配置示例、测试和验收记录均保留；仅将三个入口工作流的 `-Mode Run` 监听启动调用注释为“弃案”，误启动会明确提示而不会消费事件或额度。恢复前须重新验证额度、事件连接与路由体验。
