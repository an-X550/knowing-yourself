# 个人飞书入口、远程使用与 AI 部署

> 这是主项目个人运行环境的权威说明，不同步到 `zhiji-user/`。人类只需理解运行条件和授权点；“交给 AI 的部署指令”供维护或迁移时直接复制给执行型 AI。

## 先说结论

当前最高性价比方案是继续使用本地 Windows 电脑：手机把自然语言日志发给飞书机器人，本机监听调用分析后端生成每日反馈，再由确定性工具完成飞书沉淀和滴答行动创建。UU 远程只负责人在外面时维护电脑，不参与消息接收、分析或分发。

先观察 14 天真实使用频率；只有达到至少 10 天日志、7 次手机直达反馈，并且“电脑必须在线”仍持续造成明显阻碍，才评估云服务器。现在购买或开发云端服务不会提高分析质量，只会提前增加部署、凭证、日志和运维成本。

## 当前数据流

```text
手机飞书私聊
  -> 飞书开放平台事件
  -> 本机 lark-cli 事件监听
  -> 知己日反馈契约
  -> AI 分析后端
  -> 本地日志与每日反馈
  -> 飞书 lark-cli 文档沉淀
  -> 滴答 create-task 受限连接器
  -> 飞书原消息回复完整反馈
```

本地 Markdown 始终是权威结果。飞书和滴答都是写入成功后的后置分发；任一外部渠道失败，不得回滚或改写本地反馈。相同飞书 `message_id` 不重复分析，相同本地文件和 SHA-256 不重复创建飞书文档，滴答按规范化标题与精确截止时间防重。

## 一、飞书智能体调用的环境要求

### 当前已经验证的本机环境

| 项目 | 当前事实 |
|---|---|
| 操作系统 | Windows；当前脚本使用 Windows PowerShell |
| PowerShell | 5.1 |
| Node.js / npm | Node.js 24.18.0；npm 11.16.0 |
| 飞书工具 | 官方 `lark-cli` 1.0.86 |
| AI 入口 | Codex CLI 0.147.0，使用 ChatGPT 登录 |
| 日分析模型 | 仅飞书日分析固定为 `gpt-5.4`，推理沙箱为只读 |
| 网络 | 飞书、AI 服务和滴答连接器均须可访问；当前访问 Codex 需要 VPN |
| 电源 | 电脑不能关机或休眠；屏幕可以关闭 |
| 常驻项 | `.claude/workflows/local-feishu-daily-feedback.ps1 -Mode Run` 必须持续运行 |

不要求打开 Codex 桌面窗口。真正执行分析的是后台启动的 `codex.exe` CLI 子进程；Codex 桌面应用关闭不影响已经独立运行的监听器。当前账号登录失效、VPN 断开、电脑休眠或监听退出时，手机端都不能获得反馈。

启动前运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/workflows/local-feishu-daily-feedback.ps1 -Mode Preflight
```

预检只执行版本、飞书身份和 `codex login status` 检查，不调用模型、不消耗一次分析额度。看到 `lark=ready codex=ready config=ready` 后再启动：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/workflows/local-feishu-daily-feedback.ps1 -Mode Run
```

手机私聊本人机器人，消息以 `日志：` 或 `日志:` 开头即可；前缀后的正文可以换行，也可以采用模板或自由自然语言。正文至少应包含一项具体事实，最好再写状态、想法或下一步意图。通常需要 2–5 分钟；当前主要耗时来自 VPN、WebSocket 超时及 HTTPS 回落，不能把它理解为 GPT-5.4 的纯生成速度。

### 飞书开放平台和目录要求

1. 复用唯一的“知己 CLI”企业自建应用，启用机器人私聊消息事件 `im.message.receive_v1` 与回复消息所需权限。
2. 监听只接受配置中的唯一 `allowed_open_id`、`p2p` 文本和日志前缀；群聊、其他用户和非文本消息不进入分析。
3. 通过官方 `lark-cli` 保存应用身份与用户授权，任何 App Secret、access token 或 refresh token 都不得进入仓库、报告或聊天。
4. 飞书只写配置绑定的“知己”根目录及固定子目录；不扫描本机、不把原始日志、画像、配置、状态、代码或中间分析上传。
5. 允许分发的内容只有正式日/周/月/项目/年度复盘、人生设计、确认后的主题思考，以及用户明确收录的收藏内容和附件。收藏附件可以不是 Markdown，但必须先进入受控的收藏目录。

飞书目录和权限的完整设置门见[结果分发设置](result-distribution-setup.md)，本地消息入口的协议和验收记录见[本地飞书每日反馈入口](local-feishu-daily-feedback-entry.md)。

## 二、当前远程方式：UU 远程

UU 远程用于在手机端查看和维护这台 Windows 主机，例如确认 VPN、重新登录 Codex、查看监听窗口或重启脚本。它不是知己的数据通道：关闭 UU 远程并不会停止监听；反过来，仅连接 UU 远程也不能替代电脑在线、VPN、飞书事件监听和 AI 登录。

日常使用顺序：

1. 电脑通电、联网、不休眠，按当前网络条件保持 VPN 可用。
2. 确认飞书监听已经运行；正常情况下不需要打开 Codex 桌面应用。
3. 手机飞书发送 `日志：<任意自然语言正文>`，等待原消息下的处理中提示和最终反馈。
4. 超过 5 分钟没有结果时，再用 UU 远程检查 VPN、监听进程和 `复盘/.local-feishu-daily-feedback-runtime.log`。
5. 修复后重新发送为一条新消息；系统不提供离线队列。

安全上只启用个人账号、设备锁和平台可用的双重验证，不在远程窗口、聊天或截图中展示 App Secret、OAuth token 或 API key。UU 远程不应开放项目目录共享或无人值守文件传输权限，除非用户明确需要并理解范围。

## 三、滴答清单行动沉淀

滴答只承担执行入口，不保存完整日志或复盘。中国区使用 `dida365` 官方 MCP，目标清单固定为唯一的“知己行动”，运行配置只保存非敏感 `project_id`。

部署要求：

1. 在官方授权页面完成中国区账号授权，不把 token 复制给 AI 或写入项目。
2. 首次设置只查询一次清单，名称必须完全匹配且只有一个“知己行动”；保存其 `project_id` 后，正式运行不再读取清单。
3. 只授予并调用 `create_task`；不允许 list、search、get、update、complete 或 delete。
4. 每日反馈只创建 `⚡ 明天试试` 中唯一合格行动，最多一项；标题必须可检查，并带绝对截止日期。
5. 周/月复盘和确认后的主题思考沿用各自确认门；项目、年度、人生设计和收藏不创建滴答任务。
6. 创建失败不会改变本地反馈或飞书文档；重试必须由用户明确触发，防重状态不得删除。

飞书文档创建不需要 AI 决策；滴答任务创建也应由受限连接器完成。当前实现为了调用官方 MCP 使用隔离的 Codex 子进程，但它只暴露 `create_task`，不负责重新分析反馈。

## 四、AI 后端替换边界

真正需要 AI 的接口只有：输入“知己契约 + 当日日志”，输出一份可直接保存的 Markdown 每日反馈正文。飞书事件监听、本地落盘、SHA-256、防重、目录路由、飞书导入和滴答创建都不应交给模型自由决定。

当前实现的分析适配器是：

```text
stdin: UTF-8 日志正文
prompt: 仓库内日反馈契约和目标日期
stdout: 仅每日反馈 Markdown 正文
exit code: 0 表示成功
```

Codex 当前固定 `gpt-5.4`。以后切换到 Claude API、DeepSeek API 或其他模型时，只替换这层适配器，并保持上述输入输出契约、超时、错误码和只读权限不变。切换分析模型不需要重建飞书目录，也不需要重新授权 `lark-cli`。

如果还要移除用于滴答 MCP 的 Codex 子进程，则必须另行提供一个只允许 `create_task` 的 MCP 客户端或官方 API 适配器；这与更换分析模型是两件事。不得让 DeepSeek/Claude 直接获得任意飞书目录、任意本地文件或完整滴答权限。

通用 API 后端至少需要：服务商 API key、模型 ID、API base URL、超时、最大输出长度，以及支持 UTF-8 stdin/stdout 或等价本地进程接口的适配器。API key 只能进入系统环境变量或平台密钥存储，不能写进仓库配置。

## 五、未来备选：云服务器部署

云服务器解决的是“本机必须在线”，不是分析质量。只有本地观察门通过且离线确实持续阻碍使用时才部署。

推荐的最小云端形态仍保持单用户和单进程：

```text
飞书长连接监听 + 知己仓库 + 一个 AI API 后端
                + lark-cli 飞书分发
                + 受限滴答 create-task 连接器
                + 本地持久卷与最小日志
```

最低条件：

- 一台能持续运行 Node.js、PowerShell 7（或经验证的等价脚本）和官方 `lark-cli` 的服务器；1–2 核、2 GB 内存即可作为初始试验规格。
- 稳定访问飞书、所选 AI API 和滴答服务的网络；不依赖个人电脑 VPN。
- 持久磁盘保存仓库中的个人数据和防重状态，并有仅用户可访问的备份。
- 使用环境变量或云密钥服务保存 API key；限制入站端口，优先只建立对外出站连接。
- 用 `systemd`、Windows 服务或等价守护方式拉起监听，并设置进程退出后重启；不增加业务队列和多用户系统。

当前脚本只有 Windows 真实验收证据，不能把复制到 Linux 服务器视为已经支持。云迁移必须先用脱敏样本验证 PowerShell 路径、中文文件名、`lark-cli` 登录持久化、AI 适配器和滴答连接器，再迁移真实数据。学生云服务器价格低不等于运维成本为零；只有本地方案使用频率达标才值得承担它。

## 六、交给 AI 的一键部署指令

> 人类阅读者只需知道：下面整段可以交给 Codex、Claude、DeepSeek 或其他具备本机文件与命令执行能力的 AI。它会先检查环境，再执行能自动完成的步骤，并把平台授权留给用户。这里的“一键”是一个统一任务入口，不代表绕过飞书、滴答或 AI 服务商的人工授权。

```text
你是“知己个人飞书入口”的部署执行者。目标是在当前机器上部署单用户每日反馈闭环：
手机飞书日志 -> AI 日反馈 -> 本地写入 -> 飞书文档 -> 滴答行动 -> 飞书原消息回复。

仓库根目录由我提供。先完整读取 AGENTS.md、PROJECT_STATUS.md、
docs/personal-feishu-deployment.md、docs/local-feishu-daily-feedback-entry.md、
docs/result-distribution-setup.md，以及它们直接引用的运行契约。

硬边界：
1. 不修改、导出或同步 zhiji-user/ 与 packaging/zhiji-user-overlay/。
2. 不把 App Secret、access/refresh token、MCP token、API key 写入仓库、命令参数、报告或聊天。
3. 只接受一个 allowed_open_id 的 p2p 文本；只处理“日志：”或“日志:”前缀后的自然语言。
4. 本地 Markdown 是权威结果；写入并复读成功后才能分发。
5. 飞书只写已绑定的“知己”目录；滴答只允许 create_task；不得扫描或上传其他本地文件。
6. 不新增多用户、后台队列、Web 管理页、监控平台或其他非必要功能。

按以下顺序执行：
A. 检查操作系统、PowerShell、Node/npm、官方 lark-cli、Git 和选定 AI 后端；列出真实版本和缺失项。
B. 检查飞书 bot application identity、im.message.receive_v1、机器人回复权限和用户可见的“知己”目录。需要控制台审批或登录时暂停，只给我一条明确人工操作；不要索取或回显 secret。
C. 检查滴答账号区域。中国区绑定 dida365，国际区绑定 ticktick；只授权 create_task。首次只定位唯一“知己行动”清单并保存 project_id。
D. 从仓库示例生成被 gitignore 的本地运行配置，只写 open_id、可执行路径、folder token、project_id 和开关等 schema 已支持的非敏感值；模型写在分析适配器参数中，不擅自扩展配置 schema。
E. 配置一个分析适配器：输入 UTF-8 日志和知己日反馈契约，stdout 只输出每日反馈 Markdown，失败返回非零退出码。优先复用现有适配器，不重写分析规则。
   - Codex：使用 codex exec，当前个人方案固定 gpt-5.4、read-only、ephemeral，并用 codex login status 预检。
   - Claude：使用 Claude API/CLI 的非交互模式，API key 只放环境变量；保持同一 stdin/stdout 契约。
   - DeepSeek：使用官方 OpenAI-compatible API，API key 只放环境变量；把 system/user 消息映射到同一契约，返回正文而不是 JSON 包装。
   - 其他模型：只要能满足相同接口即可；不得改变输出骨架来迁就模型。
F. 飞书沉淀继续调用官方 lark-cli，滴答继续调用受限 create_task 连接器；不要让分析模型任意选择文件或目标目录。
G. 运行现有测试和 Preflight。用一条脱敏日志做端到端验收，记录本地路径与 SHA-256、飞书 document_token/URL、滴答唯一 task_id；重放同一 message_id 必须零新增。
H. 启动单个常驻监听。若是云服务器，只增加最小进程守护和持久目录，不扩展产品能力。
I. 最终只报告：环境状态、人工授权点、分析后端和模型、本地/飞书/滴答结果、防重结果、启动/停止命令、尚未验证事项。

如果当前代码只支持 Codex，而我选择 Claude/DeepSeek：先说明适配器缺口；只实现一个最小命令适配器并补对应测试，不改飞书和滴答分发逻辑。连续失败 3 次停止，保留原始错误证据，不用手工创建远端对象冒充自动闭环。
```

## 七、故障定位顺序

1. 没有“已收到日志”：检查电脑是否在线、监听进程、飞书 bot 身份和消息事件。
2. 有处理中但没有反馈：检查 AI 登录/API key、VPN或网络、模型可用性和运行日志。
3. 返回 `feedback_missing`：检查分析适配器 stdout 是否为非空、符合日反馈结构的 Markdown。
4. 本地成功但飞书失败：检查 `lark-cli auth status --json --verify`、应用 scope、目标 folder token 和用户权限；不得另建重复文档。
5. 本地成功但滴答失败：检查账号区域、官方授权、固定 `project_id` 和唯一 `create_task` 能力；不得读取远端任务来猜测。
6. 重复发送：以 message_id、source_path + SHA-256 和行动键核对防重状态，不删除状态文件作为修复手段。

涉及真实凭证、真实日志、远端写入或云迁移时，AI 必须贴出工具返回的脱敏证据；只看到配置或测试通过不能宣称端到端成功。
