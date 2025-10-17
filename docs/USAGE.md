# Usage Guide

Comprehensive guide to using Dev Environment Tools.

## Table of Contents

- [Getting Started](#getting-started)
- [Tmux Session Management](#tmux-session-management)
- [Claude Code Integration](#claude-code-integration)
- [Tmux Configuration](#tmux-configuration)
- [Workflows](#workflows)
- [Advanced Usage](#advanced-usage)

## Getting Started

After installation, reload your shell:

```bash
source ~/.bashrc
```

Verify installation:

```bash
# Check aliases
alias | grep -E "(tms|cy|tmls)"

# Check functions
type tmux-switch

# Test tmux config
tmux -V
```

## Tmux Session Management

### Interactive Session Switcher

Launch the interactive session switcher:

```bash
tms
```

**Features:**
- Arrow keys to navigate
- Enter to select
- Escape to cancel
- Create new sessions on the fly
- Switch between existing sessions instantly

### Direct Session Access

Create or switch to a specific session:

```bash
tms my-project
```

**Behavior:**
- If session exists: switches to it
- If session doesn't exist: creates it and switches to it
- Works both inside and outside tmux

### List Sessions

Quick list of all active tmux sessions:

```bash
tmls
```

### Common Workflows

**Start working on a project:**
```bash
tms my-project
cd ~/projects/my-project
```

**Switch between projects:**
```bash
# Use interactive menu
tms

# Or switch directly
tms another-project
```

**Create organized sessions:**
```bash
tms dev-frontend
tms dev-backend
tms monitoring
tms docs
```

## Claude Code Integration

### Launch Claude Code

Quick launch with skip permissions:

```bash
cy
```

**Equivalent to:**
```bash
claude --dangerously-skip-permissions
```

### Use Cases

**Quick edits:**
```bash
cy /path/to/file.js
```

**Project work:**
```bash
cd ~/projects/my-app
cy
```

**Combined with tmux:**
```bash
# Create dedicated Claude session
tms claude-work
cy
```

## Tmux Configuration

### Key Bindings

The included `.tmux.conf` provides:

**Pane Management:**
- `Prefix + |` - Split pane vertically
- `Prefix + -` - Split pane horizontally
- Mouse click - Switch between panes

**Session Management:**
- `Prefix + d` - Detach from session
- Windows automatically renumber when closed
- Base index starts at 1 (not 0)

**Copy Mode:**
- `Prefix + [` - Enter copy mode
- `Ctrl + Left/Right` - Jump by word
- `Home/End` - Jump to line start/end
- Mouse drag - Select text
- Vi-style navigation (j/k/h/l)

**Configuration:**
- `Prefix + r` - Reload tmux configuration

### Customization

Edit your tmux config:
```bash
nano ~/.tmux.conf
```

After changes, reload:
```bash
# Inside tmux
tmux source-file ~/.tmux.conf

# Or use the shortcut
Prefix + r
```

## Workflows

### Development Workflow

**1. Start your day:**
```bash
# Launch or resume dev session
tms dev-main

# Open project
cd ~/projects/main-app

# Start Claude for assistance
cy
```

**2. Switch contexts:**
```bash
# Quick switch to testing
tms testing

# Run tests
npm test
```

**3. End of day:**
```bash
# Detach (sessions keep running)
Prefix + d

# Or list all sessions
tmls
```

### Multi-Project Workflow

**Setup multiple project sessions:**
```bash
# Frontend work
tms frontend
cd ~/projects/frontend
npm run dev

# Backend work (in new session)
tms backend
cd ~/projects/backend
npm start

# Documentation
tms docs
cd ~/projects/docs
```

**Switch between them:**
```bash
# Use interactive switcher
tms

# Or direct switching
tms frontend
tms backend
```

### Remote Development Workflow

**On remote server:**
```bash
# Create persistent session
tms remote-dev

# Start long-running process
npm run dev

# Detach
Prefix + d

# Log out (session keeps running)
exit
```

**Reconnect later:**
```bash
ssh remote-server
tms remote-dev
```

## Advanced Usage

### Nested Tmux Sessions

Working with tmux inside tmux (local + remote):

```bash
# Local session
tms local-work

# SSH to remote
ssh remote-server

# Remote session
tms remote-dev

# Send commands to inner tmux
# Press Prefix twice (e.g., Ctrl+b Ctrl+b) to control inner tmux
```

### Automation Scripts

**Auto-create sessions:**
```bash
#!/bin/bash
# setup-dev-env.sh

tms frontend
tmux send-keys -t frontend "cd ~/projects/frontend && npm run dev" C-m

tms backend
tmux send-keys -t backend "cd ~/projects/backend && npm start" C-m

tms logs
tmux send-keys -t logs "tail -f ~/logs/app.log" C-m
```

### Session Naming Conventions

**Recommended patterns:**
```bash
tms project-feature      # By project and feature
tms dev-frontend         # By role
tms debugging-issue-123  # By task
tms temp-test           # Temporary sessions
```

### Tmux with Screen Splitting

**Create a development layout:**
```bash
# Start session
tms dev-layout

# Split horizontally
Prefix + -

# Split right pane vertically
Prefix + |

# Result: editor on left, terminal top-right, logs bottom-right
```

### Integration with Other Tools

**With Git:**
```bash
tms git-review
git log --oneline | fzf | cut -d' ' -f1 | xargs git show
```

**With Docker:**
```bash
tms docker-dev
docker ps | fzf | cut -d' ' -f1 | xargs docker exec -it bash
```

**With SSH:**
```bash
tms ssh-sessions
cat ~/.ssh/config | grep "^Host " | cut -d' ' -f2 | fzf | xargs ssh
```

## Tips and Tricks

### Performance

**Reduce escape time** (already configured):
```tmux
set -sg escape-time 0
```

**Increase history** (already configured):
```tmux
set -g history-limit 50000
```

### Mouse Support

The configuration enables mouse support, allowing:
- Click to focus panes
- Drag to resize panes
- Scroll to navigate history
- Drag to select text

### Session Persistence

Sessions survive:
- SSH disconnections
- Terminal closures
- System restarts (with tmux-resurrect plugin)

### Keyboard Shortcuts Cheat Sheet

```
Session Management:
  tms              Interactive session switcher
  tms <name>       Create/switch to session
  Prefix + d       Detach from session
  Prefix + $       Rename session

Window Management:
  Prefix + c       Create window
  Prefix + ,       Rename window
  Prefix + n       Next window
  Prefix + p       Previous window

Pane Management:
  Prefix + |       Split vertical
  Prefix + -       Split horizontal
  Prefix + o       Switch pane
  Prefix + x       Close pane
  Prefix + z       Toggle pane zoom

Copy Mode:
  Prefix + [       Enter copy mode
  q                Exit copy mode
  /                Search forward
  ?                Search backward
```

## Troubleshooting Common Issues

### fzf not found

If `tms` reports fzf not found:

```bash
# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
source ~/.bashrc
```

### Aliases not working

```bash
# Reload bashrc
source ~/.bashrc

# Check if aliases exist
alias | grep tms

# Check if functions exist
type tmux-switch
```

### Tmux config not applied

```bash
# Reload tmux config
tmux source-file ~/.tmux.conf

# Or restart tmux server
tmux kill-server
tmux
```

### Session not found

```bash
# List all sessions
tmux list-sessions

# Create new session
tms my-session
```

## Getting Help

For more help:

- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Customization Guide](CUSTOMIZATION.md)
- [Project README](../README.md)
