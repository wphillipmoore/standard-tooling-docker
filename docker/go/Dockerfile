# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
ARG GO_VERSION=1.25
FROM golang:${GO_VERSION}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# --- System packages ---------------------------------------------------------
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      git xz-utils gnupg ca-certificates && \
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

# --- Binary tools (no apt packages available) --------------------------------
ARG SHELLCHECK_VERSION=0.11.0
RUN curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" \
    | tar -xJ --strip-components=1 -C /usr/local/bin/ "shellcheck-v${SHELLCHECK_VERSION}/shellcheck"

ARG SHFMT_VERSION=3.12.0
RUN curl -fsSL "https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_amd64" \
    -o /usr/local/bin/shfmt && chmod +x /usr/local/bin/shfmt

ARG ACTIONLINT_VERSION=1.7.11
RUN curl -fsSL "https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin/ actionlint

# --- Python + yamllint -------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3-minimal python3-pip && \
    pip install --no-cache-dir --break-system-packages yamllint==1.38.0 && \
    rm -rf /var/lib/apt/lists/*

# --- Go tools ----------------------------------------------------------------
RUN go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.10.1 && \
    go install golang.org/x/vuln/cmd/govulncheck@v1.1.4 && \
    go install github.com/google/go-licenses/v2@v2.0.1 && \
    go install github.com/fzipp/gocyclo/cmd/gocyclo@v0.6.0 && \
    go install golang.org/x/tools/cmd/goimports@v0.42.0 && \
    go install github.com/vladopajic/go-test-coverage/v2@v2.18.3

# --- standard-tooling --------------------------------------------------------
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
RUN uv python install 3.14

RUN git clone --depth 1 -b develop https://github.com/wphillipmoore/standard-tooling.git /opt/standard-tooling \
    && uv sync --frozen --no-group dev --python 3.14 --project /opt/standard-tooling
ENV PATH="/opt/standard-tooling/.venv/bin:$PATH"

WORKDIR /workspace
