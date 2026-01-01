#!/bin/bash

# --------------------------
# Setup Bash Shell for macOS
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

print_tool_setup_start "Bash"

# --------------------------
# Install Bash
# --------------------------

# Install latest Bash via Homebrew (macOS includes an old version)
if ! brew list bash &> /dev/null; then
    print_info_message "Installing latest Bash via Homebrew"
    brew_install_formula bash
else
    print_info_message "Bash is already installed via Homebrew. Skipping installation."
fi

# --------------------------
# Set Bash as Default Shell
# --------------------------

# Add Homebrew bash to allowed shells if not already present
BREW_BASH="/opt/homebrew/bin/bash"
if ! grep -q "$BREW_BASH" /etc/shells; then
    print_info_message "Adding Homebrew Bash to /etc/shells"
    echo "$BREW_BASH" | sudo tee -a /etc/shells > /dev/null
fi

# Set Homebrew Bash as the default shell
if [ "$SHELL" != "$BREW_BASH" ]; then
    print_info_message "Changing default shell to Homebrew Bash ($BREW_BASH)"
    chsh -s "$BREW_BASH"
else
    print_info_message "Homebrew Bash is already the default shell."
fi

# --------------------------
# Install Starship Prompt
# --------------------------

# Install Starship prompt for Bash
if ! command -v starship &> /dev/null; then
    print_info_message "Installing Starship prompt via Homebrew"
    brew_install_formula starship
else
    print_info_message "Starship prompt is already installed."
fi

print_tool_setup_complete "Bash"

