# ReflectLoop（知己）

> Turn personal records into evidence-grounded reflections and testable actions.

ReflectLoop（中文名“知己”）是一个面向中文个人日志的本地优先 AI 复盘系统。它帮助你从真实记录中整理证据、发现模式、形成一个低成本行动，并在后续记录中验证和校准认识。

[![Version](https://img.shields.io/badge/版本-v2.6.5-green)](VERSION)
[![License](https://img.shields.io/badge/许可证-MIT-yellow)](LICENSE)

```text
记录事实 → 发现模式 → 形成行动 → 记录结果 → 校准认识
Record → Reflect → Act → Verify → Calibrate
```

它不是日记代写工具，也不以生成更多报告为目标。一次有用的输出应当区分事实与推断，指出一个有原文依据的模式，并给出能够在现实中验证的下一步。

## 选择适合你的入口

ReflectLoop 是项目总称；Windows 客户端、Codex/Claude、DSH 插件和 WorkBuddy 是不同运行入口，不会自动共享同一份数据。

| 你的使用方式 | 推荐入口 | 说明 |
| --- | --- | --- |
| 希望直接安装 Windows 应用 | [ReflectLoop Desktop Agent（知己 Windows 客户端）](https://github.com/an-X550/Reflectloop-Desktop-Agent) | 提供受控 Agent、开始、日志、复盘、项目和设置六个可视化入口；数据默认保存在本机；主仓库快照见 [桌面端说明](apps/zhiji-desktop/README.md) |
| 使用 Codex 或 Claude 读取本地 Markdown | [用户版分发仓库](https://github.com/an-X550/knowing-yourself-zhiji-user) | 下载或复制完整工作区后，Codex 可直接使用自然语言；Claude 保留 Slash Command 兼容入口；本地快照见 [用户版使用指南](zhiji-user/README.md) |
| 已安装 DeepSeek Harness | [ReflectLoop DSH 插件](https://github.com/an-X550/zhiji-dsh-plugin) | 在 DSH 会话中处理粘贴材料，或在显式配置后按日期范围只读聚合日志；主仓库快照见 [插件说明](apps/zhiji-dsh-plugin/README.md) |
| 需要手机消息入口 | [WorkBuddy + 飞书智能体部署说明](zhiji-user/docs/workbuddy-deployment.md) | 通过 `[知己]` 前缀路由日志、复盘和主题讨论；外部写入仍受授权边界约束 |

想先快速浏览而不配置运行环境，可以打开[用户上手页](zhiji-user/index.html)和[浏览器版使用说明](zhiji-user/guide.html)。四个仓库是独立发布边界：主仓库维护产品与 Skill/CLI 运行真相，用户版是安装入口，Desktop Agent 是 Windows 应用，DSH 插件是 DeepSeek Harness 适配层。

## 它能帮助你解决什么

写日志时，人容易记住当天的感受，却很难看见跨时间重复出现的模式；即使得到一个解释，也常常没有后续验证。ReflectLoop 将不同周期的复盘收敛到同一条闭环：

| 你的情况 | 可以直接说 | 你会得到 |
| --- | --- | --- |
| 刚写完日志，或今天卡住了 | `帮我做今天的日志反馈` | 一个关键洞察、一个小实验、一个观察点 |
| 不知道下一步该补什么 | `最近有什么该补？` | 当前最优先的一条闭环缺口 |
| 想把日志写得更有用 | `看看我最近几天的日志质量，只告诉我优先改进什么` | 最该补的一类证据与写作建议 |
| 想复盘一周、一个月或项目 | `生成本周复盘` / `对 X 做项目复盘` | 趋势、证据、反例与下一步 |
| 长期目标、精力或生活结构持续冲突 | `我想重新检查最近的生活方向` | 方向冲突、证据缺口与可验证的小实验 |
| 想讨论并沉淀长期观点 | `先讨论这个问题，不要保存；形成认识后再问我是否写入` | 可确认、可修正的认识与依据 |

日反馈优先于周、月和年度回顾。材料不足时，系统应建议先完成最近一次小闭环，而不是制造一份看似完整的报告。

## 最小可用闭环

完成环境准备后，把一段真实日志交给所选入口：

```text
分析这篇日志。请找出一个我可能没看到的模式；区分事实与推断；
只给我一个明天可验证的小实验，并告诉我下次需要记录什么结果。

日志：今天本来要完成方案，但我一直整理资料，直到晚上也没开始写正文。
```

下一次记录时补上：

```text
上次实验：做了 / 没做 / 做了一部分
结果：发生了什么
判断：支持原假说 / 出现反例 / 仍待验证
```

先完成一次行动和验证，再考虑更长周期的复盘；没有验证时，增加报告通常不会带来更多改变。

## AI 与 Agent 的位置

AI 和 Agent 是完成复盘闭环的手段，不是 ReflectLoop 的产品目的。不同入口的实现不同，但都应遵守相同边界：

- 从用户授权的日志、复盘、项目或公开来源中整理证据；
- 区分事实、推断、建议和证据不足；
- 将结论收敛为一个可观察、可推翻的小实验；
- 正式日志、反馈和复盘的改变遵守预览—确认—执行；
- 不因引入 Agent 而获得任意文件、Shell、浏览器或电脑控制权限。

Windows 客户端内置受控 Agent，支持有限的本地历史检索、公开来源搜索、工具回合与会话恢复；具体能力和限制以[桌面客户端 README](apps/zhiji-desktop/README.md)为准。

## 适合谁，不适合谁

如果你想从拖延、情绪反复、精力波动、项目复盘或长期方向冲突中找出可检验的规律，ReflectLoop 适合你。一段真实、简短的记录就足够开始，不需要先养成完美的日记习惯。

它不诊断心理或医疗问题，不替你决定人生，也不会把一篇日志当作对你的最终结论。AI 的分析只是待验证的假说；证据不足时应降低结论强度，而不是补完故事。

## 隐私与数据边界

- 只提供你愿意交给当前 AI 服务处理的内容；真实日志默认不进入 Git，但这不等于加密或访问控制。
- 本地 Markdown 是 Skill/CLI 入口的权威记录；Windows 客户端使用自己的本地 Markdown/JSON 数据目录，两者不会自动同步。
- 可选的飞书沉淀与滴答行动分发默认关闭；本次只想保存在电脑时，直接说“仅本地”。
- AI 负责整理证据、提出假说和设计低成本实验；你保留对经历、价值选择和重大决定的最终解释权。

完整设置见[用户版使用指南](zhiji-user/README.md)、[结果分发设置](docs/result-distribution-setup.md)和[Windows 客户端数据说明](apps/zhiji-desktop/README.md#数据备份与隐私)。

## 项目与协作

本仓库是 ReflectLoop 的主仓库，保存 Skill、共享契约、运行定义、用户分发包和独立组件的迁移快照；`.claude/` 是 Skill/CLI 侧的唯一运行真相。

- 当前能力、待验证事项与已知限制：[PROJECT_STATUS.md](PROJECT_STATUS.md)
- 版本变化：[CHANGELOG.md](CHANGELOG.md)
- 仓库地址与独立推送边界：[docs/standalone-repositories.md](docs/standalone-repositories.md)
- 仓库改名经过、旧名称兼容与排障：[docs/2026-08-22-reflectloop-repository-naming-migration.md](docs/2026-08-22-reflectloop-repository-naming-migration.md)
- 维护与贡献规范：[AGENTS.md](AGENTS.md)
- 用户版同步流程：[docs/zhiji-user-sync-workflow.md](docs/zhiji-user-sync-workflow.md)
- 方法底线：[docs/first-principles.md](docs/first-principles.md)

## 许可证

本项目采用 [MIT License](LICENSE)。
