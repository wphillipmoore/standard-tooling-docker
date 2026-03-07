# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
# dev-docs — MkDocs Material + mike for documentation preview and build.
FROM python:3.14-slim
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

ARG MKDOCS_MATERIAL_VERSION=9.6.12
ARG MIKE_VERSION=2.1.3
RUN pip install --no-cache-dir \
      "mkdocs-material==${MKDOCS_MATERIAL_VERSION}" \
      "mike==${MIKE_VERSION}"

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

RUN git clone --depth 1 -b develop https://github.com/wphillipmoore/standard-tooling.git /opt/standard-tooling \
    && cd /opt/standard-tooling && uv sync --frozen --no-group dev
ENV PATH="/opt/standard-tooling/.venv/bin:$PATH"

EXPOSE 8000

WORKDIR /workspace
