# syntax = docker/dockerfile:1.2

# Installer part
FROM mcr.microsoft.com/vscode/devcontainers/base:0-bullseye AS installer

ARG TL_URL="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
ENV PATH /usr/local/bin/texlive:$PATH
WORKDIR /workspace

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    perl \
    wget \
    xz-utils

COPY ./texlive.profile ./
RUN wget -nv "${TL_URL}" && \
    tar -xzf ./install-tl-unx.tar.gz --strip-components=1 && \
    ./install-tl --profile=texlive.profile && \
    ln -sf /usr/local/texlive/*/bin/* /usr/local/bin/texlive && \
    tlmgr install \
    collection-fontsrecommended \
    collection-langjapanese \
    collection-latexextra \
    latexmk

# Main part
# Note: You can use any Debian/Ubuntu based image you want.
FROM mcr.microsoft.com/vscode/devcontainers/base:0-bullseye

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby CLI instead of the licensed Docker CLI
ARG USE_MOBY="true"

# Enable new "BUILDKIT" mode for Docker CLI
ENV DOCKER_BUILDKIT=1

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=automatic
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    # Use Docker script from script library to set things up
    && /bin/bash /tmp/library-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

# Copy & setup TeXLive binary from installer
ENV PATH /usr/local/bin/texlive:$PATH

COPY --from=installer /usr/local/texlive /usr/local/texlive
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    perl \
    wget && \
    ln -sf /usr/local/texlive/*/bin/* /usr/local/bin/texlive

# Change login shell as zsh and install dotfiles.
ARG USER_NAME="vscode"
ARG DEVCONTAINER_PATH="/workspace/.devcontainer"
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

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access
# to the Docker socket. The script will also execute CMD as needed.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# [Optional] Uncomment this section to install additional OS packages.
# RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
#     apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get -y install --no-install-recommends \
#     <your-package-here>
