#!/bin/bash

set -eu

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

login_script="$test_root/login.sh"
sed 's/\r$//' "$repo_root/skills/baidu-drive/scripts/login.sh" > "$login_script"

mkdir -p "$test_root/bin"
cp "$repo_root/tests/fakes/bdpan" "$test_root/bin/bdpan"
chmod +x "$test_root/bin/bdpan"

export TEST_STATE="$test_root/logged-in"
export TEST_LOG="$test_root/calls.log"

auth_code="0123456789abcdef0123456789abcdef"
if ! output="$(
    printf 'y%s\n' "$auth_code" |
        PATH="$test_root/bin:$PATH" bash "$login_script" 2>&1
)"; then
    printf '%s\n' "$output"
    echo "FAIL: login script exited unsuccessfully" >&2
    exit 1
fi

printf '%s\n' "$output" | grep -Fq "https://openapi.baidu.com/oauth/test"
grep -Fxq "get:login --get-auth-url --accept-disclaimer" "$TEST_LOG"
grep -Fxq "set:login --set-code-stdin --accept-disclaimer" "$TEST_LOG"
test -f "$TEST_STATE"

if printf '%s\n' "$output" | grep -Fq "$auth_code" ||
    grep -Fq "$auth_code" "$TEST_LOG"; then
    echo "FAIL: authorization code was exposed in output or command arguments" >&2
    exit 1
fi

rm -f "$TEST_STATE"
: > "$TEST_LOG"
invalid_code="${auth_code}x"
if invalid_output="$(
    printf 'y%s\n' "$invalid_code" |
        PATH="$test_root/bin:$PATH" bash "$login_script" 2>&1
)"; then
    echo "FAIL: malformed authorization code was accepted" >&2
    exit 1
fi
if printf '%s\n' "$invalid_output" | grep -Fq "$invalid_code" ||
    grep -Fq "$invalid_code" "$TEST_LOG"; then
    echo "FAIL: malformed authorization code was exposed in output or command arguments" >&2
    exit 1
fi

echo "PASS: login commands accept the disclaimer and authorization codes stay secret"
