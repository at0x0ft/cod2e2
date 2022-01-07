# syntax = docker/dockerfile:1.2
# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.209.6/containers/python-3/.devcontainer/base.Dockerfile

# [Choice] Python version (use -bullseye variants on local arm64/Apple Silicon): 3, 3.10, 3.9, 3.8, 3.7, 3.6, 3-bullseye, 3.10-bullseye, 3.9-bullseye, 3.8-bullseye, 3.7-bullseye, 3.6-bullseye, 3-buster, 3.10-buster, 3.9-buster, 3.8-buster, 3.7-buster, 3.6-buster
ARG VARIANT="3.10-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/python:0-${VARIANT}

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# Change login shell as zsh and install dotfiles.
ARG USER_NAME="vscode"
ARG DEVCONTAINER_PATH="/workspace/.devcontainer"
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libncurses-dev \
    unzip \
    curl \
    file \
    jq \
    make \
    autoconf && \
    chsh -s $(which zsh) "${USER_NAME}" && \
    su "${USER_NAME}" -c 'git clone "https://github.com/at0x0ft/dotfiles.git" ${HOME}/.dotfiles && ${HOME}/.dotfiles/src/bin/install.sh -c' && \
    su "${USER_NAME}" -c 'ln -snv ${DEVCONTAINER_PATH}/.zhistory ${HOME}/.zhistory'

# [Optional] Uncomment this section to install additional OS packages.
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libgraphviz-dev \
    graphviz
    # <your-package-list-here>

# [Optional] If your pip requirements rarely change, uncomment this section to add them to the image.
ARG PIP_REQUIREMENTS_PATH="requirements.txt"
ARG PIP_REQUIREMENTS_DEV_PATH=".devcontainer/requirements.txt"
COPY "${PIP_REQUIREMENTS_PATH}" /tmp/pip-tmp/requirements.txt
COPY "${PIP_REQUIREMENTS_DEV_PATH}" /tmp/pip-tmp/requirements.dev.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip3 --disable-pip-version-check install -r /tmp/pip-tmp/requirements.txt && \
    pip3 --disable-pip-version-check install -r /tmp/pip-tmp/requirements.dev.txt && \
    rm -rf /tmp/pip-tmp

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
