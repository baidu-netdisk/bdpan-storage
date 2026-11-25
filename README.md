<h1 align="center"><img src="./docs/baidu-netdisk-logo.png" alt="百度网盘 Logo" width="36" align="absmiddle" />&nbsp; baidu-drive</h1>

<p align="center">
  <strong>百度网盘 AI Skill —— 让 Agent 管理你的百度网盘</strong>
</p>
<p align="center">
  <a href="https://github.com/baidu-netdisk/bdpan-storage/releases"><img src="https://img.shields.io/badge/Version-v1.7.8-2563EB?style=flat-square" alt="Version v1.7.8" /></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-16A34A?style=flat-square" alt="Apache License 2.0" /></a>
  <a href="https://pan.baidu.com/apaastobui/developer#/developer/skill"><img src="https://img.shields.io/badge/Skill-baidu--drive-0284C7?style=flat-square" alt="Skill baidu-drive" /></a>
</p>
<p align="center">
  <a href="#一键安装">🚀 一键安装</a> ·
  <a href="#使用场景">💬 使用场景</a> ·
  <a href="#详细功能">🧩 详细功能</a> ·
  <a href="#常见问题">🧰 常见问题</a>
</p>
<table>
  <tr>
    <td width="25%" align="center" valign="top">
      <strong>📥 知识入库</strong><br/>
      <sub>上传文件夹，保留目录层级<br/>浏览分享，挑选要转存的文件</sub>
    </td>
    <td width="25%" align="center" valign="top">
      <strong>🔎 知识调用</strong><br/>
      <sub>查找文件，读取正文<br/>按主题把资料整理到对应目录</sub>
    </td>
    <td width="25%" align="center" valign="top">
      <strong>🔗 成果交付</strong><br/>
      <sub>生成有期限的分享链接<br/>把成果下载到指定的本地目录</sub>
    </td>
    <td width="25%" align="center" valign="top">
      <strong>🧠 Agent 底座</strong><br/>
      <sub>跨设备读取项目笔记<br/>备份 Claw 记忆（仅支持 KimiClaw、MaxClaw、QClaw、OpenClaw）</sub>
    </td>
  </tr>
  <tr>
    <td colspan="4" align="center">
      <small>适配 Claude Code · Cursor · Codex CLI · Gemini CLI · OpenClaw · DuClaw · KimiClaw · Manus 等 AI Agent</small>
    </td>
  </tr>
</table>

---

## 一键安装

```bash
npx skills add https://github.com/baidu-netdisk/bdpan-storage/skills --skill baidu-drive
```

网盘 Skill v1.7.8 需要配套 **CLI 3.9.0 或更新版本**。首次使用时，可让 Agent 检查 CLI 版本，并按提示确认安装或更新。

需要登录时，在 Agent 对话中阅读安全须知并确认，再打开授权链接，可在任意可信设备的浏览器完成授权。回到对话后直接发送需求或“继续刚才的任务”，CLI 会单次领取凭据并执行。授权链接可直接点击，登录凭据由 CLI 管理。

## 使用场景

<table>
  <tr>
    <th width="50%" align="left">🔄 跨 Agent、跨设备延续进度</th>
    <th width="50%" align="left">🧭 回溯项目关键决策与依据</th>
  </tr>
  <tr>
    <td valign="top">
      把项目交接说明存入网盘的应用目录，换设备后可在已授权的 Agent 中读取并继续处理。<br/><br/>
      💬 “读网盘的《项目交接.md》，接着写调研提纲。”
    </td>
    <td valign="top">
      复盘会上，团队想知道当初为什么会修改方案。<br/><br/>
      💬 “上次为什么选方案 B？从网盘的评审纪要里找出依据。”
    </td>
  </tr>
</table>

| 日常场景 | 对 Agent 说 |
| --- | --- |
| 🖼️ **整理图片** | 帮我把应用目录里的照片按年份整理到不同文件夹 |
| 📥 **保存周报** | 帮我把整理好的 AI 资讯周报上传到百度网盘 |
| 🔎 **查找文件** | 帮我找到网盘里的编程课程文件夹，生成一个分享链接 |
| 🗓️ **阶段留档** | 在支持的 Claw 环境中，帮我把当前 Agent 的记忆备份到网盘 |

## 详细功能

| 功能 | 说明 | 示例指令 |
| --- | --- | --- |
| **📊 容量查询** | 查询账号总容量、已用、剩余空间和使用率 | 看看网盘还剩多少空间 |
| **⬆️ 上传** | 上传文件或文件夹。默认保留同名旧文件，确认后可覆盖单个文件 | 把「课程成绩.csv」上传到 study/成绩/ |
| **⬇️ 下载** | 将网盘文件或文件夹下载到本地 | 把「会议纪要.pdf」下载到桌面 |
| **🔗 分享链接下载** | 将分享内容先转存到自己的网盘，再下载到本地 | 把这个分享里的照片下载到电脑 |
| **📥 转存** | 转存整个分享，也可浏览分享目录后选择部分内容 | 转存分享链接里的「课程表.xlsx」 |
| **🔗 分享** | 生成分享链接，支持 1 天、7 天、30 天或永久有效 | 把「旅行攻略.pdf」分享 7 天 |
| **📋 列表查询** | 查看目录中的文件和文件夹，并提供查看入口 | 看看「项目资料/」里有哪些文件 |
| **🔎 搜索文件** | 按关键词、文件类型查找文件或文件夹 | 找一下上学期的实习报告 |
| **📝 搜索正文片段** | SVIP 可按正文关键词查找文档，查看匹配片段和来源链接 | 找出提到“碳达峰”的资料 |
| **📖 读取文件正文** | 读取 txt、md、Word、PDF、PPT、Excel 等格式文件的内容 | 读「开题报告.pdf」前 3 页 |
| **📂 移动** | 将文件或文件夹移动到指定目录 | 把「合同.pdf」放进「归档/2026/」 |
| **📄 复制** | 在网盘内复制文件或文件夹 | 把「简历.pdf」复制到「求职备份/」 |
| **✏️ 重命名** | 修改文件或文件夹名称 | 把「论文初稿.pdf」改名为「论文初稿-已改.pdf」 |
| **📁 创建文件夹** | 新建文件夹，支持多级目录 | 新建「2026 春季课程/」文件夹 |
| **🗑️ 删除** | 列明对象并取得明确确认后，删除指定文件或文件夹 | 删除「临时文件.zip」 |
| **🧠 Claw 记忆备份与恢复** | 支持 KimiClaw、MaxClaw、QClaw、OpenClaw，可备份、查看和按日期恢复 | 在 OpenClaw 中恢复昨天的记忆备份 |

## 安全设计

| 特性 | 说明 |
| --- | --- |
| **🔒 作用域隔离** | 云端文件操作限制在 `/apps/bdpan/`，即「我的应用数据/bdpan」。账号容量查询仅读取空间元数据 |
| **🗑️ 删除需明确意图 + 明确确认** | 先列出待删对象、类型和数量，说明目录删除会连带其内容，等待明确确认后执行 |
| **⚠️ 按风险确认** | 路径明确的常规操作可直接执行；删除、显式覆盖上传和同名本地下载等高风险操作需明确确认 |
| **🔐 统一授权入口** | 在 Agent 对话中确认安全须知，在浏览器中完成 OAuth 2.0 授权 |
| **🛡️ 凭据保护** | 下一次请求由 CLI 领取和保存凭据。Agent 仅展示完整授权链接、操作说明和五条使用示例 |
| **✅ SHA256 校验** | Skill 更新包必须通过 SHA256 校验。CLI 安装器在具备校验值和本地工具时校验 |
| **🔄 更新需确认** | 由用户明确请求触发更新，不自动或静默升级 |

## 系统支持

| 平台 | 架构 | 状态 |
| --- | --- | :---: |
| macOS | arm64 / amd64 | ✅ |
| Linux | arm64 / amd64 | ✅ |
| Windows（WSL） | amd64 | ✅ |
| Windows（原生） | — | 暂不支持 |

## 常见问题

遇到问题时，可直接在当前 Agent 中描述情况。

| 遇到的情况 | 可以这样说 | 处理方式 |
| --- | --- | --- |
| 登录失效 | 网盘登录过期了，帮我续上 | CLI 按需刷新凭据。需要重新授权时，引导使用新链接 |
| 想确认账号状态 | 我现在登录着网盘吗？ | 查询当前认证状态 |
| 需要更新 Skill | 看看 Skill 要不要更新 | 检查版本，确认后执行更新 |
| 新功能命令不可用 | 正文搜索用不了，帮我查查 | 检查 CLI 能力，缺少命令时提示更新 |
| 授权链接已过期 | 请给我一个新的授权链接 | 通过 CLI 获取最新授权入口 |
| 正文仍在解析 | 刚才的 PDF 读好了吗？ | 查询已有任务，避免重复提交 |
| 读取额度或并发受限 | 这次读取为什么失败？ | 按实际错误说明额度或任务限制 |

更多说明见[故障排查](./skills/baidu-drive/reference/troubleshooting.md) · [认证流程](./skills/baidu-drive/reference/authentication.md) · [使用注意事项](./skills/baidu-drive/reference/notes.md) · [命令参考](./skills/baidu-drive/reference/bdpan-commands.md)

## 项目结构

```text
bdpan-storage/
├── skills/baidu-drive/            # 百度网盘 Skill
│   ├── SKILL.md                   # Skill 定义（Agent 行为规范）
│   ├── VERSION                    # 版本号
│   ├── reference/                 # 参考文档
│   │   ├── bdpan-commands.md      # 完整命令手册
│   │   ├── authentication.md      # 认证流程说明
│   │   ├── examples.md            # 使用示例
│   │   ├── notes.md               # 使用注意事项
│   │   └── troubleshooting.md     # 故障排查
│   └── scripts/                   # 管理脚本
│       ├── install.sh             # 安装 CLI
│       ├── login.sh               # 登录授权
│       ├── update.sh              # 更新 Skill
│       ├── memory-backup.sh       # Agent 记忆备份与恢复
│       └── uninstall.sh           # 卸载
├── skills/baidu-wenku-aippt-personal/ # 百度文库 AI PPT Skill
├── .github/workflows/             # 检查与发布流程
├── docs/                          # Logo、贡献指南及社区资源
├── README.md                      # 项目说明
├── CHANGELOG.md                   # 更新记录
├── LICENSE                        # 开源许可证
└── Makefile                       # 打包工具
```

文库 Skill v1.1.1 的安装与使用见[文库 Skill README](./skills/baidu-wenku-aippt-personal/README.md)。

## 打包与发布

```bash
make help                           # 查看可用命令
make pack SKILL=baidu-drive         # 打包指定 Skill
make pack-all                       # 打包所有 Skills
```

发布流程由 GitHub Actions 管理：当 `main` 分支中的 `skills/*/VERSION` 发生变化时自动触发，也可以在 Actions 页面手动运行发布工作流。Skill 版本标签由工作流按 `<skill>/<version>` 格式生成。

## 参与贡献

欢迎参与共建！具体流程见 [贡献指南](./docs/contributing.md)。

1. Fork 本仓库，基于 `main` 创建功能分支。
2. 完成修改，检查示例、链接及相关功能。
3. 提交 PR，说明改动内容和验证方式（使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式）。

## 加入社区

<p align="center">
  <img src="./docs/join-us.png" alt="扫码加入百度网盘 Skill 社区" width="240" />
</p>
<p align="center">
  <strong>扫码添加，备注「github」即可入群</strong><br/>
</p>

- 与核心开发团队直接交流
- 提交 Bug 反馈和功能建议
- 参与 Skill 共建计划

## 许可证

本项目采用 [Apache License 2.0](./LICENSE)。
