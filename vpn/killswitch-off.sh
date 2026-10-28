#!/usr/bin/env bash
# DarkWarden — Emergency Killswitch Unlock
# Safe Dark Web Access & Defense Architecture
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null; then
    exec sudo -E "$0" "$@"
  fi
  echo "ERROR: Root privileges required." >&2
  exit 1
fi

echo "[*] Emergency: Unlocking all outbound traffic..."
if command -v ufw >/dev/null 2>&1; then
  ufw default allow outgoing >/dev/null
  ufw disable >/dev/null
  echo "[+] UFW Killswitch disabled."
fi

# Restore IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1 || true

echo "[+] Normal internet is restored immediately."
