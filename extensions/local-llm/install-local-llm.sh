#!/usr/bin/env bash
# see ADR-001-local-llm-stack.md (РП404, Ф3)
# Hardware-aware установщик локального LLM-стека (MLX) для шаблона IWE.
# Раздаёт ПРОЦЕСС выбора, а не фиксированную модель (см. "Костюм != Оснащение").
# По умолчанию ставит рекомендованную модель, влезающую в память; --max — самую тяжёлую.
# Идемпотентен: повторный запуск не ломает уже установленное.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATALOG="${IWE_LLM_CATALOG:-$HERE/model-catalog.yaml}"
DETECT="$HERE/detect-hardware.sh"
LLM_HOME="${IWE_LLM_HOME:-$HOME/.iwe-local-llm}"
VENV="$LLM_HOME/.venv"
PY="$VENV/bin/python"
CONFIG="$LLM_HOME/active-model"
PYVER="${IWE_LLM_PYVER:-3.12}"

# По умолчанию ставится рекомендованная модель (recommended: true), влезающая в память.
# --max берёт самого тяжёлого влезающего кандидата (выше качество, медленнее).
pick_mode="recommended"
[ "${1:-}" = "--max" ] && pick_mode="max"

die() { echo "error: $*" >&2; exit 1; }
log() { echo "[install-local-llm] $*"; }

[ "$(uname -s)" = "Darwin" ] || die "стек рассчитан на macOS (Apple Silicon, MLX)"
[ -f "$CATALOG" ] || die "каталог моделей не найден: $CATALOG"
[ -x "$DETECT" ] || die "детект-скрипт не найден: $DETECT"

mkdir -p "$LLM_HOME"

# 1. Железо
ram_gb=$("$DETECT" | awk -F= '/^ram_gb=/{print $2}')
[ -n "$ram_gb" ] || die "не удалось определить объём памяти"
log "память: ${ram_gb} GB"

# 2. venv (idempotent)
if [ ! -x "$PY" ]; then
  if command -v uv >/dev/null 2>&1; then
    log "создаю окружение через uv (python $PYVER)"
    uv venv --python "$PYVER" "$VENV"
  else
    log "uv не найден, создаю окружение через python$PYVER -m venv"
    command -v "python$PYVER" >/dev/null 2>&1 || die "нет python$PYVER — поставь uv или python$PYVER"
    "python$PYVER" -m venv "$VENV"
  fi
else
  log "окружение уже есть, пропускаю"
fi

# 3. mlx-lm (idempotent)
if ! "$PY" -c "import mlx_lm" 2>/dev/null; then
  log "ставлю mlx-lm"
  if command -v uv >/dev/null 2>&1; then uv pip install --python "$PY" mlx-lm
  else "$PY" -m pip install mlx-lm; fi
else
  log "mlx-lm уже установлен"
fi

# 4. Выбор модели под железо (venv python с pyyaml — после установки mlx-lm)
model=$("$PY" - "$CATALOG" "$ram_gb" "$pick_mode" <<'PY'
import sys, yaml
catalog, ram, mode = sys.argv[1], int(sys.argv[2]), sys.argv[3]
with open(catalog, encoding="utf-8") as f:
    data = yaml.safe_load(f)
fit = [c for c in data.get("candidates", []) if c.get("min_ram_gb", 1e9) <= ram]
if not fit:
    sys.exit("нет модели, влезающей в память")
if mode == "max":
    chosen = max(fit, key=lambda c: c.get("params_b", 0))         # тяжёлый из влезающих
else:
    recommended = [c for c in fit if c.get("recommended")]
    chosen = recommended[0] if recommended else max(fit, key=lambda c: c.get("params_b", 0))
print(chosen["id"])
PY
)
[ -n "$model" ] || die "не удалось выбрать модель"
log "режим выбора: $pick_mode → модель под ${ram_gb} GB: $model"

# 5. Скачать модель в кэш
log "скачиваю модель (первый раз — несколько ГБ)"
"$PY" -m mlx_lm generate --model "$model" --max-tokens 1 --prompt "ok" >/dev/null

# 6. Записать активную модель
echo "$model" > "$CONFIG"
log "активная модель записана → $CONFIG"

# 7. Smoke: совместимый интерфейс на localhost
log "проверка: запуск сервера + shim"
IWE_LLM_HOME="$LLM_HOME" bash "$HERE/iwe-local-llm.sh" start
shim=$(IWE_LLM_HOME="$LLM_HOME" bash "$HERE/iwe-local-llm.sh" test || true)
IWE_LLM_HOME="$LLM_HOME" bash "$HERE/iwe-local-llm.sh" stop
echo "$shim" | grep -q "SHIM_OK" || die "smoke провалился: shim не ответил SHIM_OK ($shim)"
log "готово. Стек установлен, модель $model, сервер на 127.0.0.1 работает."
echo ""
echo "Дальше: bash iwe-local-llm.sh start | status | use <model> | stop"
