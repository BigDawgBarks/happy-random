#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -eou pipefail

{
# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt user for a section
prompt_section() {
    local section_name="$1"
    read -p "Install/configure $section_name? (y/n): " choice
    case "$choice" in
        y|Y ) return 0 ;;
        * ) return 1 ;;
    esac
}

echo "System setup script - configures a Debian-like environment"
echo "--------------------------------------------------------"

# Section 1: Basic system setup
if prompt_section "basic system tools"; then
    echo "Updating package repositories..."
    sudo apt update

    # Install software-properties-common if not already installed
    if ! command_exists add-apt-repository; then
        echo "Installing software-properties-common..."
        sudo apt install -y software-properties-common
    fi
fi

# Section 2: Developer tools
if prompt_section "developer tools (ripgrep, fzf, silversearcher-ag)"; then
    # Install ripgrep if not already installed
    if ! command_exists rg; then
        echo "Installing ripgrep..."
        sudo apt install -y ripgrep
    else
        echo "ripgrep already installed, skipping..."
    fi

    # Install silversearcher-ag if not already installed
    if ! command_exists ag; then
        echo "Installing silversearcher-ag..."
        sudo apt install -y silversearcher-ag
    else
        echo "silversearcher-ag already installed, skipping..."
    fi

    # Install fzf if not already installed
    if [ ! -d "$HOME/.fzf" ]; then
        echo "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all --no-update-rc
    else
        echo "fzf directory already exists, skipping installation..."
    fi
fi

# Section 3: AI tools setup
if prompt_section "AI tools (llm CLI with Claude and OpenAI support)"; then
    # Install pipx if not already installed
    if ! command_exists pipx; then
        echo "Installing pipx..."
        sudo apt install -y pipx
        pipx ensurepath
        
        # Source updated PATH if possible
        if [ -f "$HOME/.bashrc" ]; then
            # shellcheck disable=SC1090
            source "$HOME/.bashrc"
        fi
        echo "Note: You may need to restart your shell for the updated PATH to take effect."
    else
        echo "pipx already installed, skipping..."
    fi

    # Install llm if not already installed
    if ! command_exists llm; then
        echo "Installing llm..."
        pipx install llm
        
        # Add Claude support
        echo "Installing llm-claude-3 plugin..."
        pipx inject llm llm-claude-3 || true
    else
        echo "llm already installed, skipping..."
    fi

    # Set up API keys
    echo "Setting up API keys for LLM services..."
    read -p "Enter OpenAI API key (or press Enter to skip): " openai_key
    if [ -n "$openai_key" ]; then
        llm keys set openai "$openai_key"
    fi

    read -p "Enter Claude API key (or press Enter to skip): " claude_key
    if [ -n "$claude_key" ]; then
        llm keys set claude "$claude_key"
    fi
fi

# Section 4: Editor setup
if prompt_section "editor setup (Neovim with configurations)"; then
    # Add neovim repository if not already added
    if ! grep -q "neovim-ppa/unstable" /etc/apt/sources.list.d/* 2>/dev/null; then
        echo "Adding Neovim unstable PPA..."
        sudo add-apt-repository -y ppa:neovim-ppa/unstable
        sudo apt update
    else
        echo "Neovim PPA already added, skipping..."
    fi

    # Install neovim if not already installed
    if ! command_exists nvim; then
        echo "Installing Neovim..."
        sudo apt install -y neovim
    else
        echo "Neovim already installed, skipping..."
    fi

    # Install luarocks if not already installed
    if ! command_exists luarocks; then
        echo "Installing luarocks..."
        sudo apt install -y luarocks
    else
        echo "luarocks already installed, skipping..."
    fi

    # Set up neovim config if not already set up
    mkdir -p "$HOME/.config/nvim"
    if [ ! -f "$HOME/.config/nvim/init.lua" ] && [ ! -f "$HOME/.config/nvim/init.vim" ]; then
        echo "Setting up Neovim configuration..."
        curl -L https://api.github.com/repos/mywang-berk/happy-random/tarball/master \
            | tar xz --strip-components=1 -C "$HOME/.config/nvim" --wildcards "*/nvim/*"
    else
        echo "Neovim configuration already exists, skipping..."
    fi
fi

# Section 5: Terminal enhancements
if prompt_section "terminal enhancements (tmux with plugins)"; then
    # Install tmux if not already installed
    if ! command_exists tmux; then
        echo "Installing tmux..."
        sudo apt install -y tmux
    else
        echo "tmux already installed, skipping..."
    fi

    # Install tmux plugin manager if not already installed
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo "Installing tmux plugin manager..."
        mkdir -p "$HOME/.tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        echo "tmux plugin manager already installed, skipping..."
    fi

    # Set up tmux configuration if it doesn't exist or doesn't have our settings
    if [ ! -f "$HOME/.tmux.conf" ] || ! grep -q "mode-keys vi" "$HOME/.tmux.conf"; then
        echo "Setting up tmux configuration..."
        cat > "$HOME/.tmux.conf" << 'EOF'
# Set vi-style key bindings for copy mode
set-window-option -g mode-keys vi

# Enable vi-style navigation in the status line
set -g status-keys vi

# Initialize tmux plugin manager (keep this at the bottom)
run '~/.tmux/plugins/tpm/tpm'
EOF
        echo "tmux configuration created."
    else
        echo "tmux configuration already exists, skipping..."
    fi
fi

echo ""
echo "Setup complete! You may need to restart your shell for some changes to take effect."
echo "To apply all changes now, run: source ~/.bashrc"
echo "For the best experience, consider starting a new terminal session."
}
