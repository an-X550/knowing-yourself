---
date: 2026-08-21
status: S3 已完成
decision: 继续执行 S4
plugin_version: 0.3.0
dsh_version: 0.1.0-rc.8
upstream_commit: 141eb6fef83422698aef7a981029e843e8161534
---

# 知己 DSH 独立插件 S3 验证报告

## 1. 结论先行

S3 通过。插件现在可以在不读取知己桌面端、不依赖项目绝对路径的前提下，使用一个明确配置的日志根目录，按日期范围只读聚合 Markdown，并让周/月/项目 Skill 消费该材料完成复盘。插件仍不写正式报告、不保存 DSH 会话结果，也没有增加通用文件系统、Shell、网络或同步能力。

本阶段最终裁决：**继续执行 S4；保持 S3 为最小只读 MVP。**

## 2. 第一性原理与 Skill/Tool 选择

S3 要解决的真实问题不是“展示更多插件结构”，而是周/月/项目复盘如果每次都重新粘贴多份日志，输入摩擦会抵消周期复盘价值。S2 已证明 Skill 可以完成判断和降级，但 Skill 本身不能可靠地从用户机器外部目录取得确定材料。因此 Skill-only 不足以完成“按日期范围读取日志”这个新增目标。

最小补足是一个单一、只读、范围受限的 Host Tool：

- Skill 继续负责事实/推断/建议区分、主要判断、证据降级和行动规划；
- `zhiji_read_journal_range` 只负责读取显式根目录、解析日期和拼接必要材料；
- Tool 不接受任意路径，不递归扫描，不写文件，不启动子进程，不联网；
- 不建设通用文件系统 API、共享 SDK、服务层、报告保存层或插件平台。

因此本阶段采用 **Skill + 一个最小 Tool**，没有因为“插件应该有 Tool”而增加其他 Host 能力。

## 3. 使用的 DSH 官方机制

- `package.json` 的公开 `dsh.bundle.patch` 入口；
- 一个官方 Bundle entry，注入 DSH 已有的 `skills` 和 `tools` registry；
- `ctx.skills.register()` 注册四个内嵌 Skill；
- `ctx.tools.register()` 注册公开 raw `ToolDefinition`，没有 deep import 和额外运行时依赖；
- DSH Agent Loop 的原生 tool-call → tool-result → 下一次模型请求回合；
- 官方 `dsh plugin --profile <name> add/remove` 和临时 `DSH_HOME` Profile。

S2 的 patch 原先有四个相同模块入口。S3 增加 Tool 后，官方 Loader 首次加载明确报错：`tool "zhiji_read_journal_range" is already registered`。这说明同模块多入口会重复执行 `apply()`。修正为一个官方 Bundle entry 后，四个 Skill 和一个 Tool 在一次 `apply()` 中注册，后续回归全部通过。

## 4. S3 实现边界

配置方式：

```powershell
$env:ZHIJI_DSH_LOG_ROOT = 'C:\Users\you\Documents\zhiji-logs'
```

Tool 参数只有：

```json
{
  "start_date": "YYYY-MM-DD",
  "end_date": "YYYY-MM-DD"
}
```

实际行为：

- 要求环境变量存在、为绝对路径、没有 `..` 段，并解析为现有目录；
- 只检查配置根目录的顶层条目；非 Markdown、嵌套目录和非普通文件明确失败；
- 支持精确命名的 `YYYY-MM-DD.md` 日文件；
- 支持文件名含年份、正文以 `YYYY-MM-DD` 或 `M月D日` 标记的日期段；
- 按日期确定性排序，返回日期、文件名、条数、空范围状态和聚合文本；
- 空范围返回结构化空结果，不伪造材料；
- 非法日期、反向范围、缺失根目录、无法解析的 Markdown、越界 symlink 和超大材料明确失败；
- 聚合文本不包含配置根目录绝对路径；
- 不写入日志、每日反馈、验证库、项目报告或任何桌面端数据。

项目 Skill 将目录日志视为过程补充证据，不把日志本身当作项目验收证明。每日 Skill 仍保持会话粘贴输入，不自动读取目录。

## 5. 实际命令与结果

开始前执行了：

```powershell
git status --short
```

输出中的 `.codex/config.toml`、`.review-*.txt`、`docs/2026-08-20-deepseek-harness-agent-execution-plan.md` 和 `package-lock.json` 等既有无关未跟踪文件未被修改或提交。

范围读取边界测试：

```powershell
node --test tests/plugin-contract.test.mjs tests/range-reader.test.mjs
```

结果：**8 passed, 0 failed**。覆盖有效日文件和月文件日期段、空范围、缺失/相对/父路径根目录、非法日期、反向范围、非 Markdown、无日期 Markdown、嵌套目录和路径边界。

官方 DSH 临时 Profile 验证：

```powershell
.\tests\s3-validation.ps1
```

关键输出：

```text
[load] Bundle, four Skills and Tool injection are loaded
[runtime] weekly consumed Tool aggregate and produced a review
[runtime] monthly consumed Tool aggregate and produced a review
[runtime] project consumed Tool aggregate and produced a review
[remove] remove and restart passed
PASS: S3 configured-root read-only range Tool and weekly/monthly/project Runtime validation
```

脚本同时执行 `npm pack`、tarball 内容检查、官方 `dsh plugin --profile headless add`，将临时配置根目录设置到仓库外，并使用确定性 LLM fixture 发起 Tool call。fixture 在下一次模型请求中检查 Tool result，而不是直接读取插件实现，因此验证了真实 Agent Loop 的工具回合。

S1/S2 回归：

```powershell
.\tests\s1-validation.ps1
.\tests\s2-validation.ps1
```

两者均以 `PASS` 结束；S1 每日复盘、S2 周/月/项目正常材料和三类证据不足降级，以及各自的官方 remove/restart 均保持通过。

## 6. 每日/周期复盘示例结果摘要

本阶段重点验证周/月/项目，而不是把 Tool 结果冒充真实模型质量：

- 周复盘从配置范围内多个日期识别“先确认风险再动手”这一跨日期判断，同时保留一次反例，并给出下周一个前置风险检查和可观察验证；
- 月复盘把多日期材料归并为重复主题，明确没有上月对比基线，并给出下月检查点和待验证假说；
- 项目复盘区分过程日志与验收证据，明确日志只能补充过程偏差，不能单独证明项目完成；
- 三类结果都保留六问结构、质量自检和证据边界，不是把文件内容直接摘要输出。

## 7. 安装、加载、移除证据

`s3-validation.ps1` 在临时 `DSH_HOME` 中完成以下闭环：

1. `npm pack` 生成 `zhiji-dsh-plugin-0.3.0.tgz`；
2. `dsh plugin --profile headless add <tarball>` 成功；
3. Profile manifest 出现 `zhiji-dsh-plugin`；
4. `--dump-config` 出现 consolidated Bundle entry 和 `tools` 注入；
5. 三个周期/项目请求都完成原生 Tool call 和下一步复盘；
6. `dsh plugin --profile headless remove zhiji-dsh-plugin` 成功；
7. Bundle 从 manifest 移除；
8. 移除后的 Profile 重新启动并输出 `DSH profile restart passed.`。

插件包只使用 Node 内置模块，不声明 DSH 源码路径，不修改 `D:\AI\deepseek-harness`，没有 install/prepare script、native dependency、Shell、子进程或网络调用。

## 8. 未验证事项与已知限制

- 没有可用的真实 `DEEPSEEK_API_KEY`，所以没有宣称真实模型输出质量已验证；
- 没有启动真实浏览器 Web UI，验证使用 DSH 官方可测试 headless Runtime；
- 未验证 DSH `0.1.0-rc.8` 以外版本，后续版本需要重新跑兼容验证；
- 只支持 README 明确列出的顶层 Markdown 格式，不承诺兼容所有历史日志命名或目录布局；
- 没有实现报告写入、正式反馈存档、验证模式写入、自动发现目录或桌面端同步；
- 没有执行 npm publish、GitHub Release、远程 push、外部市场提交或 `dsh-plugin` topic 创建。

## 9. 是否进入 S2 与最终裁决

S2 已在本轮之前完成，并由本报告中的回归再次确认。S3 的只读范围适配解决了明确的输入摩擦，且实现和安全边界仍然是最小的，因此建议进入 S4，只做本地发布准备和仓外可复现安装文档。

最终裁决：**继续；S3 已完成，保持为只读 MVP，进入 S4。**

这不改变 S1 报告中“真实模型效果和连续用户价值尚未验证”的历史结论，也不把本地确定性 fixture 结果当作真实用户证据。
