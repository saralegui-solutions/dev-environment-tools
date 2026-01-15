#!/bin/bash
#
# tmux Resilience Layer Installer
# Installs 4-layer defense against tmux crashes:
#   Layer 1: tmux 3.6a (fixes segfault bugs)
#   Layer 2: TPM + resurrect/continuum (session persistence)
#   Layer 3: systemd user service (auto-restart)
#   Layer 4: watchdog daemon (crash detection)
#
# Usage: ./install-resilience.sh [--step-by-step] [--skip-upgrade] [--yes]
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Options
STEP_BY_STEP=false
SKIP_UPGRADE=false
AUTO_YES=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --step-by-step)
            STEP_BY_STEP=true
            shift
            ;;
        --skip-upgrade)
            SKIP_UPGRADE=true
            shift
            ;;
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --step-by-step    Pause between each layer for confirmation"
            echo "  --skip-upgrade    Don't upgrade tmux (keep current version)"
            echo "  --yes, -y         Auto-confirm all prompts"
            echo "  --help, -h        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_layer() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}\n"; }

prompt() {
    if [ "$AUTO_YES" = true ]; then return 0; fi
    read -p "$(echo -e "${YELLOW}?${NC} $1 [Y/n]: ")" -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Nn]$ ]]
}

wait_for_step() {
    if [ "$STEP_BY_STEP" = true ]; then
        read -p "Press Enter to continue to next layer..."
    fi
}

# Header
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           tmux Resilience Layer Installer                     ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  4-layer defense against tmux server crashes                  ║"
echo "║                                                               ║"
echo "║  Layer 1: tmux 3.6a upgrade (fixes segfault bugs)             ║"
echo "║  Layer 2: Session persistence (resurrect + continuum)         ║"
echo "║  Layer 3: Auto-recovery (systemd user service)                ║"
echo "║  Layer 4: Crash monitoring (watchdog daemon)                  ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check current tmux version
CURRENT_TMUX_VERSION=$(tmux -V 2>/dev/null | awk '{print $2}' || echo "none")
log_info "Current tmux version: $CURRENT_TMUX_VERSION"

if ! prompt "Install tmux resilience layer?"; then
    log_warning "Installation cancelled"
    exit 0
fi

# ============================================================
# LAYER 1: tmux 3.6a Upgrade
# ============================================================
log_layer "LAYER 1: tmux Version Upgrade"

if [ "$SKIP_UPGRADE" = true ]; then
    log_info "Skipping tmux upgrade (--skip-upgrade specified)"
elif [ "$CURRENT_TMUX_VERSION" = "3.6a" ]; then
    log_success "tmux 3.6a already installed - no upgrade needed"
else
    log_info "tmux 3.4 has known segfault bugs fixed in 3.6a"

    if prompt "Build and install tmux 3.6a from source?"; then
        log_info "Installing build dependencies..."

        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y libevent-dev libncurses-dev build-essential bison pkg-config
        elif command -v brew &> /dev/null; then
            brew install libevent ncurses
        else
            log_warning "Cannot install dependencies - manual installation required"
        fi

        log_info "Downloading tmux 3.6a..."
        cd /tmp
        wget -q https://github.com/tmux/tmux/releases/download/3.6a/tmux-3.6a.tar.gz
        tar -xzf tmux-3.6a.tar.gz

        log_info "Building tmux 3.6a (this may take a minute)..."
        cd tmux-3.6a
        ./configure --prefix=/usr/local > /dev/null 2>&1
        make -j$(nproc) > /dev/null 2>&1

        log_info "Installing tmux 3.6a..."
        sudo make install > /dev/null 2>&1

        # Verify
        if /usr/local/bin/tmux -V | grep -q "3.6a"; then
            log_success "tmux 3.6a installed successfully"
        else
            log_error "tmux installation may have failed - please verify"
        fi

        # Cleanup
        rm -rf /tmp/tmux-3.6a /tmp/tmux-3.6a.tar.gz
    else
        log_warning "Skipping tmux upgrade - you may still experience crashes"
    fi
fi

wait_for_step

# ============================================================
# LAYER 2: Session Persistence (TPM + plugins)
# ============================================================
log_layer "LAYER 2: Session Persistence"

# Install TPM
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    log_success "TPM already installed"
else
    log_info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    log_success "TPM installed"
fi

# Check if resilience config already in tmux.conf
if grep -q "TMUX RESILIENCE LAYER" "$HOME/.tmux.conf" 2>/dev/null; then
    log_success "Resilience config already in ~/.tmux.conf"
else
    log_info "Adding resilience config to ~/.tmux.conf..."

    # Backup existing config
    if [ -f "$HOME/.tmux.conf" ]; then
        cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup-$(date +%Y%m%d-%H%M%S)"
        log_info "Backed up existing config"
    fi

    # Append resilience config
    cat "$SCRIPT_DIR/config/tmux-resilience.conf" >> "$HOME/.tmux.conf"
    log_success "Resilience config added to ~/.tmux.conf"
fi

log_info "Installing tmux plugins..."
log_info "After tmux starts, press: prefix + I (capital I) to install plugins"

wait_for_step

# ============================================================
# LAYER 3: Systemd Auto-Recovery
# ============================================================
log_layer "LAYER 3: Systemd Auto-Recovery"

mkdir -p "$HOME/.config/systemd/user"

# Install tmux.service
log_info "Installing tmux systemd service..."
cp "$SCRIPT_DIR/systemd/tmux.service" "$HOME/.config/systemd/user/"
log_success "tmux.service installed"

# Install watchdog service
log_info "Installing watchdog systemd service..."
cp "$SCRIPT_DIR/systemd/tmux-watchdog.service" "$HOME/.config/systemd/user/"

# Update watchdog service to use correct path
sed -i "s|/home/ben|$HOME|g" "$HOME/.config/systemd/user/tmux-watchdog.service"

log_success "tmux-watchdog.service installed"

# Enable services
log_info "Enabling systemd services..."
systemctl --user daemon-reload
systemctl --user enable tmux.service tmux-watchdog.service

log_success "Services enabled (will start on next login)"

wait_for_step

# ============================================================
# LAYER 4: Watchdog Daemon
# ============================================================
log_layer "LAYER 4: Crash Watchdog"

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/tmux"

log_info "Installing watchdog script..."
cp "$SCRIPT_DIR/scripts/tmux-watchdog.sh" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/tmux-watchdog.sh"
log_success "Watchdog script installed at ~/.local/bin/tmux-watchdog.sh"

# Ensure ~/.local/bin is in PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    log_warning "~/.local/bin is not in your PATH"
    log_info "Add this to your ~/.bashrc:"
    echo '    export PATH="$HOME/.local/bin:$PATH"'
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           Installation Complete!                              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
log_success "All 4 layers installed successfully"
echo ""
log_info "Next steps:"
echo "  1. Kill your current tmux server: tmux kill-server"
echo "  2. Log out and back in (or: systemctl --user start tmux)"
echo "  3. Attach to tmux: tmux attach -t main"
echo "  4. Install plugins: Press prefix + I (capital I)"
echo ""
log_info "Manual commands:"
echo "  • Save session:    prefix + Ctrl-s"
echo "  • Restore session: prefix + Ctrl-r"
echo ""
log_info "Logs and data:"
echo "  • Session saves:   ~/.tmux/resurrect/"
echo "  • Watchdog log:    ~/.local/share/tmux/watchdog.log"
echo ""

# Show current tmux version
NEW_VERSION=$(/usr/local/bin/tmux -V 2>/dev/null || tmux -V)
log_info "tmux version: $NEW_VERSION"

if [ "$NEW_VERSION" != "tmux 3.6a" ] && [ "$SKIP_UPGRADE" != true ]; then
    log_warning "Note: Ensure /usr/local/bin is before /usr/bin in your PATH"
fi
