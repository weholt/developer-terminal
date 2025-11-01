FROM tsl0922/ttyd:latest

# Add Docker's official GPG key:
RUN apt-get update && apt-get install -y ca-certificates curl
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt install -y curl git build-essential
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustc --version && cargo --version

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Oslo

# Install useful tools and editors
RUN apt-get update && apt-get install -y \
    nano \
    vim \
    neovim \
    git \
    curl \
    wget \
    htop \
    fzf \
    tree \
    jq \
    docker.io \
    docker-compose-plugin \
    python3 \
    python3-pip \
    python3-docker \
    unzip \
    fontconfig \
    ripgrep \
    zsh \
    fish \
    direnv \
    ripgrep \
    entr \
    rsync \
    rclone \
    glances \
    htop \
    iotop \
    iftop \
    bmon \
    ncdu \
    mediainfo \
    p7zip \
    pass \
    httpie \
    tldr \
    pgcli \
    ncdu \
    bat \
    nvtop \
    nmap \
    && rm -rf /var/lib/apt/lists/*
RUN cargo install zoxide fd-find tealdeer du-dust eza duf bottom

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install global npm packages
RUN npm install -g @google/gemini-cli @githubnext/github-copilot-cli opencode-ai && \
    ln -sf /usr/lib/node_modules/@githubnext/github-copilot-cli/cli.js /usr/local/bin/github-copilot-cli && \
    ln -sf /usr/local/bin/github-copilot-cli /usr/local/bin/copilot
RUN npm install -g @anthropic-ai/claude-code

# Install Lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit /usr/local/bin && \
    rm lazygit.tar.gz lazygit

# Install Lazydocker
RUN LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazydocker.tar.gz lazydocker && \
    install lazydocker /usr/local/bin && \
    rm lazydocker.tar.gz lazydocker

# Install uv (fast Python package installer and manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install yazi file manager (musl version for compatibility)
RUN cd /tmp && \
    wget -q https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip && \
    unzip -q yazi-x86_64-unknown-linux-musl.zip && \
    mv yazi-x86_64-unknown-linux-musl/yazi /usr/local/bin/ && \
    chmod +x /usr/local/bin/yazi && \
    rm -rf yazi-x86_64-unknown-linux-musl yazi-x86_64-unknown-linux-musl.zip

# Download and install JetBrains Mono Nerd Font
RUN mkdir -p /usr/share/fonts/truetype/jetbrains-mono && \
    cd /tmp && \
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip && \
    unzip -q JetBrainsMono.zip -d /usr/share/fonts/truetype/jetbrains-mono/ && \
    rm JetBrainsMono.zip && \
    fc-cache -fv

# Install NvChad
RUN git clone https://github.com/NvChad/starter /root/.config/nvim

# Configure Starship with Catppuccin Powerline preset
RUN mkdir -p /root/.config && \
    starship preset catppuccin-powerline -o /root/.config/starship.toml

# Configure bash to use Starship
RUN echo 'eval "$(starship init bash)"' >> /root/.bashrc

# Add useful aliases
RUN echo 'alias ll="ls -lah"' >> /root/.bashrc && \
    echo 'alias la="ls -A"' >> /root/.bashrc && \
    echo 'alias l="ls -CF"' >> /root/.bashrc && \
    echo 'alias ..="cd .."' >> /root/.bashrc && \
    echo 'alias ...="cd ../.."' >> /root/.bashrc && \
    echo 'alias gs="git status"' >> /root/.bashrc && \
    echo 'alias gd="git diff"' >> /root/.bashrc && \
    echo 'alias gl="git log --oneline -10"' >> /root/.bashrc && \
    echo 'alias dc="docker compose"' >> /root/.bashrc && \
    echo 'alias dps="docker ps"' >> /root/.bashrc && \
    echo 'alias fm="yazi"' >> /root/.bashrc

# Configure vim with basic settings (fallback for when nvim isn't used)
RUN echo 'syntax on' > /root/.vimrc && \
    echo 'set number' >> /root/.vimrc && \
    echo 'set tabstop=4' >> /root/.vimrc && \
    echo 'set shiftwidth=4' >> /root/.vimrc && \
    echo 'set expandtab' >> /root/.vimrc && \
    echo 'set autoindent' >> /root/.vimrc && \
    echo 'set smartindent' >> /root/.vimrc && \
    echo 'set mouse=a' >> /root/.vimrc && \
    echo 'set clipboard=unnamedplus' >> /root/.vimrc && \
    echo 'colorscheme desert' >> /root/.vimrc

# Create welcome message
RUN echo 'echo ""' >> /root/.bashrc && \
    echo 'echo "🏠 Welcome to @home Web Terminal"' >> /root/.bashrc && \
    echo 'echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"' >> /root/.bashrc && \
    echo 'echo "📁 Current directory: $(pwd)"' >> /root/.bashrc && \
    echo 'echo "⚙️  Editors: nano, vim, nvim (with NvChad)"' >> /root/.bashrc && \
    echo 'echo "NODE: $(node -v), NPM: $(npm -v), NPX: available"' >> /root/.bashrc && \
    echo 'echo "🐍 Python: 3.13 with uv"' >> /root/.bashrc && \
    echo 'echo "🤖 Gemini CLI: available"' >> /root/.bashrc && \
    echo 'echo "🐳 Docker: docker, docker compose, lazydocker"' >> /root/.bashrc && \
    echo 'echo "📦 Tools: git, curl, wget, htop, tree, jq, rg, yazi, lazygit"' >> /root/.bashrc && \
    echo 'echo "✨ Prompt: Starship (Catppuccin Powerline)"' >> /root/.bashrc && \
    echo 'echo ""' >> /root/.bashrc

WORKDIR /workspace

ENTRYPOINT ["ttyd"]
# Increase font size to 16px and set JetBrains Mono Nerd Font
CMD ["-p", "7681", "-W", "-t", "fontSize=16", "-t", "fontFamily='JetBrainsMono Nerd Font'", "bash"]
