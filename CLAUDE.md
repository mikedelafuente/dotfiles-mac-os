# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS dotfiles and configuration repository that automates system setup for a development workstation. The project includes:

- **Bootstrap System**: Automated setup orchestration with user configuration
- **Individual Setup Scripts**: Modular installers for specific tools and applications
- **Dotfiles Linking**: Symlink management for configuration files
- **Homebrew Integration**: Package management using Homebrew and Homebrew Cask

## Repository Structure

```
dotfiles-mac-os/
├── scripts/
│   ├── bootstrap.sh              # Main orchestration script (entry point)
│   ├── dotheader.sh              # Common header sourced by all scripts
│   ├── fn-lib.sh                 # Shared utility functions
│   ├── link-dotfiles.sh          # Symlink dotfiles to home directory
│   ├── setup-*.sh                # Individual tool setup scripts
│   └── ...
├── home/                          # Dotfiles for home directory (~/)
│   ├── .bashrc                   # Bash configuration
│   ├── .zshrc                    # Zsh configuration (macOS default shell)
│   ├── .gitconfig                # Git configuration
│   ├── .tmux.conf                # Tmux configuration
│   └── ...
├── config/                        # Application config directories
│   ├── nvim/                     # Neovim configuration (LazyVim)
│   ├── kitty/                    # Kitty terminal config
│   ├── alacritty/                # Alacritty terminal config
│   └── ...
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
2. Installs Homebrew if not already present
3. Updates Homebrew and installed packages
4. Sequentially runs all setup-*.sh scripts
5. Links dotfiles to home directory
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

### Link Dotfiles

Create symbolic links from the repository's dotfiles to the home directory:

```bash
bash scripts/link-dotfiles.sh [profile-name]
```

The profile name defaults to "dela" if not specified.

## Architecture & Design Patterns

### Sourced Header and Library System

All setup scripts follow a consistent pattern:
1. Source `dotheader.sh` which sets up the script directory and loads `fn-lib.sh`
2. Use utility functions from `fn-lib.sh` for consistent output formatting

**fn-lib.sh utilities** (scripts/fn-lib.sh):
- `print_line_break()` - Prints green section headers with timestamp
- `print_info_message()` - Blue information messages
- `print_action_message()` - Orange action messages
- `print_success_message()` - Green success messages
- `print_warning_message()` - Yellow warning messages
- `print_error_message()` - Red error messages
- `print_tool_setup_start()` / `print_tool_setup_complete()` - Tool-specific wrappers

### Bootstrap Configuration

The bootstrap process:
- Stores configuration at `~/.config/dotfiles-mac-os/.dotfiles_bootstrap_config`
- Caches timestamps for package manager updates to avoid redundant operations
- Conditionally runs setup scripts based on what's already installed (uses `brew list`)
- Ensures Homebrew is installed before proceeding with any setup

### Setup Script Conventions

Each `setup-*.sh` script:
- Sources dotheader.sh for utilities and proper script directory detection
- Checks if the tool is already installed before installing
- Handles both Homebrew formulae and casks
- Uses consistent output formatting

### Special Cases

**setup-git.sh**: Accepts full name and email as arguments (passed from bootstrap.sh)

**Rust Installation** (setup-rust.sh): Uses rustup instead of Homebrew package for better flexibility with multiple toolchain versions

**GUI Applications**: Installed via Homebrew Cask when available (e.g., `brew install --cask docker`)

## Key Design Decisions

1. **Modular Setup Scripts**: Each tool has its own script for clarity and independent execution
2. **Conditional Execution**: Bootstrap only runs scripts if the tool isn't already installed
3. **Rate-Limited Updates**: Package manager updates are cached (1-day cooldown) to avoid redundant operations
4. **Symlink-Based Dotfiles**: Configuration files are linked, not copied, allowing easy updates
5. **Single-User Focus**: Designed for user-level setup, not system-wide deployments
6. **Homebrew-First**: Uses Homebrew as the primary package manager for consistency

## Important Files

- **scripts/dotheader.sh**: Sets up `SCRIPT_DIR` variable and sources `fn-lib.sh` - required by all setup scripts
- **scripts/fn-lib.sh**: Contains all utility functions for consistent formatting and output
- **scripts/bootstrap.sh**: Orchestration logic and sequencing of all setup operations

## Development Notes

- All scripts assume bash (`#!/bin/bash`) or zsh compatibility
- Scripts use `-e` flags where appropriate to fail on errors
- Configuration is stored in `~/.config/dotfiles-mac-os/` for persistence across runs
- Package checks use `brew list` to detect installed packages (returns error if not found)
- Dotfiles are symlinked to `$HOME`
- macOS-specific: Scripts may use `defaults write` for system preferences configuration
