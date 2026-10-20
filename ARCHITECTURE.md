# Project Dark Hunt — End-to-End System Architecture
**Team:** Team NullX (DIU)  
**Classification:** Lawful Cyber Exposure & Dark Web Threat Intelligence  
**Target:** 45 Key Point Installations (KPIs) of Bangladesh  

---

## 1. Architectural Blueprint (Defense-in-Depth)

```
┌────────────────────────────────────────────────────────────────────────┐
│ Layer 1: Hardware & Physical Gateway                                   │
│ MikroTik hAP lite (nx-lab-gw) · Hidden Wi-Fi (NX-LAB) · PPPoE WAN     │
│ Isolates team & personal identities from raw home/university ISP logs. │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│ Layer 2: Network Session & Kernel Killswitch                           │
│ Proton VPN + Host UFW Firewall Session Lock (./vpn/project-vpn-on.sh)  │
│ Strict rules: blocks 100% outbound packets if VPN tunnel drops.        │
└───────────────────┬────────────────────────────────┬───────────────────┘
                    │                                │
┌───────────────────▼──────────────┐   ┌─────────────▼───────────────────┐
│ Layer 3: AI OSINT Engine         │   │ Layer 4: Link Verification      │
│ Robin in Docker Container        │   │ Tor Browser in Firejail Sandbox │
│ • Port mapped: 127.0.0.1:8501    │   │ • Ephemeral RAM filesystem      │
│ • obfs4 bridges via vpn/torrc    │   │ • No disk traces on close       │
│ • No JS execution during scrape  │   │ • Native rendering (0% lag)     │
│ • Safe LLM report generation     │   │ • Strict Seccomp & dropped caps │
└───────────────────┬──────────────┘   └─────────────┬───────────────────┘
                    │                                │
┌───────────────────▼────────────────────────────────▼───────────────────┐
│ Layer 5: Evidence Integrity & Cryptographic Provenance                 │
│ Evidence artifacts preserved with SHA-256 ledgers (./log-evidence.sh)  │
│ PII & leaked passwords redacted before team logging or submission.     │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Directory Layout

```text
~/robin/
├── ARCHITECTURE.md                  ← This document
├── SETUP.md                         ← Teammate installation & quickstart
├── PROJECT_DARK_HUNT_MASTER_WRITEUP.md ← Project scope & RACI
├── package-toolkit.sh               ← Bundles clean shareable package
├── log-evidence.sh                  ← Cryptographic SHA-256 evidence recorder
├── run-robin.sh / stop-robin.sh     ← Robin OSINT container controller
├── run-tor-browser.sh / stop-tor-browser.sh ← Firejail private Tor Browser
├── Dockerfile / entrypoint.sh       ← Tor + obfs4proxy container definition
├── investigations/                  ← Saved reports & evidence ledger
│   └── evidence/                    ← SHA-256 verified artifact repository
└── vpn/
    ├── project-vpn-on.sh            ← Starts VPN + activates UFW killswitch
    ├── project-vpn-off.sh           ← Cleanly restores normal internet
    ├── killswitch-off.sh            ← Emergency network unlock
    └── torrc                        ← Active obfs4 bridges configuration
```

---

## 3. Standard Operational Flow (SOP)

```bash
# 1. Start Session
cd ~/robin
./vpn/project-vpn-on.sh

# 2. Run OSINT Search Engine
./run-robin.sh          # UI on http://127.0.0.1:8501

# 3. Verify Dark Web Claims
./run-tor-browser.sh    # Launches private Firejail sandbox

# 4. Record Evidence Artifacts
./log-evidence.sh screenshot.png KPI-007 "Database breach claim on BreachForums"

# 5. End Session Cleanly
./stop-tor-browser.sh
./stop-robin.sh
./vpn/project-vpn-off.sh
```
