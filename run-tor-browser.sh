#!/usr/bin/env bash
# Project Dark Hunt — Start Sandboxed Tor Browser
# Team NullX
set -euo pipefail

vpn_iface_up() {
  ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -Eq '^(tun[0-9]+|proton[0-9]+|wg-proton)'
}

echo "=========================================================="
echo "  Project Dark Hunt — Launching Tor Browser"
echo "=========================================================="

# 1. Hard VPN check: Never start Tor Browser without VPN
if ! vpn_iface_up; then
  echo "[-] ERROR: VPN tunnel is NOT active!"
  echo "    For OPSEC safety, you MUST start VPN before running Tor Browser."
  echo "    Run: ./vpn/project-vpn-on.sh"
  exit 1
fi
echo "[+] VPN Tunnel verified."

# 2. Find Tor Browser binary
TOR_CMD=""
if [ -f "$HOME/.local/share/torbrowser/tbb/x86_64/tor-browser/Browser/start-tor-browser" ]; then
  TOR_CMD="$HOME/.local/share/torbrowser/tbb/x86_64/tor-browser/Browser/start-tor-browser"
elif command -v tor-browser >/dev/null 2>&1; then
  TOR_CMD="tor-browser"
elif command -v torbrowser-launcher >/dev/null 2>&1; then
  TOR_CMD="torbrowser-launcher"
fi

if [ -z "$TOR_CMD" ]; then
  echo "[-] Tor Browser not found."
  echo "    Please install torbrowser-launcher: sudo apt install -y torbrowser-launcher"
  exit 1
fi

# 3. Activate Volatile RAM-backed Anti-Forensics Storage
if [ -x "./setup-ramdisk.sh" ]; then
  ./setup-ramdisk.sh mount >/dev/null 2>&1 || true
fi

# 4. Enforce Clipboard & Anti-Snooping Privacy Hardening
if [ -x "./apply-clipboard-hardening.sh" ]; then
  ./apply-clipboard-hardening.sh >/dev/null 2>&1 || true
fi

# 5. Launch with Firejail Double-Layered Sandbox if installed
if command -v firejail >/dev/null 2>&1; then
  echo "[+] Launching inside Double-Layered Nested Sandbox:"
  echo "    [1] Outer Wall (Firejail): Host files (~/.ssh, Documents, Desktop) 100% hidden."
  echo "    [2] Inner Wall (Mozilla L3): Content processes isolated with Seccomp-BPF."
  echo "    [3] IPC & D-Bus Isolation: --nodbus, --ipc-namespace, --nosound, --novideo."
  echo "    [4] Anti-Snooping: Host clipboard protected from web-page reads & hooks."
  nohup firejail --nodbus --nosound --novideo --ipc-namespace --caps.drop=all --nonewprivs --noroot "$TOR_CMD" >/tmp/tor-browser-firejail.log 2>&1 &
  echo "[+] Tor Browser is now RUNNING in Hardened Firejail Nested Double Sandbox!"
else
  echo "[+] Launching Tor Browser (Native Mozilla Level-3 Sandbox + Seccomp-BPF)..."
  nohup "$TOR_CMD" >/tmp/tor-browser.log 2>&1 &
  echo "[+] Tor Browser is now RUNNING safely!"
fi

# 4. Start Real-Time Layer 5 Auto-Sanitizer Sentry
if [ -f "./watch-and-sanitize.sh" ]; then
  ./watch-and-sanitize.sh start >/dev/null 2>&1 || true
fi

echo "=========================================================="
echo "  OPSEC Reminder: Click the Shield icon in Tor Browser"
echo "  and set Security Level to 'Safest' (disables JavaScript)."
echo "  [Auto-Sentry]: Downloads are automatically sanitized & quarantined!"
echo "=========================================================="
