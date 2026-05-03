# Multi-Arch (ARM64) Dev Container Images Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish multi-arch (`linux/amd64` + `linux/arm64`) dev container images so they run natively on Apple Silicon without emulation warnings.

**Architecture:** Parameterize binary tool downloads in the Dockerfile via a `TARGETARCH` case block. Restructure the CI workflow to use `docker/build-push-action` with a staging-tag scan flow (build candidate → Trivy scan both platforms → attest → promote to final tag → cleanup candidate).

**Tech Stack:** Docker buildx, `docker/build-push-action`, `docker/setup-buildx-action`, `docker/setup-qemu-action`, GHCR registry cache, Trivy

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `docker/common/validation-tools.dockerfile` | Rewrite | Architecture-aware binary tool downloads |
| `.github/workflows/docker-publish.yml` | Restructure | Multi-platform build, scan, attest, promote, cleanup |

No new files are created. No other files are modified.

---

## Task 0: Validate Prerequisites

**Files:**
- None modified — this is a validation-only task

The spec requires two prerequisites be validated before implementation begins.

- [ ] **Step 1: Verify semgrep compiles on arm64**

Run a `python:3.14-slim` container under arm64 emulation and attempt the same
install sequence used in `docker/base/Dockerfile.template`:

```bash
docker run --rm --platform linux/arm64 python:3.14-slim bash -c "
  apt-get update &&
  apt-get install -y --no-install-recommends build-essential curl &&
  pip install --no-cache-dir uv &&
  uv tool install semgrep &&
  semgrep --version
"
```

Expected: semgrep installs and prints its version. If this fails, file a
blocking issue before proceeding — the base Dockerfile needs a conditional
install path for arm64.

- [ ] **Step 2: Verify all 5 binary tool arm64 download URLs**

Check that each URL returns HTTP 200 (not 404):

```bash
curl -fsSL -o /dev/null -w "%{http_code} shellcheck\n" \
  "https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.linux.aarch64.tar.xz"

curl -fsSL -o /dev/null -w "%{http_code} shfmt\n" \
  "https://github.com/mvdan/sh/releases/download/v3.12.0/shfmt_v3.12.0_linux_arm64"

curl -fsSL -o /dev/null -w "%{http_code} actionlint\n" \
  "https://github.com/rhysd/actionlint/releases/download/v1.7.11/actionlint_1.7.11_linux_arm64.tar.gz"

curl -fsSL -o /dev/null -w "%{http_code} git-cliff\n" \
  "https://github.com/orhun/git-cliff/releases/download/v2.8.0/git-cliff-2.8.0-aarch64-unknown-linux-gnu.tar.gz"

curl -fsSL -o /dev/null -w "%{http_code} hadolint\n" \
  "https://github.com/hadolint/hadolint/releases/download/v2.14.0/hadolint-linux-arm64"
```

Expected: All 5 return `200`. If any returns 404, check the release page for
the correct artifact name and update the architecture mapping table in the spec
before proceeding.

- [ ] **Step 3: Verify Trivy action supports `platform` input**

Check whether `wphillipmoore/standard-actions/actions/security/trivy@v1.4`
accepts a `platform` input. Inspect the action's `action.yml`:

```bash
gh api repos/wphillipmoore/standard-actions/contents/actions/security/trivy/action.yml?ref=v1.4 \
  --jq '.content' | base64 -d | grep -A2 'platform'
```

If `platform` is a defined input, no changes needed. If not, determine the
correct mechanism for platform-specific scanning (e.g., `trivy-args`,
`TRIVY_PLATFORM` env var, or a direct Trivy CLI call). Update Task 3 Step 1
accordingly before proceeding.

- [ ] **Step 4: Record results**

If all checks pass, add a comment to issue #111 confirming prerequisites are
validated.

---

## Task 1: Rewrite `validation-tools.dockerfile`

**Files:**
- Modify: `docker/common/validation-tools.dockerfile`

- [ ] **Step 1: Rewrite the fragment with TARGETARCH case block**

Replace the entire contents of `docker/common/validation-tools.dockerfile` with:

```dockerfile
# --- Binary tools (architecture-aware) ---------------------------------------
ARG TARGETARCH

ARG SHELLCHECK_VERSION=0.11.0
ARG SHFMT_VERSION=3.12.0
ARG ACTIONLINT_VERSION=1.7.11
ARG GIT_CLIFF_VERSION=2.8.0
ARG HADOLINT_VERSION=2.14.0

RUN case "$TARGETARCH" in \
      amd64) \
        SC_ARCH="x86_64"; \
        SHFMT_ARCH="amd64"; \
        AL_ARCH="amd64"; \
        GC_ARCH="x86_64-unknown-linux-gnu"; \
        HL_ARCH="Linux-x86_64" ;; \
      arm64) \
        SC_ARCH="aarch64"; \
        SHFMT_ARCH="arm64"; \
        AL_ARCH="arm64"; \
        GC_ARCH="aarch64-unknown-linux-gnu"; \
        HL_ARCH="linux-arm64" ;; \
      *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.${SC_ARCH}.tar.xz" \
      | tar -xJ --strip-components=1 -C /usr/local/bin/ "shellcheck-v${SHELLCHECK_VERSION}/shellcheck" && \
    curl -fsSL "https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_${SHFMT_ARCH}" \
      -o /usr/local/bin/shfmt && chmod +x /usr/local/bin/shfmt && \
    curl -fsSL "https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_${AL_ARCH}.tar.gz" \
      | tar -xz -C /usr/local/bin/ actionlint && \
    curl -fsSL "https://github.com/orhun/git-cliff/releases/download/v${GIT_CLIFF_VERSION}/git-cliff-${GIT_CLIFF_VERSION}-${GC_ARCH}.tar.gz" \
      | tar -xz --strip-components=1 -C /usr/local/bin/ "git-cliff-${GIT_CLIFF_VERSION}/git-cliff" && \
    curl -fsSL "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-${HL_ARCH}" \
      -o /usr/local/bin/hadolint && chmod +x /usr/local/bin/hadolint
```

**Note:** The hadolint arm64 artifact name (`linux-arm64`, lowercase) was
verified 2026-05-03. All 5 tool URLs confirmed against GitHub releases.

- [ ] **Step 2: Generate Dockerfiles and lint**

```bash
docker/generate.sh
hadolint docker/*/Dockerfile
```

Expected: All Dockerfiles pass hadolint with no errors. (The single large `RUN`
layer may trigger DL3059 — if so, that's a pre-existing ignore or false positive;
the consolidation is intentional.)

- [ ] **Step 3: Test amd64 build locally**

```bash
docker build --build-arg PYTHON_VERSION=3.14 -t dev-python:3.14-test docker/python/
docker run --rm dev-python:3.14-test shellcheck --version
docker run --rm dev-python:3.14-test shfmt --version
docker run --rm dev-python:3.14-test actionlint --version
docker run --rm dev-python:3.14-test git-cliff --version
docker run --rm dev-python:3.14-test hadolint --version
```

Expected: All 5 tools print their version. This confirms the amd64 path works
(plain `docker build` defaults to the host arch — amd64 on Intel, arm64 on
Apple Silicon).

- [ ] **Step 4: Test arm64 build via buildx**

Set up a local buildx builder if not already present, then build for arm64:

```bash
docker buildx create --name multiarch --use 2>/dev/null || docker buildx use multiarch
docker buildx build \
  --platform linux/arm64 \
  --build-arg PYTHON_VERSION=3.14 \
  --load \
  -t dev-python:3.14-arm64-test \
  docker/python/
docker run --rm dev-python:3.14-arm64-test shellcheck --version
docker run --rm dev-python:3.14-arm64-test shfmt --version
docker run --rm dev-python:3.14-arm64-test actionlint --version
docker run --rm dev-python:3.14-arm64-test git-cliff --version
docker run --rm dev-python:3.14-arm64-test hadolint --version
```

Expected: All 5 tools print their version under arm64. On Apple Silicon this
is native; on Intel it runs under QEMU (slower but should work).

- [ ] **Step 5: Commit**

```bash
git add docker/common/validation-tools.dockerfile
git commit -m "feat(images): make binary tool downloads architecture-aware

Use TARGETARCH case block to select correct download URLs for
shellcheck, shfmt, actionlint, git-cliff, and hadolint on both
amd64 and arm64 platforms.

Refs: #111"
```

---

## Task 2: Restructure CI Workflow — Build and Push Candidate

**Files:**
- Modify: `.github/workflows/docker-publish.yml`

This task and the next two restructure the CI workflow. They are split for
reviewability but form one logical change. Only the final task (Task 4) gets
committed.

- [ ] **Step 1: Add QEMU and buildx setup steps to `build-scan-push` job**

In the `build-scan-push` job, after the "Generate Dockerfile from template"
step and before "Log in to GHCR", add:

```yaml
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
```

- [ ] **Step 2: Replace `docker build` with `docker/build-push-action`**

Remove the existing "Build image" step. Replace it with:

```yaml
      - name: Build and push candidate
        uses: docker/build-push-action@v6
        with:
          context: docker/${{ matrix.language }}
          platforms: linux/amd64,linux/arm64
          build-args: ${{ matrix.build-arg }}=${{ matrix.version }}
          tags: ghcr.io/wphillipmoore/dev-${{ matrix.language }}:${{ matrix.version }}-candidate
          cache-from: type=registry,ref=ghcr.io/wphillipmoore/dev-${{ matrix.language }}:cache-${{ matrix.version }}
          cache-to: type=registry,ref=ghcr.io/wphillipmoore/dev-${{ matrix.language }}:cache-${{ matrix.version }},mode=max
          push: true
```

- [ ] **Step 3: Update env block**

Replace the existing `env` block in the `build-scan-push` job:

```yaml
    env:
      IMAGE: "ghcr.io/wphillipmoore/dev-${{ matrix.language }}:${{ matrix.version }}"
      CANDIDATE: "ghcr.io/wphillipmoore/dev-${{ matrix.language }}:${{ matrix.version }}-candidate"
```

Both are now registry references (not local-only tags).

---

## Task 3: Restructure CI Workflow — Scan, Attest, Promote, Cleanup

**Files:**
- Modify: `.github/workflows/docker-publish.yml` (continuing from Task 2)

- [ ] **Step 1: Replace Trivy step with dual-platform scans**

Remove the existing Trivy step. Add two scan steps:

```yaml
      - name: Trivy scan (amd64)
        uses: wphillipmoore/standard-actions/actions/security/trivy@v1.4
        with:
          scan-type: image
          scan-ref: ${{ env.CANDIDATE }}
          exit-code: "1"
          sarif-category: "trivy-image-${{ matrix.language }}-${{ matrix.version }}-amd64"
          trivyignores: .trivyignore
          platform: linux/amd64

      - name: Trivy scan (arm64)
        uses: wphillipmoore/standard-actions/actions/security/trivy@v1.4
        with:
          scan-type: image
          scan-ref: ${{ env.CANDIDATE }}
          exit-code: "1"
          sarif-category: "trivy-image-${{ matrix.language }}-${{ matrix.version }}-arm64"
          trivyignores: .trivyignore
          platform: linux/arm64
```

**Note:** The `platform` input tells Trivy which manifest entry to scan. Verify
that `wphillipmoore/standard-actions/actions/security/trivy@v1.4` supports the
`platform` input. If not, pass it via `trivy-args: --platform linux/arm64` or
equivalent — check the action's interface.

- [ ] **Step 2: Add attestation step (before promotion)**

Replace the existing "Get image digest" and "Attest build provenance" steps with:

```yaml
      - name: Get candidate digest
        id: digest
        run: |
          DIGEST=$(docker buildx imagetools inspect "$CANDIDATE" --format '{{.Manifest.Digest}}')
          echo "digest=$DIGEST" >> "$GITHUB_OUTPUT"

      - name: Attest build provenance
        uses: actions/attest-build-provenance@v4
        with:
          subject-name: "ghcr.io/wphillipmoore/dev-${{ matrix.language }}"
          subject-digest: ${{ steps.digest.outputs.digest }}
```

- [ ] **Step 3: Add promote step**

After attestation, add the promotion step that re-tags candidate → final:

```yaml
      - name: Promote candidate to final tag
        run: |
          docker buildx imagetools create \
            --tag "$IMAGE" \
            "$CANDIDATE"
```

- [ ] **Step 4: Add digest verification step**

After promotion, verify the final tag has the same digest as the candidate:

```yaml
      - name: Verify digest preservation
        run: |
          FINAL_DIGEST=$(docker buildx imagetools inspect "$IMAGE" --format '{{.Manifest.Digest}}')
          if [ "$FINAL_DIGEST" != "${{ steps.digest.outputs.digest }}" ]; then
            echo "ERROR: Final tag digest ($FINAL_DIGEST) does not match candidate (${{ steps.digest.outputs.digest }})" >&2
            exit 1
          fi
```

- [ ] **Step 5: Add candidate cleanup step**

After the digest verification, add the cleanup step. This runs regardless of
job success/failure (`if: always()`):

```yaml
      - name: Delete candidate tag
        if: always()
        continue-on-error: true
        run: |
          VERSION_ID=$(gh api \
            "/user/packages/container/dev-${{ matrix.language }}/versions" \
            --jq '.[] | select(.metadata.container.tags[] == "${{ matrix.version }}-candidate") | .id')
          if [ -n "$VERSION_ID" ]; then
            gh api --method DELETE \
              "/user/packages/container/dev-${{ matrix.language }}/versions/$VERSION_ID"
          fi
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] **Step 6: Remove the old "Tag and push image" step**

Delete the existing step that did `docker tag "$CANDIDATE" "$IMAGE"` and
`docker push "$IMAGE"` — this is now handled by the promote step.

---

## Task 4: Restructure CI Workflow — `publish-base` Job

**Files:**
- Modify: `.github/workflows/docker-publish.yml` (continuing from Task 3)

- [ ] **Step 1: Apply the same restructuring to `publish-base`**

Update the `publish-base` job to match the same pattern. Update its `env` block:

```yaml
    env:
      IMAGE: ghcr.io/wphillipmoore/dev-base:latest
      CANDIDATE: ghcr.io/wphillipmoore/dev-base:latest-candidate
```

Replace its steps with the same sequence:

```yaml
    steps:
      - name: Checkout code
        uses: actions/checkout@v6

      - name: Generate Dockerfile from template
        run: docker/generate.sh base

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GHCR
        uses: docker/login-action@v4
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push candidate
        uses: docker/build-push-action@v6
        with:
          context: docker/base
          platforms: linux/amd64,linux/arm64
          tags: ${{ env.CANDIDATE }}
          cache-from: type=registry,ref=ghcr.io/wphillipmoore/dev-base:cache
          cache-to: type=registry,ref=ghcr.io/wphillipmoore/dev-base:cache,mode=max
          push: true

      - name: Trivy scan (amd64)
        uses: wphillipmoore/standard-actions/actions/security/trivy@v1.4
        with:
          scan-type: image
          scan-ref: ${{ env.CANDIDATE }}
          exit-code: "1"
          sarif-category: trivy-image-base-amd64
          trivyignores: .trivyignore
          platform: linux/amd64

      - name: Trivy scan (arm64)
        uses: wphillipmoore/standard-actions/actions/security/trivy@v1.4
        with:
          scan-type: image
          scan-ref: ${{ env.CANDIDATE }}
          exit-code: "1"
          sarif-category: trivy-image-base-arm64
          trivyignores: .trivyignore
          platform: linux/arm64

      - name: Get candidate digest
        id: digest
        run: |
          DIGEST=$(docker buildx imagetools inspect "$CANDIDATE" --format '{{.Manifest.Digest}}')
          echo "digest=$DIGEST" >> "$GITHUB_OUTPUT"

      - name: Attest build provenance
        uses: actions/attest-build-provenance@v4
        with:
          subject-name: ghcr.io/wphillipmoore/dev-base
          subject-digest: ${{ steps.digest.outputs.digest }}

      - name: Promote candidate to final tag
        run: |
          docker buildx imagetools create \
            --tag "$IMAGE" \
            "$CANDIDATE"

      - name: Verify digest preservation
        run: |
          FINAL_DIGEST=$(docker buildx imagetools inspect "$IMAGE" --format '{{.Manifest.Digest}}')
          if [ "$FINAL_DIGEST" != "${{ steps.digest.outputs.digest }}" ]; then
            echo "ERROR: Final tag digest ($FINAL_DIGEST) does not match candidate (${{ steps.digest.outputs.digest }})" >&2
            exit 1
          fi

      - name: Delete candidate tag
        if: always()
        continue-on-error: true
        run: |
          VERSION_ID=$(gh api \
            "/user/packages/container/dev-base/versions" \
            --jq '.[] | select(.metadata.container.tags[] == "latest-candidate") | .id')
          if [ -n "$VERSION_ID" ]; then
            gh api --method DELETE \
              "/user/packages/container/dev-base/versions/$VERSION_ID"
          fi
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] **Step 2: Validate workflow YAML syntax**

```bash
actionlint .github/workflows/docker-publish.yml
```

Expected: No errors. If actionlint flags unknown action inputs (e.g., the
`platform` input on the Trivy action), suppress with an inline comment if
confirmed valid.

- [ ] **Step 3: Commit the complete workflow restructure**

```bash
git add .github/workflows/docker-publish.yml
git commit -m "feat(ci): multi-arch build with staging-tag scan flow

Switch docker-publish workflow to docker/build-push-action with
linux/amd64 + linux/arm64 platforms. Add QEMU for cross-platform
emulation on amd64 runners.

New flow: build candidate → Trivy scan both platforms → attest →
promote to final tag → cleanup candidate. Registry-based layer
cache for build time mitigation.

Refs: #111"
```

---

## Task 5: End-to-End Validation

**Files:**
- None modified — this is a validation-only task

- [ ] **Step 1: Push branch and trigger workflow**

Push the feature branch and manually trigger the workflow via `workflow_dispatch`
(or open a PR to `develop` to trigger automatically):

```bash
git push -u origin feature/111-multi-arch-images
gh workflow run "Publish dev container images" --ref feature/111-multi-arch-images
```

- [ ] **Step 2: Monitor workflow execution**

Watch the Actions tab. Confirm:
- QEMU and buildx setup steps succeed
- Build pushes to `-candidate` tags for both platforms
- Both Trivy scans (amd64 and arm64) pass
- Attestation succeeds on candidate digest
- Promotion creates the final tag
- Digest verification passes
- Candidate tag is deleted from GHCR

- [ ] **Step 3: Verify published images are multi-arch**

After the workflow completes, inspect a published image:

```bash
docker buildx imagetools inspect ghcr.io/wphillipmoore/dev-python:3.14
```

Expected output should show a manifest list with two platform entries:
`linux/amd64` and `linux/arm64`.

- [ ] **Step 4: Verify native pull on Apple Silicon**

On an Apple Silicon Mac, pull and run without the emulation warning:

```bash
docker pull ghcr.io/wphillipmoore/dev-python:3.14
docker run --rm ghcr.io/wphillipmoore/dev-python:3.14 uname -m
```

Expected: No platform mismatch warning. `uname -m` prints `aarch64`.

- [ ] **Step 5: Close issue**

```bash
gh issue close 111 --comment "Multi-arch images (amd64 + arm64) now publishing. Verified native arm64 pull on Apple Silicon."
```
