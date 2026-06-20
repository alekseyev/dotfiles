#!/bin/sh
# --no-folding: create real dirs and symlink individual files, never symlink a
# whole directory. Prevents stow from folding e.g. ~/.config/fish into a single
# symlink (which would let apps write generated files into the repo).
stow -v --no-folding -t ~ claude git fish kitty starship zsh

# scripts is fine to fold (whole directory symlinked as one).
stow -v -t ~ scripts
