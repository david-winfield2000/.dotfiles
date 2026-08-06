# Use vim mode for terminal
bindkey -v
KEYTIMEOUT=1

# Use same aliases as bash
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
# Reload should refresh zsh config, not bash
alias reload="source ~/.zshrc"

venv() {
    if [ ! -d "venv" ]; then
        python -m venv venv
        source venv/bin/activate
        [ -f "requirements.txt" ] && pip install -r requirements.txt
    else
        source venv/bin/activate
    fi
}

revenv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
    fi
    if [ -d "venv" ]; then
        rm -rf venv
    fi
    venv force
}

# Yazi wrapper to change directory after running yazi
eval "$(zoxide init zsh)"
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
export EDITOR="nvim"
export PATH=$PATH:$(go env GOPATH)/bin
