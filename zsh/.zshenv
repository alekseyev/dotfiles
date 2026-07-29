typeset -U path

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

path=($HOME/bin $HOME/.local/bin /usr/games/bin $HOME/.pyenv/bin $HOME/.pyenv/shims $path)
WORDCHARS=''
VISUAL=vim
EDITOR=vim
GIT_EDITOR=vim
# SSH_KEY=`cat ${HOME}/.ssh/id_rsa | base64 -w 0`
PYENV_ROOT="$HOME/.pyenv"
