# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
ARG PYTHON_VERSION=3.14
ARG NODE_VERSION=22.22.0
FROM node:${NODE_VERSION}-bookworm-slim AS node-donor
FROM python:${PYTHON_VERSION}-slim
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=node-donor /usr/local/bin/node /usr/local/bin/node
COPY --from=node-donor /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      git curl xz-utils && \
    rm -rf /var/lib/apt/lists/*

ARG SHELLCHECK_VERSION=0.11.0
RUN curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" \
    | tar -xJ --strip-components=1 -C /usr/local/bin/ "shellcheck-v${SHELLCHECK_VERSION}/shellcheck"

RUN npm install -g markdownlint-cli@0.47.0 && \
    npm cache clean --force

ARG SHFMT_VERSION=3.12.0
RUN curl -fsSL "https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_amd64" \
    -o /usr/local/bin/shfmt && chmod +x /usr/local/bin/shfmt

ARG ACTIONLINT_VERSION=1.7.11
RUN curl -fsSL "https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin/ actionlint

ARG TAPLO_VERSION=0.10.0
RUN curl -fsSL "https://github.com/tamasfe/taplo/releases/download/${TAPLO_VERSION}/taplo-linux-x86_64.gz" \
    | gunzip > /usr/local/bin/taplo && chmod +x /usr/local/bin/taplo

ARG GH_VERSION=2.67.0
RUN curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" \
    | tar -xz --strip-components=2 -C /usr/local/bin/ "gh_${GH_VERSION}_linux_amd64/bin/gh"

RUN pip install --no-cache-dir yamllint==1.38.0

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

RUN git clone --depth 1 -b develop https://github.com/wphillipmoore/standard-tooling.git /opt/standard-tooling \
    && uv sync --frozen --no-group dev --project /opt/standard-tooling
ENV PATH="/opt/standard-tooling/.venv/bin:$PATH"

WORKDIR /workspace
