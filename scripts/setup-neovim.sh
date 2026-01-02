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

# Homebrew dependencies for Neovim plugins
# Note: python-pynvim -> use pip3 install pynvim instead
NEOVIM_DEPS=("fd" "ripgrep" "gcc" "make")

brew_install_formulas "${NEOVIM_DEPS[@]}"

# Install python-pynvim via pip if python3 is available
if command -v python3 &> /dev/null && command -v pip3 &> /dev/null; then
    if ! pip3 list | grep -q pynvim; then
        print_info_message "Installing pynvim via pip3 (user installation)"
        pip3 install --user pynvim
    else
        print_info_message "pynvim is already installed"
    fi
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

