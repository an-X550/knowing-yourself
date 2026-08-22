# 仓库地址与推送边界

为方便检索和推送，ReflectLoop（知己）相关仓库统一记录如下。四个仓库是独立 Git 仓库；主仓库继续保存知己 Skill、共享契约、运行定义和迁移时的目录快照。

> 2026-08-22 的改名经过、版本纠正、`知己/zhiji` 兼容性边界和故障排查，统一见[《ReflectLoop 仓库命名迁移与兼容性记录》](2026-08-22-reflectloop-repository-naming-migration.md)。

| 组件 | 本地目录 | GitHub 仓库 | 默认分支 | 推送方式 |
| --- | --- | --- | --- | --- |
| ReflectLoop（知己）主仓库 | `./` | <https://github.com/an-X550/Reflectloop> | `main` | `git push origin main` |
| 知己用户版分发包 | `zhiji-user/` | <https://github.com/an-X550/knowing-yourself-zhiji-user> | `main` | `git -C zhiji-user push origin main` |
| ReflectLoop Desktop Agent（知己 Windows 客户端） | `apps/zhiji-desktop/`（主仓库快照） | <https://github.com/an-X550/Reflectloop-Desktop-Agent> | `main` | 在独立仓库工作目录执行 `git push origin main` |
| 知己 DSH 插件 | `apps/zhiji-dsh-plugin/`（主仓库快照） | <https://github.com/an-X550/zhiji-dsh-plugin> | `main` | 在独立仓库工作目录执行 `git push origin main` |

## 提交与推送约定

- 主仓库根目录和 `zhiji-user/` 内层仓库各自有自己的 Git `origin`；用户版同步脚本负责从主仓库生成或刷新用户版内容，之后仍需在 `zhiji-user/` 内单独提交和推送。
- 桌面端的独立仓库根目录包含 Electron 应用的 `package.json`；插件的独立仓库根目录包含 DSH Bundle 的 `package.json`。
- 两个组件的 `package.json` 中的 `repository`、`bugs` 和 `homepage` 字段与上表保持一致；它们是包 metadata，不会改变主仓库的 Git `origin`。
- 主仓库的 `origin` 指向 `Reflectloop`。不要为了推送独立组件而修改主仓库 remote；在对应独立仓库中提交并推送到各自的 `main`。
- 现有 `apps/zhiji-desktop/` 和 `apps/zhiji-dsh-plugin/` 目录保留用于历史、参考和主仓库兼容；后续独立版本默认以对应新仓库为开发与发布真相，不要求两边自动同步。
- ReflectLoop 是英文项目名，“知己”是中文产品名。主仓库使用 `reflectloop`，桌面独立仓库使用 `Reflectloop-Desktop-Agent`；表中的 GitHub URL、Git remote 和桌面包 metadata 保持一致。

## 快速核对 remote

```powershell
git remote get-url origin
git -C zhiji-user remote get-url origin
```

前一条应返回 `https://github.com/an-X550/Reflectloop.git`，后一条应返回 `https://github.com/an-X550/knowing-yourself-zhiji-user.git`。桌面端独立仓库应返回 `https://github.com/an-X550/Reflectloop-Desktop-Agent.git`。桌面端和 DSH 插件应在各自独立仓库的工作目录中核对和推送，不要把主仓库里的快照目录当作独立 Git 根目录。
