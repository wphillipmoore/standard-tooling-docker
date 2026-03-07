# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
# dev-docs — MkDocs Material + mike for documentation preview and build.
ARG NODE_VERSION=22.22.0
FROM node:${NODE_VERSION}-bookworm-slim AS node-donor
FROM python:3.14-slim
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=node-donor /usr/local/bin/node /usr/local/bin/node
COPY --from=node-donor /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g markdownlint-cli@0.47.0 && \
    npm cache clean --force

ARG MKDOCS_MATERIAL_VERSION=9.6.12
ARG MIKE_VERSION=2.1.3
RUN pip install --no-cache-dir \
      "mkdocs-material==${MKDOCS_MATERIAL_VERSION}" \
      "mike==${MIKE_VERSION}"

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

RUN git clone --depth 1 -b develop https://github.com/wphillipmoore/standard-tooling.git /opt/standard-tooling \
    && uv sync --frozen --no-group dev --project /opt/standard-tooling
ENV PATH="/opt/standard-tooling/.venv/bin:$PATH"

EXPOSE 8000

WORKDIR /workspace
