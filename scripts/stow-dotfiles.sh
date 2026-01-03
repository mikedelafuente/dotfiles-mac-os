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

    # Clean up first
    clean_broken_symlinks
    remove_empty_directories

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
        print_info_message "Try running: bash $0 fix"
        exit 1
    fi
}

fix_dotfiles() {
    print_line_break "Self-Healing Dotfiles Setup"

    check_stow_installed

    print_info_message "This will automatically fix common dotfile linking issues"
    print_info_message ""

    # Step 1: Clean broken symlinks
    print_line_break "Step 1: Cleaning broken symlinks"
    clean_broken_symlinks

    # Step 2: Remove empty directories
    print_line_break "Step 2: Removing empty directories"
    remove_empty_directories

    # Step 3: Restore from backups if files are missing
    print_line_break "Step 3: Restoring from backups"
    local restored=0
    while IFS= read -r -d '' backup_file; do
        local original_file="${backup_file%.backup.*}"
        if [ ! -e "$original_file" ]; then
            print_action_message "Restoring: ${original_file#$TARGET_DIR/}"
            mv "$backup_file" "$original_file"
            ((restored++))
        fi
    done < <(find "$TARGET_DIR" -name "*.backup.*" -type f -print0 2>/dev/null)

    if [ "$restored" -gt 0 ]; then
        print_success_message "Restored $restored file(s)"
    else
        print_info_message "No files needed restoration"
    fi

    # Step 4: Unlink any existing stow symlinks
    print_line_break "Step 4: Unlinking existing stow configuration"
    stow -d "$STOW_DIR" -t "$TARGET_DIR" -D "$STOW_PACKAGE" 2>/dev/null || true

    # Step 5: Clean up again
    print_line_break "Step 5: Final cleanup"
    clean_broken_symlinks
    remove_empty_directories

    # Step 6: Backup existing files
    print_line_break "Step 6: Backing up existing files"
    backup_existing_files

    # Step 7: Link with stow
    print_line_break "Step 7: Creating fresh symlinks"
    local stow_output
    stow_output=$(stow -d "$STOW_DIR" -t "$TARGET_DIR" -v "$STOW_PACKAGE" 2>&1)
    local stow_exit=$?

    if [ $stow_exit -eq 0 ]; then
        print_success_message "✓ Dotfiles successfully linked!"
        print_info_message "All configuration files are now symlinked to $TARGET_DIR"
        print_info_message ""
        print_info_message "You can safely delete backup files if everything works:"
        print_info_message "  find ~ -name '*.backup.*' -type f"
    else
        print_error_message "Failed to link dotfiles!"
        print_error_message "Stow output:"
        echo "$stow_output"
        print_info_message ""
        print_info_message "Please report this issue with the output above"
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

clean_broken_symlinks() {
    print_info_message "Cleaning up broken symlinks..."

    local cleaned=0
    # Find broken symlinks in common dotfile locations
    local search_paths=(
        "$TARGET_DIR/.config"
        "$TARGET_DIR/.local"
        "$TARGET_DIR"
    )

    for search_path in "${search_paths[@]}"; do
        if [ -d "$search_path" ]; then
            while IFS= read -r -d '' broken_link; do
                print_action_message "Removing broken symlink: ${broken_link#$TARGET_DIR/}"
                rm -f "$broken_link"
                ((cleaned++))
            done < <(find "$search_path" -maxdepth 3 -xtype l -print0 2>/dev/null)
        fi
    done

    if [ "$cleaned" -gt 0 ]; then
        print_success_message "Removed $cleaned broken symlink(s)"
    else
        print_info_message "No broken symlinks found"
    fi
}

remove_empty_directories() {
    print_info_message "Removing empty directories..."

    local removed=0
    local search_paths=(
        "$TARGET_DIR/.config"
        "$TARGET_DIR/.local"
    )

    for search_path in "${search_paths[@]}"; do
        if [ -d "$search_path" ]; then
            # Find and remove empty directories (depth-first)
            while IFS= read -r -d '' empty_dir; do
                if [ -d "$empty_dir" ] && [ -z "$(ls -A "$empty_dir" 2>/dev/null)" ]; then
                    print_action_message "Removing empty directory: ${empty_dir#$TARGET_DIR/}"
                    rmdir "$empty_dir" 2>/dev/null && ((removed++))
                fi
            done < <(find "$search_path" -depth -type d -print0 2>/dev/null)
        fi
    done

    if [ "$removed" -gt 0 ]; then
        print_success_message "Removed $removed empty director(ies)"
    fi
}

restore_backups() {
    print_line_break "Restoring Backup Files"

    print_info_message "Searching for backup files..."

    local restored=0
    # Find all backup files using process substitution to avoid subshell
    while IFS= read -r -d '' backup_file; do
        # Extract original filename by removing .backup.TIMESTAMP
        local original_file="${backup_file%.backup.*}"

        # Only restore if the original doesn't exist or is a broken symlink
        if [ ! -e "$original_file" ] || [ -L "$original_file" ]; then
            print_action_message "Restoring: ${original_file#$TARGET_DIR/}"
            rm -f "$original_file"  # Remove broken symlink if exists
            mv "$backup_file" "$original_file"
            ((restored++))
        else
            print_warning_message "Skipping (file exists): ${original_file#$TARGET_DIR/}"
        fi
    done < <(find "$TARGET_DIR" -name "*.backup.*" -type f -print0 2>/dev/null)

    if [ "$restored" -eq 0 ]; then
        print_warning_message "No backup files found or restored"
    else
        print_success_message "Restored $restored file(s) from backup"
    fi
}

clean_backups() {
    print_line_break "Cleaning Up Backup Files"

    print_info_message "Searching for backup files..."

    # Find all backup files
    local backup_files
    backup_files=$(find "$TARGET_DIR" -name "*.backup.*" -type f 2>/dev/null)

    if [ -z "$backup_files" ]; then
        print_success_message "No backup files found - already clean!"
        return 0
    fi

    # Count and show backup files
    local backup_count
    backup_count=$(echo "$backup_files" | wc -l | tr -d ' ')

    print_warning_message "Found $backup_count backup file(s):"
    echo ""

    # Show first 20 backup files
    echo "$backup_files" | head -20 | while read -r file; do
        echo "  - ${file#$TARGET_DIR/}"
    done

    if [ "$backup_count" -gt 20 ]; then
        echo "  ... and $((backup_count - 20)) more"
    fi

    echo ""
    print_warning_message "⚠️  This will PERMANENTLY delete all backup files!"
    print_info_message "If you want to restore them first, press Ctrl+C and run: $0 restore"
    echo ""
    read -p "Are you sure you want to delete all backups? (yes/no): " -r
    echo

    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info_message "Cancelled - no files were deleted"
        return 0
    fi

    # Delete backup files
    local deleted=0
    while IFS= read -r -d '' backup_file; do
        rm -f "$backup_file"
        ((deleted++))
    done < <(find "$TARGET_DIR" -name "*.backup.*" -type f -print0 2>/dev/null)

    print_success_message "Deleted $deleted backup file(s)"
    print_info_message "Your home directory is now clean of backup files"
}

verify_links() {
    print_line_break "Verifying Dotfile Symlinks"

    check_stow_installed

    print_info_message "Checking symlink status..."
    echo ""

    local total_files=0
    local linked_files=0
    local missing_files=0
    local regular_files=0

    # Check key dotfiles
    cd "$STOW_DIR/$STOW_PACKAGE" || exit 1

    while IFS= read -r -d '' source_file; do
        local rel_file="${source_file#./}"
        local target_file="$TARGET_DIR/$rel_file"
        ((total_files++))

        if [ -L "$target_file" ]; then
            # It's a symlink - check if it points to the right place
            local link_target
            link_target=$(readlink "$target_file")
            if [[ "$link_target" == *"dotfiles-mac-os/stow/dotfiles"* ]] || [[ "$link_target" == "$STOW_DIR/$STOW_PACKAGE/$rel_file" ]]; then
                echo "✓ $rel_file → symlinked correctly"
                ((linked_files++))
            else
                echo "⚠ $rel_file → symlinked to wrong location: $link_target"
            fi
        elif [ -e "$target_file" ]; then
            # File exists but is not a symlink
            echo "✗ $rel_file → exists as regular file (NOT symlinked)"
            ((regular_files++))
        else
            # File doesn't exist at all
            echo "✗ $rel_file → missing (not linked)"
            ((missing_files++))
        fi
    done < <(find . -type f -print0)

    cd - > /dev/null || exit 1

    echo ""
    print_line_break "Summary"
    echo "Total files in stow package: $total_files"
    echo "Correctly symlinked: $linked_files"
    echo "Regular files (not symlinked): $regular_files"
    echo "Missing: $missing_files"
    echo ""

    if [ "$linked_files" -eq "$total_files" ]; then
        print_success_message "All dotfiles are correctly symlinked!"
    else
        print_warning_message "Some files are not properly symlinked"
        print_info_message "Run: $0 fix"
    fi
}

show_usage() {
    cat << EOF
Usage: $0 <command>

Commands:
    fix             🔧 Auto-fix dotfile linking issues (RECOMMENDED)
    verify          Check symlink status
    link            Link all dotfiles using GNU Stow
    unlink          Remove all dotfile symlinks
    relink          Refresh symlinks (unlink + link)
    simulate        Dry-run to see what would be linked
    restore         Restore files from .backup.* files
    clean-backups   Delete all .backup.* files permanently
    help            Show this help message

Examples:
    $0 verify            # Check if symlinks are working correctly
    $0 fix               # Automatically fix any linking issues (start here!)
    $0 link              # Link dotfiles to home directory
    $0 simulate          # See what would happen (dry-run)
    $0 unlink            # Remove all symlinks
    $0 relink            # Refresh all symlinks
    $0 restore           # Restore from backups if linking failed
    $0 clean-backups     # Remove all backup files (after verifying dotfiles work)

Troubleshooting:
    If you see files instead of symlinks:
      → Run: $0 verify (to see what's wrong)
      → Run: $0 fix (to fix it)

    If stow reports conflicts:
      → Run: $0 fix

    If everything works and you want to clean up:
      → Run: $0 clean-backups (removes all .backup.* files)

Note: Existing files will be backed up automatically with .backup.TIMESTAMP suffix
EOF
}

# ------------------------------------------------------------------------------
# Main Script Logic
# ------------------------------------------------------------------------------

COMMAND="${1:-help}"

case "$COMMAND" in
    fix)
        fix_dotfiles
        ;;
    verify|check|status)
        verify_links
        ;;
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
    clean-backups|cleanup|clean)
        clean_backups
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
