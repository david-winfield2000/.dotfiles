# Navigation
alias ..="cd .."
alias ~="cd ~"

# Git
alias lg="lazygit"

# Python
alias python="python3"

# Misc
alias c="clear"
alias h="history"
alias reload="source ~/.bashrc"

# Tmux
alias t="tmux"
alias ta="tmux a"
alias tk="tmux kill-session -t"

# Claude
alias cc="claude"

tn() {
    tmux new -s "${1:-$(basename "$PWD")}"
}

# Yazi wrapper to change directory after running yazi
y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
}
