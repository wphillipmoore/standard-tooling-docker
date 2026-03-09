#!/usr/bin/env bash
# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
# build.sh — build all dev container images with default version tags.
#
# Phase 1: Python 3.14 (base image for all non-Python images)
# Phase 2: Remaining Python versions + all non-Python images
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"

build() {
  local lang="$1" version_arg="$2" version_val="$3"
  shift 3
  echo "Building dev-${lang}:${version_val} ..."
  docker build \
    --build-arg "${version_arg}=${version_val}" \
    "$@" \
    -t "dev-${lang}:${version_val}" \
    "${script_dir}/${lang}"
}

# --- Phase 1: Python 3.14 (base for all non-Python images) -------------------
build python PYTHON_VERSION 3.14

BASE_IMAGE="dev-python:3.14"

# --- Phase 2: Remaining images -----------------------------------------------
build python PYTHON_VERSION 3.12
build python PYTHON_VERSION 3.13
build ruby   RUBY_VERSION   3.2   --build-arg "BASE_IMAGE=${BASE_IMAGE}"
build ruby   RUBY_VERSION   3.3   --build-arg "BASE_IMAGE=${BASE_IMAGE}"
build ruby   RUBY_VERSION   3.4   --build-arg "BASE_IMAGE=${BASE_IMAGE}"
build java   JDK_VERSION    17    --build-arg "BASE_IMAGE=${BASE_IMAGE}"
build java   JDK_VERSION    21    --build-arg "BASE_IMAGE=${BASE_IMAGE}"
build go     GO_VERSION     1.25  --build-arg "BASE_IMAGE=${BASE_IMAGE}"
build go     GO_VERSION     1.26  --build-arg "BASE_IMAGE=${BASE_IMAGE}"
build rust   RUST_VERSION   1.92  --build-arg "BASE_IMAGE=${BASE_IMAGE}"
build rust   RUST_VERSION   1.93  --build-arg "BASE_IMAGE=${BASE_IMAGE}"

echo "Building dev-docs:latest ..."
docker build --build-arg "BASE_IMAGE=${BASE_IMAGE}" -t "dev-docs:latest" "${script_dir}/docs"

echo "All images built successfully."
