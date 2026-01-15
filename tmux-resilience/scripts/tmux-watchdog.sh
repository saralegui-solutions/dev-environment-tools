#!/bin/bash
# tmux-watchdog.sh - Crash detection and notification for tmux
# Part of the tmux resilience layer
# Created: 2026-01-15

LOGFILE="${HOME}/.local/share/tmux/watchdog.log"
NOTIFY_CMD="notify-send"
CHECK_INTERVAL=10

mkdir -p "$(dirname "$LOGFILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

log "Watchdog started (PID: $$)"

# Track tmux server PID to detect crashes (not just absence)
LAST_TMUX_PID=""

while true; do
    CURRENT_TMUX_PID=$(pgrep -x tmux | head -1)

    if [ -z "$CURRENT_TMUX_PID" ]; then
        # tmux not running - check if it was running before (crash) or never started
        if [ -n "$LAST_TMUX_PID" ]; then
            log "CRASH DETECTED: tmux server (was PID $LAST_TMUX_PID) is no longer running"

            # Send desktop notification if available
            if command -v $NOTIFY_CMD &> /dev/null; then
                $NOTIFY_CMD -u critical "tmux Crashed" "Server crashed. Restarting via systemd..."
            fi

            # Let systemd handle restart
            systemctl --user restart tmux.service 2>/dev/null
            log "Triggered systemd restart"

            # Wait for restart
            sleep 5
            NEW_PID=$(pgrep -x tmux | head -1)
            if [ -n "$NEW_PID" ]; then
                log "tmux restarted successfully (new PID: $NEW_PID)"
                LAST_TMUX_PID="$NEW_PID"
            else
                log "WARNING: tmux failed to restart"
            fi
        fi
    else
        # tmux is running
        if [ "$CURRENT_TMUX_PID" != "$LAST_TMUX_PID" ]; then
            if [ -n "$LAST_TMUX_PID" ]; then
                log "tmux PID changed: $LAST_TMUX_PID -> $CURRENT_TMUX_PID (possible restart)"
            else
                log "tmux server found (PID: $CURRENT_TMUX_PID)"
            fi
            LAST_TMUX_PID="$CURRENT_TMUX_PID"
        fi
    fi

    sleep $CHECK_INTERVAL
done
