# Images

Every image shares a common tooling layer and adds language-specific runtimes
and tools. Images are published to
`ghcr.io/wphillipmoore/dev-<language>:<version>`.

## Common Layer

All images include:

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 22.22.0 | Runtime for markdownlint-cli |
| ShellCheck | 0.11.0 | Shell script linting |
| markdownlint-cli | 0.47.0 | Markdown linting |
| git | latest | Repository operations |
| curl | latest | HTTP requests |

## Python

**Base**: `python:<version>-slim`
**Versions**: 3.12, 3.13, 3.14

| Tool | Source | Purpose |
|------|--------|---------|
| uv | `ghcr.io/astral-sh/uv:latest` | Python package manager |

## Ruby

**Base**: `ruby:<version>-slim`
**Versions**: 3.2, 3.3, 3.4

| Tool | Source | Purpose |
|------|--------|---------|
| bundler | system gem | Ruby dependency manager |

## Go

**Base**: `golang:<version>`
**Versions**: 1.25, 1.26

| Tool | Version | Purpose |
|------|---------|---------|
| golangci-lint | 2.10.1 | Go linter aggregator |
| govulncheck | 1.1.4 | Vulnerability scanner |
| go-licenses | 2.0.1 | License checker |
| gocyclo | 0.6.0 | Cyclomatic complexity |

## Java

**Base**: `eclipse-temurin:<version>-jdk`
**Versions**: 17, 21

Java images rely on the consuming repository's Maven wrapper (`mvnw`) to
bootstrap Maven at container startup. No additional Java-specific tools are
pre-installed.

## Rust

**Base**: `rust:<version>-slim`
**Versions**: 1.92, 1.93

| Tool | Version | Purpose |
|------|---------|---------|
| clippy | rustup component | Rust linter |
| rustfmt | rustup component | Code formatter |
| llvm-tools | rustup component | Coverage instrumentation |
| cargo-deny | 0.18.2 | Dependency security checker |
| cargo-llvm-cov | 0.6.16 | Code coverage |
