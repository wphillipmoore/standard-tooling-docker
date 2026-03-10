# Images

Every image shares a common tooling layer and adds language-specific
runtimes and tools. Images are published to
`ghcr.io/wphillipmoore/dev-<language>:<version>`.

## Common Layer

All language images include:

| Tool             | Version | Purpose                        |
| ---------------- | ------- | ------------------------------ |
| Node.js          | 22      | Runtime for markdownlint-cli   |
| markdownlint-cli | 0.47.0  | Markdown linting               |
| gh (GitHub CLI)  | latest  | GitHub API and workflows       |
| shellcheck       | 0.11.0  | Shell script linting           |
| shfmt            | 3.12.0  | Shell script formatting        |
| actionlint       | 1.7.11  | GitHub Actions linting         |
| git-cliff        | 2.8.0   | Changelog generation           |
| standard-tooling | develop | `st-*` CLI commands            |
| git              | latest  | Repository operations          |
| curl             | latest  | HTTP requests                  |

The `dev-docs` image includes Node.js, markdownlint-cli, gh, git,
standard-tooling, and curl but omits the validation tools (shellcheck,
shfmt, actionlint, git-cliff).

Images that include Python (dev-python, dev-docs) also have:

| Tool     | Version | Purpose         |
| -------- | ------- | --------------- |
| yamllint | 1.38.0  | YAML linting    |
| uv       | 0.7.12  | Package manager |

Non-Python images that need YAML linting install Python and yamllint via
the `python-support` fragment.

## Python

**Base**: `python:<version>-slim`
**Versions**: 3.12, 3.13, 3.14

| Tool | Version | Purpose                |
| ---- | ------- | ---------------------- |
| uv   | 0.7.12  | Python package manager |

## Ruby

**Base**: `ruby:<version>-slim`
**Versions**: 3.2, 3.3, 3.4

| Tool    | Source     | Purpose                 |
| ------- | ---------- | ----------------------- |
| bundler | system gem | Ruby dependency manager |

## Go

**Base**: `golang:<version>`
**Versions**: 1.25, 1.26

| Tool          | Version | Purpose               |
| ------------- | ------- | --------------------- |
| golangci-lint | 2.10.1  | Go linter aggregator  |
| govulncheck   | 1.1.4   | Vulnerability scanner |
| go-licenses   | 2.0.1   | License checker       |
| gocyclo       | 0.6.0   | Cyclomatic complexity |

## Java

**Base**: `eclipse-temurin:<version>-jdk`
**Versions**: 17, 21

Java images rely on the consuming repository's Maven wrapper (`mvnw`) to
bootstrap Maven at container startup. No additional Java-specific tools
are pre-installed.

## Rust

**Base**: `rust:<version>-slim`
**Versions**: 1.92, 1.93

| Tool           | Version          | Purpose                     |
| -------------- | ---------------- | --------------------------- |
| clippy         | rustup component | Rust linter                 |
| rustfmt        | rustup component | Code formatter              |
| llvm-tools     | rustup component | Coverage instrumentation    |
| cargo-deny     | 0.18.2           | Dependency security checker |
| cargo-llvm-cov | 0.6.16           | Code coverage               |

## Docs

**Base**: `python:3.14-slim`
**Version**: latest

| Tool             | Version | Purpose                    |
| ---------------- | ------- | -------------------------- |
| MkDocs Material  | 9.6.12  | Documentation site builder |
| mike             | 2.1.3   | Versioned doc deployment   |
| uv               | 0.7.12  | Package manager            |
