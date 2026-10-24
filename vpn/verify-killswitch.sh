#!/usr/bin/env bash
# Project Dark Hunt — Automated Killswitch Leak & Security Verification Tool
# Team NullX · Department of Software Engineering, DIU
# Author: Md. Tanjim Islam & Team NullX
set -euo pipefail

echo "=========================================================="
echo "  Project Dark Hunt — Live Killswitch Security Audit"
echo "=========================================================="

vpn_iface_up() {
  ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -Eq '^(tun[0-9]+|proton[0-9]+|wg-proton)'
}

# 1. Check VPN Interface
echo -n "[1] VPN Tunnel Interface: "
if vpn_iface_up; then
  VPN_DEV=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^(tun[0-9]+|proton[0-9]+|wg-proton)' | head -n 1)
  echo "ACTIVE ($VPN_DEV)"
else
  echo "INACTIVE / DISCONNECTED"
  echo "    [-] WARNING: VPN is not running. Killswitch cannot protect active session."
  exit 1
fi

# 2. Check UFW Status
echo -n "[2] Host UFW Killswitch: "
if command -v ufw >/dev/null 2>&1; then
  UFW_STATUS=$(sudo ufw status 2>/dev/null | head -n 1 || echo "unknown")
  if [[ "$UFW_STATUS" =~ "active" ]]; then
    echo "ACTIVE & ENFORCING"
  else
    echo "INACTIVE (Not enabled)"
  fi
else
  echo "UFW NOT INSTALLED"
fi

# 3. Check IPv6 Leak Prevention
echo -n "[3] IPv6 Leak Prevention: "
IPV6_ALL=$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null || echo "0")
if [ "$IPV6_ALL" = "1" ]; then
  echo "PASS (IPv6 completely disabled in kernel)"
else
  echo "WARN (IPv6 is enabled; potential bypass risk)"
fi

# 4. Physical Interface Leak Test (Simulate tunnel failure)
PHYS_DEV=$(ip route show default 2>/dev/null | grep -v 'proton\|tun' | awk '{print $5}' | head -n 1 || echo "")
if [ -z "$PHYS_DEV" ]; then
  PHYS_DEV=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^(eth[0-9]+|wlan[0-9]+|enp|wlp)' | head -n 1 || echo "")
fi

echo -n "[4] Direct Physical Egress Leak Test ($PHYS_DEV): "
if [ -n "$PHYS_DEV" ]; then
  # Try sending packet directly out through the physical interface, bypassing VPN
  if curl --interface "$PHYS_DEV" -s --connect-timeout 3 http://1.1.1.1 >/dev/null 2>&1; then
    echo "FAILED! (Cleartext traffic leaked directly over $PHYS_DEV!)"
    echo "    [!] CRITICAL OPSEC ALERT: Killswitch has allowed direct physical packet egress."
  else
    echo "PASS (Traffic strictly BLOCKED by kernel firewall)"
  fi
else
  echo "SKIPPED (No physical interface detected)"
fi

# 5. Public IP & GeoIP Verification through VPN
echo -n "[5] Current External Route: "
EXT_INFO=$(curl -s --connect-timeout 5 https://ipinfo.io/json 2>/dev/null || echo "")
if [ -n "$EXT_INFO" ]; then
  PUB_IP=$(echo "$EXT_INFO" | python3 -c 'import sys, json; d=json.load(sys.stdin); print(d.get("ip"))' 2>/dev/null || echo "Unknown")
  ORG=$(echo "$EXT_INFO" | python3 -c 'import sys, json; d=json.load(sys.stdin); print(d.get("org"))' 2>/dev/null || echo "Unknown")
  CITY=$(echo "$EXT_INFO" | python3 -c 'import sys, json; d=json.load(sys.stdin); print(d.get("city"))' 2>/dev/null || echo "Unknown")
  echo "$PUB_IP ($ORG, $CITY)"
  if [[ "$ORG" =~ [Pp]roton|[Dd]atapacket|[Cc]dn77|[Mm]247|[Ff]astly ]]; then
    echo "    [✓] Route is fully encrypted through trusted VPN node."
  elif [[ "$ORG" =~ [Dd]affodil|[Bb]angladesh|[Bb]TTCL|[Ll]ink3 ]]; then
    echo "    [✗] LEAK DETECTED: ISP is exposing true Bangladesh location ($ORG)!"
  fi
else
  echo "Unable to reach external internet."
fi

echo "=========================================================="
