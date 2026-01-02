# macOS Dotfiles

Automated macOS development environment setup for Apple Silicon Macs using Homebrew and GNU Stow.

## Quick Start

```bash
git clone https://github.com/yourusername/dotfiles-mac-os.git ~/dotfiles-mac-os
cd ~/dotfiles-mac-os
bash scripts/bootstrap.sh
```

You'll be prompted for your name and email for git configuration. The bootstrap script will:
- Install Homebrew (if not already installed)
- Install all development tools and applications
- Link dotfiles using GNU Stow
- Configure your development environment

## What Gets Installed

### CLI Tools
- **Essentials**: git, gh, curl, wget, fzf, ripgrep, fd, bat, htop, btop, ncdu, tree, jq, tmux, zoxide, stow
- **GNU Coreutils**: coreutils, findutils, gnu-sed, gnu-tar, grep (Linux compatibility)
- **Languages**: Python, Node.js (via NVM), Rust, Go, Ruby, PHP
- **Containers**: Docker Desktop, Minikube, kubectl, k9s

### GUI Applications
- **Development**: Alacritty, Docker Desktop, TablePlus, Postman
- **Productivity**: Obsidian, Rectangle, Raycast, Karabiner-Elements
- **Communication**: Zoom
- **Entertainment**: Spotify
- **Fonts**: Nerd Fonts collection (Meslo, Ubuntu, Fira Code, JetBrains Mono, Hack)

### Dotfiles (managed by GNU Stow)
- Shell: `.zshrc`, `.profile`, `.inputrc`
- Git: `.gitconfig`, `.gitignore_global`
- Editors: `.config/nvim/` (LazyVim), `.tmux.conf`
- Tools: `.config/alacritty/`, `.config/lazygit/`, `.config/starship.toml`
- Custom: `.local/bin/code` (development environment launcher)

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon Mac (M1/M2/M3)
- Admin access for installing Homebrew

## Post-Installation

After bootstrap completes, restart your terminal:
```bash
exec zsh
```

### GitHub Authentication
```bash
gh auth login
```

### SSH Keys
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub | pbcopy
# Add to GitHub → Settings → SSH keys
```

### Docker Desktop
Launch Docker Desktop from Applications and grant necessary permissions.

### macOS Productivity Tools
- **Rectangle**: Grant Accessibility permissions for window management
- **Raycast**: Set Cmd+Space hotkey, enable clipboard history
- **Karabiner-Elements**: Grant Input Monitoring permissions

## Customization

### Individual Setup Scripts
Run specific setup scripts independently:
```bash
bash scripts/setup-neovim.sh
bash scripts/setup-rust.sh
bash scripts/setup-docker.sh
```

### Manage Dotfiles
```bash
# Link all dotfiles
bash scripts/stow-dotfiles.sh link

# Unlink all dotfiles
bash scripts/stow-dotfiles.sh unlink

# Refresh symlinks
bash scripts/stow-dotfiles.sh relink
```

### Custom Development Environment
The `code` command launches a tmuxinator session for project work:
```bash
code /path/to/project
```

Customize the layout in `~/.config/tmuxinator/code.yml`

## Documentation

- **[CLAUDE.md](CLAUDE.md)**: Detailed project architecture and design decisions
- **[NOTES.md](NOTES.md)**: Installation notes and troubleshooting guide

## Updates

```bash
cd ~/dotfiles-mac-os
git pull
bash scripts/bootstrap.sh  # Re-run to install new tools
brew update && brew upgrade  # Update installed packages
```

## Architecture

This project uses:
- **Homebrew**: Package management (formulas for CLI, casks for GUI apps)
- **GNU Stow**: Dotfiles management via symlinks
- **Modular Scripts**: Independent setup scripts for each tool
- **Utility Libraries**: Shared functions for consistent output and Homebrew operations

All scripts are idempotent and safe to run multiple times.

## License

This is a personal dotfiles repository. Feel free to fork and customize for your own use.
