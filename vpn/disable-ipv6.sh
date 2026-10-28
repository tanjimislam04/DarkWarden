#!/usr/bin/env bash
# DarkWarden — Permanent IPv6 Leak Blackhole Script
# Department of Software Engineering, Daffodil International University (DIU)
# Author: Md. Tanjim Islam (tanjimislam04)
set -euo pipefail

echo "=========================================================="
echo "  DarkWarden — Permanent IPv6 Blackhole Setup"
echo "=========================================================="

if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    exec sudo "$0" "$@"
  else
    echo "[-] ERROR: Root privileges required to configure kernel sysctl." >&2
    exit 1
  fi
fi

echo "[*] Writing permanent IPv6 blackhole configuration to /etc/sysctl.d/99-disable-ipv6.conf..."
cat <<'EOF' > /etc/sysctl.d/99-disable-ipv6.conf
# Disable IPv6 completely to prevent cleartext VPN bypass
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

echo "[*] Applying kernel sysctl parameters immediately..."
sysctl -p /etc/sysctl.d/99-disable-ipv6.conf >/dev/null 2>&1 || sysctl --system >/dev/null 2>&1

# Also ensure UFW drops IPv6 by default
if [ -f /etc/default/ufw ]; then
  sed -i 's/^IPV6=.*/IPV6=no/' /etc/default/ufw 2>/dev/null || true
fi

echo "=========================================================="
echo "[✓] SUCCESS: IPv6 is now permanently disabled on host!"
echo "    - net.ipv6.conf.all.disable_ipv6 = $(sysctl -n net.ipv6.conf.all.disable_ipv6)"
echo "    - net.ipv6.conf.default.disable_ipv6 = $(sysctl -n net.ipv6.conf.default.disable_ipv6)"
echo "    - net.ipv6.conf.lo.disable_ipv6 = $(sysctl -n net.ipv6.conf.lo.disable_ipv6)"
echo "    - Zero IPv6 leak risk across reboots."
echo "=========================================================="
