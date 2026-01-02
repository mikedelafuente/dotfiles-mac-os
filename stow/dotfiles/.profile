# ~/.profile: executed by the command interpreter for login shells.
# Works with both bash and zsh.

# Set the default umask for file creation permissions
#umask 022

# If running zsh, include .zshrc if it exists
if [ -n "$ZSH_VERSION" ] && [ -f "$HOME/.zshrc" ]; then
    . "$HOME/.zshrc"
fi

# If running bash, include .bashrc if it exists
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# Add user binary directories to PATH if they exist
for dir in "$HOME/bin" "$HOME/.local/bin"; do
    if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
        export PATH="$dir:$PATH"
    fi
done
