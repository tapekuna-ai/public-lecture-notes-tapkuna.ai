#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PYTHON=${PYTHON:-python3}

if [ ! -x "$ROOT/.venv/bin/python" ]; then
  "$PYTHON" -m venv "$ROOT/.venv"
fi

if [ "${SKIP_INSTALL:-0}" != "1" ]; then
  "$ROOT/.venv/bin/python" -m pip install --upgrade pip
  "$ROOT/.venv/bin/python" -m pip install -r "$ROOT/requirements.txt"
fi

"$ROOT/.venv/bin/python" "$ROOT/scripts/build_site.py"

if [ "${SERVE:-0}" = "1" ]; then
  PORT=${PORT:-8000}
  echo "Serving http://localhost:$PORT/lab/ (Ctrl+C to stop)"
  "$ROOT/.venv/bin/python" -m jupyter lite serve --config "$ROOT/jupyter_lite_config.json" --output-dir "$ROOT/dist" --port "$PORT"
fi
