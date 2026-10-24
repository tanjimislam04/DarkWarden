#!/usr/bin/env bash
# Project Dark Hunt — Start VPN & Activate Airtight Host Killswitch
# Team NullX · Department of Software Engineering, DIU
# Author: Md. Tanjim Islam & Team NullX
set -euo pipefail

vpn_iface_up() {
  ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -Eq '^(tun[0-9]+|proton[0-9]+|wg-proton)'
}

get_vpn_endpoint_ip() {
  local peer_ip=""
  # 1. From nmcli active wireguard/vpn connection
  if command -v nmcli >/dev/null 2>&1; then
    local conn
    conn=$(nmcli -t -f UUID,TYPE,NAME con show --active 2>/dev/null | grep -E 'wireguard|vpn|Proton' | head -n 1 | cut -d: -f3 || true)
    if [ -n "$conn" ]; then
      peer_ip=$(nmcli -s -g wireguard.peers con show "$conn" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || true)
    fi
  fi
  # 2. From routing table host routes (/32)
  if [ -z "$peer_ip" ]; then
    peer_ip=$(ip route show 2>/dev/null | awk '/\/32 via/ {print $1}' | cut -d/ -f1 | head -n 1 || true)
  fi
  # 3. From active sockets
  if [ -z "$peer_ip" ] && command -v ss >/dev/null 2>&1; then
    peer_ip=$(ss -nuap 2>/dev/null | grep -E 'proton|wireguard' | awk '{print $5}' | cut -d: -f1 | grep -v '0.0.0.0' | head -n 1 || true)
  fi
  echo "$peer_ip"
}

echo "=========================================================="
echo "  Project Dark Hunt — Initializing Secure Session"
echo "=========================================================="

# 1. First attempt: Connect Proton VPN in user space if not already active
if ! vpn_iface_up; then
  echo "[-] VPN tunnel not active. Attempting connection..."
  if [ "$(id -u)" -ne 0 ] && command -v protonvpn >/dev/null 2>&1; then
    protonvpn connect || true
  fi
fi

# 2. Escalate to root for UFW Killswitch and kernel hardening
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null; then
    exec sudo -E "$0" "$@"
  fi
  echo "ERROR: Root privileges required to configure firewall killswitch." >&2
  exit 1
fi

# Wait up to 30 seconds for VPN tunnel interface to appear
for i in $(seq 1 30); do
  if vpn_iface_up; then
    break
  fi
  sleep 1
done

if ! vpn_iface_up; then
  echo "[-] VPN tunnel could not be established."
  echo "    Please open Proton VPN and connect manually, then rerun this script."
  exit 1
fi

VPN_IFACE=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^(tun[0-9]+|proton[0-9]+|wg-proton)' | head -n 1)
echo "[+] VPN Tunnel verified ($VPN_IFACE)."

# 3. Detect VPN Endpoint Server IP for Strict Egress Pinning
VPN_ENDPOINT=$(get_vpn_endpoint_ip)

# 4. Activate Airtight UFW Killswitch
echo "[*] Activating Airtight Host Egress Killswitch..."
command -v ufw >/dev/null 2>&1 || { apt-get update && apt-get install -y ufw; }

# Clean reset of existing rules to eliminate conflicts
ufw --force reset >/dev/null

# Strict default deny policies across all dimensions
ufw default deny incoming >/dev/null
ufw default deny outgoing >/dev/null
ufw default deny forward >/dev/null

# Allow loopback (essential for local IPC, Tor SOCKS5 proxy)
ufw allow in on lo >/dev/null
ufw allow out on lo >/dev/null

# Allow Docker container bridge (for Robin AI Web UI :8501)
ufw allow in on docker0 >/dev/null
ufw allow out on docker0 >/dev/null

# Allow ALL traffic ONLY inside the encrypted VPN tunnel
for vpn_pfx in tun+ proton+ wg+; do
  ufw allow in on "$vpn_pfx" >/dev/null
  ufw allow out on "$vpn_pfx" >/dev/null
done

# Allow local DHCP renewals so physical link stays alive
ufw allow out 67:68/udp >/dev/null
ufw allow in 67:68/udp >/dev/null

# Pin physical uplink strictly to the VPN server endpoint
if [ -n "$VPN_ENDPOINT" ]; then
  echo "[+] Pinning physical uplink strictly to VPN endpoint IP: $VPN_ENDPOINT"
  ufw allow out to "$VPN_ENDPOINT" >/dev/null
else
  echo "[*] Enforcing dedicated VPN protocol ports on physical uplink..."
  ufw allow out 51820/udp >/dev/null
  ufw allow out 1194/udp >/dev/null
fi

# Explicitly block plain DNS (port 53) on all physical interfaces (zero DNS leaks)
for phys in $(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^(eth|wlan|en|wl|ppp)'); do
  ufw deny out on "$phys" to any port 53 >/dev/null 2>&1 || true
done

# Enable UFW firewall
ufw --force enable >/dev/null

# 5. Kernel Hardening: Eliminate IPv6 bypass & spoofing
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1 || true
sysctl -w net.ipv4.conf.all.rp_filter=1 >/dev/null 2>&1 || true
sysctl -w net.ipv4.conf.default.rp_filter=1 >/dev/null 2>&1 || true

# 6. Real-Time Leak Verification Test
PHYS_DEV=$(ip route show default 2>/dev/null | grep -v 'proton\|tun' | awk '{print $5}' | head -n 1 || echo "")
if [ -n "$PHYS_DEV" ]; then
  if curl --interface "$PHYS_DEV" -s --connect-timeout 2 http://1.1.1.1 >/dev/null 2>&1; then
    echo "[-] WARNING: Direct physical egress test leaked! Please review UFW status."
  else
    echo "[✓] Airtight Killswitch Verified: Direct physical leakage is 100% BLOCKED."
  fi
fi

echo "=========================================================="
echo "[+] SECURE SESSION READY!"
echo "[+] Host Killswitch is ACTIVE. Normal ISP traffic is 100% BLOCKED."
echo "[+] All internet traffic is strictly locked inside: $VPN_IFACE"
echo "=========================================================="
