---
created: 2026-08-22
last_updated: 2026-08-22
---

# 知己 Agent 十项能力：第一性原理详细分析、现状盘点与高性价比裁决

## 0. 文档性质与结论范围

本文是**分析与决策文档**，不是单独的开发授权。本文同时记录本轮执行后的当前事实，用于回答以下问题：

1. 这十项能力分别解决什么真实问题？
2. 知己桌面端当前已经具备什么，哪些只是模型或 API 的理论能力？
3. 现在做是否值得、是否高性价比？
4. 如果以后要做，应优先复用什么成熟方案，哪些边界不能直接照搬？

本文不新增 MCP Server、向量数据库、系统控制权限或自我修改权限；也不把“未来可以做”写成“当前已经具备”。桌面端的主要目标是作为 LLM / Agent 应用工程作品集，真实日常使用仍可由 Skill 承担。本轮已将中文词法召回、当前回合证据卡片和版本事实统一落地到 `v2.6.0`；完整产品验证结果以 `PROJECT_STATUS.md` 与 `CHANGELOG.md` 为准，真实模型质量仍不等同于自动化测试结论。

## 1. 结论先行

不值得为了补齐一张行业能力清单，把十项能力全部接入知己。知己的核心目标仍然是：

```text
发现跨时间模式 → 形成一个可执行行动 → 用后续日志验证
```

因此，最优策略不是“把知己变成通用电脑代理”，而是保留窄而可靠的本地日志闭环：

- **已经具备，不重复建设**：上下文压缩、Function Calling、有限多步工具回合、会话持久化、工具/工作流结构化校验、受控联网、Markdown 输出。
- **已经做了高性价比的工程入口**：跨日志、复盘和已验证模式的本地只读词法检索，以及当前回合可核实的证据卡片；它不是完整长期记忆，也不称为 RAG。
- **当前只具备部分能力**：长期记忆的语义能力、Agent 自主规划和 Structured Output 的产品层；完整 RAG 生命周期当前不存在。
- **当前不具备且不建议现在做**：标准 MCP Client、多模态输入、通用 Computer Use、递归自我修改。
- **本轮已完成的作品集链路**：MiniSearch BM25+、`Intl.Segmenter`、CJK 二元词片、受限候选查询和当前回合只读证据卡片；后续只有出现新的可复现失败才评估更重的检索方案。

十项能力的总裁决如下：

| # | 能力 | 当前状态 | 现在是否高性价比 | 裁决 |
|---:|---|---|---|---|
| 1 | 上下文压缩 | 已接入 DSH `0.1.0-rc.8` 官方组件 | 否，重复建设 | 保留并观察真实长会话质量；RC 依赖不等于稳定性已充分验证 |
| 2 | 长期记忆检索 | 已完成 MiniSearch 中文词法召回、受限候选查询和当前回合证据卡片 | 是，已解决已确认的失败 | 保留来源可追踪和只读边界；暂不接向量或外部记忆 |
| 3 | Function Calling | 已有模型调用—宿主执行—结果回传闭环 | 否，已具备 | 继续收紧工具契约，不增加通用任意函数 |
| 4 | MCP 工具调用 | 内部工具桥不是 MCP，标准 Client 尚无 | 暂不值得 | 等出现明确外部 MCP Server 和真实任务后再接官方 SDK |
| 5 | 多模态理解 | 当前 Agent 消息契约为文本 | 暂不值得 | 先等一个明确图片、音频或视频场景，再按单一媒体类型接入 |
| 6 | Agent 自主规划 | 已有有限多轮工具规划，无通用任务编排 | 暂不新增 Planner | 保留受工具和确认门约束的有限自主性 |
| 7 | RAG 检索增强 | 完整生命周期不存在；当前是可解释的本地词法检索入口 | 暂不值得作为 RAG 立项 | 中文漏召回已归入 #2 修复；仍不引入向量、混合检索或 RAG 产品层 |
| 8 | Structured Output | 工具和正式工作流结构化；普通回复 Markdown | 不适合全局强制 | 按下游消费者逐工作流启用，不把聊天变成 JSON |
| 9 | Computer Use | 没有桌面感知、操作、沙箱和回滚 | 否，风险远大于当前收益 | 不实现通用电脑控制 |
| 10 | 递归自我改进 | 没有自改代码、提示词、工具和权限的能力 | 否，边界不成立 | 只允许人工审查的提案/补丁流程，不允许自主递归执行 |

## 2. 第一性原理：先拆问题，再决定能力

### 2.1 真实问题不是“缺少名词”

“上下文压缩、RAG、MCP、Computer Use”是工程名词，不是用户价值。需要先把用户真正要解决的问题拆开：

| 用户问题 | 真正需要的机制 | 不一定需要的机制 |
|---|---|---|
| Agent 忘记此前记录 | 有权威来源、可检索、可引用的历史事实 | 不一定需要向量数据库或云端记忆 |
| 多轮后越来越慢、跑偏 | token 预算、工具结果裁剪、上下文压缩 | 不一定需要换整个 Agent 框架 |
| Agent 需要查天气或读日志 | 受限工具调用、宿主执行、结果回传 | 不一定需要 MCP |
| 结果要进入 UI、文件或工作流 | 有明确 Schema 的结构化输出 | 不一定需要普通聊天全部 JSON 化 |
| 任务需要多个步骤 | 可取消、可观测、有限权限的工具循环 | 不一定需要子 Agent 或通用 Planner |
| 要读图片或听语音 | 媒体输入、附件生命周期、模型兼容 | 不一定需要一次性支持图片、音频、视频 |
| 要自动操作电脑 | 感知、动作、权限、停止、回滚和沙箱 | 绝不是加一个鼠标工具就完成 |

如果一个能力不能直接改善“发现模式—形成行动—后续验证”，或者会引入更大的权限、数据和维护边界，就不应仅因为其他 Agent 有它而接入。

### 2.2 五层边界不能混淆

```text
模型能力
  ≠ API 协议能力
  ≠ Agent Runtime 能力
  ≠ 宿主工具能力
  ≠ 产品安全能力
```

例如 DeepSeek 的 Tool Calls 让模型返回工具名称和 JSON 参数，但**模型不会执行函数**；函数由宿主程序执行，再把工具结果传回模型。[DeepSeek Tool Calls 官方文档](https://api-docs.deepseek.com/guides/tool_calls/)

同理：

- API 支持 JSON，不代表知己普通回答应全部输出 JSON。
- 模型能输出“点击按钮”的文字，不代表产品具备 Computer Use。
- Agent Runtime 能循环调用工具，不代表它拥有后台任务队列或任意写入权限。
- 有会话 JSONL，不代表已经有抽象、可纠错、可过期的长期记忆。
- 有网页搜索，不代表已经有本地资料 RAG。

### 2.3 判断“值得做”的四个问题

每项能力按以下顺序判断，不使用没有真实样本支撑的精确分数：

1. **问题证据**：是否已有具体失败、重复劳动或可观察损失？
2. **核心关联**：是否直接服务日志、复盘、行动和验证闭环？
3. **最小替代**：提示词、既有能力、一个适配器或只读索引是否已经足够？
4. **验证闭环**：完成后能否在本地用真实数据立即检查正确性、隐私和用户收益？

四项中任一项明显不成立，就先不扩展。此处不新增 hash、baseline、冻结 contract 或质量 gate；普通单元测试、类型约束、打包回归和真实样本观察已经足够作为当前证据。

### 2.4 知己的不可突破约束

- `.claude/` 是现有 Skill、命令、工作流和共享契约的运行真相，不能被新 Agent 框架替换。
- 桌面端是 Electron Windows 应用，API Key 只应留在 Main Process，Renderer 不应获得任意网络、文件或 Shell 权限。
- 日志、复盘和验证模式是用户数据；记忆检索必须能说明来源、保持只读和可删除，不应复制出第二份不可追踪的真相。
- 正式日志、周期复盘和洞察生成已有预览—确认—执行边界，规划能力不能绕过确认门。
- DeepSeek V4-Flash 的响应速度不能直接证明回答质量；速度、思考开关、工具回合完整性和任务正确性是不同变量。

## 3. 当前能力事实：知己现在真正有什么

以下是代码事实，不是模型自述：

| 能力层 | 当前事实 | 证据位置 | 明确限制 |
|---|---|---|---|
| 上下文运行时 | DSH `0.1.0-rc.8` 的 `TokenMeter`、`ToolResultPruner`、`BasicCompactionEngine` 已注册 | [`dsh-runtime.ts`](../apps/zhiji-desktop/src/main-process/agent/dsh-runtime.ts#L6)、[`dsh-runtime.ts`](../apps/zhiji-desktop/src/main-process/agent/dsh-runtime.ts#L123) | 官方 RC 组件已接入，不等于稳定性和极限长会话质量已充分验证 |
| 会话状态 | DSH JSONL 持久化、列表、resume 和 reasoning 重放 | [`dsh-runtime.ts`](../apps/zhiji-desktop/src/main-process/agent/dsh-runtime.ts#L12)、[`dsh-runtime.ts`](../apps/zhiji-desktop/src/main-process/agent/dsh-runtime.ts#L316) | 会话历史不是语义长期记忆 |
| Function Calling | AgentLoop 生成工具调用，Main Process 校验并执行，结果回传 | [`dsh-runtime.ts`](../apps/zhiji-desktop/src/main-process/agent/dsh-runtime.ts#L139)、[`agent-tool-dispatcher.ts`](../apps/zhiji-desktop/src/main-process/agent/agent-tool-dispatcher.ts#L66) | 只允许知己注册的高层工具，不是任意函数执行 |
| 工具安全边界 | 共享 Zod request/result、Main Process dispatcher、路径/URL 脱敏 | [`agent-tools.ts`](../apps/zhiji-desktop/src/shared/schemas/agent-tools.ts#L56)、[`agent-tool-dispatcher.ts`](../apps/zhiji-desktop/src/main-process/agent/agent-tool-dispatcher.ts#L17) | 内部 MessagePort 是私有桥接协议，不是标准 MCP |
| 本地记忆 | `zhiji.memory.search` 用 MiniSearch 内存 BM25+、`Intl.Segmenter`/CJK 二元词片和最多 3 个受限候选查询只读检索日志、复盘、已确认验证模式；Main Process 将同一份安全结果发为证据事件 | [`agent-memory-search-service.ts`](../apps/zhiji-desktop/src/main-process/agent/agent-memory-search-service.ts#L23)、[`agent-facade.ts`](../apps/zhiji-desktop/src/main-process/agent/agent-facade.ts#L121)、[`agent-page.tsx`](../apps/zhiji-desktop/src/renderer/pages/agent-page.tsx#L63) | 词法召回不是语义记忆；索引每次调用重建，证据卡片只保留当前 Renderer 会话运行态；不是 RAG |
| 受控联网 | `web.search` / `web.read-source` 通过 Main Process 受控调用；Windows 网络栈使用 Electron `net.fetch` | [`bootstrap.ts`](../apps/zhiji-desktop/src/main-process/bootstrap.ts#L53) | 公开来源搜索不等于本地 RAG 或任意浏览器控制 |
| 输出展示 | 工具/工作流使用结构化契约；普通回答使用 React Markdown/GFM | [`markdown-document.tsx`](../apps/zhiji-desktop/src/renderer/components/markdown-document.tsx#L1) | 普通自然语言不强制 JSON；非法单行 Markdown 不做猜测式修复 |
| 写入边界 | 日志保存、周期复盘、洞察复盘走既有领域服务和用户确认 | [`agent-tool-dispatcher.ts`](../apps/zhiji-desktop/src/main-process/agent/agent-tool-dispatcher.ts#L130) | Agent 不能自行修改 Skill、代码、权限或桌面环境 |

因此，截图式“能力清单”只能作为待核对假设，不能作为当前代码事实。特别是上下文压缩、Function Calling 和部分结构化能力已经存在；而标准 MCP、多模态、Computer Use 和递归自改并不存在。

## 4. 十项能力逐项分析

### 4.1 上下文压缩

#### 它真正解决什么问题

上下文有三个不同问题，不能都叫“压缩”：

1. **请求上下文预算**：消息、工具结果和 reasoning 逐步变长，接近模型上下文上限。
2. **信息保真**：压缩后仍要保留用户约束、关键事实、未完成任务、工具结果和确认状态。
3. **会话存储体积**：磁盘上的 JSONL 事件是否压缩，与发给模型的上下文是否压缩是两回事。

#### 当前状态

知己已经复用 DSH `0.1.0-rc.8` 的官方 `TokenMeter`、工具结果裁剪和 `BasicCompactionEngine`。这意味着“没有主动上下文压缩”的判断不准确，但 RC 版本也不能被写成稳定性已经充分验证。另一方面，当前 JSONL 会话持久化仍保持可读事件，运行配置中的 `compression: 'none'` 不能被误读为“运行时没有上下文压缩”，它主要说明持久化事件没有被压成不可直接重放的另一种格式。

当前能确认的是：压缩机制已接入；当前不能据此确认：

- 复杂中文日志在压缩后是否仍保留全部关键事实；
- 长时间工具循环是否会错误遗忘确认门或来源 ID；
- Flash 与 Pro、思考开关不同组合下的压缩质量是否相同；
- 极限长度场景下的延迟和费用是否改善到用户可感知的程度。

#### 是否值得现在做

**不值得新增实现。** 当前真实问题是“是否接入、是否正确接入、极端样本质量如何”，不是“再写一个压缩器”。重新引入 Pi、Hermes 或自研摘要链，会产生两套上下文真相、重复 token 预算计算和新的回放兼容问题。

#### 成熟方案与复用边界

Pi 已把 Agent loop、工具调用和状态管理拆成可复用运行时，但其权限模型需要宿主自行 sandbox/containerize；它适合参考运行时分层，不适合整体替换知己的安全边界。[Pi Agent README](https://github.com/earendil-works/pi)

#### 裁决

保留现有 DSH 压缩链。未来只有在真实长会话出现“压缩后关键事实丢失”时，才针对 DSH 的 compaction hook 增加保真修正或领域摘要；不建立第二个独立压缩系统。

### 4.2 长期记忆检索

#### 它真正解决什么问题

长期记忆不是“把历史全部塞进 system prompt”，而是让 Agent 在需要时从有来源的历史事实中召回内容。至少要分清四层：

| 层 | 作用 | 是否应自动绑定每轮 |
|---|---|---|
| 强制指令 | 必须遵守的规则、边界、工作方式 | 是，但应短 |
| 项目事实 | 只对某项目有效的约束、决定和背景 | 按相关性检索 |
| 用户事实/偏好 | 用户明确选择长期保留的信息 | 按范围和授权检索 |
| 会话历史 | 原始措辞、工具结果、尚未沉淀的讨论 | 按会话或搜索读取 |

Reasonix 的 Context Engine v2 明确把 standing instructions 与 background memory 分开，并提醒事实不能悄悄变成命令；这是比“一个 MEMORY.md 解决所有问题”更可靠的设计。[Reasonix Context Engine v2](https://github.com/esengine/DeepSeek-Reasonix/blob/main-v2/docs/SESSION_MEMORY_RETRIEVAL.md)

#### 当前状态

根项目 `v2.6.0` 已有 `zhiji.memory.search`：

- 只读复用日志、复盘和已确认验证模式的权威仓储；
- 使用 MiniSearch BM25+、标准中文分词和 CJK 二元词片召回，原始查询与最多 3 个候选查询按稳定 ID 合并；
- 返回稳定 ID、日期和最多 800 字符的有限原文摘录，不是模型摘要；
- 结果经过共享 Zod 契约和 Main Process `safeText`；
- 不创建第二份日志真相，不自动抽取、自动写入或调用外部记忆服务；
- Main Process 只从已校验的工具结果发出 `tool.evidence`，Agent 页面按会话展示类型、日期和真实摘录，默认 3 条、最多 8 条；
- 空结果应明确表示“未检索到”，不能把模型猜测说成“我记得”。

现有聚焦测试证明直接关键词、中文复合查询、受限候选、噪声控制、稳定排序、真实摘录、证据事件和会话隔离；完整单元测试为 53 个文件 / 314 项通过。它没有证明大规模性能、模型稳定自动检索或真实用户价值。

因此当前是“有来源的本地历史检索”，不是完整的语义长期记忆系统。它还没有：

- 每轮自动 prefetch；
- 记忆的类型、范围、过期、冲突和用户纠错模型；
- 持久化索引、向量召回、FTS5 生命周期或语义重排；
- 记忆写入、删除、忘记和隐私导出的一套独立产品界面。

#### 是否值得现在做

**长期记忆方向值得保留，但当前只能确认本地词法证据链已经实现，不能宣称语义记忆或真实用户价值已经解决。** 知己的核心数据本来就是 Markdown 日志和复盘，复用权威数据做只读词法检索和证据卡片，比接入云端记忆 SaaS 更直接。后续只在新的可复现召回或规模失败出现时升级检索引擎。

#### 成熟方案与复用边界

Hermes 已将记忆抽象成 Provider，并提供 `prefetch`、每轮同步、会话结束抽取和 Provider 工具；它还限制同时启用的外部 Provider 数量，避免工具 Schema 膨胀和多个记忆后端相互冲突。[Hermes Memory Providers](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/memory-providers.md)

知己应复用的是接口思想，而不是现在就引入 Hermes 的 Python 运行时或外部服务：

```text
search(query, scope) → 带来源的结果
prefetch(query)      → 可选、受预算限制的上下文补充
store(fact)          → 只有明确授权和独立审计后才允许
forget(id)           → 必须可追踪、可验证、可恢复或明确不可恢复
```

#### 裁决

已确认的确定性失败已通过最小方案修复：MiniSearch 内存 BM25+、`Intl.Segmenter` 和 CJK 二元词片改善中文复合查询，DeepSeek 只可通过至多 3 个受限候选查询处理有限同义表达；当前回合证据卡片只消费 Main Process 已校验的 ID、类型、日期和有限摘录，不持久化、不建立第二份记忆。只有该方案仍出现新的明确漏召回或规模失败，才评估 embedding、向量库或外部 Provider。不要把会话历史、强制指令和背景事实混成自动写入池。

### 4.3 Function Calling

#### 它真正解决什么问题

Function Calling 的本质是把自然语言决策连接到一个有 Schema、可验证、可拒绝的宿主动作：

```text
模型提出工具调用 → 宿主校验参数 → 宿主执行 → 返回工具结果 → 模型继续或结束
```

它不是模型获得电脑权限，也不是“模型自己会调用函数”。DeepSeek 官方文档明确说明函数实现由用户提供，模型只返回调用信息；官方 API 还提醒工具参数必须在代码中验证，因为模型可能生成无效 JSON 或未定义参数。[DeepSeek Tool Calls](https://api-docs.deepseek.com/guides/tool_calls/)、[DeepSeek Chat Completion API](https://api-docs.deepseek.com/api/create-chat-completion/)

#### 当前状态

知己已经具备完整但受限的 Function Calling 链路：

- DSH `AgentLoop` 接收工具定义并处理多轮回合；
- DeepSeek 模型适配器保留 tool call、reasoning 和流式增量；
- Main Process 的 `AgentToolDispatcher` 是唯一工具执行入口；
- shared Zod schema 校验请求和结果；
- 工具只暴露日志、复盘、项目、验证模式、受控联网、UI 跳转和确认后的工作流；
- 不暴露任意路径、Shell、URL 直读或任意 JavaScript 执行。

#### 是否值得现在做

**不值得重新实现。** 当前需要的是工具设计质量和错误处理，而不是再装一套 Function Calling SDK。再增加任意函数会扩大安全边界，使模型能从“日志助手”滑向“本机执行器”。

#### 裁决

继续采用“模型提议、宿主校验、领域服务执行、结果脱敏”的闭环。未来若增加工具，应先说明工具的真实用户任务、输入/输出、权限、失败语义和确认要求；不为了数量增加工具。

### 4.4 MCP 工具调用

#### 它真正解决什么问题

MCP 主要解决**跨应用工具、资源和提示词的互操作协议**，不是比 Function Calling 更聪明的模型能力。Function Calling 是一次模型—宿主调用机制；MCP 还要解决 Server 发现、传输、会话、认证、生命周期和跨进程信任。

#### 当前状态

知己当前的 `MessagePort + Main Process + Zod` 是内部桥接协议，不是 MCP Client。它已经足够承载知己自有工具，但没有：

- MCP Server 配置和发现；
- stdio/HTTP Server 生命周期；
- 每个 Server 的权限、认证和撤销界面；
- 工具数量、超时、并发和结果大小限制；
- 外部工具的来源、版本和供应链审查。

#### 是否值得现在做

**暂不值得。** “MCP 很成熟”只说明协议和 SDK 可用，不说明知己当前存在需要外接的 Server。若没有真实的外部工具任务，接入 MCP 只会重复已有 Dispatcher，并新增子进程、权限、认证和打包问题。

#### 成熟方案与复用边界

官方 TypeScript SDK 已提供 MCP Server/Client、工具、资源、提示词以及 stdio、HTTP、会话和授权相关能力；当前仓库主线已经进入新的 v2 SDK 线路。[MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)

未来接入时应：

1. 只在 Main Process 或隔离的受控 Utility 中接入，Renderer 不直接连外部 Server；
2. 固定已发布 SDK 和协议版本，不依赖浮动 `main`；
3. 只允许用户明确启用的 Server 和工具；
4. 为每个工具保留超时、取消、结果大小和错误脱敏；
5. 写入、外部发送、删除等动作继续经过知己自己的确认门；
6. 把 MCP 工具映射为知己内部统一契约，而不是让外部 Schema 直接穿透 UI 和领域服务。

#### 裁决

不安装 SDK，不启动任意 MCP Server，不改变当前工具桥。触发条件是用户给出一个具体 Server、传输方式和真实任务，而不是“以后可能用到 MCP”。

### 4.5 多模态理解

#### 它真正解决什么问题

多模态不是在提示词中写“请看图”，而是一条端到端数据链：

```text
附件选择 → 类型/大小校验 → 安全存储或上传 → provider content parts
→ 模型回放/持久化 → 结果展示 → 删除与隐私控制
```

图片、音频、视频的传输、费用、延迟、可回放性和隐私风险都不同，不能一次性作为一个模糊的“多模态开关”。

#### 当前状态

知己 Agent 的模型消息、工具桥、会话回放和 Renderer 消息契约当前以文本为主。桌面端可以展示用户提供的截图，但这不等于截图已经作为模型输入完成安全、可重放的多模态链路。当前没有统一的：

- 图片/音频/视频附件 Schema；
- MIME、大小、分辨率、时长和恶意文件限制；
- 本地文件与远端上传的隐私选择；
- 多模态消息持久化和删除策略；
- DeepSeek V4-Flash 当前端点对目标媒体类型的兼容验收。

#### 是否值得现在做

**暂不值得铺开。** 没有明确场景时，三种媒体类型一起接入的成本高于收益。若用户真实需求是“分析截图中的日志排版”，图片可能是第一个候选；若需求是语音日志，音频转写和时间戳又是另一条产品链。必须先选一个场景。

#### 成熟方案与复用边界

优先复用 provider 已有的标准 content-part 结构和成熟媒体解析库，不自创 `imageData1/imageData2` 之类协议；可以参考 Pi 的多供应商抽象，但不能因此把整个 Pi coding-agent 权限面带入桌面端。[Pi Agent README](https://github.com/earendil-works/pi)

#### 裁决

当前不修改 Renderer、IPC、会话格式和模型适配器。未来若有具体场景，先做图片或音频中的一种，明确附件生命周期和隐私边界，再判断是否值得扩大。

### 4.6 Agent 自主规划

#### 它真正解决什么问题

“自主规划”至少包含四个层次：

1. 模型在一次回复中列出步骤；
2. AgentLoop 根据工具结果继续下一步；
3. 可恢复的任务计划，包含状态、取消、重试和进度；
4. 多 Agent、后台任务和跨会话编排。

前两层不能自动等同于后两层。思考模式输出了更多 reasoning，也不代表形成了可审计、可恢复的计划。

#### 当前状态

知己已有 DSH AgentLoop，可以在一次会话内连续读取资料、搜索来源、提出工作流预览并等待确认。它是**有限自主规划**：

- 模型可以决定调用哪些已注册工具；
- 领域工具负责真实执行；
- 正式写入和周期复盘必须经过既有确认门；
- Agent 没有任意后台任务队列、子 Agent 编排、Shell、任意文件修改和无人值守运行权限。

#### 是否值得现在做

**不新增独立 Planner。** 通用 Planner 往往带来额外 token、延迟、状态同步和失败分支；对于日志读取—复盘预览—用户确认这一类有限流程，现有工具回合已经足够。一个“看起来更会规划”的系统，如果不能取消、解释、恢复和守住确认门，反而降低可靠性。

#### 成熟方案与复用边界

Pi 的 `pi-agent-core` 已将 Agent loop、tool calling 和 state management 做成独立运行时，适合借鉴职责拆分；Hermes 也把工具、记忆 Provider 和 Agent 生命周期分开。复用这些抽象比自研一套 planner 更高性价比，但不应直接引入 coding-agent 的 Shell 和任意文件能力。[Pi Agent](https://github.com/earendil-works/pi)、[Hermes Agent](https://github.com/NousResearch/hermes-agent)

#### 裁决

保留有限多步工具规划。未来只有当出现一个重复、明确、耗时且用户愿意授权的多步流程时，才设计最小任务状态对象；计划必须可见、可取消、可恢复，并把写入步骤继续交给现有领域确认门。

### 4.7 RAG 检索增强

#### 它真正解决什么问题

RAG 不是“加一个向量数据库”，而是一个完整生命周期：

```text
资料来源 → 切分 → 索引 → 查询召回 → 重排/过滤 → 带来源注入 → 回答引用
   ↑                                                        ↓
   └────────────── 更新、删除、过期和权限同步 ──────────────┘
```

如果没有来源、更新、删除和权限模型，向量库只会制造一份难以解释的第二真相。

#### 当前状态

知己当前有两类容易被混淆的检索：

- `web.search`：搜索公开来源并绑定本次会话的 `sourceId`，属于受控联网搜索；
- `zhiji.memory.search`：从本地日志、复盘和已确认验证模式做字符串包含/词法召回，是未来检索增强可复用的入口，但当前不称为 RAG。

当前没有独立切分、索引生命周期、召回评测、重排、自动引用闭环，也没有 embedding、向量数据库或混合召回。因此“RAG v0”仍会高估现有实现；准确表述是“本地可解释词法检索”。

#### 是否值得现在做

**检索增强方向可以保留，但现在既不值得向量化，也不需要用 RAG 名称包装。** 知己的本地资料规模、权威格式和核心查询都是中文日志/复盘；当前作品集首先要证明的是“检索结果来自哪里、用户能否核实”，不是检索技术名词是否完整。如果以后出现明确漏召回，再用更成熟的词法索引解决具体问题。

#### 成熟方案与复用边界

Hermes 的 Provider 文档展示了从自动 prefetch、会话同步，到本地 SQLite FTS5、混合检索、信任分数和外部 Provider 的成熟路线；Reasonix 还提供了 CJK 词法召回、作用域、过期降权和指令/事实分离的设计参考。[Hermes Memory Providers](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/memory-providers.md)、[Reasonix Session Memory Retrieval](https://github.com/esengine/DeepSeek-Reasonix/blob/main-v2/docs/SESSION_MEMORY_RETRIEVAL.md)

推荐的演进顺序是：

1. 当前先用 MiniSearch BM25+、`Intl.Segmenter` 和 CJK 二元词片修复中文复合查询，再补齐用户可见证据卡片；
2. 有限同义表达由受限候选查询处理，不维护大词典、不把候选词当事实；
3. 若仍无法处理隐含语义和跨语言查询，再评估本地 embedding 或可替换 Provider；
4. 任何语义召回都必须保留来源、时间、作用域和用户删除路径。

#### 裁决

当前 #7 不作为一项已具备能力；#2 只提供可复用的本地词法检索入口。没有明确召回失败证据，不启动 embedding、Qdrant、pgvector、云端记忆或自动知识抽取，也不在简历中把现状写成 RAG。

### 4.8 Structured Output

#### 它真正解决什么问题

Structured Output 的价值在于**下游程序需要稳定解析**，例如：

- 保存日志所需的日期、正文、项目 ID；
- UI 展示所需的卡片、导航目标和审批信息；
- 复盘工作流所需的预览材料、确认 token 和正式结果。

它不等于“回答有 Markdown 标题”，也不等于“所有自然语言都必须 JSON”。

#### 当前状态

知己已经在工具和正式工作流使用共享 Zod Schema 校验请求/结果；Renderer 对普通回答使用 Markdown/GFM，保证标题、列表、表格和代码块可读。当前是：

- **工具参数结构化**：有；
- **工具结果结构化**：有；
- **工作流结果结构化**：有；
- **普通聊天全局 JSON**：没有，也不应默认有；
- **所有下游 Schema 都由模型严格生成并自动修复**：没有。

DeepSeek JSON Output 需要 `response_format: { type: 'json_object' }`、提示词中的 JSON 约束和合理的 token 预算；官方文档也提示可能出现空内容或截断风险。DeepSeek Tool Calls 的 strict Schema 是针对工具调用格式，不等于普通回复的业务 Schema。[DeepSeek JSON Output](https://api-docs.deepseek.com/guides/json_mode/)、[DeepSeek Tool Calls strict mode](https://api-docs.deepseek.com/guides/tool_calls/)

#### 是否值得现在做

**不值得全局强制。** 普通聊天的下游消费者是人，Markdown 比 JSON 更适合阅读；日志、复盘和 UI 卡片已有明确消费者，现有结构化边界已经解决主要问题。全局 JSON 会让开放式问答变差，还会放大模型兼容、空 JSON、截断和修复成本。

#### 裁决

继续采用“有下游消费者才结构化”的策略。未来为单个工作流增加 Schema 时，按以下流程：

```text
定义消费者需要的最小 Schema → 模型生成 → Zod 解析
→ 失败时有限重试或转人工澄清 → 领域服务执行
```

不把普通 Agent 回复变成 JSON，也不重复实现 JSON Schema 校验器。

### 4.9 Computer Use

#### 它真正解决什么问题

Computer Use 是一个高风险闭环，不是“加鼠标键盘 API”：

```text
屏幕/窗口感知 → 动作规划 → 坐标或控件操作 → 新画面反馈
        ↑              ↓
     状态判断 ← 停止、超时、撤销、回滚和人工接管
```

它还需要操作系统权限、沙箱或隔离用户、敏感页面保护、动作白名单、破坏性操作确认和失败恢复。

#### 当前状态

知己没有桌面截图识别、鼠标键盘控制、窗口定位、浏览器会话接管、操作审计、沙箱和回滚系统。打开知己页面、展示 UI 卡片或导航到既有页面属于受限 UI 工具，不是 Computer Use。

Hermes 的 CLI 文档把 Computer Use 作为独立 toolset 和 driver 生命周期处理，这本身说明它需要单独的安装、运行时和平台适配，不是普通 Function Calling 的自然延伸。[Hermes CLI / Computer Use](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/reference/cli-commands.md)

#### 是否值得现在做

**不值得做。** 它偏离知己“记录—复盘—验证”的核心，且会把当前安全边界从“允许访问少量结构化数据”扩大到“允许代理操作整台电脑”。没有具体高价值流程和完整安全设施时，收益无法覆盖风险。

#### 裁决

明确不接入通用 Computer Use。以后如果出现明确任务，也只能先做隔离、只读、可见、可停止的单一流程；不允许从“能点按钮”直接演进成无人值守电脑代理。

### 4.10 递归自我改进

#### 它真正解决什么问题

需要先区分三种不同概念：

- **记忆**：保存用户或项目事实，供以后检索；
- **反馈**：用户或测试告诉 Agent 某次输出哪里不好；
- **自我修改**：Agent 改写自己的代码、提示词、工具、权限或执行策略，并自动再次运行修改后的自己。

前两种是产品能力，第三种是开发与安全边界变化。

#### 当前状态

知己没有、也不应默认拥有 Agent 自主修改代码、Skill、共享契约、工具定义、权限配置或自身提示词的能力。当前更新这些内容必须由用户或开发流程显式修改，并经过普通代码审查和验证。

Pi 的项目描述包含 self-extensible coding agent，但其 README 同时明确提示默认不提供文件、进程、网络和凭据的内置权限隔离，需要宿主自行沙箱化；这不能被理解为“可以安全地让桌面 Agent 自改”。[Pi Agent README](https://github.com/earendil-works/pi)

Reasonix 的记忆文档则强调长期事实不应悄悄变成强制指令，这同样说明“记忆召回”和“修改行为规则”必须分离。[Reasonix Session Memory Retrieval](https://github.com/esengine/DeepSeek-Reasonix/blob/main-v2/docs/SESSION_MEMORY_RETRIEVAL.md)

#### 是否值得现在做

**不值得做，且不是普通功能缺口。** 递归自改会引入权限升级、供应链、回滚、不可预测行为、隐私泄露和验证污染。它也不能直接改善知己的核心闭环；更快地产生代码变化不等于更可靠地发现和验证生活行动。

#### 裁决

不实现 Agent 自主递归自改。安全的未来替代形式只能是：

```text
Agent 提出改动建议 → 生成独立补丁/文档 → 人工审查
→ 隔离环境测试 → 人工选择是否应用 → 再次验证
```

这属于开发辅助流程，不属于产品运行时的自主权限。

## 5. 成熟方案调研：什么可以复用，什么不能照搬

| 方案 | 成熟能力 | 对知己最有价值的借鉴 | 不应直接搬入的部分 |
|---|---|---|---|
| [Pi Agent](https://github.com/earendil-works/pi) | 多供应商 API、Agent loop、tool calling、state management、可扩展 coding agent | runtime 与 provider/tool 解耦；统一模型适配的边界 | 默认权限接近启动它的用户；不带内置文件/进程/网络/凭据隔离，不适合作为桌面端整体替换 |
| [Hermes Agent](https://github.com/NousResearch/hermes-agent) | Memory Provider、自动 prefetch、turn sync、插件、MCP、Computer Use | 记忆 Provider 生命周期；单一外部 Provider；记忆与 Agent loop 解耦 | Python 运行时、外部记忆服务、Shell/浏览器/Computer Use 权限和配置复杂度 |
| [Reasonix Context Engine v2](https://github.com/esengine/DeepSeek-Reasonix/blob/main-v2/docs/SESSION_MEMORY_RETRIEVAL.md) | 指令/项目记忆/全局记忆/会话历史分层；作用域、冲突、过期和 BM25/CJK 召回 | 不让背景事实偷偷变成强制指令；项目事实优先；词法召回先于语义平台化 | coding-agent 的终端、hooks、自改和更大权限面 |
| [MiniSearch](https://github.com/lucaong/minisearch) | 内存全文索引、BM25+、字段存储、自定义 tokenizer、零传递依赖 | 复用成熟排序并接入 `Intl.Segmenter` / CJK 词片；索引按调用重建 | 不持久化索引，不把 fuzzy 当中文语义召回 |
| [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk) | MCP Client/Server、工具/资源/提示词、stdio/HTTP、会话与授权 | 将来需要外部工具时使用官方 SDK 和固定版本 | 没有外部任务时不引入；不让外部 Schema 绕过知己 Main Process 权限边界 |
| [DeepSeek API](https://api-docs.deepseek.com/guides/tool_calls/) | Tool Calls、Thinking tool turns、JSON Output、strict tool schema | 遵守官方消息回放、`reasoning_content`、工具参数和 JSON 约束 | 把 API 支持误写成产品能力；模型不能替代宿主执行、校验和权限控制 |

复用原则是：**复用接口、生命周期和成熟协议；不复用不适合知己的权限、存储、运行时和产品入口。**

## 6. 高性价比路线：现在保留什么，未来只在什么证据下扩展

### 6.1 当前应保持的最小闭环

```text
DSH AgentLoop
  → 受控工具定义
  → Main Process Zod 校验与领域服务
  → 本地日志/复盘/验证模式检索
  → 必要时受控联网
  → 预览—用户确认—正式写入
  → JSONL 会话持久化与恢复
```

这条链已经覆盖知己最主要的 Agent 工程价值，不需要再叠加一个通用 Agent 平台。自然中文召回和命中后 Renderer 证据可见这两个连续缺口已在 `v2.6.0` 补齐；仍保留不持久化、只读和来源可核实边界。

### 6.2 后续再评估的证据顺序

| 优先级 | 可能扩展 | 必须先出现的证据 | 首选成熟路径 |
|---:|---|---|---|
| 1 | 中文词法召回 | 已修复自然长问题整段词项漏召回 | MiniSearch 内存 BM25+ + `Intl.Segmenter` + CJK 二元词片 |
| 2 | 有限同义候选 | 已支持“任务过大”与“行动拆解”这类有限词面差异 | DeepSeek Tool Call 提供至多 3 个受限候选；不写入记忆 |
| 3 | 只读证据卡片 | 已让观看者核实模型使用的本地记录 | 复用 Main Process 已校验结果；默认 3 条、最多 8 条；不持久化 |
| 4 | 版本事实统一 | 已消除根项目与 Electron 的版本冲突 | `v2.6.0` 统一版本并通过打包验证 |
| 5 | 记忆自动预取 | 用户反复手动要求“先搜索我的记录”，且误召回风险可控 | 参考 Hermes `prefetch`，加入预算、来源和关闭选项 |
| 6 | 单一多模态输入 | 有稳定的图片或音频任务，且模型端点、隐私、回放都可验证 | 复用 provider content parts，只做一种媒体 |
| 7 | MCP | 有具体外部 Server、真实任务和明确权限需求 | 使用官方 MCP SDK，Main Process 统一适配 |
| 8 | 结构化工作流 | 某个下游消费者因自然语言解析反复失败 | 单工作流 Schema + Zod + 有限重试 |
| 9 | 任务规划器 | 有可重复、长耗时、需要取消/恢复的多步业务流程 | 先做可见任务状态，不先做多 Agent |
| 不做 | Computer Use | 无论何时都不能仅凭行业趋势启动 | 只有独立安全设计和具体任务后重新立项 |
| 不做 | 递归自改 | 不接受运行时自主修改自身权限和代码 | 只保留人工审查的补丁/提案流程 |

### 6.3 不把速度当质量结论

DeepSeek V4-Flash “很快”只能说明当前请求的响应延迟较低，不能推出答案质量高或低。质量至少受以下因素共同影响：

- 任务是否需要真实外部事实；
- 是否正确调用并理解工具结果；
- 是否保留 thinking tool turn 的 `reasoning_content`；
- 是否在压缩后保留关键约束；
- 是否给出可读、可执行、可验证的行动；
- 是否在不确定时承认没有证据。

因此，当前更高性价比的做法是保持工具、上下文、记忆和输出边界清晰，再通过真实使用样本观察，而不是因为速度快就更换整个 Agent 框架或堆叠能力名词。

## 7. 最终能力清单

### 当前具备

- DSH `0.1.0-rc.8` 官方上下文 token 计量、工具结果裁剪和基础压缩；
- DeepSeek Function Calling 的受限宿主执行闭环；
- 有限多轮工具规划和 thinking/reasoning 回放；
- JSONL 会话持久化、列表、resume 和工具回合重放；
- 本地日志、复盘、项目、验证模式读取；
- `zhiji.memory.search` 本地字符串/词法历史检索入口；
- 受控公开来源联网搜索和来源绑定读取；
- 工具/工作流的 Zod 结构化输入输出；
- 普通回答的 Markdown/GFM 可读渲染；
- 正式写入的预览—确认—执行边界。

### 仅部分具备

- **长期记忆**：有本地词法检索与当前回合证据卡片，但无语义记忆、自动预取、冲突/过期/忘记产品层；
- **Agent 自主规划**：有工具回合，无通用任务队列、后台调度、子 Agent 和任意文件操作；
- **Structured Output**：工具和工作流结构化，普通回答不做全局 JSON；
- **上下文管理**：有运行时压缩和会话持久化，但极限长度下的信息保真仍需真实样本观察。

### 当前不具备，也不建议现在接入

- 完整 RAG 生命周期、语义向量检索、混合召回和重排；
- 标准 MCP Client 与外部 MCP Server 生命周期；
- 图片、音频、视频的端到端模型输入与附件管理；
- 通用 Computer Use、桌面截图定位、鼠标键盘控制、沙箱和回滚；
- Agent 自主修改代码、Skill、提示词、工具、权限并递归再次执行。

## 8. 一句话决策

**知己现在不需要成为“什么都能做的 Agent”；作为作品集，它需要证明自己能从真实记录中检索证据、通过受控工具完成有限步骤，并让观看者直接核实依据。**

保留 DSH 的上下文和工具基础，准确表述现有检索边界；“MiniSearch 中文词法召回 → 受限同义候选 → 证据卡片 → 版本事实统一”已完成。只有明确任务证明当前层不够时，才评估 embedding、多模态、MCP 或最小任务状态。Computer Use 和递归自我改进不属于当前产品边界。

## 9. 相关项目文档

- [本地长期记忆检索 Spec](specs/2026-08-22-agent-memory-search.md)
- [历史执行规划](2026-08-22-agent-capabilities-execution-plan.md)
- [能力审计与作品集定位](reviews/2026-08-22-agent-capabilities-audit.md)
- [本地证据卡片 Spec](specs/2026-08-22-agent-evidence-cards.md)
- [本地证据卡片执行计划](2026-08-22-agent-evidence-cards-execution-plan.md)
- [中文检索与证据卡片执行提示词](2026-08-22-agent-retrieval-evidence-execution-prompt.md)
- [项目当前状态](../PROJECT_STATUS.md)
- [Agent 输出与上下文历史记录](../CHANGELOG.md)
