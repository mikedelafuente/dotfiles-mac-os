#!/bin/bash

# --------------------------
# Setup Neovim for macOS
# --------------------------
# This script sets up a modern, beginner-friendly Neovim configuration with:
#   - LSP support for multiple languages (Lua, Python, JS/TS, Rust, Go, PHP, C#)
#   - Treesitter for syntax highlighting
#   - Telescope for fuzzy finding
#   - Auto-completion with nvim-cmp
#   - Which-key for discovering keybindings
#   - File explorer and statusline
# --------------------------

# --------------------------
# Import Common Header 
# --------------------------

# add header file
CURRENT_FILE_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

# source header (uses SCRIPT_DIR and loads lib.sh)
if [ -r "$CURRENT_FILE_DIR/dotheader.sh" ]; then
  # shellcheck source=/dev/null
  source "$CURRENT_FILE_DIR/dotheader.sh"
else
  echo "Missing header file: $CURRENT_FILE_DIR/dotheader.sh"
  exit 1
fi

# --------------------------
# End Import Common Header 
# --------------------------

print_tool_setup_start "Neovim"

# --------------------------
# Install Neovim
# --------------------------

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    print_info_message "Neovim is not installed. Installing Neovim."
    brew_install_formula neovim
else
    print_info_message "Neovim is already installed. Skipping installation."
fi

# Print Neovim version
print_info_message "Neovim version: $(nvim --version | head -n 1)"

# --------------------------
# Install Dependencies
# --------------------------

print_info_message "Installing dependencies for Neovim plugins"

# Check for Xcode Command Line Tools (required for treesitter on macOS)
if ! xcode-select -p &> /dev/null; then
    print_warning_message "Xcode Command Line Tools not found"
    print_action_message "Installing Xcode Command Line Tools (required for treesitter)..."
    xcode-select --install
    print_info_message "Please complete the Xcode CLT installation in the popup window"
    print_info_message "After installation completes, re-run this script"
    exit 0
else
    print_info_message "Xcode Command Line Tools already installed"
fi

# Homebrew dependencies for Neovim plugins
NEOVIM_DEPS=("fd" "ripgrep" "pipx")

brew_install_formulas "${NEOVIM_DEPS[@]}"

# Ensure pipx path is configured (required before first use)
if command -v pipx &> /dev/null; then
    print_info_message "Ensuring pipx path is configured"
    pipx ensurepath &> /dev/null || true
fi

# Install pynvim via pipx (isolated Python environment)
# This avoids PEP 668 externally-managed-environment errors on macOS
if command -v pipx &> /dev/null; then
    if ! pipx list | grep -q pynvim; then
        print_info_message "Installing pynvim via pipx (isolated environment)"
        pipx install pynvim
    else
        print_info_message "pynvim is already installed via pipx"
    fi
else
    print_warning_message "pipx not found. Skipping pynvim installation."
    print_info_message "pynvim is optional for most modern Neovim plugins (Lua/Node.js based)"
fi

# Verify Node.js (required for some LSP servers, should be installed via setup-node.sh)
if ! command -v node &> /dev/null; then
    print_warning_message "Node.js is not installed. Some LSP servers may not work correctly."
    print_info_message "Run setup-node.sh to install Node.js"
else
    print_info_message "Node.js is installed: $(node --version)"
fi

# --------------------------
# Configuration Files
# --------------------------

print_info_message "Neovim configuration files are managed in the dotfiles repository"
print_info_message "Location: $(dirname "$CURRENT_FILE_DIR")/stow/dotfiles/.config/nvim"
print_info_message "The stow-dotfiles.sh script will symlink these files to ~/.config/nvim"

# Note: The actual configuration files are in stow/dotfiles/.config/nvim/ and will be linked
# by the stow-dotfiles.sh script. This keeps them version controlled.

print_action_message "Neovim setup complete!"
print_action_message ""
print_action_message "Next steps:"
print_action_message "  1. Run 'bash $CURRENT_FILE_DIR/stow-dotfiles.sh link' to link config files"
print_action_message "  2. Start Neovim with 'nvim'"
print_action_message "  3. Plugins will install automatically on first launch"
print_action_message "  4. Run ':Mason' to install additional LSP servers"
print_action_message "  5. Run ':checkhealth' to verify everything is working"
print_action_message ""
print_action_message "Quick start:"
print_action_message "  - Press <Space> to see available commands (leader key)"
print_action_message "  - Press <Space>ff to find files"
print_action_message "  - Press <Space>e to toggle file explorer"
print_action_message "  - Press K on a symbol to see documentation"

print_tool_setup_complete "Neovim"

