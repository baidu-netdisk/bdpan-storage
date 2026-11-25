# 故障排除指南

本指南涵盖了使用百度文库 AI PPT 生成功能时的常见问题和解决方案。

---

## 认证问题

PPT 业务直接使用 `run-aippt.sh`，不额外预登录；用户主动登录才调用登录脚本。`whoami` 只查询状态，不领取待授权 key。

授权状态按[认证指南](./authentication.md)处理：需要确认时在普通对话中等待用户同意或取消，返回入口后展示完整链接与说明并结束本轮。支持跨设备；网页授权后直接发下一条业务需求。

网络、服务、格式或保存错误按真实原因停止，不当作未登录，不自动 logout、删除配置或反复申请链接。链接过期由下一次请求按 CLI 状态处理，使用最新入口。

### 提示 Skill 需要升级

CLI 明确提示需要升级 Skill 时，百度文库 `baidu-wenku-aippt-personal` 至少需要 **v1.1.1**。向用户说明原因并取得确认后，执行 `bash ${CLAUDE_SKILL_DIR}/scripts/update.sh`。更新后检查该 Skill 的 `VERSION` 满足最低版本且实际包包含统一授权流程，重新加载技能或开启新会话，再重试登录；若仍低于要求，说明更新未满足要求并停止重试。

网络错误或普通 Token 刷新失败不触发技能升级，按 CLI 原始错误排查。

---

## AI PPT 生成问题

### PPT 生成超时

**症状：** 执行 `bdpan aippt` 后长时间无响应或超时。

**解决方案：**
1. 检查网络连接是否正常
2. 重试生成命令（服务端可能暂时繁忙）
3. 如果持续超时，稍后再试

### 生成结果为空或报错

**症状：** 命令执行后没有返回 PPT 文件路径或显示错误信息。

**解决方案：**
1. 确认登录状态：`bdpan whoami --json --no-check-update`
2. 检查输入描述是否足够详细（建议超过 10 个字）
3. 避免输入包含特殊字符（引号需要正确转义）
4. 如果访问 Token 过期，先由 CLI 尝试刷新；明确提示需要授权时再登录

### 参数值无效

**症状：** 提示参数值不在允许范围内。

**解决方案：**
确认参数取值在以下枚举范围内：
- **page**: 1-10、11-20、21-30、31-40、40+
- **style**: 默认、创意趣味、年终总结、卡通手绘、扁平简约、文艺清新、中国风、企业商务、未来科技、文化艺术
- **scene**: 默认、晚会表彰、传统节日、婚姻爱情、生日祝福、医学科普、建筑报告、工作总结、年终总结、工作汇报
- **color**: 默认、绿色、蓝色、紫色、橙色、黄色、红色、黑色、白色

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
bdpan aippt "主题描述" "标题" "11-20" "默认" "默认" "默认"

# 错误（Windows 路径风格）
# 不适用于 bdpan aippt
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
bdpan aippt --help
```

### 启用调试模式

```bash
# 检查配置文件是否存在及权限
ls -la ~/.config/bdpan/

# 检查登录状态和 Token 有效期
bdpan whoami
```

> **⛔ 安全警告：** 切勿使用 `cat` 查看配置文件内容，配置文件中包含 `access_token`、`refresh_token` 等敏感凭据，打印到终端或对话中可能导致泄露。
