#!/usr/bin/env bash
# Project Dark Hunt — Package Toolkit for Team (Excludes Secrets)
# Team NullX
set -euo pipefail
cd "$(dirname "$0")"

PACKAGE_NAME="TeamNullX-Robin-Toolkit-SHARE.tgz"
echo "==> Creating clean team share package: $PACKAGE_NAME..."

# Remove any old package
rm -f "$PACKAGE_NAME"

# Archive only code, configs, and scripts — NEVER .env, investigations, or git history
tar --exclude='.env' \
    --exclude='investigations/*' \
    --exclude='.git' \
    --exclude='*.tgz' \
    --exclude='__pycache__' \
    -czf "$PACKAGE_NAME" \
    Dockerfile \
    entrypoint.sh \
    requirements.txt \
    config.py \
    llm.py \
    llm_utils.py \
    model_registry.py \
    models.json \
    pipeline.py \
    prompts.py \
    scrape.py \
    search.py \
    store.py \
    ui.py \
    server.json \
    run-robin.sh \
    stop-robin.sh \
    run-tor-browser.sh \
    stop-tor-browser.sh \
    sanitize-file.sh \
    view-in-sandbox.sh \
    auto_sanitizer.py \
    watch-and-sanitize.sh \
    install-firejail.sh \
    install-dangerzone.sh \
    log-evidence.sh \
    package-toolkit.sh \
    vpn/ \
    .env.example \
    README.md \
    SETUP.md \
    ARCHITECTURE.md \
    "team nullx  project Dark Hunt _ privavcy setup.md" \
    PROJECT_DARK_HUNT_MASTER_WRITEUP.md

echo "=========================================================="
echo "[+] SUCCESS: $PACKAGE_NAME created!"
echo "    Contains: Upgraded Architecture + obfs4 Torrc + Firejail + Killswitch"
echo "    Excluded: .env (API keys), investigations, personal credentials"
echo "    You can now safely share this with Tanjim and Apon!"
echo "=========================================================="
