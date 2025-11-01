# Developer Terminal

A comprehensive Docker-based development environment with web terminal access via ttyd.

## Quick Start

### Using Docker Compose

```bash
docker-compose up -d
```

Then access the web terminal at http://localhost:7681

### Using Docker CLI

```bash
docker run -it -p 7681:7681 -v ./workspace:/workspace ghcr.io/weholt/developer-terminal:latest
```

## Features

### System Tools

- Shell Environments: bash, zsh, fish
- Editors: nano, vim, neovim (with NvChad configuration)
- Terminal UI: ttyd (web-based terminal)
- Utilities: git, curl, wget, htop, tree, jq, ripgrep, fzf, entr

### File Management

- yazi - Modern terminal file manager
- lazygit - Git UI
- lazydocker - Docker UI
- rclone - Cloud storage synchronization
- rsync - File synchronization

### Programming Languages & Tools

- Rust 1.83+ with cargo
- Node.js 20 with npm
- Python 3 with pip and uv package manager
- Build Tools: make, build-essential

### Rust Tools

Pre-installed via cargo:

- zoxide - Smart directory jumper
- fd-find - Fast alternative to find
- tealdeer - Fast tldr client
- du-dust - Better du command
- eza - Modern ls replacement
- duf - Better df command
- bottom - System monitoring

### Node.js Tools

Pre-installed globally:

- @google/gemini-cli - Google Gemini AI CLI
- @githubnext/github-copilot-cli - GitHub Copilot CLI
- @anthropic-ai/claude-code - Claude code assistant
- opencode-ai - Opencode CLI

### Development & Monitoring

- Docker - Container runtime
- docker-compose - Container orchestration
- Python3 with docker SDK - Python Docker integration
- glances - System monitoring tool
- iotop - I/O monitoring
- iftop - Network monitoring
- bmon - Bandwidth monitor
- ncdu - Disk usage analyzer
- nvtop - NVIDIA GPU monitoring
- nmap - Network scanner

### Utilities & Formats

- jq - JSON processor
- bat - Better cat with syntax highlighting
- httpie - HTTP CLI client
- pgcli - PostgreSQL CLI
- mediainfo - Media file information
- p7zip - 7-zip archive support
- pass - Password manager
- tldr - Simplified man pages

### Customization

- Starship - Smart shell prompt (Catppuccin Powerline theme)
- NvChad - Neovim configuration
- JetBrains Mono Nerd Font - Beautiful monospace font with icons
- tmux configuration - Terminal multiplexer config

## Environment

- Timezone: Europe/Oslo (customizable via TZ environment variable)
- Shell: bash (with aliases for common commands like ll, gs, gd, dc)
- Terminal Font: JetBrains Mono Nerd Font (16pt)

## Accessing the Terminal

### Web Terminal (ttyd)

Open your browser to http://localhost:7681

### Docker exec

```bash
docker exec -it <container_id> bash
```

## Configuration Files

- .bashrc - Bash configuration with aliases and Starship init
- .vimrc - Vim configuration
- .tmux.conf - Tmux configuration
- /root/.config/starship.toml - Starship prompt theme
- /root/.config/nvim - NvChad neovim configuration

## Building from Source

```bash
docker build --no-cache -t dw:latest .
```

## System Requirements

- Docker with BuildKit support
- ~2GB disk space for the image
- 2GB+ RAM recommended
- Network access for package downloads

