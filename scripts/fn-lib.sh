#!/usr/bin/env bash
# --------------------------
# fn-lib.sh - A library of reusable bash functions for macOS setup scripts
# --------------------------

print_tool_setup_start() {
  local tool_name="$1"
  print_line_break "Starting setup for $tool_name"
}

print_tool_setup_complete() {
  local tool_name="$1"
  print_line_break "Completed setup for $tool_name"
}

# Function to print a green line break with an optional title
print_line_break() {
  local title="$1"
  echo -e "\033[32m--------------------------------------------------\033[0m"
  if [ -n "$title" ]; then
    # get the current time and date and print it along with the title
    local datetime
    datetime=$(date '+%Y-%m-%d %H:%M:%S.%N')
    echo -e "\033[32m$title | $datetime\033[0m"
    echo -e "\033[32m--------------------------------------------------\033[0m"
  fi
}

# Function to print an info message in blue
print_info_message() {
  local message="$1"
  echo -e "\033[34m$message\033[0m"
}

# Function to print an action message in orange
print_action_message() {
  local message="$1"
  echo -e "\033[38;5;208m$message\033[0m"
}

print_success_message() {
  local message="$1"
  echo -e "\033[32m$message\033[0m"
}

# Function to print a warning message in yellow
print_warning_message() {
  local message="$1"
  echo -e "\033[33m$message\033[0m"
}

# Function to print an error message in red
print_error_message() {
  local message="$1"
  echo -e "\033[31m$message\033[0m"
}
