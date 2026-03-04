# Architecture

## Build Strategy

All images are built from a single `docker/build.sh` script that iterates over
every language and version combination. Each language has its own Dockerfile
under `docker/<language>/Dockerfile`.

```
docker/
├── build.sh              # Builds all 14 images
├── python/Dockerfile
├── ruby/Dockerfile
├── go/Dockerfile
├── java/Dockerfile
└── rust/Dockerfile
```

## Common Tooling Layer

Every Dockerfile uses a multi-stage build to copy Node.js from the official
`node:22.22.0-bookworm-slim` image. This avoids installing Node.js via a
package manager and keeps images reproducible. On top of Node.js, each image
installs ShellCheck and markdownlint-cli so that all standard-tooling validators
work inside any container.

## Design Principles

**Thin images** — Each image provides the language runtime, package manager, and
common tooling layer. Project-specific dependencies (from lockfiles like
`Gemfile.lock`, `uv.lock`, `go.sum`) are installed at container startup by the
consuming repository's test script.

**No repo-specific logic** — Images are general-purpose dev containers. Any
repository using the supported language can use them.

**Multi-stage builds** — Node.js and other tools are copied from upstream images
rather than installed via `apt` or `curl`, reducing layer count and improving
reproducibility.

## Publishing

Images are published to GitHub Container Registry on every push to `develop` or
`main` via the `docker-publish.yml` workflow. Each image is scanned with Trivy
before push and includes SLSA build provenance attestation.

## Consumption

Images are consumed via the `docker-test` script in
[standard-tooling](https://github.com/wphillipmoore/standard-tooling). The
script auto-detects the project language and runs the test suite inside the
matching container. Consuming repos can override the image with the
`DOCKER_DEV_IMAGE` environment variable.
