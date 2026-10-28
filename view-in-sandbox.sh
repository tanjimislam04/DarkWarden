#!/usr/bin/env bash
# DarkWarden — Disposable Docker Sandbox Viewer
# Department of Software Engineering, Daffodil International University (DIU)
# Author: Md. Tanjim Islam (tanjimislam04)
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <untrusted_file_path>"
  echo "Example:"
  echo "  $0 investigations/downloads/suspicious_leak.pdf"
  echo "  $0 investigations/downloads/breach_dump.sql"
  exit 1
fi

TARGET_FILE="$1"

if [ ! -f "$TARGET_FILE" ] && [ ! -d "$TARGET_FILE" ]; then
  echo "[-] ERROR: File or directory not found: $TARGET_FILE"
  exit 1
fi

ABS_PATH=$(realpath "$TARGET_FILE")
BASENAME=$(basename "$ABS_PATH")

echo "=========================================================="
echo "  DarkWarden — Disposable Sandbox Viewer"
echo "=========================================================="
echo "[*] Inspecting: $BASENAME"
echo "[*] Absolute:   $ABS_PATH"
echo "[*] Isolation:  Ephemeral Zero-Network Docker Container"
echo "    [i] Network:     DISABLED (--network none)"
echo "    [i] Filesystem:  READ-ONLY mount (/sample:ro)"
echo "    [i] Permissions: ALL Linux capabilities dropped (--cap-drop=ALL)"
echo "    [i] Lifecycle:   Instant Self-Destruct upon exit (--rm)"
echo "=========================================================="

DOCKER=(docker)
if ! docker info >/dev/null 2>&1; then
  if command -v sudo >/dev/null; then
    DOCKER=(sudo docker)
  fi
fi

# Run disposable container to inspect the untrusted file
"${DOCKER[@]}" run --rm -it \
  --network none \
  --read-only \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  -v "$ABS_PATH:/sample:ro" \
  python:3.12-slim \
  python3 -c "
import os, sys

path = '/sample'
is_dir = os.path.isdir(path)

print('=== 1. FILE METADATA ===')
stat = os.stat(path)
print(f'Target:       $BASENAME')
print(f'Type:         {\"Directory\" if is_dir else \"Regular File\"}')
print(f'Size:         {stat.st_size:,} bytes')
print(f'Permissions:  {oct(stat.st_mode)[-3:]}')

if not is_dir:
    print('\n=== 2. RAW HEX HEADER (First 128 Bytes) ===')
    with open(path, 'rb') as f:
        data = f.read(128)
    for i in range(0, len(data), 16):
        chunk = data[i:i+16]
        hex_str = ' '.join(f'{b:02x}' for b in chunk)
        ascii_str = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
        print(f'{i:04x}  {hex_str:<48}  |{ascii_str}|')

    print('\n=== 3. SAFE TEXT PREVIEW (First 50 Lines) ===')
    try:
        with open(path, 'r', encoding='utf-8', errors='replace') as f:
            for idx, line in enumerate(f):
                if idx >= 50:
                    print('... [Preview truncated after 50 lines] ...')
                    break
                # Replace potential terminal escape codes
                clean_line = line.replace('\x1b', '[ESC]').rstrip('\r\n')
                print(f'{idx+1:02d}: {clean_line}')
    except Exception as e:
        print(f'Could not render as text: {e}')
else:
    print('\n=== 2. DIRECTORY STRUCTURE ===')
    for root, dirs, files in os.walk(path):
        level = root.replace(path, '').count(os.sep)
        indent = ' ' * 4 * level
        print(f'{indent}{os.path.basename(root)}/')
        subindent = ' ' * 4 * (level + 1)
        for f in files[:30]:
            print(f'{subindent}{f}')
        if len(files) > 30:
            print(f'{subindent}... and {len(files)-30} more files ...')

print('\n==========================================================')
print('[+] Inspection complete. Container self-destructing now.')
print('==========================================================')
"

echo "[+] Disposable sandbox container destroyed. Host OS 100% untouched."
