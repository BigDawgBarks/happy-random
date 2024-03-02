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
sudo apt install python3-pip
pip install llm
echo <<'EOF' >> ~/.bashrc
export PATH=$PATH:/home/mywang/.local/bin'
SYSTEM_PROMPT="Speak in specific, topic-relevant terminology. Do NOT hedge or qualify. Do not waffle. Speak directly and be willing to make guesses. Explain your reasoning. Be willing to reference less reputable sources for ideas. Be willing to form opinions on things. Avoid unnecessary verbosity."
alias llm4="llm --model gpt4 --system '$SYSTEM_PROMPT'"
alias llmt="llm --model gpt-4-turbo --system '$SYSTEM_PROMPT'"
alias llmc="llm chat --model gpt4 --system '$SYSTEM_PROMPT'"
alias llmct="llm chat --model gpt-4-turbo --system '$SYSTEM_PROMPT'"
EOF
. ~/.bashrc
llm keys set openai

exit 0;
}
