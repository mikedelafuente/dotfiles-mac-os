#!/bin/bash

# --------------------------
# Setup Rust and Cargo for macOS
# --------------------------
# Rust is installed via rustup, which is the standard method across all platforms.
#
# Rustup provides:
# - Multiple toolchain versions (stable, beta, nightly)
# - Easy updates with 'rustup update'
# - Component management (rust-analyzer, clippy, rustfmt, etc.)
# - Cross-compilation support
# - Official support from the Rust team
# - Industry standard approach
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

print_tool_setup_start "Rust and Cargo"

# --------------------------
# Install Rustup
# --------------------------

# Check if Rust is already installed
if ! command -v cargo &> /dev/null; then
    print_info_message "Installing rustup via Homebrew"

    # Install rustup-init from Homebrew
    brew_install_formula rustup-init

    # Run rustup-init to install stable toolchain
    print_info_message "Running rustup-init to install stable Rust toolchain"
    rustup-init -y --default-toolchain stable

    # Source the cargo environment for immediate use
    # shellcheck source=/dev/null
    # Source cargo env only if it exists
    if [ -f "$USER_HOME_DIR/.cargo/env" ]; then
      # shellcheck disable=SC1090
      source "$USER_HOME_DIR/.cargo/env"
    fi 

    print_info_message "Rust installed successfully"
    print_info_message "Rust version: $(rustc --version)"
    print_info_message "Cargo version: $(cargo --version)"
    print_info_message "Rustup version: $(rustup --version)"
else
    print_info_message "Rust and Cargo are already installed"
    print_info_message "Rust version: $(rustc --version)"
    print_info_message "Cargo version: $(cargo --version)"
fi

# --------------------------
# Provide Update Instructions
# --------------------------

echo ""
print_info_message "To update Rust in the future, run:"
print_info_message "  rustup update"
echo ""
print_info_message "To install additional components, use:"
print_info_message "  rustup component add rust-analyzer  # LSP for IDE integration"
print_info_message "  rustup component add clippy         # Linter"
print_info_message "  rustup component add rustfmt        # Code formatter"
echo ""
print_info_message "To switch toolchains:"
print_info_message "  rustup install nightly              # Install nightly"
print_info_message "  rustup default stable               # Set default to stable"

print_tool_setup_complete "Rust and Cargo"  

