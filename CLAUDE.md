# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

<!-- include: docs/standards-and-conventions.md -->
<!-- include: docs/repository-standards.md -->

## Project Overview

This repository contains the Docker dev container images for the
standard-tooling ecosystem. Each image provides a language runtime plus
shared tooling (Node.js, ShellCheck, markdownlint) used by CI and local
Docker-first development across all managed repositories.

**Project name**: standard-tooling-docker

**Status**: Active

**Canonical Standards**: This repository follows standards at <https://github.com/wphillipmoore/standards-and-conventions> (local path: `../standards-and-conventions` if available)

## Development Commands

### Environment Setup

```bash
cd ../standard-tooling && uv sync                                                # Install standard-tooling
export PATH="../standard-tooling/.venv/bin:../standard-tooling/scripts/bin:$PATH" # Put tools on PATH
git config core.hooksPath ../standard-tooling/scripts/lib/git-hooks               # Enable git hooks
```

### Validation

```bash
hadolint docker/*/Dockerfile    # Lint Dockerfiles
shellcheck docker/build.sh      # Lint shell scripts
markdownlint '**/*.md'          # Lint Markdown
```

### Building Images Locally

```bash
docker/build.sh                 # Build all images for every version in the matrix
```

Individual images can be built with:

```bash
docker build --build-arg PYTHON_VERSION=3.14 -t dev-python:3.14 docker/python/
```

## Architecture

### Image Layout

```text
docker/
  build.sh          # Builds all images locally
  python/Dockerfile # Python dev image with uv
  java/Dockerfile   # Java dev image, Eclipse Temurin
  go/Dockerfile     # Go dev image with linters
  ruby/Dockerfile   # Ruby dev image with bundler
  rust/Dockerfile   # Rust dev image with cargo tools
```

### Common Layer

Every image includes:

- **Node.js** (multi-stage copy from `node:22.22.0-bookworm-slim`)
- **ShellCheck** (`0.11.0`)
- **markdownlint-cli** (`0.47.0`)
- Language-specific package manager and linting tools

### GHCR Publishing

Images are published to GitHub Container Registry by the `docker-publish.yml`
workflow on push to `develop` or `main`, or via manual `workflow_dispatch`.

Image naming: `ghcr.io/wphillipmoore/dev-{language}:{version}`

### Version Matrix

| Language | Versions       |
|----------|----------------|
| Ruby     | 3.2, 3.3, 3.4 |
| Python   | 3.12, 3.13, 3.14 |
| Java     | 17, 21         |
| Go       | 1.25, 1.26     |
| Rust     | 1.92, 1.93     |

To trigger a rebuild manually: Actions > "Publish dev container images" >
Run workflow.

### Design Principles

- **Thin images** — language runtime + package manager + git/curl
- **Project-managed dependencies** — tools come from lockfiles at
  container startup (e.g., `bundle install`, `uv sync`, `go install`)
- **No host requirements** — Docker is the only prerequisite for
  local development

## Key References

**Sibling repositories**:

- `../standard-tooling` — Python CLI tools and bash validators
- `../standard-tooling-plugin` — Claude Code plugin (hooks, skills, agents)
