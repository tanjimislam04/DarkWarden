# Safe Dark Web Access, OSINT Data Scraping & Threat Intelligence Disinfection Architecture

<div align="center">

![Platform](https://img.shields.io/badge/Platform-Linux%20(Kali%20%2F%20Debian%20%2F%20Ubuntu)-orange?style=for-the-badge&logo=linux)
![Security Architecture](https://img.shields.io/badge/Defense-6--Layer%20Shield-success?style=for-the-badge&logo=shield)
![Tor](https://img.shields.io/badge/Tor-obfs4%20Obfuscation-7D4698?style=for-the-badge&logo=tor-browser&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

**Department of Software Engineering · Daffodil International University (DIU)**  
*Lead Author & Architect:* **Md. Tanjim Islam (Tanjim_islam)**  
*Project Team:* **Team NullX (Rahat Sahriar Rafi, Md. Tanjim Islam, MD RAKIB HASAN APON)**  
*Advisory / Sponsor:* **Tanvir Hassan Zoha**

[Access Architecture](#-1-how-to-safely-access-the-dark-web-traffic-routing--identity-obfuscation) •
[Scraping Methodology](#-2-how-dark-web-data-scraping-works-scraping-architecture--pipeline) •
[AI Pipeline](#-3-ai-threat-intelligence-pipeline-google-gemini-integration) •
[Disinfection Suite](#-4-multi-tier-payload-disinfection-suite-the-4-sanitizer-solutions) •
[Setup & Installation](#-5-step-by-step-installation--prerequisites) •
[Daily SOP](#-6-daily-operational-workflow-standard-operating-procedure) •
[Evidence Ledger](#-7-cryptographic-evidence-integrity-chain-of-custody)

---

</div>

## 📑 Table of Contents
- [1. How to Safely Access the Dark Web (Traffic Routing & Identity Obfuscation)](#-1-how-to-safely-access-the-dark-web-traffic-routing--identity-obfuscation)
  - [1.1 Threat Model of Direct Dark Web Browsing](#11-threat-model-of-direct-dark-web-browsing)
  - [1.2 The 6-Layer Defense-in-Depth Shield Architecture](#12-the-6-layer-defense-in-depth-shield-architecture)
  - [1.3 Nested Double-Sandbox Manual Verification (Layer 4 Deep Dive)](#13-nested-double-sandbox-manual-verification-layer-4-deep-dive)
- [2. How Dark Web Data Scraping Works (Scraping Architecture & Pipeline)](#-2-how-dark-web-data-scraping-works-scraping-architecture--pipeline)
  - [2.1 SOCKS5 Proxy Architecture (`127.0.0.1:9050`)](#21-socks5-proxy-architecture-1270019050)
  - [2.2 Multi-Engine Onion Querying & Deep Crawling](#22-multi-engine-onion-querying--deep-crawling)
  - [2.3 Tor Circuit Management & Dynamic Identity Rotation (`NEWNYM`)](#23-tor-circuit-management--dynamic-identity-rotation-newnym)
  - [2.4 Circumventing Dark Web Anti-Scraping & Latency Bottlenecks](#24-circumventing-dark-web-anti-scraping--latency-bottlenecks)
  - [2.5 Safe Token Ingestion & Text Normalization](#25-safe-token-ingestion--text-normalization)
- [3. AI Threat Intelligence Pipeline (Google Gemini Integration)](#-3-ai-threat-intelligence-pipeline-google-gemini-integration)
  - [3.1 Intelligence Ingestion Workflow](#31-intelligence-ingestion-workflow)
  - [3.2 Automated Named Entity Recognition (NER)](#32-automated-named-entity-recognition-ner)
  - [3.3 5-Point Likert Credibility Scoring Matrix](#33-5-point-likert-credibility-scoring-matrix)
- [4. Multi-Tier Payload Disinfection Suite (The 4 Sanitizer Solutions)](#-4-multi-tier-payload-disinfection-suite-the-4-sanitizer-solutions)
  - [Solution 1: Universal Multi-Format Defanger](#solution-1-universal-multi-format-defanger-dangerzone-core)
  - [Solution 2: ExifTool Metadata & Web-Beacon Stripping](#solution-2-exiftool-metadata--web-beacon-stripping)
  - [Solution 3: Disposable Zero-Network Docker Viewer (Qubes OS Style)](#solution-3-disposable-zero-network-docker-viewer-qubes-os-style)
  - [Solution 4: Local Static Malware & Exploit Triage](#solution-4-local-static-malware--exploit-triage)
- [5. Step-by-Step Installation & Prerequisites](#-5-step-by-step-installation--prerequisites)
- [6. Daily Operational Workflow (Standard Operating Procedure)](#-6-daily-operational-workflow-standard-operating-procedure)
- [7. Cryptographic Evidence Integrity (Chain of Custody)](#-7-cryptographic-evidence-integrity-chain-of-custody)
- [8. Repository File Structure](#-8-repository-file-structure)
- [9. Team Toolkit Packaging & Sharing](#-9-team-toolkit-packaging--sharing)
- [10. Team Roles & Ethical Rules of Engagement](#-10-team-roles--ethical-rules-of-engagement)

---

## 🌐 1. How to Safely Access the Dark Web (Traffic Routing & Identity Obfuscation)

Investigating `.onion` hidden services requires far more than launching a basic browser. Hostile threat actors, malicious exit nodes, and state-level surveillance routinely profile investigators using network fingerprints, DNS leaks, browser zero-days, and weaponized download payloads.

### 1.1 Threat Model of Direct Dark Web Browsing

| Threat Vector | Mechanism / Attack | Consequence Without Protection | Our Countermeasure |
| :--- | :--- | :--- | :--- |
| **ISP / State Snooping** | Deep Packet Inspection (DPI) flags TLS handshakes pointing to Tor directory servers | Investigator flagged for Tor usage; ISP throttling or subpoena | **obfs4 Pluggable Transports** scrambles packets into high-entropy random byte streams |
| **Cleartext Leaks** | VPN tunnel drops unexpectedly, dumping packets onto default gateway | Real public IP address exposed to target server or eavesdroppers | **Host UFW Firewall Killswitch** drops 100% of non-VPN outbound traffic |
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
 ║   │ LAYER 1: HARDWARE GATEWAY ISOLATION                                    │     ║
 ║   │ Dedicated MikroTik Router (nx-lab-gw) · PPPoE Uplink · Hidden SSID     │     ║
 ║   │ Prevents home network cross-contamination & MAC address disclosure     │     ║
 ║   └────────────────────────────────┬───────────────────────────────────────┘     ║
 ║                                    │                                             ║
 ║                                    ▼                                             ║
 ║   ┌────────────────────────────────────────────────────────────────────────┐     ║
 ║   │ LAYER 2: NETWORK TUNNEL & EGRESS KILLSWITCH                            │     ║
 ║   │ Proton VPN (Encrypted WireGuard/OpenVPN) + Linux Host UFW Rules        │     ║
 ║   │ All non-tun0/proton0 traffic dropped. 0% cleartext leak tolerance      │     ║
 ║   └──────────┬─────────────────────────────────────────┬───────────────────┘     ║
 ║              │                                         │                         ║
 ║              ▼                                         ▼                         ║
 ║   ┌───────────────────────────────┐     ┌──────────────────────────────────┐     ║
 ║   │ LAYER 3: AUTOMATED AI SCRAPER │     │ LAYER 4: MANUAL VERIFICATION     │     ║
 ║   │ Robin Container (Docker)      │     │ Tor Browser (Nested Sandbox)     │     ║
 ║   │ • Tor daemon (SOCKS5 :9050)   │     │                                  │     ║
 ║   │ • obfs4proxy bridge routing   │     │  ┌────────────────────────────┐  │     ║
 ║   │ • Async crawling & indexing   │     │  │ Outer Wall: Firejail       │  │     ║
 ║   │ • Google Gemini LLM API       │     │  │ • Conceals ~/.ssh, history │  │     ║
 ║   │ • Streamlit Web UI (:8501)    │     │  │ • Drops Linux capabilities │  │     ║
 ║   └──────────┬────────────────────┘     │  │ • Throwaway /tmp & /dev    │  │     ║
 ║              │                          │  │  ┌──────────────────────┐  │  │     ║
 ║              │                          │  │  │ Inner Wall:          │  │  │     ║
 ║              │                          │  │  │ Mozilla L3 Seccomp   │  │  │     ║
 ║              │                          │  │  │ Safest Mode (No JS)  │  │  │     ║
 ║              │                          │  │  └──────────────────────┘  │  │     ║
 ║              │                          │  └────────────────────────────┘  │     ║
 ║              │                          └──────────────┬───────────────────┘     ║
 ║              │                                         │                         ║
 ║              ▼                                         ▼                         ║
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

### 1.3 Nested Double-Sandbox Manual Verification (Layer 4 Deep Dive)

When manual intelligence verification is required, running Tor Browser directly on the host is a catastrophic security violation. Tor Browser in this architecture runs inside a **nested double-isolation barrier**:

```text
[ Physical Host Linux Kernel ]
    └── [ Outer Wall: Firejail Sandbox ]
             ├── Strips kernel capabilities (--caps.drop=all, --nonewprivs)
             ├── Completely isolates investigator home directory (--private-home=.local/share/torbrowser)
             ├── Blocks access to ~/.ssh, ~/.bash_history, and personal documents
             ├── Maps isolated temporary directories (--private-tmp, --private-dev)
             └── [ Inner Wall: Tor Browser / Mozilla Gecko Engine ]
                      ├── Linux Seccomp-BPF system call filtering
                      ├── Multi-process content sandboxing (Sandbox Level 3)
                      └── Security Level: "Safest" (JavaScript, WebGL, & fonts disabled)
```

1. **Outer Wall — Firejail Sandbox (`run-tor-browser.sh`):**
   - **`--noprofile`**: Overrides rigid default distro profiles that inadvertently block Tor's internal background daemon and Pluggable Transport binaries.
   - **`--private-home=.local/share/torbrowser`**: Tor Browser sees only its dedicated directory. If an attacker manages to achieve arbitrary file read, they find an empty directory instead of the user's private keys or credentials.
   - **`--caps.drop=all --nonewprivs --noroot`**: Strips setuid, root execution, and all POSIX capabilities.
2. **Inner Wall — Mozilla Content Sandbox (Level 3):**
   - Renders untrusted `.onion` HTML using an unprivileged child process governed by Linux kernel Seccomp-BPF filters.
   - Even if memory corruption occurs, the process cannot invoke system calls to spawn shells or modify files.

---

## 🕷️ 2. How Dark Web Data Scraping Works (Scraping Architecture & Pipeline)

Automated dark web scraping differs radically from surface-web scraping. Hidden services exhibit high latency, frequent circuit drops, rate-limiting anti-DDoS proof-of-work challenges, and absence of standardized DNS.

```text
 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │                              ROBIN OSINT SCRAPING ENGINE                               │
 ├────────────────────────────────────────────────────────────────────────────────────────┤
 │                                                                                        │
 │  [ Target Keywords / KPI Queries ]                                                     │
 │                 │                                                                      │
 │                 ▼                                                                      │
 │  ┌───────────────────────────────┐                                                     │
 │  │ 1. Search Engine Aggregator   │ ──► Queries Ahmia, Torch, Haystak, Excava (.onion)  │
 │  └──────────────┬────────────────┘                                                     │
 │                 │                                                                      │
 │                 ▼                                                                      │
 │  ┌───────────────────────────────┐                                                     │
 │  │ 2. Deep Crawler & Dispatcher  │ ──► Asynchronously crawls breach posts & leak dumps  │
 │  └──────────────┬────────────────┘                                                     │
 │                 │                                                                      │
 │                 ▼                                                                      │
 │  ┌───────────────────────────────┐                                                     │
 │  │ 3. SOCKS5 Tor Proxy Layer     │ ──► Routes requests through local Tor (:9050)       │
 │  │    (obfs4 Transport Bridge)   │     Rotates circuit (NEWNYM) on 429/timeout errors  │
 │  └──────────────┬────────────────┘                                                     │
 │                 │                                                                      │
 │                 ▼                                                                      │
 │  ┌───────────────────────────────┐                                                     │
 │  │ 4. Token & Text Sanitizer     │ ──► Strips ANSI escapes, scripts, tracking beacons  │
 │  └──────────────┬────────────────┘                                                     │
 │                 │                                                                      │
 │                 ▼                                                                      │
 │  ┌───────────────────────────────┐                                                     │
 │  │ 5. Google Gemini LLM Engine   │ ──► Structured extraction: Target, CVE, Credibility │
 │  └───────────────────────────────┘                                                     │
 │                                                                                        │
 └────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.1 SOCKS5 Proxy Architecture (`127.0.0.1:9050`)
- Standard HTTP clients cannot resolve or reach `.onion` pseudo-top-level domains because `.onion` addresses are cryptographic public key hashes, not registered DNS records.
- Robin routes all network requests via a local **Tor daemon listening on `127.0.0.1:9050`** using SOCKS5h protocol (`socks5h://127.0.0.1:9050`). The **`h` flag** is critical: it enforces **remote DNS resolution through the Tor exit circuit**, preventing local DNS queries from leaking to the investigator's ISP.

### 2.2 Multi-Engine Onion Querying & Deep Crawling
1. **Search Engine Harvesting:** The engine queries major dark-web search indexes:
   - **Ahmia** (`juhanurmih5wu7bv5zgiqcqq...onion`): Curated index of reachable dark-web content.
   - **Torch** (`xmh57jrknzkhv6y3ls3ubx...onion`): High-volume indexed database of dark-web pages.
   - **Haystak** & **Excava**: Unfiltered onion archives.
2. **Forum & Leak-Site Crawling:** The crawler navigates to ransomware leak sites (e.g., LockBit, BlackCat/ALPHV, Play, RansomHub), underground hacking forums (BreachForums mirrors, Exploit.in), and paste dumps.
3. **No-JavaScript Parsing:** Scraping uses lightweight DOM parsing (`BeautifulSoup4`, `lxml`) without running a headless Chromium browser. This completely prevents JavaScript-based browser exploits and tracking scripts.

### 2.3 Tor Circuit Management & Dynamic Identity Rotation (`NEWNYM`)
- Dark web sites frequently rate-limit or temporarily blacklist Tor exit circuits after continuous requests.
- When Robin encounters HTTP `429 Too Many Requests`, connection timeouts, or Cloudflare/Onion DDoS barriers, it communicates with the Tor Control Port (`9051`) using the Python `stem` library:
  ```python
  from stem import Signal
  from stem.control import Controller

  def rotate_tor_circuit():
      with Controller.from_port(port=9051) as controller:
          controller.authenticate()
          controller.signal(Signal.NEWNYM)
  ```
- Sending **`SIGNAL NEWNYM`** instructs Tor to rebuild its virtual 3-hop circuit (Guard $\rightarrow$ Middle $\rightarrow$ Exit), presenting a completely new identity and IP address to the target hidden service.

### 2.4 Circumventing Dark Web Anti-Scraping & Latency Bottlenecks
- **Extended Timeout Thresholds:** Due to multi-hop onion routing, latencies range from 15 to 45 seconds. Scraping engines use asynchronous requests (`aiohttp` with SOCKS connector) and 60-second connection timeouts with exponential backoff.
- **Handling Tor Proof-of-Work (PoW):** Modern v3 hidden services implement End-to-End PoW to resist DDoS attacks. The scraper dynamically adjusts client concurrency to avoid triggering PoW difficulty spikes.
- **Header Rotation:** Emulates standard Tor Browser User-Agent strings (`Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0`) to avoid bot-signature blocking.

### 2.5 Safe Token Ingestion & Text Normalization
Dark web paste dumps frequently contain terminal hijacking sequences (ANSI escape codes), malicious zero-width tracking characters, or embedded URLs designed to beacon back to threat actor servers upon viewing. The scraper normalizes all raw text before passing it to the database or LLM:
- **ANSI Escape Sequence Stripping:** Cleanses terminal hijack characters (`\x1b[...]`).
- **Web-Beacon Neutralization:** Defangs URLs (`https://` $\rightarrow$ `hxxps://`).
- **Character Encoding Sanitization:** Normalizes UTF-8 and removes non-printable binary blobs.

---

## 🤖 3. AI Threat Intelligence Pipeline (Google Gemini Integration)

Scraped dark-web dump text is often thousands of lines of chaotic, unstructured data. Robin utilizes the **Google Gemini API** (`gemini-1.5-flash` / `gemini-1.5-pro`) to transform raw scrapes into structured, actionable law-enforcement intelligence.

### 3.1 Intelligence Ingestion Workflow
1. Scraped text is sanitized and passed into structured Gemini prompt templates.
2. Gemini evaluates context, identifies targeted infrastructure, extracts leaked artifacts, and assesses threat validity.
3. Structured JSON output is generated and fed into the Streamlit dashboard for investigator review.

### 3.2 Automated Named Entity Recognition (NER)
The AI extractor parses the following critical intelligence parameters:
- **Target Organization / KPI:** Specific entity claimed to be breached (e.g., specific ministry, power grid, telecommunication operator).
- **Threat Actor Group:** Attributed ransomware syndicate, hacktivist cell, or data broker.
- **Compromised Data Types:** PII, credentials, SQL database dumps, internal PDFs, network topology diagrams.
- **Alleged Breach Volume:** Record count, file sizes (GB/TB), publication dates.
- **Exploited CVEs / Vulnerabilities:** Specific software flaws mentioned in leak notes.

### 3.3 5-Point Likert Credibility Scoring Matrix
Every intelligence claim is graded on an objective 1-to-5 scale:

| Score | Credibility Rating | Evaluation Criteria |
| :---: | :--- | :--- |
| **1** | **Unsubstantiated / Hoax** | Pure text claim with zero sample proof; threat actor has no prior history; recycled public breach data. |
| **2** | **Low Credibility** | Basic sample provided, but matches historical public leaks; inconsistent timestamps or conflicting metadata. |
| **3** | **Moderate / Plausible** | Valid sample provided (valid employee names, matching email domains); threat actor has moderate credibility. |
| **4** | **High Credibility** | Fresh database schemas, valid corporate credentials confirmed, verified PII samples, or ransomware proof screenshots. |
| **5** | **Fully Confirmed / Critical** | Verified live database dump, private cryptographic keys, verified internal communications, or official victim acknowledgment. |

---

## 🧼 4. Multi-Tier Payload Disinfection Suite (The 4 Sanitizer Solutions)

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
- Generates a threat triage report that feeds directly into the AI credibility scoring model.

---

## 🛠️ 5. Step-by-Step Installation & Prerequisites

### 5.1 System Requirements
- **Operating System:** Linux 64-bit (`Debian 12+`, `Ubuntu 22.04 / 24.04 LTS`, or `Kali Linux Rolling`).
- **Memory & Storage:** 8 GB RAM minimum, 20 GB free disk space.
- **Network Interface:** Dedicated Ethernet or hardened Wi-Fi (`NX-LAB`).
- **API Key:** Free Google Gemini API Key from [Google AI Studio](https://aistudio.google.com/apikey).

### 5.2 One-Time Installation Commands

```bash
# 1. Update system and install essential packages
sudo apt update
sudo apt install -y docker.io containerd ufw torbrowser-launcher python3-notify2 libnotify-bin curl gnupg lsb-release inotify-tools exiftool
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

# 2. Clone / Unpack Toolkit
cd ~
tar -xzf TeamNullX-Robin-Toolkit-SHARE.tgz
cd ~/robin
chmod +x *.sh vpn/*.sh auto_sanitizer.py

# 3. Install Firejail Sandbox & Dangerzone Modules
./install-firejail.sh
./install-dangerzone.sh

# 4. Configure Gemini API Key
cp .env.example .env
nano .env
# Set: GOOGLE_API_KEY="your-actual-gemini-api-key"

# 5. Build Hardened Robin Docker Container
docker build -t robin .

# 6. Initialize Tor Browser & obfs4 Bridges
torbrowser-launcher
# In Tor Browser Settings -> Connection -> Bridges: Select "obfs4"
# Set Security Level to "Safest" (Disables JavaScript)
```

---

## 🚀 6. Daily Operational Workflow (Standard Operating Procedure)

Execute these operational steps in exact sequence for every dark-web research session:

```bash
cd ~/robin

# ==============================================================================
# STEP 1: ENGAGE VPN & HOST EGRESS KILLSWITCH
# ==============================================================================
./vpn/project-vpn-on.sh
# [Verification]: Confirms tun0/proton0 interface and activates UFW rules.
#                 All cleartext non-VPN outbound packets are strictly DROPPED.

# ==============================================================================
# STEP 2: LAUNCH ROBIN AI OSINT ENGINE
# ==============================================================================
./run-robin.sh
# [Verification]: Tor daemon + obfs4proxy boots inside Docker.
#                 Streamlit web interface available at: http://127.0.0.1:8501

# ==============================================================================
# STEP 3: LAUNCH TOR BROWSER IN NESTED DOUBLE SANDBOX + AUTO-SENTRY
# ==============================================================================
./run-tor-browser.sh
# [Verification]: Tor Browser opens wrapped in Firejail; ~/.ssh and host files hidden.
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
./log-evidence.sh sample_original-safe.pdf KPI-018 "Verified employee credential dump"
# [Verification]: Calculates SHA-256 and appends entry to investigations/evidence_ledger.csv.

# ==============================================================================
# STEP 6: CLEAN SESSION TEARDOWN
# ==============================================================================
./stop-tor-browser.sh
./stop-robin.sh
./vpn/project-vpn-off.sh
# [Verification]: Closes browser, stops container, kills sentry, and restores normal internet.
```

---

## 🔏 7. Cryptographic Evidence Integrity (Chain of Custody)

For dark-web intelligence to be admissible in legal or law-enforcement contexts, the **Chain of Custody** must be mathematically verifiable:

1. **Immutable SHA-256 Ledger:** Whenever an artifact is captured, `./log-evidence.sh` computes its cryptographic SHA-256 hash and appends it to `investigations/evidence_ledger.csv`:
   ```csv
   Timestamp,Artifact_Name,SHA256_Hash,KPI_Tag,Investigator_Notes
   2026-10-20T06:15:22Z,leak_dump-safe.pdf,a8f5b2c...,KPI-018,"Breach claim verified"
   ```
2. **Quarantine Isolation:** Hazardous original files are permanently moved to `investigations/quarantine/` with execution permissions removed (`chmod -x`).
3. **Reproducibility:** Any external auditor can re-compute the hash of the preserved artifact to prove it was never tampered with or altered post-collection.

---

## 📁 8. Repository File Structure

```text
├── ARCHITECTURE.md                               # Comprehensive system design documentation
├── Dockerfile                                    # Hardened Robin container definition with obfs4proxy
├── entrypoint.sh                                 # Container bootstrap & dynamic torrc loader
├── .env.example                                  # Sanitized API configuration template
├── auto_sanitizer.py                             # Real-time inotify download sentry & quarantine daemon
├── watch-and-sanitize.sh                         # Daemon controller for auto_sanitizer.py
├── sanitize-file.sh                              # Layer 5 Universal Anti-Malware File Sanitizer
├── view-in-sandbox.sh                            # Layer 5 Solution 3: Disposable Docker Sandbox Viewer
├── install-firejail.sh                           # Firejail sandbox automated installer
├── install-dangerzone.sh                         # Dangerzone anti-malware installer
├── run-robin.sh                                  # Docker engine launch script
├── stop-robin.sh                                 # Container teardown script
├── run-tor-browser.sh                            # Nested double-sandbox Tor launcher
├── stop-tor-browser.sh                           # Clean Tor browser & sentry shutdown
├── log-evidence.sh                               # SHA-256 cryptographic audit ledger script
├── package-toolkit.sh                            # Team share packaging script (excludes secrets)
├── investigations/
│   ├── downloads/                                # Monitored ingestion folder
│   ├── evidence/                                 # Cryptographically verified artifacts
│   ├── evidence_ledger.csv                       # Immutable investigation audit ledger
│   └── quarantine/                               # Isolated storage for hazardous originals
└── vpn/
    ├── check-bridges.sh                          # Bridge reachability verification tool
    ├── killswitch-off.sh                         # Emergency UFW restore utility
    ├── project-vpn-on.sh                         # VPN connect & UFW killswitch activation
    ├── project-vpn-off.sh                        # VPN teardown & network restore
    └── torrc                                     # Local obfs4 bridge runtime configuration
```

---

## 📦 9. Team Toolkit Packaging & Sharing

To generate a shareable distribution archive for team members that is **completely sanitized of all private keys, `.env` files, and evidence dumps**:

```bash
./package-toolkit.sh
```
This generates **`TeamNullX-Robin-Toolkit-SHARE.tgz`**. Teammates can unpack this single archive on their machine and execute `./install-firejail.sh` and `./install-dangerzone.sh` to replicate the exact environment.

---

## 👥 10. Team Roles & Ethical Rules of Engagement

### 10.1 Team Roles & KPI Assignments
| Member | Academic Institution | Responsibilities | Assigned Cohort |
| :--- | :--- | :--- | :--- |
| **Rahat Sahriar Rafi** | Dept of SWE, DIU | Team Lead, Gantt Plan, MikroTik Gateway, Risk Language | **Cohort A (KPI 001–015)** |
| **Md. Tanjim Islam** | Dept of SWE, DIU | Lead Author, Layer 4 Privacy SOP, Web Dashboard, Sanitization Architecture | **Cohort B (KPI 016–030)** |
| **MD RAKIB HASAN APON** | Dept of SWE, DIU | Evidence Verification, Credibility Scoring, Dangerzone Pipeline | **Cohort C (KPI 031–045)** |

### 10.2 Strict Rules of Engagement (ROE)
1. **Passive Lawful Observation Only:** Research is strictly confined to publicly claimed and passively observable breach announcements.
2. **Absolute Prohibition on Active Attacks:** No vulnerability scanning, port scanning, or DoS testing against any dark web or victim infrastructure.
3. **Zero Credential Testing:** Never attempt to authenticate into third-party or government systems using leaked credentials.
4. **Mandatory PII Redaction:** All Personally Identifiable Information (NIDs, passwords, banking info) must be masked (`*****`) prior to archiving.
5. **Zero Commercial Transactions:** Never purchase databases, exploits, or memberships from cybercriminals.

---

<div align="center">

**Safe Dark Web Access & Threat Intelligence Scraping Platform**  
*Department of Software Engineering · Daffodil International University*  
*Document Author:* **Md. Tanjim Islam (Tanjim_islam)**

</div>
