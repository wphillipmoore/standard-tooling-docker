# standard-tooling-docker

Docker dev container images for the
[standard-tooling](https://github.com/wphillipmoore/standard-tooling) ecosystem.
Each image provides a language runtime plus shared tooling (Node.js, ShellCheck,
markdownlint) used by CI and local Docker-first development across all managed
repositories.

## Table of Contents

- [Available Images](#available-images)
- [Usage](#usage)
- [Common Tooling](#common-tooling)
- [Publishing](#publishing)
- [Migration Note](#migration-note)

## Available Images

All images are published to GitHub Container Registry at
`ghcr.io/wphillipmoore/dev-{language}:{version}`.

| Image        | Versions         | Base                      |
| ------------ | ---------------- | ------------------------- |
| `dev-ruby`   | 3.2, 3.3, 3.4    | `ruby:<v>-slim`           |
| `dev-python` | 3.12, 3.13, 3.14 | `python:<v>-slim`         |
| `dev-java`   | 17, 21           | `eclipse-temurin:<v>-jdk` |
| `dev-go`     | 1.25, 1.26       | `golang:<v>`              |
| `dev-rust`   | 1.92, 1.93       | `rust:<v>-slim`           |

## Usage

Pull a pre-built image:

```bash
docker pull ghcr.io/wphillipmoore/dev-python:3.14
```

Or build all images locally:

```bash
docker/build.sh
```

Build a single image:

```bash
docker build --build-arg PYTHON_VERSION=3.14 -t dev-python:3.14 docker/python/
```

## Common Tooling

Every image includes:

- **Node.js** 22.22.0 (multi-stage copy)
- **ShellCheck** 0.11.0
- **markdownlint-cli** 0.47.0
- Language-specific package manager and linting tools

## Publishing

Images are published automatically on push to `develop` or `main` via the
`docker-publish.yml` workflow. Manual rebuilds can be triggered via
`workflow_dispatch` in the Actions tab.

## Migration Note

These images were originally maintained in the
[standard-tooling](https://github.com/wphillipmoore/standard-tooling) repository
under `docker/`. They were split into this dedicated repository to provide an
independent release lifecycle and clearer separation of concerns.
