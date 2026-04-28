# --- standard-tooling (via uv — for Python-native base images) --------------
# Pinned to the rolling minor tag (`v1.4`), force-updated by
# standard-actions' `tag-and-release` on every patch release. This image
# rebuilds via .github/workflows/docker-publish.yml's
# `repository_dispatch:[standard-tooling-released]` trigger on each
# standard-tooling release, so each new image carries the freshly-
# released version. See
# wphillipmoore/standard-tooling/docs/specs/host-level-tool.md
# "Dev container image policy" and standard-tooling-docker#51.
ARG ST_TOOLING_TAG=v1.4
RUN uv pip install --system \
    "standard-tooling @ git+https://github.com/wphillipmoore/standard-tooling@${ST_TOOLING_TAG}"
