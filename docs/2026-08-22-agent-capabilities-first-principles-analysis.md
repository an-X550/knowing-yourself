---
created: 2026-08-22
last_updated: 2026-08-22
---

# 知己 Agent 十项能力：第一性原理分析与裁决

## 结论先行

不建议为了“能力清单看起来完整”把十项能力全部接入。知己的核心价值不是成为通用电脑代理，而是把本地日志、复盘、验证模式收敛成可验证的行动闭环。当前最值得立即做的只有两项：

1. **能力自述校准**：让 Agent 按当前真实代码回答“我有什么能力”，修正截图中把已具备的上下文压缩误报为“不具备”、把内部工具桥说成模糊能力的问题。
2. **本地长期记忆关键词检索**：新增一个只读 `zhiji.memory.search` 工具，检索知己已有的日志、复盘和已确认验证模式。它先解决“能找回过去发生过什么”，不引入外部记忆服务、向量数据库或自动写入。

其余能力的裁决是：已有能力不重复建设；没有当前证据、会扩大安全边界或会显著增加维护成本的能力暂不做。这个结论不是拒绝未来演进，而是把每项能力放在“真实问题—最小机制—可验证收益”的顺序中。

## 评估基准

从第一性原理看，能力是否值得做取决于四个问题：

- 是否有当前、具体的使用问题，而不是行业清单带来的焦虑？
- 是否直接服务“发现模式 → 形成行动 → 后续验证”的核心闭环？
- 现有能力、提示词或一个小适配器是否已经足够？
- 能否在本地立即验证正确性、隐私边界和用户收益？

还要区分五层概念：

```text
模型能力（能生成什么）
  ≠ API 协议（能否输出工具调用/JSON）
  ≠ Agent Runtime（能否循环、压缩、持久化）
  ≠ Host Tool（宿主实际允许访问什么）
  ≠ 产品能力（用户能否安全完成目标）
```

例如 DeepSeek API 的 Function Calling 只会生成函数名和 JSON 参数，函数本身必须由宿主执行；模型不会因为 API 支持 tool call 就自动访问网页、文件或电脑。[DeepSeek Tool Calls](https://api-docs.deepseek.com/guides/tool_calls/)

## 当前代码事实

截至本次审计，桌面端已经具备：

- DSH `TokenMeter`、`ToolResultPruner`、`BasicCompactionEngine`，并在 Utility runtime 启动时注册；不是截图所说的“没有主动上下文压缩”。
- DSH `AgentLoop`、工具定义、Main Process `AgentToolDispatcher`、共享 Zod schema 和 DeepSeek API 工具名映射；Function Calling 已是正式链路。
- JSONL 会话持久化、重启后的列表/resume、工具回合重放和 reasoning 流。
- `journals/reviews/projects/patterns/web` 等受控工具；web 搜索结果通过会话内 `sourceId` 读取，最近已切换到 Electron `net.fetch`。
- 具体工作流的 JSON/Zod 结构化输出，例如验证模式候选和正式复盘；普通 Agent 回复故意使用 Markdown，不强制输出 JSON。

当前尚未具备或只具备部分能力：

- 没有专门的本地长期记忆检索工具；现有日志/复盘工具主要是列表、按 ID 读取和日期/项目筛选，模型不能稳定按关键词找回较早内容。
- 没有标准 MCP Client；现有工具桥是知己自己的 MessagePort + Main Process 校验协议。
- Renderer 到模型的消息契约目前是文本块，没有图片、音频、视频和附件的端到端传输。
- Agent 可以连续进行多轮工具调用，但没有通用的自主任务队列、子 Agent 编排、任意文件修改或后台运行权限。
- 没有向量数据库、embedding 管线、chunk/index 生命周期或检索评测闭环；当前 web 搜索是受控公开来源检索，不等于本地 RAG。
- 没有 Computer Use 权限、桌面截图/坐标输入、沙箱和回滚系统，也没有递归修改自身代码/提示词/工具的机制。

## 十项能力裁决

| # | 能力 | 当前事实 | 是否值得现在做 | 裁决与最小路径 |
|---:|---|---|---|---|
| 1 | 上下文压缩 | 已接入 DSH 官方 token meter、工具结果裁剪和 basic compaction；会话仍保留 JSONL 原始事件 | 否，重复建设 | **不新增**。补齐能力自述和验证说明即可；不自研摘要器、不复制 Pi/Hermes 的另一套压缩链。 |
| 2 | 长期记忆检索 | 可读取日志/复盘/模式，但缺少跨时间关键词入口；截图中的“部分具备”基本正确 | 是，收益直接且成本低 | **立即做** `zhiji.memory.search`。只读检索现有权威 Markdown/模式仓储，返回有限脱敏摘要和 ID；不自动写记忆。 |
| 3 | Function Calling | DSH ToolRuntime + Main Process dispatcher + DeepSeek 工具名兼容映射已在用 | 否，已具备 | **不新增**。继续让所有工具经过共享 Zod、Main Process 权限和已有确认门。 |
| 4 | MCP 工具调用 | 当前内部工具桥不是 MCP；官方 TypeScript SDK 可做 Client，但需要管理 stdio/HTTP、进程生命周期、认证和每个 server 的权限 | 暂不值得 | **暂不做**。当前没有明确 MCP server、用户配置需求或验收场景；先保留适配边界。若未来接入，使用官方 SDK v1 生产线，不复制协议。 |
| 5 | 多模态理解 | 当前消息、provider 和 Agent 回放都是文本契约；图片/音频/视频还没有安全的附件生命周期 | 暂不值得 | **暂不做**。先确认目标场景（图片日志、截图诊断还是语音输入）和 V4-Flash 端到端支持，再做单一媒体类型，不一次铺开多模态平台。 |
| 6 | Agent 自主规划 | DSH AgentLoop 可多轮思考、调用多个工具；正式写入、周期复盘仍有用户确认门 | 暂不新增独立规划器 | **保留现状并校准表述**。多步工具回合已经是有限自主规划；不引入复杂 Planner、子 Agent 或后台任务，避免与知己确认边界冲突。 |
| 7 | RAG 检索增强 | web 是公开来源检索；本地资料缺少关键词召回，向量 RAG 全链路不存在 | 是，但先做可解释基线 | **与 #2 合并做第一阶段**。关键词/短语召回是可验证的本地 RAG v0；暂不引入 embedding、向量库和外部记忆服务。 |
| 8 | Structured Output | 工具参数/结果走 Zod；验证模式和正式工作流已有 JSON 输出；普通回复按产品要求使用 Markdown | 否，不能全局强制 | **不新增全局 JSON 模式**。未来仅为有明确下游消费者的单个工作流开启 strict/JSON；不牺牲对话可读性。 |
| 9 | Computer Use | 当前没有桌面控制、截图定位、权限审批、沙箱、回滚和防误操作机制 | 否，风险高且偏离核心 | **明确不做**。它会把本地日志助手扩大为可操作电脑的高风险代理；没有具体业务闭环和安全设施时不接入。 |
| 10 | 递归自我改进 | 没有也不应默认拥有自改代码、提示词、工具或权限的能力 | 否，边界不成立 | **明确不做**。允许用户和开发流程显式更新代码/Skill/提示词，但不允许 Agent 自主修改并再次执行自身。 |

## 成熟方案调研与复用边界

### Pi Agent

Pi 提供统一多供应商 API、Agent loop、tool calling 和 state management，适合参考运行时抽象；但其 README 明确指出默认没有内置文件、进程、网络和凭据权限限制，需要宿主自行 sandbox/containerize。[Pi Agent README](https://github.com/earendil-works/pi)

知己已经有 DSH AgentLoop 和更窄的 Main Process 工具边界。整体替换 Pi 会重复运行时、打包和持久化工作，还可能削弱现有安全边界，因此不采用整体迁移；只借鉴其“runtime 与工具解耦”的思路。

### Hermes Agent

Hermes 的成熟做法是把长期记忆抽象为 provider 生命周期：`prefetch`、`sync_turn`、工具检索和可替换后端；它还用 FTS5 做跨会话搜索，并把外部 memory provider 做成可插拔选项。[Hermes memory providers](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/memory-providers.md) [Hermes README](https://github.com/NousResearch/hermes-agent)

这证明“记忆检索应与 Agent loop 解耦”是成熟方向。但知己目前的权威数据是本地 Markdown，规模和具体痛点尚不足以支付 SQLite/embedding/外部 provider 的维护成本；本次先做不引入依赖的只读关键词适配器，并把将来切换 FTS5/向量后端的边界写清楚。

### Reasonix

Reasonix 的 README 已说明旧 TypeScript 线处于 maintenance mode，活跃开发已转向 Go rewrite；它提供 MCP、插件、hooks、memory 分类和 cache-aware context maintenance 等可参考设计。[Reasonix README](https://github.com/esengine/DeepSeek-Reasonix)

Reasonix 更像通用 coding agent 平台，不适合直接嵌入知己的 Electron Main/Utility 安全架构。只复用“插件/工具/上下文维护应有明确生命周期”的思想，不引入其终端、hooks、shell 或自改能力。

### MCP 官方 SDK

官方 TypeScript SDK 提供 MCP Client/Server、stdio、Streamable HTTP、认证和工具发现；当前 main 分支 v2 仍是 pre-alpha，仓库建议生产使用 v1.x。[MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk) [MCP Client Guide](https://github.com/modelcontextprotocol/typescript-sdk/blob/main/docs/client.md)

MCP 是成熟协议，但“协议成熟”不等于“此刻值得接入”。知己缺少具体 server 配置、权限 UI、进程退出策略、工具数量上限和用户验收样本。本轮不安装 SDK，不启动任意外部进程，不改变既有安全边界。

### DeepSeek 官方接口

DeepSeek 当前 API 已支持 Function Calling、并行工具调用和 Beta strict tool schema；JSON Output 适合有明确机器消费者的场景。Thinking 模式的工具回合要求完整回传 `reasoning_content`，当前知己已在 DSH 回放链路中保留 reasoning。[Tool Calls](https://api-docs.deepseek.com/guides/tool_calls/) [JSON Output](https://api-docs.deepseek.com/guides/json_mode/) [Thinking Mode](https://api-docs.deepseek.com/guides/thinking_mode/)

因此不把 DeepSeek API 的“支持”误写成产品的“自动具备”：函数执行、校验、权限、记忆存储和输出展示仍由知己负责。

## 风险边界

- 本次不删除、不迁移、不重写现有 Skill 系统、日志仓储、DSH 会话或用户数据。
- `memory.search` 只读现有数据，不接受路径、URL、Shell、写入指令或任意代码。
- 结果只回传稳定 ID、日期、有限摘要；沿用现有路径/URL 脱敏策略。
- 不增加 hash、baseline、冻结 contract 或质量 gate；用普通单元测试、类型检查、打包和可复现样例验证即可。
- 不新增 MCP、Computer Use、递归自改、外部向量服务或新的 API Key。
