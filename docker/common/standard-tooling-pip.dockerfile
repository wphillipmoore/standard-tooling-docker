# --- standard-tooling (via pip — for non-Python base images) ----------------
# Pinned to the rolling minor tag (`v1.3`), force-updated by
# standard-actions' `tag-and-release` on every patch release. This image
# rebuilds via .github/workflows/docker-publish.yml's
# `repository_dispatch:[standard-tooling-released]` trigger on each
# standard-tooling release, so each new image carries the freshly-
# released version. Mirrors standard-tooling-uv.dockerfile's pin so the
# Python and non-Python images stay on the same release boundary. Issues
# #51 and #72.
ARG ST_TOOLING_TAG=v1.3
RUN git clone --depth 1 -b ${ST_TOOLING_TAG} https://github.com/wphillipmoore/standard-tooling.git /tmp/standard-tooling && \
    pip install --no-cache-dir --break-system-packages /tmp/standard-tooling && \
    rm -rf /tmp/standard-tooling
