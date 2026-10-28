#!/usr/bin/env bash
# DarkWarden — Manage Real-Time Auto-Sanitizer Sentry
# Department of Software Engineering, DIU
set -euo pipefail
cd "$(dirname "$0")"

PID_FILE="/tmp/darkhunt_sanitizer.pid"

status() {
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "[+] Auto-Sanitizer Sentry is RUNNING (PID: $(cat "$PID_FILE"))"
    return 0
  else
    echo "[-] Auto-Sanitizer Sentry is NOT running."
    return 1
  fi
}

start() {
  if status >/dev/null 2>&1; then
    echo "[!] Sentry is already running (PID: $(cat "$PID_FILE"))."
    exit 0
  fi

  echo "==> Starting DarkWarden Auto-Sanitizer Sentry in background..."
  nohup python3 auto_sanitizer.py >/dev/null 2>&1 &
  echo $! > "$PID_FILE"
  sleep 1

  if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "=========================================================="
    echo "[+] SUCCESS: Auto-Sanitizer Sentry is now ACTIVE!"
    echo "    Watching: ~/Downloads and Tor Browser Downloads"
    echo "    Behavior: Auto-Defangs files -> Quarantines bad files -> Desktop Alert"
    echo "    Log File: investigations/sanitizer.log"
    echo "=========================================================="
  else
    echo "[-] Failed to start sentry. Check python3 auto_sanitizer.py"
    exit 1
  fi
}

stop() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      echo "==> Stopping Auto-Sanitizer Sentry (PID: $PID)..."
      kill "$PID" 2>/dev/null || true
    fi
    rm -f "$PID_FILE"
    echo "[+] Sentry stopped."
  else
    pkill -f "auto_sanitizer.py" 2>/dev/null || true
    echo "[+] Sentry stopped."
  fi
}

case "${1:-start}" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart)
    stop
    sleep 1
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart}"
    exit 1
    ;;
esac
