#!/bin/bash
# bdpan OOB 登录脚本
# 用于非 GUI 环境下的手动授权登录

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 解析参数
SKIP_CONFIRM="no"
while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y)
            SKIP_CONFIRM="yes"
            shift
            ;;
        --help|-h)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --yes, -y    跳过安全确认（自动化场景）"
            echo "  --help       显示帮助信息"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 bdpan 是否已安装
if ! command -v bdpan &> /dev/null; then
    log_error "bdpan 未安装，请先运行: bash scripts/install.sh"
    exit 1
fi

# 检查当前登录状态
log_info "检查登录状态..."

# 获取 bdpan 版本
BDPAN_VERSION=$(bdpan version 2>/dev/null | head -1 || echo "unknown")

if bdpan whoami 2>/dev/null | grep -q "已登录"; then
    log_warn "已经登录，无需重复登录"
    bdpan whoami
    exit 0
fi

log_info "未登录，开始 OOB 授权流程..."

# 安全免责声明
echo ""
echo -e "${RED}┌──────────────────────────────────────────────────────────────┐${NC}"
echo -e "${RED}│              ⚠️  baidu drive 安全须知 & 免责声明                │${NC}"
echo -e "${RED}├──────────────────────────────────────────────────────────────┤${NC}"
echo -e "${RED}│${NC} 1. 请备份网盘重要数据，谨慎操作。                            ${RED}│${NC}"
echo -e "${RED}│${NC}    请务必【备份】网盘重要数据。                               ${RED}│${NC}"
echo -e "${RED}│${NC} 2. [行为负责] AI Agent 行为具有不可预测性，请实时             ${RED}│${NC}"
echo -e "${RED}│${NC}    【人工审核】指令执行过程，对执行后果负责。                  ${RED}│${NC}"
echo -e "${RED}│${NC} 3. [安全提醒] 严禁在他人、公用或不可信的环境中                ${RED}│${NC}"
echo -e "${RED}│${NC}    扫码授权，以免网盘数据被窃取！                              ${RED}│${NC}"
echo -e "${RED}│${NC}    在公共环境使用完毕后，请务必执行                             ${RED}│${NC}"
echo -e "${RED}│${NC}    【bdpan logout】 彻底清除授权。                             ${RED}│${NC}"
echo -e "${RED}│${NC} 4. [严禁泄露] 请严格保护配置文件与 Token，                    ${RED}│${NC}"
echo -e "${RED}│${NC}    切勿在公开仓库或对话中暴露！                                ${RED}│${NC}"
echo -e "${RED}├──────────────────────────────────────────────────────────────┤${NC}"
echo -e "${RED}│${NC} 使用本工具即代表您已阅读并认可上述条款。数据安全，人人有责。  ${RED}│${NC}"
echo -e "${RED}└──────────────────────────────────────────────────────────────┘${NC}"
echo ""

# 用户确认
if [ "$SKIP_CONFIRM" = "yes" ]; then
    log_info "自动模式，跳过安全确认"
else
    echo -n -e "${YELLOW}已阅读上述安全须知，确认继续登录? [y/N] ${NC}"
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "已取消登录"
        exit 0
    fi
fi

# 获取授权链接
log_info "正在获取授权链接..."

# 检查是否支持 --get-auth-url 参数
if bdpan login --help 2>/dev/null | grep -q "get-auth-url"; then
    # 新版本，支持 --get-auth-url
    AUTH_URL=$(bdpan login --get-auth-url --accept-disclaimer 2>/dev/null || echo "")

    if [ -z "$AUTH_URL" ]; then
        log_error "获取授权链接失败"
        exit 1
    fi
else
    # 旧版本，尝试执行 login 捕获输出
    log_warn "当前版本可能不支持 --get-auth-url，尝试兼容模式..."
    log_error "当前 bdpan 版本: ${BDPAN_VERSION}"
    log_error "请升级到支持 --get-auth-url 的 bdpan 版本（>= 3.0.0）"
    log_error "升级方式: bash scripts/install.sh --force"
    exit 1
fi

# 显示授权链接
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}请在浏览器中打开以下链接完成授权:${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
# 纯文本单独一行输出，不附带任何 ANSI/OSC 转义序列。
# 无论是真实终端、日志采集，还是 AI Agent（如小艺 claw 等）抓取 stdout 文本
# 再转发展示给用户，都能拿到一个完整、干净、可直接复制/点击的 URL。
# 注意：此前版本使用 OSC 8 超链接转义序列（\e]8;;URL\e\\显示文本\e]8;;\e\\）
# 在同一行内嵌入了两次 URL，在非真实终端环境（如部分 Agent 的输出解析逻辑）
# 下容易被截断或错误拼接，导致用户拿到的链接不可用。
echo "${AUTH_URL}"
echo ""
# 提供给 AI Agent 的 Markdown 格式，便于 Agent 直接抓取并放到代码块外
echo -e "${YELLOW}Agent请提取以下Markdown格式回复给用户(需放在代码块外):${NC}"
echo "[👉 点击此处打开授权页面](${AUTH_URL})"
echo ""
# 仅在真实交互式终端下，额外附加 OSC 8 可点击版本作为增强体验
# （支持 iTerm2、VS Code Terminal、Wezterm、GNOME Terminal、Windows Terminal 等）。
# 当 stdout 被管道/重定向或被 Agent 捕获时 [ -t 1 ] 为 false，不会输出该转义
# 序列，从而避免被非终端场景的文本解析逻辑误处理。
if [ -t 1 ]; then
    echo -e "\033]8;;${AUTH_URL}\033\\${YELLOW}👆 点击此处直接打开授权页面（如终端支持）${NC}\033]8;;\033\\"
    echo ""
fi
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}提示:${NC}"
echo -e "${YELLOW}1. 可直接复制上方链接到浏览器打开（支持的终端也可直接点击）${NC}"
echo -e "${YELLOW}2. 链接有效期为 10 分钟${NC}"
echo -e "${YELLOW}3. 授权成功后，浏览器会显示一个 32 位授权码${NC}"
echo -e "${YELLOW}4. 请复制授权码并粘贴到下方${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 提示用户输入授权码
echo -n "请输入浏览器中显示的授权码 (32 位十六进制字符): "
read -r AUTH_CODE

if [ -z "$AUTH_CODE" ]; then
    log_error "授权码不能为空"
    exit 1
fi

# 校验授权码格式：32 位十六进制字符
if ! echo "$AUTH_CODE" | grep -qE '^[a-fA-F0-9]{32}$'; then
    log_error "授权码格式不正确（应为 32 位十六进制字符，如: ca0ee3070f75d0246357e5c74d525bda）"
    log_error "当前输入: ${AUTH_CODE}"
    log_error "请确认您复制的是完整的授权码"
    exit 1
fi

# 使用授权码完成登录
log_info "正在使用授权码完成登录..."

# 通过 stdin 安全传递授权码，避免在 ps / /proc/PID/cmdline 中泄露
if bdpan login --help 2>/dev/null | grep -q "set-code-stdin"; then
    echo "$AUTH_CODE" | bdpan login --set-code-stdin --accept-disclaimer
else
    unset AUTH_CODE
    log_error "当前 bdpan 版本不支持 --set-code-stdin（安全授权码传递）"
    log_error "当前 bdpan 版本: ${BDPAN_VERSION}"
    log_error "请升级到 >= 3.6.2: bash scripts/install.sh --force"
    exit 1
fi

# 立即清除内存中的授权码
unset AUTH_CODE

# 验证登录
if bdpan whoami &> /dev/null; then
    log_info "✓ 登录成功！"
    bdpan whoami
else
    log_error "登录失败，请检查授权码是否正确"
    exit 1
fi
