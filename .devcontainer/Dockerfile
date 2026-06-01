FROM mcr.microsoft.com/devcontainers/javascript-node:24

ARG TZ
ENV TZ="$TZ"

# Generate ja_JP.UTF-8 locale
RUN sed -i '/^# ja_JP.UTF-8/s/^# //' /etc/locale.gen && locale-gen

# Install additional tools (base image already includes: less, git, procps, sudo, zsh, man-db, unzip, gnupg2, jq, nano, vim-tiny, iproute2)
RUN apt-get update && apt-get install -y --no-install-recommends \
  awscli \
  bat \
  dnsutils \
  eza \
  fd-find \
  fish \
  ripgrep \
  vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && ln -s "$(which batcat)" /usr/local/bin/bat \
  && ln -s "$(which fdfind)" /usr/local/bin/fd

# Install neovim
ARG NEOVIM_VERSION=0.12.2
RUN ARCH=$(dpkg --print-architecture) && \
  if [ "$ARCH" = "arm64" ]; then NVIM_ARCH="arm64"; else NVIM_ARCH="x86_64"; fi && \
  wget "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz" && \
  rm -rf "/opt/nvim-linux-${NVIM_ARCH}" && \
  tar -C /opt -xzf "nvim-linux-${NVIM_ARCH}.tar.gz" && \
  rm "nvim-linux-${NVIM_ARCH}.tar.gz"
ENV PATH="$PATH:/opt/nvim-linux-x86_64/bin:/opt/nvim-linux-arm64/bin"

# Install git-worktree-runner (gtr)
RUN git clone --depth 1 https://github.com/coderabbitai/git-worktree-runner.git /opt/git-worktree-runner \
  && /opt/git-worktree-runner/install.sh

# Install chezmoi
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

# Install lazygit
ARG LAZYGIT_VERSION=0.51.1
RUN ARCH=$(dpkg --print-architecture) && \
  if [ "$ARCH" = "arm64" ]; then GOARCH="arm64"; else GOARCH="x86_64"; fi && \
  wget "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${GOARCH}.tar.gz" && \
  tar xzf "lazygit_${LAZYGIT_VERSION}_Linux_${GOARCH}.tar.gz" lazygit && \
  install lazygit /usr/local/bin && \
  rm lazygit "lazygit_${LAZYGIT_VERSION}_Linux_${GOARCH}.tar.gz"

# Install starship
RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y

# Install delta
ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

ARG USERNAME=node

# Set up command history directory
RUN mkdir /command-history \
  && touch /command-history/.command_history \
  && chown -R $USERNAME /command-history

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create config directories and set permissions
RUN mkdir -p /home/node/.claude && \
  chown -R node:node /home/node/.claude
RUN mkdir -p /home/node/.copilot && \
  chown -R node:node /home/node/.copilot

# Set up non-root user
USER node

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set the default editor and visual
ENV EDITOR=nano
ENV VISUAL=nano

# Set up bash history
RUN echo "export HISTFILE=/command-history/.command_history" >> "$HOME/.bashrc" \
  && echo "shopt -s histappend" >> "$HOME/.bashrc" \
  && echo 'PROMPT_COMMAND="history -a; $PROMPT_COMMAND"' >> "$HOME/.bashrc"

# Set up zsh with zsh-in-docker (default theme: powerlevel10k)
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -p https://github.com/zsh-users/zsh-autosuggestions \
  -p https://github.com/zsh-users/zsh-syntax-highlighting \
  -a 'eval "$(fzf --zsh)"' \
  -a "export HISTFILE=/command-history/.command_history" \
  -x

# Install Claude Code
ARG CLAUDE_CODE_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Skip Claude Code onboarding screen
# https://github.com/anthropics/claude-code/issues/8938
RUN echo '{ "hasCompletedOnboarding": true }' > /home/node/.claude/.claude.json
