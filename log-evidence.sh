#!/usr/bin/env bash
# Project Dark Hunt — Evidence Integrity & SHA-256 Logger
# Team NullX
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: ./log-evidence.sh <file_or_screenshot> [KPI-ID] [Optional note]"
  echo "Example: ./log-evidence.sh screenshot.png KPI-007 'Claimed database dump on BreachForums'"
  exit 1
fi

FILE="$1"
KPI_ID="${2:-KPI-UNASSIGNED}"
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
  echo "Timestamp,KPI_ID,Filename,SHA256,Note" > "$LEDGER"
fi

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
BASENAME="$(basename "$FILE")"
TARGET_FILE="$EVIDENCE_DIR/${KPI_ID}_${TIMESTAMP}_${BASENAME}"

# Copy file into preserved evidence directory
cp "$FILE" "$TARGET_FILE"
HASH="$(sha256sum "$TARGET_FILE" | awk '{print $1}')"

# Append record to immutable ledger
echo "\"$TIMESTAMP\",\"$KPI_ID\",\"$(basename "$TARGET_FILE")\",\"$HASH\",\"$NOTE\"" >> "$LEDGER"

echo "=========================================================="
echo "[+] EVIDENCE LOGGED SUCCESSFULLY"
echo "    File:      $TARGET_FILE"
echo "    SHA-256:   $HASH"
echo "    Ledger:    $LEDGER"
echo "=========================================================="
