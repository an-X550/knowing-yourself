---
created: 2026-08-21
status: 已完成；目标模式执行完成
scope: apps/zhiji-desktop Agent
---

# 知己桌面端 Agent 输出质量与上下文控制：第一性原理分析

## 结论先行

这次问题值得做，但不值得把 Agent 一次性改造成“完整通用 Agent 平台”。最小高性价比路径是：

1. 立即处理 Agent 输出可读性：采用成熟的 Markdown 渲染器，补上 Agent 的格式契约，并用截图中的“Markdown 标记挤在一行”作为回归样例。
2. 立即补上 Agent 的思考模式控制和当前模型可见性。模型输入框已经存在，缺口是 Agent 没有独立的思考开关，用户也看不出当前请求实际使用的模型/模式。
3. 暂不为通用聊天强行加入 Structured Output。正式日志、复盘和工具调用已经分别使用 Zod/JSON 与结构化工具协议；自由对话应保留 Markdown。
4. 不自研上下文压缩，直接接入官方 DSH compaction 能力。已确认 `dsh-compaction`、`dsh-compaction-basic`、`dsh-token-meter` 和工具结果裁剪包存在 `0.1.0-rc.8` 版本，peer 版本族与当前 DSH 相容；本轮已完成官方包最小组合、工具回合、持久化和打包验证。

因此，本轮已完成“输出质量 + 思考控制 + 官方上下文管理最小接入验证”的闭环；完整 Pi runtime 替换和通用 Structured Output 仍不做，因为它们会重复现有 DSH/安全/正式工作流能力，且不能直接解决截图中的可读性问题。

## 一、需求与约束的区分

### 用户实际要求

- 截图中的 Agent 回复虽然含有 Markdown 标记，但视觉上挤成一段，用户无法快速阅读；让 Agent 自己重新格式化也没有稳定解决。
- Agent 响应很快，但用户无法判断这是模型能力、关闭深度思考、上下文过短还是质量不足造成的。
- 希望有通用 Agent 的模型选择、思考模式选择、上下文管理、上下文压缩和必要的结构化输出。
- 先判断是否值得做、现在做是否高性价比，优先复用 GitHub/官方成熟方案，不重复造轮子。

### 不是本次需求的内容

- 用户提供的截图只作为问题证据，不是要复制到仓库的产品文案。
- 项目内 `AGENTS.md`、`CLAUDE.md` 和共享契约是执行约束，不是 Agent 要回答的内容。
- 不改变日志、复盘、确认、正式写入、safeStorage、备份和回收站安全边界。
- 不把“响应更慢”或“增加 JSON 字段”本身当成质量提升。

## 二、已知事实、假设和不可突破约束

| 类型 | 证据或判断 |
|---|---|
| 已知事实 | `agent-page.tsx:119-120` 已将已完成消息和流式消息交给 `MarkdownDocument`，不是完全没有渲染层。 |
| 已知事实 | `markdown-document.tsx:7-71` 是自定义的有限解析器，只覆盖少量标题、列表、引用、表格和行内语法，并要求块级 Markdown 具有真实换行。 |
| 已知事实 | 截图中可见 `###`、`---`、`|` 等标记连在正文中；这说明至少有一类输出在进入渲染器时缺少可识别的块边界。确切原始字节仍需用脱敏 fixture 或一次本地复现确认。 |
| 已知事实 | `dsh-runtime.ts:108` 的 Agent persona 没有实际换行、标题、列表或代码块规则；`dsh-runtime.ts:149-164` 会把 DSH 当前消息投影到 Main Process 的模型桥。 |
| 已知事实 | `openai-compatible-provider.ts:47-48,69-73` 对 DeepSeek Agent 固定发送 `thinking: { type: 'disabled' }`，这是此前为规避工具回合缺少 `reasoning_content` 的兼容性修复。 |
| 已知事实 | 设置页已有全局模型输入框；`ConfigureAi.streamAgent()` 每次从当前配置读取模型。当前没有 Agent 专用思考开关，也没有在 Agent 页面显示当前模型/模式。 |
| 已知事实 | `agent-protocol.ts` 的消息数量上限不是 token 预算、上下文窗口测量或压缩；本轮已将官方 `dsh-token-meter`、`dsh-compaction-basic` 和工具结果裁剪包加载进当前 Utility runtime。精确版本为 `0.1.0-rc.8`，peer 版本族与当前 DSH 对齐。 |
| 未验证假设 | 截图中的挤行是否每次都由模型缺少换行造成，还是还叠加了打包产物/字体/CSS 问题。先用固定脱敏文本和真实请求体分别验证。 |
| 未验证假设 | 用户是否已经遇到长会话上下文溢出；目前只有“没有压缩能力”的代码事实，没有长会话失败样本。 |
| 不可突破约束 | API Key 继续只在 Main Process；Renderer 只接收脱敏配置；不开放 Shell、任意文件、任意 URL 或绕过确认的写入。 |

## 三、根因链路

### 1. “有 Markdown 但堆成一段”不是单一问题

可读性链路是：

```text
模型生成文本
  → DSH assistant/message 事件
  → AgentFacade 保存 content
  → AgentPage 交给 Markdown 渲染器
  → 浏览器块级布局
```

当前至少有三个可能断点：

- 生成契约断点：系统 persona 没有要求“标题、列表、表格必须使用真实换行”，用户临时要求格式时，模型可能只插入 `###` 和 `---` 字符。
- 解析能力断点：自定义解析器只识别标准形式，例如 `### 标题`；`###标题`、一行内的 `---###` 或复杂 GFM 语法不会变成块元素。
- 验证闭环断点：没有对 Agent 自由文本做 Markdown 可读性检查，也没有失败后的确定性修复策略，因此“让模型再改一次”仍然依赖模型自觉。

第一性原理上，用户要的是“信息层次一眼可见”，不是“输出中出现 Markdown 字符”。所以应先修复渲染和生成契约，不能只继续加强一句“请用 Markdown”。成熟方案优先采用 `react-markdown` + `remark-gfm`，不启用 raw HTML；它们分别由 [remarkjs/react-markdown](https://github.com/remarkjs/react-markdown) 和 [remarkjs/remark-gfm](https://github.com/remarkjs/remark-gfm) 维护。

### 2. “回答快”不能推出“质量差”

当前 DeepSeek Agent 被明确关闭 thinking。于是“首字快、总时延短”是预期现象，但它只说明生成路径短，不能证明事实性、工具选择、上下文利用和行动建议质量。

更有解释力的变量是：

```text
质量 = 模型能力 × 有效上下文 × 思考预算 × 输出契约 × 工具正确性
```

当前用户看不到其中的“思考预算”和“当前模型”，也没有同一问题在不同模式下的对照。因此现在最值得补的不是一个伪精确的质量分数，而是让用户能够选择模式，并用固定样例比较结果。

### 3. 持久化会话不是上下文管理

DSH JSONL 持久化解决的是“重启后恢复会话事件”；它没有解决“模型请求将多少历史送入上下文”。当前桥接把 DSH 派生的消息投影给 OpenAI 兼容请求，协议只限制消息数量，不测量 token，也不在压力下摘要旧内容。

官方 DSH 当前提供 `dsh-compaction`、`dsh-compaction-basic`、`dsh-token-meter` 和工具结果裁剪包这条成熟能力链，设计上包含压力触发、摘要、工具结果裁剪和持久事件。精确查询确认这些包均有 `0.1.0-rc.8`，peer 版本族可与当前 DSH 对齐；本轮已验证当前 Utility composition 的启动、工具回合、持久化、恢复和打包加载。由于 DeepSeek V4 的官方上下文窗口为 1M，本轮没有用真实超长会话强行制造压力调用，不能把“已接入”表述成“已完成真实摘要质量验证”。

Pi agent 也提供成熟的 `transformContext`、上下文用量、压缩条目、模型选择和 thinking level 设计。它适合作为交互和数据模型参考；完整替换当前 DSH runtime 则会重复现有 DSH 会话持久化、工具桥、正式工作流确认和安全隔离，迁移成本高，不能证明是高性价比。因此优先使用当前 DSH 官方扩展点，只有官方组合出现无法修复的宿主缺口，才做一次小范围 Pi core 适配性验证，不引入第二套 Agent runtime。

所以当前正确动作是兼容性 POC + 最小官方接入，而不是自写“保留最近 N 条消息”的压缩逻辑。后者会破坏工具调用/结果配对、重启恢复和上下文可重建性，属于重复造轮子。

### 4. Structured Output 不是所有回答的默认形态

DeepSeek 的 JSON Output 适合“模型输出要被程序继续解析”的一次性任务；官方要求 `response_format: { type: 'json_object' }` 并在提示词中明确 JSON。知己已有：

- 日志/复盘内部生成使用 JSON object + Zod 解析；
- Agent 工具调用使用 DSH 工具 schema + 共享 Zod 校验；
- 页面结果卡使用 `AgentPresentationCardSchema`。

把所有 Agent 自由回复强制成 JSON，会让普通对话失去自然语言和 Markdown，还可能与工具调用回合的 `reasoning_content`/消息重放兼容性冲突。当前没有具体的“自由回复解析失败事故”证明需要这一层，故不新增。

## 四、价值—成本判断

| 方向 | 真实问题 | 成本 | 现在判断 |
|---|---|---:|---|
| 成熟 Markdown 渲染 + Agent 格式契约 | 截图中的信息不可读，直接影响每次 Agent 使用 | 低—中 | 现在做，收益直接且可用 DOM/fixture 验证 |
| Agent 思考开关 | 当前 DeepSeek 被固定关闭 thinking，用户无法在速度与质量间选择 | 中 | 现在做最小全局设置，先不做复杂 per-session 配置 |
| 模型可见性/预设 | 全局模型字段已有，但 Agent 页面没有告诉用户当前使用什么 | 低 | 与思考开关一起补充显示；不做模型市场或自动发现 |
| 官方 DSH compaction 最小接入 | 解决上下文长期增长，并复用官方 token/摘要/裁剪语义 | 低—中 | 现在做兼容性 POC；组合通过就接入，失败则记录具体宿主缺口 |
| 完整替换为 Pi agent runtime | 获得成熟模型/思考/压缩 UX，但会重做当前 DSH 会话、工具和安全边界 | 高 | 不做；只复用 Pi 的成熟概念作为设计参考 |
| 自研上下文压缩 | 解决潜在问题，但要维护 token、工具配对、失败恢复和持久化语义 | 高 | 现在不做 |
| 通用 Structured Output | 当前没有具体解析事故；会压缩自由对话能力 | 中—高 | 现在不做 |
| 自动质量评分/速度门禁 | 容易把代理偏好伪装成客观质量，并新增维护负担 | 中 | 不做 |

## 五、本轮裁决

### 进入执行

- Agent 回复使用成熟 Markdown 解析，保持不执行 raw HTML。
- Agent persona 增加可执行格式契约：标题/列表/表格/代码块使用真实换行，短答也保留段落边界，不把 Markdown 标记挤在行内。
- DeepSeek Agent 增加可选 thinking enabled/disabled；启用时若工具回合仍缺少必要 reasoning replay，必须明确失败或降级，不能静默伪装为已深度思考。
- Agent 页面显示当前 provider/model/thinking 状态，并能直达设置调整。
- 新增脱敏 Markdown fixture、请求体测试和人工质量对照记录；这些是验证证据，不新增 hash、baseline 或产品 gate。

### 官方 POC 与最小接入

- 在当前精确 `0.1.0-rc.8` 依赖族上验证并接入官方 compaction/token-meter/工具结果裁剪组合。
- 用不含个人内容的长会话 fixture 验证 token 统计、压力触发、摘要后的工具回合、持久化和恢复；不把 IPC 的消息数上限当成上下文管理。
- 若组合通过，保留官方包和最小宿主适配；若失败，记录具体 API/事件/打包缺口，禁止为了接入而升级或 fork 整套 DSH。
- 不把“尚无线上溢出事故”当作不做基础能力的理由：官方包已经与当前版本族对齐，接入成本和回归范围可控，且可通过普通测试验证；不做的仍是自研替代和完整 Pi runtime 替换。

### 明确不做

- 不强制所有普通 Agent 回答为 JSON。
- 不把响应慢当成质量高，也不添加质量分数或自动拦截。
- 不升级整套 DSH 依赖来“顺便”获得 compaction。
- 不改正式日志/复盘生成链路，不把 Agent 自由文本当作正式产物写入。

## 六、最小验证问题

执行前后只需要回答这些问题：

1. 同一段包含标题、列表、表格、代码块的 Markdown，页面是否产生对应块元素，而不是显示 `###`/`|` 原文？
2. 截图中的缺少换行样例，原始 content 到底是缺少换行，还是仅渲染样式异常？
3. DeepSeek 请求体是否能按设置分别出现 `thinking: enabled` 与 `thinking: disabled`，且 API Key 仍不越过 Main Process？
4. 在相同模型、相同材料、相同问题下，thinking 开关是否改变可观察结果；若没有，是否应保留默认关闭以降低延迟和费用？
5. 官方 compaction 包能否在当前依赖族中安全加载和工作；如果不能，具体缺口是否值得另开适配，而不是升级整组 DSH？

本文件是分析结论与执行裁决；具体实现和验证证据见：

- `docs/specs/2026-08-21-desktop-agent-quality-and-context.md`
- `docs/2026-08-21-desktop-agent-quality-and-context-execution-plan.md`

## 七、执行结果与边界

- 已接入 `react-markdown@10.1.0` + `remark-gfm@4.0.1`，普通合法 Markdown 会按块元素渲染；raw HTML 不通过 `rehypeRaw` 执行，历史页面安全回归保持通过。
- 已接入 DeepSeek Agent thinking 开关、reasoning 流与工具回合重放，并在 Agent 页面显示实际 provider/model/thinking；默认仍为关闭，速度不能作为质量证明。
- 已接入官方 DSH token meter、basic compaction 和 tool-result pruner（均为 `0.1.0-rc.8`），未新增自研压缩、消息粗暴截断、hash、baseline 或质量 gate。
- 52 个测试文件、296 个测试通过；typecheck 通过；lint 0 错误、6 个既有警告；桌面端打包通过。
- 截图中的原始文本若确实把 `###`、`---`、`|` 压在同一行，它仍可能是非法 Markdown；本轮不加入猜测式换行修复，优先依靠格式契约和成熟渲染器。真实模型的 thinking 开关质量对照需后续用受控问题和可用 API Key 单独观察。
