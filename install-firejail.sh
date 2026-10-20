#!/usr/bin/env bash
# Project Dark Hunt — Install Firejail Sandbox (v0.9.80)
# Team NullX · Department of SWE, DIU
set -euo pipefail

echo "=========================================================="
echo "  Project Dark Hunt — Firejail Sandbox Installer"
echo "=========================================================="

if command -v firejail >/dev/null 2>&1; then
  echo "[+] Firejail is already installed:"
  firejail --version | head -n 2
  echo "[+] No further action needed."
  exit 0
fi

echo "[*] Installing Firejail 0.9.80..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"
DEB_URL="https://github.com/netblue30/firejail/releases/download/0.9.80/firejail_0.9.80_1_amd64.deb"

echo "[*] Downloading package from GitHub..."
curl -sSL -o firejail.deb "$DEB_URL"

echo "[*] Installing .deb package..."
sudo apt install -y ./firejail.deb

echo "=========================================================="
echo "[+] SUCCESS: Firejail $(firejail --version | head -n 1) installed successfully!"
echo "=========================================================="
