# syntax = docker/dockerfile:1.2
ARG RUNTIME_BASE_IMAGE
FROM ${RUNTIME_BASE_IMAGE}
ARG USERNAME='vscode'
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN command -v useradd >/dev/null 2>&1 && \
    if [ "${?}" = 0 ]; then groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}; \
    else addgroup -g ${USER_GID} ${USERNAME} && adduser -u ${USER_UID} ${USERNAME}; fi && \
    su ${USERNAME} -c \
    'mkdir -p "/home/${USERNAME}/.vscode-server/extensions" && mkdir -p "/home/${USERNAME}/.vscode-server-insiders/extensions"'
