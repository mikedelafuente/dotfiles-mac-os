#!/bin/bash

# --------------------------
# Setup PHP for macOS
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

print_tool_setup_start "PHP"

# --------------------------
# Install PHP
# --------------------------

# Check if PHP is already installed
if command -v php &> /dev/null; then
    print_info_message "PHP is already installed. Skipping installation."
else
    print_info_message "Installing PHP and common extensions"
    brew_install_formula php

    # Verify installation
    if command -v php &> /dev/null; then
        print_info_message "PHP installed successfully."
    else
        print_error_message "PHP installation failed."
        exit 1
    fi
fi

# Print PHP version
print_info_message "PHP version: $(php --version | head -n 1)"

# --------------------------
# Install Composer
# --------------------------

if command -v composer &> /dev/null; then
    print_info_message "Composer is already installed. Skipping installation."
    print_info_message "Composer version: $(composer --version)"
else
    print_info_message "Installing Composer"
    brew_install_formula composer

    if command -v composer &> /dev/null; then
        print_info_message "Composer installed successfully."
        print_info_message "Composer version: $(composer --version)"
    else
        print_warning_message "Composer installation failed."
    fi
fi

# --------------------------
# PHP Configuration on macOS
# --------------------------

# On macOS, Homebrew PHP comes with most common extensions compiled in
# If you need to customize PHP settings, the configuration file is located at:
# /opt/homebrew/etc/php/<version>/php.ini

PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_INI_PATH="/opt/homebrew/etc/php/${PHP_VERSION}/php.ini"

if [ -f "$PHP_INI_PATH" ]; then
    print_info_message "PHP configuration file: $PHP_INI_PATH"
    print_info_message "Most common extensions are already enabled by default"
else
    print_warning_message "PHP configuration file not found at expected location"
fi

# --------------------------
# Install Laravel Installer
# --------------------------

if command -v laravel &> /dev/null; then
    print_info_message "Laravel installer is already installed."
    print_info_message "Laravel version: $(laravel --version)"
else
    if command -v composer &> /dev/null; then
        print_info_message "Installing Laravel installer globally via Composer"
        composer global require laravel/installer

        # Add Composer global bin to PATH if not already there
        COMPOSER_BIN="$USER_HOME_DIR/.config/composer/vendor/bin"
        ZSHRC="$USER_HOME_DIR/.zshrc"
        if [[ ":$PATH:" != *":$COMPOSER_BIN:"* ]] && [ -f "$ZSHRC" ]; then
            print_info_message "Adding Composer global bin to PATH in ~/.zshrc"
            echo "export PATH=\"\$PATH:$COMPOSER_BIN\"" >> "$ZSHRC"
        fi

        print_info_message "Laravel installer installed. Restart your terminal or run:"
        print_info_message "  export PATH=\"\$PATH:$COMPOSER_BIN\""
    else
        print_warning_message "Cannot install Laravel installer - Composer not available"
    fi
fi

print_tool_setup_complete "PHP"


