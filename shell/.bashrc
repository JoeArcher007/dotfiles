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

# PROMPT COLOURS / PROMPT OPTIONS
# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

# Function to handle prompt setup
set_prompt() {
    local exit_status=$?

    # Update terminal title and history
    case "$TERM" in
        xterm*|rxvt*)
            # Update terminal title: "user@host: cwd"
            echo -ne "\033]0;${USER}@${HOSTNAME%%.*}: ${PWD}\007"
            ;;
    esac

    # Record each line as it gets issued
    history -a
    history -n

    # Store exit status for use in prompt (ensure it's always set)
    LAST_EXIT_CODE=$exit_status
}

# Initialize LAST_EXIT_CODE to 0 on startup
LAST_EXIT_CODE=0

# Set PROMPT_COMMAND to run our function before each prompt
PROMPT_COMMAND=set_prompt

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# The below will change the prompt colours. If it's root user, change to ALL
# red. If it's a regular user, change to purple/cyan with colored backgrounds. 
# Otherwise, just go to a fallback non-coloured prompt.
if [ "$color_prompt" = yes ]; then
    if [ $(id -u) -eq 0 ]; then
        # Root user prompt with dark red background for username@hostname and cyan background for :[cwd]
        # Second line shows time with green/red background based on exit status
        PS1='\n\[\033[41;38;5;208m\]\u@\h\[\033[0m\]\[\033[46;30m\]:[\w]\[\033[0m\]\n$(if [ "${LAST_EXIT_CODE:-0}" -eq 0 ]; then printf "\[\033[42;30m\]%s {%d} >\[\033[0m\] " "$(date +%H:%M:%S)" "${LAST_EXIT_CODE}"; else printf "\[\033[41;30m\]%s {%d} >\[\033[0m\] " "$(date +%H:%M:%S)" "${LAST_EXIT_CODE}"; fi)'
    else
        # Regular user prompt with purple background for username@hostname and cyan background for :[cwd]
        # Second line shows time with green/red background based on exit status
        PS1='\n\[\033[45;30m\]\u@\h\[\033[0m\]\[\033[46;30m\]:[\w]\[\033[0m\]\n$(if [ "${LAST_EXIT_CODE:-0}" -eq 0 ]; then printf "\[\033[42;30m\]%s {%d} >\[\033[0m\] " "$(date +%H:%M:%S)" "${LAST_EXIT_CODE}"; else printf "\[\033[41;30m\]%s {%d} >\[\033[0m\] " "$(date +%H:%M:%S)" "${LAST_EXIT_CODE}"; fi)'
    fi
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -d /home/joe/.acme.sh ]; then
. "/home/joe/.acme.sh/acme.sh.env"
fi

alias ed='ed -p"^ED^ > "'

# Alias to find external IP anywhere
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

# Make CD show differnt options for when you have a spelling mistage
shopt -s cdspell 2> /dev/null
shopt -s dirspell 2> /dev/null
shopt -s autocd 2> /dev/null
export EDITOR=vim

# The below is to sort the files in cap's first, and then not caps second.
# Easier to read and sort through IMO
export LC_COLLATE=C
eval "$(dircolors -b)"
