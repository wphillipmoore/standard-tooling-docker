#!/usr/bin/env bash
# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
# build.sh — build all dev container images with default version tags.
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"

build() {
  local lang="$1" version_arg="$2" version_val="$3"
  echo "Building dev-${lang}:${version_val} ..."
  docker build \
    --build-arg "${version_arg}=${version_val}" \
    -t "dev-${lang}:${version_val}" \
    "${script_dir}/${lang}"
}

build python PYTHON_VERSION 3.12
build python PYTHON_VERSION 3.13
build python PYTHON_VERSION 3.14
build ruby   RUBY_VERSION   3.2
build ruby   RUBY_VERSION   3.3
build ruby   RUBY_VERSION   3.4
build java   JDK_VERSION    17
build java   JDK_VERSION    21
build go     GO_VERSION     1.25
build go     GO_VERSION     1.26
build rust   RUST_VERSION   1.92
build rust   RUST_VERSION   1.93

echo "Building dev-docs:latest ..."
docker build -t "dev-docs:latest" "${script_dir}/docs"

echo "All images built successfully."
