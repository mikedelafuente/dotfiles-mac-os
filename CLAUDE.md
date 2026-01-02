# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS dotfiles and configuration repository that automates system setup for a development workstation. The project includes:

- **Bootstrap System**: Automated setup orchestration with user configuration
- **Individual Setup Scripts**: Modular installers for specific tools and applications
- **GNU Stow Integration**: Modern dotfiles management using symlinks
- **Homebrew Integration**: Package management using Homebrew formulas and casks
- **GNU Coreutils**: Linux-compatible command-line tools for cross-platform consistency

**Target Platform**: Apple Silicon Macs (M1/M2/M3) running macOS 14.0 (Sonoma) or later

## Repository Structure

```
dotfiles-mac-os/
├── scripts/
│   ├── bootstrap.sh              # Main orchestration script (entry point)
│   ├── dotheader.sh              # Common header sourced by all scripts
│   ├── fn-lib.sh                 # Shared utility functions
│   ├── brew-lib.sh               # Homebrew-specific utility functions
│   ├── stow-dotfiles.sh          # GNU Stow dotfiles management
│   ├── setup-*.sh                # Individual tool setup scripts
│   └── ...
├── stow/
│   └── dotfiles/                 # Single stow package
│       ├── .config/              # → ~/.config/
│       │   ├── alacritty/
│       │   ├── lazydocker/
│       │   ├── lazygit/
│       │   ├── nvim/             # Neovim configuration (LazyVim)
│       │   ├── starship.toml
│       │   ├── tmuxinator/
│       │   └── Code/
│       ├── .local/
│       │   └── bin/
│       │       └── code          # Custom development environment launcher
│       ├── .zshrc               # Zsh configuration with GNU coreutils
│       ├── .gitconfig            # Git configuration with macOS helpers
│       ├── .gitignore_global
│       ├── .inputrc
│       ├── .nvim-cheatsheet.md
│       ├── .profile
│       ├── .tmux.conf
│       └── .welcome.md
└── NOTES.md                      # Installation notes
```

## Common Commands

### Bootstrap New System

The primary entry point for setting up a new macOS system:

```bash
cd /path/to/dotfiles-mac-os
bash scripts/bootstrap.sh
```

This script:
1. Collects user information (full name, email)
2. Installs Homebrew if not already present (at `/opt/homebrew` for Apple Silicon)
3. Updates Homebrew (rate-limited to once per 24 hours)
4. Sequentially runs all setup-*.sh scripts
5. Links dotfiles using GNU Stow
6. Cleans up unused Homebrew packages

### Run Individual Setup Scripts

Each setup script can be run independently (useful for debugging or re-running specific installations):

```bash
bash scripts/setup-essentials.sh
bash scripts/setup-neovim.sh
bash scripts/setup-rust.sh
bash scripts/setup-docker.sh
bash scripts/setup-git.sh <full-name> <email-address>
```

### Manage Dotfiles with GNU Stow

GNU Stow creates symbolic links from `stow/dotfiles/` to your home directory:

```bash
# Link all dotfiles
bash scripts/stow-dotfiles.sh link

# Unlink all dotfiles (remove symlinks)
bash scripts/stow-dotfiles.sh unlink

# Refresh symlinks (unlink then link)
bash scripts/stow-dotfiles.sh relink

# Dry run (see what would happen without making changes)
bash scripts/stow-dotfiles.sh simulate
```

The script automatically backs up existing files before creating symlinks.

## Architecture & Design Patterns

### Sourced Header and Library System

All setup scripts follow a consistent pattern:
1. Source `dotheader.sh` which sets up the script directory and loads both `fn-lib.sh` and `brew-lib.sh`
2. Use utility functions for consistent output formatting and package management

**fn-lib.sh utilities** (scripts/fn-lib.sh):
- `print_line_break()` - Prints green section headers with timestamp
- `print_info_message()` - Blue information messages
- `print_action_message()` - Orange action messages
- `print_success_message()` - Green success messages
- `print_warning_message()` - Yellow warning messages
- `print_error_message()` - Red error messages
- `print_tool_setup_start()` / `print_tool_setup_complete()` - Tool-specific wrappers

**brew-lib.sh utilities** (scripts/brew-lib.sh):
- `ensure_homebrew_installed()` - Auto-install Homebrew if missing
- `brew_install_formula()` - Install CLI tool (formula)
- `brew_install_formulas()` - Install multiple formulas at once
- `brew_install_cask()` - Install GUI application (cask)
- `brew_install_casks()` - Install multiple casks at once
- `brew_update_if_stale()` - Rate-limited updates (24-hour cache)
- `is_formula_installed()` / `is_cask_installed()` - Check installation status
- `brew_tap_if_needed()` - Add Homebrew tap if not already added
- `brew_cleanup()` - Remove old versions and free space

### Bootstrap Configuration

The bootstrap process:
- Stores configuration at `~/.config/dotfiles-mac-os/.dotfiles_bootstrap_config`
- Caches timestamps for package manager updates to avoid redundant operations (24-hour cooldown)
- Conditionally runs setup scripts based on what's already installed
- Ensures Homebrew is installed before proceeding with any setup
- Detects macOS version and architecture using `sw_vers` and `uname -m`

### Setup Script Conventions

Each `setup-*.sh` script:
- Sources `dotheader.sh` for utilities and proper script directory detection
- Checks if the tool is already installed before installing (using `command -v` or `brew list`)
- Uses `brew_install_formula()` for CLI tools and `brew_install_cask()` for GUI apps
- Uses consistent output formatting via fn-lib.sh functions
- Prints tool setup start/complete messages

Example pattern:
```bash
#!/bin/bash
# Source header
CURRENT_FILE_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
if [ -r "$CURRENT_FILE_DIR/dotheader.sh" ]; then
  source "$CURRENT_FILE_DIR/dotheader.sh"
else
  echo "Missing header file: $CURRENT_FILE_DIR/dotheader.sh"
  exit 1
fi

print_tool_setup_start "Tool Name"

# Check if already installed
if ! command -v tool &> /dev/null; then
    print_action_message "Installing Tool Name..."
    brew_install_formula tool-name
else
    print_info_message "Tool Name is already installed."
fi

print_tool_setup_complete "Tool Name"
```

### Special Cases

**setup-git.sh**: Accepts full name and email as arguments (passed from bootstrap.sh). Configures git with macOS osxkeychain credential helper.

**setup-starship.sh**: Installs modern bash via Homebrew (macOS ships with old bash 3.2), adds it to `/etc/shells`, and sets it as the default shell.

**setup-docker.sh**: Installs Docker Desktop via Homebrew Cask. Does NOT use systemctl (Linux-only). User must launch Docker Desktop manually after installation.

**setup-rust.sh**: Uses `rustup-init` formula instead of direct rust package for better flexibility with multiple toolchain versions.

**setup-node.sh**: Uses NVM (Node Version Manager) via curl installation for maximum compatibility and version management.

**setup-essentials.sh**: Installs GNU coreutils (coreutils, findutils, gnu-sed, gnu-tar, grep) for Linux command compatibility. The .zshrc is configured to prioritize GNU versions in PATH.

**GUI Applications**: Installed via Homebrew Cask:
- Spotify, Obsidian, Zoom (productivity apps)
- Postman, TablePlus (developer tools)
- Alacritty terminal

**macOS-Specific Tools**: New scripts for macOS productivity:
- Rectangle (window management, replaces Linux tiling WM)
- Raycast (Spotlight replacement with productivity features)
- Karabiner-Elements (advanced keyboard customization)

## GNU Stow Dotfiles Management

### How It Works

GNU Stow creates symlinks from the `stow/dotfiles/` directory to your home directory. For example:
- `stow/dotfiles/.zshrc` → `~/.zshrc`
- `stow/dotfiles/.config/nvim/` → `~/.config/nvim/`
- `stow/dotfiles/.local/bin/code` → `~/.local/bin/code`

This approach provides:
- **Version Control**: All dotfiles tracked in git
- **Easy Updates**: Edit files in the repo, changes reflected immediately
- **Clean Uninstall**: `stow -D` removes all symlinks
- **Backup Safety**: Existing files are backed up before linking

### Stow Package Structure

The repository uses a **single stow package** approach (`dotfiles/`) rather than multiple packages. All configuration files are in one package for simplicity.

Files at the root of `stow/dotfiles/` are linked to `~/`
Files in `stow/dotfiles/.config/` are linked to `~/.config/`

## Key Design Decisions

1. **Modular Setup Scripts**: Each tool has its own script for clarity and independent execution
2. **Conditional Execution**: Bootstrap only runs scripts if the tool isn't already installed
3. **Rate-Limited Updates**: Homebrew updates are cached (24-hour cooldown) to avoid redundant operations
4. **GNU Stow for Dotfiles**: Modern symlink management replacing manual scripting
5. **Single-User Focus**: Designed for user-level setup, not system-wide deployments
6. **Homebrew-First**: Uses Homebrew as the primary package manager for consistency
7. **GNU Coreutils**: Installs GNU versions of core utilities for Linux compatibility
8. **Apple Silicon Only**: Hardcoded to `/opt/homebrew` (no Intel Mac support)
9. **No Desktop Environments**: Unlike the Arch Linux version, this is CLI-focused (macOS provides the GUI)

## Important Files

- **scripts/dotheader.sh**: Sets up `DF_SCRIPT_DIR` variable and sources both `fn-lib.sh` and `brew-lib.sh` - required by all setup scripts
- **scripts/fn-lib.sh**: Contains all utility functions for consistent formatting and output
- **scripts/brew-lib.sh**: Homebrew-specific utilities for package management
- **scripts/bootstrap.sh**: Orchestration logic and sequencing of all setup operations
- **scripts/stow-dotfiles.sh**: GNU Stow wrapper for dotfiles management
- **stow/dotfiles/.zshrc**: Zsh configuration with Homebrew and GNU coreutils in PATH
- **stow/dotfiles/.gitconfig**: Git configuration with macOS credential helper

## macOS-Specific Considerations

### Homebrew Paths

Apple Silicon Macs use `/opt/homebrew` for Homebrew installation (Intel Macs use `/usr/local`). This repository is configured for Apple Silicon only.

### GNU Coreutils in PATH

The `.zshrc` file adds GNU coreutils to the PATH with highest priority:
```bash
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
```

This allows Linux-style commands like `ls --color=auto` to work without modification.

### Git Credentials

macOS provides `osxkeychain` for secure credential storage. The `.gitconfig` is configured to use it:
```ini
[credential]
    helper = osxkeychain
```

### Docker Desktop

Docker on macOS requires Docker Desktop (GUI app). Unlike Linux, there is no systemd service to manage. Users must launch Docker Desktop from Applications after installation.

### Shell Configuration

macOS ships with bash 3.2 (from 2007) due to licensing. The setup-starship.sh script installs a modern bash version via Homebrew and configures it as the default shell.

## Development Notes

- All scripts assume bash (`#!/bin/bash`)
- Scripts are designed to be idempotent (safe to run multiple times)
- Configuration is stored in `~/.config/dotfiles-mac-os/` for persistence across runs
- The bootstrap script handles being run as a regular user (sudo is invoked per-command when needed)
- Package checks use `command -v` for executables and `brew list` for Homebrew packages
- Dotfiles are symlinked to `$HOME` via GNU Stow
- All setup scripts source `dotheader.sh` which provides both fn-lib.sh and brew-lib.sh utilities

## Conversion from Arch Linux

This repository was converted from an Arch Linux dotfiles repository. Key changes:
- Replaced `pacman`/`yay` with Homebrew formulas and casks
- Removed Linux desktop environments (Hyprland, GNOME, Waybar)
- Replaced manual `link-dotfiles.sh` with GNU Stow
- Added GNU coreutils for command compatibility
- Removed systemd service management
- Added macOS-specific productivity tools
- Updated .zshrc and .gitconfig for macOS
