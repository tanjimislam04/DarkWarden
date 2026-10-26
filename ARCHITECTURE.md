# Project Dark Hunt — End-to-End System Architecture

**Classification:** Lawful Cyber Exposure & Dark Web Threat Intelligence  
**Target:** 45 Key Point Installations (KPIs) of Bangladesh  
**Department:** Department of Software Engineering · Daffodil International University (DIU)  
**Lead Author & Architect:** Md. Tanjim Islam (Tanjim_islam)  
**Project Team:** Team NullX (Rahat Sahriar Rafi, Md. Tanjim Islam, MD RAKIB HASAN APON)  
**Advisory / Sponsor:** Tanvir Hassan Zoha  

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
 ║   │  │ • Drops Linux kernel capabilities (--caps.drop=all, --noroot)    │  │     ║
 ║   │  │ • Maps throwaway RAM-backed /tmp and /dev devices                │  │     ║
 ║   │  │  ┌────────────────────────────────────────────────────────────┐  │  │     ║
 ║   │  │  │ Inner Wall: Mozilla Content Sandbox (Level 3)              │  │  │     ║
 ║   │  │  │ • Isolated child rendering processes with Seccomp-BPF      │  │  │     ║
 ║   │  │  │ • Security Level: "Safest" (JavaScript disabled globally)  │  │  │     ║
 ║   │  │  └────────────────────────────────────────────────────────────┘  │  │     ║
 ║   │  └──────────────────────────────────────────────────────────────────┘  │     ║
 ║   └────────────────────────────────┬───────────────────────────────────────┘     ║
 ║                                    │                                             ║
 ║                                    ▼                                             ║
 ║   ┌────────────────────────────────────────────────────────────────────────┐     ║
 ║   │ LAYER 5: PAYLOAD DISINFECTION & SENTRY (Auto-Sanitizer Daemon)         │     ║
 ║   │ • Real-Time Inotify Download Watcher (auto_sanitizer.py)               │     ║
 ║   │ • Dangerzone Pixel Flattening (Destroys macros, scripts, font bugs)   │     ║
 ║   │ • CSV Formula Defanging (=cmd|... neutralized with ')                  │     ║
 ║   │ • ExifTool Metadata & Tracker Stripping                                │     ║
 ║   │ • Dangerous original auto-moved to investigations/quarantine/          │     ║
 ║   │ • Disposable Zero-Network Docker Viewer (view-in-sandbox.sh)           │     ║
 ║   └────────────────────────────────┬───────────────────────────────────────┘     ║
 ║                                    │                                             ║
 ║                                    ▼                                             ║
 ║   ┌────────────────────────────────────────────────────────────────────────┐     ║
 ║   │ LAYER 6: EVIDENCE INTEGRITY & CHAIN OF CUSTODY                         │     ║
 ║   │ SHA-256 Cryptographic Hash Generation + Immutable CSV Audit Ledger     │     ║
 ║   │ logs artifact name, hash, timestamp, and investigator KPI tag          │     ║
 ║   └────────────────────────────────────────────────────────────────────────┘     ║
 ║                                                                                  ║
 ╚══════════════════════════════════════════════════════════════════════════════════╝
```

---

## 2. Directory Layout

```text
~/robin/
├── ARCHITECTURE.md                  ← System blueprint & defense-in-depth model
├── README.md                        ← Main operational & architectural guide
├── SETUP.md                         ← Setup, prerequisites & installation reference
├── LICENSE                          ← MIT License
├── auto_sanitizer.py                ← Real-time inotify download sentry daemon
├── watch-and-sanitize.sh            ← Controller for auto_sanitizer.py
├── sanitize-file.sh                 ← Universal Anti-Malware File Sanitizer (4 solutions)
├── view-in-sandbox.sh               ← Disposable Zero-Network Docker Viewer
├── run-tor-browser.sh               ← Nested double-sandbox Tor launcher (Firejail)
├── stop-tor-browser.sh              ← Clean Tor browser & sentry shutdown
├── install-firejail.sh              ← Firejail sandbox automated installer
├── install-dangerzone.sh            ← Dangerzone anti-malware installer
├── log-evidence.sh                  ← Cryptographic SHA-256 evidence ledger recorder
├── package-toolkit.sh               ← Clean team distribution bundler
├── investigations/                  ← Monitored folder, evidence & quarantine
│   ├── downloads/                   ← Monitored ingestion folder
│   ├── evidence/                    ← SHA-256 verified artifact repository
│   ├── evidence_ledger.csv          ← Immutable audit ledger
│   └── quarantine/                  ← Isolated storage for hazardous originals
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
cd ~/robin
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
./log-evidence.sh threat_actor_dump-safe.pdf KPI-018 "Verified threat actor breach claim"

# ==============================================================================
# 5. Clean Session Teardown
# ==============================================================================
./stop-tor-browser.sh
./vpn/project-vpn-off.sh
```
