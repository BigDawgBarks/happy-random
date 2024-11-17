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
llm install llm-claude-3
echo <<'EOF' >> ~/.bashrc
export PATH=$PATH:/home/mywang/.local/bin'
SYSTEM_PROMPT="Speak in specific, topic-relevant terminology. Do NOT hedge or qualify. Do not waffle. Speak directly and be willing to make guesses. Explain your reasoning. Be willing to reference less reputable sources for ideas. Be willing to form opinions on things. Avoid unnecessary verbosity."
alias llm4="llm --model gpt4 --system '$SYSTEM_PROMPT'"
alias llmt="llm --model gpt-4-turbo --system '$SYSTEM_PROMPT'"
alias llmc="llm chat --model gpt4 --system '$SYSTEM_PROMPT'"
alias llmct="llm chat --model gpt-4-turbo --system '$SYSTEM_PROMPT'"
alias clx="llm chat --model claude-3.5-sonnet"
alias llmx="llm --model claude-3.5-sonnet"
EOF
. ~/.bashrc
llm keys set openai
llm keys set claude

# Install neovim and vim-plug
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim
sudo apt install luarocks
mkdir -p ~/.config/nvim
sh -c 'curl -fLo ~/.config/nvim/init.vim --create-dirs \
   https://raw.githubusercontent.com/mywang-berk/happy-random/master/vimrc'
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# CR-soon mywang: delete the bashrc bits and move those to bashrc
# CR-someday mywang: add steps for installing firacode and setting up vim kickstart

# CR-someday mywang: expand this to handle setting up tmux.conf
# Set up tmux-plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

exit 0;
}
