# Python Remote-Container Development Environments

## Description

VSCode Docker remote container development environment for Python + Jupyter.

## Installed Extensions

- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)
- [Python Docstring Generator](https://marketplace.visualstudio.com/items?itemName=njpwerner.autodocstring)
- [Jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
- [Rainbow CSV](https://marketplace.visualstudio.com/items?itemName=mechatroner.rainbow-csv)

## Notice

- Application source code directory name (path) must be **`./src`**.
- If you want to use requirements.txt in `src` directory, please **modify `PIP_REQUIREMENTS_PATH` value in [`./.devcontainer/docker-compose.yml`](./.devcontainer/docker-compose.yml)** and **uncomment `!src/requirements.txt` in [`./.dockerignore`](./.dockerignore)**
