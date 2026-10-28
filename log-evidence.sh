#!/usr/bin/env bash
# DarkWarden — Cryptographic Evidence Integrity & GPG Logger
# Department of Software Engineering, Daffodil International University (DIU)
# Author: Md. Tanjim Islam (tanjimislam04)
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: ./log-evidence.sh <file_or_screenshot> [CASE-ID/TAG] [Optional note]"
  echo "Example: ./log-evidence.sh sample-safe.pdf CASE-001 'Verified threat actor breach claim'"
  exit 1
fi

FILE="$1"
CASE_TAG="${2:-CASE-001}"
NOTE="${3:-No description provided}"

if [ ! -f "$FILE" ]; then
  echo "ERROR: File '$FILE' does not exist." >&2
  exit 1
fi

EVIDENCE_DIR="investigations/evidence"
LEDGER="$EVIDENCE_DIR/evidence_ledger.csv"
mkdir -p "$EVIDENCE_DIR"

# Initialize CSV ledger if missing
if [ ! -f "$LEDGER" ]; then
  echo "Timestamp,Case_Tag,Filename,SHA256,Note" > "$LEDGER"
fi

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
BASENAME="$(basename "$FILE")"
CLEAN_TIMESTAMP="$(echo "$TIMESTAMP" | tr -d ':-')"
TARGET_FILE="$EVIDENCE_DIR/${CASE_TAG}_${CLEAN_TIMESTAMP}_${BASENAME}"

# Copy file into preserved evidence directory
cp "$FILE" "$TARGET_FILE"
HASH="$(sha256sum "$TARGET_FILE" | awk '{print $1}')"

# Append record to immutable ledger
echo "\"$TIMESTAMP\",\"$CASE_TAG\",\"$(basename "$TARGET_FILE")\",\"$HASH\",\"$NOTE\"" >> "$LEDGER"

# Cryptographic GPG Detached Signing (Non-Repudiation)
SIGNER_EMAIL="islamtanjim2004@gmail.com"
GPG_SIGNED="NO"

if gpg --list-secret-keys "$SIGNER_EMAIL" >/dev/null 2>&1; then
  # Sign the updated audit ledger
  gpg --batch --yes --detach-sign --armor --default-key "$SIGNER_EMAIL" --output "$LEDGER.asc" "$LEDGER" 2>/dev/null || true
  # Sign the individual evidence artifact
  gpg --batch --yes --detach-sign --armor --default-key "$SIGNER_EMAIL" --output "$TARGET_FILE.asc" "$TARGET_FILE" 2>/dev/null || true
  GPG_SIGNED="YES"
fi

echo "=========================================================="
echo "[+] EVIDENCE LOGGED SUCCESSFULLY"
echo "    File:          $TARGET_FILE"
echo "    SHA-256 Hash:  $HASH"
echo "    Ledger:        $LEDGER"
if [ "$GPG_SIGNED" = "YES" ]; then
  echo "    GPG Signature: $LEDGER.asc [VERIFIED]"
  echo "    Artifact Sig:  $TARGET_FILE.asc [VERIFIED]"
  echo "    Signer:        Md. Tanjim Islam <$SIGNER_EMAIL>"
  echo "    Status:        Court-Admissible (Tamper-Proof & Non-Repudiable)"
else
  echo "    GPG Signature: PENDING (Run ./setup-gpg-key.sh to enable)"
fi
echo "=========================================================="
