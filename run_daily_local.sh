#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/cron.log"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

mkdir -p "$LOG_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
}

log "Starting scheduled daily run"
if "$SCRIPT_DIR/run_local.sh" >> "$LOG_FILE" 2>&1; then
  log "Scheduled daily run finished successfully"
else
  status=$?
  log "Scheduled daily run failed with exit code $status"
  exit $status
fi
