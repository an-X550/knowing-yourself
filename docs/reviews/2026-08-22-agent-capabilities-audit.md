---
created: 2026-08-22
last_updated: 2026-08-22
---

# 知己桌面 Agent 能力审计与作品集定位

## 1. 审计结论

原《知己 Agent 十项能力》报告的大方向正确，但需要把三件事分开：

1. **代码已经接入**：存在实现、契约和自动化测试。
2. **产品可以演示**：用户能在界面看到该能力产生的可核实结果。
3. **用户价值已经验证**：真实使用证明它稳定解决了问题。

当前知己已经完成第 1 层的大部分 Agent 工程能力，但长期记忆检索尚未充分达到第 2 层，也没有必要以第 3 层作为桌面端作品集的主要成功标准。桌面端的目标不是替代实际使用中的 Skill，而是成为一个可信、可解释、可复现的 LLM / Agent 应用工程作品。

因此，本轮裁决是：

- 保留 DSH Runtime、上下文组件、Function Calling、受控工具、会话持久化和现有词法记忆检索；
- 不为简历关键词新增 MCP、多模态、向量数据库、Computer Use 或递归自改；
- 不把当前词法检索称为 RAG；
- 下一项唯一值得进入 Spec 的产品能力是**只读证据卡片**，让观看者直接核实 Agent 使用了哪些本地记录；
- 本轮只形成审计、Spec 和计划，不实施代码。

## 2. 审计范围与证据

本次核对了以下本地事实：

- DSH 组合、Agent persona、工具定义和 JSONL 会话恢复；
- Main Process 工具调度、共享 Zod 请求/结果契约和写入确认；
- `zhiji.memory.search` 服务、Dispatcher、Runtime 注册和单元测试；
- DeepSeek thinking/tool-call 消息回放和 JSON Output 接口；
- Agent Renderer 的消息、工具活动和审批卡片展示；
- `VERSION`、`PROJECT_STATUS.md`、Electron `package.json` 和锁文件的版本事实。

外部方案只采用一手资料：

- [Pi Agent](https://github.com/earendil-works/pi)
- [Hermes Memory Providers](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/memory-providers.md)
- [Reasonix Context Engine v2](https://github.com/esengine/DeepSeek-Reasonix/blob/main-v2/docs/SESSION_MEMORY_RETRIEVAL.md)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [DeepSeek Tool Calls](https://api-docs.deepseek.com/guides/tool_calls/)
- [DeepSeek Thinking Mode](https://api-docs.deepseek.com/guides/thinking_mode)
- [DeepSeek JSON Output](https://api-docs.deepseek.com/guides/json_mode/)

本轮重新运行了记忆服务、工具调度和 DSH Runtime 的聚焦回归：3 个测试文件、15 项测试通过。没有重新运行完整测试、打包、安装矩阵或真实模型质量评测。

## 3. 当前能力事实

| 能力 | 当前代码事实 | 产品可见性 | 准确表述 |
|---|---|---|---|
| 上下文管理 | DSH `TokenMeter`、`ToolResultPruner`、`BasicCompactionEngine` 已注册 | 用户只能间接感知长会话表现 | 已接入官方上下文计量、裁剪和基础压缩；极限长会话保真未重新验证 |
| Function Calling | DSH AgentLoop 产生调用，Main Process 校验并执行，结果回传 | Agent 页显示工具活动标签 | 受控 Function Calling，不是任意函数执行 |
| 有限多步规划 | 模型可连续调用已注册工具，正式复盘仍需确认 | 可看到连续工具活动和审批 | 有限工具回合，不是后台任务、Planner 或多 Agent |
| 会话状态 | DSH JSONL 持久化、列表、resume 和工具回合重放 | 重启后可继续会话 | 会话记忆，不等于长期语义记忆 |
| 本地长期记忆 | `zhiji.memory.search` 跨日志、复盘、已验证模式做字符串包含匹配 | 只显示“已完成：检索长期记忆”，命中证据不结构化展示 | 本地可解释词法检索，不称为 RAG |
| 受控联网 | `web.search` / `web.read-source` 经 Main Process 和会话来源绑定 | 工具活动可见，结果由模型组织 | 受控公开来源检索，不是浏览器控制 |
| Structured Output | 工具和正式工作流有 Zod/JSON 契约；普通回答 Markdown/GFM | 结构化审批卡片和 Markdown 回复 | 有下游消费者时结构化，不全局 JSON |
| 安全边界 | Renderer 无 API Key、任意文件、Shell 或直接网络权限；写入走领域服务和确认 | 用户能看到审批边界 | 宿主受限工具代理，不是通用电脑代理 |

## 4. 原报告本次已修正的内容

### 4.1 “长期记忆已完成最小闭环”已降级

实现确实存在，但当前算法只有：

```text
完整查询字符串命中优先
→ 查询词项命中数量
→ 日期倒序
```

中文连续字符会被当作一个完整词项。现有测试主要证明“行动”这样的直接关键词能命中三类来源，不能证明以下能力：

- 同义表达召回；
- 中文复合查询分词；
- BM25、字段权重或相关性校准；
- 大规模历史下的性能；
- 模型能稳定自动调用检索；
- 用户能从界面核实模型使用的证据。

所以应写成“本地词法检索入口已实现”，不能写成“长期记忆问题已解决”。

### 4.2 “RAG v0”表述不准确

当前没有独立的切分、索引、召回评测、重排和引用闭环。把所有“检索后交给模型回答”的系统都叫 RAG，会削弱面试叙事的可信度。推荐使用：

> 跨日志、复盘和已验证模式的本地可解释词法检索。

只有未来出现明确漏召回，再优先考虑 SQLite FTS5/BM25；仍不足时才考虑 embedding 或混合检索。

### 4.3 “有限脱敏摘要”实际是有限原文摘录

`AgentMemorySearchService` 返回的是命中位置附近最多 800 字符的原文窗口，Dispatcher 再执行路径/URL 脱敏。它不是模型摘要。文档应称为“有限脱敏摘录”，避免把截断误写为摘要生成。

### 4.4 自动测试不能替代用户可见证据

现有 Git、类型、Zod 和单元测试足以证明工具契约可运行，但 Agent 页只展示工具名称和状态。观看者无法判断最终回答中的日期和事实是否真的来自检索结果。证据卡片解决的是这个具体展示失败，不需要新增长期 baseline、hash 或发布 gate。

### 4.5 版本事实存在冲突

根 `VERSION` 与 `PROJECT_STATUS.md` 是 `2.5.0`，Electron `apps/zhiji-desktop/package.json` 和对应锁文件仍是 `2.0.4`。在修复并重新打包前，不能把 Electron 安装包对外表述为已确认的 `2.5.0`。该问题独立于本轮证据卡片需求，不在本轮修改。

### 4.6 DSH 成熟度需要准确表述

当前 DSH 依赖为 `0.1.0-rc.8`。可以表述为“复用 DeepSeek Harness 官方组件”，但不应把 RC 依赖写成已经稳定成熟且无需关注升级风险的底座。

## 5. 外部成熟方案的正确复用边界

| 方案 | 可借鉴 | 当前不搬入 |
|---|---|---|
| Pi | Agent runtime、tool calling、state management 与 provider 解耦 | 整体替换 DSH；文件、进程、网络和凭据权限面 |
| Hermes | Memory Provider 生命周期、prefetch、turn sync、单一 Provider 选择 | Python Runtime、外部记忆 SaaS、自动记忆写入和大工具面 |
| Reasonix | 指令与背景事实分层、来源/作用域/新鲜度、BM25/CJK 演进思路 | coding-agent 终端、自改和更大权限面 |
| MCP 官方 SDK | 有具体外部 Server 时复用 Client、transport、session 和 auth | 为关键词接入空 Server；让外部 Schema 绕过 Main Process |
| DeepSeek API | 正确回放 tool call 与 `reasoning_content`；按消费者使用 JSON Output | 把 API 支持误写为宿主执行能力；普通回复全局 JSON |

复用原则不变：**复用协议、接口和生命周期，不照搬权限面、运行时和产品定位。**

## 6. 作品集定位

目标岗位叙事：LLM / Agent 应用工程。

项目应证明：

- 能把 Agent Runtime 接入 Electron，而不是只调用一次模型 API；
- 能处理上下文计量、压缩、工具结果裁剪和会话恢复；
- 能设计模型—Utility Process—Main Process—领域服务的权限边界；
- 能让 Function Calling 经过结构化校验、错误脱敏和用户确认；
- 能从本地权威记录检索证据，并让用户直接核实；
- 能区分模型能力、API 能力、Runtime 能力、宿主能力和产品能力；
- 能选择不做 MCP、多模态、Computer Use 和递归自改，并说明成本与边界。

不应宣称：

- 自研 Agent Runtime 或上下文压缩算法；
- 完整 RAG、向量数据库或语义记忆；
- 标准 MCP Client；
- 通用 Computer Use；
- Agent 自主修改自身代码和权限。

## 7. 最终裁决

当前不需要继续堆叠 Agent 能力名词。最有性价比的下一步，是把已经存在的本地检索从“后台工具调用成功”提升为“前台证据可核实”，并用三条脱敏演示场景证明事实查询、模式查询和冲突处理。

需求见 [`agent-evidence-cards`](../specs/2026-08-22-agent-evidence-cards.md)，执行步骤见 [`agent-evidence-cards-execution-plan`](../2026-08-22-agent-evidence-cards-execution-plan.md)。
