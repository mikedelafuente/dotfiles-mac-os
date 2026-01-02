# macOS Dotfiles Installation Notes

## Prerequisites

- **macOS Version**: Sonoma (14.0) or later recommended
- **Architecture**: Apple Silicon (M1/M2/M3) - optimized for `/opt/homebrew`
- **Admin Access**: Required for Homebrew installation
- **Xcode Command Line Tools**: Installed automatically by Homebrew

## Fresh macOS System Setup

### 1. Clone this Repository

```bash
git clone https://github.com/yourusername/dotfiles-mac-os.git ~/dotfiles-mac-os
cd ~/dotfiles-mac-os
```

### 2. Run Bootstrap Script

The bootstrap script will:
- Install Homebrew (if not present)
- Install all development tools and GUI applications
- Link dotfiles using GNU Stow
- Configure your development environment

```bash
bash scripts/bootstrap.sh
```

You'll be prompted for:
- Your full name (for Git configuration)
- Your email address (for Git configuration)

### 3. Restart Terminal

After bootstrap completes, restart your terminal to apply all PATH changes:

```bash
# Close and reopen Terminal, or:
exec zsh
```

## What Gets Installed

### Homebrew Formulas (CLI Tools)

**Essential Development Tools:**
- git, gh (GitHub CLI)
- curl, wget
- fzf, ripgrep, fd
- bat, htop, btop, ncdu, tree
- jq, tmux, zoxide
- stow (dotfiles manager)
- shellcheck, tldr, fastfetch

**GNU Coreutils (Linux Compatibility):**
- coreutils, findutils, gnu-sed, gnu-tar, grep

**Language Runtimes & Tools:**
- Python 3, Node.js (via NVM), Rust (via rustup), Go, Ruby, PHP

**Container & Kubernetes:**
- Docker Desktop, Minikube, kubectl

### Homebrew Casks (GUI Applications)

**Development:**
- Docker Desktop, Alacritty Terminal, TablePlus, Postman

**Communication:**
- Zoom

**Productivity:**
- Obsidian, Rectangle, Raycast, Karabiner-Elements

**Entertainment:**
- Spotify

**Fonts:**
- Nerd Fonts (Meslo, Ubuntu, Fira Code, JetBrains Mono, Hack)

## Dotfiles Managed by GNU Stow

All dotfiles are symlinked from `stow/dotfiles/` to your home directory:
- Shell: `.zshrc`, `.profile`, `.inputrc`
- Git: `.gitconfig`, `.gitignore_global`
- Editors: `.config/nvim/`, `.tmux.conf`
- Tools: `.config/alacritty/`, `.config/lazygit/`, `.config/starship.toml`

## Post-Installation Steps

### GitHub Authentication

```bash
gh auth login
```

### SSH Key Generation

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub | pbcopy
# Add to GitHub → Settings → SSH keys
```

### Docker Desktop

Launch from Applications and grant permissions.

### macOS Tools Setup

**Rectangle**: Grant Accessibility permissions, configure shortcuts
**Raycast**: Set Cmd+Space hotkey, enable clipboard history
**Karabiner-Elements**: Grant Input Monitoring permissions

## Troubleshooting

**Homebrew Installation Fails**: Run Homebrew installer manually
**Stow Conflicts**: Backup existing files with `mv ~/.zshrc ~/.zshrc.backup`
**Command Not Found**: Run `eval "$(/opt/homebrew/bin/brew shellenv)"`
**Docker Issues**: Launch Docker Desktop from Applications manually

## Verify Installation

```bash
brew doctor
ls -la ~/ | grep '^l'    # Check symlinked dotfiles
which ls                 # Should show GNU coreutils
```

## Updates

```bash
brew update && brew upgrade
cd ~/dotfiles-mac-os && git pull
```

For more details, see CLAUDE.md.
