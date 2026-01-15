# tmux Resilience Layer

A comprehensive solution to prevent and recover from tmux server crashes. Born from a real-world incident where a tmux 3.4 segmentation fault killed all active sessions during a voice-to-Claude Code testing session.

## The Problem

On January 15, 2026, all tmux sessions crashed simultaneously:

```
kernel: tmux: server[5295]: segfault at 5b766ab22d64 ip 00005b4e4694ac3c sp 00007ffcf5c6f210 error 4 in tmux[5b4e46908000+af000]
```

**Root cause:** Known bugs in tmux 3.4 related to ncurses API incompatibility, triggered by:
- Mouse operations
- Copy/paste in vi mode
- Long-running sessions with heavy usage

When the tmux server crashes, **ALL sessions under that server are lost instantly** - there's no recovery.

## The Solution: 4-Layer Defense

```
┌─────────────────────────────────────────────────────────────────┐
│                    TMUX RESILIENCE LAYERS                       │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 1: Fix Root Cause          │  Upgrade tmux 3.4 → 3.6a   │
├───────────────────────────────────┼─────────────────────────────┤
│  LAYER 2: Session Persistence     │  TPM + resurrect/continuum │
├───────────────────────────────────┼─────────────────────────────┤
│  LAYER 3: Auto-Recovery           │  Systemd user service      │
├───────────────────────────────────┼─────────────────────────────┤
│  LAYER 4: Monitoring              │  Crash detection + alerts  │
└───────────────────────────────────┴─────────────────────────────┘
```

## Quick Install

```bash
# One-command installation
./install-resilience.sh

# Or step by step:
./install-resilience.sh --step-by-step
```

## What's Included

### Layer 1: tmux 3.6a Upgrade
- Fixes ALL known segfault bugs from tmux 3.4
- Build script for systems stuck on old package versions
- Preserves existing tmux configuration

### Layer 2: Session Persistence
- **tmux-resurrect:** Saves session state to disk
- **tmux-continuum:** Auto-saves every 5 minutes
- **TPM (Tmux Plugin Manager):** Manages plugins

**What gets saved:**
- All sessions, windows, and panes
- Working directories per pane
- Window/pane layouts
- Scrollback history (optional)
- Vim/Neovim sessions

**What doesn't survive:**
- Running processes mid-execution
- Environment variables
- Shell functions

### Layer 3: Systemd Auto-Recovery
- User-level systemd service for tmux
- Auto-restarts on crash within 3 seconds
- Starts automatically on login

### Layer 4: Crash Watchdog
- Monitors tmux server health
- Desktop notifications on crash
- Logs all crash events
- Triggers systemd restart

## Manual Commands

After installation, you can manually save/restore:

| Action | Keybinding |
|--------|------------|
| Save session | `prefix + Ctrl-s` |
| Restore session | `prefix + Ctrl-r` |
| Reload tmux config | `prefix + r` |

## Directory Structure

```
tmux-resilience/
├── config/
│   └── tmux-resilience.conf    # Config to append to .tmux.conf
├── scripts/
│   └── tmux-watchdog.sh        # Crash monitoring daemon
├── systemd/
│   ├── tmux.service            # tmux server as systemd service
│   └── tmux-watchdog.service   # Watchdog as systemd service
├── install-resilience.sh       # Main installer
└── README.md                   # This file
```

## Troubleshooting

### Plugins not loading
```bash
# Verify TPM is installed
ls ~/.tmux/plugins/tpm

# Manually install plugins (inside tmux)
# Press: prefix + I (capital I)
```

### systemd services not starting
```bash
# Check service status
systemctl --user status tmux
systemctl --user status tmux-watchdog

# View logs
journalctl --user -u tmux -f
```

### Session not auto-restoring
```bash
# Check resurrect save files
ls ~/.tmux/resurrect/

# Manual restore
# Inside tmux, press: prefix + Ctrl-r
```

### tmux version still old after upgrade
```bash
# Check which tmux is being used
which tmux
/usr/local/bin/tmux -V  # Should be 3.6a
/usr/bin/tmux -V        # System version (probably 3.4)

# Ensure /usr/local/bin is first in PATH
echo $PATH
```

## Recovery After a Crash

If your sessions crashed BEFORE installing this solution:

1. **Sessions are gone** - tmux server crashes are unrecoverable
2. Install this solution to prevent future crashes
3. If using Claude Code, restart your sessions manually
4. Future crashes will auto-recover within ~5 seconds

## Technical Details

### Why tmux 3.4 crashes
- ncurses >= 6.4-20230408 changed internal APIs
- tmux 3.4 wasn't updated for these changes
- Mouse clicks and copy operations trigger undefined behavior
- Result: segmentation fault crashes the entire server

### Why tmux 3.6a is safe
- Released December 5, 2024
- Complete rewrite of ncurses interaction layer
- Extensive testing with newer ncurses versions
- Also fixes format string vulnerabilities

### Session save format
resurrect saves to `~/.tmux/resurrect/last`:
```
pane    session_name    window_index    :window_name    window_active    ...
```

### Watchdog behavior
- Checks every 10 seconds (configurable)
- Detects PID changes (restart detection)
- Logs to `~/.local/share/tmux/watchdog.log`
- Uses desktop notifications if available

## Contributing

Found an issue or improvement? Open a PR at:
https://github.com/saralegui-solutions/dev-environment-tools

## License

MIT License - See LICENSE file in repository root.
