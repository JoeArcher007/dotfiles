# --- Color support for ls and grep (cross-platform safe) ---

# GNU/Linux check: dircolors + GNU ls with --color
if command -v dircolors >/dev/null 2>&1 && ls --color=auto >/dev/null 2>&1 2>/dev/null; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

# macOS / BSD fallback: use ls -G if available
elif ls -G >/dev/null 2>&1; then
    alias ls='ls -G'
    # grep on BSD/macOS may or may not support --color, so test it
    if grep --color=auto "" >/dev/null 2>&1; then
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
fi

# --- Optional: small enhancements ---
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias ed='ed -p"^ED^ > "'
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

