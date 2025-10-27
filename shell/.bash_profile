# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs

# Add ~/.local/bin to PATH if it exists and isn't already included              
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then 
    PATH="$HOME/.local/bin:$PATH"                                               
 fi
export PATH
