# DSH 插件平台 P0 可行性审查

- 日期：2026-08-21
- 范围：只核验上游兼容性与集成路径；未执行 P1-P4
- 上游源码：D:\AI\deepseek-harness
- 上游提交：141eb6fef83422698aef7a981029e843e8161534
- 知己当前版本：2.0.4
- 最终裁决：CONDITIONAL GO

## 结论摘要

结论不是“知己现在已经能安装社区插件”，而是：

1. DSH 的 Profile、Bundle、Loader、HMR 和 inventory 在上游 rc.8 源码中已经形成可复用的公开包边界；官方 Windows CLI 测试和本地无副作用 fixture 均验证了 Profile/Bundle 的安装、更新、移除路径。
2. 知己当前只锁定了 DSH Agent 运行所需的 rc.8 核心包，没有锁定 app-boot、Loader、HMR、inventory，也没有 Profile Host。当前生产 Runtime 因此不能宣称支持 DSH Profile 或社区插件。
3. dsh plugin 不是可直接嵌入的包管理库，而是把参数原样转发给 pnpm 的 CLI 路径。它可以作为未来薄适配的外部入口，但要在 Electron 打包环境中稳定解析 pnpm、Profile、Node 模块和原生依赖，仍需单独验证。
4. DSH 插件是同一 Node/Electron Utility Process 中的可信宿主代码，不是知己 API 白名单提供的系统沙箱。只要允许加载第三方 Node 插件，就必须把它视为拥有当前进程账户权限的代码。
5. 因此唯一推荐路线是：保持当前固定 Runtime 为默认生产路径；未来只在一个可选、隔离的 Utility Profile Host 中按精确版本复用 DSH 官方公开包，并让包管理继续由官方 dsh CLI/pnpm 负责。若这个隔离路径或信任边界无法成立，就停止平台化，继续使用固定 Runtime。

这次没有下载、安装或执行任何未经核验的第三方插件。实验包是本地构造的无副作用、预构建、只用于 dump-config 的 fixture，测试后已清理。

## 证据口径

报告中的标签含义如下：

- [源码/测试确认]：由本地源码、包元数据或实际命令结果直接确认。
- [官方文档]：由 DSH 官方仓库文档明确说明。
- [推断]：根据已确认的执行模型得出的工程判断，不冒充上游承诺。
- [尚未验证]：本次没有足够证据，不写成已实现。

已按要求依次阅读：

1. AGENTS.md
2. .claude/shared/ai-operating-principles.md
3. .claude/shared/contracts/first-principles-analysis.md
4. PROJECT_STATUS.md
5. CHANGELOG.md 最近 5 条
6. docs/development-governance.md
7. docs/specs/2026-08-20-dsh-plugin-platform-architecture.md
8. docs/2026-08-20-dsh-plugin-platform-execution-plan.md
9. docs/specs/2026-08-20-deepseek-harness-agent-architecture.md
10. apps/zhiji-desktop/docs/architecture.md
11. apps/zhiji-desktop/docs/dsh-integration-notes.md
12. apps/zhiji-desktop/package.json 和 package-lock.json

没有修改 VERSION、PROJECT_STATUS.md、CHANGELOG.md、生产源码或已有工作区改动。

## 第一性原理判断

### 1. 知己真正需要解决的用户问题

[源码/项目文档确认] 知己当前的产品问题是本地日志、复盘和 Agent 闭环，当前 Agent Runtime 使用固定的 DSH Agent/Loop/LLM/Session/Tools 组合，并由 Main Process 持有数据、密钥、正式写入和权限边界。现有桌面端架构没有把“任意第三方 Node 插件”列为已验证的用户需求。

[尚未验证] 本次在 PROJECT_STATUS.md、桌面端文档和现有测试中没有发现真实用户安装插件失败、插件数量、插件需求或社区扩展带来的具体使用证据。规划文档提出的“可扩展能力”目前是产品假设，不是已经测量的需求。

所以 P0 的真实问题应收窄为：

> 能否以低于自建插件平台的成本，让一个受控的外部 Bundle 在不修改固定 Runtime 代码的情况下，为知己增加一个经过审核的能力？

不能把问题扩大成“知己应当拥有一个插件市场”或“所有 DSH 插件都能在知己中运行”。

### 2. DSH 官方已经实现什么

| 能力 | 已确认的官方职责 |
|---|---|
| Profile | 在 DSH Home 下维护 profile package.json、dsh.profile.bundles 和用户 patch；负责 Profile 启动和 layer 组合。 |
| Bundle | 由 package.json 的 dsh.bundle.patch 声明配置层；Bundle patch 以 entry rows 插入或覆盖插件。 |
| Loader | 负责 Cordis EntryTree 的创建、更新、移除、等待和插件生命周期。 |
| HMR | 监听用户 patch、配置文件和源文件；配置按 entry id 重组；源文件变更时卸载并重新加载依赖该文件的插件。 |
| inventory | 只读投影 Loader 当前树，提供 entry id、module specifier、enabled 和 Fiber phase。 |
| dsh plugin | 初始化 Profile 后把剩余参数转发给 Profile 目录中的 pnpm，并在成功后根据 dsh.bundle 声明重排 Bundle 列表。 |

依据：[app-boot 官方 README](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/packages/boot/app-boot/README.md)、[Loader API README](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/vendor/loader/README.md)、[CLI 行为参考](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/apps/cli/reference/README.md)、[plugin.ts](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/apps/cli/src/plugin.ts)、[inventory README](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/packages/host/plugin-inventory/README.md)。

### 3. 哪些能力只是源码存在，哪些已经公开发布

[源码/包元数据确认]

- 上游源码提交 141eb6f 的根版本是 0.1.0-rc.8。
- rc.8 并非“完全没有发布”。npm 可以按精确版本和 next tag 解析到 rc.8。
- 但 npm latest 仍指向较旧版本：dsh 是 rc.7，app-boot 是 rc.6，inventory 是 0.0.1-rc.3。无版本约束地安装 latest 会和知己当前 rc.8 依赖混用。
- app-boot、inventory、Loader、HMR 都有公开的根入口。dsh 根包的元数据只提供 bin: dsh -> lib/bin.js，没有 main/exports 可供知己把它当 Profile Host 库导入。
- app-boot 的 peer closure 还包括 group、include、loader、timer、launch-environment、home-paths、invariants、system-prompt 等包；这些并不在知己当前 package.json/package-lock.json 中。

[推断] “源码存在但当前发布包不可用”不能笼统成立。准确说法是：目标能力已经有 rc.8 发布物，但没有进入知己的锁定依赖闭包，也没有经过知己 Electron Utility Process 的 Profile Host 打包验证。

### 4. 哪些能力必须由知己实现

DSH 不会替知己完成以下边界：

- 将 DSH Profile Host 生命周期接入当前 Electron Utility Process，并决定 Profile 重启只重启 Utility 还是影响整桌面。
- 把知己现有 Main Process 数据、密钥、日志、复盘、正式写入和审批服务安全地映射给插件。
- 确定 Profile Home、锁文件、pnpm 可执行文件、Node 版本和 Windows 原生模块的分发方式。
- 处理第三方宿主代码的用户信任、失败恢复、安装前后状态和产品默认策略。
- 如果产品要显示版本、来源、安装渠道、兼容性或变更历史，补充 inventory 没有提供的包元数据投影。
- 把 DSH 的进程内插件事件转成知己允许的、可验证的 Main/Renderer 消息；不能把插件直接暴露为任意知己 API。

### 5. 最小投入是否产生可验证用户价值

[已验证的最小技术价值] 一个只包含 dsh.bundle.patch 的本地预构建 Bundle，可以被官方 dsh plugin 安装到 Profile，进入 dump-config，更新版本后保持 Bundle layer，移除后恢复为 base；这个闭环不要求复制 DSH Loader、HMR 或 Profile parser。

[尚未验证的产品价值] 这个技术闭环还没有证明知己用户真的需要社区插件。最小的后续价值测试应是一个受控的、经过审核的 Bundle 为用户增加一个现有产品闭环内的能力，并能在不改固定 Runtime 的情况下安装、启动、移除和恢复。若这个单一用例都没有明确用户收益，就不值得继续建设通用平台。

### 6. 固定 Runtime 是否应暂缓平台化

应该暂缓把平台化作为默认产品路径。当前固定 Runtime 的工具清单、Main 权限桥、Utility 隔离和 Renderer sandbox 都更简单、更容易验证。第三方插件会把新的 Node 宿主代码、包解析、原生模块和信任问题带进同一 Utility 进程。

这不否定 CONDITIONAL GO：它只允许一个可选、隔离、开发者/受控用户范围的 P1 验证；不允许把当前固定 Runtime 直接改成开放式插件宿主。

## 版本兼容矩阵

版本结果均以 2026-08-21 在本机执行的 npm 元数据为准；exact rc.8 表示可以按精确版本解析，不表示 npm latest 已切换。

| 组件 | 知己当前锁定 | 本地 DSH 源码 | npm latest | 精确版本/公开入口 | 结论 |
|---|---:|---:|---:|---|---|
| Electron | ^43.4.0 | 不适用 | 不适用 | 当前打包目标 win32 x64 | 当前固定 Utility 路径已通过 package/E2E；Profile Host 仍未验证。 |
| @deepseek-ai/dsh | 无 | 0.1.0-rc.8 | 0.1.0-rc.7 | 0.1.0-rc.8 可解析；只有 dsh bin，无 library exports | 可作为 CLI，不可当作公开 Profile Host API。 |
| @deepseek-ai/dsh-app-boot | 无 | 0.1.0-rc.8 | 0.1.0-rc.6 | 0.1.0-rc.8 可解析；根入口、invariant、package.json | 目标复用入口，但必须补齐同版本 peer closure。 |
| @deepseek-ai/cordis-plugin-loader | 无 | 1.0.2 | 1.0.2 | 根入口公开；peer Cordis ^4.0.1 | 与 Cordis 4.0.1 版本方向匹配。 |
| @deepseek-ai/cordis-plugin-hmr | 无 | 1.0.16 | 1.0.16 | 根入口公开；peer Loader、Timer、Cordis | 版本匹配方向明确，但需要 Node internal module loader。 |
| @deepseek-ai/dsh-host-plugin-inventory | 无 | 0.1.0-rc.8 | 0.0.1-rc.3 | 0.1.0-rc.8 可解析；根入口、types、typert、remote | 可作为只读 Host projection，不能代替包管理器。 |
| @deepseek-ai/cordis | 4.0.1 | 4.0.1 | 4.0.1 | stable 4.0.1 | 与当前知己和上游 peer 范围匹配。 |
| @deepseek-ai/dsh-sdk-client | 无 | 0.1.0-rc.8 | 0.0.1-rc.1 | rc.8 可解析；根入口 | 它是外部 subprocess 的 JSON-RPC client，不是 Profile Host API。 |

当前知己 package.json/package-lock.json 中的 DSH 依赖为 Agent、Agent Loop、Invariants、LLM、Scope、Session、Session Persistence JSONL、Settings、System Prompt、Tools 的 0.1.0-rc.8，加 Cordis 4.0.1。没有 dsh-app-boot、cordis-plugin-loader、cordis-plugin-hmr、dsh-host-plugin-inventory 或 dsh CLI。

版本依据：[dsh npm 页面](https://www.npmjs.com/package/%40deepseek-ai/dsh)、[app-boot npm 页面](https://www.npmjs.com/package/%40deepseek-ai/dsh-app-boot)、[inventory npm 页面](https://www.npmjs.com/package/%40deepseek-ai/dsh-host-plugin-inventory)、[Loader npm 页面](https://www.npmjs.com/package/%40deepseek-ai/cordis-plugin-loader)、[HMR npm 页面](https://www.npmjs.com/package/%40deepseek-ai/cordis-plugin-hmr)；实际当天结果以本节命令记录为准。

## 官方公开入口核验

### app-boot 与 Profile/Bundle

[源码/包元数据确认] packages/boot/app-boot/package.json 提供根入口，rc.8 npm 元数据返回：

- main: lib/index.js
- types: lib/types/index.d.ts
- exports: .、./invariant、./src/*、./package.json

可复用的根入口包括 resolveProfileDir、initProfile、loadProfile、readProfileManifest、writeProfileManifest、resolveBundleDir、composeEntries、healProfilesModuleFallback、boot 和 watchUserPatches。Profile 的 manifest 结构和 Bundle 的 dsh.bundle.patch 结构也由官方文档定义。

本次推荐只使用根入口；不使用任何没有 documented contract 的源码 deep import。虽然包元数据列出 ./src/*，这不应被当作知己的集成依赖。

官方资料：[app-boot README](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/packages/boot/app-boot/README.md)、[Profile 源码](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/packages/boot/app-boot/src/profile.ts)、[插件发布教程](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/user/develop/basic/publish.md)。

### Loader

[官方文档/源码确认] Loader 的公开 API 包括 create、update、remove、resolve、resolveGroup、await 和 locate。Loader 负责运行中的 EntryTree 和插件 Fiber 生命周期。

这解决的是“Profile 已经组合完成后，如何管理运行中 entry”的问题，不等于“如何安装一个新的 npm Bundle”。安装、Profile manifest 和 Bundle layer 仍由 app-boot/CLI 处理。

官方资料：[Loader README](https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/vendor/loader/README.md)、[Loader package.json](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/vendor/loader/package.json)。

### HMR

[官方文档/源码确认] HMR 根入口可用，但要求 Loader、Timer 和能够访问 Node internal module loader 的运行时。HMR 会监听源文件和精确配置路径；插件源文件改变时，卸载并重新加载受影响 entry；框架级依赖变化会调用 loader.exit()，交给宿主重启。

因此“支持 HMR”不能被简化为“任何 Bundle 版本更新都零重启”。HMR 是运行中代码/配置变更的机制，包依赖和 Bundle membership 仍有 Profile boot 边界。

官方资料：[HMR README](https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/vendor/hmr/README.md)、[Composition and HMR 教程](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/cordis-tutorial/06-composition-and-hmr.md)。

### Profile/Bundle 与 dsh plugin

[官方源码确认] apps/cli/src/plugin.ts 的 runPlugin() 是薄转发器：

- 初始化缺失 Profile；
- 对 Windows 使用 shell 方式调用 PATH 中的 pnpm；
- 将剩余参数原样传给 pnpm；
- 成功后检查安装包是否声明 dsh.bundle.patch，并重写 dsh.profile.bundles；
- 包没有 Bundle 声明时只作为普通 dependency，并给出 warning。

[未发现的能力] 这条路径没有公开的 Host API、签名校验、官方来源白名单、事务回滚或市场目录。它不能直接作为知己的插件管理服务导入。

官方资料：[plugin.ts](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/apps/cli/src/plugin.ts)、[profile-boot.ts](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/apps/cli/src/profile-boot.ts)、[CLI reference](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/apps/cli/reference/README.md)。

### inventory

[源码/测试确认] inventory 是 read-only Host projection。list() 每次直接遍历 ctx.loader.entries()，跳过 group entry，返回：

| 字段 | 含义 |
|---|---|
| entryId | Loader entry 的稳定 id |
| moduleName | entry 的 module specifier |
| enabled | 是否 disabled |
| fiberPhase | pending、loading、active、failed、unloading，或没有 live Fiber 时为 null |

inventory 不返回 package version、来源 URL、npm/tag/commit、profile、Bundle provenance、lockfile、安装时间、失败历史、订阅事件，也没有 enable/disable/add/remove/update 方法。它不能独立支撑知己的插件管理 UI 或版本审计。

官方资料：[inventory README](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/packages/host/plugin-inventory/README.md)、[inventory source](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/packages/host/plugin-inventory/src/index.ts)。

### SDK 是否能替代 Profile Host

[源码/包文档确认] packages/sdk 提供的是驱动完整 Harness runtime subprocess 的 stdio JSON-RPC client/protocol/server 组合。它不创建 Profile、不解析 Bundle、不安装 pnpm dependency，也没有本次所需的 Host composition API。当前 SDK 还没有把知己现有 MessagePort bridge 的中途取消、server-to-client request 和 protocol version negotiation 完整替代掉。

结论：P1 不应为了复用 Profile 而把当前 Utility MessagePort 改造成 SDK subprocess 协议；这会扩大集成面而不减少 Profile Host 工作。

## 实际执行命令与结果

所有命令均在 Windows PowerShell 执行。输出中的 warning 原样保留为判断依据，不把 warning 当成通过条件之外的成功。

### 版本和源码状态

~~~powershell
git -C D:\AI\deepseek-harness status --short --branch
git -C D:\AI\deepseek-harness rev-parse HEAD
node -p "require('D:/AI/deepseek-harness/package.json').version"
node -p "require('D:/AI/deepseek-harness/package.json').packageManager"
node -p "require('D:/AI/deepseek-harness/package.json').engines.node"
node --version
npm --version
pnpm --version
~~~

结果：

~~~text
## master...origin/master
141eb6fef83422698aef7a981029e843e8161534
0.1.0-rc.8
pnpm@11.7.0
^22.19.0 || >=24.0.0
v24.18.0
11.16.0
11.22.0
~~~

[源码/测试确认] 上游工作区干净；本机 Node 满足上游根 package.json 的 engine 声明。Electron 内嵌 Node 与该声明的精确关系仍需在未来打包 Profile Host 里单独确认。

### npm dist-tags、精确版本和 exports

执行了：

~~~powershell
npm view @deepseek-ai/dsh dist-tags --json
npm view @deepseek-ai/dsh-app-boot dist-tags --json
npm view @deepseek-ai/dsh-host-plugin-inventory dist-tags --json
npm view @deepseek-ai/dsh@0.1.0-rc.8 version main bin exports --json
npm view @deepseek-ai/dsh-app-boot@0.1.0-rc.8 version main types exports --json
npm view @deepseek-ai/dsh-host-plugin-inventory@0.1.0-rc.8 version main types exports --json
npm view @deepseek-ai/cordis-plugin-loader@1.0.2 version main types exports --json
npm view @deepseek-ai/cordis-plugin-hmr@1.0.16 version main types exports --json
~~~

关键结果：

~~~text
@deepseek-ai/dsh             latest 0.1.0-rc.7   next 0.1.0-rc.8
@deepseek-ai/dsh-app-boot    latest 0.1.0-rc.6   next 0.1.0-rc.8
@deepseek-ai/dsh-host-plugin-inventory
                              latest 0.0.1-rc.3  next 0.1.0-rc.8
@deepseek-ai/cordis-plugin-loader
                              latest 1.0.2        next 1.0.2-rc.4
@deepseek-ai/cordis-plugin-hmr
                              latest 1.0.16       next 1.0.16-rc.4
@deepseek-ai/cordis          latest 4.0.1
~~~

rc.8 app-boot、inventory、stable Loader、stable HMR 的 metadata 均返回了公开 main/types/exports。rc.8 dsh 只返回 bin，未返回 main/exports。

这条结果修正了规划文档中“rc.8 未发布”或“所有目标能力只有 master 源码”的过强表述：准确事实是 rc.8 已可按精确版本/next 获取，但不是 latest，且没有进入知己当前依赖闭包。无需为了这一事实修正修改规划文档，本报告给出证据即可。

### 官方上游测试

最初执行：

~~~powershell
pnpm exec vitest run apps/cli/tests/built-bin.e2e.ts --reporter=verbose
~~~

结果：退出码 1，原始关键输出为：

~~~text
No test files found
~~~

原因是默认 Vitest 配置只包含 package spec 文件，没有加载 e2e 配置；这不是产品失败，但不能把这条命令写成通过。

随后执行正确的 e2e 配置：

~~~powershell
pnpm exec vitest run --config vitest.e2e.config.ts apps/cli/tests/built-bin.e2e.ts --reporter=verbose
~~~

结果：退出码 0，1 个文件、18 个测试通过。相关测试实际覆盖：

- 预构建 custom Profile 的启动和 dispose；
- Profile patch 的热更新与移除后恢复；
- 相对路径 add 以 invoking directory 为锚点；
- remove 同时移除 dependency 和 Bundle layer；
- update 后新版本取得 dsh.bundle 声明时自动加入 Bundle list。

继续执行：

~~~powershell
pnpm exec vitest run packages/boot/app-boot/tests/config-reload.spec.ts packages/boot/app-boot/tests/hmr-config.spec.ts packages/boot/app-boot/tests/user-patches.spec.ts packages/host/plugin-inventory/tests/inventory.spec.ts --reporter=verbose
~~~

结果：退出码 0，4 个文件、36 个测试通过。覆盖了配置失败保留 last-good tree、entry 替换回滚、精确配置 watcher、用户 patch add/failure/recovery/removal、inventory projection 等。

### 本地无副作用 Bundle fixture

为了不执行第三方插件，临时构造了 dsh-p0-local-bundle 的 1.0.0 和 2.0.0 预构建 tarball。package.json 仅声明：

- type: module
- main: index.js
- files: index.js、cordis.patch.yml
- dsh.bundle.patch: ./cordis.patch.yml

index.js 只导出值和函数，不读写外部文件、不联网、不生成子进程。fixture 和本地 127.0.0.1 registry 测试结束后已删除。

命令和结果：

~~~powershell
node D:\AI\deepseek-harness\apps\cli\lib\bin.js plugin --profile p0 add --offline <absolute-path>\dsh-p0-local-bundle-1.0.0.tgz
~~~

退出码 0。Profile package.json 写入精确 file tarball dependency；dsh.profile.bundles 包含 @deepseek-ai/dsh-base 和 dsh-p0-local-bundle；--dump-config 输出 p0-local-bundle layer。

~~~powershell
node registry-server.mjs 4873
node D:\AI\deepseek-harness\apps\cli\lib\bin.js plugin --profile p0 update --registry http://127.0.0.1:4873 --latest dsh-p0-local-bundle
~~~

退出码 0。Profile dependency 从 1.0.0 变为 2.0.0，pnpm-lock.yaml 的 importer/package/snapshot 均为 2.0.0，Bundle layer 仍然存在。该测试验证了真实的版本解析和 update，不是仅修改已安装目录。

~~~powershell
node D:\AI\deepseek-harness\apps\cli\lib\bin.js plugin --profile p0 remove dsh-p0-local-bundle
~~~

退出码 0。dependency 被移除，Bundle list 恢复为 @deepseek-ai/dsh-base，dump-config 中不再出现 fixture layer。

还执行了一个故意错误的转发参数：

~~~powershell
node D:\AI\deepseek-harness\apps\cli\lib\bin.js plugin --profile p0 remove dsh-p0-local-bundle --offline
~~~

退出码 1，原始关键输出为：

~~~text
[ERROR] Unknown option: 'offline'
dsh: pnpm failed with exit code 1
~~~

这证明 dsh plugin 是 pnpm 薄转发器；它不会把所有 pnpm 选项抽象成自己的稳定 API。失败后 Profile 未被错误命令移除，随后用不带 --offline 的合法命令完成了移除。

### 知己 Windows/Electron 路径

执行：

~~~powershell
npm run package
~~~

结果：退出码 0，Electron Forge 报告 Packaging for x64 on win32；Vite 成功构建 main、preload、renderer 和 src/main-process/agent/utility.ts。

保留的 warning：

~~~text
npm warn Unknown project config "electron_mirror".
node_modules/gray-matter/lib/engines.js ... Use of eval ...
~~~

这些 warning 没有阻止本次 package，但不能忽略为零风险。

打包后检查：

~~~powershell
npx --no-install asar list apps\zhiji-desktop\out\知己-win32-x64\resources\app.asar
Get-ChildItem apps\zhiji-desktop\out -Recurse -File -Filter *.node
~~~

结果：

- app.asar 包含 .vite/build/utility.js 和 @deepseek-ai DSH 包；
- app.asar.unpacked 实际包含 @koromix/koffi-win32-x64/win32_x64/koffi.node；
- forge.config.ts 的 external/ignore 规则保留了 DSH package-relative package.json 解析所需的 node_modules，并将 native .node 解包。

执行：

~~~powershell
npm test -- tests/unit/dsh-runtime.test.ts --reporter=verbose
~~~

结果：退出码 0，1 个文件、4 个 DshRuntime 测试通过，覆盖 Utility 侧启动、Agent loop、严格工具桥、持久化恢复和损坏数据报告。

执行：

~~~powershell
npm run test:e2e
npm run typecheck
~~~

结果：

- test:e2e 退出码 0；Playwright 在打包后的 app.asar 上运行 1 个桌面测试，1 passed（7.4s）；测试结束关闭 Electron app 并清理临时 data/userData；
- typecheck 退出码 0。

这些结果确认知己现有固定 Runtime 的 Windows 打包、当前 Utility 入口和桌面启动/退出路径可复现通过；它们没有确认“rc.8 app-boot + Profile + 外部 Bundle 在打包后的 Utility Process 中已可用”。后者仍是 P1 输入。

## 热更新、Profile 重启和源码 HMR 的边界

| 变更 | 官方语义 | 对知己的含义 |
|---|---|---|
| profile cordis.patch.yml 增删/修改 | app-boot 通过 HMR watcher 事务性重组 patch；非法文件保留 last-good tree 并发出失败事件 | 未来可留在同一个 Profile Host/Utility 中热更新；仍需把错误状态映射给 Main。 |
| home patch 修改 | 同样属于配置层重组 | 不能绕过知己自己的数据/权限边界。 |
| 已加载插件源文件修改 | HMR 跟踪 Node module graph，卸载并重新加载受影响 entry | 依赖 Node internal module loader；不代表 npm 包版本变更已热替换。 |
| framework-level dependency 修改 | HMR 可调用 loader.exit()，让宿主重启 | 未来应重启 Profile Host Utility，而不是重写 Bundle 生命周期。 |
| dsh.profile.bundles 增删 | Bundle set 在 Profile start 时组合；官方 CLI 文档要求重启 Profile | 需要 stop/restart Profile Host Utility；不要求整个知己桌面重启，但这一点尚未在知己新 Host 中实测。 |
| Bundle package update | pnpm update 后 CLI reconcile manifest；运行中的 Profile 不自动取得新的 Bundle membership | 不能把 update 成功写盘误报成 live update；必须重新启动 Profile Host。 |

证据：[CLI reference 的 Profile/plugin-management 章节](https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/apps/cli/reference/README.md)、[HMR README](https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/vendor/hmr/README.md)、[HMR 教程](https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/docs/cordis-tutorial/06-composition-and-hmr.md)。本次官方测试确认了配置 HMR；没有把 Bundle membership 改动注入一个已运行的 Electron Profile Host，因为知己目前没有这个 Host。

## 插件安装、更新、移除的真实可行性

### 官方 CLI 当前能做什么

[源码/测试确认] 在 Windows 内置 CLI 路径中，以下已可复现：

- npm registry 预构建 Bundle：add；
- 本地预构建 tarball：add；
- 本地 directory/link：add；
- 通过 pnpm registry 的真实版本更新：update；
- remove dependency 并同步 Bundle list；
- update 后包新增 dsh.bundle 声明时自动激活为 Bundle layer；
- plain dependency 没有 dsh.bundle 声明时仍可安装，但不进入 Profile layer。

官方教程还明确支持 Git、npm 和 tarball，但 Git 来源安装的是 source；pnpm >=10 需要用户在 pnpm-workspace.yaml 中 allowBuilds 后才会执行 prepare。官方文档把这个 allowance 明确描述为“在安装时执行包代码”，不属于 Agent sandbox。

依据：[官方发布教程](https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/docs/user/develop/basic/publish.md) 和本报告的 local registry fixture 结果。

### 知己当前能否真正安装社区插件

当前答案：不能对产品用户作出这个承诺。

原因不是 DSH CLI 没有安装能力，而是知己当前：

1. 没有 Profile Host；
2. 没有 dsh CLI/pnpm 的产品内调用路径；
3. package.json/package-lock.json 没有 app-boot/Loader/HMR/inventory 的精确闭包；
4. 没有第三方 Node Host code 的信任/恢复/兼容性约定；
5. 当前固定 Utility 中只注册知己经过审核的工具，而不是任意 Bundle 的插件树。

未来若按推荐路线完成隔离 P1，能安装的对象应限定为：

- manifest 声明 dsh.bundle.patch；
- npm/tarball/local checkout 已包含可加载的构建产物；
- package.json、lockfile、peer dependencies 与 Profile Host 的精确 DSH 版本闭包匹配；
- 插件只依赖 Profile Host 实际提供的 Cordis/DSH services；
- 没有未处理的 native ABI 或 Electron packaging 问题；
- 用户明确接受它是同进程 Node 宿主代码。

以下情况需要区分：

| 情况 | pnpm/DSH 行为 | 知己产品判断 |
|---|---|---|
| 没有 dsh.bundle.patch | 可以作为普通 dependency 安装，但不激活 Bundle layer | 不能称为“已安装可用插件”。 |
| Git 包有 prepare，但没有 allowBuilds | pnpm >=10 可能拒绝执行构建 | 当前路线不接受，除非明确选择并信任源码构建。 |
| 只有 TypeScript source，没有 lib/dist | 安装可能成功，boot 时解析失败 | 不能安装为可运行 Bundle。 |
| peer 依赖混用 rc.6、rc.7、rc.8 | 可能安装或启动失败，版本关系不受本报告保证 | 必须停止，不放宽版本判断。 |
| 需要 dsh-base 的 shell/fs/skills/network 等知己未提供的能力 | package 可下载，但 Profile boot/entry 会失败或权限语义不一致 | 不能接入当前知己默认 Runtime。 |
| 需要 native .node 且没有正确 Electron ABI/unpack | 可能在安装后或 Utility boot 时失败 | 不能进入产品路径。 |
| 来源、代码、行为未核验 | 技术上 pnpm 可能仍会安装 | 产品上拒绝；安装能力不等于信任。 |

## Windows/Electron 风险

### 已确认的部分

- 知己现有 Utility 入口使用 process.parentPort 接收 MessagePort；Main 使用 utilityProcess.fork、MessageChannelMain 和 exit/error 处理。
- Vite 将 @deepseek-ai 包外置，避免 DSH 包的 createRequire(import.meta.url) 找不到自身 package.json。
- Forge 保留 DSH、koffi 和 @koromix，并将 .node 解包。
- 当前 Windows x64 package、桌面 E2E、DshRuntime 单测和 typecheck 均通过。

对应本地代码：

- apps/zhiji-desktop/src/main-process/agent/utility.ts
- apps/zhiji-desktop/src/main-process/agent/electron-agent-runtime.ts
- apps/zhiji-desktop/vite.main.config.ts
- apps/zhiji-desktop/forge.config.ts

### 尚未确认的部分

- Electron 43 的内嵌 Node 是否在所有目标构建上满足 DSH root engine；本机 node v24.18.0 通过不等于打包后 Electron Node 已验证。
- app-boot 的 Node internal module loader 能否在知己打包后的 Utility Process 中完整工作。
- Profile Home 下的 pnpm workspace、lockfile、node_modules fallback 和 Windows junction farm 在安装权限受限的用户环境中是否稳定。
- 外部 Bundle 自带 native module 时，Forge 的 external/ignore/unpack 是否能覆盖未知包，而不是只覆盖当前已知的 koffi。
- Profile Host 崩溃、坏 Bundle、安装中断和 Profile restart 的数据恢复流程。

[推断] 由于 app-boot 的 fallback 会维护 DSH_HOME/profiles/node_modules，Windows 的 junction 权限、路径规范化和真实目录冲突是实际风险；这不是 Git、版本号、普通 TypeScript 测试能覆盖的。P1 应先做一次临时 Profile Host 启停和失败恢复试验，不能直接进入产品安装路径。

## 插件市场现状

[源码/官方页面确认] 官方仓库本次扫描没有发现 first-party marketplace、plugin store 或官方插件注册服务。官方的 dsh-plugin topic 是 GitHub 的公开 topic 页面，包含 DSH 仓库和大量社区/非官方项目；它提供发现入口，不提供版本审计、签名、兼容性证明、安装事务或官方背书。

依据：[GitHub dsh-plugin topic](https://github.com/topics/dsh-plugin)、[官方插件发布教程](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/user/develop/basic/publish.md)。

因此：

- npm 是分发 registry，不是官方 DSH 市场；
- GitHub topic 是搜索标签，不是官方市场；
- 社区目录、第三方网页或“插件商店”不能被当作 DeepSeek 官方兼容性证明；
- P0 不建设知己插件市场，也不为社区插件做自动搜索或下载。

## 安全与信任边界

### 当前知己边界

知己当前的 Renderer 使用 nodeIntegration false、contextIsolation true、sandbox true；Main Process 保留 API key、数据根目录、正式写入和权限判断；Utility 只运行固定的 DSH Agent/Loop/Tools 组合，并通过受控 MessagePort 请求 Main 的知己服务。

这个边界保护的是“固定 Runtime 能调用哪些知己服务”，不是“任意加载进 Utility 的 Node 模块能做什么”。

### 第三方 DSH Node 插件的真实权限

[官方文档确认] Bundle 中的插件模块由 Node Loader 导入并在宿主进程中 mount；Git prepare 的执行还发生在安装阶段，官方明确提示它在 Agent sandbox 之外运行。

[推断] 一个被加载进同一 Utility Process 的第三方 Node 插件通常可以使用该进程账户可用的 Node 能力，包括读取有权限的文件、访问网络、创建子进程、加载 native module 和观察/修改同进程可见的配置对象。它不需要通过 zhiji.journals.* 或其他知己 API 才能做这些事情。

所以不能使用以下错误表述：

- “知己只暴露了几个 API，所以第三方插件被系统沙箱限制了。”
- “DSH sandbox 会自动沙箱化插件本身。”
- “inventory 只返回少数字段，所以插件只能看到少量信息。”

正确表述是：知己 API bridge 可以限制插件调用知己正式数据服务的路径，但不能把同进程 Node 插件变成 OS-level sandbox。若产品不能接受这个信任模型，平台化应停止。

### P0 的安全结论

- 不下载或执行未核验第三方插件；
- 不把 GitHub topic、npm 包名或社区目录当成信任；
- 预构建 tarball 降低安装时执行脚本，不等于运行时插件安全；
- allowBuilds 是明确的安装时执行权限，应作为高风险操作处理；
- 现有 DSH sandbox 的文件效果约束针对 DSH model-facing subprocess，不替代第三方 Host code 隔离；
- P0 不新增 hash、baseline 或自建安全 gate；先把具体事故和现有机制缺口记录清楚。

## 唯一推荐集成路线

### 隔离复用路线

1. 保持当前固定 Runtime 和现有 Main/Utility/Renderer 权限边界为默认生产路径。
2. 未来只增加一个可选的 Profile Host adapter，运行在独立的 DSH Utility/Host 生命周期中，不把通用第三方插件直接塞进当前固定 DshRuntime。
3. Profile Host 只使用 app-boot、Loader、HMR、inventory 的公开根入口；锁定完整 rc.8 依赖闭包和 Cordis 4.0.1，不使用 internal deep import、不混用 latest、不复制上游源码。
4. 包管理继续委托官方 dsh CLI/pnpm；知己只负责调用边界、Profile 目录、Main 权限桥和 Utility stop/restart。不要自建 pnpm 替代物、插件协议或市场。
5. 第一阶段只接受预构建 npm/tarball 或明确审核的本地 Bundle；不在产品路径中执行 Git prepare 或任意第三方安装脚本。
6. Profile patch 和源文件编辑留给 DSH HMR；Bundle membership 的 add/remove/update 只触发 Profile Host Utility 重启，不重写 Bundle 生命周期，也不要求整个桌面重启。
7. inventory 只作为运行态只读 projection；版本、来源和 lockfile provenance 若以后确有产品需求，另行依据证据决定，不把 inventory 误扩展成包管理器。

这是成本最低的路线，因为 DSH 继续拥有 Profile composition、Loader lifecycle、HMR 和 pnpm integration；知己只增加宿主进程、Main bridge、打包和信任适配。复制 Loader/HMR/Profile parser 或自己定义包管理器都会引入上游漂移和第二套生命周期真相。

## 继续条件与停止条件

以下是进入 P1 的事实输入条件，不是本次新增实现的 gate、hash 或 baseline。

### 允许继续到 P1 的条件

1. 在干净临时 Profile 中，精确 rc.8 app-boot、inventory 及其 peer closure 能通过公开根入口安装和启动，不用 deep import、不复制源码、不混用 rc。
2. 在打包后的知己 Windows x64 Utility Process 中，Profile Host 能启动、报告 ready、正常 stop，并能在不重启整个桌面的情况下重启 Profile Host。
3. Profile patch 热更新、Bundle membership 重启、坏配置 last-good/recovery 三条边界都有可复跑结果。
4. pnpm 的解析位置和版本在 Electron 打包后是确定的；不能依赖用户机器偶然存在的 pnpm PATH。
5. 至少有一个真实用户价值明确的、预构建、无 native dependency 的受控 Bundle fixture，能 add、启动、提供能力、remove 并恢复固定 Runtime。
6. 产品负责人明确接受“第三方插件是同进程 Node host code，不是系统沙箱”的信任模型，并决定其默认是否关闭。

### 必须停止的条件

- 只能通过 internal deep import、复制上游实现或混用 rc.6/rc.7/rc.8 才能启动；
- 公开包闭包无法在干净 Profile 安装，或 pnpm/Node 版本无法在打包应用中确定；
- Utility Process 无法稳定加载、退出、重启 Profile，或 native module 需要无法维护的打包 fork；
- 为了零重启而重写 DSH Bundle/Profile 生命周期；
- 需要知己自建包管理器、插件协议、签名市场或大规模改造当前固定 Runtime；
- 没有明确用户价值，只有“以后可能有社区插件”的规划假设；
- 安全/信任边界无法被产品接受。

## 最终裁决

**CONDITIONAL GO。**

含义严格限定为：

- 可以继续做一个隔离的 P1 可行性实现，前提是满足上面的输入条件；
- DSH 官方 Profile、Bundle、Loader、HMR、inventory 的核心复用方向成立；
- 不能把当前知己描述成已经具备社区插件安装能力；
- 不能把 dsh-plugin topic 描述成官方插件市场；
- 不能把知己 API 权限桥描述成系统沙箱；
- 当前生产 Runtime 应继续保持固定实现，直到隔离 Profile Host 和信任边界有实测证据。

## 允许进入 P1 的明确输入（本次未执行）

1. 精确锁定并验证：@deepseek-ai/dsh-app-boot 0.1.0-rc.8、@deepseek-ai/dsh-host-plugin-inventory 0.1.0-rc.8、@deepseek-ai/cordis 4.0.1、Loader 1.0.2、HMR 1.0.16，以及 app-boot/inventory 所需的 group、include、timer、launch-environment、home-paths、brand、typert、invariants 等完整 peer closure。
2. 一个只包含 dsh.bundle.patch、无 install/build script、无 native dependency 的预构建 Bundle fixture。
3. 一个 Electron Utility Process 的 Profile Host 启停探针，明确使用公开根入口和现有 MessagePort/Main bridge，不修改当前固定 DshRuntime。
4. 一个只在本地临时目录执行的 add、dump-config、启动、patch HMR、Bundle restart、update、remove、recovery 测试集。
5. Windows 打包方案：确定 pnpm 的分发/解析位置、DSH 包 externalization、Profile node_modules fallback/junction 和未知 native dependency 的处理方式。
6. 产品级信任决定：是否只允许审核后的预构建 Bundle；是否向用户公开任何安装入口；第三方 host code 的风险提示、失败恢复和撤销策略。

P1 输入条件未满足前，不执行插件 UI、插件市场、生产 Runtime 改造或社区插件安装。

## 证据索引

### 上游本地源码路径

- D:\AI\deepseek-harness\apps\cli\src\plugin.ts
- D:\AI\deepseek-harness\apps\cli\src\profile-boot.ts
- D:\AI\deepseek-harness\apps\cli\reference\README.md
- D:\AI\deepseek-harness\packages\boot\app-boot
- D:\AI\deepseek-harness\packages\host\plugin-inventory
- D:\AI\deepseek-harness\packages\sdk
- D:\AI\deepseek-harness\vendor\loader
- D:\AI\deepseek-harness\vendor\hmr
- D:\AI\deepseek-harness\docs\user\develop\basic\publish.md
- D:\AI\deepseek-harness\docs\cordis-tutorial\06-composition-and-hmr.md

### 知己本地路径

- C:\Users\panda\.claude\skills\知己\apps\zhiji-desktop\package.json
- C:\Users\panda\.claude\skills\知己\apps\zhiji-desktop\package-lock.json
- C:\Users\panda\.claude\skills\知己\apps\zhiji-desktop\src\main-process\agent\utility.ts
- C:\Users\panda\.claude\skills\知己\apps\zhiji-desktop\src\main-process\agent\electron-agent-runtime.ts
- C:\Users\panda\.claude\skills\知己\apps\zhiji-desktop\vite.main.config.ts
- C:\Users\panda\.claude\skills\知己\apps\zhiji-desktop\forge.config.ts

### 官方公开链接

- [DeepSeek Harness repository](https://github.com/deepseek-ai/deepseek-harness)
- [dsh CLI source](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/apps/cli/src/plugin.ts)
- [Profile boot source](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/apps/cli/src/profile-boot.ts)
- [CLI behavior reference](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/apps/cli/reference/README.md)
- [app-boot](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/packages/boot/app-boot/README.md)
- [Loader](https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/vendor/loader/README.md)
- [HMR](https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/vendor/hmr/README.md)
- [plugin-inventory](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/packages/host/plugin-inventory/README.md)
- [Bundle publish/install](https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/docs/user/develop/basic/publish.md)
- [Composition and HMR](https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/docs/cordis-tutorial/06-composition-and-hmr.md)
- [GitHub dsh-plugin topic](https://github.com/topics/dsh-plugin)
- [@deepseek-ai/dsh exact npm version](https://www.npmjs.com/package/%40deepseek-ai/dsh/v/0.1.0-rc.8)
- [@deepseek-ai/dsh-app-boot exact npm version](https://www.npmjs.com/package/%40deepseek-ai/dsh-app-boot/v/0.1.0-rc.8)
- [@deepseek-ai/dsh-host-plugin-inventory exact npm version](https://www.npmjs.com/package/%40deepseek-ai/dsh-host-plugin-inventory/v/0.1.0-rc.8)
