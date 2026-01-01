#!/bin/bash

# --------------------------
# Setup Obsidian for macOS
# --------------------------
# Obsidian is installed via Homebrew Cask.
# The cask provides:
# - Easy updates through Homebrew
# - Native macOS integration
# - Standard macOS application management
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

print_tool_setup_start "Obsidian"

# --------------------------
# Install Obsidian via Homebrew Cask
# --------------------------

# Check if Obsidian is already installed
if command -v obsidian &> /dev/null; then
    print_info_message "Obsidian is already installed. Skipping installation."
else
    print_info_message "Installing Obsidian via Homebrew Cask"

    # Install Obsidian via Homebrew Cask
    brew_install_cask obsidian

    if command -v obsidian &> /dev/null; then
        print_info_message "Obsidian installed successfully"
        print_info_message "You can launch Obsidian from Applications"
    else
        print_error_message "Obsidian installation failed"
    fi
fi

print_tool_setup_complete "Obsidian"

