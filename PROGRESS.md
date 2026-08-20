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
