# --- standard-tooling (via pip — for non-Python base images) ----------------
RUN git clone --depth 1 -b develop https://github.com/wphillipmoore/standard-tooling.git /tmp/standard-tooling && \
    pip install --no-cache-dir --break-system-packages /tmp/standard-tooling && \
    rm -rf /tmp/standard-tooling
