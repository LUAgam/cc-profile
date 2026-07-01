#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

export PATH="$repo_dir/bin:$PATH"
export CC_CONFIG_DIR="$tmp_dir/config"

mkdir -p "$CC_CONFIG_DIR/profiles"
chmod 700 "$CC_CONFIG_DIR" "$CC_CONFIG_DIR/profiles"

cat > "$CC_CONFIG_DIR/profiles/runapi.env" <<'EOF'
ANTHROPIC_BASE_URL=https://example.test
ANTHROPIC_API_KEY=sk-test-secret
ANTHROPIC_MODEL=claude-test-model
EOF
chmod 600 "$CC_CONFIG_DIR/profiles/runapi.env"

ccprofile use runapi >/dev/null

[ "$(ccprofile current)" = "runapi" ]
ccprofile list | grep -q '^\* runapi$'
ccprofile show runapi | grep -q 'ANTHROPIC_API_KEY=\*\*\*\*\*\*\*\*secret'

model="$(ccrun runapi bash -lc 'printf "%s" "$ANTHROPIC_MODEL"')"
[ "$model" = "claude-test-model" ]

default_model="$(ccrun bash -lc 'printf "%s" "$ANTHROPIC_MODEL"')"
[ "$default_model" = "claude-test-model" ]

no_profile="$(ccrun --no-profile bash -lc 'printf "%s" "${ANTHROPIC_MODEL:-unset}"')"
[ "$no_profile" = "unset" ]

env_output="$(ccenv runapi)"
printf '%s\n' "$env_output" | grep -q '^export ANTHROPIC_BASE_URL='
printf '%s\n' "$env_output" | grep -q '^export ANTHROPIC_API_KEY='

echo "smoke tests passed"
