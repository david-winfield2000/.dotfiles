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

# Nvm setup
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  

# Yazi wrapper to change directory after running yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
export EDITOR="nvim"
export PATH=$PATH:$(go env GOPATH)/bin
eval "$(zoxide init zsh)"

# Use vim mode for terminal
bindkey -v

function zle-keymap-select zle-line-init {
  case $KEYMAP in
    vicmd) echo -ne '\e[2 q';;      # block cursor for normal mode
    *) echo -ne '\e[6 q';;          # bar cursor for insert mode
  esac
}

zle -N zle-keymap-select
zle -N zle-line-init
echo -ne '\e[6 q'  # start with bar cursor
