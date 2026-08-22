---
created: 2026-08-22
last_updated: 2026-08-22
status: awaiting-implementation
---

# Agent 本地证据卡片执行计划

## 1. 目标

在不改变现有检索算法、数据权威来源、DSH 会话格式和写入权限的前提下，把 `zhiji.memory.search` 的安全命中结果展示为当前回合可核实的证据卡片。

需求来源：[`agent-evidence-cards`](specs/2026-08-22-agent-evidence-cards.md)。本计划只描述实施顺序，本轮不执行代码。

## 2. 白名单范围

允许修改：

- `apps/zhiji-desktop/src/shared/schemas/` 下 Agent 事件或卡片契约；
- `apps/zhiji-desktop/src/main-process/agent/` 下工具结果事件转发；
- `apps/zhiji-desktop/src/renderer/pages/agent-page.tsx` 及必要的局部样式/组件；
- 与上述行为直接对应的 unit/integration/E2E 测试；
- 脱敏演示夹具和说明；
- 实施完成后的 `VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`。

禁止扩展：

- 检索算法、向量库、MCP、多模态、Computer Use、自改；
- Renderer 文件读取、Shell、任意 URL 或 API Key；
- DSH JSONL 会话事件格式和备份生命周期；
- 正式日志/复盘写入确认边界；
- 新的用户入口、后台任务、hash、baseline 或 gate。

## 3. 阶段 0：实施前事实复核

1. 确认工作区未覆盖用户现有的报告修改和未跟踪文件。
2. 核对 Agent Utility event、Preload IPC 和 Renderer 订阅的现有边界。
3. 核对日志/复盘详情页可接受的导航目标；已验证模式若无详情页则不增加跳转。
4. 核对 Electron 包版本与根 `VERSION` 的冲突，并作为独立修复处理；在版本事实一致前不生成正式安装包版本结论。

完成条件：列出会修改的精确文件和事件流，不新增数据层或通用卡片框架。

## 4. 阶段 A：共享结构化事件

1. 在现有 Agent Utility event 联合类型中增加只读证据结果事件，例如：

```text
tool.evidence
  sessionId
  callId
  source: memory.search
  hits[]: id / kind / date / excerpt
```

2. 复用既有 `AgentMemorySearchHit` 对应字段约束，限制命中数和摘录长度。
3. 不发送原始路径、URL、仓储对象或模型 reasoning。
4. 增加 Schema 测试：合法事件通过；未知字段、非法类型、超长内容和超过 8 条被拒绝。

完成条件：跨进程事件只表达 Renderer 真正需要的最小字段。

## 5. 阶段 B：Main Process / Utility 结果转发

首选最小路径：

1. 保持 `AgentToolDispatcher` 作为唯一校验和脱敏入口。
2. `memory.search` 返回 `AgentToolResultSchema` 校验通过后，由当前工具桥发出证据事件。
3. 证据事件与原工具结果使用同一份已脱敏对象，避免重新读取仓储或复制脱敏逻辑。
4. 工具空结果、错误或取消只保留现有活动/错误反馈，不产生证据卡片。
5. 事件绑定 `sessionId` 和 `callId`，防止并发会话串卡。

若 Utility 无法在不重复解析业务结果的情况下安全发事件，则将事件构造放在 Main Process facade；仍禁止 Renderer 直接接触 Dispatcher 或仓储。

完成条件：模型收到的工具结果与 Renderer 卡片来自同一份 Main Process 已校验数据。

## 6. 阶段 C：Renderer 证据卡片

1. Agent 页按 `sessionId` 保存当前运行期证据组。
2. 每组默认显示 3 条，允许展开至最多 8 条。
3. 显示类型、日期和摘录；空日期显示“日期未知”。
4. 日志/复盘仅在能映射到既有白名单导航目标时显示“查看记录”。
5. 已验证模式无详情目标时只展示证据，不新增页面。
6. 切换会话不串卡；删除会话清理对应卡片；应用重启不恢复卡片。
7. 卡片不展示 hidden reasoning、工具 JSON、路径或 URL。

完成条件：用户无需相信模型复述，就能核实本次回答使用的本地记录。

## 7. 阶段 D：演示夹具与三场景

1. 复用 repository 的临时目录测试方式准备固定脱敏夹具。
2. 夹具包含跨日期日志、周期复盘、已验证模式和一处日志/复盘冲突。
3. 不向正式 UI 增加“导入演示数据”入口。
4. 若现场演示需要初始化，只提供开发/演示专用流程，并使用独立数据目录；不得覆盖默认数据目录。
5. 记录三条固定演示提问及预期：事实查询、模式查询、冲突查询。

完成条件：同一份夹具可重复证明三条产品行为，不包含真实私人日志。

## 8. 阶段 E：验证

聚焦验证：

- shared Agent event/schema；
- Agent tool dispatcher/facade；
- DSH runtime 或工具桥；
- Agent Page 卡片显示、展开、会话隔离、删除清理和安全导航；
- 三场景脱敏夹具。

完整验证：

```text
npm test
npm run typecheck
npm run lint
npm run package
npm run test:e2e
```

视觉检查：

- 长摘录不会撑破 Agent 页面；
- 3 条默认卡片不淹没对话；
- 展开/收起、日期未知和空结果状态清楚；
- 卡片与现有审批卡片、结果卡片视觉层级一致。

完成条件：普通测试和现有发布验证通过；不新增独立质量 gate。

## 9. 阶段 F：文档与发布

1. 把 Spec 状态改为 completed，并在 `PROJECT_STATUS.md` 将对应任务勾选。
2. 修正文档中的“RAG v0”“脱敏摘要”等过度表述，统一为“本地可解释词法检索”“有限脱敏摘录”。
3. 在版本事实一致后按语义化版本更新桌面端与项目版本。
4. 更新 `CHANGELOG.md`，只记录用户可见的证据卡片、演示边界和验证结果。
5. 只提交本任务文件，不纳入用户现有的其他未提交/未跟踪内容；推送由用户手动完成。

## 10. 防作弊验收

- 不能用模型在最终回答中手写“来源：某日志”替代结构化卡片事件。
- 不能从 Renderer 直接读取本地日志生成卡片。
- 不能用固定截图或硬编码命中结果替代 Dispatcher 的真实工具结果。
- 不能把测试夹具或演示初始化写入用户默认数据目录。
- 不能为了通过演示把自动检索改成无条件每轮扫描全部资料。
- 不能把词法检索改名为 RAG 来冒充本轮完成了检索升级。

## 11. 回退

证据卡片是只读展示层，回退时删除新增事件、Renderer 状态/组件和对应测试即可；`memory.search`、DSH Runtime、会话 JSONL、日志/复盘仓储和正式写入链不应受影响。
