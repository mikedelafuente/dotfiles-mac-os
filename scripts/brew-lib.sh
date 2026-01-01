#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Homebrew Library Functions for macOS
# ------------------------------------------------------------------------------
# This library provides utility functions for managing Homebrew packages
# It should be sourced by setup scripts via dotheader.sh

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

# Apple Silicon uses /opt/homebrew, Intel uses /usr/local
# Since we're targeting Apple Silicon only, hardcode the path
BREW_PREFIX="/opt/homebrew"
BREW_BIN="$BREW_PREFIX/bin/brew"

# Cache file for tracking last brew update
BREW_UPDATE_CACHE="$HOME/.cache/dotfiles-mac-os/.last_brew_update"

# ------------------------------------------------------------------------------
# Homebrew Installation
# ------------------------------------------------------------------------------

ensure_homebrew_installed() {
    if command -v brew &> /dev/null; then
        print_info_message "Homebrew is already installed at: $(command -v brew)"
        return 0
    fi

    print_action_message "Homebrew not found. Installing Homebrew..."

    # Install Homebrew using official installation script
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    eval "$($BREW_BIN shellenv)"

    if command -v brew &> /dev/null; then
        print_success_message "Homebrew successfully installed!"
    else
        print_error_message "Homebrew installation failed!"
        print_info_message "Please install Homebrew manually: https://brew.sh"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Homebrew Updates (Rate-Limited)
# ------------------------------------------------------------------------------

brew_update_if_stale() {
    # Create cache directory if it doesn't exist
    mkdir -p "$(dirname "$BREW_UPDATE_CACHE")"

    # Get last update timestamp (default to 0 if file doesn't exist)
    local last_update=0
    if [ -f "$BREW_UPDATE_CACHE" ]; then
        last_update=$(cat "$BREW_UPDATE_CACHE")
    fi

    local current_time=$(date +%s)
    local time_diff=$((current_time - last_update))
    local one_day=86400  # 24 hours in seconds

    if [ "$time_diff" -lt "$one_day" ]; then
        print_info_message "Last Homebrew update was less than a day ago. Skipping update."
        return 0
    fi

    print_action_message "Updating Homebrew (last update was $(($time_diff / 3600)) hours ago)..."

    if brew update; then
        echo "$current_time" > "$BREW_UPDATE_CACHE"
        print_success_message "Homebrew updated successfully!"
    else
        print_warning_message "Homebrew update failed, but continuing..."
    fi
}

# ------------------------------------------------------------------------------
# Package Installation - Formulas (CLI Tools)
# ------------------------------------------------------------------------------

is_formula_installed() {
    local package="$1"

    if brew list "$package" &> /dev/null; then
        return 0  # Package is installed
    else
        return 1  # Package is not installed
    fi
}

brew_install_formula() {
    local package="$1"

    if is_formula_installed "$package"; then
        print_info_message "Formula already installed: $package"
        return 0
    fi

    print_action_message "Installing formula: $package"

    if brew install "$package"; then
        print_success_message "Successfully installed: $package"
        return 0
    else
        print_error_message "Failed to install: $package"
        return 1
    fi
}

brew_install_formulas() {
    # Install multiple formulas at once
    # Usage: brew_install_formulas package1 package2 package3

    local packages_to_install=()

    for package in "$@"; do
        if ! is_formula_installed "$package"; then
            packages_to_install+=("$package")
        else
            print_info_message "Formula already installed: $package"
        fi
    done

    if [ ${#packages_to_install[@]} -eq 0 ]; then
        print_info_message "All formulas are already installed"
        return 0
    fi

    print_action_message "Installing ${#packages_to_install[@]} formula(s): ${packages_to_install[*]}"

    if brew install "${packages_to_install[@]}"; then
        print_success_message "Successfully installed ${#packages_to_install[@]} formula(s)!"
        return 0
    else
        print_error_message "Failed to install some formulas"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Package Installation - Casks (GUI Applications)
# ------------------------------------------------------------------------------

is_cask_installed() {
    local cask="$1"

    if brew list --cask "$cask" &> /dev/null; then
        return 0  # Cask is installed
    else
        return 1  # Cask is not installed
    fi
}

brew_install_cask() {
    local cask="$1"

    if is_cask_installed "$cask"; then
        print_info_message "Cask already installed: $cask"
        return 0
    fi

    print_action_message "Installing cask: $cask"

    if brew install --cask "$cask"; then
        print_success_message "Successfully installed: $cask"
        return 0
    else
        print_error_message "Failed to install: $cask"
        return 1
    fi
}

brew_install_casks() {
    # Install multiple casks at once
    # Usage: brew_install_casks app1 app2 app3

    local casks_to_install=()

    for cask in "$@"; do
        if ! is_cask_installed "$cask"; then
            casks_to_install+=("$cask")
        else
            print_info_message "Cask already installed: $cask"
        fi
    done

    if [ ${#casks_to_install[@]} -eq 0 ]; then
        print_info_message "All casks are already installed"
        return 0
    fi

    print_action_message "Installing ${#casks_to_install[@]} cask(s): ${casks_to_install[*]}"

    if brew install --cask "${casks_to_install[@]}"; then
        print_success_message "Successfully installed ${#casks_to_install[@]} cask(s)!"
        return 0
    else
        print_error_message "Failed to install some casks"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Package Management - Cleanup
# ------------------------------------------------------------------------------

brew_cleanup() {
    print_action_message "Cleaning up old Homebrew versions..."

    if brew cleanup; then
        print_success_message "Homebrew cleanup complete!"
    else
        print_warning_message "Homebrew cleanup had some issues, but continuing..."
    fi
}

# ------------------------------------------------------------------------------
# Tap Management
# ------------------------------------------------------------------------------

brew_tap_if_needed() {
    local tap="$1"

    if brew tap | grep -q "^$tap\$"; then
        print_info_message "Tap already added: $tap"
        return 0
    fi

    print_action_message "Adding Homebrew tap: $tap"

    if brew tap "$tap"; then
        print_success_message "Successfully added tap: $tap"
        return 0
    else
        print_error_message "Failed to add tap: $tap"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

get_brew_prefix() {
    # Returns the Homebrew prefix path
    echo "$BREW_PREFIX"
}

ensure_brew_in_path() {
    # Adds Homebrew to PATH for the current session
    if ! command -v brew &> /dev/null; then
        eval "$($BREW_BIN shellenv)"
    fi
}
