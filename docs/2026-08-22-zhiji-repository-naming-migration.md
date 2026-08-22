---
type: decision-record
status: current
created: 2026-08-22
last_updated: 2026-08-22
keywords:
  - zhiji
  - zhiji-Desktop-Agent
  - repository rename
  - GitHub rename
  - zhiji compatibility
---

# zhiji 仓库最终命名迁移与兼容性记录

本文记录 2026-08-22 晚间先采用 ReflectLoop、随后放弃该前缀并统一到 zhiji 的 GitHub 仓库改名、相关文档与 metadata 调整，以及“本地仍有知己/zhiji 是否会损坏”的判断。它是后续遇到克隆、推送、链接、构建、数据目录或旧名称问题时的原因查询入口。

## 快速结论

仓库改名真正需要保持的是**引用关系正确**，不是让所有地方使用同一个字符串。

- GitHub 仓库名、Git remote、当前 README 链接和包的仓库 metadata 应指向同一公开地址。
- 本地目录名不需要与 GitHub 仓库名一致；Git 根据 `.git` 和 remote 工作，不根据外层文件夹名称工作。
- “知己”是继续沿用的中文产品名；当前 GitHub 仓库统一使用小写 `zhiji` 前缀。
- `zhiji` 出现在数据目录、环境变量、备份格式、代码标识和本地快照路径时，可能承担兼容性职责；没有迁移方案时不应全局替换。
- 历史 CHANGELOG、归档文档和旧提交应保留当时事实，不追改成今天的名称。
- 此前采用的 ReflectLoop 命名决策已被取代。当前四仓库的最终命名体系是 `zhiji`、`zhiji-Desktop-Agent`、`zhiji-Agent-Skill` 和 `zhiji-DSH-Plugin`。本地目录与 DSH 内部包 ID 保持兼容，不因 GitHub 仓库改名而全局替换。

## 截至 2026-08-22 的当前事实

| 仓库角色 | 当前 GitHub 仓库 | 当前本地位置 | 当前判断 |
| --- | --- | --- | --- |
| 项目、Skill/CLI 与共享契约主仓库 | [`an-X550/zhiji`](https://github.com/an-X550/zhiji) | 仓库根目录 | 已完成平台改名、remote 和公开入口同步 |
| Windows 客户端 | [`an-X550/zhiji-Desktop-Agent`](https://github.com/an-X550/zhiji-Desktop-Agent) | `apps/zhiji-desktop/` 是主仓库快照；独立仓库另有工作目录 | 已完成平台改名、README、包名和仓库 metadata 同步 |
| Codex/Claude 用户分发包 | [`an-X550/zhiji-Agent-Skill`](https://github.com/an-X550/zhiji-Agent-Skill) | `zhiji-user/`，且自身是独立 Git 仓库 | 已完成仓库改名、remote 和公开链接同步 |
| DeepSeek Harness 插件 | [`an-X550/zhiji-DSH-Plugin`](https://github.com/an-X550/zhiji-DSH-Plugin) | `apps/zhiji-dsh-plugin/` 是主仓库快照 | 已完成仓库改名、remote、README 和 package repository metadata 同步 |

zhiji 是当前英文仓库前缀，“知己”是中文产品名。ReflectLoop 只在下方历史时间线和旧决策说明中保留；当前 GitHub 页面、remote、README 和 package metadata 均使用表中地址，本地 `zhiji-*` 路径和 DSH 包 ID 继续作为兼容性标识。

## 最终命名迁移结果

本轮最终放弃 ReflectLoop 前缀，并将四个仓库统一为以下精确名称；版本号保持不变：

| 仓库 | 最终 GitHub URL |
| --- | --- |
| 主仓库 | <https://github.com/an-X550/zhiji> |
| Desktop Agent | <https://github.com/an-X550/zhiji-Desktop-Agent> |
| Agent Skill | <https://github.com/an-X550/zhiji-Agent-Skill> |
| DSH Plugin | <https://github.com/an-X550/zhiji-DSH-Plugin> |

产品名 `知己`、桌面端 `productName`、数据目录、`ZHIJI_*` 环境变量、`.zhiji.zip` 备份格式、Bundle ID、用户数据结构和本地快照目录均不因仓库改名而改变。历史 CHANGELOG、旧决策和本文件的历史时间线保留当时采用 ReflectLoop 的事实。

## 晚间更新顺序

### 主仓库

| 时间 | 提交 | 作用 |
| --- | --- | --- |
| 20:54 | `545bb76` | 以 Agent 为核心重写入口，并将源码版本从 2.6.4 调整为 2.6.5 |
| 20:58 | `9f45161` | 采用 ReflectLoop 英文品牌，保留“知己”中文名，重构根 README 与桌面快照 README |
| 22:10 | `d167a65` | 平台改名后同步主仓库和当时桌面仓库的 URL、remote 说明及 package metadata |
| 22:35 | `accfed2` | 将桌面仓库定位进一步明确为 Desktop Agent；该提交曾误把部分当前版本写成 2.6.6 |
| 22:42 | `efd740f` | 以前向纠正提交恢复当前版本 2.6.5，并统一到 `Reflectloop-Desktop-Agent` 地址 |
| 22:50 | `8eba0f2` | 依据第一性原理重构 Desktop Agent README，版本保持 2.6.5 |
| 22:56 | `c2a551d` | 进一步明确四个公开入口和独立仓库边界 |

`accfed2` 已经进入公开历史，因此不删除、不改写历史。当前真相由后续 `efd740f` 和当前文件共同确定：版本是 **2.6.5**。这属于可审计的前向纠正，不会损坏 Git 历史。

### Desktop Agent 独立仓库

| 时间 | 提交 | 作用 |
| --- | --- | --- |
| 21:55 | `dd1a6d2` | 采用 ReflectLoop 品牌并重写 README |
| 22:10 | `95a3584` | 同步平台改名后的仓库 metadata |
| 22:41 | `d03f4df` | 明确 Desktop Agent 定位，统一仓库 URL、包名、关键词和安装说明，版本保持 2.6.5 |
| 22:50 | `5281ce1` | 依据第一性原理重构独立仓库 README，版本保持 2.6.5 |

### Agent Skill 与 DSH 独立仓库

用户在 GitHub 完成以下平台改名后，本轮同步了本地 remote、当前 README、跨仓库公开链接和适用的 package repository metadata：

- `knowing-yourself-zhiji-user` → `Reflectloop-Agent-Skill`
- `zhiji-dsh-plugin` → `Reflectloop-DSH-Plugin`

DSH 的 npm 包名、Bundle ID、Skill 运行入口和 remove 命令仍保持 `zhiji-dsh-plugin`，因为它们是安装与运行时兼容标识，不是 GitHub 仓库名。

## 为什么不能全局替换“知己/zhiji”

从第一性原理看，命名的作用是让某一层的对象可被稳定识别。不同层解决的问题不同：

| 层级 | 例子 | 主要作用 | 改名原则 |
| --- | --- | --- | --- |
| 公开仓库与品牌 | `zhiji`、`zhiji-Agent-Skill`、`zhiji-Desktop-Agent`、`zhiji-DSH-Plugin` | 搜索、识别、分享和定位 | 名称确定后同步 GitHub、remote 和当前链接 |
| 本地源码目录 | `zhiji-user/`、`apps/zhiji-desktop/`、`apps/zhiji-dsh-plugin/` | 代码引用、脚本和主仓库快照定位 | 不要求与远程同名；只有真实维护收益大于迁移成本时才改 |
| 包 metadata | `zhiji-desktop-agent`、`repository`、`bugs`、`homepage` | 构建和生态工具识别 | 与 lock 文件及公开仓库地址一起修改和验证 |
| 用户可见产品名 | `productName: "知己"` | Windows 应用名称和中文品牌连续性 | 继续保留“知己” |
| 持久化与接口标识 | `%APPDATA%\知己`、`Documents/知己`、`ZHIJI_DATA_ROOT`、`.zhiji.zip` | 找到旧数据、配置、测试入口和备份 | 视为兼容性接口；如要改名，必须设计兼容读取和数据迁移 |
| 历史记录 | CHANGELOG、归档文档、旧提交 | 解释当时发生了什么 | 不追改历史事实 |

当前受 Git 跟踪的文件中，`apps/zhiji-desktop`、`apps/zhiji-dsh-plugin`、`zhiji-user/` 分别被 48、6、58 个文件引用。仅为“看起来统一”而改目录，会扩大脚本、文档、测试和同步流程的变更面，却不改善用户查找 GitHub 仓库的体验。

## 哪些改动会产生真实影响

| 现象 | 优先检查 | 原因 |
| --- | --- | --- |
| `git push` 找不到仓库或没有权限 | `git remote get-url origin` | 本地文件夹名称不影响推送，remote 地址才影响 |
| README、Release 或 Issues 链接 404 | 当前 README 和 `package.json` 中的 URL | 平台改名后，硬编码旧地址可能失效或依赖 GitHub 重定向 |
| 应用升级后像“数据消失” | `productName`、Electron `userData`、`Documents/知己`、`zhiji-config.json` | 改变数据定位标识会让新版应用转向新目录；原数据通常仍在旧目录，并非文件被仓库改名删除 |
| 旧备份不能导入 | `.zhiji.zip`、manifest 和业务 schema | 备份后缀与格式是兼容性协议，不是公开品牌文案 |
| E2E 或插件读取失败 | `ZHIJI_DATA_ROOT`、`ZHIJI_E2E_EXECUTABLE`、`ZHIJI_E2E_API_KEY`、`ZHIJI_DSH_LOG_ROOT` | 环境变量是调用接口；单边改名会让既有脚本失效 |
| 构建或同步脚本报路径不存在 | 三个本地快照目录及其脚本引用 | 只改一部分目录引用会造成路径断裂 |
| npm 安装或打包出现包身份不一致 | `package.json` 与 `package-lock.json` | 包名或版本修改时必须同步 lock 文件 |

因此，仓库改名本身不会损坏本地文件。风险来自某个真正被程序、Git、脚本或数据迁移使用的引用只改了一半。

## 后续修改规则

1. 先确定四个仓库各自的用户、入口和发布职责，再确定最终仓库名；不要逐个凭感觉改名。
2. 对每个 `知己/zhiji` 命中先分类到上表的某一层，无法分类时先不改。
3. 平台仓库改名后，同一轮同步 remote、当前 README 的 clone/Release/Issues 链接、GitHub About，以及适用的 package metadata。
4. 本地源码目录默认保留。若以后确有维护收益，再单独迁移并一次性更新脚本、文档、测试和同步流程。
5. 数据目录、环境变量、备份格式或应用身份如需改名，必须作为兼容性迁移处理，而不是文案替换；至少保留旧值读取、迁移验证和用户可见说明。
6. CHANGELOG 和归档只记录真实历史，不把旧名称批量改成新名称。
7. 版本号只为产品版本变化服务。仓库命名或文档纠错不自动产生新版本；本轮当前版本保持 2.6.5。

## 快速排查命令

在主仓库根目录运行：

```powershell
git status --short --branch
git remote get-url origin
git ls-remote origin refs/heads/main
git -C zhiji-user remote get-url origin
git grep -n "github.com/an-X550/"
git grep -n -E "apps/zhiji-desktop|apps/zhiji-dsh-plugin|zhiji-user/"
git grep -n -E "ZHIJI_|Documents/知己|APPDATA.*知己|\.zhiji\.zip"
```

预期主仓库 remote 为 `https://github.com/an-X550/zhiji.git`；用户版独立仓库 remote 为 `https://github.com/an-X550/zhiji-Agent-Skill.git`。Desktop Agent 和 DSH 插件必须在各自独立仓库根目录核对 remote，不能把主仓库快照目录当成独立 Git 根目录；DSH 的 package name、Bundle ID 和 remove 命令仍为 `zhiji-dsh-plugin`。

如果问题只涉及旧名称是否“残留”，先看命中属于当前链接、内部路径、兼容标识还是历史记录；只有当前链接错误或真实接口迁移不完整时才需要修改。

## 关联入口

- 当前仓库地址与推送边界：[`standalone-repositories.md`](standalone-repositories.md)
- 当前产品事实和关键决策：[`../PROJECT_STATUS.md`](../PROJECT_STATUS.md)
- 发布级变化历史：[`../CHANGELOG.md`](../CHANGELOG.md)
- 主仓库入口：[`../README.md`](../README.md)
- 用户版同步流程：[`zhiji-user-sync-workflow.md`](zhiji-user-sync-workflow.md)
