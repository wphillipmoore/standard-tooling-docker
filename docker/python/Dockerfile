# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
ARG PYTHON_VERSION=3.14
FROM python:${PYTHON_VERSION}-slim
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# --- System packages -------------------------------------------------------
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      git curl xz-utils gnupg ca-certificates \
      shellcheck shfmt && \
    rm -rf /var/lib/apt/lists/*

# --- Node.js via NodeSource apt repo ----------------------------------------
ARG NODE_MAJOR=22
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g markdownlint-cli@0.47.0 && \
    npm cache clean --force

# --- GitHub CLI via official apt repo ---------------------------------------
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# --- actionlint (no apt package available) ----------------------------------
ARG ACTIONLINT_VERSION=1.7.11
RUN curl -fsSL "https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin/ actionlint

# --- Python tools via pip ---------------------------------------------------
RUN pip install --no-cache-dir yamllint==1.38.0 uv==0.7.12

# --- standard-tooling -------------------------------------------------------
RUN git clone --depth 1 -b develop https://github.com/wphillipmoore/standard-tooling.git /tmp/standard-tooling \
    && uv pip install --system /tmp/standard-tooling \
    && rm -rf /tmp/standard-tooling

WORKDIR /workspace
