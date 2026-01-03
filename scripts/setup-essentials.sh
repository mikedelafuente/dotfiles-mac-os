#!/bin/bash
# -------------------------
# Setup Essential Packages for macOS
# -------------------------

# --------------------------
# Import Common Header
# --------------------------

CURRENT_FILE_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

# Source header (uses SCRIPT_DIR and loads lib.sh)
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

# --------------------------
# Install Essential Packages
# --------------------------

print_tool_setup_start "Essential Packages"

# Essential CLI tools for macOS development
# Note: Removed xsel (X11), net-tools (use netstat), linux-firmware-intel (Linux-only)
# Added: GNU coreutils for Linux command compatibility
ESSENTIAL_PACKAGES=(
    git
    curl
    wget
    fzf
    ripgrep
    fd
    bat
    htop
    ncdu
    tree
    jq
    tmux
    ncurses
    btop
    duf
    stow
    shellcheck
    gh
    tldr
    fastfetch
    zoxide
    coreutils
    findutils
    gnu-sed
    gnu-tar
    grep
)

print_line_break "Installing essential packages via Homebrew"

# Use brew-lib function to install all formulas
brew_install_formulas "${ESSENTIAL_PACKAGES[@]}"

print_success_message "GNU coreutils installed. PATH configured in .zshrc to use GNU commands by default."
print_info_message "Zoxide initialization is configured in .zshrc for interactive shells."

print_tool_setup_complete "Essential Packages"
