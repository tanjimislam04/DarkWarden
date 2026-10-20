# Project Dark Hunt — Master Writeup (Team NullX)

**For:** Tanjim, Apon, and anyone joining the work  
**Author / lead:** Rahat Sahriar Rafi  
**Updated:** 20 October 2026  

This is the **one document** that explains what this project is, what we already built, how to work safely, and what is left before **31 October 2026**.

---

## 1. What this project is

**Name:** Project Dark Hunt  
**Team:** Team NullX (DIU)  
**Sponsor notice:** Tanvir Hassan Zoha  

**Goal:** Produce a law-enforcement–oriented assessment of **publicly claimed / lawfully observable** cyber exposure affecting Bangladesh’s **45 Key Point Installations (KPIs)** — what is alleged to leak, from where, how credible it is, what risk it creates, and what to do next.

**We do not:** hack live systems, buy criminal-market access, or use leaked passwords to “verify” accounts.

**Only hard deadline:** final package **31 October 2026**  
**21 October:** progress check-in with sir (status only, not a submission gate)

### Final deliverables (all due 31 Oct)

1. KPI-wise Dark Web Exposure Inventory  
2. Verified Intelligence & Evidence Reference List  
3. Proposed HTML/Web Dashboard Design  
4. Risk Assessment Summary for Law Enforcement  
5. Consolidated Research Report + Gantt Chart  

---

## 2. Who does what

| Member | Role on this project |
|--------|----------------------|
| **Rahat Sahriar Rafi** | Lead — plan, Gantt, Notion/standup, KPI framing, risk language, sir update, Cohort A (KPI 1–15), lab/toolkit setup |
| **Md. Tanjim Islam** | Dashboard (HTML/web), schema/CSV wiring, Cohort B (KPI 16–30) |
| **MD RAKIB HASAN APON** | Evidence & verification, credibility scoring, Cohort C (KPI 31–45) |

Full RACI: [`TEAM.md`](TEAM.md) · Plan: [`EXECUTION_PLAN.md`](EXECUTION_PLAN.md)

---

## 3. What we already did (so far)

### 3.1 Planning & tracking

- Team locked (3 people) + ownership + KPI cohorts  
- Execution plan + Gantt (`docs/gantt.html`)  
- Notion setup notes + daily report template  
- Data schema + sample inventory (`data/schema.json`, `data/inventory.sample.json`)  
- KPI master slots for all 45 (`data/kpi-master.csv`) — **official names still need filling**  
- Dashboard design proposal (`docs/DASHBOARD_PROPOSAL.md`) — **prototype build is Tanjim’s next big piece**

### 3.2 Lab network (MikroTik)

For safer research traffic (lab Wi‑Fi, not home ISP branding in clear):

- Router: MikroTik **hAP lite**, identity **`nx-lab-gw`**  
- LAN: `192.168.88.1/24`  
- WAN: PPPoE (`mahbub1001@daffodilnet.com`) — confirmed up when last checked  
- Wi‑Fi: **NX-LAB** (hidden SSID, WPA2‑PSK)  
- Hardened admin (default password rotated; joke hotspot removed)  

Credentials for lab gear stay in the lead’s private config — ask Rahat if you need to join the lab Wi‑Fi.

### 3.3 Research toolkit (Robin / Tor / VPN)

Built under **`~/robin`** so dark-web work is safer and repeatable for the whole team.

**Share package (no secrets):**  
`~/robin/TeamNullX-Robin-Toolkit-SHARE.tgz`  
or follow **`~/robin/SETUP.md`**

What it includes:

| Piece | Purpose |
|--------|---------|
| Proton VPN (GUI) | Hide destinations from ISP while working |
| **Project killswitch** | Whole PC locked to VPN **only during a work session**; off when you end the session |
| Tor Browser in Docker | Manual browse like real Tor Browser → https://127.0.0.1:6901 |
| Robin in Docker | AI-assisted dark-web OSINT → http://127.0.0.1:8501 |
| obfs4 bridges | Tor entry via bridges in `vpn/torrc` |
| Gemini API | Free LLM key for Robin (each person uses their own) |

**How a safe work day looks**

```text
cd ~/robin
./vpn/project-vpn-on.sh        # Proton + host killswitch ON
./run-tor-browser.sh           # browse  https://127.0.0.1:6901  (pw: nullx1)
./run-robin.sh                 # OSINT   http://127.0.0.1:8501   (needs .env keys)
# ... collect claims, redact, log evidence ...
./stop-tor-browser.sh
./stop-robin.sh
./vpn/project-vpn-off.sh       # killswitch OFF + VPN OFF → normal internet
```

If VPN drops while killswitch is on and you are locked out:

```bash
./vpn/killswitch-off.sh
```

Details: `~/robin/SETUP.md` · `~/robin/ARCHITECTURE.md` · `~/robin/vpn/README.md`

### 3.4 Incident master report (supporting research)

In the project folder:

- `Bangladesh_Cyber_Incidents_90_Master_Report.xlsx`  
- `Bangladesh_Cyber_Incidents_90_Master_Report.pdf` (landscape A4, same style as the Complete report)  
- `Bangladesh_Cyber_Incidents_90_Complete_Master_Report.pdf` (reference format)

This is a **chronological Bangladesh cyber-incident compilation** (supporting context for KPI exposure work). Keep using redacted language in shared decks.

### 3.5 What we deliberately stopped / cleaned

- Tails USB sticks were reformatted back to normal data drives (`USB_DATA` / exFAT) when no longer needed  
- Temporary lab “joke hotspot” was removed  
- Router footprints scrubbed before Tails research where applicable  

---

## 4. Hard rules (everyone)

1. Public or authorized sources only  
2. No logging into systems with leaked credentials  
3. Redact PII / passwords before Notion, chat, or slides  
4. Every claim needs: source + date + verification status  
5. Daily ethics gate (lawful source? authorized method? redacted? integrity logged?)  

If any answer is **no** → stop and tell Rahat before continuing.

---

## 5. What each person should do next

### Rahat (Lead / Cohort A)

- [ ] Fill official names for KPI-001…015 (and chase sponsor list if unclear)  
- [ ] Start claim intake for Cohort A into `data/inventory.csv`  
- [ ] Draft risk language / LEA summary outline  
- [ ] 21 Oct sir status update  
- [ ] Keep toolkit docs updated for the team  

### Tanjim (Dashboard / Cohort B)

- [ ] Freeze schema with Rahat  
- [ ] Build empty dashboard shell that can load redacted CSV/JSON  
- [ ] Start Cohort B claim collection (016–030)  
- [ ] Install Robin toolkit from `SETUP.md` if doing any dark-web checks  

### Apon (Evidence / Cohort C)

- [ ] Own evidence field practice + search-log format  
- [ ] Start Cohort C claim collection (031–045)  
- [ ] Verification / credibility scoring as rows come in  
- [ ] Install Robin toolkit from `SETUP.md` if needed  

---

## 6. Where files live

### Project folder — `/home/nullx-a/Project Dark Hunt/`  
(or your copy of this repo)

```text
README.md
docs/
  MASTER_WRITEUP.md    ← this file
  EXECUTION_PLAN.md
  TEAM.md
  DASHBOARD_PROPOSAL.md
  gantt.html
  NOTION_SETUP.md
data/
  schema.json
  kpi-master.csv
  inventory.csv / inventory.sample.json
templates/daily-report.md
daily/                   # standup notes
*.pdf / *.xlsx           # incident master reports
```

### Research toolkit — `~/robin/` (separate from secrets in git)

```text
SETUP.md                 ← teammate install + daily commands
ARCHITECTURE.md
TeamNullX-Robin-Toolkit-SHARE.tgz   ← zip to send (no .env)
run-robin.sh / stop-robin.sh
run-tor-browser.sh / stop-tor-browser.sh
vpn/project-vpn-on.sh / project-vpn-off.sh
vpn/torrc                ← obfs4 bridges
.env                     ← NEVER share (Gemini + Proton OpenVPN)
```

---

## 7. What “done” looks like on 31 Oct

- All 45 KPIs named and assigned  
- Inventory rows with sources + credibility + recommended actions (redacted)  
- Evidence list with hashes / references where we stored artefacts  
- Dashboard prototype loads sample/redacted data  
- Risk summary in LEA language  
- Consolidated report + Gantt  
- Lead (Rahat) signs the final checklist  

---

## 8. Quick card (paste in WhatsApp / Discord)

```text
Project Dark Hunt — Team NullX
Mission: lawful dark-web/OSINT exposure map for BD 45 KPIs → LEA insights
Deadline: 31 Oct 2026 | 21 Oct = status with sir only
Lead Rahat | Dashboard Tanjim | Evidence Apon
Cohorts: A 1–15 Rahat | B 16–30 Tanjim | C 31–45 Apon
Safe session: ~/robin → project-vpn-on → Tor Browser / Robin → project-vpn-off
Read: docs/MASTER_WRITEUP.md + ~/robin/SETUP.md
Never share .env or raw credentials
```

---

## 9. Contact

Questions on plan, lab Wi‑Fi, or toolkit → **Rahat**  
Questions on dashboard fields → **Tanjim**  
Questions on evidence/verification → **Apon**

**Team NullX · Project Dark Hunt · DIU**
