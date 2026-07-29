# Environment
set -gx VISUAL vim
set -gx EDITOR vim
set -gx GIT_EDITOR vim
set -gx PYENV_ROOT $HOME/.pyenv

# /opt/homebrew on Apple Silicon, /usr/local on Intel and under Rosetta,
# /home/linuxbrew on Linux. Sets HOMEBREW_PREFIX, used below.
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
    if test -x $brew
        $brew shellenv fish | source
        break
    end
end
set -e brew

# Prepended in the order given, so earlier entries win. Missing directories are
# skipped, and the $HOMEBREW_PREFIX entries expand to nothing where brew isn't
# installed. Keg-only formulae aren't linked into $HOMEBREW_PREFIX/bin, so
# libpq, openjdk and gnu-sed have to be named here.
fish_add_path $HOME/bin $HOME/.local/bin /usr/games/bin \
    $PYENV_ROOT/bin $PYENV_ROOT/shims \
    $HOMEBREW_PREFIX/opt/libpq/bin \
    $HOMEBREW_PREFIX/opt/openjdk/bin \
    $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin \
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Appended so they rank below the additions above.
fish_add_path -a /usr/local/bin /usr/local/sbin

# Interactive-only setup
if status is-interactive
    # direnv
    if type -q direnv
        direnv hook fish | source
    end

    # Aliases (gecho/cecho live in functions/ as autoloaded functions)
    alias tm 'tmux new-session -t main; or tmux new-session -s main'
    alias glog 'git --no-pager log --color=always -20 --format="%C(yellow)%h%Creset  %s %Cgreen(%cr) %C(bold blue)<%an>%Creset"'

    switch (uname)
        case Darwin
            if type -q gls
                alias ls 'gls --hyperlink=auto --color=auto'
                alias ll 'gls -lh --hyperlink=auto --color=auto'
                alias la 'gls -lAh --hyperlink=auto --color=auto'
            else
                alias ls 'ls -G'
                alias ll 'ls -lhG'
                alias la 'ls -lAhG'
            end
        case Linux
            alias ls 'ls --hyperlink=auto --color=auto'
            alias ll 'ls -lh --hyperlink=auto --color=auto'
            alias la 'ls -lAh --hyperlink=auto --color=auto'
    end

    # Local machine-specific overrides
    test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish

    # Prompt
    starship init fish | source
end
