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
grep -Fq "get:login --get-auth-url --accept-disclaimer" "$TEST_LOG"
grep -Fq "set:login --set-code-stdin --accept-disclaimer" "$TEST_LOG"
test -f "$TEST_STATE"

echo "PASS: both login subcommands accept the disclaimer without exposing the authorization code"
