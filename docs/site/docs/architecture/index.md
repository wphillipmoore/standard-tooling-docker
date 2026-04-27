# Architecture

## Build Strategy

All images are built from Dockerfile templates using a two-stage process:

1. `generate.sh` expands `Dockerfile.template` files by replacing
   `# @include` directives with the contents of shared fragments from
   `docker/common/`.
2. `build.sh` calls `generate.sh` then runs `docker build` for every
   language and version combination.

```text
docker/
├── build.sh                    # Builds all images
├── generate.sh                 # Expands templates into Dockerfiles
├── common/
│   ├── github-cli.dockerfile
│   ├── node-markdownlint.dockerfile
│   ├── python-support.dockerfile
│   ├── standard-tooling-pip.dockerfile
│   ├── standard-tooling-uv.dockerfile
│   └── validation-tools.dockerfile
├── base/Dockerfile.template
├── python/Dockerfile.template
├── ruby/Dockerfile.template
├── go/Dockerfile.template
├── java/Dockerfile.template
└── rust/Dockerfile.template
```

### Templating

Each `Dockerfile.template` contains standard Dockerfile instructions plus
`# @include common/<fragment>.dockerfile` directives. `generate.sh`
replaces each directive with the full contents of the referenced fragment,
producing a final `Dockerfile` in the same directory.

This eliminates duplication — shared tool installations (GitHub CLI,
Node.js, markdownlint, validation tools, standard-tooling) are maintained
once in `docker/common/` and included by every template that needs them.

### Version management

All shared tool versions are pinned via `ARG` directives in the common
fragments. A version bump is a one-line change in one file, applied to
all images automatically at build time.

## Common Tooling Layer

Every language image includes the following shared fragments:

- **`node-markdownlint.dockerfile`** — Node.js via NodeSource apt repo
  and markdownlint-cli via npm.
- **`github-cli.dockerfile`** — GitHub CLI via the official apt repo.
- **`validation-tools.dockerfile`** — Binary installs of shellcheck,
  shfmt, actionlint, and git-cliff.
- **`python-support.dockerfile`** — Minimal Python plus yamllint, used
  by non-Python images that still need YAML linting.
- **`standard-tooling-*.dockerfile`** — Clones and installs
  [standard-tooling](https://github.com/wphillipmoore/standard-tooling)
  for `st-*` CLI commands. The image is pinned to the rolling minor
  tag (currently `v1.3`); a `repository_dispatch` from
  `standard-tooling`'s release pipeline rebuilds the image on every
  patch release. Python-based images use the `uv` variant; others
  use `pip`.

The `dev-base` image includes all common fragments plus documentation
tooling (MkDocs Material, mike). It is the fallback image for repos
with no detected language.

## Design Principles

**Thin images** — Each image provides the language runtime, package
manager, and common tooling layer. Project-specific dependencies (from
lockfiles like `Gemfile.lock`, `uv.lock`, `go.sum`) are installed at
container startup by the consuming repository's test script.

**No repo-specific logic** — Images are general-purpose dev containers.
Any repository using the supported language can use them.

**No duplication** — Shared tooling is maintained in common fragments.
Adding a tool to all images means editing one fragment file.

## Publishing

Images are published to GitHub Container Registry on every push to
`develop` or `main` via the `docker-publish.yml` workflow. Each image is
scanned with Trivy before push and includes SLSA build provenance
attestation.

### Image namespace

Image URLs use the **user namespace** (`ghcr.io/wphillipmoore/...`), not
a repo-specific namespace. This means image paths are stable across
repository migrations — they do not change when the publishing repository
changes.

### Authentication

The workflow authenticates with `GITHUB_TOKEN` using `packages: write`
permission. No personal access token or additional secret is needed.

### GHCR package access grants

Each `dev-*` package on GHCR must explicitly grant this repository write
access. The packages were originally created by the `standard-tooling`
repository, so that repo has implicit write access. This repo does not,
unless manually configured.

Per-package setup (one-time, for each of `dev-python`, `dev-java`,
`dev-go`, `dev-ruby`, `dev-rust`, `dev-base`):

1. Navigate to the package settings page on GHCR.
2. Under **Manage Actions access**, click **Add Repository**.
3. Select `standard-tooling-docker`.
4. Set role to **Write**.

## Consumption

Images are consumed via `st-docker-run` and `st-docker-test` in
[standard-tooling](https://github.com/wphillipmoore/standard-tooling).
`st-docker-run` runs arbitrary commands inside the matching container;
`st-docker-test` auto-detects the project language and runs the test
suite. Consuming repos can override the image with the `DOCKER_DEV_IMAGE`
environment variable.
