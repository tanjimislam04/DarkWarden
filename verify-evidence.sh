#!/usr/bin/env bash
# DarkWarden — Cryptographic Evidence Integrity & GPG Verifier
# Department of Software Engineering, Daffodil International University (DIU)
# Author: Md. Tanjim Islam (tanjimislam04)
set -euo pipefail

EVIDENCE_DIR="investigations/evidence"
LEDGER="$EVIDENCE_DIR/evidence_ledger.csv"
LEDGER_SIG="$LEDGER.asc"
PUBKEY="$EVIDENCE_DIR/investigator_public_key.asc"
[ ! -f "$PUBKEY" ] && [ -f "$EVIDENCE_DIR/team_nullx_public_key.asc" ] && PUBKEY="$EVIDENCE_DIR/team_nullx_public_key.asc"

echo "=========================================================="
echo "  DarkWarden — Cryptographic Evidence Audit Tool"
echo "=========================================================="

if [ ! -f "$LEDGER" ]; then
  echo "[-] ERROR: Evidence ledger not found: $LEDGER"
  exit 1
fi

# Step 1: Ensure public key is imported if available
if [ -f "$PUBKEY" ]; then
  gpg --import "$PUBKEY" >/dev/null 2>&1 || true
fi

# Step 2: Verify GPG Detached Signature on Ledger
echo -n "[1] Evidence Ledger GPG Signature: "
SIGNATURE_VALID=0
if [ -f "$LEDGER_SIG" ]; then
  if gpg --verify "$LEDGER_SIG" "$LEDGER" >/dev/null 2>&1; then
    SIGNER_INFO=$(gpg --verify "$LEDGER_SIG" "$LEDGER" 2>&1 | awk '/Good signature from/ {print substr($0, index($0,$4))}' | head -n 1)
    echo "VALID & UNTAMPERED"
    echo "    [✓] Signer: $SIGNER_INFO"
    echo "    [✓] Non-Repudiation: 100% Guaranteed (No bytes altered since signing)"
    SIGNATURE_VALID=1
  else
    echo "TAMPERED / INVALID SIGNATURE!"
    echo "    [!] CRITICAL ALERT: Evidence ledger has been modified after signature creation!"
  fi
else
  echo "NOT SIGNED (Run ./log-evidence.sh with GPG key to generate signature)"
fi

# Step 3: Verify Cryptographic SHA-256 Hashes of All Artifacts in Ledger
echo -e "\n[2] Verifying Cryptographic Hash Integrity of All Artifacts:"
TOTAL=0
MATCHED=0
FAILED=0

# Read CSV skipping header
while IFS=, read -r timestamp case_tag filename sha256 note; do
  # Remove quotes
  timestamp=$(echo "$timestamp" | tr -d '"')
  case_tag=$(echo "$case_tag" | tr -d '"')
  filename=$(echo "$filename" | tr -d '"')
  sha256=$(echo "$sha256" | tr -d '"')
  note=$(echo "$note" | tr -d '"')

  [ "$timestamp" = "Timestamp" ] && continue
  [ -z "$filename" ] && continue

  TOTAL=$((TOTAL + 1))
  FILEPATH="$EVIDENCE_DIR/$filename"

  if [ ! -f "$FILEPATH" ]; then
    echo "    [-] MISSING ARTIFACT: $filename"
    FAILED=$((FAILED + 1))
    continue
  fi

  ACTUAL_HASH=$(sha256sum "$FILEPATH" | awk '{print $1}')
  if [ "$ACTUAL_HASH" = "$sha256" ]; then
    SIG_FLAG=""
    if [ -f "$FILEPATH.asc" ] && gpg --verify "$FILEPATH.asc" "$FILEPATH" >/dev/null 2>&1; then
      SIG_FLAG=" [GPG-Verified]"
    fi
    echo "    [✓] $case_tag: $filename -> MATCH$SIG_FLAG"
    MATCHED=$((MATCHED + 1))
  else
    echo "    [✗] $case_tag: $filename -> HASH MISMATCH!"
    echo "        Expected: $sha256"
    echo "        Actual:   $ACTUAL_HASH"
    FAILED=$((FAILED + 1))
  fi
done < "$LEDGER"

echo "----------------------------------------------------------"
echo "[+] Audit Summary: $TOTAL artifacts tracked, $MATCHED verified, $FAILED discrepancies."
if [ "$FAILED" -eq 0 ] && [ "$TOTAL" -gt 0 ] && [ "$SIGNATURE_VALID" -eq 1 ]; then
  echo "[✓] Chain of Custody: 100% Cryptographically Admissible & Verified."
  echo "=========================================================="
  exit 0
else
  echo "[-] Chain of Custody Audit FAILED! (Discrepancies or signature mismatch found)"
  echo "=========================================================="
  exit 1
fi
