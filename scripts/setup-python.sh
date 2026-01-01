#!/bin/bash

# --------------------------
# Setup Python for macOS
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

print_tool_setup_start "Python"

# --------------------------
# Install Python
# --------------------------

# Install Python 3 via Homebrew (macOS includes an old version)
print_info_message "Installing Python 3 via Homebrew"
brew_install_formula python@3.12

# Python 3 from Homebrew includes pip automatically
print_info_message "Python version: $(python3 --version)"
print_info_message "pip version: $(pip3 --version)"

print_success_message "Python 3 and pip installed successfully!"
print_info_message "Python and pip are available as 'python3' and 'pip3'"

print_tool_setup_complete "Python"

