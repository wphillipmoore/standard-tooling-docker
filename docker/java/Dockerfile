# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
ARG JDK_VERSION=21
ARG BASE_IMAGE=ghcr.io/wphillipmoore/dev-python:3.14
FROM eclipse-temurin:${JDK_VERSION}-jdk AS jdk-donor
FROM ${BASE_IMAGE}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=jdk-donor /opt/java /opt/java
ENV JAVA_HOME="/opt/java/openjdk"
ENV PATH="${JAVA_HOME}/bin:$PATH"

# Maven wrapper self-bootstraps from consuming repos.

WORKDIR /workspace
