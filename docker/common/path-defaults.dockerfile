# --- Default PATH entries ----------------------------------------------------
# Static paths that should be available in all dev container images.
# ~/.local/bin: where `uv tool install` places console-script entry points.
# GitHub Actions forces HOME=/github/home in container jobs (actions/runner#863),
# so include both paths to work in CI and local Docker contexts.
ENV PATH="/github/home/.local/bin:/root/.local/bin:${PATH}"
