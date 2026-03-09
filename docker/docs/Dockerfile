# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
# dev-docs — MkDocs Material + mike for documentation preview and build.
ARG BASE_IMAGE=ghcr.io/wphillipmoore/dev-python:3.14
FROM ${BASE_IMAGE}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG MKDOCS_MATERIAL_VERSION=9.6.12
ARG MIKE_VERSION=2.1.3
RUN pip install --no-cache-dir \
      "mkdocs-material==${MKDOCS_MATERIAL_VERSION}" \
      "mike==${MIKE_VERSION}"

EXPOSE 8000

WORKDIR /workspace
