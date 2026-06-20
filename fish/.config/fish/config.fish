# Environment
set -gx VISUAL vim
set -gx EDITOR vim
set -gx GIT_EDITOR vim
set -gx PYENV_ROOT $HOME/.pyenv

# PATH
fish_add_path $HOME/bin $HOME/.local/bin /usr/games/bin
fish_add_path $PYENV_ROOT/bin $PYENV_ROOT/shims
fish_add_path /usr/local/opt/openjdk/bin

switch (uname)
    case Darwin
        if type -q brew
            fish_add_path (brew --prefix)/opt/gnu-sed/libexec/gnubin
        end
        fish_add_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
end

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
