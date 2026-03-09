#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR"

required_vars=(
  ZOTERO_ID
  ZOTERO_KEY
  SENDER
  SENDER_PASSWORD
  RECEIVER
  OPENAI_API_KEY
  OPENAI_API_BASE
)

missing=()
for name in "${required_vars[@]}"; do
  value="${(P)name-}"
  if [[ -z "$value" ]] && [[ -f .env ]]; then
    value="$(python3 - <<'PY2' "$name"
from pathlib import Path
import sys

target = sys.argv[1]
for line in Path('.env').read_text().splitlines():
    line = line.strip()
    if not line or line.startswith('#') or '=' not in line:
        continue
    key, value = line.split('=', 1)
    if key == target:
        print(value.strip())
        break
PY2
)"
  fi
  if [[ -z "$value" ]]; then
    missing+=("$name")
  fi
  export "$name=${value}"
done

if (( ${#missing[@]} > 0 )); then
  echo "Missing required settings: ${missing[*]}" >&2
  echo "Update .env or export them in your shell, then rerun ./run_local.sh" >&2
  exit 1
fi

if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi

args=("$@")
if [[ -n "${OPENAI_MODEL:-}" ]]; then
  args+=("llm.generation_kwargs.model=${OPENAI_MODEL}")
fi

exec uv run python src/zotero_arxiv_daily/main.py "${args[@]}"
