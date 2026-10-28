#!/usr/bin/env bash
# Safe Dark Web Access — Stop Firejail Tor Browser
# Safe Dark Web Access & Defense Architecture
set -euo pipefail

echo "==> Closing Firejail Tor Browser session..."

# Terminate any firejail instances running torbrowser
if command -v firejail >/dev/null 2>&1; then
  firejail --shutdown 2>/dev/null || true
fi

pkill -f "torbrowser-launcher" 2>/dev/null || true
pkill -f "firefox.real" 2>/dev/null || true
# Stop Auto-Sanitizer Sentry
if [ -f "./watch-and-sanitize.sh" ]; then
  ./watch-and-sanitize.sh stop >/dev/null 2>&1 || true
fi

# Shred and teardown volatile RAM storage
if [ -x "./setup-ramdisk.sh" ]; then
  ./setup-ramdisk.sh unmount >/dev/null 2>&1 || true
fi

echo "[+] Tor Browser closed. Auto-Sanitizer Sentry disengaged."
echo "[+] Volatile quarantine & downloads purged from RAM (Anti-Forensics complete)."
