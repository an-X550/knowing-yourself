---
created: 2026-08-22
last_updated: 2026-08-22
status: approved
---

# 桌面端本地发布质量与设置页体验修复执行计划

## 目标

在不全局重做 UI、不替换 Agent runtime、不操作 GitHub 远程的前提下，完成以下结果：

1. 用同条件对照区分日反馈问题属于模型输出、开发/生产差异还是旧制品；
2. 将设置页收敛为“通用 / AI 与个性化 / 数据与隐私”三个任务域；
3. 把日志模板管理移到日志页，删除无实际版本检查能力的更新控件；
4. 修复侧栏滚动归属和暗色下拉框；
5. 为结构化日反馈增加失败分类、一次重试和安全恢复入口；
6. 生成并完成核心功能冒烟的版本独立本地 Release Candidate；
7. 把 GitHub `v2.0.5` 核对与新版本发布留到单独授权的第二阶段。

对应需求：[`desktop-release-quality-and-settings-ux`](specs/2026-08-22-desktop-release-quality-and-settings-ux.md)。

## 实施边界

- 当前文档阶段不执行以下任务；开始编码前需由用户确认本计划。
- 实施时只改 `apps/zhiji-desktop/`、对应测试和必须同步的项目文档。
- 不修改 `.claude/` 产品逻辑、DSH Agent、记忆检索、WorkBuddy 或用户版分发包，除非实际测试证明存在直接依赖。
- 不清理用户数据、旧 GitHub Release 或仓库中的用户既有改动。
- 工作区当前存在其他未跟踪文件；实施和提交必须只选择本任务文件。
- 当前基线为 `2.6.2`，本轮目标版本为 `2.6.3`；版本号只在实现和验证完成后同步。

## 阶段 0：建立可判诊断

### 0.1 保存事实而非猜根因

建立一份临时诊断记录，至少包含：

- 当前 Git commit；
- 根 `VERSION`、桌面 `package.json` 和现有安装/免安装制品版本；
- Windows 版本、显示缩放、窗口尺寸和主题；
- 服务商、模型、base URL 类型；
- 输入日志使用固定脱敏样本，不使用真实个人日志；
- 开发模式、免安装包、全新安装包三种结果。

不得在诊断前写“GitHub 漏组件”或“asar 缺依赖”为根因。

### 0.2 准备确定性本地模型替身

在测试目录复用 Node HTTP 能力启动最小 OpenAI-compatible 本地服务，不增加生产依赖。它应能按测试用例依次返回：

1. 合法日反馈 JSON；
2. 空 `content`；
3. `finish_reason: length` 的截断 JSON；
4. 非法 JSON；
5. 合法 JSON 但字段缺失；
6. 首次非法、第二次合法；
7. 连续两次非法。

测试只使用 `localhost`，沿用现有开发/测试允许的本地 HTTP 边界。不得让生产默认配置指向测试服务。

### 0.3 三形态对照

用同一固定输入依次运行：

```text
npm start
  -> 当前源码开发模式

npm run package
  -> out/知己-win32-x64 免安装包

npm run make
  -> 全新 Setup.exe 安装到干净 userData/dataRoot
```

先用本地模型替身验证客户端链路；若存在安全可用的真实 DeepSeek 配置，再做一次脱敏冒烟。没有安全配置时明确记录未验证，不索要 Key、不使用假成功；真实服务失败时只记录 HTTP/结束原因/输出分类，不保存原文。

### 0.4 阶段完成条件

- 能回答同一输入在三种形态下分别发生了什么；
- 能区分模型输出异常与构建/配置异常；
- 没有为了复现而修改正式用户数据；
- 后续测试用例能稳定重放至少一种已知失败。

## 阶段 1：先写失败测试

### 1.1 设置页组件测试

修改 `tests/unit/settings-page.test.tsx`，先让以下断言失败：

- 存在“通用 / AI 与个性化 / 数据与隐私”三个标签；
- 默认只展示通用内容；
- 切换标签后表单草稿不丢失；
- AI 普通路径不同时展示所有高级字段；
- 个人背景默认只显示摘要，点击后可编辑和授权；
- 数据页包含“存储位置”“备份与恢复”；
- 用户文案为“在资源管理器中查看”“创建备份”“从备份恢复”；
- 不存在“发布地址”“保存地址”“检查更新”；
- 不存在日志模板管理。

### 1.2 日志模板测试

修改 `tests/unit/today-page.test.tsx` 或新增最小模板管理组件测试：

- 日志页模板选择附近存在“管理模板”；
- 可新建、编辑、删除模板；
- 删除仍需确认；
- 关闭管理界面后可直接在当前日志中使用更新后的模板；
- 页面切换不修改模板文件格式和日志正文。

### 1.3 AppShell 测试

为 AppShell 增加：

- 本地状态文案为“本地保存 / 查看存储位置”；
- 不渲染完整数据路径；
- 点击后导航到设置的数据标签；
- 缺 API Key 的恢复入口仍能导航到 AI 标签。

滚动固定关系不依赖 JSDOM 猜布局，在打包 Playwright 测试中验证。

### 1.4 日反馈运行时测试

扩展 `tests/integration/generate-daily-review.test.ts` 和 Provider 测试：

- 合法 JSON 只调用一次；
- 空内容、截断、非法 JSON、Schema 不匹配分别形成不同脱敏分类；
- 首次结构失败、第二次合法时只保存一次；
- 连续失败时调用两次、不保存、返回可恢复错误；
- 401/403、429、网络超时、用户取消不触发结构重试；
- 重试不放宽 Zod Schema；
- 审计或诊断不包含日志正文、个人背景或 Key。

### 1.5 CSS/主题测试

不创建整页截图 baseline。使用打包 Playwright 验证：

- 深色主题下 select 的 computed style 为 `background-repeat: no-repeat`；
- 项目选择和 AI 设置选择都只显示一个箭头；
- 右侧工作区滚动前后，侧栏状态项的 viewport 坐标保持不变；
- 关键导航、按钮和模板入口在自动化测试中可见且可操作；本轮不扩展宽度/DPI 人工矩阵。

## 阶段 2：重整设置与日志模板

### 2.1 增加设置页内部导航状态

在 Renderer 内定义小范围 `SettingsSection`：

```ts
type SettingsSection = 'general' | 'ai' | 'data';
```

允许导航目标携带设置区段，但不把它扩成 Main Process/DSH 工具契约。优先在现有 Renderer `NavigationTarget` 中增加可选 intent；只有 Agent 导航共享 Schema 必须经过时才同步最小枚举。

验收：

- 普通点击设置默认 `general`；
- 本地保存状态进入 `data`；
- Agent 缺 Key 恢复进入 `ai`；
- 浏览器式刷新或应用重启不要求记住上次标签。

### 2.2 拆分设置内容

把单个 `SettingsPage` 的状态与视图拆成内部组件，建议边界：

- `GeneralSettings`；
- `AiSettings`；
- `PersonalizationSettings`；
- `DataAndPrivacySettings`；
- `AppVersionFooter`。

组件拆分用于降低单文件认知负担，不新增全局状态库。异步加载和错误状态保持在最接近数据所有者的层级；共享初始加载可由父页统一执行，避免重复 IPC。

### 2.3 AI 渐进展示

- 将三张 provider card 改为紧凑 provider select；
- 保留 OpenAI、DeepSeek、其他兼容服务；
- 默认展示服务商、API Key、模型、“保存并测试”；
- 高级设置按用户操作展开；
- 自定义 URL 和思考模式按服务商条件渲染；
- “仅保存”和“移除 Key”放在高级区；
- 保存/测试结果显示在 AI 任务组内，不复用模板消息状态。

不要删除 `ProviderCard` 前先搜索消费者；确认无其他消费者后再删除文件和测试。

### 2.4 个人背景

- 初始只显示“未设置”或“已设置 · 已/未允许 AI 使用”；
- 点击后展开 textarea 和授权 checkbox；
- 保存、清空和错误反馈归属该区；
- 清空仍需明确确认；如果当前实现没有确认，本轮补普通 ConfirmDialog，因为清空个人背景是不可逆内容删除；
- 不改变文件位置、frontmatter 或 AI 注入条件。

### 2.5 数据与隐私

- 按 Spec 组合“存储位置”和“备份与恢复”；
- 将状态消息拆成 location/backup/restore 各自状态，避免一个字符串跨区复用；
- “从备份恢复”打开现有选择→校验→预览→确认流程；
- 恢复写入空目录的限制和既有 ZIP 校验全部保留。

### 2.6 移动日志模板管理

- 复用既有 `TemplateRepository`、IPC、Modal 和 ConfirmDialog；
- 将模板列表、新建/编辑/删除状态从 `SettingsPage` 移到日志页附近的独立 `TemplateManager`；
- 不复制第二套模板状态或仓储；
- 模板变更完成后刷新日志页模板选择；
- 设置页删除模板相关 state、effects、消息和 modal。

### 2.7 删除伪更新控件

- 删除设置页的发布地址输入、保存地址和检查更新按钮；
- `app:get-info` 只保留版本信息；
- 删除不再被消费的 `setUpdateUrl` preload/desktop API/IPC；
- `DataRootConfig` 对历史 `updateUrl` 做兼容读取，避免旧配置导致启动失败；实现可选择读取后忽略，或在下一次配置写入时自然移除；
- 不新增真正的更新检查，不用 `shell.openExternal` 替代旧按钮；
- 更新安装/分发文档，删除让普通用户填写发布地址的说明。

## 阶段 3：共享视觉修复

### 3.1 侧栏与工作区

- `.desktop-shell` 固定为 viewport 高度；
- `.sidebar` 保持自身高度和底部状态；
- `.workspace` 设置正确的 `min-height: 0` / overflow 边界；
- `.page-view` 成为唯一主要内容滚动容器；
- 用紧凑状态项替换 `.privacy-card`；
- 窄侧栏提供图标和可访问说明。

不要使用 `position: fixed` 覆盖整个布局，除非 Playwright 证明 grid/flex 的 viewport 高度方案不足；优先保留现有文档流和键盘顺序。

### 3.2 select 级联

最小修复优先：

- 把字段背景从会重置子属性的 `background` 简写改为 `background-color`；
- 或在最终高优先级 select 规则中显式声明 image/repeat/position；
- 浅/深主题共享布局属性，只覆盖箭头颜色；
- 为 disabled select 补足对比度和非交互 cursor。

测试必须覆盖共享规则，不能只给“关联项目”加页面特例。

### 3.3 卡片、按钮和间距

- 设置页停止每个区段都使用大号 `.card`；
- 任务组内使用 8/16px，组间使用 24px；
- 内容区域设置合理 `max-width`，宽屏不把字段拉满；
- 每个任务组最多一个 primary；
- 删除对布局无贡献的边框和过大圆角；
- 不全局修改所有页面的半径令牌，避免超出已确认范围。

## 阶段 4：补强日反馈输出恢复

### 4.1 Provider 元数据

在不影响 Agent streaming/tool call 的前提下，让结构化 collect 路径获得：

```ts
interface StructuredCompletion {
  content: string;
  finishReason: string | null;
}
```

实施前先搜索全部 `ProviderPort.collect` 消费者。优先增加一个明确的结构化完成方法或最小返回类型，而不是让所有 Agent 流式事件承担 JSON 业务元数据。测试 fake 必须能指定 `finishReason`。

请求要求：

- 继续发送 `response_format: { type: 'json_object' }`；
- 提示中继续包含 JSON 字样和完整示例；
- 为日反馈设置足以容纳 Schema 的明确 `max_tokens`，避免依赖服务商不透明默认值；
- 收集最终 `finish_reason`；
- 空内容在 JSON.parse 前分类。

### 4.2 解析分类

将 `parseDailyReviewOutput` 的异常映射为内部有限分类，不把 Zod 全量错误直接展示给用户。分类逻辑保留在 Main Process：

- 空内容；
- 长度截断；
- JSON 语法错误；
- Schema 不匹配。

错误摘要只保留字段路径和问题类型，不保留字段值。

### 4.3 一次重试

在 `runDailyFeedback` 的生成节点内封装最多两次结构尝试：

1. 第一次按现有提示生成；
2. 仅结构失败时加入短修复提示；
3. 第二次成功后继续现有 normalize/render/save；
4. 第二次失败抛出新的可恢复 AppError；
5. AbortSignal 在两次调用间继续生效；取消后不得发第二次请求。

不得把完整失败输出回传模型。可提供不含值的字段错误摘要，避免把用户内容或未知模型文本再次扩大。

### 4.4 Renderer 恢复体验

- 将当前 `Error invoking remote method...` 技术前缀映射为用户文案；
- 保留“重新生成”；
- 增加“查看诊断信息”展开区；
- 明确“日志和已有数据没有受到影响”；
- 如果自动重试正在进行，阶段状态显示“正在重新整理反馈格式”，不让用户误以为按钮无响应。

## 阶段 5：安装版 E2E 真实性

### 5.1 扩展打包 E2E

基于现有 `e2e/desktop.spec.ts` 与 `e2e/release-quality.spec.ts` 保持场景可定位：

1. `release-quality.spec.ts` 设置场景：三标签、普通/高级 AI 设置、日志模板、脱敏日志和“本地保存”入口；
2. `release-quality.spec.ts` 暗色场景：共享 select 的 computed style；
3. `release-quality.spec.ts` 侧栏场景：工作区滚动、侧栏坐标不变；
4. `release-quality.spec.ts` packaged-asar 日反馈场景：本地 fake provider 首次失败、第二次成功与安全恢复；
5. `release-quality.spec.ts` 安装版场景：真实启动 Agent 并新建会话；安装版日反馈恢复明确 skip，不伪造空通过。

Playwright 不能直接拦截 Electron Main Process 原生文件对话框；备份/恢复和改目录测试按官方建议通过 `electronApplication.evaluate()` 注入确定性 dialog 替身，不点击真实系统窗口。

### 5.2 安装版与打包版边界

- 安装版真实 E2E 只验证启动、设置分区、日志/模板、本地保存入口、暗色 select、侧栏滚动和 Agent 新建会话；
- 结构化日反馈失败恢复只在 `packaged-asar` 模式通过 Main Process 测试替身注入，验证分类、一次重试和不泄漏；
- 安装版的日反馈测试必须明确跳过并说明需要真实 AI 配置，不得以没有执行步骤的空通过代替真实验证；
- 不添加 production backdoor、不拦截真实网络、不把假 provider 当作安装版真实 AI 冒烟；
- 本轮取消手工截图、900px/常用宽度/宽屏、100%/125%/150% DPI 和像素 baseline，也不再做颜色/圆角/阴影/风格调整。

### 5.3 回归命令

在 `apps/zhiji-desktop` 执行：

```powershell
npm test
npm run typecheck
npm run lint
npm run package
npm run test:e2e
```

完成安装版前再执行 `npm run make`。`make` 非零退出（包括 rcedit 报错）即失败；不得从失败的 `out/make` 复制任何文件。应从 ASCII 路径或已核对目标的 ASCII junction 重跑，并核对退出码、元数据、文件时间和三件套内部版本一致。

## 阶段 6：生成本地 Release Candidate

### 6.1 版本同步

实施完成后按治理规范递增 patch，并同步：

本轮以 `2.6.2` 为基线，目标版本固定为 `2.6.3`；旧 `v2.6.2` RC 保留，不覆盖。

- 根 `VERSION`；
- `apps/zhiji-desktop/package.json`；
- `apps/zhiji-desktop/package-lock.json`；
- `PROJECT_STATUS.md`；
- `CHANGELOG.md`；
- 受影响的 README/安装分发说明。

不要在编码开始前预占版本；如果执行时当前版本已经变化，以当时版本为基准。

### 6.2 安全清理旧安装制品

清理前：

1. 解析目标绝对路径；
2. 确认它严格位于 `apps/zhiji-desktop/out/make/squirrel.windows/x64`；
3. 列出将被替换的文件；
4. 只删除该目录，不递归删除 `out`、工作区根或任何环境变量指向的宽路径。

随后执行全新 `npm run make`。

### 6.3 建立版本目录

将本次三个 Squirrel 制品复制到：

```text
out/release-candidate/vX.Y.Z/
```

把 `Setup.exe` 重命名为 `Zhiji-Setup-vX.Y.Z.exe`；`.nupkg` 和 `RELEASES` 保持内部一致。记录 Git commit 和生成时间到人工验收记录，不新增 hash 文件。

### 6.4 全新安装核心冒烟

用 RC 目录的安装器完成：

- 首次安装和启动；
- 全新 `userData` 与数据目录；
- 主题切换；
- 设置分区、侧栏“本地保存”导航、写脱敏日志和模板插入；
- Agent 页面新建会话；
- 若有安全可用配置，再执行一次真实 DeepSeek 脱敏日反馈，否则标记未验证；
- 关闭重启后核心配置和数据仍存在；
- 不在本轮扩展升级/卸载/Windows 10 或 DPI 完整矩阵。

只把这一份 RC 标记为“可进入远程发布评估”。

## 阶段 7：GitHub 第二阶段（当前不执行）

只有本地 RC 通过且用户再次明确授权后：

1. 只读读取 GitHub `v2.0.5` 的 tag、commit 和资产元数据；
2. 下载到独立临时目录检查版本，不覆盖本地 RC；
3. 形成旧 Release 根因报告；
4. 不编辑 `v2.0.5`；
5. 为新的修订版本准备 Release Notes；
6. 用户确认后才 push/tag/upload；
7. 上传 RC 中已经验收的同一份文件，不在上传前重打包。

## 文件影响预估

实施 Agent 必须先搜索实际消费者，以下只是预估而非写入白名单：

| 区域 | 可能受影响文件 |
|---|---|
| 设置页 | `src/renderer/pages/settings-page.tsx`、新增内部设置组件、`src/index.css` |
| 导航 | `src/renderer/app/navigation.ts`、`app-shell.tsx`、必要时共享导航 Schema |
| 模板 | `today-page.tsx`、新增 `template-manager.tsx`、现有模板测试 |
| 更新死代码 | `preload.ts`、`shared/contracts/desktop-api.ts`、`register-handlers.ts`、`data-root-config.ts`、安装分发文档 |
| 日反馈 | `openai-compatible-provider.ts`、`provider-port.ts`、`daily-runtime.ts`、解析/错误类型、Renderer 错误展示 |
| 测试 | settings/today/provider/daily integration、拆分后的 Playwright E2E |
| 发布事实 | `VERSION`、桌面 package/lock、`CHANGELOG.md`、`PROJECT_STATUS.md`、必要 README |

不得修改与任务无关的 `.claude/` 契约、Agent 检索、DSH 插件或用户日志。

## 提交顺序建议

为便于回退，实施时使用小而完整的本地提交：

1. 测试：固定设置/侧栏/暗色/结构化输出失败；
2. UI：设置三标签、模板迁移、死更新删除；
3. UI：侧栏、select 和视觉层级；
4. AI：失败分类、一次重试和恢复界面；
5. E2E/文档/版本：本地 RC 与发布说明。

每个提交都只包含本任务文件；不提交现有未跟踪审查文件和其他用户改动。推送始终由用户手动决定。

## 最终交付

- 已实现且通过回归的本地源码；
- 本地诊断记录，明确事故 A（DSH 安装缺失依赖）与事故 B（GitHub v2.0.5 日反馈根因仍未确认）的证据边界；
- `out/release-candidate/vX.Y.Z/` 中经过安装验收的三件套；
- 更新后的安装分发说明；
- GitHub 第二阶段待办，不包含任何远程修改。
