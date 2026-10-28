#!/usr/bin/env python3
"""
DarkWarden — Automated Real-Time Download Sanitizer & Sentry
Department of Software Engineering, Daffodil International University (DIU)
Author: Md. Tanjim Islam (tanjimislam04)

Monitors Downloads and Tor Browser download directories in real-time.
Whenever an untrusted file finishes downloading:
  1. Identifies file type and executes ./sanitize-file.sh
  2. Quarantines the dangerous raw original to investigations/quarantine/
  3. Leaves only the clean *-safe.* file in Downloads
  4. Triggers a desktop notification alert via notify-send
"""

import os
import sys
import time
import shutil
import subprocess
from pathlib import Path

DARKWARDEN_DIR = Path(__file__).resolve().parent
QUARANTINE_DIR = DARKWARDEN_DIR / "investigations" / "quarantine"
LOG_FILE = DARKWARDEN_DIR / "investigations" / "sanitizer.log"

WATCH_DIRS = [
    Path.home() / "Downloads",
    Path.home() / ".local" / "share" / "torbrowser" / "tbb" / "x86_64" / "tor-browser" / "Browser" / "Downloads",
    DARKWARDEN_DIR / "investigations" / "downloads"
]

IGNORE_EXTENSIONS = {".part", ".crdownload", ".tmp", ".download", ".aria2"}
PROCESSED_FILES = set()

def send_alert(title: str, message: str, urgency: str = "critical"):
    """Sends a graphical desktop alert notification using notify-send."""
    try:
        subprocess.run([
            "notify-send",
            "-u", urgency,
            "-i", "security-high",
            "-a", "DarkWarden",
            title,
            message
        ], check=False)
    except Exception as e:
        print(f"[!] Notification error: {e}", file=sys.stderr)

def log_event(message: str):
    """Logs message to stdout and to sanitizer.log."""
    timestamp = time.strftime("[%Y-%m-%d %H:%M:%S]")
    line = f"{timestamp} {message}"
    print(line)
    try:
        QUARANTINE_DIR.mkdir(parents=True, exist_ok=True)
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(line + "\n")
    except Exception:
        pass

def is_file_ready(filepath: Path) -> bool:
    """Checks if the file is completely written (size unchanged for 1.5s)."""
    try:
        size1 = filepath.stat().st_size
        time.sleep(1.5)
        size2 = filepath.stat().st_size
        return size1 == size2 and size1 > 0
    except OSError:
        return False

def sanitize_and_alert(file_path: Path):
    """Executes sanitization, quarantines the hazardous raw file, and alerts user."""
    if file_path in PROCESSED_FILES:
        return

    # Check for temporary/incomplete downloads or safe files
    if file_path.suffix.lower() in IGNORE_EXTENSIONS:
        return
    if "-safe" in file_path.name or file_path.name.startswith("."):
        return

    log_event(f"[*] NEW UNTRUSTED DOWNLOAD DETECTED: {file_path.name}")
    
    # Ensure download has finished
    if not is_file_ready(file_path):
        return

    PROCESSED_FILES.add(file_path)
    
    # Run ./sanitize-file.sh
    sanitize_script = DARKWARDEN_DIR / "sanitize-file.sh"
    out_dir = file_path.parent
    
    try:
        cmd = [str(sanitize_script), str(file_path), str(out_dir)]
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, check=True)
        log_event(f"[+] Sanitizer completed for: {file_path.name}")
        
        # Run YARA IOC & Threat Intelligence Scan
        yara_matches = []
        try:
            from yara_scanner import scan_file as yara_scan, format_alert_summary
            yara_matches = yara_scan(file_path)
            if yara_matches:
                log_event(f"[🚨 YARA THREAT DETECTED]: {format_alert_summary(yara_matches)}")
        except Exception as ye:
            log_event(f"[!] YARA scan error: {ye}")

        # Determine the generated safe artifact
        safe_candidates = list(out_dir.glob(f"{file_path.stem}-safe.*")) + list(out_dir.glob(f"{file_path.stem}-extracted-safe"))
        safe_name = safe_candidates[0].name if safe_candidates else f"{file_path.stem}-safe.*"
        
        # Move raw dangerous original into quarantine folder
        QUARANTINE_DIR.mkdir(parents=True, exist_ok=True)
        quarantine_target = QUARANTINE_DIR / file_path.name
        # If target already exists, append timestamp
        if quarantine_target.exists():
            quarantine_target = QUARANTINE_DIR / f"{file_path.stem}_{int(time.time())}{file_path.suffix}"
        
        shutil.move(str(file_path), str(quarantine_target))
        log_event(f"[🔒] Hazardous original quarantined: -> {quarantine_target}")
        
        # Send Graphical Desktop Alert with YARA Threat Intelligence
        if yara_matches:
            top_threat = yara_matches[0]
            alert_title = f"🚨 YARA ALERT: {top_threat['category']} Detected!"
            alert_body = (
                f"⚠️ Threat: {top_threat['description']}\n"
                f"📁 Original: {file_path.name} [Quarantined to RAM]\n"
                f"✅ Sterile File: {safe_name}"
            )
            send_alert(alert_title, alert_body, urgency="critical")
        else:
            alert_title = "🛡️ DarkWarden — File Auto-Sanitized!"
            alert_body = (
                f"⚠️ Untrusted Download: {file_path.name}\n"
                f"✅ Disinfected Sterile File: {safe_name}\n"
                f"🔒 Original quarantined in RAM (Zero host risk)."
            )
            send_alert(alert_title, alert_body, urgency="critical")
        log_event(f"[✓] Alert dispatched for: {safe_name}")
        
    except subprocess.CalledProcessError as e:
        log_event(f"[-] ERROR: Sanitization failed for {file_path.name}:\n{e.output}")
        send_alert("⚠️ Sanitization Warning", f"Could not sanitize {file_path.name}. Check sanitizer.log", urgency="normal")
    except Exception as ex:
        log_event(f"[-] Unexpected error: {ex}")

def main():
    log_event("==========================================================")
    log_event("  Safe Dark Web Access — Real-Time Download Sanitizer Sentry")
    log_event("==========================================================")
    
    # Ensure watch directories exist
    active_watches = []
    for d in WATCH_DIRS:
        try:
            d.mkdir(parents=True, exist_ok=True)
            active_watches.append(d)
            log_event(f"[+] Sentry active on: {d}")
        except Exception as e:
            log_event(f"[!] Warning: Could not watch {d}: {e}")

    send_alert(
        "🛡️ DarkWarden Sentry Active",
        "Real-time download sanitizer is watching Downloads. All dark-web files will be auto-sanitized.",
        urgency="low"
    )

    log_event("[*] Sentry listening for incoming dark-web downloads (Ctrl+C to stop)...")

    # Polling loop (robust against all file systems and permissions)
    known_files = {}
    for d in active_watches:
        for f in d.glob("*"):
            if f.is_file():
                known_files[f] = f.stat().st_mtime

    while True:
        try:
            time.sleep(1.0)
            for d in active_watches:
                if not d.exists():
                    continue
                current_files = list(d.glob("*"))
                for f in current_files:
                    if f.is_file() and f not in known_files:
                        known_files[f] = f.stat().st_mtime
                        sanitize_and_alert(f)
                    elif f.is_file():
                        # If file was modified recently and is not ignored
                        mtime = f.stat().st_mtime
                        if mtime > known_files.get(f, 0) and f.suffix.lower() not in IGNORE_EXTENSIONS:
                            known_files[f] = mtime
                            # Might have finished a rename from .part to final
                            if f not in PROCESSED_FILES and "-safe" not in f.name:
                                sanitize_and_alert(f)
        except KeyboardInterrupt:
            log_event("[-] Sentry stopped by user.")
            break
        except Exception as e:
            log_event(f"[!] Sentry loop warning: {e}")
            time.sleep(2.0)

if __name__ == "__main__":
    main()
