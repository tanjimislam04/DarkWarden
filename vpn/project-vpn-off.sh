#!/usr/bin/env bash
# DarkWarden — Teardown VPN & Disable Killswitch
# Safe Dark Web Access & Defense Architecture
set -euo pipefail

vpn_iface_up() {
  ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -Eq '^(tun[0-9]+|proton[0-9]+|wg-proton)'
}

echo "=========================================================="
echo "  DarkWarden — Ending Secure Session"
echo "=========================================================="

# 1. First attempt: Disconnect via user-space protonvpn CLI (with user's active DBus session)
if [ "$(id -u)" -ne 0 ] && command -v protonvpn >/dev/null 2>&1; then
  echo "[*] Requesting Proton VPN disconnect..."
  protonvpn disconnect 2>/dev/null || true
fi

# 2. Escalate to root for UFW and NetworkManager cleanup
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null; then
    exec sudo -E "$0" "$@"
  fi
  echo "ERROR: Root privileges required for firewall and network cleanup." >&2
  exit 1
fi

# 3. Disable Host UFW Killswitch
echo "[*] Disabling Host Killswitch..."
if command -v ufw >/dev/null 2>&1; then
  ufw default allow outgoing >/dev/null 2>&1 || true
  ufw disable >/dev/null 2>&1 || true
  echo "[+] Firewall killswitch deactivated. Outbound traffic restored."
fi

# Keep IPv6 disabled for permanent zero-leak protection
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.lo.disable_ipv6=1 >/dev/null 2>&1 || true

# 4. Force-disconnect any remaining Proton VPN connections in NetworkManager
if command -v nmcli >/dev/null 2>&1; then
  nmcli -t -f UUID,TYPE,NAME con show --active 2>/dev/null | while IFS=: read -r uuid type name; do
    if [[ "$name" =~ [Pp]roton|[Pp]vpn ]] || [ "$type" = "wireguard" ] || [ "$type" = "vpn" ]; then
      echo "[*] Tearing down NetworkManager VPN connection: $name..."
      nmcli con down uuid "$uuid" >/dev/null 2>&1 || true
    fi
  done
fi

# 5. Clean up any leftover virtual interfaces (proton0, ipv6leakintrf0)
ip link delete proton0 2>/dev/null || true
ip link delete ipv6leakintrf0 2>/dev/null || true

# 6. Verification
if vpn_iface_up; then
  echo "[-] WARNING: VPN interface is still active. Please check Proton VPN app manually."
else
  echo "[+] Proton VPN disconnected & verified."
fi

echo "=========================================================="
echo "[+] Session closed. Normal internet restored."
echo "=========================================================="
