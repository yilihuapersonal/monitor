#!/bin/bash
# Cursor Hook: 将 Agent 状态写入 VibeCodingMonitor 共享文件
# 用法: vibe-status.sh <mode>

set -euo pipefail

MODE="${1:-thinking}"
INPUT=""
if [[ ! -t 0 ]]; then
  if IFS= read -r -t 0.1 first 2>/dev/null; then
    INPUT="$first"
    while IFS= read -r -t 0.05 line; do
      INPUT+=$'\n'"$line"
    done
  fi
fi

STATUS_DIR="$HOME/Library/Application Support/VibeCodingMonitor"
STATUS_FILE="$STATUS_DIR/status.json"
mkdir -p "$STATUS_DIR"

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

write_status() {
  local status="$1"
  local event="$2"
  local message="$3"
  local ts
  ts="$(date +%s)"

  cat >"$STATUS_FILE" <<EOF
{"status":"$(json_escape "$status")","event":"$(json_escape "$event")","message":"$(json_escape "$message")","timestamp":$ts}
EOF
}

tool_name() {
  if [[ -z "$INPUT" ]]; then
    echo ""
    return
  fi
  sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <<<"$INPUT" | head -1
}

exit_code() {
  if [[ -z "$INPUT" ]]; then
    echo "0"
    return
  fi
  local code
  code="$(sed -n 's/.*"exit_code"[[:space:]]*:[[:space:]]*\([0-9-]*\).*/\1/p' <<<"$INPUT" | head -1)"
  echo "${code:-0}"
}

is_user_action_tool() {
  case "$1" in
    AskQuestion|SwitchMode) return 0 ;;
    *) return 1 ;;
  esac
}

is_code_tool() {
  case "$1" in
    Write|StrReplace|EditNotebook|Delete|Task|Shell) return 0 ;;
    *) return 1 ;;
  esac
}

case "$MODE" in
  idle|thinking|executing|processing|error|waiting)
    write_status "$MODE" "manual" ""
    ;;
  sessionStart|afterAgentThought|preCompact|postToolUse|subagentStop|subagentStart|beforeReadFile|afterFileEdit)
    write_status "thinking" "$MODE" ""
    ;;
  afterAgentResponse|stop|sessionEnd)
    write_status "idle" "$MODE" ""
    ;;
  postToolUseFailure)
    write_status "error" "$MODE" "工具执行失败"
    ;;
  preToolUse)
    TOOL="$(tool_name)"
    if is_user_action_tool "$TOOL"; then
      write_status "waiting" "$MODE" "等待用户选择"
    elif is_code_tool "$TOOL"; then
      write_status "executing" "$MODE" "$TOOL"
    else
      write_status "thinking" "$MODE" "$TOOL"
    fi
    ;;
  beforeShellExecution)
    write_status "processing" "$MODE" "命令执行中"
    ;;
  beforeMCPExecution)
    write_status "waiting" "$MODE" "等待 MCP 许可"
    ;;
  afterShellExecution)
    CODE="$(exit_code)"
    if [[ "$CODE" != "0" ]]; then
      write_status "error" "$MODE" "命令退出码 $CODE"
    else
      write_status "thinking" "$MODE" ""
    fi
    ;;
  afterMCPExecution)
    write_status "thinking" "$MODE" ""
    ;;
  *)
    write_status "thinking" "$MODE" ""
    ;;
esac

exit 0
