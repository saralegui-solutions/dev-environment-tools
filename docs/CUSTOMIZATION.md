# Customization Guide

How to customize and extend Dev Environment Tools for your workflow.

## Table of Contents

- [Tmux Configuration](#tmux-configuration)
- [Shell Functions](#shell-functions)
- [Aliases](#aliases)
- [Key Bindings](#key-bindings)
- [Color Schemes](#color-schemes)
- [Advanced Customization](#advanced-customization)

## Tmux Configuration

### Editing Tmux Config

Your tmux configuration is at `~/.tmux.conf`.

**Edit the file:**
```bash
nano ~/.tmux.conf
```

**Reload after changes:**
```bash
tmux source-file ~/.tmux.conf
# Or inside tmux: Prefix + r
```

### Common Customizations

#### Change Prefix Key

Default is `Ctrl+b`. Change to `Ctrl+a`:

```tmux
# Unbind default prefix
unbind C-b

# Set new prefix
set -g prefix C-a

# Allow sending prefix to applications
bind C-a send-prefix
```

#### Adjust Status Bar

```tmux
# Position (top or bottom)
set -g status-position bottom

# Update interval
set -g status-interval 1

# Center window list
set -g status-justify centre

# Status bar colors
set -g status-style bg=black,fg=white

# Current window highlight
setw -g window-status-current-style bg=blue,fg=white,bold
```

#### Mouse Configuration

```tmux
# Enable mouse (already enabled by default)
set -g mouse on

# Disable mouse
set -g mouse off

# Mouse scrolling speed
bind -n WheelUpPane select-pane -t= \; copy-mode -e \; send-keys -M
bind -n WheelDownPane select-pane -t= \; send-keys -M
```

#### History Settings

```tmux
# Increase scrollback buffer (default: 50000)
set -g history-limit 100000

# Decrease for memory savings
set -g history-limit 10000
```

#### Window/Pane Settings

```tmux
# Start window numbering at 0 instead of 1
set -g base-index 0

# Don't renumber windows
set -g renumber-windows off

# Automatically rename windows
setw -g automatic-rename on

# Set window title
set -g set-titles on
set -g set-titles-string '#h:#S.#I.#P #W'
```

## Shell Functions

### Customizing tmux-switch

Edit `~/.bashrc` or create `~/.bash_functions`:

#### Change FZF Appearance

```bash
tmux-switch() {
    # ... existing code ...

    # Customize fzf appearance
    local selection=$(echo "$options" | fzf \
        --prompt="SELECT SESSION: " \
        --height=60% \
        --border=sharp \
        --color=dark \
        --preview='tmux list-windows -t {}' \
        --preview-window=right:50% \
        --reverse)

    # ... rest of function ...
}
```

#### Add Session Preview

```bash
# Show session details in fzf
local selection=$(echo "$sessions" | fzf \
    --preview='tmux list-windows -t {} | head -10' \
    --preview-window=right:60%)
```

#### Auto-Start Command in New Session

```bash
tmux-switch() {
    # ... after session creation ...

    # Auto-start command in new sessions
    if [ "$selection" = "[CREATE NEW SESSION]" ]; then
        read -p "Enter new session name: " session_name
        read -p "Start directory [$(pwd)]: " start_dir
        start_dir=${start_dir:-$(pwd)}

        tmux new-session -d -s "$session_name" -c "$start_dir"
        tmux switch-client -t "$session_name"
    fi
}
```

### Creating Custom Functions

Add to `~/.bashrc`:

```bash
# Quick session with preset directory
tms-project() {
    local project="$1"
    tms "$project"
    cd ~/projects/"$project"
}

# Session with split layout
tms-dev() {
    local session="$1"
    tms "$session"
    tmux split-window -h
    tmux split-window -v
    tmux select-pane -t 0
}

# Kill all sessions except current
tms-clean() {
    tmux list-sessions | grep -v attached | cut -d: -f1 | xargs -I {} tmux kill-session -t {}
}
```

## Aliases

### Adding More Aliases

Edit `~/.bashrc`:

```bash
# Tmux aliases
alias tma='tmux attach-session -t'       # Attach to session
alias tmk='tmux kill-session -t'         # Kill session
alias tmn='tmux new-session -s'          # New named session

# Combined tmux + directory
alias tms-home='tms home && cd ~'
alias tms-work='tms work && cd ~/projects'

# Claude Code variations
alias cyw='cy --working-directory'       # Specify working directory
alias cyv='cy --verbose'                 # Verbose mode

# Quick session shortcuts
alias dev='tms development'
alias test='tms testing'
alias prod='tms production'
```

### Conditional Aliases

```bash
# Different behavior on different machines
if [[ $(hostname) == "laptop" ]]; then
    alias tms-default='tms laptop-work'
elif [[ $(hostname) == "desktop" ]]; then
    alias tms-default='tms desktop-work'
fi

# SSH-specific aliases
if [ -n "$SSH_CONNECTION" ]; then
    alias tms='tms remote-$(hostname)'
fi
```

## Key Bindings

### Custom Tmux Key Bindings

Add to `~/.tmux.conf`:

```tmux
# Switch windows with Alt+Arrow (no prefix needed)
bind -n M-Left previous-window
bind -n M-Right next-window

# Switch panes with Alt+hjkl (no prefix needed)
bind -n M-h select-pane -L
bind -n M-j select-pane -D
bind -n M-k select-pane -U
bind -n M-l select-pane -R

# Resize panes
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Quick pane layouts
bind = select-layout tiled
bind + select-layout main-horizontal
bind _ select-layout main-vertical

# Synchronize panes toggle
bind S set-window-option synchronize-panes

# Clear screen and history
bind C-l send-keys 'C-l' \; clear-history
```

### Readline Key Bindings

Edit `~/.inputrc`:

```bash
# Vi mode
set editing-mode vi

# Or emacs mode (default)
set editing-mode emacs

# Show vi mode in prompt
set show-mode-in-prompt on
```

## Color Schemes

### Tmux Color Themes

#### Solarized Dark

Add to `~/.tmux.conf`:

```tmux
# Solarized Dark colors
set -g status-style bg=colour235,fg=colour136
setw -g window-status-style fg=colour244
setw -g window-status-current-style fg=colour166,bg=default,bright
set -g pane-border-style fg=colour235
set -g pane-active-border-style fg=colour240
set -g message-style bg=colour235,fg=colour166
```

#### Dracula Theme

```tmux
# Dracula colors
set -g status-style bg=colour236,fg=colour141
setw -g window-status-current-style fg=colour212,bg=colour236,bold
set -g pane-border-style fg=colour238
set -g pane-active-border-style fg=colour141
```

#### Nord Theme

```tmux
# Nord colors
set -g status-style bg=colour0,fg=colour7
setw -g window-status-current-style fg=colour4,bg=colour0,bold
set -g pane-border-style fg=colour0
set -g pane-active-border-style fg=colour4
```

### Terminal Color Test

```bash
# Test 256 colors
for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolor%-5i\x1b[0m" $i
    if ! (( ($i + 1) % 8 )); then
        echo
    fi
done
```

## Advanced Customization

### Session Templates

Create session templates:

```bash
# ~/.tmux-templates/dev.sh
#!/bin/bash
SESSION="dev-$1"

tmux new-session -d -s $SESSION
tmux rename-window -t $SESSION:0 'editor'
tmux send-keys -t $SESSION:0 'vim' C-m

tmux new-window -t $SESSION:1 -n 'terminal'
tmux send-keys -t $SESSION:1 'cd ~/projects/'$1 C-m

tmux new-window -t $SESSION:2 -n 'server'
tmux send-keys -t $SESSION:2 'npm run dev' C-m

tmux select-window -t $SESSION:0
tmux attach-session -t $SESSION
```

**Usage:**
```bash
bash ~/.tmux-templates/dev.sh my-project
```

### Plugin Integration

**Install TPM (Tmux Plugin Manager):**

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**Add to `~/.tmux.conf`:**
```tmux
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Initialize plugin manager (keep at bottom)
run '~/.tmux/plugins/tpm/tpm'
```

**Install plugins:**
```
Prefix + I
```

### FZF Customization

**Custom FZF options in functions:**

```bash
# ~/.bashrc or ~/.bash_functions

export FZF_DEFAULT_OPTS='
  --height 60%
  --border sharp
  --color dark
  --prompt "⚡ "
  --pointer "▶"
  --marker "✓"
'

# Or customize per command
export FZF_TMUX_OPTS='-p 80%,60%'
```

### Environment-Specific Configs

```bash
# ~/.bashrc

# Load machine-specific config
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi

# Load work-specific config
if [[ $(hostname) == work-* ]]; then
    source ~/.bashrc.work
fi
```

### Integration with Claude Code

**Project-specific Claude config:**

```bash
# Function to start Claude with project config
cyp() {
    local project="$1"
    local config="$HOME/.claude-configs/${project}.json"

    if [ -f "$config" ]; then
        cy --config "$config"
    else
        cy
    fi
}
```

### Automation Scripts

**Auto-restore sessions on boot:**

```bash
# ~/.config/systemd/user/tmux.service

[Unit]
Description=Tmux Session Restore

[Service]
Type=forking
ExecStart=/usr/bin/tmux new-session -d -s auto-restore
ExecStart=/usr/bin/tmux send-keys -t auto-restore 'tms work' C-m

[Install]
WantedBy=default.target
```

**Enable:**
```bash
systemctl --user enable tmux.service
systemctl --user start tmux.service
```

## Configuration Examples

### Minimal Setup

For low-resource machines:

```tmux
# ~/.tmux.conf - minimal
set -g mouse on
set -g history-limit 5000
set -g status off
set -sg escape-time 0
```

### Power User Setup

For intensive development:

```tmux
# ~/.tmux.conf - power user
set -g mouse on
set -g history-limit 100000
set -g status-interval 1
set -sg escape-time 0

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'

# Auto-save sessions
set -g @continuum-restore 'on'
```

### Remote Development Setup

For SSH environments:

```bash
# ~/.bashrc - remote setup

# Auto-attach or create main session on login
if [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
    tmux new-session -A -s main
fi

# SSH-aware prompt
if [ -n "$SSH_CONNECTION" ]; then
    export PS1="[\u@\h-REMOTE] \w $ "
fi
```

## Sharing Your Configuration

**Export your config:**

```bash
# Create shareable package
mkdir ~/my-dev-config
cp ~/.tmux.conf ~/my-dev-config/
grep -A 100 "Dev Environment Tools" ~/.bashrc > ~/my-dev-config/bash_functions.sh
```

**Create installer:**

```bash
# ~/my-dev-config/install.sh
#!/bin/bash
cp tmux.conf ~/.tmux.conf
cat bash_functions.sh >> ~/.bashrc
echo "Configuration installed!"
```

## Getting Help

For more information:

- [Usage Guide](USAGE.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Main README](../README.md)
