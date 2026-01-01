#!/bin/bash
# --------------------------
# Setup Nerd Fonts via Homebrew Cask
# --------------------------

# --------------------------
# Import Common Header
# --------------------------

CURRENT_FILE_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

if [ -r "$CURRENT_FILE_DIR/dotheader.sh" ]; then
  # shellcheck source=/dev/null
  source "$CURRENT_FILE_DIR/dotheader.sh"
else
  echo "Missing header file: $CURRENT_FILE_DIR/dotheader.sh"
  exit 1
fi

# --------------------------
# Install Nerd Fonts
# --------------------------

print_tool_setup_start "Nerd Fonts"

# Tap the Homebrew cask-fonts repository if not already tapped
brew_tap_if_needed homebrew/cask-fonts

# Nerd Fonts to install (same as original Arch setup)
NERD_FONTS=(
    font-meslo-lg-nerd-font
    font-ubuntu-nerd-font
    font-fira-code-nerd-font
    font-jetbrains-mono-nerd-font
    font-hack-nerd-font
)

print_line_break "Installing Nerd Fonts via Homebrew Cask"

# Install each font cask
brew_install_casks "${NERD_FONTS[@]}"

print_success_message "Nerd Fonts installed successfully!"
print_info_message "Fonts are automatically available to all applications on macOS"
print_info_message "No font cache refresh needed"

print_tool_setup_complete "Nerd Fonts"
