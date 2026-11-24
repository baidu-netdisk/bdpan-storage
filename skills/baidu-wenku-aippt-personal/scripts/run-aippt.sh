#!/bin/bash
# AI PPT 生成入口脚本
# 用法: bash run-aippt.sh "<query>" "<title>" "<page>" "<style>" "<scene>" "<color>"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

BDPAN="bdpan"

# 授权交给实际业务命令处理；仅透传当前调用的 Skill 信息与明确确认。
SKILL_VERSION=$(tr -d '[:space:]' < "$SKILL_DIR/VERSION") || exit 1
if [ -z "$SKILL_VERSION" ]; then
    printf '%s\n' 'Skill VERSION 为空，请检查安装包。' >&2
    exit 1
fi
auth_args=(--auth-flow cli --skill-name baidu-wenku-aippt-personal --skill-version "$SKILL_VERSION")
if [ "${1:-}" = --auth-confirmed ]; then
    auth_args+=(--auth-confirmed)
    shift
fi

# 1. 检测渠道
channel=$(bash "$SCRIPT_DIR/detect-agent.sh")

# 2. 调用 bdpan aippt
"$BDPAN" aippt --channel="$channel" "${auth_args[@]}" "$@"
ret=$?
[ "$ret" -eq 0 ] || exit "$ret"

# 3. 检查更新
bash "$SCRIPT_DIR/check-update.sh"

exit $ret
