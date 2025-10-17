# Dev Environment Tools

A comprehensive package of terminal productivity tools, tmux configurations, and shell enhancements for development environments. Designed for easy deployment across multiple machines with automated dependency management.

## 🚀 Features

- **Tmux Configuration**: Optimized tmux setup with mouse support, vi-mode, and performance enhancements
- **Interactive Session Switcher**: fzf-powered tmux session management
- **Claude Code Integration**: Quick-launch aliases for Claude Code
- **Automated Installation**: One-command setup with dependency checking
- **Backup System**: Safely backs up existing configurations
- **Cross-Platform**: Works on Linux and macOS

## 📦 What's Included

### Tmux Configuration
- Mouse support enabled
- Vi-style key bindings
- Performance optimizations (reduced escape time, increased history)
- Session management enhancements
- Custom window/pane navigation
- Copy mode improvements

### Shell Functions & Aliases
- **`tms`** / **`tmux-switch`** - Interactive tmux session switcher with fzf
- **`cy`** - Launch Claude Code with skip permissions flag
- **`tmls`** - Quick list of active tmux sessions

### Dependencies (Auto-Installed)
- tmux 3.0+
- fzf (fuzzy finder)
- Node.js (via nvm)
- Claude Code CLI

## 🔧 Quick Installation

### One-Line Install
```bash
git clone https://github.com/saralegui-solutions/dev-environment-tools.git
cd dev-environment-tools
./scripts/install.sh
```

### Installation Options
```bash
# Auto-confirm all prompts
./scripts/install.sh --yes

# Skip dependency installation
./scripts/install.sh --skip-deps

# Show help
./scripts/install.sh --help
```

## 📖 Usage

### After Installation

Reload your shell or source your bashrc:
```bash
source ~/.bashrc
```

### Tmux Session Management

**Interactive session switcher:**
```bash
tms
```
Opens an fzf menu to:
- Switch between existing sessions
- Create new sessions
- Navigate with arrow keys

**Direct session switching:**
```bash
tms my-session-name
```
Creates or switches to a named session directly.

**List sessions:**
```bash
tmls
```

### Claude Code

**Launch Claude Code (skip permissions):**
```bash
cy
```
Equivalent to `claude --dangerously-skip-permissions`

### Tmux Key Bindings

The included `.tmux.conf` provides:

- **Split panes**: `|` (vertical) and `-` (horizontal)
- **Reload config**: `Prefix + r`
- **Copy mode**: Vi-style navigation with `Ctrl+Arrow` for word jumping
- **Mouse support**: Click to select panes, scroll to navigate history

## 📁 Project Structure

```
dev-environment-tools/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── scripts/
│   └── install.sh                     # Main installation script
├── config/
│   ├── tmux.conf                      # Tmux configuration
│   └── bash_functions.sh              # Shell functions and aliases
└── docs/
    ├── USAGE.md                       # Detailed usage guide
    ├── TROUBLESHOOTING.md             # Common issues and solutions
    └── CUSTOMIZATION.md               # Configuration customization guide
```

## 🔍 Detailed Documentation

- **[Usage Guide](docs/USAGE.md)** - Comprehensive usage examples and workflows
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Customization](docs/CUSTOMIZATION.md)** - How to customize configurations

## 🛠️ Manual Installation

If you prefer to install components manually:

### 1. Copy Tmux Configuration
```bash
cp config/tmux.conf ~/.tmux.conf
```

### 2. Add Functions to Bashrc
```bash
cat config/bash_functions.sh >> ~/.bashrc
source ~/.bashrc
```

### 3. Install Dependencies Manually

**Install tmux:**
```bash
# Ubuntu/Debian
sudo apt install tmux

# macOS
brew install tmux
```

**Install fzf:**
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
```

**Install Node.js via nvm:**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install --lts
```

**Install Claude Code:**
```bash
npm install -g @anthropic-ai/claude-code
```

## 🔄 Updating

To update to the latest version:

```bash
cd dev-environment-tools
git pull
./scripts/install.sh
```

## 🗑️ Uninstallation

### Remove Configurations
```bash
rm ~/.tmux.conf

# Remove from bashrc (edit manually)
nano ~/.bashrc
# Delete section: "# Dev Environment Tools - tmux-switch" to "# End Dev Environment Tools"
```

### Restore from Backup
If you backed up configurations during installation:
```bash
# Backups are stored at ~/.config/dev-tools-backup-TIMESTAMP/
ls ~/.config/dev-tools-backup-*/

# Restore example
cp ~/.config/dev-tools-backup-20241017-102600/.tmux.conf ~/
```

## 🧪 Testing on New Machine

To test this package on a new machine (as another Claude Code session might):

1. **Clone the repository:**
   ```bash
   git clone https://github.com/saralegui-solutions/dev-environment-tools.git
   cd dev-environment-tools
   ```

2. **Review the installation script:**
   ```bash
   cat scripts/install.sh
   ```

3. **Run installation:**
   ```bash
   ./scripts/install.sh --yes
   ```

4. **Verify installation:**
   ```bash
   # Check tmux config
   cat ~/.tmux.conf

   # Check for functions
   type tms cy tmls

   # Test tmux session switcher
   tms test-session
   ```

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on a clean system
5. Submit a pull request

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues, questions, or suggestions:

- **GitHub Issues**: [Create an issue](https://github.com/saralegui-solutions/dev-environment-tools/issues)
- **Documentation**: Check [docs/](docs/) directory for detailed guides

## 🎯 Use Cases

### Remote Development
Perfect for quickly setting up consistent environments on remote servers accessed via SSH.

### Team Onboarding
Standardize development environments across team members with one installation command.

### Multi-Machine Workflows
Maintain the same productivity tools across laptop, desktop, and cloud instances.

### Container Development
Include in Dockerfile or docker-compose for consistent containerized development environments.

## 🏗️ Architecture

This package follows a modular design:

- **Installation Script**: Detects system, checks dependencies, handles backups
- **Configuration Files**: Standalone configs that can be used independently
- **Documentation**: Comprehensive guides for all skill levels

The installer is idempotent - running it multiple times is safe and will update configurations without breaking existing setups.

## 📊 Requirements

### Minimum Requirements
- Linux (Ubuntu 18.04+, Debian 10+, RHEL 8+) or macOS 10.14+
- Bash 4.0+
- Git
- Internet connection (for dependency installation)

### Recommended
- Terminal with 256 color support
- UTF-8 locale
- At least 100MB free disk space

## 🔐 Security

- No elevated privileges required for normal operation
- Dependencies installed via official package managers
- Source code is open and reviewable
- Backups created before any modifications

## 📚 Additional Resources

- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [fzf Examples](https://github.com/junegunn/fzf/wiki/examples)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)

---

**Created by**: Saralegui Solutions LLC
**Repository**: https://github.com/saralegui-solutions/dev-environment-tools
**Version**: 1.0.0
**Last Updated**: October 2024
