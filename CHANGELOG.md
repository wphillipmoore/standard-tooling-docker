# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/)
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Initial repository created by migrating Docker dev container images from
  [standard-tooling](https://github.com/wphillipmoore/standard-tooling).
- Dockerfiles for Python, Java, Go, Ruby, and Rust dev containers.
- `docker/build.sh` for local image builds.
- `docker-publish.yml` workflow for GHCR publishing.
- `ci.yml` workflow for PR validation (Hadolint, ShellCheck, Markdownlint).
- Rust images (1.92, 1.93) added to CI publish matrix.
