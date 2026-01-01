#!/bin/bash
# --------------------------
# Setup Karabiner-Elements (Keyboard Customization)
# --------------------------
# Advanced keyboard remapping for macOS

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
# Install Karabiner-Elements
# --------------------------

print_tool_setup_start "Karabiner-Elements"

print_info_message "Karabiner-Elements is a powerful keyboard customizer for macOS"
print_info_message "Use it to remap keys, create complex shortcuts, and more"

brew_install_cask karabiner-elements

if [ $? -eq 0 ]; then
    print_success_message "Karabiner-Elements installed successfully!"
    print_info_message "Launch Karabiner-Elements from Applications to configure"
    print_info_message "Common use cases:"
    print_info_message "  • Remap Caps Lock to Control/Escape"
    print_info_message "  • Create hyper key (Cmd+Ctrl+Option+Shift)"
    print_info_message "  • Import complex modifications from community"
    print_warning_message "Note: Requires granting Accessibility permissions in System Settings"
fi

print_tool_setup_complete "Karabiner-Elements"
