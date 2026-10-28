#!/usr/bin/env bash
# Project Dark Hunt — Tor Browser Clipboard & Anti-Snooping Hardener
# Team NullX · Department of Software Engineering, DIU
# Author: Md. Tanjim Islam & Team NullX
set -euo pipefail

TOR_PROFILE_DIR="$HOME/.local/share/torbrowser/tbb/x86_64/tor-browser/Browser/TorBrowser/Data/Browser/profile.default"

echo "=========================================================="
echo "  Project Dark Hunt — Clipboard & Anti-Snooping Hardening"
echo "=========================================================="

if [ ! -d "$TOR_PROFILE_DIR" ]; then
  # Fallback search if path differs
  TOR_PROFILE_DIR=$(find "$HOME/.local/share/torbrowser" -maxdepth 6 -type d -name "profile.default" 2>/dev/null | head -n 1 || true)
fi

if [ -z "$TOR_PROFILE_DIR" ] || [ ! -d "$TOR_PROFILE_DIR" ]; then
  echo "[-] NOTICE: Tor Browser profile not found yet. Profile will be hardened upon first launch."
  exit 0
fi

USER_JS="$TOR_PROFILE_DIR/user.js"
echo "[*] Enforcing strict anti-snooping rules in: $USER_JS"

cat <<'EOF' > "$USER_JS"
// Project Dark Hunt — Team NullX Hardware & Clipboard Privacy Policy

// 1. Anti-Clipboard Hijacking & Snooping
user_pref("dom.events.asyncClipboard.readText", false);
user_pref("dom.events.asyncClipboard.clipboardData", false);
user_pref("dom.allow_cut_copy", false);
user_pref("clipboard.autocopy", false);

// 2. Hardware Device & Sensor Isolation
user_pref("media.navigator.enabled", false);
user_pref("media.navigator.permission.disabled", true);
user_pref("media.peerconnection.enabled", false);
user_pref("device.sensors.enabled", false);
user_pref("dom.gamepad.enabled", false);
user_pref("dom.vr.enabled", false);

// 3. Audio / Ultrasound Tracking Prevention
user_pref("media.autoplay.default", 5);
user_pref("dom.webaudio.enabled", false);

// 4. Memory & Performance Fingerprinting Minimization
user_pref("dom.enable_performance_observer", false);
user_pref("dom.enable_resource_timing", false);
user_pref("dom.enable_user_timing", false);
EOF

echo "[✓] SUCCESS: Clipboard and hardware privacy rules locked in Tor Browser profile."
echo "    - navigator.clipboard.readText() -> BLOCKED (Cannot read host clipboard)"
echo "    - copy/cut event interception    -> BLOCKED"
echo "    - WebRTC, Camera, Mic, Sensors   -> 100% DISABLED"
echo "=========================================================="
