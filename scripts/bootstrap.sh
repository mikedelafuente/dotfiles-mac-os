#!/bin/bash
# ----------------
# Bootstrap Script for macOS
# ----------------
#
# Determine if we are running with sudo, and if so get the actual user's home directory
if [ "$(whoami)" != "${SUDO_USER:-$(whoami)}" ]; then
    USER_HOME_DIR=$(eval echo "~${SUDO_USER}")
else
    USER_HOME_DIR="$HOME"
fi

# Make a bootstrap config folder
BOOTSTRAP_CONFIG_DIR="$USER_HOME_DIR/.config/dotfiles-mac-os"
mkdir -p "$BOOTSTRAP_CONFIG_DIR"

# Read in configuration from file if it exists
if [ -r "$BOOTSTRAP_CONFIG_DIR/.dotfiles_bootstrap_config" ]; then
  # shellcheck source=/dev/null
  source "$BOOTSTRAP_CONFIG_DIR/.dotfiles_bootstrap_config"
else
  echo "Configuration file not found."
  FULL_NAME=""
fi

# Prompt for full name
if [ -z "$FULL_NAME" ]; then
  read -rp "Enter your full name (e.g., John Doe): " FULL_NAME
else
  read -rp "Enter your full name (e.g., John Doe) [$FULL_NAME]: " INPUT_FULL_NAME
  if [ -n "$INPUT_FULL_NAME" ]; then
    FULL_NAME="$INPUT_FULL_NAME"
  fi
fi

# Prompt for email address
if [ -z "$EMAIL_ADDRESS" ]; then
  read -rp "Enter your email address (e.g., john.doe@example.com): " EMAIL_ADDRESS
else
  read -rp "Enter your email address (e.g., john.doe@example.com) [$EMAIL_ADDRESS]: " INPUT_EMAIL_ADDRESS
  if [ -n "$INPUT_EMAIL_ADDRESS" ]; then
    EMAIL_ADDRESS="$INPUT_EMAIL_ADDRESS"
  fi
fi


# Validate the variables with the user
echo "Please confirm the following information:"
echo "Full Name: $FULL_NAME"
echo "Email Address: $EMAIL_ADDRESS"

read -rp "Is this information correct? (y/n): " CONFIRMATION
if [[ ! "$CONFIRMATION" =~ ^[Yy]$ ]]; then
  echo "Aborting. Please run the script again to enter the correct information."
  exit 1
fi

# Write the configuration file
{
  echo "# Configuration file for dotfiles bootstrap script"
  echo "FULL_NAME=\"$FULL_NAME\""
  echo "EMAIL_ADDRESS=\"$EMAIL_ADDRESS\""
} > "$BOOTSTRAP_CONFIG_DIR/.dotfiles_bootstrap_config"

# --------------------------
# Start of Bootstrap Script
# --------------------------

echo "Starting bootstrap process... pwd is $(pwd)"
echo "macOS Version: $(sw_vers -productVersion)"
echo "Architecture: $(uname -m)"
echo "Current user: $(whoami)"
echo "Home directory: $HOME"
echo "Real user: ${SUDO_USER:-$(whoami)}"
echo "Home directory of real user: $(eval echo ~${SUDO_USER:-$(whoami)})"
echo "Shell: $SHELL"
echo "Script directory: $(dirname -- "${BASH_SOURCE[0]}")"
echo "----------------------------------------"

if [ "$(whoami)" != "${SUDO_USER:-$(whoami)}" ]; then
    echo "Please start this script without sudo."
    exit 1
fi

# Run a sudo command early to prompt for the password
sudo -v

# Keep sudo alive in the background for the duration of the script
# This prevents multiple password prompts during a long bootstrap process
{
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" 2>/dev/null || exit
    done
} &
SUDO_KEEPALIVE_PID=$!

# Ensure we kill the keepalive process when the script exits
trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT

# --------------------------
# Import Common Header
# --------------------------

# Add header file
CURRENT_FILE_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

# Source header (uses SCRIPT_DIR and loads lib.sh)
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

# Set the script directory variable
DF_SCRIPT_DIR="$CURRENT_FILE_DIR"

# --------------------------
# Ensure Homebrew is Installed
# --------------------------

print_line_break "Homebrew Setup"

ensure_homebrew_installed

# --------------------------
# Update Homebrew (Rate Limited)
# --------------------------

brew_update_if_stale

# --------------------------
# Run Individual Setup Scripts
# --------------------------

# Install Essential Packages
bash "$DF_SCRIPT_DIR/setup-essentials.sh"

# Set up Git configuration
bash "$DF_SCRIPT_DIR/setup-git.sh" "$FULL_NAME" "$EMAIL_ADDRESS"

# Setup GitHub CLI and Copilot CLI
bash "$DF_SCRIPT_DIR/setup-github-cli.sh"

# --------------------------
# Run Individual Setup Scripts
# --------------------------

# Install Node.js and npm (needed by multiple tools)
bash "$DF_SCRIPT_DIR/setup-node.sh"

# Setup Python
bash "$DF_SCRIPT_DIR/setup-python.sh"

# Setup Starship Prompt (works with zsh)
bash "$DF_SCRIPT_DIR/setup-starship.sh"

# Before setting up Alacritty, ensure Rust is installed
bash "$DF_SCRIPT_DIR/setup-rust.sh"

# Setup Go (Golang)
bash "$DF_SCRIPT_DIR/setup-golang.sh"

# Setup Alacritty terminal
bash "$DF_SCRIPT_DIR/setup-alacritty.sh"

# Setup TablePlus for database management
bash "$DF_SCRIPT_DIR/setup-tableplus.sh"

# Setup Neovim and Lazyvim - This needs to run after python setup
bash "$DF_SCRIPT_DIR/setup-neovim.sh"

# Run the setup-docker.sh script to set up Docker
bash "$DF_SCRIPT_DIR/setup-docker.sh"

# Setup Minikube (Kubernetes cluster manager)
bash "$DF_SCRIPT_DIR/setup-minikube.sh"

# Install Claude Code CLI
bash "$DF_SCRIPT_DIR/setup-claude.sh"

# Setup Code Command (development environment launcher)
bash "$DF_SCRIPT_DIR/setup-code.sh"

# Install PHP
bash "$DF_SCRIPT_DIR/setup-php.sh"

# Install Ruby on Rails
bash "$DF_SCRIPT_DIR/setup-ruby.sh"

# Install Postman
bash "$DF_SCRIPT_DIR/setup-postman.sh"

# Install Spotify
bash "$DF_SCRIPT_DIR/setup-spotify.sh"

# Install Obsidian
bash "$DF_SCRIPT_DIR/setup-obsidian.sh"

# Install Zoom
bash "$DF_SCRIPT_DIR/setup-zoom.sh"

# Setup Nerd Fonts (Homebrew cask-fonts)
bash "$DF_SCRIPT_DIR/setup-fonts.sh"

# Setup macOS-specific productivity tools
bash "$DF_SCRIPT_DIR/setup-rectangle.sh"
bash "$DF_SCRIPT_DIR/setup-raycast.sh"
bash "$DF_SCRIPT_DIR/setup-karabiner.sh"

# Link dotfiles using GNU Stow
bash "$DF_SCRIPT_DIR/stow-dotfiles.sh" link

# --------------------------
# Clean Up
# --------------------------

print_line_break "Cleaning up Homebrew"

brew_cleanup

print_line_break "Bootstrap completed!"

print_success_message "Setup is complete. Please restart your terminal to apply all changes."
print_info_message "Shell: $SHELL"
print_info_message "Next steps:"
print_info_message "  1. Restart your terminal"
print_info_message "  2. Verify Homebrew: brew doctor"
print_info_message "  3. Check dotfiles: ls -la ~/ | grep '^l'"

