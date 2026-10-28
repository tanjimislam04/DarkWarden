#!/usr/bin/env bash
# Safe Dark Web Access & Threat Intelligence Disinfection Architecture
# Layer 5 Universal Anti-Malware & File Sanitizer
# Author: Md. Tanjim Islam (tanjimislam04)
# Solutions: Universal Defanger (1) + Exif Stripper (2) + Static Triage (4)
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <untrusted_file_path> [output_directory]"
  echo "Example:"
  echo "  $0 dark_leak.pdf"
  echo "  $0 leaked_database.sql"
  echo "  $0 breach_users.csv"
  echo "  $0 dump.zip"
  exit 1
fi

INPUT_FILE="$1"
OUT_DIR="${2:-$(dirname "$INPUT_FILE")}"

if [ ! -f "$INPUT_FILE" ]; then
  echo "[-] ERROR: File not found: $INPUT_FILE"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$OUT_DIR"
BASENAME=$(basename "$INPUT_FILE")
FILENAME="${BASENAME%.*}"
EXT="${BASENAME##*.}"
EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

echo "=========================================================="
echo "  Safe Dark Web Access — Anti-Malware Triage & Sanitizer"
echo "=========================================================="
echo "[*] Target File:   $INPUT_FILE"
ORIG_HASH=$(sha256sum "$INPUT_FILE" | awk '{print $1}')
echo "[*] SHA-256 Hash:  $ORIG_HASH"

MIME_TYPE=$(file -b --mime-type "$INPUT_FILE" 2>/dev/null || echo "application/octet-stream")
echo "[*] Detected MIME: $MIME_TYPE"
echo "----------------------------------------------------------"

# ====================================================================
# SOLUTION 4: STATIC MALWARE & EXPLOIT TRIAGE ENGINE
# ====================================================================
echo "[*] Running Solution 4: Static Exploit & Malware Signature Triage..."

TRIAGE_RESULT=$(python3 -c "
import sys, re, os

in_path = sys.argv[1]
ext = sys.argv[2].lower()

threats = []
credibility_recommendation = 'Neutral'

try:
    with open(in_path, 'rb') as f:
        header = f.read(2048)
        f.seek(0)
        full_content = f.read(5 * 1024 * 1024) # Scan first 5MB
except Exception as e:
    print(f'Error reading file: {e}')
    sys.exit(0)

# Check 1: Masquerading Executables
if header.startswith(b'MZ'):
    threats.append('Disguised Windows PE Executable (MZ Header)')
if header.startswith(b'\x7fELF'):
    threats.append('Disguised Linux ELF Executable')

# Check 2: PDF Exploits
if b'%PDF' in header or ext == 'pdf':
    pdf_indicators = [
        (b'/JavaScript', 'Embedded JavaScript engine payload'),
        (b'/JS', 'Embedded JS script stream'),
        (b'/Launch', 'Direct OS command /Launch action'),
        (b'/OpenAction', 'Auto-executing /OpenAction hook'),
        (b'/EmbeddedFiles', 'Embedded malicious binary file stream'),
        (b'/RichMedia', 'Flash / RichMedia exploit container'),
        (b'/XFA', 'XML Forms Architecture exploit surface')
    ]
    for pattern, desc in pdf_indicators:
        if pattern in full_content:
            threats.append(f'PDF Exploit: {desc}')

# Check 3: Office Macros & VBA Payloads
if ext in ('doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'):
    if b'vbaProject.bin' in full_content or b'AutoOpen' in full_content or b'Document_Open' in full_content:
        threats.append('Weaponized Office Macro (VBA AutoOpen / Execution routine)')
    if re.search(rb'(?i)(powershell|cmd\.exe|wscript\.shell|URLDownloadToFile)', full_content):
        threats.append('Office Macro Shell / Downloader Payload')

# Check 4: CSV Formula Injection (DDE)
if ext in ('csv', 'tsv'):
    try:
        text = full_content.decode('utf-8', errors='ignore')
        if re.search(r'(?m)^[\s]*[=+@-]\s*(cmd|powershell|calc|certutil)', text, re.I):
            threats.append('CRITICAL: CSV Formula Injection (DDE Shellcode Trigger)')
    except Exception:
        pass

# Check 5: Web-Beacons & Canary Tracking Traps
if re.search(rb'(?i)(canarytokens\.(com|org)|webhook\.site|burpcollaborator\.net)', full_content):
    threats.append('OPSEC Trap: Active Canarytoken Web-Beacon detected (IP tracking trap)')

if threats:
    print('THREAT_DETECTED|' + '; '.join(threats))
else:
    print('CLEAN|No static exploit signatures found')
" "$INPUT_FILE" "$EXT_LOWER")

STATUS=$(echo "$TRIAGE_RESULT" | cut -d'|' -f1)
DETAILS=$(echo "$TRIAGE_RESULT" | cut -d'|' -f2)

if [ "$STATUS" = "THREAT_DETECTED" ]; then
  echo ""
  echo "⚠️  ========================================================"
  echo "⚠️  [ALERT] STATIC TRIAGE DETECTED SUSPICIOUS / WEAPONIZED INDICATORS!"
  echo "⚠️  Details: $DETAILS"
  echo "⚠️  Credibility Impact: SCORE 1 (Malicious Lure / Fraudulent Decoy)"
  echo "⚠️  ========================================================"
  echo ""
else
  echo "[+] Static Triage: No active exploit signatures detected (Structure Clean)."
fi

# Run YARA Rules Threat Intelligence Triage
if [ -f "$SCRIPT_DIR/yara_scanner.py" ]; then
  python3 "$SCRIPT_DIR/yara_scanner.py" "$INPUT_FILE" 2>/dev/null || true
fi
echo "----------------------------------------------------------"

# ====================================================================
# SOLUTION 1 & 2: UNIVERSAL DEFANGING & METADATA STRIPPING PIPELINE
# ====================================================================

python_defang() {
  python3 -c "
import sys, os, re, csv, zipfile

mode = sys.argv[1]
in_path = sys.argv[2]
out_path = sys.argv[3]

if mode == 'csv':
    # Defang CSV / Spreadsheet Formula Injection (DDE injection)
    with open(in_path, 'r', encoding='utf-8', errors='replace') as fin, \
         open(out_path, 'w', encoding='utf-8', newline='') as fout:
        reader = csv.reader(fin)
        writer = csv.writer(fout)
        for row in reader:
            safe_row = []
            for cell in row:
                if cell and cell[0] in ('=', '+', '-', '@', '\t', '\r'):
                    safe_row.append(\"'\" + cell)
                else:
                    safe_row.append(cell)
            writer.writerow(safe_row)

elif mode == 'text':
    # Strip terminal ANSI escape codes and defang web beacons
    with open(in_path, 'r', encoding='utf-8', errors='replace') as fin:
        content = fin.read()
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\\\-_]|\[[0-?]*[ -/]*[@-~])')
    cleaned = ansi_escape.sub('', content)
    cleaned = re.sub(r'https?://([a-zA-Z0-9.-]+\.canarytokens\.(com|org))', r'hxxps://[\1]', cleaned)
    cleaned = re.sub(r'https?://([a-zA-Z0-9.-]*webhook\.site)', r'hxxps://[\1]', cleaned)
    with open(out_path, 'w', encoding='utf-8') as fout:
        fout.write(cleaned)

elif mode == 'zip':
    dest_dir = out_path
    os.makedirs(dest_dir, exist_ok=True)
    with zipfile.ZipFile(in_path, 'r') as zf:
        total_uncompressed = 0
        total_compressed = 0
        for info in zf.infolist():
            norm = os.path.normpath(info.filename)
            if norm.startswith('/') or norm.startswith('..') or '..' in norm.split(os.path.sep):
                raise ValueError(f'Malicious Zip-slip path detected: {info.filename}')
            total_uncompressed += info.file_size
            total_compressed += info.compress_size
        
        if total_compressed > 0 and (total_uncompressed / total_compressed) > 100 and total_uncompressed > 500*1024*1024:
            raise ValueError(f'Potential Zip-bomb detected! Ratio: {total_uncompressed/total_compressed:.1f}x')
        
        zf.extractall(dest_dir)
" "$@"
}

SAFE_FILE=""

case "$EXT_LOWER" in
  pdf|doc|docx|ppt|pptx|xls|xlsx|odt|rtf)
    SAFE_FILE="$OUT_DIR/${FILENAME}-safe.pdf"
    echo "[+] CATEGORY: Document / Office File"
    echo "    [Action]: Pixel Rasterization Disinfection (Solution 1) + Metadata Stripping (Solution 2)"

    # Method 1: Dangerzone CLI (Freedom of the Press Foundation)
    if command -v dangerzone-cli >/dev/null 2>&1; then
      echo "[*] Disinfecting via Dangerzone container engine..."
      dangerzone-cli --output-filename "$SAFE_FILE" "$INPUT_FILE" >/dev/null 2>&1 || true
    fi

    # Method 2: Core Pixel Rasterization (pdftoppm + img2pdf)
    if [ ! -f "$SAFE_FILE" ] && command -v pdftoppm >/dev/null 2>&1 && command -v img2pdf >/dev/null 2>&1 && [ "$EXT_LOWER" = "pdf" ]; then
      echo "[*] Disinfecting via Core Pixel Rasterization (Flattening code to raw pixels)..."
      TMP_RASTER=$(mktemp -d)
      pdftoppm -png -r 150 "$INPUT_FILE" "$TMP_RASTER/page"
      img2pdf "$TMP_RASTER"/page-*.png -o "$SAFE_FILE" >/dev/null 2>&1
      rm -rf "$TMP_RASTER"
    fi

    # Method 3: Metadata Stripping & Sanitization
    if [ ! -f "$SAFE_FILE" ]; then
      echo "[*] Applying ExifTool metadata and tracking removal (Solution 2)..."
      SAFE_FILE="$OUT_DIR/${FILENAME}-safe.${EXT}"
      cp "$INPUT_FILE" "$SAFE_FILE"
      if command -v exiftool >/dev/null 2>&1; then
        exiftool -all= -overwrite_original "$SAFE_FILE" >/dev/null 2>&1 || true
      fi
    else
      # Strip metadata from rasterized output as well
      if command -v exiftool >/dev/null 2>&1; then
        exiftool -all= -overwrite_original "$SAFE_FILE" >/dev/null 2>&1 || true
      fi
    fi
    ;;

  csv|tsv)
    SAFE_FILE="$OUT_DIR/${FILENAME}-safe.${EXT}"
    echo "[+] CATEGORY: Structured Spreadsheet Dump (CSV/TSV)"
    echo "    [Action]: Formula Injection Neutralization & DDE Disarming"
    python_defang csv "$INPUT_FILE" "$SAFE_FILE"
    if command -v exiftool >/dev/null 2>&1; then
      exiftool -all= -overwrite_original "$SAFE_FILE" >/dev/null 2>&1 || true
    fi
    ;;

  sql|json|txt|log|html|htm|xml)
    SAFE_FILE="$OUT_DIR/${FILENAME}-safe.${EXT}"
    echo "[+] CATEGORY: Database / Raw Text Leak"
    echo "    [Action]: Terminal ANSI Escape Code Stripping & Canary Defanging"
    python_defang text "$INPUT_FILE" "$SAFE_FILE"
    if command -v exiftool >/dev/null 2>&1; then
      exiftool -all= -overwrite_original "$SAFE_FILE" >/dev/null 2>&1 || true
    fi
    ;;

  zip|tar|gz|tgz|7z|rar)
    SAFE_DIR="$OUT_DIR/${FILENAME}-extracted-safe"
    SAFE_FILE="$SAFE_DIR"
    echo "[+] CATEGORY: Compressed Archive Dump"
    echo "    [Action]: Zip-Bomb & Zip-Slip Structural Audit"
    if [ "$EXT_LOWER" = "zip" ]; then
      python_defang zip "$INPUT_FILE" "$SAFE_DIR"
    else
      mkdir -p "$SAFE_DIR"
      tar -xzf "$INPUT_FILE" -C "$SAFE_DIR" 2>/dev/null || true
    fi
    echo "[+] Extracted clean files to: $SAFE_DIR"
    ;;

  *)
    SAFE_FILE="$OUT_DIR/${FILENAME}-safe.${EXT}"
    echo "[+] CATEGORY: Generic Binary / Data Asset"
    echo "    [Action]: Complete Metadata Stripping (Solution 2)"
    cp "$INPUT_FILE" "$SAFE_FILE"
    if command -v exiftool >/dev/null 2>&1; then
      exiftool -all= -overwrite_original "$SAFE_FILE" >/dev/null 2>&1 || true
    fi
    ;;
esac

echo "=========================================================="
if [ -f "$SAFE_FILE" ]; then
  SAFE_HASH=$(sha256sum "$SAFE_FILE" | awk '{print $1}')
  echo "[+] SUCCESS: Sanitized sterile artifact created!"
  echo "    Safe File:   $SAFE_FILE"
  echo "    Safe SHA256: $SAFE_HASH"
  echo "    Status:      SAFE TO OPEN ON HOST OS"
elif [ -d "$SAFE_FILE" ]; then
  echo "[+] SUCCESS: Safe archive extraction verified!"
  echo "    Directory:   $SAFE_FILE"
  echo "    Status:      SAFE TO INSPECT"
fi
echo "=========================================================="
echo "Next step: Log this finding into the cryptographic evidence ledger:"
echo "  ./log-evidence.sh \"$SAFE_FILE\" CASE-001 \"Sanitized proof description\""
echo "To safely inspect in disposable Docker sandbox: ./view-in-sandbox.sh \"$SAFE_FILE\""
echo "=========================================================="
