#!/bin/bash

# --------------------------
# Setup Docker for macOS
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

print_tool_setup_start "Docker"

# --------------------------
# Check if Docker is Already Installed
# --------------------------

# Check if Docker Desktop is installed
if [ -d "/Applications/Docker.app" ] && command -v docker &> /dev/null; then
  print_info_message "Docker Desktop is already installed."

  # Check if Docker daemon is running
  if docker info &> /dev/null; then
    print_success_message "Docker is installed and running."
    docker --version
    print_tool_setup_complete "Docker"
    exit 0
  else
    print_warning_message "Docker Desktop is installed but not running."
    print_info_message "Please launch Docker Desktop from Applications folder."
    exit 0
  fi
fi

# --------------------------
# Install Docker Desktop
# --------------------------

print_info_message "Installing Docker Desktop via Homebrew Cask"
brew_install_cask docker

# --------------------------
# Install Lazy Docker
# --------------------------

print_info_message "Installing lazydocker via Homebrew"
brew_install_formula lazydocker

# --------------------------
# Installation Complete
# --------------------------

echo ""
print_success_message "Docker Desktop installation completed!"
echo ""
print_warning_message "IMPORTANT: Next steps to complete Docker setup:"
print_info_message "  1. Launch Docker Desktop from Applications folder"
print_info_message "  2. Grant necessary permissions in System Settings → Privacy & Security"
print_info_message "  3. Wait for Docker daemon to start (whale icon appears in menu bar)"
print_info_message "  4. Docker commands will then work in terminal"
echo ""
print_info_message "After Docker Desktop starts, verify with: docker --version"
echo ""

print_tool_setup_complete "Docker"

