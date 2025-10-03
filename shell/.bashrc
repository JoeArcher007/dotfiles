# ~/.bashrc: executed by bash(1) for non-login shells.
# Modified by: Joe Archer

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Ghostty shell integration for Bash. This must be at the top of your bashrc!
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

# HISTORY
# Don't record duplicate commands, and ignore commands starting with a space or
# duplicates of the last command.
HISTCONTROL="erasedupes:ignoreboth"

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# Keep 50k commands in memory
HISTSIZE=50000
# Keep 500k commands on disk
HISTFILESIZE=500000

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT='%F %T '

# Append to the history file, don't overwrite it
shopt -s histappend
# Save multi-line commands as one command
shopt -s cmdhist

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

# TERMINAL/WINDOW BEHAVIOUR
# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# FILE VIEWING
# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# DEBIAN CHROOT DETECTION
# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Initialize LAST_EXIT_CODE to 0 on startup
LAST_EXIT_CODE=0

# OPTIMIZED: Simplified prompt function
# Store exit code and update history efficiently
set_prompt() {
    LAST_EXIT_CODE=$?
    history -a
}

# Set PROMPT_COMMAND to run our function before each prompt
PROMPT_COMMAND=set_prompt

# OPTIMIZED: Skip color capability check - modern terminals support color
# This eliminates unnecessary tput calls on every shell startup
color_prompt=yes

# OPTIMIZED: Pre-compute prompt colors based on user ID at startup
# This avoids checking $(id -u) on every prompt render
# For regular users, generate a unique color for hostname based on hash
if [ "$(id -u)" -eq 0 ]; then
    # Root user prompt with dark red background for username@hostname and cyan background for :[cwd]
    PS1='\[\e]0;\u@\h: \w\a\]\[\033[41;38;5;208m\]\u@\h\[\033[0m\]\[\033[46;30m\]:[\w]\[\033[0m\]\n$(if [ "${LAST_EXIT_CODE:-0}" -eq 0 ]; then printf "\[\033[42;30m\]%s {%d} >\[\033[0m\] " "\t" "${LAST_EXIT_CODE}"; else printf "\[\033[41;30m\]%s {%d} >\[\033[0m\] " "\t" "${LAST_EXIT_CODE}"; fi)'
else
    # Generate a color code (16-231 range for 256 colors, avoiding black/white/bright)
    # Use hostname hash to get consistent color per host
    HOSTNAME_COLOR=$(( ($(hostname | cksum | cut -d' ' -f1) % 180) + 52 ))
    
    # Regular user prompt with purple background for username and hostname-based color for @hostname
    PS1='\[\e]0;\u@\h: \w\a\]\[\033[45;30m\]\u\[\033[0m\]\[\033[48;5;'"${HOSTNAME_COLOR}"';30m\]@\h\[\033[0m\]\[\033[46;30m\]:[\w]\[\033[0m\]\n$(if [ "${LAST_EXIT_CODE:-0}" -eq 0 ]; then printf "\[\033[42;30m\]%s {%d} >\[\033[0m\] " "\t" "${LAST_EXIT_CODE}"; else printf "\[\033[41;30m\]%s {%d} >\[\033[0m\] " "\t" "${LAST_EXIT_CODE}"; fi)'
fi

# OPTIMIZED: Removed redundant color_prompt checks and xterm title setting
# (now integrated directly into PS1 above)

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# OPTIMIZED: Lazy-load bash aliases only if file exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# OPTIMIZED: Lazy-load acme.sh only if directory exists
if [ -d /home/joe/.acme.sh ]; then
    . "/home/joe/.acme.sh/acme.sh.env"
fi

# Aliases
alias ed='ed -p"^ED^ > "'
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

# Make CD show different options for when you have a spelling mistake
shopt -s cdspell 2> /dev/null
shopt -s dirspell 2> /dev/null
shopt -s autocd 2> /dev/null

# Editor and collation settings
export EDITOR=vim
export LC_COLLATE=C
export VISUAL=vim

# OPTIMIZED: Cache dircolors output to avoid running it on every shell startup
# Only regenerate if .dircolors is newer than cached version
DIRCOLORS_CACHE=~/.cache/dircolors
if [ ! -f "$DIRCOLORS_CACHE" ] || [ ~/.dircolors -nt "$DIRCOLORS_CACHE" ] 2>/dev/null; then
    mkdir -p ~/.cache
    dircolors -b > "$DIRCOLORS_CACHE" 2>/dev/null
fi
[ -f "$DIRCOLORS_CACHE" ] && . "$DIRCOLORS_CACHE"
