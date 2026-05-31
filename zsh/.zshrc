# 🚀
eval "$(starship init zsh)"

# PATH
export PATH="$PATH:$HOME/bin:$HOME/.local/bin:/usr/games/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin/vendor_perl:/usr/bin/core_perl"
export PATH="/usr/local/opt/openjdk/bin:$PATH"

case "$OSTYPE" in
  darwin*)
    export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
    export PATH=$PATH:"/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    ;;
  linux*)
    ;;
esac

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
