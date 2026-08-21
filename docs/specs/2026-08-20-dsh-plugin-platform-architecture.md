---
created: 2026-08-20
reviewed: 2026-08-21
status: superseded；不再执行
depends_on: docs/specs/2026-08-20-deepseek-harness-agent-architecture.md
superseded_by: docs/specs/2026-08-21-zhiji-dsh-plugin-architecture.md
---

# 知己桌面端与 DeepSeek Harness 插件平台融合架构

## 1. 决策结论

知己继续定位为“**本地优先的复盘领域 Agent 产品**”，不转型为通用 Agent 或编码 Agent。DeepSeek Harness（DSH）提供可组合的 Agent 与插件运行时；知己提供复盘领域能力、个人数据边界、正式产物、确认语义和面向普通用户的专业界面。

本轮采用以下架构方向：

1. 保留知己现有 React 桌面界面和日志、复盘、项目、设置等专业页面，不使用 DSH Web UI 替换产品主界面。
2. 将当前只手工注册固定工具的 DSH Utility Runtime，演进为“**知己专用 DSH Profile Host**”。
3. 优先复用 DSH 源码和官方 CLI 已有的 Cordis Loader、Profile/Bundle、配置热更新、只读 plugin inventory 和插件包管理，不另造第二套插件内核；只有与知己锁定版本匹配的发布包通过 P0 后才能进入产品依赖。
4. 知己只实现 DSH 无法替代的宿主适配：Electron 生命周期、Main Process 权限桥、复盘领域服务、正式写入确认、插件管理的薄 UI 和产品策略。
5. 初期支持 DSH 原生 Host 插件扩展 Agent 的工具、Skill、system-prompt section 和设置；不开放插件自定义 React 页面，不默认安装 Shell、任意文件或编码工具。
6. 插件包安装、更新或移除沿用 DSH 的 Profile 重启边界，只重启独立 DSH Utility Process；该能力对外称“安装扩展并重新加载”，不宣传为零重启热插拔。

这使知己有条件接入经过兼容和信任核验的 DSH 社区插件，又不会退化成一个比 Codex 能力更弱的通用 Agent 壳。它不承诺 GitHub topic 中任意仓库都可直接、安全安装。

## 2. 前面对话形成的有效共识

### 2.1 已确认的产品判断

- 原有 Skill 与桌面端可以共享同一套复盘方法和输出契约；桌面端的价值首先是把依赖 Codex/WorkBuddy 的能力产品化，让普通用户打开即用。
- 接入 DSH 后，当前前端主要增加了 Agent 会话入口；真正的变化在后端 Agent loop、工具调用、会话持久化、取消和确认桥。
- 当前知己已经具备受限领域 Agent 的基础，但只使用了 DSH 核心包，没有体现 DSH “一切皆插件”的 Profile、Loader 和插件生态。
- 用户明确希望拥抱 DSH 开放平台，让开发者制作并发布插件；这已从“未来可能需要”变为本轮主动选择的产品方向。
- 开放插件不能以牺牲知己定位为代价。知己仍以“记录 → 反馈 → 复盘 → 行动验证”为核心，不与 Codex 竞争代码编辑、Shell、通用工作区和任意自动化。
- DSH 源码已下载到仓库外，可用于接口核验、构建和插件机制研究；产品运行时优先消费官方发布包或可复现的官方构建产物，不复制上游源码进知己仓库，也不先维护 fork。

### 2.2 当前不作为前置条件的事项

- 暂不以目标用户观察作为架构实施前置条件。
- 暂不要求先完成真实模型驱动的 Agent 独立闭环验收。
- 不因为简历叙事而增加与产品目标无关的插件市场、云服务、向量库、通用文件系统或复杂规划器。

## 3. 第一性原理复核

### 3.1 真正问题

真正要解决的不是“让知己看起来更像 DSH”，而是：

> 如何让复盘能力可以由用户和开发者持续扩展，而不要求每次新增分析视角、数据来源或 Agent 工具都修改、重新发布知己核心，同时不把未经审核的宿主代码直接带进个人数据环境。

可安装扩展只有在解决这个问题时才有价值。“热插拔”不是产品目标，也不是安装第三方 Bundle 的准确术语；复制 DSH Web UI、展示插件术语或允许任意代码执行，都不是目标本身。

### 3.2 已知事实

- 当前桌面端锁定 DSH `0.1.0-rc.8` 与 Cordis `4.0.1`，已在 Electron Utility Process 中运行 Agent loop、工具注册和 JSONL 会话持久化。
- 当前 `DshRuntime` 通过静态 `TOOL_DEFINITIONS` 手工注册全部 `zhiji.*` 工具，没有 Cordis Loader、Profile、Bundle、插件 inventory 或包管理。
- DSH 官方源码已提供 `@deepseek-ai/dsh-app-boot`、`@deepseek-ai/cordis-plugin-loader`、`@deepseek-ai/cordis-plugin-hmr`、`@deepseek-ai/dsh-host-plugin-inventory`、Profile Bundle 和 `dsh plugin` 管理链路。
- DSH 的 Package/Bundle 成员变化以 Profile 重启为正式边界；普通 Profile 配置变更可通过 watcher/HMR 重新组合。
- DSH TypeScript SDK 可驱动完整子进程运行时，但 rc.8 协议缺少本项目已具备的轮次中取消和服务端向客户端审批请求，因此不能未经验证直接替换当前 MessagePort 桥。
- 截至 2026-08-21，官方 npm 的版本并未完全同步：`@deepseek-ai/dsh` 最新为 `0.1.0-rc.7`，`dsh-app-boot` 为 `0.1.0-rc.6`，`dsh-host-plugin-inventory` 为 `0.0.1-rc.3`，而知己核心包和本地源码为 rc.8。不能把本地 master/rc.8 源码中存在的接口直接当作可安装发布接口。
- 官方 `dsh plugin` 是 pnpm 的薄封装：它支持 `add`、`remove`、`update` 等包管理动词，并在成功后维护 Profile 的 Bundle 列表；运行中的 Profile 不会自动采用新的 Bundle 集合，必须重启该 Profile。
- 官方 inventory 只返回 Loader entry id、模块 specifier、有效启用状态和 Fiber phase；它不提供包版本、来源、兼容性、历史错误、订阅或启停/安装写接口。
- 官方没有插件商店。官方仓库只建议插件作者添加 GitHub `dsh-plugin` topic 便于发现；GitHub topic、社区目录和社区“市场”均不代表官方兼容或安全审核。

### 3.3 未验证假设

- 社区插件是否主要扩展复盘视角、外部数据源、结果分发，还是会要求任意 UI 和通用系统权限。
- 发布版 Electron 是否适合随应用提供版本匹配的 DSH CLI 与 pnpm，或第一版只支持预构建 npm/tarball Bundle。
- DSH rc.8 全套 Profile Host 能力何时以相互兼容的版本发布，以及能否在 Electron Utility Process 中稳定打包。
- GitHub topic 中有多少插件真正声明 `dsh.bundle`、包含预构建产物、兼容知己锁定版本并适合复盘领域。

这些未知会直接决定是否进入 P1-P3。P0 可以执行，但在发布包版本闭合、打包和安全模型得到实测前，不得把 Profile Host 或任意社区安装入口视为已承诺功能。

### 3.4 不可突破约束

- Main Process 继续独占 API Key、日志/复盘仓储和正式写入能力。
- 插件不能通过知己提供的领域 API 绕过 Zod、材料预览、用户确认、乐观并发、回收站或现有复盘质量门。
- Renderer 继续保持 `nodeIntegration: false`、`contextIsolation: true`、`sandbox: true`；插件代码不进入主 Renderer。
- 知己默认 Profile 不注册 Shell、任意文件、任意 URL、代码编辑或工作区工具。
- 正式日志与复盘仍以知己仓储为唯一权威；插件输出不能只存在于聊天气泡或私有文件中。
- 插件系统不可成为 `.claude/` 的第二份运行真相；桌面端仍不在运行时读取仓库 Skill 路径。

### 3.5 价值取舍

开放性与聚焦性不能同时最大化。选择是：

- 允许兼容的 DSH 插件扩展 Agent，但默认展示和支持“复盘扩展”；
- 保留 DSH 原生插件格式和生命周期，不承诺所有通用 DSH 插件在知己中都有良好体验；
- 初期接受安装/更新插件后重启 Agent Runtime，以换取复用官方 Profile 边界、降低状态错误和实现成本；
- 插件开发者可使用 DSH Web UI、官方开发教程和 HMR 调试，普通知己用户继续使用桌面端。

## 4. 为什么不直接采用 DSH Web UI

| 方案 | 收益 | 代价 | 裁决 |
|---|---|---|---|
| 用 DSH Web UI 替换知己 React | 最完整复用通用插件 UI | 丢失专业日志/复盘页面，产品变成通用 Harness，破坏定位 | 不采用 |
| 在桌面端并排嵌入 DSH Web UI | 快速获得插件设置与轨迹页面 | 两套导航、会话和设置真相，用户难以理解，安全边界复杂 | 不采用 |
| 知己 React + DSH Profile Host | 保留产品差异，同时复用插件运行时 | 需要实现薄的 Electron/权限/UI 适配 | 采用 |
| 外部 SDK 子进程完全替代当前 Runtime | 运行时与 Profile 最独立 | rc.8 缺少轮次取消和审批反向请求，可能回退现有正式工作流 | 仅保留为后续替代候选 |

DSH Web UI 继续作为插件开发、运行轨迹和上游行为核验工具，而不是知己产品 UI。

## 5. 复用边界：DSH 做什么，知己做什么

| 能力 | DSH/上游负责 | 知己负责 |
|---|---|---|
| 插件生命周期 | Cordis Loader 的 mount/unmount、依赖等待、Fiber 状态 | Electron 启停、错误中文化、Agent Runtime 重启 |
| 插件组合 | Profile、Bundle、`cordis.patch.yml`、配置 watcher/HMR | 固定 `zhiji` Profile 的默认边界与产品策略 |
| 插件发现状态 | `dsh-host-plugin-inventory` 的只读 Loader 快照 | 从 Profile manifest/lockfile 补充版本和来源；设置页列表及中文文案 |
| 插件启停 | Loader/Profile patch 与配置 HMR | 写入受控 `cordis.patch.yml`、空闲调度和错误恢复；inventory 本身不负责修改 |
| 包管理 | 官方 `dsh plugin` CLI 与 pnpm/Profile manifest | 固定兼容版本、打包环境适配、用户确认和恢复路径；不重写 pnpm 转发与 Bundle reconcile |
| Agent 能力注册 | `ctx.tools.register()`、Skill/system prompt section、session events | `zhiji.*` 高层领域能力及权限桥 |
| 模型访问 | DSH LLM/Agent loop | Main Process 密钥和现有 OpenAI-compatible Provider |
| 个人数据 | 不直接持有知己仓储 | Main Process 仓储、Schema、确认、备份与恢复 |
| 产品界面 | 不作为主界面 | React 日志/复盘/项目/设置/Agent 页面 |

禁止复制 DSH Loader、HMR、Profile parser、插件 inventory 或浏览器模块系统到知己仓库。只有上游发布接口无法满足且已有最小复现证据时，才评估受控适配或上游贡献。

## 6. 目标架构

```text
Electron Renderer（知己 React）
├─ 日志 / 复盘 / 项目 / Agent
└─ 设置 > 复盘扩展
   ├─ 已安装插件与状态
   ├─ 启用 / 停用 / 重新加载
   └─ 安装 / 更新 / 移除（后续阶段）
        │ 具名 IPC + Zod
        ▼
Main Process
├─ PluginManager
│  ├─ 管理知己 DSH Profile 位置
│  ├─ 委托官方插件包管理
│  └─ 触发受控 Utility 重启
├─ PluginCapabilityDispatcher
│  └─ 只暴露经授权的知己高层用例
├─ AgentFacade / ModelTransport
└─ 现有日志、复盘、项目、备份与凭据服务
        │ MessagePort
        ▼
Electron Utility Process
└─ Zhiji DSH Profile Host
   ├─ dsh-app-boot + Cordis Loader
   ├─ zhiji-base Bundle
   │  ├─ Agent loop / session / persistence
   │  ├─ 知己 system prompt
   │  └─ 内置 zhiji.* 工具桥
   ├─ 用户安装的兼容 DSH Bundles
   ├─ plugin inventory
   └─ 配置 HMR（仅在安全静止点生效）
```

## 7. 知己 Profile 与插件兼容模型

### 7.1 单一插件格式

插件继续使用 DSH 原生 Package/Bundle 约定：包在 `package.json` 声明 `dsh.bundle.patch`，由 Profile 组合其 `cordis.patch.yml`。知己不定义第二套 Loader 或依赖格式。

知己可以增加一个轻量、可选的 `zhiji` 元数据段，只用于产品展示与兼容判断，例如插件名称、适用的知己 Plugin API 版本、需要的领域权限和结果类别。该字段不参与模块加载，也不替代 DSH manifest。

### 7.2 初期支持的插件能力

- 注册 Agent 工具，但工具访问个人数据必须调用 Main Process 能力桥。
- 注册 Skill 或 system-prompt section，扩展分析视角和任务指导。
- 注册只影响 Agent Runtime 的设置 provider。
- 订阅 DSH session/tool 事件，用于插件自身可观察行为。
- 使用既有 `ui.present`/`ui.navigate` 结果卡和专业页面展示结果。

### 7.3 初期不支持的插件能力

- 向知己主 Renderer 注入任意 JavaScript、React 组件或 CSS。
- 由知己 API 直接暴露数据目录、凭据文件、备份包、Shell、任意文件系统或任意网络能力。
- 覆盖知己内置日志、复盘 Schema 和正式保存语义。
- 在应用后台自行更新、静默新增权限或远程下发代码。

这些是知己宿主 API 的边界，不是对第三方 Node 代码的系统级隔离承诺。未经额外进程/OS 沙箱，外部 DSH 插件仍可能直接调用 Node 和操作系统能力，因此只能加载已核验插件。

## 8. 运行时变更语义

审查后不再把整体能力笼统称为“热插拔”。DSH 有真实的配置热更新和开发期模块 HMR，但生产环境安装、更新、移除 Bundle 的官方边界是 Profile 重启。

### 8.1 配置热更新

通过 Profile patch 表达的插件启用状态和配置变化优先使用 DSH watcher/HMR。只在 Agent 没有运行中的 turn、tool 或 pending approval 时应用；否则排队到 idle。失败时保留上一个可用组合并向设置页报告 Fiber 状态。

### 8.2 Bundle 安装、更新和移除

Bundle 成员变化沿用 DSH 官方 Profile 重启边界：

1. Main Process 等待 Agent 静止或让用户停止当前任务。
2. 委托官方插件包管理修改独立 `zhiji` Profile。
3. 关闭并重启 DSH Utility Process。
4. DSH 从 JSONL 恢复会话，重新发布 plugin inventory。
5. 知己专业页面和本地数据服务始终可用。

用户无需重新安装或重启整个知己应用。此方案比在运行中替换依赖图、原生模块和插件代码更可靠，也更符合上游正式边界。

### 8.3 插件开发 HMR

本地插件开发者可使用 DSH 官方 HMR、Web UI 和开发教程。知己生产包不承担源码 watcher、Vite 插件 bundle 构建或 React 状态保留。

## 9. 权限、信任与数据生命周期

### 9.1 两层信任边界

1. **知己领域 API 权限**：继续使用 DSH 工具执行管线和 Main Process `PluginCapabilityDispatcher`；写入类能力复用知己现有确认语义。
2. **插件代码信任**：DSH 插件是可执行的 Node 宿主代码，不等于安全沙箱。即使知己不向它暴露 API Key 和仓储对象，它仍可能使用 Node/系统能力访问当前 OS 用户可读文件、网络或子进程。第一版只能支持知己内置、官方或人工核验并由用户明确选择的插件；GitHub topic 一键安装、静默更新和未知来源代码不在范围内。

如果未来提供公共插件目录，必须另行设计来源展示、版本固定、代码/Bundle patch 审查、撤回和进程/系统级隔离。能力声明只能约束知己 API，不能约束插件自己的 Node 权限；它也不能由“模型工具需要确认”替代，因为插件代码在模型调用之前就可能执行。

### 9.2 存储位置

- DSH Profile、插件包、lockfile 和运行配置放在 Electron `userData` 下的独立目录，不进入知己业务数据目录，也不随日志备份导出。
- Agent JSONL 会话继续位于知己数据根 `agent/sessions/`，保证数据位置迁移和恢复语义不回退。
- 插件产生的正式知己数据必须通过领域服务写入既有仓储；插件私有缓存归插件自己管理，不能伪装成知己正式产物。

### 9.3 版本与恢复

- 会话事件或工具结果需要能识别调用时的插件 ID/版本；插件缺失时历史仍可读，不重新执行旧工具。
- 包管理优先依赖官方 Profile manifest、包版本和 lockfile，不新增自定义哈希或冻结机制。
- 插件安装失败时不得破坏当前可启动 Profile；官方 CLI 会直接修改目标 Profile，并不提供事务式安全切换，因此知己若开放安装，需要先在临时 Profile 完成安装与 boot smoke，再切换 Profile 指针。

上述临时 Profile 不是为了增加形式化门禁，而是防止一个具体事故：不完整依赖或启动失败让整个 Agent Runtime 无法启动。Git、应用版本号和普通单测无法保护用户运行时下载的新包，因此需要安装前独立 boot 验证。该 smoke 只能验证“能加载”，不能证明插件无恶意行为或数据风险。

## 10. 前端产品设计

插件入口位于“设置 > 复盘扩展”，而不是新增通用插件市场一级导航。

第一版只展示：

- Loader entry id、模块名称和运行状态；版本与来源只能从 Profile manifest/lockfile 补充，兼容状态必须由知己实际验证或人工标记，不能从 inventory 推断；
- 启用/停用状态；
- DSH Fiber 状态（转译为“可用、等待依赖、加载失败、正在更新”）；
- 权限摘要；
- 重新加载、停用和查看错误；
- 后续阶段的安装、更新和移除。

Agent 页面继续只展示用户能理解的工具活动和结果卡，不暴露 Cordis、Fiber、Bundle 等开发术语。插件作者的高级调试继续使用 DSH Web UI。

## 11. 分阶段实施裁决

| 阶段 | 目标 | 用户可见变化 | 是否进入本轮执行规划 |
|---|---|---|---|
| P0 | 核验 rc.8 插件 API、Profile boot、Utility 打包和包管理边界 | 无 | 是 |
| P1 | 将固定 Runtime 重构为知己 DSH Profile Host，行为完全同构 | 无 | 是 |
| P2 | 接入 inventory、启用/停用和受控 Runtime 重启 | 设置页出现“复盘扩展” | 是 |
| P3 | 接入已核验插件的安装、更新、移除和兼容元数据 | 高级入口可按包规格安装 DSH Bundle | 条件进入，需 P0 证明发布版本、打包和回退路径 |
| P4 | 提供插件作者模板、示例插件和开发 HMR说明 | 开发者可制作知己插件 | 是 |
| P5 | 插件自定义 Renderer UI | 插件可扩展桌面页面 | 否，重新过必要性闸门 |
| P6 | 自有在线插件市场、审核、签名和自动更新 | 社区分发平台 | 否，重新过必要性闸门 |

## 12. 验收标准

- [ ] 知己使用 DSH/Cordis Profile 与 Loader 管理内置和外部插件，不维护第二套插件内核。
- [ ] 当前 Agent 工具、模型代理、会话持久化、取消、审批和正式写入行为在 P1 后不回退。
- [ ] 一个仓库外、预构建且固定版本的 DSH 测试 Bundle 可以被知己 Profile 安装并向 Agent 注册只读工具。
- [ ] 插件启用、停用或配置变更后，Agent 下一次请求得到正确的工具和提示词集合。
- [ ] Bundle 安装、更新或移除只需重启 Agent Utility Process；日志、复盘和设置页面仍可使用。
- [ ] 知己不向插件上下文提供 API Key、知己仓储或 Renderer 执行能力；领域访问必须经过 Main Process 能力桥。文档明确说明这不等于限制插件自身的 Node/OS 权限。
- [ ] 插件加载失败不会破坏上一个可启动 Profile，也不会删除插件包或用户数据。
- [ ] 会话在插件停用或缺失后仍能列表、打开和继续；旧工具结果保留为历史事实。
- [ ] 设置页以官方 inventory 展示 Loader 状态，并从 Profile manifest/lockfile 补充包信息；不把 inventory 描述为版本、来源或写操作 API。
- [ ] 打包后的 Windows 应用可以找到 Profile、官方 DSH 运行时和插件依赖，不依赖开发机绝对路径。

## 13. 明确非目标

- 不把知己变成编码 Agent、MCP 聚合器或任意自动化平台。
- 不复制、fork 或手工重写 DSH Web UI、Cordis Loader、HMR、Profile 和包管理。
- 不在第一版提供插件自定义 React 页面。
- 不在第一版建立知己自有插件市场、账号、云端上传或自动审核服务；插件发现先链接官方建议的 GitHub `dsh-plugin` topic，安装仅接受明确包规格且标注“未获官方审核”。
- 不默认启用任意 Shell、文件系统、代码执行和无范围联网插件。
- 不用热插拔重写现有日志、复盘和项目页面，也不把正式报告改成自由聊天输出。
- 不以目标用户观察或真实 Agent 完整闭环作为本轮架构实施前置条件。

## 14. 难度与是否应该实现

| 范围 | 难度 | 主要成本 | 裁决 |
|---|---|---|---|
| P0-P1：Profile Host 同构迁移 | 中高 | 运行时 boot、打包、会话/取消/审批回归 | 应实现，是后续复用上游插件能力的基础 |
| P2：inventory 与启用/停用 | 中 | 只读 inventory、Profile patch、IPC、idle/restart 生命周期 | 应实现，体现可组合与可重载，不宣传为插件市场热插拔 |
| P3：已核验插件安装/更新/移除 | 高 | CLI/pnpm 打包、版本错位、事务式 Profile 切换、安全告知 | 条件实现，先由 P0 证明官方发布链路可嵌入 |
| P4：作者模板与示例 | 中 | 兼容元数据、文档、示例 Bundle | 应实现，否则开放能力无法被使用 |
| P5：任意插件 UI | 很高 | Renderer 动态模块、样式和生命周期、安全 | 暂不实现 |
| P6：公共市场和不可信插件 | 很高 | 后端、分发、信任、隔离、审核、撤回 | 暂不实现 |

第一性原理结论：**现在确定应该做的是 P0；P1-P2 只有在版本与打包验证通过后实施，P3-P4 继续保持条件性。**必须以 DSH 原生 Profile/Bundle 为唯一插件内核，并把开放边界限制在复盘领域和已核验插件。当前证据不支持向普通用户承诺“去插件市场任选一个即可热插拔安装”。

## 15. 实施任务读取顺序

1. 本文。
2. `docs/2026-08-20-dsh-plugin-platform-execution-plan.md`。
3. `docs/specs/2026-08-20-deepseek-harness-agent-architecture.md`。
4. `apps/zhiji-desktop/docs/architecture.md` 与 `apps/zhiji-desktop/docs/dsh-integration-notes.md`。
5. DSH 源码中的 `packages/boot/app-boot`、`vendor/loader`、`vendor/hmr`、`packages/host/plugin-inventory`、`apps/cli/src/plugin.ts`、`apps/cli/src/profile-boot.ts` 和 SDK 限制说明。
6. 当前源码与锁文件。上游接口与本文不同，以“复用上游插件内核、保留知己领域边界”为裁决原则，更新文档后再继续。

## 16. 上游参考

- DeepSeek Harness：<https://deepseek.com/harness/en/>
- Extension Cookbook：<https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/cookbook/extension-cookbook.md>
- Cordis Composition and HMR：<https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/cordis-tutorial/06-composition-and-hmr.md>
- DSH CLI Profile 与插件管理：<https://github.com/deepseek-ai/deepseek-harness/blob/master/apps/cli/reference/README.md>
- DSH 插件打包与安装教程：<https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/develop/basic/publish.md>
- 官方插件发现入口（GitHub topic）：<https://github.com/topics/dsh-plugin>
- 官方仓库安全讨论：<https://github.com/deepseek-ai/deepseek-harness/discussions/587>

# 当前状态：已被“知己 DSH 独立插件”路线取代，不再执行
