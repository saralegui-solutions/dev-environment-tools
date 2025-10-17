#!/bin/bash
#
# Dev Environment Tools Installer
# Installs tmux configuration, aliases, and dependencies
#
# Usage: ./install.sh [--yes] [--skip-deps]
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
AUTO_YES=false
SKIP_DEPS=false
BACKUP_DIR="$HOME/.config/dev-tools-backup-$(date +%Y%m%d-%H%M%S)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--yes] [--skip-deps]"
            echo ""
            echo "Options:"
            echo "  --yes, -y        Auto-confirm all prompts"
            echo "  --skip-deps      Skip dependency installation"
            echo "  --help, -h       Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Prompt function
prompt_yes_no() {
    if [ "$AUTO_YES" = true ]; then
        return 0
    fi

    local prompt="$1"
    read -p "$(echo -e "${YELLOW}?${NC} $prompt [y/N]: ")" -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Check if running on supported system
check_system() {
    log_info "Checking system compatibility..."

    if [[ ! "$OSTYPE" =~ ^(linux|darwin) ]]; then
        log_error "Unsupported operating system: $OSTYPE"
        log_error "This installer supports Linux and macOS only"
        exit 1
    fi

    log_success "System compatible: $OSTYPE"
}

# Check and install dependencies
install_dependencies() {
    if [ "$SKIP_DEPS" = true ]; then
        log_info "Skipping dependency installation (--skip-deps specified)"
        return 0
    fi

    log_info "Checking dependencies..."

    local missing_deps=()

    # Check tmux
    if ! command -v tmux &> /dev/null; then
        missing_deps+=("tmux")
    else
        log_success "tmux $(tmux -V) found"
    fi

    # Check fzf
    if ! command -v fzf &> /dev/null && [ ! -f "$HOME/.fzf/bin/fzf" ]; then
        missing_deps+=("fzf")
    else
        log_success "fzf found"
    fi

    # Check node (for Claude Code)
    if ! command -v node &> /dev/null; then
        missing_deps+=("node")
    else
        log_success "node $(node --version) found"
    fi

    # Check Claude Code
    if ! command -v claude &> /dev/null; then
        missing_deps+=("claude")
    else
        log_success "Claude Code $(claude --version 2>/dev/null | head -1) found"
    fi

    if [ ${#missing_deps[@]} -eq 0 ]; then
        log_success "All dependencies satisfied"
        return 0
    fi

    log_warning "Missing dependencies: ${missing_deps[*]}"

    if ! prompt_yes_no "Install missing dependencies?"; then
        log_warning "Skipping dependency installation"
        return 0
    fi

    # Install dependencies
    for dep in "${missing_deps[@]}"; do
        case $dep in
            tmux)
                install_tmux
                ;;
            fzf)
                install_fzf
                ;;
            node)
                install_node
                ;;
            claude)
                install_claude_code
                ;;
        esac
    done
}

install_tmux() {
    log_info "Installing tmux..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y tmux
    elif command -v brew &> /dev/null; then
        brew install tmux
    elif command -v yum &> /dev/null; then
        sudo yum install -y tmux
    else
        log_error "Cannot install tmux: package manager not found"
        return 1
    fi

    log_success "tmux installed"
}

install_fzf() {
    log_info "Installing fzf..."

    if [ -d "$HOME/.fzf" ]; then
        log_warning "fzf directory already exists at ~/.fzf"
        cd "$HOME/.fzf" && git pull
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    fi

    "$HOME/.fzf/install" --all --no-bash --no-zsh --no-fish

    log_success "fzf installed"
}

install_node() {
    log_info "Installing Node.js via nvm..."

    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    else
        log_info "nvm already installed"
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    nvm install --lts
    nvm use --lts

    log_success "Node.js $(node --version) installed"
}

install_claude_code() {
    log_info "Installing Claude Code..."

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    npm install -g @anthropic-ai/claude-code

    log_success "Claude Code installed"
}

# Backup existing configurations
backup_configs() {
    log_info "Checking for existing configurations..."

    local files_to_backup=()

    [ -f "$HOME/.tmux.conf" ] && files_to_backup+=(".tmux.conf")

    if [ ${#files_to_backup[@]} -eq 0 ]; then
        log_info "No existing configurations to backup"
        return 0
    fi

    if ! prompt_yes_no "Backup existing configurations to $BACKUP_DIR?"; then
        log_warning "Skipping backup (existing files will be overwritten)"
        return 0
    fi

    mkdir -p "$BACKUP_DIR"

    for file in "${files_to_backup[@]}"; do
        cp "$HOME/$file" "$BACKUP_DIR/"
        log_success "Backed up $file"
    done

    log_success "Backup created at $BACKUP_DIR"
}

# Install tmux configuration
install_tmux_config() {
    log_info "Installing tmux configuration..."

    cp "$PROJECT_ROOT/config/tmux.conf" "$HOME/.tmux.conf"

    log_success "tmux configuration installed at ~/.tmux.conf"
}

# Install bash functions and aliases
install_bash_config() {
    log_info "Installing bash functions and aliases..."

    # Check if already installed
    if grep -q "# Dev Environment Tools - tmux-switch" "$HOME/.bashrc" 2>/dev/null; then
        log_warning "bash configuration already installed"
        if ! prompt_yes_no "Reinstall bash configuration?"; then
            log_info "Skipping bash configuration"
            return 0
        fi

        # Remove old installation
        sed -i '/# Dev Environment Tools - tmux-switch/,/# End Dev Environment Tools/d' "$HOME/.bashrc"
    fi

    # Append new configuration
    cat "$PROJECT_ROOT/config/bash_functions.sh" >> "$HOME/.bashrc"

    log_success "bash functions and aliases installed"
    log_info "Run 'source ~/.bashrc' or start a new shell to use them"
}

# Install fzf configuration to bashrc if needed
configure_fzf() {
    if [ -f "$HOME/.fzf.bash" ] && ! grep -q "fzf.bash" "$HOME/.bashrc" 2>/dev/null; then
        log_info "Adding fzf to bashrc..."
        echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' >> "$HOME/.bashrc"
        log_success "fzf configured"
    fi
}

# Main installation
main() {
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║     Dev Environment Tools Installer               ║"
    echo "╠═══════════════════════════════════════════════════╣"
    echo "║  Tmux configuration, aliases, and productivity    ║"
    echo "║  tools for development environments               ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""

    check_system

    if ! prompt_yes_no "Continue with installation?"; then
        log_warning "Installation cancelled"
        exit 0
    fi

    echo ""
    install_dependencies
    echo ""
    backup_configs
    echo ""
    install_tmux_config
    echo ""
    install_bash_config
    echo ""
    configure_fzf

    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║           Installation Complete! ✓                ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    log_success "Dev Environment Tools installed successfully"
    echo ""
    log_info "Next steps:"
    echo "  1. Reload your shell: source ~/.bashrc"
    echo "  2. Try the new commands:"
    echo "     • tms          - Switch between tmux sessions"
    echo "     • cy           - Launch Claude Code (skip permissions)"
    echo "     • tmls         - List tmux sessions"
    echo ""
    log_info "For more information, see: README.md"
    echo ""

    if [ -d "$BACKUP_DIR" ]; then
        log_info "Backup of old configs: $BACKUP_DIR"
    fi
}

main "$@"
