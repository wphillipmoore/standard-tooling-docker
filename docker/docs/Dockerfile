# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
# dev-docs — MkDocs Material + mike for documentation preview and build.
FROM python:3.14-slim
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# --- System packages ---------------------------------------------------------
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      git curl gnupg ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# --- Node.js via NodeSource apt repo -----------------------------------------
ARG NODE_MAJOR=22
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g markdownlint-cli@0.47.0 && \
    npm cache clean --force

# --- GitHub CLI via official apt repo ----------------------------------------
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# --- MkDocs ------------------------------------------------------------------
ARG MKDOCS_MATERIAL_VERSION=9.6.12
ARG MIKE_VERSION=2.1.3
RUN pip install --no-cache-dir \
      "mkdocs-material==${MKDOCS_MATERIAL_VERSION}" \
      "mike==${MIKE_VERSION}" \
      uv==0.7.12

# --- standard-tooling --------------------------------------------------------
RUN git clone --depth 1 -b develop https://github.com/wphillipmoore/standard-tooling.git /tmp/standard-tooling \
    && uv pip install --system /tmp/standard-tooling \
    && rm -rf /tmp/standard-tooling

EXPOSE 8000

WORKDIR /workspace
