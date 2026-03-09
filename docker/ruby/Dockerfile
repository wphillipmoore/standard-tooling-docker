# Managed by standard-tooling-docker — DO NOT EDIT in downstream repos.
# Canonical source: https://github.com/wphillipmoore/standard-tooling-docker
ARG RUBY_VERSION=3.4
ARG BASE_IMAGE=ghcr.io/wphillipmoore/dev-python:3.14
FROM ruby:${RUBY_VERSION}-slim AS ruby-donor
FROM ${BASE_IMAGE}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Ruby runtime shared library dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential libyaml-dev libffi-dev libgmp-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=ruby-donor /usr/local/bin/ruby /usr/local/bin/
COPY --from=ruby-donor /usr/local/bin/gem /usr/local/bin/
COPY --from=ruby-donor /usr/local/bin/bundle /usr/local/bin/
COPY --from=ruby-donor /usr/local/bin/bundler /usr/local/bin/
COPY --from=ruby-donor /usr/local/bin/irb /usr/local/bin/
COPY --from=ruby-donor /usr/local/bin/erb /usr/local/bin/
COPY --from=ruby-donor /usr/local/lib/ruby /usr/local/lib/ruby
COPY --from=ruby-donor /usr/local/lib/libruby* /usr/local/lib/
COPY --from=ruby-donor /usr/local/include/ruby* /usr/local/include/

RUN ldconfig

RUN gem install bundler

WORKDIR /workspace
