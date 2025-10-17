# Troubleshooting Guide

Common issues and solutions for Dev Environment Tools.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Dependency Problems](#dependency-problems)
- [Configuration Issues](#configuration-issues)
- [Runtime Errors](#runtime-errors)
- [Platform-Specific Issues](#platform-specific-issues)

## Installation Issues

### Permission Denied

**Problem:**
```bash
bash: ./scripts/install.sh: Permission denied
```

**Solution:**
```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

### Git Not Installed

**Problem:**
```
bash: git: command not found
```

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install git

# macOS
brew install git

# RHEL/CentOS
sudo yum install git
```

### Installation Script Fails

**Problem:**
Installation stops with errors.

**Solution:**
```bash
# Run with verbose output
bash -x scripts/install.sh

# Skip dependency installation
./scripts/install.sh --skip-deps

# Check for required commands
command -v bash git curl
```

## Dependency Problems

### fzf Not Found

**Problem:**
```
bash: fzf: command not found
```

**Solution:**
```bash
# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

# Add to bashrc if not automatic
echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' >> ~/.bashrc
source ~/.bashrc

# Verify
fzf --version
```

### Node.js Not Found

**Problem:**
```
bash: node: command not found
bash: npm: command not found
```

**Solution:**
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js
nvm install --lts
nvm use --lts

# Verify
node --version
npm --version
```

### Claude Code Not Found

**Problem:**
```
bash: claude: command not found
```

**Solution:**
```bash
# Ensure Node.js is installed
node --version

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Check installation
claude --version

# If still not found, check PATH
echo $PATH | grep -o "$HOME/.nvm"

# Add to PATH if needed
export PATH="$HOME/.nvm/versions/node/$(nvm current)/bin:$PATH"
```

### tmux Too Old

**Problem:**
```
tmux: protocol version mismatch
```

**Solution:**
```bash
# Check version
tmux -V

# Upgrade tmux (Ubuntu/Debian)
sudo apt update
sudo apt install tmux

# macOS
brew upgrade tmux

# Build from source (if needed)
git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure && make
sudo make install
```

## Configuration Issues

### Aliases Not Working

**Problem:**
```bash
tms
bash: tms: command not found
```

**Solution:**
```bash
# Check if bashrc was sourced
source ~/.bashrc

# Verify alias exists
alias | grep tms

# Check if bash_functions.sh was added
grep -q "Dev Environment Tools" ~/.bashrc
echo $?  # Should output 0

# Manually add if missing
cat config/bash_functions.sh >> ~/.bashrc
source ~/.bashrc
```

### Tmux Config Not Applied

**Problem:**
Tmux doesn't reflect configuration changes.

**Solution:**
```bash
# Verify config file exists
ls -la ~/.tmux.conf

# Reload config
tmux source-file ~/.tmux.conf

# If inside tmux, use shortcut
# Prefix + r

# Kill tmux server and restart
tmux kill-server
tmux

# Check for syntax errors
tmux -f ~/.tmux.conf
```

### Backup Files Not Created

**Problem:**
Installation doesn't create backups.

**Solution:**
```bash
# Manually create backup
mkdir -p ~/.config/dev-tools-backup-$(date +%Y%m%d-%H%M%S)
cp ~/.tmux.conf ~/.config/dev-tools-backup-$(date +%Y%m%d-%H%M%S)/

# Run installer with auto-confirm
./scripts/install.sh --yes
```

## Runtime Errors

### tmux-switch Shows Error

**Problem:**
```
error connecting to /tmp/tmux-1000/default
```

**Solution:**
```bash
# Check tmux is running
ps aux | grep tmux

# Check socket directory permissions
ls -la /tmp/tmux-$(id -u)/

# Fix permissions if needed
chmod 700 /tmp/tmux-$(id -u)/

# Restart tmux server
tmux kill-server
tmux
```

### fzf Menu Doesn't Appear

**Problem:**
`tms` doesn't show interactive menu.

**Solution:**
```bash
# Check if fzf is in PATH
which fzf

# If not found, source fzf
source ~/.fzf.bash

# Test fzf directly
echo -e "option1\noption2\noption3" | fzf

# Check terminal support
echo $TERM
# Should be: screen-256color, xterm-256color, or similar
```

### Session Creation Fails

**Problem:**
```
tmux: invalid session
```

**Solution:**
```bash
# Check for special characters in session name
# Avoid: ./:[]

# Use valid session names
tms dev-work      # Good
tms "dev:work"    # Bad

# List existing sessions
tmux list-sessions

# Kill problematic session
tmux kill-session -t session-name
```

### Mouse Not Working in Tmux

**Problem:**
Can't click or scroll in tmux.

**Solution:**
```bash
# Check tmux config
grep mouse ~/.tmux.conf
# Should show: set -g mouse on

# Reload config
tmux source-file ~/.tmux.conf

# Check terminal support
echo $TERM

# For some terminals, enable mouse events
# In tmux config:
# set -g mouse on
# set-option -g mouse on
```

## Platform-Specific Issues

### macOS Issues

**Problem:**
`tmux` command differs from Linux.

**Solution:**
```bash
# Install tmux via Homebrew
brew install tmux

# macOS uses different clipboard
# Update ~/.tmux.conf for macOS
# Use: reattach-to-user-namespace for clipboard

# Install reattach-to-user-namespace
brew install reattach-to-user-namespace
```

**macOS Copy/Paste:**
```tmux
# Add to ~/.tmux.conf
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"
```

### WSL Issues

**Problem:**
Clipboard integration doesn't work.

**Solution:**
```bash
# Install wslu for WSL clipboard
sudo apt install wslu

# Update ~/.tmux.conf
# bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "clip.exe"
```

### SSH Connection Issues

**Problem:**
Configurations not available over SSH.

**Solution:**
```bash
# Ensure bashrc is sourced for SSH
# Add to ~/.bashrc
if [ -n "$SSH_CONNECTION" ]; then
    export PS1="(ssh) $PS1"
fi

# Check if .bashrc is sourced
ssh remote-server 'echo $SHELL'
ssh remote-server 'type tms'

# Force source on login
# Add to ~/.bash_profile
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
```

### Terminal Emulator Issues

**Problem:**
Key bindings don't work in certain terminals.

**Solution:**
```bash
# Check terminal capabilities
infocmp $TERM

# Try different TERM settings
export TERM=xterm-256color

# Or in tmux config
set -g default-terminal "screen-256color"

# For problematic terminals, use different prefix
# Edit ~/.tmux.conf
# set -g prefix C-a
# unbind C-b
```

## Diagnostic Commands

### System Information

```bash
# Check system
uname -a
cat /etc/os-release

# Check shell
echo $SHELL
bash --version

# Check environment
env | grep -E "(PATH|TERM|SHELL)"
```

### Dependency Versions

```bash
# Check all tools
tmux -V
fzf --version
node --version
npm --version
claude --version

# Check where commands are located
which tmux fzf node npm claude
```

### Configuration Files

```bash
# Check if files exist
ls -la ~/.tmux.conf
ls -la ~/.fzf.bash
ls -la ~/.bashrc

# Check recent modifications
ls -lt ~/ | grep -E "(tmux|bash|fzf)" | head

# Check bashrc contents
grep "Dev Environment Tools" ~/.bashrc
```

### Tmux Diagnostics

```bash
# List sessions
tmux list-sessions

# Server info
tmux info

# List clients
tmux list-clients

# Check socket
ls -la /tmp/tmux-$(id -u)/
```

## Getting More Help

### Enable Debug Mode

```bash
# Run installer with bash debug
bash -x scripts/install.sh

# Tmux verbose
tmux -v

# Check logs
journalctl --user -u tmux
```

### Collect Information

When reporting issues, include:

```bash
# System info
uname -a
cat /etc/os-release

# Versions
bash --version
tmux -V
fzf --version

# Configuration
head -20 ~/.tmux.conf
grep "tmux-switch" ~/.bashrc

# Error messages
# Copy exact error output
```

### Reset to Clean State

```bash
# Backup current config
mv ~/.tmux.conf ~/.tmux.conf.backup
mv ~/.bashrc ~/.bashrc.backup

# Reinstall
cd dev-environment-tools
./scripts/install.sh --yes

# Restore if needed
mv ~/.tmux.conf.backup ~/.tmux.conf
mv ~/.bashrc.backup ~/.bashrc
```

## Common Error Messages

### "command not found"

**Causes:**
- Not in PATH
- Not installed
- Not sourced

**Fix:**
```bash
source ~/.bashrc
hash -r  # Clear command cache
```

### "Permission denied"

**Causes:**
- File not executable
- Directory permissions

**Fix:**
```bash
chmod +x scripts/install.sh
chmod 700 ~/.ssh  # If SSH related
```

### "No such file or directory"

**Causes:**
- Wrong path
- File not created

**Fix:**
```bash
# Check actual location
find ~ -name "tmux.conf"
find ~ -name "bash_functions.sh"
```

## Still Having Issues?

If you're still experiencing problems:

1. **Check Documentation**: Review [USAGE.md](USAGE.md) and [CUSTOMIZATION.md](CUSTOMIZATION.md)
2. **Create Issue**: [GitHub Issues](https://github.com/saralegui-solutions/dev-environment-tools/issues)
3. **Include Details**: System info, error messages, steps to reproduce
