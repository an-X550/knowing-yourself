# 知己 Skill Runtime 与本地 Agent 架构设计

## 结论

知己不应继续停留在“选择材料 → 调用 LLM → 保存 Markdown”的 AI 调用器，也不应嵌入一个可任意读写和自由规划的通用 Agent。第一阶段应升级为：

> **Windows 本地优先、单用户、应用开启时运行的 Skill Runtime。它以 `.claude/` 为业务规则真相，用 LangGraph JS 编排受控工作流；模型只能在明确的知己工具与确认边界内协作。**

这不是重造 Codex、Claude Code、OpenClaw 的 Agent Harness。Codex 等宿主提供通用文件、终端、浏览器和子代理能力；知己只复用成熟的流程编排、状态持久化和 Schema 校验，并自行保留不可替代的领域逻辑：证据规则、最小上下文、验证闭环、复盘结构与用户确认。

## 真实问题，而不是“是否要做 Agent”

### 用户真正需要的是可复现的知己方法，而不是多一个模型入口

现有 `.claude/` 已积累并反复优化：日反馈的 D0–D6 与 A–D 输入等级、昨日行动闭环、验证沉淀、复盘六问、自然语言路由、主题思考确认沉淀和副作用确认门。当前桌面端只将一部分规则硬编码为短提示词和材料选择，因此同一个“日反馈/复盘”在 Codex 与桌面端可能行为不同，用户也看不到模型依据和写入边界。

不能靠“再写一个更长 prompt”修复：证据读取顺序、是否写入、何时暂停确认、怎样恢复失败任务都必须由程序控制，而不是由模型临场决定。

### 已知事实、约束与价值取舍

| 类型 | 内容 | 架构含义 |
|---|---|---|
| 已知事实 | `.claude/` 是现有业务语义和运行规则的唯一真相；桌面端是 Electron + TypeScript、本地 Markdown/JSON、OpenAI-compatible API。 | 不建立第二套业务方法论；做受测试保护的适配层。 |
| 已知事实 | Windows 桌面端已有安全 IPC、密钥保护、原子写入、回收站、备份与 Zod Schema。 | 复用现有基础设施，不迁移到服务端。 |
| 不可突破约束 | LLM API 只会返回文本或工具调用请求；它不会自行读取用户磁盘、联网或执行本地写入。 | 所有工具均须由应用实现、校验、授权并把结果回传给模型。 |
| 第一阶段边界 | Windows、本地单用户、应用打开时运行、本地保存。 | 不做云端、后台常驻、多用户、移动端、飞书、滴答。 |
| 价值取舍 | 用户要的是高质量、可信、可回看，而非任意自治。 | 优先确定性工作流；仅在模糊意图处使用有限 Agent 决策。 |

## “受控 Agent”不等于功能受限

“不能任意读写文件或联网”指的是禁止模型获得无边界的系统权限，不是禁止主题思考、搜索或写入。

模型可以提出调用请求；应用按工具 Schema、路径策略和用户批准执行。举例：

| 用户能力 | 应提供的受控工具 | 不允许的替代方式 |
|---|---|---|
| 主题思考读取既有认识 | `read_thinking_index`、`read_selected_topics(max=2)` | 递归扫描任意磁盘目录 |
| 确认后沉淀主题 | `propose_topic_update` → `await_user_approval` → `commit_topic_update` | 模型直接覆写任意 Markdown |
| 用户明确要求查资料 | `web_search(query, domains?, recency?)`、`read_web_source(sourceId)` | 浏览任意 URL、执行网页脚本或悄悄联网 |
| 存档日志与复盘 | `save_validated_journal`、`save_validated_review` | 自由 `write(path, contents)` |
| 删除用户数据 | `move_known_record_to_trash(recordId)` | 自由 `delete(path)` |

联网工具只在用户明确要求检索、核查时注册，并在 UI 中显示“将检索什么”。搜索结果是外部证据，不自动改变长期认识或写入本地；任何沉淀仍要求用户确认。主题思考默认只读知己数据，且保持“首次讨论不写入、确认后才沉淀”的既有契约。

## 技术选型：复用什么，拒绝什么

### 推荐：LangGraph JS 作为编排内核

LangGraph JS 是 TypeScript 的低层状态图编排框架，可独立使用而不强制引入 LangChain。它提供条件路由、人工中断/恢复和检查点；SQLite checkpointer 适合本地工作流。其官方文档说明 `interrupt` 会保存 JSON 状态、等待用户输入，并以 `thread_id` 恢复；持久化把单次线程检查点与跨线程长期数据分开。[LangGraph JS](https://github.com/langchain-ai/langgraphjs)；[人工中断](https://docs.langchain.com/oss/javascript/langgraph/interrupts)；[持久化](https://docs.langchain.com/oss/javascript/langgraph/persistence)。

采用它是为了避免自研工作流状态机、暂停恢复与失败检查点；不是为了使用 LangChain 的通用 Agent、工具市场或服务端 Agent Server。

### 不作为第一阶段内核的方案

| 候选 | 判断 | 理由 |
|---|---|---|
| 继续手写所有状态机 | 不选 | 很快会重复实现图编排、暂停、恢复、审计与迁移兼容。 |
| LangChain 高层 Agent | 暂不选 | 对固定、强约束的知己流程过度抽象，模型自主循环反而增加漂移。 |
| DeepSeek Harness | 仅做隔离 Spike，不进正式依赖 | 官方项目是 TypeScript/MIT，但 README 明示仍处 developer preview 且将有破坏性变更；它的插件化通用 Harness 不应决定知己领域边界。[项目说明](https://github.com/deepseek-ai/deepseek-harness) |
| OpenClaw / AGNT | 不选 | 它们面向跨渠道、后台、插件、子 Agent 和通用个人助手；与第一阶段范围相比过重，带来维护和权限面。AGNT 自身定位为本地 Agent OS，包含 goals、plugins、traces、memory 等完整系统。[AGNT](https://github.com/agnt-gg/agnt) |

### DeepSeek Harness 的正确处理

在独立、不接触真实用户数据的 Spike 中验证它是否改善 DeepSeek 特定的工具调用、上下文压缩和协议兼容；只记录结果。它达到以下条件前，不能替换 LangGraph 或进入发布依赖：

1. 至少经历一个稳定发布周期且无阻断性 API 变化；
2. 能嵌入 Electron Main Process，不强制启动独立 Web UI/服务；
3. 能实现知己现有的路径范围、审批、审计和 Schema 输出要求；
4. 在日反馈金样本上至少不劣于现有 OpenAI-compatible Adapter。

## 目标架构

```text
React Renderer
  └─ 显示材料依据、生成状态、待确认操作和结果；不接触文件/密钥/网络
       ↓ 受校验 IPC
Electron Main Process
  ├─ Intent Router
  │    固定入口优先；仅把模糊自然语言分类到已注册工作流
  ├─ Zhiji Skill Runtime（领域适配层）
  │    ├─ Workflow Registry：每种能力的图、版本、输入和审批策略
  │    ├─ Context Builder：按契约建立最小证据包
  │    ├─ Domain Tools：受 Zod 与路径策略约束的业务能力
  │    ├─ Policy Gate：预算、超时、模型、隐私、读写和联网授权
  │    ├─ Output Validator：结构、证据引用、写入前检查
  │    └─ Audit Recorder：规则/材料/工具/模型/结果的可回看记录
  ├─ LangGraph JS
  │    ├─ 条件路由、暂停审批、失败恢复
  │    └─ SQLite checkpointer：只存运行状态和审计索引
  ├─ Existing Infrastructure
  │    ├─ Markdown/JSON repositories、atomic write、backup、recycle bin
  │    ├─ safeStorage credentials、OpenAI-compatible LLM adapter
  │    └─ IPC schemas 与 Electron security boundary
  └─ User Data Root
       ├─ journals/reviews/projects/profile：继续为可读 Markdown/JSON
       └─ runtime.sqlite：检查点、审计、待审批操作；不替代业务数据
```

### 状态、数据与审计分层

- **业务真相**：日志、复盘、项目、个人资料及其既有 Markdown/JSON；用户能直接备份、阅读和迁移。
- **规则真相**：`.claude/` 内的 command、agent、contract、paths；产品只实现受版本锁定的兼容映射。
- **运行状态**：`runtime.sqlite` 的检查点、任务状态、审批请求、审计索引。它损坏或删除时不能损坏业务数据；可从业务数据开始新运行。
- **审计事实**：每次运行记录 `workflowVersion`、规则映射版本、材料 ID 与版本、模型与 provider、工具调用摘要、用户审批、最终写入 ID 和失败原因。记录摘要与哈希，不复制 API Key 或无关完整隐私材料。

## Skill 适配：不是动态执行 Markdown

Skill Markdown 同时包含人类可读方法论、Codex/Claude 宿主工具名与业务规则。直接把它整个交给模型执行，会让模型自行解释工具、越过确认边界并制造不可复现的流程。

正确做法是“规则源 + 显式兼容映射 + 一致性测试”：

```text
.claude/command + agent + contract
  → 人工维护的 Compatibility Manifest
  → Workflow Definition（图、读取范围、工具、Schema、审批、写入）
  → Prompt Assembler + Context Builder + Validators
  → 金样本 / 契约测试
```

每个工作流清单至少声明：引用的规则文件和版本、输入 Schema、可读取材料、材料优先级、允许工具、模型输出 Schema、暂停条件、写入目标与后写校验。任何 `.claude/` 规则变更都触发兼容测试；若语义受影响而产品映射未更新，发布门应失败。

这保留“`.claude/` 是唯一业务规则真相”，但不让桌面安装包在运行时依赖开发者机器的 `.claude` 目录。分发时随应用发布经过构建校验的规则快照和 manifest，并记录快照版本；开发仓库仍是这些快照的来源。

## 工具、上下文和权限策略

### 先确定性路由，再有限 Agent 路由

日期选择、点击“生成周报”、日志保存等已知意图由程序确定性进入工作流。只有“最近有什么该补”“关于刚才再展开”等模糊表述才由模型输出受 Zod 校验的 `WorkflowIntent`，其值只能来自注册表。模型不能创建新工作流或升级权限。

### 最小证据包

上下文构建器按现有契约选择材料，而不把所有日志、完整聊天史或个人资料发送给模型：

- 日反馈：目标日志、上一日反馈、`verified-patterns`；仅在契约指定的冲突时补读。
- 周/月/项目复盘：先读下游沉淀物与证据包，只有冲突/引用缺失才读原始日志。
- 主题思考：先读 `thinking_index`；只有主题明显匹配时读取最多两篇，首稿不写入。
- 个人资料：只有用户明确启用后才加入；每次审计可显示“已使用/未使用”。
- 联网检索：只有用户显式提出搜索/核查、或某个经用户开启的工作流明确声明需要外部事实时才执行；结果来源 URL 与日期需显示给用户。

### 审批与副作用

| 动作 | 默认策略 |
|---|---|
| 在允许范围读本地知己数据 | 自动，显示材料摘要 |
| 调用用户已配置的 LLM | 自动，显示模型与将发送的材料类别 |
| 保存自动生成的日反馈 | 自动，但必须通过结构校验、原子写入和复读验证 |
| 更新长期主题、画像或验证模式 | 先展示差异，用户明确确认 |
| 联网搜索 | 用户显式请求后执行；显示查询与来源 |
| 导出、恢复、删除、外部发送 | 始终显式确认 |

## 第一阶段交付：日反馈闭环

不同时迁移所有 Skill。以日反馈建立可复用范式：

```text
输入日期
 → 查找日志
 → 读取上一反馈与验证沉淀
 → 建立证据卡并判断 A/B/C/D
 → D 级：返回一个补证问题并结束
 → A/B/C：调用模型取得严格 JSON
 → 结构、引用与长度校验
 → 确定性渲染
 → 原子写入、复读校验
 → 更新验证沉淀
 → 保存审计事件
```

**范围外**：飞书、滴答、云端、后台常驻、多用户、MCP server/marketplace、通用 shell、任意文件工具、子 Agent、向量数据库、自动长期记忆提炼。

### 后续迁移顺序

1. **兼容矩阵与金样本**：先建立所有桌面能力与 `.claude` 规则的差距表，不能凭“输出看起来像”宣称对齐。
2. **日反馈**：完成完整垂直切片与运行审计。
3. **周/月/项目复盘**：迁移材料优先级、复盘六问、证据不足降级、用户回应区和写入门。
4. **主题思考**：实现“讨论优先、确认后沉淀”的暂停/恢复图；增加显式联网检索工具。
5. **窄意图 Agent**：仅为模糊自然语言选择既有工作流，不增加自由自治。
6. **仅在真实证据出现时扩展**：例如关闭软件仍需等待审批、长时任务常失败、多个工作流并行等，再评估常驻服务、队列或更复杂框架。

## 验收与止损

### 日反馈第一阶段验收

- [ ] 同一金样本下，桌面端遵守与 `daily-review` / `daily-analyzer` 相同的 A–D 降级、昨日闭环和单行动边界。
- [ ] D 级输入绝不生成或保存正式反馈。
- [ ] 无上一行动证据时绝不推断“没做”。
- [ ] 输出不合 Schema、无可用引用或写入复读失败时，不产生正式反馈。
- [ ] 界面能看见本次读取的材料类别、规则版本、模型、写入结果和待确认操作，而不泄露完整内部思维链。
- [ ] 关闭或崩溃后，未完成运行能安全显示为失败/可重试；不会重复写入业务记录。
- [ ] 原有单元、集成、E2E、类型检查、lint 和 Windows 打包门保持通过。

### 不通过时的止损

若日反馈在金样本上未能达到 Skill 契约，停止迁移其他能力，先修复兼容层或回退到现有已验证实现；不得以“已经接入 Agent 框架”替代行为质量。若 LangGraph 的 Electron/SQLite 集成、包体积或升级成本高于手写的明确工作流并无可验证收益，可保留其接口边界后以小型本地状态机替换实现。

## 下一步

先撰写“桌面端 × Skill 兼容矩阵”和“日反馈 Runtime 设计”，然后再进入代码计划。DeepSeek Harness 验证独立进行，不接触真实数据，也不阻塞日反馈迁移。
