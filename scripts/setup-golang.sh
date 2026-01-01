#!/bin/bash

# --------------------------
# Setup Go (Golang) for macOS
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

print_tool_setup_start "Go (golang)"

# --------------------------
# Install Golang
# --------------------------

print_info_message "Installing Go via Homebrew"
brew_install_formula go

# Print Golang version
print_info_message "Golang version: $(go version)"

# Install gopls (Go Language Server) via Homebrew
print_info_message "Installing gopls (Go Language Server)"
brew_install_formula gopls

print_success_message "Go installed successfully!"
print_info_message "GOPATH is automatically set by Go (defaults to ~/go)"

print_tool_setup_complete "Go (golang)"

