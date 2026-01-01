#!/bin/bash

# --------------------------
# Setup Zoom for macOS
# --------------------------
# Zoom is installed via Homebrew Cask.
# The cask provides the official Zoom client.
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

print_tool_setup_start "Zoom"

# --------------------------
# Install Zoom via Homebrew Cask
# --------------------------

# Check if Zoom is already installed
if command -v zoom &> /dev/null; then
    print_info_message "Zoom is already installed. Skipping installation."
else
    print_info_message "Installing Zoom via Homebrew Cask"

    # Install Zoom via Homebrew Cask
    brew_install_cask zoom

    if command -v zoom &> /dev/null; then
        print_info_message "Zoom installed successfully"
        print_info_message "You can launch Zoom from Applications"
    else
        print_error_message "Zoom installation failed"
    fi
fi

print_tool_setup_complete "Zoom"

