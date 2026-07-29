typeset -U path

# /opt/homebrew on Apple Silicon, /usr/local on Intel and under Rosetta,
# /home/linuxbrew on Linux. shellenv sets HOMEBREW_PREFIX, used below.
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x $brew ]] && eval "$($brew shellenv)" && break
done
unset brew

# Assign the array, never `export PATH=...`: typeset -U only dedupes assignments
# to `path`, so the string form quietly accumulates duplicates.
path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.pyenv/bin
  $HOME/.pyenv/shims
  $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
  $HOMEBREW_PREFIX/opt/openjdk/bin
  $path
  /usr/local/bin
  /usr/local/sbin
  /usr/games/bin
  /usr/bin/vendor_perl
  /usr/bin/core_perl
  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
)

# Drop whatever this machine doesn't have — the perl dirs on macOS, the VS Code
# bundle on Linux, all of Homebrew where it isn't installed.
path=(${^path}(N-/))

WORDCHARS=''
VISUAL=vim
EDITOR=vim
GIT_EDITOR=vim
# SSH_KEY=`cat ${HOME}/.ssh/id_rsa | base64 -w 0`
PYENV_ROOT="$HOME/.pyenv"
