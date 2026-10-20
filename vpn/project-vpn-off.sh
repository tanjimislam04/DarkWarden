#!/usr/bin/env bash
# Project Dark Hunt — Teardown VPN & Disable Killswitch
# Team NullX
set -euo pipefail

need_root() {
  if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null; then
      exec sudo -E "$0" "$@"
    fi
    echo "ERROR: Root privileges required." >&2
    exit 1
  fi
}

need_root "$@"

echo "=========================================================="
echo "  Project Dark Hunt — Ending Secure Session"
echo "=========================================================="

# 1. Disable Killswitch
echo "[*] Disabling Host Killswitch..."
if command -v ufw >/dev/null 2>&1; then
  ufw default allow outgoing >/dev/null
  ufw disable >/dev/null
  echo "[+] Firewall killswitch deactivated. Outbound traffic restored."
fi

# Restore IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1 || true

# 2. Disconnect Proton VPN
if command -v protonvpn >/dev/null 2>&1; then
  runner=(protonvpn)
  if [ -n "${SUDO_USER:-}" ]; then
    runner=(sudo -u "$SUDO_USER" protonvpn)
  fi
  "${runner[@]}" disconnect >/dev/null 2>&1 || true
  echo "[+] Proton VPN disconnected."
fi

echo "=========================================================="
echo "[+] Session closed. Normal internet restored."
echo "=========================================================="
