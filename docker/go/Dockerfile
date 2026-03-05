# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
ARG GO_VERSION=1.25
ARG NODE_VERSION=22.22.0
FROM node:${NODE_VERSION}-bookworm-slim AS node-donor
FROM golang:${GO_VERSION}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=node-donor /usr/local/bin/node /usr/local/bin/node
COPY --from=node-donor /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      xz-utils && \
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

RUN apt-get update && apt-get install -y --no-install-recommends python3-minimal python3-pip \
    && pip install --no-cache-dir --break-system-packages yamllint==1.38.0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.10.1 && \
    go install golang.org/x/vuln/cmd/govulncheck@v1.1.4 && \
    go install github.com/google/go-licenses/v2@v2.0.1 && \
    go install github.com/fzipp/gocyclo/cmd/gocyclo@v0.6.0 && \
    go install golang.org/x/tools/cmd/goimports@v0.42.0 && \
    go install github.com/vladopajic/go-test-coverage/v2@v2.18.3

WORKDIR /workspace
