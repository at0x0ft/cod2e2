# Base Remote-Container Development Environments

## Description

VSCode Docker remote container development base environment

## How to Use

1. Write your preferred config to [`.env`](./.env) and [`./devcontainer/config`](./.devcontainer/config) .
2. Generate [`.devcontainer/docker-compose.yml`](./.devcontainer/docker-compose.yml) for remote development using [`.devcontainer/generate_docker_compose.sh`](./.devcontainer/generate_docker_compose.sh) .
3. Open VSCode in this directory and reopen this repository in the container.

## Notice

1. Source code directory name (path) must be **`./src`** (you can change this in [`.env`](./.env)) .
2. In "How to Use" step 2, you must correspond setting values between [`config`](./.devcotainer/../.devcontainer/config) and [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json).
3. [`.devcontainer/docker/development_base/Dockerfile`](./.devcontainer/docker/development_base/Dockerfile) is completely same with [`../../development_base/.devcontainer`](../../development_base/.devcontainer) one. However, currently docker-compose build with their symlinks are not working properly. So now they are just copied ones (hoping to fix this issue: [https://github.com/docker/compose/issues/7397](https://github.com/docker/compose/issues/7397)) .

## Installed Extensions

### Common

- [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [jumpy](https://marketplace.visualstudio.com/items?itemName=wmaurer.vscode-jumpy)
- [indent-rainbow](https://marketplace.visualstudio.com/items?itemName=oderwat.indent-rainbow)
- [zenkaku](https://marketplace.visualstudio.com/items?itemName=mosapride.zenkaku)
- [Path Intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense)
- [Visual Studio IntelliCode](https://marketplace.visualstudio.com/items?itemName=visualstudioexptteam.vscodeintellicode)
- [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
- [GitLens — Git supercharged](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [Git Graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph)
- [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
- [markdownlint](https://marketplace.visualstudio.com/items?itemName=davidanson.vscode-markdownlint)
