# 🛡️ DarkWarden — Safe Dark Web Access, Process Sandboxing & File Disinfection Architecture

<div align="center">

![Platform](https://img.shields.io/badge/Platform-Linux%20(Kali%20%2F%20Debian%20%2F%20Ubuntu)-orange?style=for-the-badge&logo=linux)
![Security Architecture](https://img.shields.io/badge/Defense-6--Layer%20Shield-success?style=for-the-badge&logo=shield)
![Tor](https://img.shields.io/badge/Tor-obfs4%20Obfuscation-7D4698?style=for-the-badge&logo=tor-browser&logoColor=white)
![Sandbox](https://img.shields.io/badge/Sandbox-Firejail%20Double%20Layer-red?style=for-the-badge)
![Disinfection](https://img.shields.io/badge/Disinfection-Universal%20Defanger-blue?style=for-the-badge)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

**Department of Software Engineering · Daffodil International University (DIU)**  
*Lead Author & Architect:* **Md. Tanjim Islam (Tanjim_islam)**  

[Access Architecture](#-1-how-to-safely-access-the-dark-web-traffic-routing--identity-obfuscation) •
[Tor Mechanics](#-2-tor-routing-obfs4-obfuscation--socks5-architecture) •
[Disinfection Suite](#-3-multi-tier-payload-disinfection-suite-the-4-sanitizer-solutions) •
[Setup & Installation](#-4-step-by-step-installation--prerequisites) •
[Daily SOP](#-5-daily-operational-workflow-standard-operating-procedure) •
[Evidence Ledger](#-6-cryptographic-evidence-integrity-chain-of-custody)

---

</div>

## 📑 Table of Contents
- [1. How to Safely Access the Dark Web (Traffic Routing & Identity Obfuscation)](#-1-how-to-safely-access-the-dark-web-traffic-routing--identity-obfuscation)
  - [1.1 Threat Model of Direct Dark Web Browsing](#11-threat-model-of-direct-dark-web-browsing)
  - [1.2 The 6-Layer Defense-in-Depth Shield Architecture](#12-the-6-layer-defense-in-depth-shield-architecture)
  - [1.2.1 Layer 1: Dual-Mode Network Gateway (Hardware Router vs. Host Stealth Mode)](#121-layer-1-dual-mode-network-gateway-hardware-router-vs-host-stealth-mode)
  - [1.3 Nested Double-Sandbox Manual Verification (Layer 4 Deep Dive)](#13-nested-double-sandbox-manual-verification-layer-4-deep-dive)
- [2. Tor Routing, obfs4 Obfuscation & SOCKS5 Architecture](#-2-tor-routing-obfs4-obfuscation--socks5-architecture)
  - [2.1 SOCKS5 Proxy Architecture (`127.0.0.1:9050` / `9150`)](#21-socks5-proxy-architecture-1270019050--9150)
  - [2.2 Deep Packet Inspection (DPI) Resistance via obfs4 Pluggable Transports](#22-deep-packet-inspection-dpi-resistance-via-obfs4-pluggable-transports)
  - [2.3 Circumventing Dark Web Anti-Scraping & Latency Bottlenecks](#23-circumventing-dark-web-anti-scraping--latency-bottlenecks)
  - [2.4 5-Point Likert Credibility Scoring Matrix](#24-5-point-likert-credibility-scoring-matrix)
- [3. Multi-Tier Payload Disinfection Suite (The 4 Sanitizer Solutions)](#-3-multi-tier-payload-disinfection-suite-the-4-sanitizer-solutions)
  - [Solution 1: Universal Multi-Format Defanger (Dangerzone Core)](#solution-1-universal-multi-format-defanger-dangerzone-core)
  - [Solution 2: ExifTool Metadata & Web-Beacon Stripping](#solution-2-exiftool-metadata--web-beacon-stripping)
  - [Solution 3: Disposable Zero-Network Docker Viewer (Qubes OS Style)](#solution-3-disposable-zero-network-docker-viewer-qubes-os-style)
  - [Solution 4: Local Static Malware & Exploit Triage](#solution-4-local-static-malware--exploit-triage)
- [4. Step-by-Step Installation & Prerequisites](#-4-step-by-step-installation--prerequisites)
- [5. Daily Operational Workflow (Standard Operating Procedure)](#-5-daily-operational-workflow-standard-operating-procedure)
- [6. Cryptographic Evidence Integrity (Chain of Custody)](#-6-cryptographic-evidence-integrity-chain-of-custody)
- [7. Repository File Structure](#-7-repository-file-structure)
- [8. Ethical Rules of Engagement (ROE)](#-8-ethical-rules-of-engagement-roe)

---

## 🌐 1. How to Safely Access the Dark Web (Traffic Routing & Identity Obfuscation)

Investigating `.onion` hidden services requires far more than launching a basic browser. Hostile threat actors, malicious exit nodes, and state-level surveillance routinely profile investigators using network fingerprints, DNS leaks, browser zero-days, and weaponized download payloads.

### 1.1 Threat Model of Direct Dark Web Browsing

| Threat Vector | Mechanism / Attack | Consequence Without Protection | Our Countermeasure |
| :--- | :--- | :--- | :--- |
| **ISP / State Snooping** | Deep Packet Inspection (DPI) flags TLS handshakes pointing to Tor directory servers | Investigator flagged for Tor usage; ISP throttling or subpoena | **obfs4 Pluggable Transports** scrambles packets into high-entropy random byte streams |
| **Cleartext Leaks** | VPN tunnel drops unexpectedly, dumping packets onto default gateway | Real public IP address exposed to target server or eavesdroppers | **Airtight UFW Killswitch** drops 100% of non-VPN physical egress |
| **Browser Zero-Days** | Malicious JavaScript escapes browser heap to execute shellcode on host | Total host compromise; exfiltration of SSH keys and credentials | **Firejail outer sandbox** hides `$HOME`, drops kernel capabilities, and mounts throwaway `/tmp` |
| **Browser De-Anonymization** | HTML5 Canvas, WebGL, WebRTC, and AudioContext fingerprinting | Persistent tracking across different `.onion` websites | **Mozilla Content Sandbox L3 + "Safest" Mode** (JavaScript completely disabled) |
| **Weaponized Leak Files** | PDFs with font zero-days, Excel macros, CSV command injection | Remote Code Execution (RCE) upon opening downloaded leak files | **Universal Defanging Pipeline** flattens files into sanitized RGB pixels |

---

### 1.2 The 6-Layer Defense-in-Depth Shield Architecture

All outbound and inbound operations flow through six strictly isolated defense tiers:

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

### 1.2.1 Layer 1: Dual-Mode Network Gateway (Hardware Router vs. Host Stealth Mode)

The architecture is designed to be **Router-Agnostic** and operates reliably in two operational environments:

1. **Mode A — Dedicated Lab Hardware (MikroTik hAP lite `nx-lab-gw`):**
   - Connected via hidden SSID `NX-LAB` with dedicated PPPoE uplink.
   - Provides physical hardware network segmentation and prevents domestic LAN cross-contamination.

2. **Mode B — Remote / Host Stealth Mode (When Lab Router is Unavailable):**
   - When operating over standard home Wi-Fi, campus networks, or mobile hotspots, physical router isolation is substituted by **Linux Host-Level Stealth Controls**:
     - **Full Incoming Traffic Drop (`ufw default deny incoming`):** Completely conceals the workstation from other devices on the same Wi-Fi subnet; drops all ARP, mDNS, NetBIOS, and port-scan probes.
     - **Strict Egress Killswitch (Layer 2):** Prevents cleartext leaks from reaching the local router by forcing 100% of outbound packets through the encrypted VPN tunnel.
     - **Reverse Path Filtering (`net.ipv4.conf.all.rp_filter=1`):** Rejects spoofed packets and asymmetric routing attacks.
     - **MAC Address Randomization:** Obfuscates the physical NIC hardware address from public router DHCP lease logs.

---

### 1.3 Nested Double-Sandbox Manual Verification (Layer 4 Deep Dive)

When manual intelligence verification is required, running Tor Browser directly on the host is a catastrophic security violation. Tor Browser in this architecture runs inside a **nested double-isolation barrier**:

```text
[ Physical Host Linux Kernel ]
    └── [ Outer Wall: Firejail Sandbox ]
             ├── Strips kernel capabilities (--caps.drop=all, --nonewprivs, --noroot)
             ├── Completely isolates investigator home directory via official whitelist
             ├── Blocks access to ~/.ssh, ~/.bash_history, Desktop, and personal documents
             ├── Maps isolated temporary directories (--private-tmp, --private-dev)
             └── [ Inner Wall: Tor Browser / Mozilla Gecko Engine ]
                      ├── Linux Seccomp-BPF system call filtering
                      ├── Multi-process content sandboxing (Sandbox Level 3: -sandboxReporter 3)
                      └── Security Level: "Safest" (JavaScript, WebGL, & fonts disabled)
```

1. **Outer Wall — Firejail Sandbox (`run-tor-browser.sh`):**
   - **Targeted Directory Whitelisting:** Firejail whitelists only the dedicated Tor Browser directory and `Downloads`. The investigator's entire `$HOME` directory (`~/.ssh`, `Documents`, `Desktop`, bash histories, credentials) is completely concealed.
   - **Kernel Capability Stripping (`caps.drop all`, `nonewprivs`, `noroot`):** Strips all administrative capabilities to prevent container-breakout privilege escalations.
   - **Filesystem Isolation (`private-dev`, `private-tmp`):** Maps throwaway RAM-backed `/tmp` and `/dev` nodes.
2. **Inner Wall — Mozilla Content Sandbox (Level 3):**
   - Renders untrusted `.onion` HTML using an unprivileged child process governed by Linux kernel Seccomp-BPF filters.
   - Even if memory corruption occurs, the process cannot invoke system calls to spawn shells or modify files.

---

## 🔒 2. Tor Routing, obfs4 Obfuscation & SOCKS5 Architecture

### 2.1 SOCKS5 Proxy Architecture (`127.0.0.1:9050` / `9150`)
- Standard HTTP clients cannot resolve or reach `.onion` pseudo-top-level domains because `.onion` addresses are cryptographic public key hashes, not registered DNS records.
- Network requests route via SOCKS5h protocol (`socks5h://127.0.0.1:9050` or `:9150`). The **`h` flag** is critical: it enforces **remote DNS resolution through the Tor exit circuit**, preventing local DNS queries from leaking to the investigator's ISP.

### 2.2 Deep Packet Inspection (DPI) Resistance via obfs4 Pluggable Transports
- **obfs4 (The Obfuscator 4):** A look-like-nothing pluggable transport layer that transforms the Tor traffic handshake into completely high-entropy random byte streams.
- To an ISP or state-level Deep Packet Inspection engine, obfs4 packets look like unidentifiable background noise, preventing Tor protocol fingerprinting and automated firewall blocks.
- Managed via `vpn/torrc` and verified using `./vpn/check-bridges.sh`.

### 2.3 Circumventing Dark Web Anti-Scraping & Latency Bottlenecks
- **Extended Timeout Thresholds:** Due to multi-hop onion routing, latencies range from 15 to 45 seconds. Investigations use 60-second connection timeouts with exponential backoff.
- **Handling Tor Proof-of-Work (PoW):** Modern v3 hidden services implement End-to-End PoW to resist DDoS attacks.
- **Header Rotation:** Emulates standard Tor Browser User-Agent strings (`Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0`) to avoid bot-signature blocking.

### 2.4 5-Point Likert Credibility Scoring Matrix
Every intelligence claim is graded on an objective 1-to-5 scale:

| Score | Credibility Rating | Evaluation Criteria |
| :---: | :--- | :--- |
| **1** | **Unsubstantiated / Hoax** | Pure text claim with zero sample proof; threat actor has no prior history; recycled public breach data. |
| **2** | **Low Credibility** | Basic sample provided, but matches historical public leaks; inconsistent timestamps or conflicting metadata. |
| **3** | **Moderate / Plausible** | Valid sample provided (valid employee names, matching email domains); threat actor has moderate credibility. |
| **4** | **High Credibility** | Fresh database schemas, valid corporate credentials confirmed, verified PII samples, or ransomware proof screenshots. |
| **5** | **Fully Confirmed / Critical** | Verified live database dump, private cryptographic keys, verified internal communications, or official victim acknowledgment. |

---

## 🧼 3. Multi-Tier Payload Disinfection Suite (The 4 Sanitizer Solutions)

Opening downloaded dark-web files on an investigator workstation is an extreme hazard. The toolkit deploys **four defense solutions** that guarantee zero malicious code survives:

### Solution 1: Universal Multi-Format Defanger (Dangerzone Core)
- **Documents (`.pdf`, `.docx`, `.xlsx`, `.pptx`):**
  - Uses Dangerzone's containerized pixel-flattening engine.
  - The document is converted inside a sandboxed container into **raw RGB bitmap pixels**, completely stripping embedded JavaScript, macro payloads, font exploit buffers, and remote OLE objects.
  - The sanitized pixels are re-assembled into a clean, sterile `*-safe.pdf`.
- **Spreadsheets (`.csv`, `.tsv`):**
  - Threat actors embed Dynamic Data Exchange (DDE) formulas in CSV dumps (e.g., `=cmd|'/C calc'!A0` or `=HYPERLINK(...)`).
  - The sanitizer parses all fields and prepends a single quotation mark (`'`) to any cell starting with `=`, `+`, `-`, `@`, or `|`, neutralizing formula execution across Microsoft Excel, LibreOffice Calc, and Google Sheets.
- **Dumps & Scripts (`.sql`, `.txt`, `.json`):**
  - Strips ANSI control characters to prevent terminal hijacking when using `cat` or `grep`.
  - Automatically defangs tracking links (`http://` $\rightarrow$ `hxxp://`).
- **Compressed Archives (`.zip`, `.tar.gz`, `.7z`):**
  - Audited against **Zip-Bomb** decompression attacks and **Zip-Slip** path-traversal exploits (`../../etc/passwd`) before extraction into an isolated directory.

### Solution 2: ExifTool Metadata & Web-Beacon Stripping
Threat actors embed tracking beacons, canary tokens, and metadata traps in document properties (Author, Company, Comments) that attempt outbound HTTP connections when opened.
- The sanitizer automatically executes `exiftool -all= -overwrite_original` across every downloaded file, stripping GPS tags, software signatures, author IDs, and hidden URL beacons.

### Solution 3: Disposable Zero-Network Docker Viewer (Qubes OS Style)
For inspecting files that must be viewed in their native original formatting without risking host compromise:
- Script: `./view-in-sandbox.sh <path-to-file>`
- Spawns an **ephemeral Docker container** with:
  - `--network none` (complete network isolation; zero outbound phone-home capability).
  - `--read-only` root filesystem (cannot persist malware).
  - `--cap-drop=ALL` (drops all Linux capabilities).
  - File is mounted read-only and rendered via an isolated container viewer.
  - Upon closing the viewer window, the container and all execution remnants **instantly self-destruct**.

### Solution 4: Local Static Malware & Exploit Triage
Before any file is handled, the automated engine executes static triage:
- Extracts file entropy and true MIME signatures (defeats double-extension tricks like `leak.pdf.exe`).
- Scans for known trojans, shellcode stubs, and CVE exploits.
- Generates a threat triage report that feeds directly into credibility scoring.

---

## 🛠️ 4. Step-by-Step Installation & Prerequisites

### 4.1 System Requirements
- **Operating System:** Linux 64-bit (`Debian 12+`, `Ubuntu 22.04 / 24.04 LTS`, or `Kali Linux Rolling`).
- **Memory & Storage:** 4 GB RAM minimum (8 GB recommended), 10 GB free disk space.
- **Network Interface:** Ethernet, Wi-Fi, or Mobile Hotspot.

### 4.2 One-Time Installation Commands

```bash
# 1. Update system and install essential packages
sudo apt update
sudo apt install -y ufw torbrowser-launcher python3-notify2 libnotify-bin curl gnupg lsb-release exiftool
# (Optional: install Docker if using Disposable Sandbox Viewer)
sudo apt install -y docker.io containerd && sudo systemctl enable --now docker

# 2. Make scripts executable
cd ~/darkwarden
chmod +x *.sh vpn/*.sh auto_sanitizer.py

# 3. Install Firejail Sandbox & Dangerzone Modules
./install-firejail.sh
./install-dangerzone.sh

# 4. Initialize Tor Browser & obfs4 Bridges
torbrowser-launcher
# In Tor Browser Settings -> Connection -> Bridges: Select "obfs4"
# Set Security Level to "Safest" (Disables JavaScript globally)
```

---

## 🚀 5. Daily Operational Workflow (Standard Operating Procedure)

Execute these operational steps in exact sequence for every dark-web research session:

```bash
cd ~/darkwarden

# ==============================================================================
# STEP 1: ENGAGE VPN & AIRTIGHT HOST KILLSWITCH
# ==============================================================================
./vpn/project-vpn-on.sh
# [Verification]: Confirms VPN tunnel, activates UFW rules, pins uplink to VPN IP.
#                 All cleartext physical packets are strictly DROPPED.

# ==============================================================================
# STEP 2: VERIFY KILLSWITCH & TOR BRIDGES (RECOMMENDED)
# ==============================================================================
./vpn/verify-killswitch.sh   # Confirms physical leak is 100% blocked
./vpn/check-bridges.sh       # Tests TCP reachability of configured obfs4 bridges

# ==============================================================================
# STEP 3: LAUNCH TOR BROWSER IN NESTED DOUBLE SANDBOX + AUTO-SENTRY
# ==============================================================================
./run-tor-browser.sh
# [Verification]: Tor Browser opens in Firejail; ~/.ssh and host files hidden.
#                 Background Sentry (auto_sanitizer.py) continuously monitors ~/Downloads.

# ==============================================================================
# STEP 4: AUTOMATED / MANUAL PAYLOAD DISINFECTION (LAYER 5)
# ==============================================================================
# [AUTOMATIC]: Any file downloaded through Tor Browser is automatically intercepted,
#              defanged, original quarantined to investigations/quarantine/,
#              and a desktop alert is dispatched.
# [MANUAL]: To sanitize an external file on demand:
./sanitize-file.sh /path/to/downloaded_leak.pdf

# [ZERO-NETWORK PREVIEW]: To inspect a suspicious original in an ephemeral sandbox:
./view-in-sandbox.sh investigations/quarantine/sample_original.pdf

# ==============================================================================
# STEP 5: RECORD CRYPTOGRAPHIC EVIDENCE (LAYER 6)
# ==============================================================================
./log-evidence.sh sample-safe.pdf CASE-001 "Verified dark web breach claim"
# [Verification]: Calculates SHA-256 and appends entry to investigations/evidence_ledger.csv.

# ==============================================================================
# STEP 6: CLEAN SESSION TEARDOWN
# ==============================================================================
./stop-tor-browser.sh
./vpn/project-vpn-off.sh
# [Verification]: Closes browser, kills sentry, tears down VPN, and restores normal internet.
```

---

## 🔏 6. Cryptographic Evidence Integrity (Chain of Custody)

For dark-web intelligence to be admissible in legal or law-enforcement contexts, the **Chain of Custody** must be mathematically verifiable:

1. **Immutable SHA-256 Ledger:** Whenever an artifact is captured, `./log-evidence.sh` computes its cryptographic SHA-256 hash and appends it to `investigations/evidence_ledger.csv`:
   ```csv
   Timestamp,Case_Tag,Filename,SHA256_Hash,Investigator_Notes
   2026-10-20T06:15:22Z,CASE-001,leak_dump-safe.pdf,a8f5b2c...,"Breach claim verified"
   ```
2. **Quarantine Isolation:** Hazardous original files are permanently moved to `investigations/quarantine/` with execution permissions removed (`chmod -x`).
3. **Reproducibility:** Any external auditor can re-compute the hash of the preserved artifact to prove it was never tampered with or altered post-collection.

---

## 📁 7. Repository File Structure

```text
├── ARCHITECTURE.md                               # Comprehensive system design documentation
├── README.md                                     # Main operational & architectural guide
├── SETUP.md                                      # Setup & deployment reference
├── LICENSE                                       # Official MIT License
├── setup-ramdisk.sh                              # Volatile RAM-backed Anti-Forensics storage controller
├── auto_sanitizer.py                             # Real-time inotify download sentry daemon
├── yara_scanner.py                               # YARA Threat Intelligence & IOC detection engine
├── yara_rules/                                   # Dark web threat ruleset (Infostealers, Ransomware, Exploits)
├── watch-and-sanitize.sh                         # Controller for auto_sanitizer.py
├── sanitize-file.sh                              # Layer 5 Universal Anti-Malware File Sanitizer
├── view-in-sandbox.sh                            # Layer 5 Solution 3: Disposable Docker Sandbox Viewer
├── run-tor-browser.sh                            # Nested double-sandbox Tor launcher (Firejail)
├── stop-tor-browser.sh                           # Clean Tor browser & sentry shutdown
├── apply-clipboard-hardening.sh                  # Tor Browser user.js clipboard & anti-snooping hardener
├── install-firejail.sh                           # Firejail sandbox automated installer
├── install-dangerzone.sh                         # Dangerzone anti-malware installer
├── setup-gpg-key.sh                              # Investigator GPG 4096-bit key generator & exporter
├── log-evidence.sh                               # Cryptographic SHA-256 & GPG evidence ledger recorder
├── verify-evidence.sh                            # Tamper-evident GPG signature & SHA-256 audit tool
├── package-toolkit.sh                            # Toolkit packaging script (excludes secrets)
├── investigations/
│   ├── downloads/                                # Volatile RAM-backed ingestion folder (tmpfs)
│   ├── quarantine/                               # Volatile RAM-backed isolated storage (tmpfs)
│   ├── evidence/                                 # Persistent SHA-256 & GPG verified artifact repository
│   │   ├── evidence_ledger.csv                   # Immutable investigation audit ledger
│   │   ├── evidence_ledger.csv.asc               # GPG Detached Armored Digital Signature
│   │   └── investigator_public_key.asc           # Public GPG key for court / evaluator verification
│   └── evidence_ledger.csv                       # Symlink to evidence/evidence_ledger.csv
└── vpn/
    ├── project-vpn-on.sh                         # VPN connect & airtight UFW killswitch activation
    ├── project-vpn-off.sh                        # VPN teardown & network restore
    ├── verify-killswitch.sh                      # Live killswitch leak & security audit tool
    ├── killswitch-off.sh                         # Emergency UFW restore utility
    ├── check-bridges.sh                          # Bridge reachability verification tool
    └── torrc                                     # Local obfs4 bridge runtime configuration
```

---

## ⚖️ 8. Ethical Rules of Engagement (ROE) & Operational Constraints

Operating in dark web environments, analyzing underground threat actor leak sites, and handling untrusted payloads presents severe legal, ethical, and operational risks. This architecture enforces strict adherence to defensive Cyber Threat Intelligence (CTI) standards, the Budapest Convention on Cybercrime, and ISO/IEC 27037 digital evidence integrity guidelines.

### 8.1 Technical Enforcement Matrix

| Architectural Defense Layer | Operational Restriction Enforced | Defensive Rationale & Legal Safeguard |
|---|---|---|
| **Layer 1 & Layer 2: VPN Killswitch & IPv6 Blackhole** | **No Raw Egress / Strict Anonymity** | Enforces complete isolation from ISP surveillance and prevents accidental clearnet exposure of the investigator's true IP. |
| **Layer 3: RAM-Backed `tmpfs` Anti-Forensics** | **Zero Persistent Contraband / Ephemeral Staging** | Untrusted payloads reside exclusively in volatile memory (`/dev/shm`), ensuring illegal or contaminated material is irrevocably wiped upon session termination. |
| **Layer 4: Hardened Firejail & D-Bus/Clipboard Isolation** | **No Host Compromise / Passive Observation Only** | D-Bus, audio/video devices, and host IPC are blocked; hostile scripts cannot compromise the host system, steal host clipboard data, or log keystrokes. |
| **Layer 5: Automated YARA Triage & Dangerzone Disinfection** | **Mandatory Payload Neutralization & No Malware Propagation** | Dangerous active content (macros, embedded exploits, PDF actions) is converted into pixel-rendered sanitized PDFs. Live malware is never executed on the host. |
| **Layer 6: GPG 4096-Bit Non-Repudiation Evidence Ledger** | **Immutable Chain of Custody & Court-Admissibility** | SHA-256 digests and detached GPG signatures guarantee forensic evidence cannot be manipulated or fabricated, meeting judicial integrity standards (FRE 902(14)). |

### 8.2 Core Operational Principles

1. **Passive Lawful Observation Only (Zero Attack Egress):**
   - The platform is strictly constrained to passive monitoring of publicly accessible `.onion` breach disclosures, ransomware PR portals, and threat-actor announcements.
   - Absolutely no port scanning (Nmap), vulnerability exploitation, brute-forcing, SQL injection, or denial-of-service (DoS) may ever be directed at any hidden service, relay, or third-party infrastructure.

2. **Absolute Prohibition on Purchasing or Financial Interaction:**
   - Under no circumstances shall cryptocurrency (Bitcoin, Monero) or any financial consideration be exchanged with threat actors, illicit brokers, or dark web marketplaces.
   - No payment shall be made for stolen databases, private keys, zero-day exploits, or invite codes. Research is confined strictly to open telemetry and public leaks.

3. **Zero Credential Re-Testing or Unauthorized Access:**
   - Leaked credentials, database dumps, or authentication tokens uncovered during threat triage must **NEVER** be tested, verified, or submitted against victim or third-party login portals. Testing leaked credentials constitutes unauthorized access under computer fraud statutes.

4. **Mandatory PII Masking and Data Privacy Compliance:**
   - Any sensitive Personally Identifiable Information (PII) — including National Identity numbers, banking records, health data, and unhashed credentials — must be scrubbed, sanitized, or redacted (`*****`) before archiving or reporting.

5. **Strict Chain of Custody & Responsible Disclosure:**
   - All documented intelligence must be recorded through `log-evidence.sh` with GPG detached cryptographic signatures to guarantee timestamp and hash immutability.
   - Legitimate critical vulnerabilities or imminent threats discovered during research must be responsibly disclosed to appropriate national CERTs, affected organizations, or academic authorities through secure channels.

---

<div align="center">

**DarkWarden — Safe Dark Web Access & Host Defense Platform**  
*Department of Software Engineering · Daffodil International University*  
*Document Author:* **Md. Tanjim Islam (Tanjim_islam)**

</div>
