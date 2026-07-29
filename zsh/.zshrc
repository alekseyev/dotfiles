# Use fish for interactive sessions while keeping zsh as the POSIX login shell.
# (chsh stays pointed at zsh, which always exists, so we never risk a broken
# login shell if the fish binary's path goes away — e.g. Intel brew/Rosetta.)
# Escape hatch: `NO_FISH=1 zsh` gives a plain zsh session. Launching zsh from
# within fish also stays in zsh, since NO_FISH is exported below.
# `-t 1` keeps the handoff away from programmatic shells: VS Code and similar
# tools resolve the environment by running `zsh -ic` with output piped, and
# exec'ing fish there hands them back an empty env instead of PATH.
if [[ -o interactive && -t 1 && -z "$NO_FISH" && -z "$INSIDE_EMACS" ]] && command -v fish >/dev/null 2>&1; then
  export NO_FISH=1
  exec fish
fi

# 🚀
eval "$(starship init zsh)"

# Aliases
alias gecho='echo -e "\033[01;32m"'
alias tm='tmux new-session -t main || tmux new-session -s main'
alias glog='git --no-pager log --color=always -20 --format="%C(yellow)%h%Creset  %s %Cgreen(%cr) %C(bold blue)<%an>%Creset"'

case "$OSTYPE" in
  darwin*)
    if command -v gls >/dev/null 2>&1; then
      alias ls='gls --hyperlink=auto --color=auto'
      alias ll='gls -lh --hyperlink=auto --color=auto'
      alias la='gls -lAh --hyperlink=auto --color=auto'
    else
      alias ls='ls -G'
      alias ll='ls -lhG'
      alias la='ls -lAhG'
    fi
    ;;
  linux*)
    alias ls='ls --hyperlink=auto --color=auto'
    alias ll='ls -lh --hyperlink=auto --color=auto'
    alias la='ls -lAh --hyperlink=auto --color=auto'
    ;;
esac

# ***
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt autocd
autoload -Uz compinit
compinit

eval "$(direnv hook zsh)"

[[ ! -f ~/.zshlocalrc ]] || source ~/.zshlocalrc
