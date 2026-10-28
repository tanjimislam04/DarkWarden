#!/usr/bin/env python3
"""
Safe Dark Web Access — Automated YARA IOC & Threat Intelligence Scanner
Department of Software Engineering, Daffodil International University (DIU)
Author: Md. Tanjim Islam (tanjimislam04)

Scans files and extracted archives against the Safe Dark Web Threat Intelligence ruleset.
Detects Infostealer logs (Lumma, RedLine, Vidar), Ransomware extortion notes,
weaponized document exploits (Follina, Equation Editor, DDE), and credential leaks.
"""

import sys
import os
import yara
from pathlib import Path

RULES_DIR = Path(__file__).resolve().parent / "yara_rules"
INDEX_FILE = RULES_DIR / "index.yar"

_COMPILED_RULES = None

def get_compiled_rules():
    """Compiles and caches the master YARA rules index."""
    global _COMPILED_RULES
    if _COMPILED_RULES is None:
        if not INDEX_FILE.exists():
            raise FileNotFoundError(f"YARA master index not found at: {INDEX_FILE}")
        _COMPILED_RULES = yara.compile(str(INDEX_FILE))
    return _COMPILED_RULES

def scan_file(file_path):
    """
    Scans a single file against the YARA ruleset.
    Returns a list of match dictionaries:
    [
        {
            "rule": "LummaStealer_LogFormat",
            "category": "Infostealer",
            "severity": "HIGH",
            "description": "Lumma Stealer C2 extracted credentials...",
            "strings": [...]
        }
    ]
    """
    path = Path(file_path)
    if not path.is_file():
        return []

    try:
        rules = get_compiled_rules()
    except Exception as e:
        print(f"[-] YARA compilation error: {e}", file=sys.stderr)
        return []

    try:
        # For very large files, avoid reading whole file into memory if over 50MB
        size = path.stat().st_size
        if size > 50 * 1024 * 1024:
            with open(path, "rb") as f:
                data = f.read(25 * 1024 * 1024)
            matches = rules.match(data=data)
        else:
            matches = rules.match(str(path))
    except Exception as e:
        print(f"[-] YARA scan error on {path.name}: {e}", file=sys.stderr)
        return []

    results = []
    for m in matches:
        meta = m.meta or {}
        results.append({
            "rule": m.rule,
            "category": meta.get("threat_category", "Unknown"),
            "severity": meta.get("severity", "MEDIUM"),
            "description": meta.get("description", m.rule),
            "tags": m.tags,
            "matched_strings": [str(s.identifier) for s in m.strings[:5]] if hasattr(m, "strings") else []
        })

    return results

def format_alert_summary(matches):
    """Generates a concise notification string from matches."""
    if not matches:
        return ""
    # Sort by severity priority: CRITICAL > HIGH > MEDIUM > LOW
    severity_weights = {"CRITICAL": 4, "HIGH": 3, "MEDIUM": 2, "LOW": 1}
    sorted_matches = sorted(matches, key=lambda x: severity_weights.get(x["severity"], 0), reverse=True)
    top_match = sorted_matches[0]
    
    rule_desc = top_match["description"]
    category = top_match["category"]
    severity = top_match["severity"]
    
    return f"[{severity}] {category}: {rule_desc}"

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <file_or_directory>")
        sys.exit(1)

    target = Path(sys.argv[1])
    if not target.exists():
        print(f"[-] Target not found: {target}")
        sys.exit(1)

    files_to_scan = [target] if target.is_file() else list(target.rglob("*"))

    total_scanned = 0
    threats_found = 0

    print("==========================================================")
    print("  Safe Dark Web Access — YARA Threat Intelligence Triage")
    print("==========================================================")

    for f in files_to_scan:
        if not f.is_file():
            continue
        total_scanned += 1
        matches = scan_file(f)
        if matches:
            threats_found += 1
            print(f"\n[🚨] THREAT DETECTED in: {f.name}")
            for m in matches:
                color = "CRITICAL" if m['severity'] == "CRITICAL" else "WARNING"
                print(f"    • Severity:    {m['severity']}")
                print(f"    • Category:    {m['category']}")
                print(f"    • Rule Name:   {m['rule']}")
                print(f"    • Description: {m['description']}")
            print("----------------------------------------------------------")

    print(f"\n[i] Scan Complete: {total_scanned} files inspected, {threats_found} threat matches.")
    if threats_found == 0:
        print("[✓] All inspected files are CLEAN (No YARA threat matches).")
    print("==========================================================")

if __name__ == "__main__":
    main()
