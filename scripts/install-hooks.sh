#!/bin/bash
# 安装 Cursor Hooks 到用户目录 ~/.cursor/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_HOOKS="$SCRIPT_DIR/../cursor-hooks"
CURSOR_DIR="$HOME/.cursor"
HOOKS_DIR="$CURSOR_DIR/hooks"

echo "→ 安装 Vibe Coding Monitor Hooks"
mkdir -p "$HOOKS_DIR"
cp "$REPO_HOOKS/vibe-status.sh" "$HOOKS_DIR/vibe-status.sh"
chmod +x "$HOOKS_DIR/vibe-status.sh"

if [[ -f "$CURSOR_DIR/hooks.json" ]]; then
  echo "⚠️  已存在 ~/.cursor/hooks.json"
  echo "   请手动合并 cursor-hooks/hooks.json 中的 hooks 配置"
  echo "   或备份后执行: cp $REPO_HOOKS/hooks.json ~/.cursor/hooks.json"
else
  cp "$REPO_HOOKS/hooks.json" "$CURSOR_DIR/hooks.json"
  echo "✓ 已写入 ~/.cursor/hooks.json"
fi

mkdir -p "$HOME/Library/Application Support/VibeCodingMonitor"
TS="$(date +%s)"
printf '{"status":"idle","event":"install","message":"Hooks 已安装","timestamp":%s}\n' "$TS" \
  > "$HOME/Library/Application Support/VibeCodingMonitor/status.json"

echo ""
echo "✓ 安装完成！请重启 Cursor 使 Hooks 生效。"
echo "  状态文件: ~/Library/Application Support/VibeCodingMonitor/status.json"
