# 桌面端 Skill Runtime P1-P4 交付进度（已完成）

目标：完成受控 Skill Runtime（周期复盘、验证模式、主题思考/受控联网、意图路由），可测试、可打包、可维护。
顺序：任务0 基线 -> P0/P2 周期复盘完善 -> P1 验证模式 -> P3 主题思考/联网 -> P4 意图路由 -> 全量验证+聚焦提交。
最大风险：新增 IPC/UI 面破坏既有日反馈闭环；模型输出不合 Schema；打包链受网络影响。（均未发生）

- [x] 任务0：基线 38 files/158 tests 通过；typecheck 通过；lint 0 error；package x64 成功。基线 HEAD a695b20 + 未提交 P2 探索。
- [x] P0/P2 周期复盘：下游沉淀优先（阈值 3）、A-D 分级、D 级补证不调模型、预览确认、原子保存；提交 `49f2013`。
- [x] P1 验证模式：候选-确认/拒绝、JSON 快照原子写+复读、损坏报错；提交 `fb3a326`。
- [x] P3 主题思考/受控联网：讨论-差异-确认-沉淀、文件型 checkpoint、sourceId 会话绑定；提交 `7908a4c`。
- [x] P4 意图路由：确定性匹配 -> 固定枚举 -> Zod 失败回退澄清；提交 `a9fcf78`。
- [x] 最终：npm test 50 files/229 tests 全过；typecheck 通过；lint 0 error/5 既有 warning；package x64 成功。handoff/PROJECT_STATUS/CHANGELOG 已更新。BLOCKED.md：无。

高性价比决策记录：WebSourceContent 与 WorkflowIntent Schema 统一放 shared/domain（避免 renderer 跨层引 infrastructure）；P3/P4 提示词为自有快照，只把 `.claude` 契约当规则源参考。

## DeepSeek Harness Agent 阶段 0（2026-08-20，已完成）

- [x] 基线：`npm test` 54 files / 308 tests 全绿、跳过 0；`npm run typecheck` 通过；`npm run lint` 0 error / 7 个既有 warning。
- [x] 修复 `reviews-page.test.tsx` 的日期敏感断言：改为由同一默认范围函数计算的相对期望，不改产品日期逻辑，也不冻结其他异步页面测试的时钟。
- [x] 核验 DSH 源码 `D:\AI\deepseek-harness`：`0.1.0-rc.8`、提交 `141eb6f`、Node `24.18.0`、`pnpm run build` 成功；上游工作树保持干净。
- [x] 核验 Agent、Agent loop、session、tools、LLM、JSONL persistence、Cordis 和 SDK 的发布包与扩展点；阶段 A 优先采用发布包，接入面见 `apps/zhiji-desktop/docs/dsh-integration-notes.md`。
- [x] 未进入阶段 A：未新增 DSH 依赖、IPC、Utility Process、Agent 页面或领域工具。

## DeepSeek Harness Agent 阶段 A（2026-08-20，已完成）

- [x] 使用 npm 发布的 DSH 核心包建立独立 Electron Utility Process 构建入口；`npm run package` 成功并在 `app.asar` 确认 `utility.js` 产物。
- [x] 建立 `AgentFacade`、共享 Zod MessagePort 协议、`agent.start/send/cancel/list/get` IPC、Preload 订阅和 Agent 一级页面；原有六页职责未改变。
- [x] Main Process `AgentModelTransport` 经 `ConfigureAi.stream()` 代理模型流；API Key 不进入 Renderer、Utility Process 或会话结构。
- [x] 新增真实 DSH loop + 假模型、假 DSH 两轮流事件/取消/退出/崩溃、Agent 页面和 schema 测试；阶段 B 前未接入领域工具或持久化会话。

## DeepSeek Harness Agent 阶段 B（2026-08-20，已完成）

- [x] Main Process `AgentToolDispatcher` 对每个 Utility Process 工具请求再次执行共享严格 Zod 校验；只复用既有日志、复盘、项目、主题、验证模式和 `WebSearchService` 的只读服务，结果限制为脱敏摘要。
- [x] DSH 只注册显式的知己高层工具，以及 `ui.navigate` / `ui.present`；未加载 Shell、终端、通用文件系统、任意 URL、设置、备份、删除、确认或正式工作流工具。
- [x] Agent 页将工具活动、导航和结果卡片视为数据：Renderer 再验证导航目标，只映射到既有页面，不执行 URL、脚本或 DOM 指令。
- [x] 工具流可跨日志与复盘两类材料完成一轮真实 DSH Agent loop；补齐 OpenAI 兼容工具调用分片缺少后续 call ID 的解析回归，避免真实模型截断工具参数。

## DeepSeek Harness Agent 阶段 C（2026-08-20，已完成）

- [x] `AgentToolDispatcher` 继续作为 Main Process 唯一入口：新增日志创建/更新、每日反馈、周期复盘预览/生成和洞察预览/生成；所有入参和跨进程结果均经共享严格 Zod，正式服务仍由既有应用用例负责。
- [x] 周/月/项目及 coach/yearly/life-design 复盘沿用既有 `previewToken + materials digest`；Main Process 另持有 30 分钟、一次性、按 session 绑定的 `approvalId`，Renderer 的“确认并继续”按钮通过具名 `agent:confirm` IPC 恢复 Agent，不接受模型或普通文本冒充确认。
- [x] `tool.cancel` 从 DSH `ToolRunContext.signal` 经 MessagePort 传到 Main，连接 `ReviewTaskManager` 的 AbortSignal；取消测试证明模型中断后不会调用正式复盘保存。
- [x] 成功结果只返回脱敏摘要并生成受校验的既有日志/复盘页结果卡；未开放 Shell、任意文件、任意 URL、批量删除、主题确认或验证模式确认。
- [x] 阶段 C focused 测试覆盖预览—确认—生成、Agent 页面确认、取消和结果卡；最终回归 `npm test` 56 files / 322 tests、`npm run typecheck`、`npm run lint`（0 error / 7 既有 warning）与 `npm run package` 均通过。

## DeepSeek Harness Agent 阶段 D1：会话生命周期（2026-08-20，已完成）

- [x] 采用 npm 发布的 `@deepseek-ai/dsh-session-persistence-jsonl@0.1.0-rc.8`，不复制上游源码；Main Process 将当前数据根的 `agent/sessions/` 传给 Utility Process，使用 plain JSONL，API Key 不进入会话。
- [x] 新增 `session.list` / `session.snapshot` 协议；Agent 页面可在重启后列出有限长度的会话投影，发送消息时由 DSH `AgentRegistry.resume` 继续事件历史。
- [x] 数据目录迁移沿用现有递归复制；备份路径白名单接纳 DSH 会话 JSONL，并用 `Session.fromRestore` 校验 header、事件类型、顺序与序号；损坏会话明确拒绝，不静默重置。
- [x] 回归：`dsh-runtime.test.ts` 覆盖写入—重启—列表—resume；`agent-facade.test.ts` 覆盖恢复投影；`data-transfer.test.ts` 覆盖会话备份与损坏拒绝。
- [x] 全量验证：`npm test` 56 files / 326 tests；`npm run typecheck`；`npm run lint` 0 error / 6 既有 warning；`npm run package` 均通过。
- [x] 主题思考高性价比加固（历史，v1.28.3）：提案记录生成时的主题版本；确认写入在仓储队列内做条件检查，拒绝旧提案覆盖新认识；按别名更新时仍写回规范主题文件。该桌面端运行时随后由阶段 E 移除，旧 checkpoint 不主动删除。
- [x] 阶段 D2 主题会话迁移取消：主题思考不是桌面端复盘核心闭环；不再为桌面端维护第二套主题会话、提案和确认协议，已有主题数据保留，Skill/CLI 侧能力不受影响。

## DeepSeek Harness Agent 阶段 E：主题范围清理（2026-08-20，已完成）

- [x] 生产打包启动链修复（v1.28.1）：DSH 包保持外置以保留包相对 `package.json` 解析，生产 `app.asar` 纳入 DSH 与 Koffi 原生依赖，Utility Process 使用 `process.parentPort`；打包后的 Agent 会话创建和既有日志/每日/周复盘 E2E 通过。
- [x] 无 API Key 的恢复路径（v1.28.2）：模型错误仍由 Main Process 中文化，Agent 页面新增“打开设置”按钮；不把 Key 暴露给 Renderer，不增加第二套设置真相。
- [x] 依据第一性原理移除桌面端主题思考：删除导航、页面、复盘页跳转按钮、IPC/Preload API、主题服务/仓储/会话 checkpoint、提示词、主题 DSH 工具及其测试；日志、每日反馈、周/月/项目/年度复盘主链路保持不变。
- [x] 旧 `topics/` 与 `runtime/topic-sessions/` 用户数据不主动删除；Skill/CLI 侧主题契约和 WorkBuddy 路由不修改。D2 主题会话迁移取消，不再为非核心辅助能力维护第二套协议。
- [x] 当前验证：`npm run test:e2e` 1 passed（重跑通过）；`npm test` 51 files / 286 tests；`npm run typecheck`；`npm run lint` 0 error / 6 既有 warning；`npm run package` 均通过。
- [ ] 人工完成 Windows 安装/升级/卸载保留数据矩阵，并观察真实 Agent 多步任务。

## DeepSeek Harness Agent 阶段 F：API 凭据恢复（2026-08-20，已完成）

- [x] 复现并定位截图错误：凭据密文复制到另一份 Electron `userData` 或密钥环变化后，`safeStorage.decryptString` 失败；此前异常会沿 `settings:get` 冒泡为“暂时无法读取本地数据”。
- [x] `CredentialStore` 仅将密文解密失败视为当前 API Key 不可用，保留原 `credentials.json`，不降级明文、不删除数据；设置页可以继续加载并重新保存 API Key。
- [x] 回归覆盖密文失配不崩溃且凭据文件仍保留；focused 6 tests、全量 51 files / 286 tests、typecheck、lint（0 error / 6 既有 warning）、package 和打包 E2E（1 passed）均通过。

## DeepSeek Harness Agent 阶段 G：DeepSeek 连接可用性（2026-08-21，已完成）

- [x] 依据 DeepSeek 官方当前模型清单，将桌面端默认模型更新为 `deepseek-v4-flash`；旧 `deepseek-chat` / `deepseek-reasoner` 配置读取时自动迁移，不改动 API Key 或日志数据。
- [x] 连接测试改为非流式、最多 1 token 的请求，避免把“鉴权/模型检查”误当成完整生成并等待 SSE 超时；正式复盘和 Agent 仍保留流式链路。
- [x] focused 27 tests、Node HTTPS 无 Key 网络冒烟（服务端约 250ms 返回 401）、全量 51 files / 289 tests、typecheck、lint（0 error / 6 既有 warning）、标准 package 与打包 E2E（1 passed）均通过。

## DeepSeek Harness Agent 阶段 H：Agent 工具协议兼容（2026-08-21，已完成）

- [x] 复现用户“每日反馈可用、Agent 提问失败”：普通 DeepSeek 请求返回 200，带当前 Agent 工具定义返回 400；服务端明确拒绝含 `.` 的函数名。
- [x] 在 OpenAI 兼容层仅对外部 API 请求将工具名转换为字母/数字/下划线/连字符，模型返回工具调用时映射回 DSH 内部名称；不改变既有工具 action、会话数据或 Main Process 权限边界。
- [x] DeepSeek Agent 请求显式使用非思考模式，避免当前桥接协议未传递 `reasoning_content` 导致工具回合协议错误；每日反馈等普通生成链路保持原模式。
- [x] focused provider/Agent tests（16 tests）、typecheck、全量 51 files / 290 tests、lint（0 error / 6 既有 warning）、标准 package 与打包 E2E（1 passed）均通过。
