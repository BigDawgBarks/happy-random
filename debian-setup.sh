#!/bin/bash

set -eou pipefail

# Some basic setup (installing tools, etc.) I like to do in every debian-derivative environment I work in.
{
sudo apt update;
sudo apt install ripgrep; # rg > grep

# Install ctrl+R fzf over bash history. Very important to productivity; annoying to work without it.
sudo apt install silversearcher-ag
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

exit 0;
}
