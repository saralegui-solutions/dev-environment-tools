# Claude Code Session Guide

Quick reference for Claude Code sessions deploying this package to new machines.

## 🎯 Quick Start

### For Claude Code: Installation on New Machine

**1. Clone and Install:**
```bash
git clone https://github.com/saralegui-solutions/dev-environment-tools.git
cd dev-environment-tools
./scripts/install.sh --yes
```

**2. Verify Installation:**
```bash
source ~/.bashrc
type tms cy tmls
tmux -V
fzf --version
claude --version
```

**3. Test Functionality:**
```bash
# Test tmux session switcher
tms test-session

# Exit session
exit

# Test Claude Code
cy --version
```

## 📋 What This Package Does

### Installed Components

1. **Tmux Configuration** (`~/.tmux.conf`)
   - Mouse support, vi-mode, optimized settings

2. **Shell Functions** (added to `~/.bashrc`)
   - `tmux-switch()` - Interactive session management
   - Works with or without fzf

3. **Aliases** (added to `~/.bashrc`)
   - `tms` - Quick session switcher
   - `cy` - Claude Code with skip permissions
   - `tmls` - List sessions

4. **Dependencies** (auto-installed if missing)
   - tmux
   - fzf (fuzzy finder)
   - Node.js (via nvm)
   - Claude Code CLI

## 🔍 Troubleshooting for Claude Code

### Common Issues

**1. Dependencies Not Found After Installation**
```bash
# Reload shell environment
source ~/.bashrc

# Verify PATH
echo $PATH | grep -E "(nvm|fzf)"

# If needed, load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

**2. Aliases Not Working**
```bash
# Check if installation added functions
grep "Dev Environment Tools" ~/.bashrc

# If missing, reinstall
./scripts/install.sh --yes
source ~/.bashrc
```

**3. fzf Not in PATH**
```bash
# fzf should be at ~/.fzf/bin/fzf
ls -la ~/.fzf/bin/fzf

# Add to PATH if needed
export PATH="$HOME/.fzf/bin:$PATH"

# Or source fzf bash completion
source ~/.fzf.bash
```

**4. Installation Fails**
```bash
# Run with debug mode
bash -x scripts/install.sh

# Or skip dependency installation and install manually
./scripts/install.sh --skip-deps
```

## 📖 For Another Claude Code Session

### Installation Checklist

- [ ] Clone repository
- [ ] Run `./scripts/install.sh --yes`
- [ ] Reload shell: `source ~/.bashrc`
- [ ] Verify dependencies: `tms`, `cy`, `tmls`
- [ ] Test tmux session: `tms test`
- [ ] Check tmux config: `cat ~/.tmux.conf`

### Key Files and Their Purpose

```
dev-environment-tools/
├── scripts/install.sh           # Main installer (run this first)
├── config/tmux.conf            # Tmux configuration
├── config/bash_functions.sh    # Shell functions to add to ~/.bashrc
├── README.md                   # Main documentation
├── docs/USAGE.md              # Detailed usage guide
├── docs/TROUBLESHOOTING.md    # Common issues
└── docs/CUSTOMIZATION.md      # How to customize
```

### Installation Options

```bash
# Fully automated (recommended)
./scripts/install.sh --yes

# Interactive (asks for confirmation)
./scripts/install.sh

# Skip dependencies (if already installed)
./scripts/install.sh --skip-deps

# Show help
./scripts/install.sh --help
```

### Verification Commands

```bash
# Check installation
type tms cy tmls tmux-switch

# Check versions
tmux -V
fzf --version
node --version
claude --version

# Test functionality
tms  # Should show interactive menu
```

## 🧠 Understanding the Package

### What Gets Modified

1. **~/.tmux.conf** - Created or overwritten (backup created first)
2. **~/.bashrc** - Functions and aliases appended (not replaced)
3. **~/.fzf/** - fzf installed if not present
4. **~/.nvm/** - nvm and Node.js installed if not present

### Backup System

The installer creates backups at:
```
~/.config/dev-tools-backup-TIMESTAMP/
```

Contains copies of any existing configurations before modification.

### Idempotent Installation

Running the installer multiple times is safe:
- Detects existing installations
- Updates configurations
- Doesn't break existing setups

## 🔧 Manual Installation (If Automated Fails)

### Step-by-Step Manual Process

**1. Copy tmux config:**
```bash
cp config/tmux.conf ~/.tmux.conf
```

**2. Add functions to bashrc:**
```bash
cat config/bash_functions.sh >> ~/.bashrc
source ~/.bashrc
```

**3. Install fzf:**
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
```

**4. Install Node.js:**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install --lts
```

**5. Install Claude Code:**
```bash
npm install -g @anthropic-ai/claude-code
```

## 📚 Additional Resources

### Documentation Files

- **[README.md](README.md)** - Project overview and quick start
- **[docs/USAGE.md](docs/USAGE.md)** - Comprehensive usage examples
- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Issue resolution
- **[docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md)** - Configuration customization

### Key Commands Reference

```bash
# Tmux session management
tms                    # Interactive session switcher
tms session-name       # Create/switch to session
tmls                   # List sessions

# Claude Code
cy                     # Launch with skip permissions
cy /path/to/file       # Open specific file

# Tmux key bindings
Prefix + |            # Split vertical
Prefix + -            # Split horizontal
Prefix + r            # Reload config
Prefix + d            # Detach
```

## 🚀 Deployment Scenarios

### Scenario 1: Fresh Ubuntu/Debian Server

```bash
# 1. Install git (if not present)
sudo apt update && sudo apt install -y git

# 2. Clone and install
git clone https://github.com/saralegui-solutions/dev-environment-tools.git
cd dev-environment-tools
./scripts/install.sh --yes

# 3. Reload and test
source ~/.bashrc
tms
```

### Scenario 2: macOS Development Machine

```bash
# 1. Ensure Homebrew installed
which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install git (if needed)
brew install git

# 3. Clone and install
git clone https://github.com/saralegui-solutions/dev-environment-tools.git
cd dev-environment-tools
./scripts/install.sh --yes
```

### Scenario 3: Remote SSH Development

```bash
# 1. SSH to remote machine
ssh user@remote-server

# 2. Clone and install
git clone https://github.com/saralegui-solutions/dev-environment-tools.git
cd dev-environment-tools
./scripts/install.sh --yes

# 3. Start persistent session
tms remote-dev

# 4. Detach and logout (session persists)
# Press: Ctrl+b then d
exit
```

## ⚠️ Important Notes for Claude Code

### Before Installation

1. **Check System Requirements:**
   - Linux or macOS
   - Bash 4.0+
   - Git installed
   - Internet connection

2. **Check Existing Configs:**
   ```bash
   ls -la ~/.tmux.conf ~/.bashrc
   ```

3. **Backup Important Configs:**
   ```bash
   cp ~/.tmux.conf ~/.tmux.conf.backup
   cp ~/.bashrc ~/.bashrc.backup
   ```

### After Installation

1. **Always reload shell:**
   ```bash
   source ~/.bashrc
   ```

2. **Verify all components:**
   ```bash
   type tms cy tmls
   ```

3. **Test tmux:**
   ```bash
   tms test-session
   ```

### If Something Goes Wrong

1. **Check installation logs** (installer shows verbose output)
2. **Review [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)**
3. **Restore from backup:**
   ```bash
   ls ~/.config/dev-tools-backup-*/
   cp ~/.config/dev-tools-backup-*/.tmux.conf ~/
   ```

## 🎓 Learning Path for New Users

### Day 1: Basic Usage

1. Install the package
2. Try `tms` to create a session
3. Practice switching sessions
4. Learn basic tmux key bindings (Prefix + |, -)

### Day 2: Workflow Integration

1. Create project-specific sessions
2. Use `cy` for Claude Code integration
3. Customize tmux config
4. Add personal aliases

### Day 3: Advanced Features

1. Review [CUSTOMIZATION.md](docs/CUSTOMIZATION.md)
2. Set up session templates
3. Configure fzf options
4. Explore tmux plugins

## 🔗 Repository

**GitHub**: https://github.com/saralegui-solutions/dev-environment-tools

**Clone URL**: `git clone https://github.com/saralegui-solutions/dev-environment-tools.git`

**Issues**: https://github.com/saralegui-solutions/dev-environment-tools/issues

---

**For Claude Code Sessions**: This package is designed for autonomous deployment. The installer handles all dependencies and configurations automatically. Just clone and run `./scripts/install.sh --yes`.
