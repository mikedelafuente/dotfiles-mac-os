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
# Install Claude Code via npm
# --------------------------

# Load NVM if available (required for npm with NVM installations)
export NVM_DIR="$USER_HOME_DIR/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    print_error_message "npm is not installed. Please run setup-node.sh first."
    exit 1
fi

# Install Claude Code via npm (no sudo needed with NVM)
if ! command -v claude-code &> /dev/null; then
    print_action_message "Installing Claude Code CLI globally via npm..."
    npm install -g @anthropic-ai/claude-code

    if command -v claude-code &> /dev/null; then
        print_success_message "Claude Code CLI installed successfully!"
        claude-code --version
    else
        print_error_message "Failed to install Claude Code CLI"
        exit 1
    fi
else
    print_info_message "Claude Code CLI is already installed."
    claude-code --version
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


