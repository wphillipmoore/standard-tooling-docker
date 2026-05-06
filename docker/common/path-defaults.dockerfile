# --- Default PATH entries ----------------------------------------------------
# Static paths that should be available in all dev container images.
# /workspace/.venv/bin: where `uv sync` places console-script entry points.
# ~/.local/bin: where `uv tool install` places console-script entry points.
# GitHub Actions forces HOME=/github/home in container jobs (actions/runner#863),
# so include both paths to work in CI and local Docker contexts.
ENV PATH="/workspace/.venv/bin:/github/home/.local/bin:/root/.local/bin:${PATH}"
