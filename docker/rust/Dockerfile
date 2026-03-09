# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
ARG RUST_VERSION=1.93
ARG BASE_IMAGE=ghcr.io/wphillipmoore/dev-python:3.14
FROM rust:${RUST_VERSION}-slim AS rust-donor
FROM ${BASE_IMAGE}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=rust-donor /usr/local/cargo /usr/local/cargo
COPY --from=rust-donor /usr/local/rustup /usr/local/rustup
ENV CARGO_HOME="/usr/local/cargo"
ENV RUSTUP_HOME="/usr/local/rustup"
ENV PATH="/usr/local/cargo/bin:$PATH"

RUN rustup component add clippy rustfmt llvm-tools

RUN cargo install cargo-deny@0.19.0 && \
    cargo install cargo-llvm-cov@0.6.16 && \
    rm -rf /usr/local/cargo/registry

WORKDIR /workspace
