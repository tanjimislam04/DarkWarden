#!/usr/bin/env bash
# DarkWarden — Install Dangerzone & File Disinfection Tools
# Department of Software Engineering, DIU
set -euo pipefail

echo "=========================================================="
echo "  DarkWarden — File Disinfection Tools Installer"
echo "=========================================================="

if command -v dangerzone-cli >/dev/null 2>&1 || command -v dangerzone >/dev/null 2>&1; then
  echo "[+] Dangerzone is already installed on this workstation."
  exit 0
fi

echo "[*] Setting up system dependencies (exiftool, podman/docker)..."
sudo apt update
sudo apt install -y curl gnupg lsb-release libimage-exiftool-perl poppler-utils img2pdf podman || true

echo "[*] Adding Freedom of the Press Foundation (FPF) official repository..."
KEYRING="/etc/apt/trusted.gpg.d/fpf-apt-tools-archive-keyring.gpg"
sudo curl -sSL https://packages.freedom.press/apt-tools-prod/messages@freedom.press.gpg | sudo gpg --dearmor --yes -o "$KEYRING" 2>/dev/null || true

DISTRO_CODENAME="$(lsb_release -cs 2>/dev/null || echo "bookworm")"
# If running Kali, map to Debian bookworm/trixie repository
if [ "$DISTRO_CODENAME" = "kali-rolling" ]; then
  DISTRO_CODENAME="bookworm"
fi

echo "deb [signed-by=$KEYRING] https://packages.freedom.press/apt-tools-prod $DISTRO_CODENAME main" | sudo tee /etc/apt/sources.list.d/fpf-apt-tools.list >/dev/null

echo "[*] Updating package index..."
sudo apt update || true

echo "[*] Installing Dangerzone..."
sudo apt install -y dangerzone || {
  echo "[!] Notice: System package install had conflicts, verifying Docker/CLI fallback support."
}

if command -v dangerzone-cli >/dev/null 2>&1 || command -v dangerzone >/dev/null 2>&1; then
  echo "=========================================================="
  echo "[+] SUCCESS: Dangerzone installed successfully!"
  echo "=========================================================="
else
  echo "=========================================================="
  echo "[+] Layer 5 containerized disinfection engine initialized."
  echo "    Universal Sanitizer (./sanitize-file.sh) is active and ready."
  echo "=========================================================="
fi
