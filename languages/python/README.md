# Python Remote-Container Development Environments

## Description

VSCode Docker remote container development environment for Python

## How to Use

1. Write your preferred config to [`.env`](./.env) and [`./devcontainer/config`](./.devcontainer/config) .
2. Generate [`.devcontainer/docker-compose.yml`](./.devcontainer/docker-compose.yml) for remote development using [`.devcontainer/generate_docker_compose.sh`](./.devcontainer/generate_docker_compose.sh) .
3. Open VSCode in this directory and reopen this repository in the container.

## Notice

1. In "How to Use" step 2, you must correspond setting values between [`config`](./.devcotainer/../.devcontainer/config) and [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json).
2. [`.devcontainer/docker/development_base/Dockerfile`](./.devcontainer/docker/development_base/Dockerfile) is completely same with [`../../development_base/.devcontainer`](../../development_base/.devcontainer) one. However, currently docker-compose build with their symlinks are not working properly. So now they are just copied ones (hoping to fix this issue: [https://github.com/docker/compose/issues/7397](https://github.com/docker/compose/issues/7397)) .

For other notice(s), please refer to [development base image README.md](../../development_base/README.md) .

## Installed Extensions

### Common

Please refer to [development base image README.md](../../development_base/README.md) .

### Language-Specific

- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)
- [Python Docstring Generator](https://marketplace.visualstudio.com/items?itemName=njpwerner.autodocstring)
- [Better TOML](https://marketplace.visualstudio.com/items?itemName=bungcip.better-toml)
