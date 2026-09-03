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
# History expansions (!!, !$, !foo) land on the command line for review before
# running, instead of executing immediately -- a safety net against surprises.
shopt -s histverify

# Don't record noise commands. Space-prefixed and consecutive-duplicate
# filtering is already handled by HISTCONTROL above, so this only lists the
# specific commands not worth keeping.
HISTIGNORE="exit:ls:bg:fg:history:clear"

# TERMINAL/WINDOW BEHAVIOUR
# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Disable XON/XOFF flow control so Ctrl+S is freed for readline's
# forward-i-search (the partner to Ctrl+R's backward search), instead of
# freezing terminal output. Ctrl+Q is freed too. Nothing on a modern terminal
# relies on software flow control.
stty -ixon 2>/dev/null

# The pattern "**" in a pathname expansion context matches all files and zero
# or more directories and subdirectories (e.g. ls **/*.md).
shopt -s globstar

# FILE VIEWING
# Make less more friendly for non-text input files, see lesspipe(1)
# Debian ships the binary as `lesspipe`; Fedora/Arch ship it as `lesspipe.sh`.
if command -v lesspipe.sh >/dev/null 2>&1; then
    eval "$(SHELL=/bin/sh lesspipe.sh)"
elif command -v lesspipe >/dev/null 2>&1; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

# DEBIAN CHROOT DETECTION
# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Initialize exit-code state on startup, before the first prompt renders.
LAST_EXIT_CODE=0
EXIT_COLOR=$'\001\033[0;1;32m\002'   # bold green (success)

# OPTIMIZED: Simplified prompt function
# Store exit code and update history efficiently
set_prompt() {
    LAST_EXIT_CODE=$?
    # Colour the exit code and prompt marker green on success, red on failure.
    # Raw ESC bytes (not \033) with \001/\002 non-print markers, since PS1
    # decodes backslash escapes *before* it expands ${EXIT_COLOR}, so \033 here
    # would render literally. \001/\002 are what \[ \] decode to.
    if [ "$LAST_EXIT_CODE" -eq 0 ]; then
        EXIT_COLOR=$'\001\033[0;1;32m\002'   # bold green
    else
        EXIT_COLOR=$'\001\033[0;1;31m\002'   # bold red
    fi
    # -a flushes this session's new commands to the history file; -n then reads
    # in commands other open terminals have flushed, so history is shared live
    # across sessions without a jarring full reload.
    history -a
    history -n
}

# Set PROMPT_COMMAND to run our function before each prompt
PROMPT_COMMAND=set_prompt

# Prompt design: bold *foreground* colours on the terminal's own background,
# with no colour blocks. Blocks with black text turn illegible on a dimmed
# backlight; foreground text rides the full brightness range behind it and
# inherits foot's accessible 16-colour palette, so it stays readable in both
# the light and dark themes (Ctrl+Shift+t) and in any ambient light.
#
# Layout (two lines):
#   user@host:[cwd]
#   HH:MM:SS {exit} >          (exit + marker: green on success, red on error)
#
# id -u is checked once here, not per render.
if [ "$(id -u)" -eq 0 ]; then
    # Root: whole identity in bold red as a danger signal, marker is a red '#'.
    PS1='\[\e]0;\u@\h: \w\a\]\[\033[1;31m\]\u@\h\[\033[0m\]:\[\033[1;33m\][\w]\[\033[0m\]\n\[\033[1m\]\t\[\033[0m\] \[\033[2m\]{${EXIT_COLOR}${LAST_EXIT_CODE}\[\033[0;2m\]}\[\033[0m\] ${EXIT_COLOR}#\[\033[0m\] '
else
    # Per-host colour, hashed into the accessible ANSI foreground set (bold
    # 31-36 and bright 91-96) so it's distinct per host yet legible in both
    # themes. $HOSTNAME is a bash builtin, avoiding a fork of hostname(1).
    _hc=$(( $(printf '%s' "$HOSTNAME" | cksum | cut -d' ' -f1) % 12 ))
    if [ "$_hc" -lt 6 ]; then
        HOST_COLOR="1;3$((_hc + 1))"   # bold 31..36
    else
        HOST_COLOR="1;9$((_hc - 5))"   # bright 91..96
    fi
    unset _hc

    # user (bold green) @host (per-host colour) :[cwd] (bold cyan)
    PS1='\[\e]0;\u@\h: \w\a\]\[\033[1;32m\]\u\[\033[0m\]\[\033['"${HOST_COLOR}"'m\]@\h\[\033[0m\]:\[\033[1;36m\][\w]\[\033[0m\]\n\[\033[1m\]\t\[\033[0m\] \[\033[2m\]{${EXIT_COLOR}${LAST_EXIT_CODE}\[\033[0;2m\]}\[\033[0m\] ${EXIT_COLOR}>\[\033[0m\] '
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
if [ -d "$HOME/.acme.sh" ]; then
    . "$HOME/.acme.sh/acme.sh.env"
fi

# Aliases live in ~/.bash_aliases (sourced above), not here.

# Make CD show different options for when you have a spelling mistake
shopt -s cdspell 2> /dev/null
shopt -s dirspell 2> /dev/null
shopt -s autocd 2> /dev/null

# Refuse to clobber an existing file with > (use >| to force the overwrite).
set -o noclobber

# Editor and collation settings
export EDITOR=vim
export LC_COLLATE=C
export VISUAL=vim

# Cache dircolors output so dircolors is forked once (to build the cache), then
# cheaply sourced on every later shell startup. Delete the cache file to force a
# regenerate. This is the single owner of LS_COLORS; the ls/grep colour aliases
# live in .bash_aliases.
DIRCOLORS_CACHE=~/.cache/dircolors
if [ ! -f "$DIRCOLORS_CACHE" ]; then
    mkdir -p ~/.cache
    dircolors -b > "$DIRCOLORS_CACHE" 2>/dev/null
fi
[ -f "$DIRCOLORS_CACHE" ] && . "$DIRCOLORS_CACHE"

# Man pages: recolour groff's SGR output on the way to the pager.
#
# groff 1.23 emits real SGR escapes (ESC[1m bold, ESC[4m underline) instead of
# the old overstrike encoding (char, BS, char). The LESS_TERMCAP_md/us settings
# below only fire when less has to *translate* overstrike into terminal codes,
# so under this groff they never run and man pages render in plain bold and
# underline with no colour at all.
#
# The usual fix is GROFF_NO_SGR=1, which forces groff back to overstrike and
# does work -- but it also drops the OSC-8 hyperlinks groff embeds in man pages
# (verified: 60 links to 0), and foot renders those, see osc8-underline in
# foot.ini. So rewrite the SGR codes instead: hyperlinks pass through untouched
# and the colours stay ANSI *indices*, so they still inherit the Modus palette
# and follow the Ctrl+Shift+t toggle.
#
# \x1b in a pattern is a GNU sed extension, so this is guarded; on BSD/macOS
# sed it falls back to an uncoloured pager rather than a broken one.
if printf 'x' | sed -E 's/\x78/y/' 2>/dev/null | grep -q y; then
    export MANPAGER="sh -c 'sed -E \"s/\x1b\[1m/\x1b[1;32m/g; s/\x1b\[4m/\x1b[4;34m/g\" | less -R'"
else
    export MANPAGER="less -R"
fi

# Render ANSI colour instead of printing it as literal escape codes. Needed
# whenever colour is piped into less, e.g. `ls -lah --color=always | less` or
# `grep --color=always ... | less` -- note the `always`, since the --color=auto
# in .bash_aliases correctly strips colour as soon as stdout isn't a terminal.
#
# -R (not -r): -R passes only colour escapes through and keeps less's idea of
# the line width correct, whereas -r passes every control character raw and can
# corrupt the display on binary-ish input. MANPAGER above already spells out
# `less -R` for itself, so it doesn't depend on this.
export LESS=-R

# less's own rendering. LESS_TERMCAP_so is still live regardless of the above:
# less uses the standout capability for its status line and for search-match
# highlighting, independent of what the input looks like. md/us apply to any
# overstrike-encoded input less is given (man is no longer such a source).
# These use ANSI *indices* only, never hardcoded RGB, so
# they inherit foot's Modus palette and follow the Ctrl+Shift+t theme toggle.
#
# Standout (search matches and the prompt line) uses reverse video rather than
# a colour pair. The old value here was `103;30` -- black on bright yellow --
# which assumed bright yellow is a light colour. Under any AAA palette it
# isn't: bright yellow has to be dark enough to clear 7:1 on a light
# background, so black-on-it measured 1.61:1 and search hits were effectively
# invisible in light mode. Reverse video swaps the terminal's own foreground
# and background, so it is always at maximum contrast in both themes -- the
# same trick tmux's status bar uses.
export LESS_TERMCAP_mb=$'\e[1;31m'     # start blink      -> bold red
export LESS_TERMCAP_md=$'\e[1;32m'     # start bold       -> bold green
export LESS_TERMCAP_me=$'\e[0m'        # turn off bold, blink and underline
export LESS_TERMCAP_so=$'\e[7m'        # start standout   -> reverse video
export LESS_TERMCAP_se=$'\e[27m'       # stop standout    -> reverse off
export LESS_TERMCAP_us=$'\e[4;34m'     # start underline  -> underlined blue
export LESS_TERMCAP_ue=$'\e[24m'       # stop underline   -> underline off

# Only prepend host-specific dirs to PATH if they exist and aren't already present,
# so PATH doesn't grow with each new non-login shell that inherits an already-populated PATH.
# Prepended (rather than appended) so these user-installed binaries take priority over system ones.
for dir in "$HOME/.spicetify" "$HOME/.local/bin"; do
    if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
        PATH="$dir:$PATH"
    fi
done
export PATH

# SSH agent for Ansible work: load the android16 key via keychain. Guarded on
# both keychain being installed and the key existing, so shells on hosts that
# have neither stay error-free. keychain reuses a running agent, so re-running
# this per shell is cheap.
if command -v keychain >/dev/null 2>&1 && [ -f ~/.ssh/android16 ]; then
    eval "$(keychain --eval --quiet ~/.ssh/android16)"
fi
