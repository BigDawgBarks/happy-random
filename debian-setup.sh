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

# Install simonw/llm
sudo apt install pipx
pipx install llm
pipx ensurepath
exec bash
llm install llm-claude-3
. ~/.bashrc
llm keys set openai
llm keys set claude

# Install neovim and vim-plug
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim
sudo apt install luarocks
mkdir -p ~/.config/nvim
curl -L https://api.github.com/repos/mywang-berk/happy-random/tarball/master \
	| tar xz --strip-components=DEPTH -C ~/.config/nvim --wildcards "*/nvim/*"
# CR-someday mywang: expand this to handle setting up tmux.conf
# Set up tmux-plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# set tmux settings
echo >~/.tmux.conf <<EOF
# Set vi-style key bindings for copy mode
set-window-option -g mode-keys vi

# Enable vi-style navigation in the status line
set -g status-keys vi
EOF

exit 0;
}
