<h1 align="center">baidu-drive</h1>

<p align="center">
  <b>百度网盘 AI Skill — 让 Agent 一句话操作你的网盘</b>
</p>

<p align="center">
  <a href="https://github.com/BaiduNetdiskAIBot/bdpan-storage/releases"><img src="https://img.shields.io/badge/version-v1.2.0-blue" alt="Version"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-green" alt="License"></a>
  <a href="https://pan.baidu.com/apaastobui/developer#/developer/skill"><img src="https://img.shields.io/badge/skill-baidu--netdisk-orange" alt="Skill"></a>
</p>

<p align="center">
  上传 / 下载 / 转存 / 分享 / 搜索 / 移动 / 复制 / 重命名 / 创建文件夹<br/>
  适配 Claude Code · OpenClaw · DuClaw · KimiClaw · Manus 等 AI Agent
</p>

<p align="center">
  <em>Baidu Netdisk AI Skill — Manage cloud files with natural language.</em><br/>
  <em>Compatible with Claude Code · Cursor · Codex CLI · Gemini CLI · OpenClaw · DuClaw · KimiClaw · Manus</em>
</p>

---

## 一键安装

```bash
npx skills add https://github.com/baidu-netdisk/bdpan-storage/skills --skill baidu-drive
```

首次使用时，Skill 会自动引导完成 CLI 工具安装和百度网盘登录授权。

## 用自然语言操作网盘

安装完成后，在你的 AI Agent 中直接说：

```
帮我上传 ./report.pdf 到百度网盘
```

```
从网盘下载 backup/ 文件夹到本地
```

```
转存这个链接：<百度网盘分享链接>?pwd=abcd
```

```
搜索网盘里所有 PDF 文件
```

```
把网盘里的 report.pdf 分享给同事
```

Skill 自动识别意图、执行操作、返回格式化结果。

## 功能

| 功能 | 说明 | 示例指令 |
|------|------|---------|
| **上传** | 上传文件或文件夹到网盘 | "上传 ./data.csv 到网盘" |
| **下载** | 从网盘下载到本地 | "下载网盘里的 report.pdf" |
| **分享链接下载** | 通过分享链接 + 提取码下载 | "下载这个网盘分享 https://pan.baidu.com/s/1xxx 提取码 abcd" |
| **转存** | 将分享内容转存到自己的网盘 | "转存这个链接到网盘" |
| **分享** | 生成分享链接（1天、7天、30天、永久） | "把 report.pdf 分享给别人" |
| **列表查询** | 查看网盘文件列表 | "看看网盘里有什么文件" |
| **搜索** | 按关键词/类型搜索 | "在网盘搜一下所有图片" |
| **移动** | 移动文件到指定目录 | "把 report.pdf 移动到 backup 目录" |
| **复制** | 复制文件到指定目录 | "复制 config.yaml 到 backup" |
| **重命名** | 重命名文件或文件夹 | "把 old.pdf 重命名为 new.pdf" |
| **创建文件夹** | 在网盘中新建文件夹 | "在网盘里新建一个 projects 文件夹" |

## 使用示例

### 上传并分享

```
帮我上传 ./report.pdf 到网盘并分享
```

```
上传并分享成功!
链接: https://pan.baidu.com/s/xxxxxxx
提取码: abcd
有效期: 7 天
```

### 查看文件列表

```
查看我网盘里的文件
```

```
类型    大小          修改时间              文件名
------  ------------  --------------------  --------
目录     -            2026-02-20 10:30:00  backup
文件    1.5 MB        2026-02-25 15:20:00  report.pdf
文件    256 KB        2026-02-24 09:15:00  config.yaml

共 3 项
```

### 转存分享链接

```
帮我转存这个链接到网盘 <百度网盘分享链接>?pwd=abcd
```

```
转存成功!
文件: 项目资料.zip (128 MB)
目标目录: 我的应用数据/bdpan/
```

## 安全设计

| 特性 | 说明 |
|------|------|
| **作用域隔离** | 所有操作限制在 `/apps/bdpan/` 目录，无法访问用户其他文件 |
| **删除需明确意图 + 明确确认** | 仅当用户明确要求删除时才调用 `rm`，且必须先列出待删对象、等待用户明确确认；删除范围同样限制在 `/apps/bdpan/` 内 |
| **修改前确认** | 移动、重命名、覆盖等操作执行前必须用户确认 |
| **OAuth 2.0** | 授权码模式认证，不存储用户密码 |
| **Token 保护** | 配置文件含 Token，Agent 禁止读取或输出其内容 |
| **安全传码** | 授权码通过 stdin 传递，不暴露在进程列表中 |
| **SHA256 校验** | 安装和更新的二进制文件强制完整性校验 |
| **更新需确认** | 禁止自动或静默更新，必须用户明确指令并确认 |

> 本工具处于公测期（BETA），建议备份重要数据，并人工审核每条 AI 执行的命令。

## 系统支持

| 平台 | 架构 | 状态 |
|------|------|:----:|
| macOS | arm64 / amd64 | &#x2705; |
| Linux | arm64 / amd64 | &#x2705; |
| Windows (WSL) | amd64 | &#x2705; |
| Windows (原生) | — | &#x274C; |

## 故障排除

遇到问题时，直接对 Skill 说：

- **Token 过期** — "百度网盘 token 过期了" → 自动引导重新登录
- **检查状态** — "检查网盘登录状态" → 显示当前认证信息
- **更新** — "更新一下 bdpan" → 检查并更新 Skill 和 CLI

更多故障排查指南参见 [troubleshooting.md](./skills/baidu-netdisk/reference/troubleshooting.md)。

## 项目结构

```
bdpan-storage/
├── skills/baidu-netdisk/           # Skill 主目录
│   ├── SKILL.md                    # Skill 定义（Agent 行为规范）
│   ├── VERSION                     # 版本号
│   ├── reference/                  # 参考文档
│   │   ├── bdpan-commands.md       # 完整命令手册
│   │   ├── authentication.md       # 认证流程说明
│   │   ├── examples.md             # 使用示例
│   │   └── troubleshooting.md      # 故障排查
│   └── scripts/                    # 管理脚本
│       ├── install.sh              # 安装
│       ├── login.sh                # 登录
│       ├── update.sh               # 更新
│       └── uninstall.sh            # 卸载
├── .github/workflows/              # CI/CD
├── docs/                           # 文档资源
└── Makefile                        # 打包工具
```

## 打包与发布

```bash
make help                           # 查看可用命令
make pack SKILL=baidu-netdisk       # 打包指定 Skill
make pack-all                       # 打包所有 Skills
```

推送 tag 自动触发 GitHub Release：

```bash
git tag v1.2.0
git push origin v1.2.0
```

## 参与贡献

欢迎参与共建！详见 [贡献指南](./docs/contributing.md)。

1. Fork 本仓库
2. 基于 `main` 创建功能分支
3. 提交 PR（使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式）

## 加入社区

<p align="center">
  <img src="./docs/join-us.png" alt="加入社区" width="260" />
</p>

<p align="center"><b>扫码添加，备注「github」即可入群</b></p>

- 与核心开发团队直接交流
- 提交 Bug 反馈和功能建议
- 参与 Skill 共建计划

## 许可证

[Apache License 2.0](./LICENSE)
