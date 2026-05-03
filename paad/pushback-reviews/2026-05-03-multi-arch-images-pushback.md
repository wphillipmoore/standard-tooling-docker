# Pushback Review: Multi-Arch (ARM64) Dev Container Images

**Date:** 2026-05-03
**Spec:** `docs/specs/2026-05-03-multi-arch-images-design.md`
**Commit:** a3d656217eaa248147c64ec59500e04deed34082

## Source Control Conflicts

None — no conflicts with recent changes. The two files in scope
(`validation-tools.dockerfile`, `docker-publish.yml`) match what the spec
assumes. PR #109 (semgrep bake, 2026-05-01) is relevant but not a conflict —
surfaced as a feasibility concern below.

## Issues Reviewed

### [1] QEMU setup missing from CI workflow
- **Category:** Omission
- **Severity:** Critical
- **Issue:** The workflow steps included `docker/setup-buildx-action` but not
  `docker/setup-qemu-action`. Building `linux/arm64` on GitHub's amd64
  runners requires QEMU userspace emulation, which buildx does not install
  on its own. Arm64 builds would fail immediately.
- **Resolution:** Add `docker/setup-qemu-action` as a step before buildx
  setup. Spec updated.

### [2] Semgrep ARM64 compilation not validated
- **Category:** Feasibility
- **Severity:** Serious
- **Issue:** `docker/base/Dockerfile.template` installs semgrep via
  `uv tool install` with `build-essential` for native compilation of
  `semgrep-core` (OCaml). The spec's "Unchanged" list did not acknowledge
  this dependency or validate it works on arm64 under QEMU.
- **Resolution:** Added as a prerequisite — validate semgrep arm64
  compilation before implementation. If it fails, the base Dockerfile
  needs a conditional. Spec updated.

### [3] Tool binary naming unverified
- **Category:** Feasibility
- **Severity:** Serious
- **Issue:** The architecture mapping table listed arm64 artifact names that
  may not match actual GitHub release naming conventions (e.g., hadolint
  uses `Linux-x86_64` for amd64 — the arm64 name may be `Linux-arm64`,
  not `linux-arm64`). Incorrect names cause 404 download failures.
- **Resolution:** Added as a prerequisite — verify all 5 tool URLs against
  actual release pages. Table marked as preliminary. Spec updated.

### [4] Trivy scans amd64 only
- **Category:** Omission
- **Severity:** Moderate
- **Issue:** Trivy on an amd64 runner scanning a multi-arch manifest only
  scans the amd64 layers. Arm64 layers (potentially different apt package
  builds) go unscanned.
- **Resolution:** Add a second Trivy scan step with `--platform linux/arm64`
  for each matrix entry. Spec updated.

### [5] Attestation race condition
- **Category:** Ambiguity
- **Severity:** Moderate
- **Issue:** The original flow promoted the candidate to the final tag
  before attesting. This creates a window where the final tag is live
  without attestation.
- **Resolution:** Attest the candidate manifest digest before promotion.
  Since `imagetools create` re-tags without changing the digest, the
  attestation remains valid on the final tag. Added a digest verification
  step after promotion as a safety check. Spec updated.

### [6] Stale cache tags accumulate
- **Category:** Omission
- **Severity:** Minor
- **Issue:** Persistent `cache-{version}` tags in GHCR are never cleaned up
  when versions are retired from the matrix.
- **Resolution:** Noted as a known limitation in the spec. Separate issue
  #125 filed for a periodic audit mechanism.

## Unresolved Issues

None — all issues addressed.

## Summary

- **Issues found:** 6
- **Issues resolved:** 6
- **Unresolved:** 0
- **Spec status:** Ready for implementation (pending prerequisites validation)
