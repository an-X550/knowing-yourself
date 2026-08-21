---
created: 2026-08-21
status: 已完成；目标模式执行完成
analysis: docs/reviews/2026-08-21-desktop-agent-first-principles-analysis.md
---

# 知己桌面端 Agent 输出质量与上下文控制规格

## 需求目标

让知己桌面端 Agent 的输出可读、模型行为可解释，并为长会话上下文管理保留官方扩展路径。

> 作为使用知己 Agent 的用户，我希望回复真正按结构显示，并能选择当前 Agent 是否启用 DeepSeek thinking，以便在速度、成本和质量之间做有意识的取舍。

## 边界约束

- 不修改日志、日反馈、周/月/项目/年度复盘的正式生成和写入契约。
- 不改变 API Key 只在 Main Process 解密和使用的安全边界。
- 不增加 Shell、任意文件、任意 URL、任意 HTML 或绕过页面确认的 Agent 能力。
- 不把普通对话强制改成 JSON；Structured Output 只继续服务已有的内部解析场景。
- 不自研上下文压缩；优先接入已确认与当前 DSH `0.1.0-rc.8` 版本族相容的官方 compaction/token-meter 能力。若最小宿主组合失败，记录具体缺口，不升级或 fork 整套 DSH。
- 不新增 hash、冻结 contract、baseline 或质量 gate；测试只验证可观察的协议和渲染行为。

## 实施范围

### A. 输出可读性（本次实现）

- 用成熟的 CommonMark/GFM React 渲染方案替换有限的自定义 Markdown 解析，保留 frontmatter 剥离和 raw HTML 不执行的安全边界。
- 在 DSH Agent persona 中增加真实换行、块级结构和代码块规则。
- 对 Agent 已完成消息和流式消息使用同一渲染组件。
- 增加标题、列表、表格、引用、代码块、行内格式和截图式输出的脱敏回归样例。

### B. 模型与思考控制（本次最小实现）

- 复用现有全局 provider/model 设置，不建设模型市场和远程模型目录。
- 增加 Agent thinking 选项，至少支持 `disabled` 与 `enabled`；默认保持现有关闭行为，避免升级后无提示地增加成本和延迟。
- Main Process 将选项映射到 DeepSeek OpenAI-compatible 请求；非 DeepSeek provider 不发送 DeepSeek 专用字段。
- Agent 页面显示当前 provider、model 和 thinking 状态，并提供设置入口；不在 Renderer 暴露 Key。
- 若启用 thinking 的工具回合无法安全重放 reasoning 内容，明确提示不可用或回退到关闭模式；不得把失败请求伪装成成功。

### C. 上下文管理（官方最小接入）

- 已确认官方 `@deepseek-ai/dsh-compaction`、`@deepseek-ai/dsh-compaction-basic`、`@deepseek-ai/dsh-token-meter` 及工具结果裁剪包均存在 `0.1.0-rc.8`，peer 版本族可与当前 DSH 对齐。
- 在当前 Utility composition 中完成最小加载和运行验证：token 统计插件、官方 compaction/pruner 链路、工具回合、JSONL 持久化、恢复和打包加载；真实 1M 上下文压力与摘要内容质量不在本轮伪造验证。
- 通过后接入官方事件/引擎/裁剪能力，保留当前 DSH 会话和工具桥；不实现按消息条数粗暴截断。
- 若宿主 API 或打包仍有缺口，记录精确缺口并停止该扩展，不为接入而升级或 fork 整套 DSH。

### E. 成熟方案取舍

- Pi agent 的 `transformContext`、compaction entry、context usage、model selection 和 thinking level 作为成熟交互/数据模型参考。
- 不整体替换当前 DSH runtime：现有项目已经依赖 DSH 的会话持久化、工具桥、正式工作流确认和安全隔离，整体迁移成本高且会重复实现宿主能力。
- Markdown 使用成熟 CommonMark/GFM React 生态；安全上不启用 raw HTML。thinking 继续通过当前 Main Process provider 适配，不引入第二个模型/Agent runtime。

### D. Structured Output（本次不扩展）

- 保留已有 `collect(..., { jsonObject: true })` + Zod 的内部结构化生成。
- 保留 Agent 工具 schema、工具桥 schema 和结果卡 schema。
- 普通助手消息继续是自然语言/Markdown，除非未来出现具体的、可复现的解析事故并单独通过必要性闸门。

## 验收标准

- [x] 脱敏 Markdown fixture 中的标题、列表、表格、引用、代码块和行内格式在 Agent 消息区域呈现为对应 HTML 元素，不显示原始 `###`、表格分隔线或代码围栏。
- [x] 流式输出与完成后的同一内容使用同一渲染规则；完成后不会因重新渲染改变结构。
- [x] Agent persona 明确要求真实换行；但真实模型输出质量对照尚未作为通过依据。
- [x] Settings 可保存 Agent thinking 选项；关闭时请求保持现有 `thinking: { type: 'disabled' }`，开启时按设置发送 enabled，且 Key 不进入 Renderer/DSH session。
- [x] Agent 页面显示实际 provider/model/thinking 状态；更改模型仍复用现有 provider 配置和安全保存流程。
- [x] 现有正式日志/复盘、确认门、备份恢复和 Agent 工具安全测试全部保持通过。
- [x] 上下文 POC 已给出“官方组合可接入”结论；只引入官方压缩运行时和最小宿主适配，不引入自研替代。

## 文件影响预估

- 修改：`apps/zhiji-desktop/src/renderer/components/markdown-document.tsx`
- 修改：`apps/zhiji-desktop/src/renderer/pages/agent-page.tsx`
- 修改：`apps/zhiji-desktop/src/main-process/agent/dsh-runtime.ts`
- 修改：`apps/zhiji-desktop/src/main-process/infrastructure/ai/openai-compatible-provider.ts`
- 修改：`apps/zhiji-desktop/src/main-process/application/configure-ai.ts`
- 修改：`apps/zhiji-desktop/src/shared/schemas/domain.ts`、`src/shared/schemas/ipc.ts`（若 Agent thinking 复用 provider 配置）
- 修改：设置页、preload/IPC 类型及对应测试（按实际契约影响收敛）
- 可能新增：`react-markdown`、`remark-gfm`（锁定经验证的版本；不启用 raw HTML）
- 测试：Markdown 组件、provider 请求体、设置保存、Agent 页面和打包后冒烟

## 实施计划

1. 先运行现有验证并用脱敏 fixture 判定截图问题是生成换行、解析器能力还是 CSS。
2. 接入成熟 Markdown/GFM 渲染器，补 Agent persona 的格式契约和渲染回归。
3. 增加 Agent thinking 设置，贯穿配置、Main Process 请求和 Agent 页面可见状态。
4. 验证并最小接入官方 compaction/token-meter；若宿主组合失败，记录 API/事件/打包缺口并停止，不 fork 或升级整套 DSH。
5. 运行类型检查、lint、单测、打包和既有 e2e；再更新项目状态、版本和 CHANGELOG。

## 执行结果

- 依赖：`react-markdown@10.1.0`、`remark-gfm@4.0.1`、官方 DSH compaction/token-meter/tool-result-pruner `0.1.0-rc.8`。
- 验证：52 个测试文件、296 个测试通过；typecheck 通过；lint 0 错误、6 个既有警告；桌面端打包通过。
- 未扩展：通用 Structured Output、完整 Pi runtime、自动质量评分、启发式非法 Markdown 修复、真实 API Key 下的 Flash thinking A/B 质量结论。

## 当前状态：已完成；目标模式执行完成
