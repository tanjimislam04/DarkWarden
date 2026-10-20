#!/usr/bin/env bash
# Project Dark Hunt — Check obfs4 Bridge Reachability
# Team NullX · Department of SWE, DIU
set -euo pipefail

cd "$(dirname "$0")/.."

TORRC="vpn/torrc"

echo "=========================================================="
echo "  Project Dark Hunt — obfs4 Bridge Connectivity Check"
echo "=========================================================="

if [ ! -f "$TORRC" ]; then
  echo "[-] ERROR: $TORRC not found!"
  exit 1
fi

# Pre-flight check: VPN must be up to check bridges
if ! ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -Eq '^(tun[0-9]+|proton[0-9]+|wg-proton)'; then
  echo "[!] WARNING: VPN tunnel is NOT active!"
  echo "    Testing bridges without VPN may leak requests to your ISP."
  echo "    Please run: ./vpn/project-vpn-on.sh"
  exit 1
fi

echo "[+] VPN Tunnel verified. Testing bridges through encrypted tunnel..."
echo "----------------------------------------------------------"

BRIDGE_COUNT=0
ONLINE_COUNT=0

while read -r line; do
  if [[ "$line" =~ ^Bridge[[:space:]]+obfs4[[:space:]]+([0-9a-fA-F.:]+):([0-9]+) ]]; then
    IP="${BASH_REMATCH[1]}"
    PORT="${BASH_REMATCH[2]}"
    BRIDGE_COUNT=$((BRIDGE_COUNT + 1))
    
    # Test TCP port reachability
    if timeout 3 bash -c "cat < /dev/null > /dev/tcp/$IP/$PORT" 2>/dev/null; then
      echo "[✓] Bridge #$BRIDGE_COUNT ($IP:$PORT) -> ONLINE & REACHABLE"
      ONLINE_COUNT=$((ONLINE_COUNT + 1))
    else
      echo "[✗] Bridge #$BRIDGE_COUNT ($IP:$PORT) -> TIMEOUT / UNREACHABLE"
    fi
  fi
done < "$TORRC"

echo "----------------------------------------------------------"
echo "[*] Result: $ONLINE_COUNT of $BRIDGE_COUNT configured obfs4 bridges are active."
if [ "$ONLINE_COUNT" -gt 0 ]; then
  echo "[+] Tor traffic obfuscation is HEALTHY."
else
  echo "[-] All bridges unreachable. Request fresh bridges from https://bridges.torproject.org"
fi
echo "=========================================================="
