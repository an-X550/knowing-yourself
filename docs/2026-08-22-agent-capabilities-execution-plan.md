---
created: 2026-08-22
last_updated: 2026-08-22
---

# Agent 十项能力执行规划

## 执行原则

本计划按“先复用、后适配；先只读、后写入；先可验证、后平台化”执行。不会整体替换 DSH，不安装未必要的 MCP/记忆/向量/Computer Use 依赖，不触碰知己原有 Skill 和用户数据。

## 阶段 0：分析与裁决（已完成）

- 读取当前 DSH runtime、工具桥、DeepSeek provider、会话持久化和现有状态文档。
- 查阅 Pi、Hermes、Reasonix、官方 MCP TypeScript SDK 和 DeepSeek 官方工具调用/JSON/Thinking 文档。
- 将十项能力分为“已有不重复”“立即做最小版本”“证据不足暂缓”“明确不做”。
- 形成 [`agent-capabilities-first-principles-analysis`](2026-08-22-agent-capabilities-first-principles-analysis.md) 与本 Spec。

## 阶段 A：能力自述校准（立即执行）

修改 DSH Agent persona，明确十项能力的真实状态：

- 已具备：上下文压缩、Function Calling、有限多步工具规划、内部结构化工具协议。
- 新增后具备：本地关键词记忆检索和基础可解释 RAG。
- 部分具备：长期记忆、RAG、Structured Output。
- 不具备：标准 MCP Client、多模态输入、通用 Computer Use、递归自我改进。

验收：Runtime 单元测试检查模型请求 system 文本包含关键边界，防止 Agent 再根据模型常识编造能力。

## 阶段 B：本地长期记忆检索（立即执行）

1. 新增只读 `AgentMemorySearchService`，复用现有 journals/reviews/verifiedPatterns 服务。
2. 在 shared Zod contract 中加入 `memory.search` request/result。
3. 在 Main Process dispatcher 中接入服务，继续使用 `safeText` 脱敏。
4. 在 DSH runtime 注册 `zhiji.memory.search`，不改变既有工具名称映射和模型桥。
5. 添加 service、schema、dispatcher、runtime 回归测试。

## 阶段 C：验证与发布

- 运行 focused tests：memory service、agent-tools、dispatcher、dsh-runtime。
- 运行 `npm test`、`npm run typecheck`、`npm run lint`。
- 运行 `npm run package` 与 `npm run test:e2e`。
- 核对打包 asar 只包含预期代码，未引入外部运行时依赖。
- 更新 `VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`；本地提交，推送由用户手动完成。

## 暂缓清单与触发条件

| 能力 | 当前动作 | 触发再评估的证据 |
|---|---|---|
| MCP | 不安装 SDK、不启动 server | 用户提供具体 MCP server、传输方式和至少一个真实任务 |
| 多模态 | 不改消息协议和 UI | 明确的图片/音频使用场景、模型接口支持和附件隐私方案 |
| 向量 RAG | 不建 embedding/index | 关键词检索在真实样本中失效，且数据规模/召回指标足以证明需要语义检索 |
| Computer Use | 不实现 | 明确高价值桌面流程、权限审批、沙箱、回滚和人工停止机制 |
| 递归自我改进 | 不实现 | 不接受“让 Agent 自己改自己”的默认授权；只有独立、人工审查的开发流程才可更新代码/Skill |

## 完成定义

完成不等于十项全部打勾，而是：事实与能力自述一致；本地历史记录可检索；既有工具/压缩/持久化/安全边界不回归；暂缓项有清晰触发证据；所有改动有自动验证和可回退的本地 Git 提交。
