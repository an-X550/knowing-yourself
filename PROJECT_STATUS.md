---
created: 2026-07-05
last_updated: 2026-08-22
---

# PROJECT_STATUS - 知己

**当前版本**：2.6.3

## 项目概述

**知己** 是面向中文个人日志的 AI 复盘系统，把日记、复盘与长期方向校准收敛为可验证的行动闭环。

- 高频闭环：日志粘贴 -> 日反馈 -> 次日验证
- 低频校准：周/月/项目/年复盘 -> 方向异常提醒 -> 人生设计升级

## 技术栈

| 层面 | 选型 |
|------|------|
| 运行平台 | Codex 自然语言入口；Claude 命令兼容；WorkBuddy 飞书入口；Electron Windows 客户端 |
| 内容格式 | Markdown + YAML frontmatter |
| 核心入口 | 自然语言 + 兼容 Slash Commands |
| 共享契约 | `.claude/shared/` |
| 配置与版本 | JSON；Git + 语义化版本 |

## 架构设计

```text
命令层 -> 用户入口与流程编排
代理层 -> 日志读取、分析执行、综合输出
视角层 -> 分析框架、评分标准、输出边界
```

`.claude/` 是唯一运行真相；`zhiji-user/` 是用户版分发包，`packaging/zhiji-user-overlay/` 是其变体定义源。README 负责入口，本文档只记录当前事实，CHANGELOG 记录发布历史，AGENTS/CLAUDE 定义执行规范。

## 当前进度

| 项目 | 状态 | 当前能力或证据缺口 |
|------|------|------|
| Agent 打包启动兼容性 | 已修复 | Forge 生产 asar 已保留外置 DSH 运行时及其 peer-only 依赖，包括 `zod`、`@standard-schema/spec` 与 `@deepseek-ai/dsh-timeout` 等；v2.6.3 安装版启动与 Agent 新建会话 E2E 通过。Utility 启动错误现在保留有限、脱敏诊断，不再只显示“运行已停止”。 |
| 桌面端本地发布质量 | v2.6.3 核心验收完成；真实 DeepSeek 未验证 | 设置三标签、日志模板迁移、伪更新控件删除、侧栏/工作区滚动、暗色下拉框、AI 高级设置分层和日反馈一次结构重试已落地；`npm test` 53 files / 324 tests、`npm run typecheck` 通过、`npm run lint` 0 errors / 6 个既有 warnings、打包版 `npm run test:e2e` 5 passed / 1 skipped、安装版 v2.6.3 E2E 4 passed / 1 skipped、ASCII 根 junction 下 `npm run make` 退出 0。版本独立 RC 位于 `apps/zhiji-desktop/out/release-candidate/v2.6.3/`，v2.6.2 RC 保留；没有安全可用配置，真实 DeepSeek 冒烟待用户在应用内完成。 |
| 日反馈闭环 | 已完成 | 日志粘贴与 `/daily-review` 统一进入 `daily-analyzer`；输出按单洞察、单行动、可观察预测收敛，输入不足按 A-D 证据等级降级。 |
| 本地飞书日反馈入口 | 弃案；实现保留、监听已注释 | 2026-08-20 因本地前台监听、Codex 额度依赖和前缀路由带来的使用摩擦，改由 WorkBuddy 工作区代理承担飞书交互。主工作流及用户版镜像保留，`-Mode Run` 的监听启动调用已注释并显示弃案提示；恢复前需重新验证额度、事件连接与路由体验。 |
| WorkBuddy 多通道运行入口 | 每日日志默认分发已通过脱敏真实验收；已加入快路径约束 | `[知己]` 已真实触发绝对路径入口：原文、每日反馈和验证沉淀完成写入与复读后，飞书使用既有 `lark_cli_path` 成功导入在线文档，滴答只通过唯一的 `dida365_create_task` 创建 1 项任务，两个渠道状态独立写入既有幂等文件。本地权威产物固定为 UTF-8 Markdown；飞书在线文档只是导入副本。首次实测约 8 分钟主要耗在 WorkBuddy 的路径、配置和状态探索，现已加入直接路径、最小并行读取与禁止探索性调用的快路径约束，待下一次脱敏日志复测耗时。用户决定不再重复两次外部人工写入；同内容防重与单次“仅本地”退出继续由已通过的自动化回归覆盖。WorkBuddy `disabledTools` 仍禁用滴答其余 49 个工具，不回退 Codex。周复盘和主题路由尚未做真实验收。实现规格见 [`workbuddy-feishu-runtime-entry`](docs/specs/2026-08-20-workbuddy-feishu-runtime-entry.md)。 |
| 日志质量教练 | 已完成 | `journal-quality-coach` 独立评估分析就绪度与六个中立写作观察点；不以外部课程、固定模板或分享行为作为质量门。 |
| 周/月/项目复盘 | 已完成真实验收 | 统一复盘六问；按会改变判断、重来选择或行动的内容自适应展开，保留证据、边界、项目锚点与行动质量门。Codex 可直接理解三类自然语言请求，Claude slash command 保持兼容。 |
| 闭环缺口检查与提醒 | 语义检查已完成；滴答通知待首次真实验证 | Codex 的“下一步、遗漏、更新、复盘”语义继续进入统一检查。一次性与周期性纯提醒默认由滴答原生通知承担，只通知用户手动开始；Codex 定时派发经受控测试和完整重启后仍未送达，不再作为默认通道。已创建每周日 19:00（`Asia/Shanghai`）周复盘滴答任务，首次真实通知待 2026-08-16 验证。 |
| 可选结果分发 | 四来源滴答最小适配可正式使用 | `ticktick_adaptation: ready_for_formal_use`。飞书历史 60 项已按人工确认完成同步；滴答只处理每日反馈、周复盘、月复盘和已确认主题思考，任务仅含 SMART 化标题与截止时间。自动化端到端模拟覆盖四来源、确认门、防重、旧状态、失败重试、仅本地和日志完成判断；官方 MCP 冒烟测试已在现有“知己行动”清单成功创建一项脱敏任务。正式运行使用设置阶段保存的清单 `project_id`，不读取或更新远端任务，不做后台重试、模糊去重或复杂调度。 |
| 低频人生设计 | 已完成 | `/life-design` 是独立方向校准入口；年度链路仍待更多月报样本完成端到端验证。 |
| 运行快路径 | 已完成 | 日反馈优先复用已有反馈；复盘优先消费沉淀物和证据包，仅在冲突或引用缺失时扩大读取范围。 |
| 用户版分发与边界 | 已完成 WorkBuddy 入口同步；真实用户部署待验收 | overlay、manifest、导出链路、Codex 日志路由、Windows Stop Hook、年度目录和分发边界测试已具备。用户版现包含与主项目逐字一致的 WorkBuddy 多通道入口，以及可由 AI 执行、但保留人类授权的 WorkBuddy/飞书智能体/飞书云文档/滴答 MCP 部署说明；不包含维护者的 open_id、目录 token、清单 ID、凭证、状态或个人远程偏好。仍需真实用户按说明完成一次脱敏部署验收。 |
| 用户版浏览入口 | 已完成 | `zhiji-user/` 的 `index.html`、`guide.html` 与 `setup.html` 由 overlay 和 manifest 受控导出，分别面向首次了解、完整使用说明与 WorkBuddy 飞书智能体/飞书云文档/滴答设置；HTML 只承担离线阅读与导航，Markdown 保留技术细节。 |
| Windows 桌面客户端 | 核心 Skill 用户闭环、日志完整性、复盘能力和 Agent 会话数据生命周期已完成；2026-08-14 全面审计优化（P0+P1）已落地；目标用户理解测试和安装矩阵待人工验收 | 一级导航为开始、Agent、日志、复盘、项目、设置；桌面端不再承载主题思考。桌面端不运行 Claude Skill/Agent，而由 Main Process 通过受校验的结构化契约实现同等复盘行为：每日反馈现按 Skill 的昨日闭环、单一盲点、可选历史连接、单一原子行动与认知追踪格式确定性排版；日志质量检查按 A-D 分析就绪度、六步法、重复模式和一项改进输出。反馈与复盘在前端安全渲染标题、引用、列表和表格，不再裸显 Markdown 符号或执行原始 HTML。个人背景仅在用户明确开启后注入 AI；数据目录、可验证备份、安全 IPC 和 OpenAI 兼容接口保持不变。2026-08-14 审计优化落地：首页意图路由整体删除（用户拍板）；全部用户可见错误中文化、网络层加固；契约类型归位 shared 与返回类型命名化；新鲜度逻辑抽 shared 去重；五个未使用依赖与 react-query 死接线移除；D1-D6 漂移点全部登记入兼容矩阵与契约对照表。阶段 C 的 Agent 正式工作流仍复用既有日志、每日反馈、周/月复盘和洞察服务；阶段 D1 新增官方 DSH JSONL 会话持久化、重启列表/resume、数据目录迁移和备份损坏校验，不改变专业页面职责。v1.28.1 修复生产 asar 的 DSH 依赖与 Utility Process 启动链；v1.28.2 在 Agent 遇到 API Key 缺失时提供直达设置页的恢复入口；v2.0.0 按第一性原理移除主题思考桌面入口及其运行时接入，历史主题数据不删除，Skill/CLI 侧能力不变；v2.0.1 在 safeStorage 密文失配时保留数据并让设置页恢复，不再阻断本地日志与复盘页面；v2.0.2 更新 DeepSeek V4 模型默认值、迁移旧模型并将连接测试改为非流式短请求；v2.0.3 修复 Agent 工具名不符合 DeepSeek API 约束，DeepSeek Agent 关闭思考模式以避免桥接协议缺少 `reasoning_content`；v2.0.4 修复 Agent 对相对日期的错误回答，增加明确确认后的会话回收站删除，并支持 Enter 发送、Shift+Enter 换行。验收门：`npm test` 51 files / 293 tests、`npm run typecheck`、`npm run lint` 0 error / 6 既有 warning、`npm run package` 和打包后 `npm run test:e2e` 1 passed；独立假说台账、关闭窗口草稿保护、合并恢复、安装/升级/卸载和 Windows 10 仍未实现或验证。 |
| Agent 输出质量与上下文 | v2.4.0 已完成最小高性价比闭环；真实模型质量 A/B 与安装矩阵仍待人工验收 | Agent 使用 `react-markdown@10.1.0` + `remark-gfm@4.0.1` 渲染合法 Markdown，persona 要求标题、列表、表格、引用、代码块使用真实换行；raw HTML 不执行。DeepSeek Agent 支持 thinking 开启/关闭、reasoning 流和工具回合重放，Agent 页显示 provider/model/thinking，API Key 仍只在 Main Process。官方 `dsh-token-meter`、`dsh-compaction-basic`、`dsh-compaction-tool-result-pruner` 均以 `0.1.0-rc.8` 接入当前 Utility runtime，保留 JSONL 会话与工具桥；不整体替换为 Pi runtime、不自研压缩、不强制普通回复 JSON。自动验收：`npm test` 52 files / 296 tests、`npm run typecheck`、`npm run lint` 0 error / 6 既有 warning、`npm run package` 通过。 |
| Agent 受控联网 | 已修复；真实模型工具回合待人工验收 | 现有 `web.search` 在 Main Process 使用 Electron 官方 `net.fetch`，复用 Chromium 网络栈及 Windows 系统代理/WPAD/HTTPS 隧道能力；保留搜索会话来源绑定和 Main Process 网络边界。Node `fetch` 对 DuckDuckGo 的本机连接超时已用 Electron 网络栈替换；打包 Main Process 对 DuckDuckGo 与 Open-Meteo 的联网冒烟均返回 HTTP 200，既有打包 E2E 通过；未新增搜索供应商、天气专用工具或额外 API Key。分析与执行规划见 [`agent-web-connectivity-analysis-and-plan`](docs/2026-08-22-agent-web-connectivity-analysis-and-plan.md)。 |
| Agent 本地历史检索与能力自述 | v2.6.1 已完成中文召回、当前回合证据卡片与冲突规则修复 | Agent 会说明 DSH 上下文组件、Function Calling、有限多步工具规划和内部结构化校验的真实边界；`zhiji.memory.search` 现在以 MiniSearch 内存 BM25+、`Intl.Segmenter`/CJK 二元词片和最多 3 个受限候选查询复用日志、复盘和已确认验证模式仓储，返回有限脱敏原文摘录。Main Process 只把同一份已校验安全结果以当前回合证据事件发送到 Renderer；Agent 页按会话隔离，发送下一条消息时只清除目标会话上一回合证据，默认 3 条、最多 8 条并提供安全导航。DSH persona 明确要求发现冲突时列出双方、日志原文优先且证据不足不得编造裁决。它仍不是 RAG 或完整长期记忆；索引不持久化，不新增向量数据库、外部服务或自动写入。见 [`agent-capabilities-first-principles-analysis`](docs/2026-08-22-agent-capabilities-first-principles-analysis.md)、[`agent-memory-search`](docs/specs/2026-08-22-agent-memory-search.md)、[`agent-evidence-cards`](docs/specs/2026-08-22-agent-evidence-cards.md)。 |
| DeepSeek Harness Agent 升级 | 阶段 0、A、B、C、D1 已完成；阶段 E 已完成桌面主题范围清理，D2 不适用 | DSH `0.1.0-rc.8` 发布包在独立 Electron Utility Process 运行，Main Process 以 MessagePort 代理模型并独占 API Key。Agent 可通过 Main Process Zod 校验的高层工具读取脱敏日志/复盘/项目/验证模式、受控搜索与读源；阶段 C 已接入日志创建/更新、每日反馈及周期/洞察复盘的预览—页面确认—生成链路，阶段 D1 已接入官方 JSONL 会话持久化、重启后的列表与 `resume`，并纳入数据目录迁移、备份路径白名单和 DSH 事件校验。生产 asar 的 DSH 依赖和 Utility Process 启动链已修复；无 API Key 时 Agent 错误可直达设置页。正式结果以既有页面展示，不暴露路径、URL、Shell、任意文件或写入捷径。桌面端不再初始化主题服务或注册主题 DSH 工具；已有主题数据不主动删除，Skill/CLI 侧继续独立运行。接入面和验证证据见 [`dsh-integration-notes`](apps/zhiji-desktop/docs/dsh-integration-notes.md)。 |
| 知己 DSH 独立插件 | S4 本地发行准备已完成；不执行公开发布 | `apps/zhiji-dsh-plugin/` 使用一个官方 Bundle 入口，一次性注册四个 Skill 和 `zhiji_read_journal_range`；当前 package `0.3.1` 无运行时依赖、native dependency、install/prepare script 或桌面端依赖。S1/S2/S3 的 Runtime、边界、remove/restart 已通过；S4 额外通过 tarball 白名单、精确 DSH 兼容声明和仓库外临时目录安装/移除/restart。验证报告见 [`zhiji-dsh-plugin-s4-validation`](docs/reviews/2026-08-21-zhiji-dsh-plugin-s4-validation.md)。 |
| 质量基线 | 已完成 | 覆盖日反馈、周/月/项目/年度复盘、人生设计和用户版的组件边界；真实样本仍需持续补齐。 |
| 主题思考库 | 桌面端已移除；Skill/CLI 侧保留 | 桌面端不再提供主题页面、IPC、会话、仓储或 DSH 主题工具；用户已有 `topics/` 与旧 checkpoint 数据不删除、不主动迁移，继续讨论和沉淀使用 Skill/CLI 侧契约。 |
| 收藏吃灰库 | 已完成 | 用户明确收录时按标题、摘要、关键词、原文/摘录、链接五段式保存，并有主项目与用户版路由回归。 |
| 治理文档职责 | 已完成 | 默认上下文只保留入口与当前事实；文件改动时按需加载治理细则，历史决策独立归档。 |

## 待办事项

当前仍有引用价值的实现规格：[`audit-cleanup`](docs/specs/audit-cleanup.md)、[`deepseek-harness-agent-architecture`](docs/specs/2026-08-20-deepseek-harness-agent-architecture.md)、[`zhiji-dsh-plugin-architecture`](docs/specs/2026-08-21-zhiji-dsh-plugin-architecture.md)、[`directory-boundary-tightening`](docs/specs/directory-boundary-tightening.md)、[`evolution-roadmap`](docs/specs/evolution-roadmap.md)、[`git-commit-escalation-flow`](docs/specs/git-commit-escalation-flow.md)、[`monthly-perspective-audit`](docs/specs/monthly-perspective-audit-2026-07-08.md)、[`monthly-processor-evidence-packets`](docs/specs/monthly-processor-evidence-packets.md)、[`monthly-synthesis-theme-compression`](docs/specs/monthly-synthesis-theme-compression.md)、[`workbuddy-feishu-runtime-entry`](docs/specs/2026-08-20-workbuddy-feishu-runtime-entry.md)、[`agent-memory-search`](docs/specs/2026-08-22-agent-memory-search.md)、[`desktop-release-quality-and-settings-ux`](docs/specs/2026-08-22-desktop-release-quality-and-settings-ux.md)。

### 高优先级

- [x] 按 [`desktop-release-quality-and-settings-ux`](docs/specs/2026-08-22-desktop-release-quality-and-settings-ux.md) 与 [`execution-plan`](docs/2026-08-22-desktop-release-quality-and-settings-ux-execution-plan.md) 完成桌面端本地发布质量修复：设置三标签、日志模板入口迁移、伪更新控件删除、侧栏固定、暗色下拉框、日反馈一次结构重试、DSH 生产 peer-only 依赖和版本独立 RC 均已验证。GitHub `v2.0.5` 仍不覆盖，远程核对与发布需单独授权。
- [x] 按 DeepSeek Harness Agent 架构完成阶段 0/A/B/C/D1/E：Utility Process、DSH 会话桥、模型传输、Agent 页面、日志/复盘只读与正式工作流工具、JSONL 会话持久化、重启 resume、备份生命周期和桌面主题范围清理均已实现；日志与复盘主链路保留。
- [x] 阶段 D2 取消：主题思考不是桌面端复盘核心闭环；桌面端主题入口及运行时已删除，已有主题数据不主动删除，Skill/CLI 侧能力不受影响。
- [x] v2.0.1 凭据恢复：safeStorage 无法解开旧密文时不再阻断 `settings:get` 和本地数据加载；凭据文件保留，设置页重新保存 API Key 后恢复当前密钥环。
- [x] v2.0.2 DeepSeek 连接恢复：默认模型切换为 `deepseek-v4-flash`，已保存的 `deepseek-chat` / `deepseek-reasoner` 自动迁移；测试连接不再走流式生成链路。
- [x] v2.0.3 Agent 连接恢复：DeepSeek 工具函数名在 API 边界转换为合法格式并映射回 DSH 内部名称；Agent 使用非思考模式，避免工具回合缺少 `reasoning_content`。
- [x] v2.0.4 Agent 可用性恢复：每轮请求注入桌面端真实日期；会话可在确认后移入系统回收站；Enter 发送、Shift+Enter 换行。
- [x] v2.0.4 打包版真实可用性验收：当前 API Key 可用；Enter 提问“今天星期几”得到本机正确星期；只读日志查询返回真实摘要；验收会话确认删除后进入回收站，重启不恢复，既有日志与复盘未改动。
- [x] v2.4.0 Agent 输出与上下文最小闭环：成熟 Markdown/GFM 渲染、格式 persona、DeepSeek thinking 开关与 reasoning/tool replay、provider/model/thinking 可见性，以及官方 DSH token meter/compaction/tool-result pruner 接入均已通过自动回归和桌面打包验证；不新增自研压缩、自由回复 JSON、hash、baseline 或质量 gate。
- [x] v2.5.0 Agent 能力边界与本地历史检索：能力自述与十项能力裁决已按第一性原理收敛；新增只读 `zhiji.memory.search` 字符串/词法检索入口，结果经过 Zod、Main Process 脱敏和 DSH 工具桥；不把现状称为 RAG，不新增 MCP、向量数据库、Computer Use 或递归自改。
- [x] v2.6.0 Agent 中文历史检索与证据卡片：MiniSearch 内存 BM25+、`Intl.Segmenter`、CJK 二元词片和至多 3 个受限候选查询已修复自然中文复合/有限同义召回；Main Process 已校验命中结果以当前回合只读卡片展示，默认 3 条、最多 8 条。索引不持久化，不新增向量 RAG、MCP、多模态或权限；覆盖复合/同义、噪声、排序、真实摘录、契约兼容、空结果、会话隔离和安全导航（见 [`agent-evidence-cards`](docs/specs/2026-08-22-agent-evidence-cards.md)、[`execution-plan`](docs/2026-08-22-agent-evidence-cards-execution-plan.md) 与 [`execution-prompt`](docs/2026-08-22-agent-retrieval-evidence-execution-prompt.md)）。
- [x] v2.6.1 Agent 证据生命周期与冲突规则修复：发送下一条消息时只清除当前会话上一回合的证据组，其他会话和新回合证据不受影响；DSH persona 明确要求列出冲突双方、以日志原文作为事实最高依据、不得让复盘或模式静默覆盖日志，证据不足时不得编造裁决。普通测试固定页面会话隔离/逐回合清理/3 条默认与 8 条上限，以及真实 DSH Runtime 系统规则；不修改 DSH JSONL、检索排序、持久化索引或安全边界。
- [x] v2.6.2 桌面端本地发布质量：设置三标签与日志模板管理、布局/暗色下拉修复、日反馈结构化失败的一次安全重试和安装包 DSH peer-only 依赖补齐均已落地；53 files / 317 tests、typecheck、lint、5 项打包 E2E、Squirrel RC 生成和安装版启动烟测通过。失败模型输出不回显，不新增 hash、baseline 或质量 gate。
- [x] v2.6.3 验收修订：普通 AI 路径只保留“保存并测试”，`仅保存` 与 `移除已保存 Key` 下沉到 AI 高级设置；结构化日反馈覆盖截断/Schema/非结构错误/取消边界；安装版结构化恢复明确 skip，新增真实 Agent 新建会话和日志/模板/本地保存/暗色/滚动冒烟；v2.6.3 RC 已安装验收，v2.6.2 RC 保留。截图、宽度/DPI 矩阵和像素 baseline 按用户要求取消。
- [x] S0 知己 DSH 独立插件路线定稿：桌面端不再平台化；旧 P1-P4 取消，P0 证据保留；新架构和 S0-S4 执行计划明确直接使用 DSH Web UI，不建设同步工具或跨项目源码同构门禁。
- [x] S1 每日复盘 Bundle MVP：官方 Profile add、Skill 加载、固定日志 keyless Runtime、remove 与移除后重启均通过；真实模型/用户价值仍待观察（见 [`zhiji-dsh-plugin-s1-validation`](docs/reviews/2026-08-21-zhiji-dsh-plugin-s1-validation.md)）。
- [x] S2 周/月/项目复盘：四种 DSH Skill、代表性材料、输入不足降级、输出差异、S1 回归和官方 remove/restart 均通过；后续 S3/S4 已按用户明确决定完成（见 [`zhiji-dsh-plugin-s2-validation`](docs/reviews/2026-08-21-zhiji-dsh-plugin-s2-validation.md)）。
- [x] S3 显式日志根目录只读聚合：`zhiji_read_journal_range` 的 Markdown、日期范围、路径边界和失败行为测试通过；周/月/项目 Tool 回合、S1/S2 回归、官方 remove/restart 均通过（见 [`zhiji-dsh-plugin-s3-validation`](docs/reviews/2026-08-21-zhiji-dsh-plugin-s3-validation.md)）。
- [x] S4 本地发行准备：`zhiji-dsh-plugin@0.3.1` 的 metadata、兼容版本、tarball 白名单、仓库外官方安装、remove 和 restart 均通过；未执行 npm publish、GitHub Release、远程 push 或外部市场提交（见 [`zhiji-dsh-plugin-s4-validation`](docs/reviews/2026-08-21-zhiji-dsh-plugin-s4-validation.md)）。
- [ ] 连续运行至少 5 次真实 `/daily-review`，验证 `verified-patterns.md` 写回质量。
- [ ] 完成至少 3 次真实闭环缺口检查，记录建议是否可执行、是否被忽略为噪声、是否漏掉必要动作；未出现重复证据前不调整阈值或增加类别。
- [ ] 以真实样本观察周/月/项目复盘；仅在出现可复现的重复、证据缺口或行动不可检查时修复。
- [ ] 跑完一次真实 `/life-design --quick`。
- [ ] 用 `zhiji-user/` 完成一次用户视角干运行，并发给 3–5 位目标用户试用。
- [ ] 在隔离或可回退环境完成 Windows 11 安装、升级、卸载且保留数据的人工矩阵；再补 Windows 10 干净虚拟机验收，未运行前不标记通过。
- [ ] 邀请 3–5 位不使用 CLI 的目标用户做 10 秒理解测试：能否指出如何开始写日志、生成今日反馈、找到周复盘和确认数据位置；未完成前不声称易用性已被真实用户验证。
- [ ] 按 `packaging/zhiji-user-boundaries.json` 与质量矩阵补真实素材验收；只收敛已有证据支持的 shared 文件。
- [ ] 2026-08-16 19:00 验证滴答周复盘任务首次真实通知；创建成功不等于通知送达，未验证前不增加其他复盘提醒。
- [x] 本地飞书日反馈入口验证已停止（2026-08-20 弃案）：保留实现与验收记录，不继续观察 14 天或扩展该入口。
- [x] 用一份脱敏单日日志完成 WorkBuddy 飞书入口首次人工验收：原文、每日反馈和验证沉淀写入并复读成功，飞书文档与滴答单任务默认分发成功。
- [ ] 验证 WorkBuddy 周复盘与 Skill/CLI 主题首次讨论、确认沉淀的真实写入边界（不属于桌面端运行时）。

### 中优先级

- [x] R2 证据分级分歧已修复（v1.24.5）：正则判 D 时经 D 级语义复核（至多一次短调用），确认本人经历保守升 C，失败回落原 D；A/B/C 级差登记为已知差异；金样本 10 条回归（见 `docs/2026-08-14-r2-grading-fix-task-brief.md`）。
- [x] 桌面端月报深度已实现（v1.24.6，阶段 B）：主主题归并（五要素）、下月规划目标+手段+检查点+假说、触发条件满足时输出指向复盘页方向校准的升级提醒；主主题不足时代码强制披露不硬凑；周报/项目复盘零变化。
- [x] 洞察三链路契约审计完成（v1.24.7，阶段 C）：coach/yearly/life-design 无结构漂移；4 项判据漂移已修（coach 六步法命名与方向信号判据→`journal-coach-v3`、yearly 升级提醒→`yearly-review-v2`、life-design 下次如何验证→`life-design-v2`）；4 项设计性差异与 1 项已知差异登记不修（报告见 `docs/2026-08-14-insight-contract-audit.md`）。
- [x] 桌面端全面审计优化完成（v1.25.0）：S1 意图路由删除、S2/S4 错误中文化与网络加固、S3 主题思考 v2、S5 契约类型归位、S6 新鲜度去重、S7 依赖清理、S8 台账登记（D1-D6）全部落地；P2（B2 IPC 错误结构化、C5 e2e 补测、F5/F4）与 D2 消费规则实现延后（见 `docs/2026-08-14-desktop-optimization-plan.md` 非目标）。
- [x] 桌面端后端清理（v1.26.2，spec 阶段 4）：ProviderPort/fenced-JSON/预览令牌归一，3 个死代码文件删除，15 处裸 Error→AppError + CANCELLED 错误码，AI 60s 超时与取消误报修复，project/pattern 仓储写队列，IPC model 注入样板下沉。e2e 与视觉走查仍待人工。
- [ ] 用真实非模板日志补周报、项目复盘示例。
- [ ] 为 `/yearly-review` 准备足够月报样本。

### 低优先级

- [ ] 在真实需求出现前，暂缓 CSV 导出、自动化回归扩张和国际化。

## 已知问题

1. 输入与输出目录仍使用中文名称，部分 Windows/CI 环境可能有编码或路径兼容性问题。
2. 日志常按“单文件包整月”存储，增加解析复杂度。
3. `/yearly-review` 依赖链条长，尚缺足够端到端验证。
4. 样本仍偏单用户和真实个人语境，迁移到其他用户前需校准提示语和示例。
5. overlay 仍有已声明理由的 override，后续只在有收益证据时收敛为 byte-identical shared 文件。
6. 没有“日志 / 日记 / 记录一下”等意图的自由文本无法仅靠 Hook 安全区分普通对话，当前会先确认一次再存档。
7. 本地飞书入口为弃案：实现仍保留但监听已注释；历史上依赖 Windows、网络、前台监听和 Codex 额度，且通常需 2–5 分钟，不提供离线补偿。
8. Windows 客户端当前安装包未签名，首次安装可能出现 SmartScreen 提示；v2.6.3 已用隔离临时数据根完成安装版核心冒烟和 Agent 新建会话验证，但尚未完整验证升级、卸载与 Windows 10 兼容性。
9. WorkBuddy 每日日志默认分发已通过一次脱敏真实消息验收；周复盘、主题讨论与确认沉淀仍只有静态边界测试，尚未真实验收。
10. 非法或缺少块边界的单行 Markdown（如 `###`、`---`、`|` 被模型挤在同一行）无法由成熟 Markdown 解析器可靠猜测意图；本轮不做启发式修复，后续先观察真实样本再决定是否值得单独立项。
11. DeepSeek V4/Pro 的官方上下文容量已纳入 compaction 路由；未知模型或自定义 provider 不猜测上下文窗口，因此不会伪造压缩容量。真实超长会话摘要触发和 Flash thinking 关闭/开启质量差异仍待受控样本。
12. 源码、免安装包、Squirrel 制品与版本独立 RC 已统一为 `2.6.3`：根 `VERSION`、`PROJECT_STATUS.md`、Electron `apps/zhiji-desktop/package.json`、应用锁文件、当前 `out/知己-win32-x64` 和 `out/release-candidate/v2.6.3/` 一致；旧 `out/release-candidate/v2.6.2/` 保留，后续分发只使用已安装验收的 v2.6.3 RC 三件套。
13. 两个事故分开记录：事故 A 是 v2.6.2 production asar 缺少 DSH peer-only 运行依赖导致 `ERR_MODULE_NOT_FOUND`，依赖已补齐且 v2.6.3 安装版 Agent 新建会话通过；事故 B 是 GitHub `v2.0.5` 用户报告的每日反馈格式失败，本地 JSON 校验/分类/一次重试已实现并覆盖回归，但尚未用同一服务商、模型、输入和远程资产做复核，原始远端根因仍未确认。

## 关键决策记录

2026-07-15 之前的历史决策见 [`project-status-decisions-through-2026-07-15.md`](docs/archive/project-status-decisions-through-2026-07-15.md)。

| 日期 | 决策 | 理由 |
|------|------|------|
| 2026-08-22 | 桌面端先修本地安装包质量与设置页信息架构，GitHub 远程后置 | 用户真实分发的 `v2.0.5` 暴露核心闭环和 UI 问题，而开发模式成功不能代表安装包可用；本轮以全新安装包为完成标准，设置页收敛为三标签，删除伪更新控件，日反馈只补一次结构重试，并让每个版本产生独立 RC。Pi、Hermes Memory、Reasonix Context Engine 和 MCP 不能直接解决当前事故，不接入；远程旧 Release 不覆盖，后续只上传本地已验收的同一份新版本制品。 |
| 2026-08-22 | 桌面 Agent 先修中文词法召回，再增加本地证据卡片 | 当前连续中文被当成长词项，存在自然查询零命中的确定性失败；只做卡片会更清楚地展示空结果。先复用 MiniSearch BM25+ 与 `Intl.Segmenter`/CJK 词片，有限同义由受限 Tool Call 候选处理，再展示 Main Process 已校验证据。索引不持久化，不新增向量 RAG、MCP、多模态、Computer Use、递归自改或卡片持久化。 |
| 2026-08-22 | 当前回合证据按发送边界清理，冲突裁决由 DSH persona 明确约束 | 已确认的事故是上一回合证据在同一会话继续显示，且检索同时返回日志/复盘时运行规则未要求指出冲突；最小修复是 Renderer 发送消息时只删除目标会话运行态证据组，并在真实 DSH Runtime 系统规则中声明日志原文优先、冲突显式披露和证据不足不编造。普通测试足以验证这两个行为，不新增 hash、baseline、gate、排序器或持久化机制。 |
| 2026-08-22 | DSH peer-only 运行包必须声明为桌面端生产依赖 | 安装版真实启动暴露 `@deepseek-ai/dsh-timeout` 缺少的 `ERR_MODULE_NOT_FOUND`；开发模式和普通测试不会经过生产 asar 的依赖裁剪。将 DSH 外置包实际需要的 peer-only 运行包声明为直接 production dependencies，保留既有 asar 外置规则和 Fuses，不新增 hash、baseline 或 gate。 |
| 2026-08-22 | 分离安装事故 A 与 GitHub 日反馈事故 B 的根因结论 | A 已有生产 asar 缺依赖和 v2.6.3 安装版 Agent 新建会话证据；B 只有用户报告与本地实现/回归，缺少同服务商、模型、输入和远程资产对照，因此只能标记“原始根因未确认”，不能把本地修复冒充为远程根因证明。 |
| 2026-08-22 | 本轮验收收敛为核心功能冒烟 | 用户取消手工截图、900px/常用宽度/宽屏、100%/125%/150% DPI、像素比较和继续风格调整；保留自动行为测试、安装版 Agent/日志/模板/本地保存/暗色/滚动验证，不新增 baseline、hash、冻结 contract 或独立 gate。 |
| 2026-07-15 | 显式第一性原理请求采用共享复核契约而非新命令 | 用户在发现内容过长或结论可疑时已主动使用该表述；用短契约覆盖默认表达深度，不改变入口、路径或报告骨架。 |
| 2026-08-01 | 确认后的主题更新先重组当前论证 | 仅要求比较与合并仍会诱发机械追加；新认知先分类其对当前判断的影响，再重组受影响章节并检查依据、去重、边界与行动/转向，不限制篇幅，也不增加用户成本。 |
| 2026-07-19 | 主题思考采用默认审查、合并更新与自适应行动门槛 | 新信息会长期追加；创建和更新都比较旧内容，以保留、修正、替换、合并、归档或不写入收敛重复、冲突和失效行动；只有会改变判断、行动或验证时才展开。 |
| 2026-07-31 | 主题首稿与确认沉淀分离 | 首稿只读取问题、依据、判断和下一步；0–6、维护与全量审查只在用户确认沉淀后读取，继续讨论只在会改变当前判断时可选。 |
| 2026-07-31 | Codex 以自然语言直达周/月/项目复盘 | 用户实际在 Codex 中工作；以单一共享路由复用 `.claude/` 综合定义，保留 Claude slash command 兼容，未增加默认调用或读取范围。 |
| 2026-08-01 | 复盘时机检查采用语义入口与手动触发 | 固定口令会增加记忆负担，后台自动化也缺少稳定收益证据；以自然语言意图和无参数 `/review` 统一接入既有检查器，只提供一条可执行建议，保留用户决定权。 |
| 2026-08-01 | 闭环缺口检查以新增证据而非文件年龄判断 | 仅用 `last_updated` 会制造无效催办；日反馈缺口、周期报告、current 实质变化和日志质量抽样都必须同时满足新增材料与下游沉淀缺失，且统一只输出一条手动建议。 |
| 2026-08-01 | 语义化缺口检查须由 Codex 入口显式触达 | 仅在共享契约中定义规则不能保证普通“下一步/遗漏”提问会读取它；入口规范必须声明该语义路由。current 判断只接受最近的新反馈晚于其 last_updated，避免把旧文件日期本身当作提醒理由。 |
| 2026-08-01 | 提醒绑定成功日反馈而非后台计时 | 主动提醒必须独立于用户记忆，但纯定时会制造噪声；因此只在新日反馈和验证沉淀完成后检查一次，并以可丢弃状态对同一候选执行 7 天冷却。 |
| 2026-08-12 | 纯提醒默认使用滴答清单原生通知 | 用户需要的是可靠地被提醒后手动决定是否复盘；Codex 定时派发在多轮受控测试与重启后仍未送达，滴答已成功返回原生时间、提醒和周重复字段。一次性与周期性纯提醒统一走滴答，只有用户明确指定时才例外；自动执行请求另行评估。 |
| 2026-08-12 | 先用本地飞书私聊验证每日反馈使用频率 | 当前真实摩擦只集中在每天打开电脑和 Agent；复用现有飞书 bot、Codex 登录与日反馈契约，以本人 open_id、固定 `日志：` 前缀和 message_id 防重提供手机入口。电脑离线即不可用，先观察 14 天，不开发云服务、队列、多用户或周/月入口。 |
| 2026-08-20 | 主题思考先做高性价比安全加固，不强行 DSH 迁移 | 主题思考的核心价值是讨论后由用户确认并沉淀可回看的认识；现有独立页面已完成该闭环。DSH 目前没有同等的提案、差异和确认门，迁移会复制流程并增加数据风险，因此先让提案携带主题版本、确认时做条件写入；只有真实证据证明 Agent 连续会话降低摩擦，才重新评估 D2。 |
| 2026-08-12 | 个人部署文档按稳定边界而非具体 AI 产品组织 | 飞书事件、本地落盘、飞书导入和滴答创建无需模型自由决策；只把“日志到反馈正文”定义为可替换 AI 适配器。当前继续用本地 Windows、VPN 和 UU 远程，达到 14 天使用门后才评估云服务器。 |
| 2026-08-12 | 用户版同步运行能力但不复制个人环境 | 分发版需要能执行同等手机日反馈链路，因此共享监听工作流和配置 schema；平台身份、远端目录、滴答清单和 AI 凭证必须由用户独立授权。Claude/DeepSeek 通过相同 stdin/stdout 分析适配器接入，不重写确定性分发。 |
| 2026-08-13 | Windows 客户端采用本地优先 Electron 模块化单体 | 普通用户需要脱离 CLI/Skill 的低摩擦入口，同时现有 `.claude/` 必须保持唯一运行真相；Renderer、Preload、Main Process 分层既能提供可视化产品，也能展示安全 IPC、本地 Markdown、OpenAI 兼容接口、可验证备份与 E2E 等前端/全栈工程能力。 |
| 2026-08-14 | 桌面周期复盘与 Skill 契约同构，质量门由代码强制而非提示词自觉 | 审计确认桌面端输出结构缺六问标题与方向锚点缺席检查；补齐同构后用 `applyPeriodicQualityGates` 确定性注入降级标注，避免依赖模型自觉；月报主主题归并因 `/life-design` 不在桌面端而延后。 |
| 2026-08-14 | R2 证据分级出现实际分歧则另行立项而非顺手修正 | 对照发现分歧 3/5 且含 D 级误熔断，说明正则判据与语义判据不同构；修复需新样本回归与 TDD，属独立能力变更，不在对齐任务内顺手改代码。 |
| 2026-08-14 | D 级判级引入语义复核而非重写正则（用户拍板放行契约变更） | 冻结项“D 级降级不调用模型”改为“反馈生成不调用模型；判级阶段允许至多一次复核短调用”；复核确认本人经历只保守升 C，失败回落原 D，兼顾闭环修复与成本可控；A/B/C 精度对齐不修，登记为已知差异。 |
| 2026-08-14 | 洞察链路审计优先：只修判据漂移，设计性差异只登记 | coach/yearly/life-design 三链路无结构漂移；六步法命名、方向信号判据、升级提醒与“下次如何验证”属模型触发口径漂移，成本低的提示词修复即可；yearly <6 硬拦截、简洁输出、仅 quick 模式是桌面语境的有意取舍，登记进兼容矩阵与对照表防止误当缺失补齐。 |
| 2026-08-14 | 首页意图路由整体删除（用户拍板） | 首页已有建议下一步卡片、能力链接与侧边栏导航三种入口，意图框是第四种且唯一依赖模型；删除降低使用摩擦与维护面；Skill 侧 `codex-natural-language-routing` 契约（CLI 域）不受影响。 |
| 2026-08-14 | 审计漂移点以登记为先、实现另过闸门 | D1 双轨数据、D3 月报标题、D4 视角层、D2 消费规则均为有意或已知差异，登记入兼容矩阵/对照表即可；D2 若实现需另过必要性闸门与金样本验证；台账登记遗漏本身通过“不同构必登记一行”机制防范。 |
| 2026-08-14 | 桌面重设计采用自研苹果设计令牌而非引入 Tailwind/组件库 | 86 个源文件已有 BEM 雏形，苹果感来自层级、留白与动效纪律而非框架；迁移风险大于收益；SF Pro 有许可限制，用 Windows 系统字体栈替代。 |
| 2026-08-14 | AI 流式只落在主题讨论，复盘生成改用真实阶段进度 | 日反馈/周期复盘走 JSON 结构化输出 + 确定性排版，逐字流式只会给用户看裸 JSON；主题讨论是自由文本，流式有真实价值；复盘等待用 ReviewTaskManager 阶段推送解决。 |
| 2026-08-20 | 禁用 Superpowers 自动工作流约束 | 当前项目已具备自身的开发规范与治理流程；保留既有 superpowers 文本为注释，避免其在后续开发任务中被自动触发，同时保留可恢复性。 |
| 2026-08-20 | 桌面端以 DSH 编排层升级为 Agent，现有知己内核继续掌握正式产物 | 用户目标是拥有能够连续理解、调用工具和多步执行的知己 Agent；最小替代不是恢复只负责跳转的意图路由。DSH 置于独立 Utility Process，现有 React 页面、领域服务、LangGraph、Schema、确认和本地安全边界继续保留；不采用 DSH Web UI，不给模型通用文件或 Shell 权限。 |
| 2026-08-20 | DSH 阶段 D1 先做会话生命周期，主题迁移延后 | 实际需要先解决的是 Agent 重启后不丢上下文、数据根迁移不漏文件、备份损坏可判定；官方 JSONL persistence 与 `AgentRegistry.resume` 已能直接满足。当前 DSH 工具尚未覆盖主题提案、差异展示和确认沉淀，强制迁移会破坏已有主题闭环，因此保留 `TopicSessionStore`，把主题迁移作为 D2，待同等确认语义和真实使用证据出现后再做。每日分析、周复盘、月复盘及专业页面不受影响。 |
| 2026-08-20 | 依据第一性原理移除桌面端主题思考 | 主题思考只是讨论后沉淀认识的辅助便利，不是复盘核心闭环；维护独立页面、会话、提案、确认和 DSH 工具的成本高于当前收益。因此删除桌面端主题入口与运行时链路，保留已有 `topics/` 与旧 checkpoint 数据，Skill/CLI 侧契约不变，D2 取消；日志、每日反馈、周/月复盘和项目链路保持不变。 |
| 2026-08-21 | 知己能力改为独立 DSH 插件发行，不把桌面端改造成插件平台 | P0 证明官方 Profile/Bundle/CLI 可复用，但桌面端开放任意 Host 插件会引入信任、打包和产品定位成本。新路线保持桌面端 React 与固定 Runtime 不变，把当前复盘能力转化为仓库外 Bundle 并直接使用 DSH Web UI；第一版只验证每日复盘，不建设市场、同步工具或两端源码同构门禁。 |
| 2026-08-21 | S1 采用 Skill-only 并保持 MVP | DSH 用户在会话中已经能明确粘贴单日日志；官方 Skill Registry、skill tool 和 `/zhiji-daily-review` 用户触发足以完成事实/推断区分、单一洞察、单一行动和验证。文件读取、跨日聚合和写入没有当前证据，增加 Host Tool 只会扩大宿主权限；先保留可安装、可运行、可移除的 Bundle，等待真实模型和使用证据后再决定 S2。 |
| 2026-08-21 | 用户明确覆盖 S1 的“保持 MVP”裁决，继续执行 S2-S4 | 用户已阅读并接受 S1 报告中缺少真实模型质量和连续使用证据的风险，明确要求依次实现周期/项目复盘、显式只读日志目录适配和本地发行准备；这一决定改变的是继续开发的取舍，不改变 S1 历史证据、安全边界或“没有真实模型效果证明”的事实。 |
| 2026-08-21 | S3 只增加一个显式根目录范围 Tool，不建设通用文件系统能力 | Skill 无法可靠读取用户外部 Markdown，重复粘贴是 S3 的明确输入摩擦；最小缺口是按日期范围只读聚合。Tool 不接受路径参数、不递归、不写入、不联网，周/月/项目仍由 Skill 负责判断，避免把每日复盘插件扩展成通用宿主工具框架。 |
| 2026-08-21 | S4 停在本地可发布 MVP，不执行公开发行 | 当前已能从仓外 tarball 通过官方 Profile 安装、识别、移除和重启；真实模型质量、连续用户价值和公开发布需求仍未验证，因此只补齐 metadata、包白名单和使用文档，不 publish、不建市场、不 push。 |
| 2026-08-22 | 桌面 Agent 采用成熟 Markdown/GFM 与官方 DSH 上下文组件，不替换为 Pi runtime | 截图的直接问题是合法 Markdown 的渲染与生成格式契约，`react-markdown`/`remark-gfm` 能以低成本修复可读性；Pi 的上下文变换、压缩条目、模型/thinking 交互只作为设计参考。当前 DSH 已有会话、工具、安全和确认边界，整体迁移会重复实现；官方 DSH compaction/token-meter/pruner 已能在现有 Utility 组合中接入，因此优先复用官方扩展。 |
