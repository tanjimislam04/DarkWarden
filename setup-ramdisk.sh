#!/usr/bin/env bash
# Project Dark Hunt — Volatile RAM-backed Anti-Forensics Storage Controller
# Team NullX · Department of Software Engineering, DIU
# Author: Md. Tanjim Islam & Team NullX
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUARANTINE_DIR="$SCRIPT_DIR/investigations/quarantine"
DOWNLOADS_DIR="$SCRIPT_DIR/investigations/downloads"
SHM_QUARANTINE="/dev/shm/darkhunt-quarantine-${USER}"
SHM_DOWNLOADS="/dev/shm/darkhunt-downloads-${USER}"

is_tmpfs() {
  local target="$1"
  if [ -d "$target" ] && mountpoint -q "$target" 2>/dev/null; then
    local fstype
    fstype=$(findmnt -n -o FSTYPE "$target" 2>/dev/null || echo "")
    [ "$fstype" = "tmpfs" ]
  elif [ -L "$target" ]; then
    local dest
    dest=$(readlink -f "$target")
    [[ "$dest" == /dev/shm/* ]]
  else
    return 1
  fi
}

mount_ramdisk() {
  echo "=========================================================="
  echo "  Project Dark Hunt — Activating Volatile RAM Storage"
  echo "=========================================================="

  mkdir -p "$QUARANTINE_DIR" "$DOWNLOADS_DIR"

  if is_tmpfs "$QUARANTINE_DIR"; then
    echo "[✓] Volatile RAM storage is ALREADY ACTIVE on $QUARANTINE_DIR."
    return 0
  fi

  # Attempt 1: Native kernel tmpfs mount (if root / sudo available)
  if [ "$(id -u)" -eq 0 ]; then
    echo "[*] Mounting native kernel tmpfs (2GB, noexec, nosuid, nodev)..."
    mount -t tmpfs -o size=2G,mode=0700,noexec,nosuid,nodev tmpfs "$QUARANTINE_DIR"
    mount -t tmpfs -o size=2G,mode=0700,noexec,nosuid,nodev tmpfs "$DOWNLOADS_DIR"
    
    local real_user="${SUDO_USER:-$USER}"
    chown -R "$real_user:$real_user" "$QUARANTINE_DIR" "$DOWNLOADS_DIR"
    echo "[✓] Native kernel tmpfs mounted successfully."
  else
    # Attempt 2: User-space POSIX RAM tmpfs via /dev/shm (zero-sudo required)
    echo "[*] Setting up user-space volatile RAM storage via /dev/shm..."
    mkdir -p "$SHM_QUARANTINE" "$SHM_DOWNLOADS"
    chmod 0700 "$SHM_QUARANTINE" "$SHM_DOWNLOADS"

    # Safely swap persistent folder with RAM symlink
    if [ ! -L "$QUARANTINE_DIR" ]; then
      if [ -d "$QUARANTINE_DIR" ] && [ "$(ls -A "$QUARANTINE_DIR" 2>/dev/null)" ]; then
        mv "$QUARANTINE_DIR"/* "$SHM_QUARANTINE"/ 2>/dev/null || true
      fi
      rm -rf "$QUARANTINE_DIR"
      ln -s "$SHM_QUARANTINE" "$QUARANTINE_DIR"
    fi

    if [ ! -L "$DOWNLOADS_DIR" ]; then
      if [ -d "$DOWNLOADS_DIR" ] && [ "$(ls -A "$DOWNLOADS_DIR" 2>/dev/null)" ]; then
        mv "$DOWNLOADS_DIR"/* "$SHM_DOWNLOADS"/ 2>/dev/null || true
      fi
      rm -rf "$DOWNLOADS_DIR"
      ln -s "$SHM_DOWNLOADS" "$DOWNLOADS_DIR"
    fi
    echo "[✓] User-space RAM storage (/dev/shm) activated successfully."
  fi

  echo "----------------------------------------------------------"
  echo "[+] Ingestion: $DOWNLOADS_DIR [VOLATILE RAM]"
  echo "[+] Quarantine: $QUARANTINE_DIR [VOLATILE RAM]"
  echo "[+] Security: 100% Zero physical SSD/HDD sector writes."
  echo "    Hazardous payloads vanish from memory upon power-off or session stop."
  echo "=========================================================="
}

wipe_ramdisk() {
  echo "[*] Securely shredding volatile quarantine artifacts..."
  if [ -d "$QUARANTINE_DIR" ]; then
    find -L "$QUARANTINE_DIR" -type f -exec shred -u -z -n 1 {} + 2>/dev/null || true
    rm -rf "$QUARANTINE_DIR"/* 2>/dev/null || true
  fi
  if [ -d "$DOWNLOADS_DIR" ]; then
    find -L "$DOWNLOADS_DIR" -type f -exec shred -u -z -n 1 {} + 2>/dev/null || true
    rm -rf "$DOWNLOADS_DIR"/* 2>/dev/null || true
  fi
  echo "[✓] Volatile RAM storage wiped clean."
}

unmount_ramdisk() {
  echo "=========================================================="
  echo "  Project Dark Hunt — Teardown Volatile RAM Storage"
  echo "=========================================================="
  wipe_ramdisk

  # Unmount native tmpfs if mounted
  if mountpoint -q "$QUARANTINE_DIR" 2>/dev/null; then
    if [ "$(id -u)" -eq 0 ]; then
      umount "$QUARANTINE_DIR" 2>/dev/null || true
      umount "$DOWNLOADS_DIR" 2>/dev/null || true
    else
      sudo umount "$QUARANTINE_DIR" 2>/dev/null || true
      sudo umount "$DOWNLOADS_DIR" 2>/dev/null || true
    fi
  fi

  # Remove user-space symlinks and restore standard directories
  if [ -L "$QUARANTINE_DIR" ]; then
    rm -f "$QUARANTINE_DIR"
    mkdir -p "$QUARANTINE_DIR"
    chmod 0700 "$QUARANTINE_DIR"
  fi
  if [ -L "$DOWNLOADS_DIR" ]; then
    rm -f "$DOWNLOADS_DIR"
    mkdir -p "$DOWNLOADS_DIR"
    chmod 0700 "$DOWNLOADS_DIR"
  fi

  rm -rf "$SHM_QUARANTINE" "$SHM_DOWNLOADS" 2>/dev/null || true

  echo "[✓] Volatile storage unmounted and cleaned up."
  echo "=========================================================="
}

status_ramdisk() {
  echo "=========================================================="
  echo "  Project Dark Hunt — RAM Storage Status"
  echo "=========================================================="
  if is_tmpfs "$QUARANTINE_DIR"; then
    echo "[✓] Quarantine Status: ACTIVE IN RAM (tmpfs)"
    if [ -L "$QUARANTINE_DIR" ]; then
      echo "    Type: User-Space POSIX tmpfs -> $(readlink -f "$QUARANTINE_DIR")"
    else
      echo "    Type: Kernel Mount -> $(findmnt -n -o SOURCE,FSTYPE,OPTIONS "$QUARANTINE_DIR" 2>/dev/null || echo "tmpfs")"
    fi
  else
    echo "[-] Quarantine Status: PERSISTENT DISK (Not in RAM)"
  fi

  if is_tmpfs "$DOWNLOADS_DIR"; then
    echo "[✓] Downloads Status:  ACTIVE IN RAM (tmpfs)"
  else
    echo "[-] Downloads Status:  PERSISTENT DISK (Not in RAM)"
  fi
  echo "=========================================================="
}

case "${1:-status}" in
  mount|start)
    mount_ramdisk
    ;;
  unmount|stop)
    unmount_ramdisk
    ;;
  wipe)
    wipe_ramdisk
    ;;
  status)
    status_ramdisk
    ;;
  *)
    echo "Usage: $0 {mount|unmount|wipe|status}"
    exit 1
    ;;
esac
