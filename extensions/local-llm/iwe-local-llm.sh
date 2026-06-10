#!/usr/bin/env bash
# see ADR-001-local-llm-stack.md (РП404)
# Обёртка локального LLM-стека (MLX). JOB: приватность + fallback.
# Сервер биндится только на localhost (B7.3).
# Команды: start | test | stop | status | pull <model> | use <model>
set -euo pipefail

LLM_HOME="${IWE_LLM_HOME:-$HOME/.iwe-local-llm}"
PY="$LLM_HOME/.venv/bin/python"
CONFIG="$LLM_HOME/active-model"          # одна строка: id активной модели
DEFAULT_MODEL="mlx-community/Qwen2.5-7B-Instruct-4bit"
HOST="127.0.0.1"
PORT="${IWE_LLM_PORT:-8080}"
PIDFILE="$LLM_HOME/server.pid"
LOGFILE="$LLM_HOME/server.log"

die() { echo "error: $*" >&2; exit 1; }
[ -x "$PY" ] || die "venv не найден ($PY). Сначала установщик: install-local-llm.sh"

# Активная модель: env > config-файл > дефолт
active_model() {
  if [ -n "${IWE_LLM_MODEL:-}" ]; then echo "$IWE_LLM_MODEL"
  elif [ -f "$CONFIG" ]; then cat "$CONFIG"
  else echo "$DEFAULT_MODEL"; fi
}

start() {
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "уже запущен (pid $(cat "$PIDFILE"))"; return 0
  fi
  local model; model=$(active_model)
  "$PY" -m mlx_lm server --model "$model" --host "$HOST" --port "$PORT" > "$LOGFILE" 2>&1 &
  echo $! > "$PIDFILE"
  for _ in $(seq 1 30); do
    if curl -s -o /dev/null -w '%{http_code}' "http://$HOST:$PORT/v1/models" 2>/dev/null | grep -q 200; then
      echo "запущен на http://$HOST:$PORT (модель $model, pid $(cat "$PIDFILE"))"; return 0
    fi
    sleep 1
  done
  kill "$(cat "$PIDFILE")" 2>/dev/null || true   # не оставлять осиротевший mlx_lm и мёртвый PID
  rm -f "$PIDFILE"
  die "сервер не поднялся за 30с, см. $LOGFILE"
}

test_shim() {
  local out
  out=$(curl -s "http://$HOST:$PORT/v1/chat/completions" \
    -H 'Content-Type: application/json' \
    -d '{"messages":[{"role":"user","content":"Reply with exactly: SHIM_OK"}],"max_tokens":10,"temperature":0.0}')
  echo "$out" | "$PY" -c "
import sys, json
raw = sys.stdin.read()
try:
    print('shim:', json.loads(raw)['choices'][0]['message']['content'].strip())
except (ValueError, KeyError, IndexError):
    print('shim: невалидный ответ сервера:', raw[:300])   # видно причину, не голый трейс
"
}

stop() {
  [ -f "$PIDFILE" ] || { echo "не запущен"; return 0; }
  if kill "$(cat "$PIDFILE")" 2>/dev/null; then echo "остановлен"; else echo "процесс уже мёртв"; fi
  rm -f "$PIDFILE"
}

status() {
  local model; model=$(active_model)
  echo "активная модель: $model"
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "сервер: запущен (pid $(cat "$PIDFILE"), http://$HOST:$PORT)"
  else
    echo "сервер: остановлен"
  fi
}

# Скачать модель в кэш заранее (не делая активной)
pull() {
  local model="${1:?usage: pull <model-id>}"
  echo "скачиваю $model ..."
  "$PY" -m mlx_lm generate --model "$model" --max-tokens 1 --prompt "ok" >/dev/null
  echo "готово: $model в кэше"
}

# Поставить модель в работу: скачать (если нет) + записать активной + перезапустить сервер
use() {
  local model="${1:?usage: use <model-id>}"
  pull "$model"
  echo "$model" > "$CONFIG"
  echo "активная модель → $model"
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    stop; start
  fi
}

case "${1:-}" in
  start)  start ;;
  test)   test_shim ;;
  stop)   stop ;;
  status) status ;;
  pull)   pull "${2:-}" ;;
  use)    use "${2:-}" ;;
  *) die "usage: $0 start|test|stop|status|pull <model>|use <model>" ;;
esac
