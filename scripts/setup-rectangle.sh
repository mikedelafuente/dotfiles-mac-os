#!/bin/bash
# --------------------------
# Setup Rectangle (Window Management)
# --------------------------
# Rectangle provides Hyprland-style window tiling for macOS

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
# Install Rectangle
# --------------------------

print_tool_setup_start "Rectangle Window Manager"

print_info_message "Rectangle provides keyboard-driven window management for macOS"
print_info_message "It replaces the Hyprland tiling functionality from Linux"

brew_install_cask rectangle

if [ $? -eq 0 ]; then
    print_success_message "Rectangle installed successfully!"
    print_info_message "Launch Rectangle from Applications to set up keyboard shortcuts"
    print_info_message "Recommended shortcuts:"
    print_info_message "  • Left Half: Ctrl+Option+Left"
    print_info_message "  • Right Half: Ctrl+Option+Right"
    print_info_message "  • Maximize: Ctrl+Option+Return"
    print_info_message "  • Center: Ctrl+Option+C"
fi

print_tool_setup_complete "Rectangle Window Manager"
