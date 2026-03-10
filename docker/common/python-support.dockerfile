# --- Python + yamllint (for non-Python base images) -------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3-minimal python3-pip && \
    pip install --no-cache-dir --break-system-packages yamllint==1.38.0 && \
    rm -rf /var/lib/apt/lists/*
