#!/usr/bin/env bash

# Installation script for Developer Terminal tools on Arch Linux
# This script installs all tools from the Dockerfile

set -euo pipefail

echo "=================================="
echo "Developer Terminal Arch Linux Setup"
echo "=================================="
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "⚠️  This script should not be run as root. Please run as a regular user (sudo will be used when needed)."
   exit 1
fi

# Function to print status messages
print_status() {
    echo "➜ $1"
}

print_success() {
    echo "✓ $1"
}

# Update package lists
print_status "Updating package database..."
sudo pacman -Sy --noconfirm

# Install base utilities
print_status "Installing base utilities..."
sudo pacman -S --needed --noconfirm \
    ca-certificates curl git base-devel \
    nano vim neovim wget htop fzf tree jq \
    python python-pip python-docker \
    unzip fontconfig ripgrep zsh fish direnv entr \
    rsync rclone glances iotop iftop bmon ncdu \
    mediainfo p7zip pass httpie tldr pgcli bat nmap tmux

print_success "Base utilities installed"

# Install docker if not already installed
if ! command -v docker &> /dev/null; then
    print_status "Installing Docker..."
    sudo pacman -S --needed --noconfirm docker docker-compose
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker "$USER"
    print_success "Docker installed (you may need to log out and back in for group changes to take effect)"
else
    print_success "Docker already installed"
fi

# Install GitHub CLI
if ! command -v gh &> /dev/null; then
    print_status "Installing GitHub CLI..."
    sudo pacman -S --needed --noconfirm github-cli
    print_success "GitHub CLI installed"
else
    print_success "GitHub CLI already installed"
fi

# Install Rust and Cargo
if ! command -v cargo &> /dev/null; then
    print_status "Installing Rust..."
    sudo pacman -S --needed --noconfirm rust cargo
    print_success "Rust installed"
else
    print_success "Rust already installed"
fi

# Install Rust tools
print_status "Installing Rust tools (this may take a while)..."
cargo install zoxide fd-find tealdeer du-dust eza duf bottom
print_success "Rust tools installed"

# Install Node.js if not already installed
if ! command -v node &> /dev/null; then
    print_status "Installing Node.js..."
    sudo pacman -S --needed --noconfirm nodejs npm
    print_success "Node.js installed"
else
    print_success "Node.js already installed"
fi

# Install Node.js tools
print_status "Installing Node.js tools..."
sudo npm install -g \
    @google/gemini-cli \
    @githubnext/github-copilot-cli \
    @anthropic-ai/claude-code \
    opencode-ai
print_success "Node.js tools installed"

# Install lazygit
if ! command -v lazygit &> /dev/null; then
    print_status "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit.tar.gz /tmp/lazygit
    print_success "lazygit installed"
else
    print_success "lazygit already installed"
fi

# Install lazydocker
if ! command -v lazydocker &> /dev/null; then
    print_status "Installing lazydocker..."
    LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazydocker.tar.gz -C /tmp lazydocker
    sudo install /tmp/lazydocker /usr/local/bin
    rm /tmp/lazydocker.tar.gz /tmp/lazydocker
    print_success "lazydocker installed"
else
    print_success "lazydocker already installed"
fi

# Install uv (Python package manager)
if ! command -v uv &> /dev/null; then
    print_status "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    print_success "uv installed"
else
    print_success "uv already installed"
fi

# Install CodeRabbit CLI
if ! command -v coderabbit &> /dev/null; then
    print_status "Installing CodeRabbit CLI..."
    curl -fsSL https://cli.coderabbit.ai/install.sh | sh
    print_success "CodeRabbit CLI installed"
else
    print_success "CodeRabbit CLI already installed"
fi

# Install Starship
if ! command -v starship &> /dev/null; then
    print_status "Installing Starship..."
    sudo pacman -S --needed --noconfirm starship
    print_success "Starship installed"
else
    print_success "Starship already installed"
fi

# Install Yazi file manager
if ! command -v yazi &> /dev/null; then
    print_status "Installing Yazi..."
    cd /tmp
    wget -q https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip
    unzip -q yazi-x86_64-unknown-linux-musl.zip
    sudo mv yazi-x86_64-unknown-linux-musl/yazi /usr/local/bin/
    sudo chmod +x /usr/local/bin/yazi
    rm -rf yazi-x86_64-unknown-linux-musl*
    print_success "Yazi installed"
else
    print_success "Yazi already installed"
fi

# Install JetBrains Mono Nerd Font
if [ ! -d /usr/share/fonts/truetype/jetbrains-mono ] || [ -z "$(ls -A /usr/share/fonts/truetype/jetbrains-mono)" ]; then
    print_status "Installing JetBrains Mono Nerd Font..."
    sudo mkdir -p /usr/share/fonts/truetype/jetbrains-mono
    cd /tmp
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
    sudo unzip -q -o JetBrainsMono.zip -d /usr/share/fonts/truetype/jetbrains-mono/
    rm JetBrainsMono.zip
    sudo fc-cache -fv > /dev/null 2>&1
    print_success "JetBrains Mono Nerd Font installed"
else
    print_success "JetBrains Mono Nerd Font already installed"
fi

# Install NvChad
if [ ! -d "$HOME/.config/nvim" ]; then
    print_status "Installing NvChad..."
    git clone https://github.com/NvChad/starter "$HOME/.config/nvim"
    print_success "NvChad installed"
else
    print_success "NvChad already installed (skipping)"
fi

# Configure Starship
if [ ! -f "$HOME/.config/starship.toml" ]; then
    print_status "Configuring Starship..."
    mkdir -p "$HOME/.config"
    starship preset catppuccin-powerline -o "$HOME/.config/starship.toml"
    
    # Add Starship to bashrc if not already there
    if ! grep -q "starship init bash" "$HOME/.bashrc"; then
        echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
    fi
    print_success "Starship configured"
else
    print_success "Starship already configured"
fi

# Add useful aliases if not already present
print_status "Adding useful aliases..."
if ! grep -q "alias ll=" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" << 'EOF'

# Developer Terminal aliases
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline -10"
alias dc="docker compose"
alias fm="yazi"
EOF
    print_success "Aliases added"
else
    print_success "Aliases already present"
fi

# Basic vimrc if not present
if [ ! -f "$HOME/.vimrc" ]; then
    print_status "Creating basic .vimrc..."
    cat > "$HOME/.vimrc" << 'EOF'
syntax on
set number
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set mouse=a
set clipboard=unnamedplus
colorscheme desert
EOF
    print_success ".vimrc created"
else
    print_success ".vimrc already exists"
fi

echo ""
echo "=================================="
echo "✓ Installation Complete!"
echo "=================================="
echo ""
echo "⚠️  Important: Please restart your terminal or run 'source ~/.bashrc' to apply changes."
echo ""
echo "📦 Installed tools:"
echo "  - System utilities (git, vim, neovim, tmux, etc.)"
echo "  - GitHub CLI (gh)"
echo "  - Docker"
echo "  - Rust tools (zoxide, fd, eza, etc.)"
echo "  - Node.js tools (Copilot CLI, Gemini CLI, etc.)"
echo "  - Lazy tools (lazygit, lazydocker)"
echo "  - uv, CodeRabbit CLI, Starship, Yazi"
echo "  - JetBrains Mono Nerd Font"
echo "  - NvChad (Neovim configuration)"
echo ""
