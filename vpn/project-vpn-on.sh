#!/usr/bin/env bash
# Project Dark Hunt — Start VPN & Activate Host Killswitch
# Team NullX
set -euo pipefail

need_root() {
  if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null; then
      exec sudo -E "$0" "$@"
    fi
    echo "ERROR: Root privileges required to configure VPN/Killswitch." >&2
    exit 1
  fi
}

vpn_iface_up() {
  ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -Eq '^(tun[0-9]+|proton[0-9]+|wg-proton)'
}

echo "=========================================================="
echo "  Project Dark Hunt — Initializing Secure Session"
echo "=========================================================="

# 1. Check or establish VPN
if ! vpn_iface_up; then
  echo "[-] VPN tunnel not active. Attempting connection..."
  if command -v protonvpn >/dev/null 2>&1; then
    runner=(protonvpn)
    if [ -n "${SUDO_USER:-}" ]; then
      runner=(sudo -u "$SUDO_USER" -E protonvpn)
    fi
    "${runner[@]}" connect || true
  fi

  # Wait up to 30 seconds for tunnel
  for i in $(seq 1 30); do
    if vpn_iface_up; then
      break
    fi
    sleep 1
  done
fi

if ! vpn_iface_up; then
  echo "[-] VPN tunnel could not be started automatically."
  echo "    Please open Proton VPN and click 'Connect', then run this script again."
  exit 1
fi

echo "[+] VPN Tunnel verified."

# 2. Activate UFW Killswitch
need_root "$@"

echo "[+] Activating Host Killswitch (locking all outbound traffic to VPN)..."
command -v ufw >/dev/null 2>&1 || { apt-get update && apt-get install -y ufw; }

ufw default deny incoming >/dev/null
ufw default deny outgoing >/dev/null

# Allow loopback (critical for internal communications)
ufw allow out on lo >/dev/null
ufw allow in on lo >/dev/null

# Allow Docker container bridge network (for port 8501 Web UI)
ufw allow in on docker0 >/dev/null
ufw allow out on docker0 >/dev/null

# Allow VPN interfaces
ufw allow out on tun+ >/dev/null
ufw allow in on tun+ >/dev/null
ufw allow out on proton+ >/dev/null
ufw allow in on proton+ >/dev/null

# Allow OpenVPN & WireGuard endpoints to stay connected
ufw allow out 1194/udp >/dev/null
ufw allow out 443/tcp >/dev/null
ufw allow out 51820/udp >/dev/null

ufw --force enable >/dev/null

# 3. Disable IPv6 to prevent IPv6 bypass leaks
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1 || true

echo "=========================================================="
echo "[+] SECURE SESSION READY!"
echo "[+] Host Killswitch is ACTIVE. Normal ISP traffic is BLOCKED."
echo "[+] All traffic is forced through MikroTik -> Proton VPN."
echo "=========================================================="
