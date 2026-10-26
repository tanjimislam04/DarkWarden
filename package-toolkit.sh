#!/usr/bin/env bash
# Project Dark Hunt — Package Toolkit for Team (Excludes Secrets)
# Team NullX
set -euo pipefail
cd "$(dirname "$0")"

PACKAGE_NAME="TeamNullX-SafeTor-Toolkit-SHARE.tgz"
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
    LICENSE

echo "=========================================================="
echo "[+] SUCCESS: $PACKAGE_NAME created!"
echo "    Contains: 6-Layer Architecture + obfs4 Torrc + Firejail + Killswitch + Sanitizer"
echo "    Excluded: .env (API keys), investigations, personal credentials"
echo "    You can now safely share this with Rafi, Tanjim, and Apon!"
echo "=========================================================="
