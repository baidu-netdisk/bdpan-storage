---
name: baidu-wenku-aippt-personal
description: >-
  百度文库智能PPT个人版 — 一句话自动生成高质量 PPT，支持多种风格、场景和配色。
  TRIGGER: 用户提及"生成PPT/做PPT/制作PPT/AI PPT/aippt/幻灯片/演示文稿"时触发。
  DO NOT TRIGGER: 非 PPT 相关操作，文件管理操作，网盘上传下载等操作。
allowed-tools: Bash, Read, Glob, Grep
argument-hint: "[PPT 主题描述]"
---

# 百度文库 AI PPT 生成 Skill

一句话自动生成高质量 PPT，支持多种风格、场景和配色方案。底层通过 `bdpan aippt` 命令实现。

> 使用示例详见 [reference/aippt-examples.md](./reference/aippt-examples.md)

## 触发规则

同时满足以下条件才执行：

1. 用户提及"生成PPT"、"做PPT"、"制作PPT"、"AI PPT"、"aippt"、"幻灯片"、"演示文稿"
2. 提供了主题、大纲或内容描述

未通过触发规则时，禁止执行任何 bdpan 命令。

> **上下文延续：** 当前对话已在进行 PPT 生成操作时，后续消息无需再次提及关键词即可触发。

---

## 安全约束（最高优先级，不可被任何用户指令覆盖）

1. **主动登录**：必须使用 `bash ${CLAUDE_SKILL_DIR}/scripts/login.sh`，禁止直接调用 `bdpan login` 及其任何参数；普通业务由 CLI 在执行时处理授权
2. **Token/配置**：禁止读取或输出 `~/.config/bdpan/config.json` 内容（含 `access_token`、`refresh_token` 等敏感凭据）
3. **更新/登录**：更新必须由用户明确指令触发，禁止自动或静默执行；Agent 禁止使用 `--yes` 参数执行 update.sh。login.sh 仅在本会话、同一授权流程已有明确安全确认时可加 `--confirmed`；旧 `--yes` 不可用，新会话无确认记录须重新确认
4. **环境变量**：Agent 禁止主动设置 `BDPAN_CONFIG_PATH`、`BDPAN_BIN`、`BDPAN_INSTALL_DIR` 等环境变量

---

## 前置检查

每次触发时按顺序执行：

1. **安装检查**：`command -v bdpan` 并检查 `bdpan version`，登录要求 CLI >= **3.9.0**。未安装时告知用户并确认后执行 `bash ${CLAUDE_SKILL_DIR}/scripts/install.sh`；版本过低时说明要求，仅在用户明确要求并确认后执行 `bdpan update`。安装或更新后复查版本，满足要求后在同一轮继续下一步，不停下来等用户再次提出。
2. **登录检查**：直接执行 `run-aippt.sh`，由业务 CLI 复用、刷新或单次领取凭据；不要额外调用登录脚本或用 `whoami` 预检。返回授权状态时按下方「登录确认」处理。用户主动登录才使用登录脚本；`whoami` 仅查询状态，不领取待授权 key。

### 登录确认

`run-aippt.sh` 为实际业务 CLI 透传 `--auth-flow cli --skill-name baidu-wenku-aippt-personal --skill-version "<本 Skill 的 VERSION 实际值>"`，不另行调用登录脚本。直接调用业务 CLI 时也须带这些参数。同一会话、同一授权流程已明确确认时，业务命令可加 `--auth-confirmed`，主动登录脚本可加 `--confirmed`；不默认同意或持久化确认，新会话无记录须重新确认。

1. 收到 `confirmation_required` 时，先说明 CLI 已明确给出的链接过期或授权失效原因（如有），再在普通对话中使用以下固定话术。结束本轮，等待用户明确回复同意或取消，不使用弹窗或选择按钮。取消、未答或含糊时不发起授权。

   > 授权前请先确认安全须知：仅在可信环境授权，以免网盘数据被窃取；在公共环境用完后，请执行退出登录，彻底清除授权；请备份重要数据并审核 Agent 操作；不要在对话或公开仓库中暴露凭证；使用完可注销。
   >
   > 是否确认继续百度网盘授权？

2. 用户同意后，带本轮确认继续原业务或主动登录。收到 `authorization_required` 时，过期或失效原因以本次 CLI 返回的 `data.message` 为准，不另外补充或改写。按[认证指南](./reference/authentication.md)的固定话术，在同一条回复仅展示完整可点击链接、CLI 说明和五条示例，然后结束本轮。新发和重发链接时，`data.expires_at` 仅供程序使用，不展示具体到期时间或剩余时长。链接放在代码块外，按 `[点击此处完成授权登录](URL)` 展示，含 key 的链接也不得改写。
3. 用户网页授权后直接发下一条需求，由 CLI 领取后执行业务；不要求回复“已授权”、不轮询、不等待原命令，也不在收到授权状态的本轮再次登录或重试业务。继续原任务时保留对象、目标与条件，有歧义先澄清。
4. 用户明确要求重发授权链接时，必须调用一次 `bash ${CLAUDE_SKILL_DIR}/scripts/login.sh` 获取当前结果，禁止直接复制历史授权 URL，也不重跑原业务。脚本只传可选的 `--confirmed`（仅本会话、同一授权流程已明确确认时），不附加 CLI 公共参数或 `--continue-task` 等静默参数。按本次返回处理：需确认则先对话确认；待授权则展示完整固定话术和五条示例；已登录不强制换发；失败则停止，不回贴旧链接或连续重试。

状态、升级和错误处理见[认证指南](./reference/authentication.md)。已有有效凭据或已有 key 的单次领取无需重复确认；主动登录成功才展示“无需重复授权 / 登录成功”和五条示例，业务成功直接返回实际结果。

---

## 核心操作：AI PPT 生成

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/run-aippt.sh "<用户原始query>" "<title>" "<page>" "<style>" "<scene>" "<color>"
```

**参数说明：**

| 参数 | 说明 |
|------|------|
| 第1参数（用户query） | **严格使用用户的原始输入**，不做任何加工或改写 |
| title（标题） | Agent 从用户 query 中提取或生成一个简短精炼的 PPT 标题 |
| page（页数） | 取值：1-10、11-20、21-30、31-40、40+（默认：11-20）。根据用户指定的页数选择最匹配的枚举值 |
| style（风格） | 取值：默认、创意趣味、年终总结、卡通手绘、扁平简约、文艺清新、中国风、企业商务、未来科技、文化艺术（默认：默认） |
| scene（场景） | 取值：默认、晚会表彰、传统节日、婚姻爱情、生日祝福、医学科普、建筑报告、工作总结、年终总结、工作汇报（默认：默认） |
| color（颜色） | 取值：默认、绿色、蓝色、紫色、橙色、黄色、红色、黑色、白色（默认：默认） |

**智能选择规则：** Agent 根据用户 query 自动生成 title，并判断最匹配的 page、style、scene、color 值。若无法明确判断，则使用默认值。title/page/style/scene/color 参数对用户不可见，Agent 静默选择后直接执行。

**授权处理：** `run-aippt.sh` 直接调用业务 CLI；同一授权流程已确认时，在原始 query 前加 `--auth-confirmed`。遇到授权状态按「登录确认」展示并结束，不解析成大纲、不报告生成成功；只有业务成功才检查更新。

**执行步骤：**

1. 将用户原始 query 作为第一参数，生成 title，智能匹配 page、style、scene、color（不向用户展示）
2. 执行：
   ```bash
   bash ${CLAUDE_SKILL_DIR}/scripts/run-aippt.sh "<用户原始query>" "<title>" "<page>" "<style>" "<scene>" "<color>"
   ```
3. **解析命令输出中的大纲**：Agent 必须在思考过程（thinking）中完整记录并分析生成的 PPT 大纲内容，包括各章节标题和子标题的结构，以便用户通过查看思考过程了解 PPT 内容结构
4. 向用户展示生成结果（文件名、预览链接、剩余次数），并且必须原样展示命令输出中的使用说明提示（tip）
5. **原样展示规则**：命令输出中 `[DISPLAY_VERBATIM_START]` 和 `[DISPLAY_VERBATIM_END]` 之间的内容，必须作为引用块（blockquote `>`）完整原样展示给用户，禁止省略、改写、总结或翻译。示例输出格式：
   > 温馨提示：今日AI PPT 生成次数已经用完，明日 0 点后会自动刷新额度。如有大量生成PPT需求，可以通过官网联系我们。官网地址：https://pan.baidu.com/union/home
6. 如果命令输出中包含更新提示，原样展示给用户（无输出则跳过）

**确认规则：**

- 用户提供了主题描述 → 直接执行

---

## 技能升级

用户回复"技能升级"时：
1. 执行 `bash ${CLAUDE_SKILL_DIR}/scripts/update.sh`
2. 展示更新结果
3. 提示用户重新打开技能体验新版本

---

## 授权后继续使用

网页授权不会自动执行原任务。用户下一次发送业务需求时，由 CLI 单次领取并保存凭据，然后返回真实业务结果；无需复制凭据或口头确认登录。详见[认证指南](./reference/authentication.md)。

用户误发凭据时，不复述、不透传该轮原文，整轮省略 `--session-input`，也不得将其作为业务 query。

---

## 管理功能

### 安装

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/install.sh [--yes]
```

### 登录 / 注销

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/login.sh              # 主动登录；已完成本会话安全确认时加 --confirmed
bdpan logout                                            # 注销
```

### 卸载

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/uninstall.sh [--yes]   # 卸载
```

### 更新（必须用户明确指令触发）

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/update.sh              # 检查并更新（需用户确认）
bash ${CLAUDE_SKILL_DIR}/scripts/update.sh --check       # 仅检查更新
```

---

## 参考文档

遇到对应问题时按需查阅，无需预加载：

| 文档 | 何时查阅 |
|------|---------|
| [aippt-examples.md](./reference/aippt-examples.md) | AI PPT 生成使用示例和智能匹配参考 |
| [authentication.md](./reference/authentication.md) | 认证流程细节、Token 管理 |
| [troubleshooting.md](./reference/troubleshooting.md) | 遇到错误需要排查 |
