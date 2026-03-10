# --- standard-tooling (via uv — for Python-native base images) --------------
RUN git clone --depth 1 -b develop https://github.com/wphillipmoore/standard-tooling.git /tmp/standard-tooling \
    && uv pip install --system /tmp/standard-tooling \
    && rm -rf /tmp/standard-tooling
