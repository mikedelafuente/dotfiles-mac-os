#!/bin/bash

# --------------------------
# Setup Kitty Terminal for Arch Linux
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

print_tool_setup_start "Kitty"

# --------------------------
# Install Kitty
# --------------------------

# Install Kitty using Homebrew Cask
if ! command -v kitty &> /dev/null; then
    print_info_message "Installing Kitty via Homebrew Cask"
    brew_install_cask kitty
else
    print_info_message "Kitty is already installed. Skipping installation."
fi

# --------------------------
# Install Catppuccin Theme for Kitty
# --------------------------

KITTY_THEMES_DIR="$USER_HOME_DIR/.config/kitty/themes"
CATPPUCCIN_THEME_FILE="$KITTY_THEMES_DIR/catppuccin-mocha.conf"

if [ ! -f "$CATPPUCCIN_THEME_FILE" ]; then
    print_info_message "Installing Catppuccin theme for Kitty"

    mkdir -p "$KITTY_THEMES_DIR"

    # Download Catppuccin Mocha theme
    if wget -q "https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf" -O "$CATPPUCCIN_THEME_FILE"; then
        print_info_message "Catppuccin Mocha theme installed successfully"
    else
        print_error_message "Failed to download Catppuccin theme"
    fi
else
    print_info_message "Catppuccin theme already installed. Skipping."
fi

# --------------------------
# macOS Configuration Notes
# --------------------------

print_info_message ""
print_info_message "Kitty installed successfully!"
print_info_message ""
print_info_message "To use Kitty as your default terminal:"
print_info_message "  1. Launch Kitty from Applications folder"
print_info_message "  2. Set it as default in Terminal app preferences if desired"
print_info_message "  3. Or simply use Spotlight/Raycast to launch Kitty directly"
print_info_message ""
print_info_message "Kitty configuration is managed by dotfiles at:"
print_info_message "  ~/.config/kitty/kitty.conf"

print_tool_setup_complete "Kitty"

