# Optimized multi-stage build for @home Web Terminal

# -------------------------------
# Stage 1: Build and install Rust tools
# -------------------------------
FROM rust:latest AS rusttools

RUN apt-get update && apt-get install -y curl build-essential && rm -rf /var/lib/apt/lists/*
RUN cargo install zoxide fd-find tealdeer du-dust eza duf bottom

# -------------------------------
# Stage 2: Build Node tools
# -------------------------------
FROM node:20-slim AS nodetools

RUN npm install -g \
    @google/gemini-cli \
    @githubnext/github-copilot-cli \
    @anthropic-ai/claude-code \
    opencode-ai

# -------------------------------
# Stage 3: Base system setup
# -------------------------------
FROM tsl0922/ttyd:latest AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Oslo

# Install base utilities and dependencies
RUN apt-get update && \
    apt-get install -y \
      ca-certificates curl git build-essential \
      nano vim neovim wget htop fzf tree jq \
      docker.io \
      python3 python3-pip python3-docker \
      unzip fontconfig ripgrep zsh fish direnv entr \
      rsync rclone glances iotop iftop bmon ncdu \
      mediainfo p7zip pass httpie tldr pgcli bat nvtop nmap tmux ffmpeg \
      && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# Stage 4: Lazy tools (lazygit, lazydocker)
# -------------------------------
FROM base AS lazytools

RUN set -eux; \
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*'); \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"; \
    tar xf lazygit.tar.gz lazygit; \
    install lazygit /usr/local/bin; \
    rm lazygit.tar.gz lazygit

RUN set -eux; \
    LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*'); \
    curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"; \
    tar xf lazydocker.tar.gz lazydocker; \
    install lazydocker /usr/local/bin; \
    rm lazydocker.tar.gz lazydocker

# -------------------------------
# Stage 5: Final image
# -------------------------------
FROM base

# Copy Rust tools and Node tools
COPY --from=rusttools /usr/local/cargo/bin/* /usr/local/bin/
COPY --from=nodetools /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=nodetools /usr/local/bin /usr/local/bin

# Link Copilot CLI
RUN ln -sf /usr/lib/node_modules/@githubnext/github-copilot-cli/cli.js /usr/local/bin/github-copilot-cli && \
    ln -sf /usr/local/bin/github-copilot-cli /usr/local/bin/copilot

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Install CodeRabbit CLI
RUN curl -fsSL https://cli.coderabbit.ai/install.sh | sh

# Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install VHS (requires ffmpeg)
RUN set -eux; \
    VHS_VERSION=$(curl -s "https://api.github.com/repos/charmbracelet/vhs/releases/latest" | jq -r '.tag_name | ltrimstr(\"v\")'); \
    curl -Lo vhs.tar.gz "https://github.com/charmbracelet/vhs/releases/download/v${VHS_VERSION}/vhs_${VHS_VERSION}_Linux_x86_64.tar.gz"; \
    tar xf vhs.tar.gz vhs; \
    install vhs /usr/local/bin; \
    rm vhs.tar.gz vhs

# Install Yazi file manager (musl binary)
RUN cd /tmp && \
    wget -q https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip && \
    unzip -q yazi-x86_64-unknown-linux-musl.zip && \
    mv yazi-x86_64-unknown-linux-musl/yazi /usr/local/bin/ && \
    chmod +x /usr/local/bin/yazi && \
    rm -rf yazi-x86_64-unknown-linux-musl*

# Fonts: JetBrains Mono Nerd Font
RUN mkdir -p /usr/share/fonts/truetype/jetbrains-mono && \
    cd /tmp && \
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip && \
    unzip -q JetBrainsMono.zip -d /usr/share/fonts/truetype/jetbrains-mono/ && \
    rm JetBrainsMono.zip && \
    fc-cache -fv

# Install NvChad
RUN git clone https://github.com/NvChad/starter /root/.config/nvim

# Configure Starship
RUN mkdir -p /root/.config && \
    starship preset catppuccin-powerline -o /root/.config/starship.toml && \
    echo 'eval "$(starship init bash)"' >> /root/.bashrc

# Aliases
RUN echo 'alias ll="ls -lah"' >> /root/.bashrc && \
    echo 'alias la="ls -A"' >> /root/.bashrc && \
    echo 'alias l="ls -CF"' >> /root/.bashrc && \
    echo 'alias gs="git status"' >> /root/.bashrc && \
    echo 'alias gd="git diff"' >> /root/.bashrc && \
    echo 'alias gl="git log --oneline -10"' >> /root/.bashrc && \
    echo 'alias dc="docker compose"' >> /root/.bashrc && \
    echo 'alias fm="yazi"' >> /root/.bashrc

# Basic vimrc
RUN echo 'syntax on\nset number\nset tabstop=4\nset shiftwidth=4\nset expandtab\nset autoindent\nset smartindent\nset mouse=a\nset clipboard=unnamedplus\ncolorscheme desert' > /root/.vimrc

# Welcome banner
RUN echo 'echo ""' >> /root/.bashrc && \
    echo 'echo "🏠 Welcome to Developer Terminal"' >> /root/.bashrc && \
    echo 'echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"' >> /root/.bashrc && \
    echo 'echo "📁 Current directory: $(pwd)"' >> /root/.bashrc && \
    echo 'echo "⚙️  Editors: nano, vim, nvim (NvChad)"' >> /root/.bashrc && \
    echo 'echo "🐍 Python: 3.x with uv | 🧠 AI CLIs: Copilot, Gemini, Claude, Opencode, CodeRabbit"' >> /root/.bashrc && \
    echo 'echo "🐳 Docker tools: docker, compose, lazydocker"' >> /root/.bashrc && \
    echo 'echo "📦 Utilities: git, gh, curl, htop, tree, jq, rg, yazi, lazygit"' >> /root/.bashrc && \
    echo 'echo "✨ Starship (Catppuccin Powerline)"' >> /root/.bashrc && \
    echo 'echo ""' >> /root/.bashrc

COPY .tmux.conf /root/.tmux.conf

WORKDIR /workspace

ENTRYPOINT ["ttyd"]
CMD ["-p", "7681", "-W", "-t", "fontSize=16", "-t", "fontFamily='JetBrainsMono Nerd Font'", "bash"]
