# 故障排除指南

本指南涵盖了使用 bdpan CLI 时的常见问题和解决方案。

---

## 认证问题

普通业务直接调用 CLI；记忆包装脚本不额外预登录。正文搜索先用登录脚本准备凭据，再用 `whoami` 查会员。`whoami` 只查询状态，不领取待授权 key。

授权状态按[认证指南](./authentication.md)处理：需要确认时在普通对话中等待用户同意或取消，返回入口后展示完整链接与说明并结束本轮。支持跨设备；网页授权后直接发下一条业务需求。

网络、服务、格式或保存错误按真实原因停止，不当作未登录，不自动 logout、删除配置或反复申请链接。链接过期由下一次请求按 CLI 状态处理，使用最新入口。

### 提示 Skill 需要升级

CLI 明确提示需要升级 Skill 时，百度网盘 `baidu-drive` 至少需要 **v1.7.8**。向用户说明原因并取得确认后，执行 `bash ${CLAUDE_SKILL_DIR}/scripts/update.sh`。更新后检查该 Skill 的 `VERSION` 满足最低版本且实际包包含统一授权流程，重新加载技能或开启新会话，再重试登录；若仍低于要求，说明更新未满足要求并停止重试。

网络错误或普通 Token 刷新失败不触发技能升级，按 CLI 原始错误排查。

---

## 文件操作问题

### 路径不在允许范围

**症状：**
```
错误: 路径不在允许范围内
Error: Path not in allowed range
```

**解决方案：**
确保所有路径都在 `/apps/bdpan/` 目录下。

错误：
```bash
bdpan ls /my-documents
bdpan upload ./file.txt /other/file.txt
```

正确：
```bash
bdpan ls my-documents
bdpan upload ./file.txt my-documents/file.txt
```

### 使用中文路径导致下载/上传失败

**症状：**
```
错误: 文件不存在
# 实际原因：使用了 "/我的应用数据/bdpan/..." 而不是 "/apps/bdpan/..."
```

**说明：**
百度网盘界面中显示的 **"我的应用数据"** 是中文显示名，对应的 API 实际路径是 **`/apps`**。两个方向都需要映射：
- **调用命令时**：中文路径 → API 路径（`我的应用数据` → `/apps`）
- **展示给用户时**：API 路径 → 中文路径（`/apps` → `我的应用数据`）

**路径映射：**
| 用户可见名称 | API 实际路径 |
|-------------|-------------|
| 我的应用数据 | `/apps` |
| 我的应用数据/bdpan | `/apps/bdpan` |

**解决方案：**
调用命令时使用相对路径或英文 API 绝对路径，展示给用户时转换为中文名：

```bash
# ✅ 命令中使用 API 路径
bdpan download report.pdf ./report.pdf

# ✅ 展示给用户时使用中文名
# "文件已上传到：我的应用数据/bdpan/report.pdf"

# ❌ 命令中使用中文路径
bdpan download /我的应用数据/bdpan/report.pdf ./report.pdf

# ❌ 展示给用户时暴露 API 路径
# "文件已上传到：/apps/bdpan/report.pdf"
```

### 文件不存在

**症状：**
```
错误: 文件不存在
Error: File not found
```

**解决方案：**
1. 检查本地文件是否存在：
   ```bash
   ls -la <本地路径>
   ```
2. 检查远程文件是否存在：
   ```bash
   bdpan ls
   ```

### 上传/下载超时

**症状：** 操作耗时过长并超时，或大文件下载中途中断。

**原因：** Agent 的 Bash 工具有执行超时限制（默认 2 分钟，最大 10 分钟），大文件下载耗时超过此限制会导致进程被终止。

**解决方案：**
1. Agent 应遵循 SKILL.md 中的**大文件下载策略**：≤ 50MB 直接下载，> 50MB 使用 `nohup` 后台下载 + 轮询进度
2. 如果后台下载仍然失败，建议用户在终端直接执行：
   ```bash
   bdpan download <远端路径> <本地路径>
   ```
3. 检查网络连接稳定性
4. 对于非常大的文件，考虑先压缩/分割：
   ```bash
   # 上传前压缩
   tar -czf archive.tar.gz large-folder/
   bdpan upload archive.tar.gz backup/archive.tar.gz
   ```

### 转存失败

**症状：**
```
错误: 转存失败
Error: Transfer failed
```

**常见原因及解决方案：**

1. **分享链接已失效**：联系分享者重新生成链接
2. **提取码错误**：确认提取码是否正确
   ```bash
   # 提取码通过 -p 传入
   bdpan transfer "<百度网盘分享链接>" -p abcd
   # 或包含在链接中
   bdpan transfer "<百度网盘分享链接>?pwd=abcd"
   ```

#### 分享链接提取码错误码

| CLI 场景 | 用户提示 | 处理方式 |
|---|---|---|
| `errno=13003`，URL 无 `pwd` 且未传 `-p` | 该分享链接需要提取码，请补充提取码后重试。 | 向用户询问提取码后重试 |
| `errno=13003`，已传 `-p` 或 URL 含 `pwd` | 提取码错误，请检查提取码后重试。 | 检查提取码后重试 |
| `errno=13004` | 分享链接已失效、已取消或不存在。 | 更换有效分享链接，不建议重试 |

无码公开链接不应在执行前被 Skill 拦截。URL 没有 `pwd` 且用户未提供提取码时，直接执行 `bdpan transfer` 或分享链接 `bdpan download`；如果服务端返回 `errno=13003`，再提示用户补充提取码。
3. **网盘空间不足**：清理网盘空间后重试

#### 网盘空间不足（-10）

**症状：** CLI 返回 `errno=-10`，提示「网盘可用空间不足，文件没有保存」。

**处理方式：** 先提示用户清理网盘空间，并把 CLI 返回消息里的两条收银台链接原样给用户，用于扩容（开通/续费会员）：

- 移动端主收银台：`https://pan.baidu.com/wap/vip/user?from=bdpan`
- 电脑端主收银台：`https://pan.baidu.com/buy/checkoutcounter?from=bdpan`

端类型无法判定，两条都要给，由用户按设备选择；也可直接调用 `bdpan vip --json` 取这两条链接。**不得只给一条，不得自行拼接其它支付地址，不得凭记忆报价格或容量套餐。**

#### 分享转存数量超限（13072 / 13073）

**症状：**

```text
errno=13072, hit transfer file count limit
errno=13073, hit transfer file count limit
```

**原因：** 接收分享的账号触发单次实际转存数量限制。目录会递归计算内部文件和子目录，因此只选择 1 个顶层目录也可能超限。`page_size=100` 只是目录查询的单页大小，与转存权益不是同一限制。

权益说明：普通用户 500、VIP 3000、SVIP 50000。

**处理方式：**

1. 询问用户是否改为选择性转存；
2. 使用 `bdpan transfer list "<分享链接>" --json` 浏览目录；
3. 让用户选择更小的目录或更少文件；
4. 用户确认清单和目标目录后，使用 `bdpan transfer select` 提交；
5. 不自动拆分或反复重试。若符合账号权益仍失败，保留错误 ID 反馈官方排查。

#### 异步转存仍在处理中或无法查询

转存接口可能先返回任务 ID，随后由任务队列异步执行。普通 `transfer`、分享链接 `download` 和 `transfer select` 返回 `status=submitted` 时，只能说明任务已提交，不能说明文件已经转存或下载完成。

处理规则：

1. 保留并展示 `task_id`、转存位置；分享链接下载还要展示本地目标路径。
2. 不要回复“转存成功/下载成功”，不要根据目标目录中的旧文件推断本次任务已完成，也不要生成完成文件的查看链接。
3. `errno=13070` 在短暂重试后仍未找到任务时，提示任务状态暂时无法查询，稍后再查，不要重复提交。
4. `errno=13071` 表示已有其他转存任务正在进行，等待约 5 分钟后再试。
5. 任务查询出现 `-6`、`13998`、`13080` 或 `13081` 时，说明当前账号暂时没有任务查询权限/权益；这不等于转存失败，应告知用户任务已提交并建议稍后在百度网盘确认。

#### 错误码 errno=13045（自己的分享链接）

**症状：**
```
转存失败: errno=13045, msg=prohibit transfer self share link
```

**原因：**
这是您自己创建并分享的链接，文件已经在您的网盘中，无需再次转存。

**处理方式：**
- **不向用户展示错误**，直接告知文件已在网盘中
- 使用 `bdpan ls` 查找并展示该文件
- 如需要，可提供分享链接供他人使用

示例回复：
```
✅ 文件已在您的网盘中！

文件信息：
- 文件名：example.pdf
- 位置：我的应用数据/bdpan/example.pdf
- 大小：1.2 MB

无需转存，直接使用即可。
```

### 权限不足

**症状：**
```
错误: 权限不足
Error: Permission denied
```

**解决方案：**
1. 检查本地文件权限：
   ```bash
   ls -l <本地路径>
   ```
2. 确保您对目标目录有写入权限：
   ```bash
   ls -ld <目标目录>
   ```

---

## 安装问题

### 命令未找到

**症状：** `bdpan: command not found`

**解决方案：**
```bash
# 重新运行安装脚本
bash ${CLAUDE_SKILL_DIR}/scripts/install.sh

# 或者检查 ~/.local/bin 是否在 PATH 中
echo $PATH

# 如果缺失则添加到 PATH（添加到 ~/.zshrc 或 ~/.bashrc）
export PATH="$HOME/.local/bin:$PATH"
```

### 下载了错误的架构

**症状：** 二进制文件无法运行或提示 "exec format error"

**解决方案：**
```bash
# 删除现有二进制文件
rm ~/.local/bin/bdpan

# 重新安装
bash ${CLAUDE_SKILL_DIR}/scripts/install.sh
```

---

## JSON 输出问题

### 无效的 JSON 输出

**症状：** `--json` 输出无法被解析。

**解决方案：**
1. 确保 stdout 中没有错误消息
2. 检查输出中只有 JSON 内容
3. 使用 `jq` 验证：
   ```bash
   bdpan ls --json | jq .
   ```

---

## 平台特定问题

### macOS

#### Gatekeeper 阻止

**症状：** 无法打开应用，因为它来自身份不明的开发者。

**解决方案：**
```bash
xattr -d com.apple.quarantine ~/.local/bin/bdpan
```

### Linux

#### 缺少依赖

**症状：** 二进制文件运行失败，提示缺少库。

**解决方案：**
安装所需依赖（特定于发行版）：
```bash
# Debian/Ubuntu
sudo apt-get install libc6

# Fedora/RHEL
sudo dnf install glibc
```

### Windows (WSL)

#### 路径问题

**症状：** Windows 路径无法正常工作。

**解决方案：**
在 WSL 中始终使用 Unix 风格路径：
```bash
# 正确
bdpan upload ./file.txt file.txt

# 错误
bdpan upload .\\file.txt file.txt
```

---

## 获取帮助

### 检查版本

```bash
bdpan version
```

### 获取命令帮助

```bash
bdpan --help
bdpan upload --help
bdpan download --help
```

### 启用调试模式

```bash
# 检查配置文件是否存在及权限
ls -la ~/.config/bdpan/

# 检查登录状态和 Token 有效期
bdpan whoami
```

> **⛔ 安全警告：** 切勿使用 `cat` 查看配置文件内容，配置文件中包含 `access_token`、`refresh_token` 等敏感凭据，打印到终端或对话中可能导致泄露。
