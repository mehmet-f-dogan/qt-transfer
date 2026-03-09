#!/bin/bash
set -e

PORT=${PORT:-5000}
PROTO=${PROTO:-TCP}

if [ "$SERVER" = "1" ]; then
    # ── Headless server mode ──────────────────────────────────────────────
    # Tell Qt not to look for a real display — offscreen is a no-op platform
    # plugin that satisfies Qt's platform requirement without needing xcb/X11.
    export QT_QPA_PLATFORM=offscreen
    echo "[entrypoint] Starting headless server on port $PORT (proto: $PROTO)"
    exec /usr/local/bin/app --server --port "$PORT"
else
    # ── GUI client mode ───────────────────────────────────────────────────
    # Prefer an X11 display passed from the host (e.g. via -e DISPLAY).
    # If no display is available, spin up a virtual framebuffer with Xvfb.
    if [ -z "$DISPLAY" ]; then
        echo "[entrypoint] No DISPLAY set — starting Xvfb on :99"
        Xvfb :99 -screen 0 1280x800x24 -nolisten tcp &
        export DISPLAY=:99
        sleep 1
    fi

    echo "[entrypoint] Starting GUI client (DISPLAY=$DISPLAY)"
    export QT_DEBUG_PLUGINS=1
    exec /usr/local/bin/app
fi