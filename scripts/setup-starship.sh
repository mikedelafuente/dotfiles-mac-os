#!/bin/bash

# --------------------------
# Setup Starship Prompt for macOS
# --------------------------
# Starship is a minimal, fast, and customizable prompt for any shell (zsh, bash, fish, etc.)
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

print_tool_setup_start "Starship Prompt"

# --------------------------
# Install Starship
# --------------------------

if command -v starship &> /dev/null; then
    print_info_message "Starship prompt is already installed. Skipping installation."
    print_info_message "Starship version: $(starship --version)"
else
    print_info_message "Installing Starship prompt via Homebrew"
    brew_install_formula starship

    if command -v starship &> /dev/null; then
        print_info_message "Starship installed successfully"
        print_info_message "Starship version: $(starship --version)"
    else
        print_error_message "Starship installation failed"
    fi
fi

# --------------------------
# Configuration
# --------------------------

print_info_message "Starship configuration: ~/.config/starship.toml"
print_info_message "The .zshrc file already includes: eval \"\$(starship init zsh)\""

print_tool_setup_complete "Starship Prompt"
