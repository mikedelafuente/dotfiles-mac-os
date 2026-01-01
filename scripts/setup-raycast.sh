#!/bin/bash
# --------------------------
# Setup Raycast (Productivity Launcher)
# --------------------------
# Raycast is a powerful Spotlight replacement

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
# Install Raycast
# --------------------------

print_tool_setup_start "Raycast"

print_info_message "Raycast is a blazingly fast productivity launcher for macOS"
print_info_message "Features: app launcher, clipboard history, snippets, extensions, and more"

brew_install_cask raycast

if [ $? -eq 0 ]; then
    print_success_message "Raycast installed successfully!"
    print_info_message "Launch Raycast from Applications to complete setup"
    print_info_message "Recommended settings:"
    print_info_message "  • Set hotkey to Cmd+Space (replace Spotlight)"
    print_info_message "  • Enable clipboard history"
    print_info_message "  • Browse extensions for GitHub, Jira, etc."
fi

print_tool_setup_complete "Raycast"
