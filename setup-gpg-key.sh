#!/usr/bin/env bash
# Project Dark Hunt — Investigator GPG Key Generator & Exporter
# Team NullX · Department of Software Engineering, DIU
# Author: Md. Tanjim Islam & Team NullX
set -euo pipefail

KEY_NAME="${1:-Md. Tanjim Islam}"
KEY_EMAIL="${2:-islamtanjim2004@gmail.com}"
KEY_COMMENT="Team NullX Threat Intelligence Custody Key"

echo "=========================================================="
echo "  Project Dark Hunt — Investigator GPG Key Initialization"
echo "=========================================================="

# Check if key already exists
EXISTING_KEY=$(gpg --list-secret-keys --with-colons "$KEY_EMAIL" 2>/dev/null | awk -F: '/^sec/ {print $5}' | head -n 1 || true)

if [ -n "$EXISTING_KEY" ]; then
  echo "[✓] GPG Signing Key ALREADY EXISTS for $KEY_NAME <$KEY_EMAIL>."
  KEY_ID="$EXISTING_KEY"
else
  echo "[*] Generating military-grade 4096-bit RSA GPG signing key for:"
  echo "    Name:    $KEY_NAME"
  echo "    Email:   $KEY_EMAIL"
  echo "    Comment: $KEY_COMMENT"

  cat <<EOF | gpg --batch --gen-key >/dev/null 2>&1
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $KEY_NAME
Name-Email: $KEY_EMAIL
Name-Comment: $KEY_COMMENT
Expire-Date: 0
%no-protection
%commit
EOF
  KEY_ID=$(gpg --list-secret-keys --with-colons "$KEY_EMAIL" 2>/dev/null | awk -F: '/^sec/ {print $5}' | head -n 1)
  echo "[✓] 4096-bit GPG Key generated successfully!"
fi

FINGERPRINT=$(gpg --fingerprint "$KEY_EMAIL" 2>/dev/null | awk '/Key fingerprint/ {print substr($0, index($0,$4))}' | head -n 1 || echo "$KEY_ID")

mkdir -p investigations/evidence

# Export public key for court / team / evaluator verification
PUBKEY_PATH="investigations/evidence/team_nullx_public_key.asc"
gpg --armor --export "$KEY_EMAIL" > "$PUBKEY_PATH"
cp "$PUBKEY_PATH" "investigations/team_nullx_public_key.asc" 2>/dev/null || true

echo "----------------------------------------------------------"
echo "[+] Key ID:       $KEY_ID"
echo "[+] Fingerprint:  $FINGERPRINT"
echo "[+] Public Key:   $PUBKEY_PATH"
echo "    (Share this public key with evaluators or law enforcement to verify evidence)"
echo "=========================================================="
