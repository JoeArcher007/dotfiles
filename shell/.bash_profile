# ~/.bash_profile: executed by bash(1) for login shells.
# Modified by: Joe Archer

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Rust/cargo binaries (rustup was installed with --no-modify-path, so we add
# this ourselves). Covers harper-ls and any future `cargo install` tools.
if [ -d "$HOME/.cargo/bin" ] && [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi
