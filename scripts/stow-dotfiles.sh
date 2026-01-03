#!/bin/bash

# ------------------------------------------------------------------------------
# Stow Dotfiles Management Script
# Replaces the old link-dotfiles.sh with GNU Stow integration
# ------------------------------------------------------------------------------

# Source the common header (provides DF_SCRIPT_DIR, USER_HOME_DIR, fn-lib functions)
source "$(dirname "${BASH_SOURCE[0]}")/dotheader.sh"

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

DOTFILES_REPO_ROOT="$(cd "$DF_SCRIPT_DIR/.." && pwd)"
STOW_DIR="$DOTFILES_REPO_ROOT/stow"
STOW_PACKAGE="dotfiles"
TARGET_DIR="$USER_HOME_DIR"

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

check_stow_installed() {
    if ! command -v stow &> /dev/null; then
        print_error_message "GNU Stow is not installed!"
        print_info_message "Install it with: brew install stow"
        exit 1
    fi
}

backup_existing_files() {
    print_info_message "Checking for existing files that need backup..."

    local backup_timestamp
    backup_timestamp="$(date +%Y%m%d_%H%M%S)"
    local files_backed_up=0

    # Get list of all files in stow package (store in array to avoid subshell issues)
    local file_list
    file_list=$(cd "$STOW_DIR/$STOW_PACKAGE" && find . -type f | sed 's|^\./||')

    # Process each file
    for rel_file in $file_list; do
        local target_file="$TARGET_DIR/$rel_file"

        # If target exists and is NOT a symlink, back it up
        if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
            local backup_file="$target_file.backup.$backup_timestamp"
            local backup_dir
            backup_dir="$(dirname "$backup_file")"

            # Ensure backup directory exists
            mkdir -p "$backup_dir"

            print_action_message "Backing up: $rel_file"
            if mv "$target_file" "$backup_file"; then
                ((files_backed_up++))
            else
                print_error_message "Failed to backup: $rel_file"
                exit 1
            fi
        fi
    done

    if [ "$files_backed_up" -eq 0 ]; then
        print_success_message "No conflicts found - ready to link!"
    else
        print_warning_message "Backed up $files_backed_up file(s) with suffix .backup.$backup_timestamp"
    fi
}

link_dotfiles() {
    print_line_break "Linking Dotfiles with GNU Stow"

    check_stow_installed

    print_info_message "Stow directory: $STOW_DIR"
    print_info_message "Package: $STOW_PACKAGE"
    print_info_message "Target: $TARGET_DIR"

    backup_existing_files

    print_action_message "Creating symlinks with GNU Stow..."

    # Capture stow output for debugging
    local stow_output
    stow_output=$(stow -d "$STOW_DIR" -t "$TARGET_DIR" -v "$STOW_PACKAGE" 2>&1)
    local stow_exit=$?

    if [ $stow_exit -eq 0 ]; then
        print_success_message "Dotfiles successfully linked!"
        print_info_message "All configuration files are now symlinked to $TARGET_DIR"
    else
        print_error_message "Failed to link dotfiles!"
        print_error_message "Stow output:"
        echo "$stow_output"
        print_info_message ""
        print_info_message "Possible solutions:"
        print_info_message "  1. Run 'bash $0 simulate' to see what stow would do"
        print_info_message "  2. Check for existing directories that conflict with stow"
        print_info_message "  3. Manually remove conflicting directories/files"
        exit 1
    fi
}

unlink_dotfiles() {
    print_line_break "Unlinking Dotfiles with GNU Stow"

    check_stow_installed

    print_info_message "Removing symlinks for package: $STOW_PACKAGE"
    print_action_message "Unlinking dotfiles..."

    if stow -d "$STOW_DIR" -t "$TARGET_DIR" -D -v "$STOW_PACKAGE" 2>&1; then
        print_success_message "Dotfiles successfully unlinked!"
        print_info_message "All symlinks have been removed from $TARGET_DIR"
    else
        print_error_message "Failed to unlink dotfiles!"
        exit 1
    fi
}

relink_dotfiles() {
    print_line_break "Relinking Dotfiles (Refresh)"

    print_info_message "This will unlink and then relink all dotfiles"
    print_action_message "Step 1: Unlinking..."

    stow -d "$STOW_DIR" -t "$TARGET_DIR" -D "$STOW_PACKAGE" &> /dev/null

    print_action_message "Step 2: Relinking..."

    if stow -d "$STOW_DIR" -t "$TARGET_DIR" -R -v "$STOW_PACKAGE" 2>&1; then
        print_success_message "Dotfiles successfully relinked!"
    else
        print_error_message "Failed to relink dotfiles!"
        exit 1
    fi
}

simulate_link() {
    print_line_break "Simulating Dotfile Linking (Dry Run)"

    check_stow_installed

    print_info_message "Running stow simulation - no changes will be made"
    print_action_message "Simulating link operation..."

    stow -d "$STOW_DIR" -t "$TARGET_DIR" -n -v "$STOW_PACKAGE" 2>&1

    print_success_message "Simulation complete!"
    print_info_message "Run '$0 link' to apply these changes"
}

restore_backups() {
    print_line_break "Restoring Backup Files"

    print_info_message "Searching for backup files..."

    # Find all backup files
    local backup_files
    backup_files=$(find "$TARGET_DIR" -name "*.backup.*" -type f 2>/dev/null)

    if [ -z "$backup_files" ]; then
        print_warning_message "No backup files found"
        return 0
    fi

    print_info_message "Found backup files. Restoring..."

    echo "$backup_files" | while read -r backup_file; do
        # Extract original filename by removing .backup.TIMESTAMP
        local original_file="${backup_file%.backup.*}"

        # Only restore if the original doesn't exist or is a broken symlink
        if [ ! -e "$original_file" ] || [ -L "$original_file" ]; then
            print_action_message "Restoring: $(basename "$original_file")"
            rm -f "$original_file"  # Remove broken symlink if exists
            mv "$backup_file" "$original_file"
        else
            print_warning_message "Skipping (file exists): $(basename "$original_file")"
        fi
    done

    print_success_message "Backup restoration complete!"
}

show_usage() {
    cat << EOF
Usage: $0 <command>

Commands:
    link        Link all dotfiles using GNU Stow
    unlink      Remove all dotfile symlinks
    relink      Refresh symlinks (unlink + link)
    simulate    Dry-run to see what would be linked
    restore     Restore files from .backup.* files
    help        Show this help message

Examples:
    $0 link              # Link dotfiles to home directory
    $0 simulate          # See what would happen (dry-run)
    $0 unlink            # Remove all symlinks
    $0 relink            # Refresh all symlinks
    $0 restore           # Restore from backups if linking failed

Note: Existing files will be backed up automatically with .backup suffix
EOF
}

# ------------------------------------------------------------------------------
# Main Script Logic
# ------------------------------------------------------------------------------

COMMAND="${1:-help}"

case "$COMMAND" in
    link)
        link_dotfiles
        ;;
    unlink)
        unlink_dotfiles
        ;;
    relink)
        relink_dotfiles
        ;;
    simulate|--simulate|-n|--dry-run)
        simulate_link
        ;;
    restore)
        restore_backups
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_error_message "Unknown command: $COMMAND"
        echo
        show_usage
        exit 1
        ;;
esac
