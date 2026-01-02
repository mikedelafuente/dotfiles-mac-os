#!/bin/bash

# --------------------------
# Setup Claude Code CLI for macOS
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

print_tool_setup_start "Claude Code CLI"

# --------------------------
# Install Claude Code via Homebrew
# --------------------------

# Check if Claude Code is already installed
if ! command -v claude &> /dev/null; then
    print_action_message "Installing Claude Code CLI via Homebrew..."
    brew_install_formula claude-code
else
    print_info_message "Claude Code CLI is already installed."
fi

# Verify installation
if command -v claude &> /dev/null; then
    print_success_message "Claude Code CLI installed successfully!"
    claude --version
else
    print_error_message "Failed to install Claude Code CLI"
    exit 1
fi

# --------------------------
# Setup Instructions
# --------------------------

print_info_message ""
print_info_message "Claude Code CLI installation complete!"
print_info_message ""
print_info_message "Next steps:"
print_info_message "  1. Authenticate with your Anthropic API key:"
print_info_message "     claude-code auth"
print_info_message ""
print_info_message "  2. Start using Claude Code:"
print_info_message "     claude-code [directory]"
print_info_message ""

print_tool_setup_complete "Claude Code CLI"


