# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
ARG GO_VERSION=1.25
ARG BASE_IMAGE=ghcr.io/wphillipmoore/dev-python:3.14
FROM golang:${GO_VERSION} AS go-donor
FROM ${BASE_IMAGE}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=go-donor /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:/root/go/bin:$PATH"

RUN go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.10.1 && \
    go install golang.org/x/vuln/cmd/govulncheck@v1.1.4 && \
    go install github.com/google/go-licenses/v2@v2.0.1 && \
    go install github.com/fzipp/gocyclo/cmd/gocyclo@v0.6.0 && \
    go install golang.org/x/tools/cmd/goimports@v0.42.0 && \
    go install github.com/vladopajic/go-test-coverage/v2@v2.18.3

WORKDIR /workspace
