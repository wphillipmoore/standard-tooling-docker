# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Auto-memory policy

**Do NOT use MEMORY.md.** Never write to MEMORY.md or any file under the
memory directory. All behavioral rules, conventions, and workflow instructions
belong in managed, version-controlled documentation (CLAUDE.md, AGENTS.md,
skills, or docs/). If you want to persist something, tell the human what you
would save and let them decide where it belongs.

## Parallel AI agent development

This repository supports running multiple Claude Code agents in parallel via
git worktrees. The convention keeps parallel agents' working trees isolated
while preserving shared project memory (which Claude Code derives from the
session's starting CWD).

**Canonical spec:**
[`standard-tooling/docs/specs/worktree-convention.md`](https://github.com/wphillipmoore/standard-tooling/blob/develop/docs/specs/worktree-convention.md)
— full rationale, trust model, failure modes, and memory-path implications.
The canonical text lives in `standard-tooling`; this section is the local
on-ramp.

### Structure

```text
~/dev/github/standard-tooling-docker/     ← sessions ALWAYS start here
  .git/
  CLAUDE.md, docker/, …                   ← main worktree (usually `develop`)
  .worktrees/                             ← container for parallel worktrees
    issue-48-adopt-worktree-convention/   ← worktree on feature/48-...
    …
```

### Rules

1. **Sessions always start at the project root.**
   `cd ~/dev/github/standard-tooling-docker && claude` — never from inside
   `.worktrees/<name>/`. This keeps the memory-path slug stable and shared.
2. **Each parallel agent is assigned exactly one worktree.** The session
   prompt names the worktree (see Agent prompt contract below).
   - For Read / Edit / Write tools: use the worktree's absolute path.
   - For Bash commands that touch files: `cd` into the worktree first,
     or use absolute paths.
3. **The main worktree is read-only.** All edits flow through a worktree
   on a feature branch — the logical endpoint of the standing
   "no direct commits to develop" policy.
4. **One worktree per issue.** Don't stack in-flight issues. When a
   branch lands, remove the worktree before starting the next.
5. **Naming: `issue-<N>-<short-slug>`.** `<N>` is the GitHub issue
   number; `<short-slug>` is 2–4 kebab-case tokens.

### Agent prompt contract

When launching a parallel-agent session, use this template (fill in the
placeholders):

```text
You are working on issue #<N>: <issue title>.

Your worktree is: /Users/pmoore/dev/github/standard-tooling-docker/.worktrees/issue-<N>-<slug>/
Your branch is:   feature/<N>-<slug>

Rules for this session:
- Do all git operations from inside your worktree:
    cd <absolute-worktree-path> && git <command>
- For Read / Edit / Write tools, use the absolute worktree path.
- For Bash commands that touch files, cd into the worktree first
  or use absolute paths.
- Do not edit files at the project root. The main worktree is
  read-only — all changes flow through your worktree on your
  feature branch.
```

All fields are required.

## Project Overview

This repository contains the Docker dev container images for the
standard-tooling ecosystem. Each image provides a language runtime plus
shared tooling (Node.js, ShellCheck, markdownlint) used by CI and local
Docker-first development across all managed repositories.

**Project name**: standard-tooling-docker

**Status**: Active

**Standards reference**: <https://github.com/wphillipmoore/standards-and-conventions>
— historical reference; active standards documentation lives in the
standard-tooling repository under `docs/`.

## Development Commands

### Environment Setup

```bash
# Host-installed standard-tooling provides st-* commands on PATH.
# Install per the host-level-tool spec
# (https://github.com/wphillipmoore/standard-tooling/blob/develop/docs/specs/host-level-tool.md):
uv tool install 'standard-tooling @ git+https://github.com/wphillipmoore/standard-tooling@v1.4'
# (or `pip install` into the same Python env that hosts `uv`).

# Enable the pre-commit gate (refuses raw `git commit`; admits
# st-commit). The gate is vendored at `.githooks/pre-commit` in
# this repo.
git config core.hooksPath .githooks
```

### Validation

```bash
hadolint docker/*/Dockerfile    # Lint Dockerfiles
shellcheck docker/build.sh      # Lint shell scripts
markdownlint .                  # Lint Markdown
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

Image URLs use the **user namespace** (`ghcr.io/wphillipmoore/...`), not a
repo-specific namespace. This means image paths are stable across repo
migrations — they do not change when the publishing repository changes.

#### Publishing prerequisites

The workflow uses `secrets.GITHUB_TOKEN` with `packages: write` permission.
No PAT or additional secret is needed. However, each GHCR package must
explicitly grant this repository write access because the packages were
originally created by the `standard-tooling` repository.

Per-package setup (one-time, for each of `dev-python`, `dev-java`, `dev-go`,
`dev-ruby`, `dev-rust`):

1. Navigate to the package settings page on GHCR.
2. Under **Manage Actions access**, click **Add Repository**.
3. Select `standard-tooling-docker`.
4. Set role to **Write**.

### Version Matrix

| Language | Versions         |
| -------- | ---------------- |
| Ruby     | 3.2, 3.3, 3.4    |
| Python   | 3.12, 3.13, 3.14 |
| Java     | 17, 21           |
| Go       | 1.25, 1.26       |
| Rust     | 1.92, 1.93       |

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
