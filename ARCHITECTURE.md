# 🛡️ DarkWarden — Safe Dark Web Access & Host Defense Architecture

**Classification:** Lawful Cyber Exposure & Dark Web Threat Intelligence  
**Scope:** Host System Protection, Tor Anonymity, Anti-Forensics & Untrusted Payload Disinfection  
**Department:** Department of Software Engineering · Daffodil International University (DIU)  
**Lead Author & Architect:** Md. Tanjim Islam (Tanjim_islam)  

---

## 1. Architectural Blueprint (6-Layer Defense-in-Depth Shield)

```text
 ╔══════════════════════════════════════════════════════════════════════════════════╗
 ║                                                                                  ║
 ║   [ Internet Service Provider (ISP) / Public Uplink ]                            ║
 ║            │                                                                     ║
 ║            ▼                                                                     ║
 ║   ┌────────────────────────────────────────────────────────────────────────┐     ║
 ║   │ LAYER 1: HARDWARE GATEWAY / HOST-LEVEL STEALTH ISOLATION               │     ║
 ║   │ Dual-Mode: MikroTik Lab Gateway (nx-lab-gw) OR Host LAN Stealth & Drop │     ║
 ║   │ Prevents local network cross-contamination & MAC address disclosure    │     ║
 ║   └────────────────────────────────┬───────────────────────────────────────┘     ║
 ║                                    │                                             ║
 ║                                    ▼                                             ║
 ║   ┌────────────────────────────────────────────────────────────────────────┐     ║
 ║   │ LAYER 2: ENCRYPTED NETWORK TUNNEL & AIRTIGHT EGRESS KILLSWITCH         │     ║
 ║   │ Proton VPN (Encrypted WireGuard) + Linux Host UFW Firewall Drop Rules   │     ║
 ║   │ Physical uplink pinned strictly to VPN IP; zero cleartext leak         │     ║
 ║   └────────────────────────────────┬───────────────────────────────────────┘     ║
 ║                                    │                                             ║
 ║                                    ▼                                             ║
 ║   ┌────────────────────────────────────────────────────────────────────────┐     ║
 ║   │ LAYER 3: TOR TRAFFIC OBFUSCATION & PLUGGABLE TRANSPORTS                │     ║
 ║   │ obfs4proxy Bridge Routing · Anti-DPI Packet Scrambling · SOCKS5 Proxy  │     ║
 ║   │ Scrambles Tor handshakes into high-entropy random byte streams         │     ║
 ║   └────────────────────────────────┬───────────────────────────────────────┘     ║
 ║                                    │                                             ║
 ║                                    ▼                                             ║
 ║   ┌────────────────────────────────────────────────────────────────────────┐     ║
 ║   │ LAYER 4: NESTED DOUBLE-SANDBOX TOR BROWSER                             │     ║
 ║   │  ┌──────────────────────────────────────────────────────────────────┐  │     ║
 ║   │  │ Outer Wall: Firejail Sandbox                                     │  │     ║
 ║   │  │ • Conceals ~/.ssh, Desktop, bash history, credentials            │  │     ║
 ║   │  │ • D-Bus & IPC Isolation: --nodbus, --ipc-namespace, --nosound   │  │     ║
 ║   │  │ • Drops Linux kernel capabilities (--caps.drop=all, --noroot)    │  │     ║
 ║   │  │ • Maps throwaway RAM-backed /tmp and /dev devices                │  │     ║
 ║   │  │  ┌────────────────────────────────────────────────────────────┐  │  │     ║
 ║   │  │  │ Inner Wall: Mozilla Content Sandbox (Level 3)              │  │  │     ║
 ║   │  │  │ • Isolated child rendering processes with Seccomp-BPF      │  │  │     ║
 ║   │  │  │ • Security Level: "Safest" (JavaScript disabled globally)  │  │  │     ║
 ║   │  │  │ • Clipboard Isolation: Host clipboard snooping BLOCKED     │  │  │     ║
 ║   │  │  └────────────────────────────────────────────────────────────┘  │  │     ║
 ║   │  └──────────────────────────────────────────────────────────────────┘  │     ║
 ║   └────────────────────────────────┬───────────────────────────────────────┘     ║
 ║                                    │                                             ║
 ║                                    ▼                                             ║
 ║   ┌────────────────────────────────────────────────────────────────────────┐     ║
 ║   │ LAYER 5: PAYLOAD DISINFECTION & SENTRY (Auto-Sanitizer Daemon)         │     ║
 ║   │ • Volatile RAM Storage (setup-ramdisk.sh: zero physical disk writes)   │     ║
 ║   │ • Real-Time Inotify Download Watcher (auto_sanitizer.py)               │     ║
 ║   │ • YARA Threat Intelligence Triage (Lumma, RedLine, LockBit, Follina)   │     ║
 ║   │ • Dangerzone Pixel Flattening (Destroys macros, scripts, font bugs)   │     ║
 ║   │ • CSV Formula Defanging (=cmd|... neutralized with ')                  │     ║
 ║   │ • ExifTool Metadata & Tracker Stripping                                │     ║
 ║   │ • Dangerous original auto-quarantined to volatile RAM (tmpfs)          │     ║
 ║   │ • Disposable Zero-Network Docker Viewer (view-in-sandbox.sh)           │     ║
 ║   └────────────────────────────────┬───────────────────────────────────────┘     ║
 ║                                    │                                             ║
 ║                                    ▼                                             ║
 ║   ┌────────────────────────────────────────────────────────────────────────┐     ║
 ║   │ LAYER 6: EVIDENCE INTEGRITY & CHAIN OF CUSTODY                         │     ║
 ║   │ • SHA-256 Cryptographic Hash Generation + Immutable CSV Audit Ledger   │     ║
 ║   │ • Military-Grade 4096-bit GPG Detached Digital Signing (Non-Repudiation)│    ║
 ║   │ • Live Audit Verification Tool (verify-evidence.sh)                    │     ║
 ║   └────────────────────────────────┬───────────────────────────────────────┘     ║
 ║                                                                                  ║
 ╚══════════════════════════════════════════════════════════════════════════════════╝
```

---

## 2. Directory Layout

```text
~/darkwarden/
├── ARCHITECTURE.md                  ← System blueprint & defense-in-depth model
├── README.md                        ← Main operational & architectural guide
├── SETUP.md                         ← Setup, prerequisites & installation reference
├── LICENSE                          ← MIT License
├── setup-ramdisk.sh                 ← Volatile RAM-backed Anti-Forensics storage controller
├── auto_sanitizer.py                ← Real-time inotify download sentry daemon
├── yara_scanner.py                  ← YARA Threat Intelligence & IOC detection engine
├── yara_rules/                      ← Dark web threat ruleset (Infostealers, Ransomware, Exploits)
├── watch-and-sanitize.sh            ← Controller for auto_sanitizer.py
├── sanitize-file.sh                 ← Universal Anti-Malware File Sanitizer (4 solutions)
├── view-in-sandbox.sh               ← Disposable Zero-Network Docker Viewer
├── run-tor-browser.sh               ← Nested double-sandbox Tor launcher (Firejail)
├── stop-tor-browser.sh              ← Clean Tor browser & sentry shutdown
├── apply-clipboard-hardening.sh     ← Tor Browser user.js clipboard & anti-snooping hardener
├── install-firejail.sh              ← Firejail sandbox automated installer
├── install-dangerzone.sh            ← Dangerzone anti-malware installer
├── setup-gpg-key.sh                 ← Investigator GPG 4096-bit key generator & exporter
├── log-evidence.sh                  ← Cryptographic SHA-256 & GPG evidence ledger recorder
├── verify-evidence.sh               ← Tamper-evident GPG signature & SHA-256 audit tool
├── package-toolkit.sh               ← Clean team distribution bundler
├── investigations/                  ← Monitored folder, evidence & quarantine
│   ├── downloads/                   ← Volatile RAM-backed ingestion folder (tmpfs)
│   ├── quarantine/                  ← Volatile RAM-backed isolated storage (tmpfs)
│   ├── evidence/                    ← Persistent SHA-256 & GPG verified artifact repository
│   │   ├── evidence_ledger.csv      ← Immutable audit ledger
│   │   ├── evidence_ledger.csv.asc  ← GPG Detached Armored Digital Signature
│   │   └── investigator_public_key.asc← Public GPG key for court / evaluator verification
│   └── evidence_ledger.csv          ← Symlink to evidence/evidence_ledger.csv
└── vpn/
    ├── project-vpn-on.sh            ← Starts VPN + pins airtight UFW killswitch
    ├── project-vpn-off.sh           ← Cleanly restores normal network & removes killswitch
    ├── verify-killswitch.sh         ← Live killswitch leak & security audit tool
    ├── killswitch-off.sh            ← Emergency network unlock utility
    ├── check-bridges.sh             ← Bridge reachability verification tool
    └── torrc                        ← Active obfs4 bridges configuration
```

---

## 3. Standard Operational Flow (SOP)

```bash
# ==============================================================================
# 1. Start Encrypted Session & Lock Killswitch (Layer 2)
# ==============================================================================
cd ~/darkwarden
./vpn/project-vpn-on.sh
./vpn/verify-killswitch.sh   # Confirms physical leak is 100% blocked
./vpn/check-bridges.sh       # Tests TCP reachability of configured obfs4 bridges

# ==============================================================================
# 2. Launch Nested Double-Sandbox Tor Browser & Auto-Sentry (Layers 4 & 5)
# ==============================================================================
./run-tor-browser.sh
# Firejail outer sandbox wraps Tor Browser; auto_sanitizer.py monitors downloads.

# ==============================================================================
# 3. Disinfect Downloaded Payloads (Layer 5)
# ==============================================================================
# Automatic: auto_sanitizer.py quarantines dangerous originals and runs defanging.
# Manual (if needed):
./sanitize-file.sh ~/Downloads/threat_actor_dump.xlsx
./view-in-sandbox.sh ~/investigations/quarantine/sample.pdf

# ==============================================================================
# 4. Record Evidence Integrity (Layer 6)
# ==============================================================================
./log-evidence.sh threat_actor_dump-safe.pdf CASE-001 "Verified dark web breach claim"

# ==============================================================================
# 5. Clean Session Teardown
# ==============================================================================
./stop-tor-browser.sh
./vpn/project-vpn-off.sh
```

---

## 4. Ethical Rules of Engagement (ROE) & Operational Constraints

| Defense Layer | Restriction Enforced | Defensive Rationale & Legal Safeguard |
|---|---|---|
| **Layer 1 & Layer 2: VPN Killswitch & IPv6 Blackhole** | **No Raw Egress / Strict Anonymity** | Enforces complete isolation from ISP surveillance and prevents accidental clearnet exposure of the investigator's true IP. |
| **Layer 3: RAM-Backed `tmpfs` Anti-Forensics** | **Zero Persistent Contraband / Ephemeral Staging** | Untrusted payloads reside exclusively in volatile memory (`/dev/shm`), ensuring illegal or contaminated material is irrevocably wiped upon session termination. |
| **Layer 4: Hardened Firejail & D-Bus/Clipboard Isolation** | **No Host Compromise / Passive Observation Only** | D-Bus, audio/video devices, and host IPC are blocked; hostile scripts cannot compromise the host system, steal host clipboard data, or log keystrokes. |
| **Layer 5: Automated YARA Triage & Dangerzone Disinfection** | **Mandatory Payload Neutralization & No Malware Propagation** | Dangerous active content (macros, embedded exploits, PDF actions) is converted into pixel-rendered sanitized PDFs. Live malware is never executed on the host. |
| **Layer 6: GPG 4096-Bit Non-Repudiation Evidence Ledger** | **Immutable Chain of Custody & Court-Admissibility** | SHA-256 digests and detached GPG signatures guarantee forensic evidence cannot be manipulated or fabricated, meeting judicial integrity standards (FRE 902(14)). |

