#!/bin/bash

# --------------------------
# Setup Alacritty Terminal for macOS
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

print_tool_setup_start "Alacritty"

# --------------------------
# Install Alacritty
# --------------------------

# Install Alacritty using Homebrew Cask
if ! command -v alacritty &> /dev/null; then
    print_info_message "Installing Alacritty via Homebrew Cask"
    brew_install_cask alacritty
else
    print_info_message "Alacritty is already installed. Skipping installation."
fi

# --------------------------
# macOS Configuration Notes
# --------------------------

print_info_message ""
print_info_message "Alacritty installed successfully!"
print_info_message ""
print_info_message "To use Alacritty as your default terminal:"
print_info_message "  1. Launch Alacritty from Applications folder"
print_info_message "  2. Set it as default in Terminal app preferences if desired"
print_info_message "  3. Or simply use Spotlight/Raycast to launch Alacritty directly"
print_info_message ""
print_info_message "Alacritty configuration is managed by dotfiles at:"
print_info_message "  ~/.config/alacritty/alacritty.toml"

print_tool_setup_complete "Alacritty"
