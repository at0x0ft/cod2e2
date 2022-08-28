# cod2e2

## Description

VSCode personal development environment templates for Docker remote container

## Purpose (Focus? Goal?)

This repository is especially focusing on **splitting environment to source code** and **construct new (or somewhat minor) language environment flexibly and easily**.

## Composition

- [`base`](./base/): base debian development environment docker image
- [`languages`](./languages/): other language specific development environment docker image derived from [`base`](./base/) image
- [`tools`](./tools/): maintenance shellscript tools (please read [`README.md`](./tools/README.md) inside this directory)
