# Pushback Review: Release Workflow, Image Naming Convention, and Nightly Rebuilds

**Date:** 2026-05-09
**Spec:** docs/superpowers/specs/2026-05-09-release-workflow-and-image-naming-design.md
**Commit:** 51df9b0

## Source Control Conflicts

One minor conflict: cd.yml was created by #172 (f355426, 2026-05-09) as
a thin shim calling cd-docs only. The spec originally described
"rewriting" cd.yml — updated to "extend" to reflect the actual starting
point.

No other conflicts with recent changes.

## Scope Assessment

**Cohesion:** The three bundled features (naming convention, release
workflow, nightly rebuilds) are genuinely interdependent. No split
recommended.

**Size:** Large spec touching 4 workflow files, 2 external repos, and
all consuming repos. The interdependencies make splitting impractical,
and the migration sequence is already phased.

## Issues Reviewed

### [1] Base image has no path through cd-docker-publish.yml
- **Category:** omissions
- **Severity:** critical
- **Issue:** The spec described cd-docker-publish.yml only in terms of
  the parameterized language matrix. The base image (`:latest`, no
  build-arg, no version matrix) doesn't fit this pattern. The current
  `publish-base` job was unaccounted for.
- **Resolution:** Keep `publish-base` as a separate job inside
  cd-docker-publish.yml, parameterized by `image-prefix`. Avoids matrix
  hacks and preserves the existing working structure.

### [2] `if: always()` gate would publish prod images after a failed release
- **Category:** security
- **Severity:** serious
- **Issue:** The spec said docker-publish depends on release with
  `if: always()`, but this fires on all outcomes including failure. A
  failed release (bad changelog, tagging error) would still trigger
  prod image publishing.
- **Resolution:** Use explicit condition:
  `if: always() && (needs.release.result == 'success' || needs.release.result == 'skipped')`

### [3] Nightly rebuilds don't cover prod images
- **Category:** omissions
- **Severity:** serious
- **Issue:** Nightly rebuilds only target `dev-` images. If upstream
  base images get CVE fixes, `prod-` images won't pick them up until
  the next merge to main. Could leave production images with known CVEs
  for days or weeks.
- **Resolution:** Accept the gap intentionally. Prod stays
  release-gated for stability. Nightly `dev-` rebuilds surface CVE
  problems early via failure notifications. Automating the response
  (e.g., auto-triggering a release when nightly finds issues) is future
  work. Reasoning documented in the decision record.

### [4] Attestation subject-name hardcodes `dev-` prefix
- **Category:** contradictions
- **Severity:** moderate
- **Issue:** The spec claimed "all other build logic remains unchanged,"
  but the attestation `subject-name`, `CANDIDATE` env var, and
  `CACHE_TAG` env var all hardcode the `dev-` prefix and must be
  parameterized by `image-prefix`.
- **Resolution:** Updated the spec to explicitly call out these
  parameterization points and qualify the "remains unchanged" claim.

### [5] cd-release.yml existence not confirmed in spec
- **Category:** feasibility
- **Severity:** moderate
- **Issue:** The spec references `cd-release.yml@v1.5` but doesn't
  confirm it exists or link to its documentation. Implementers would
  need to verify independently.
- **Resolution:** Confirmed it exists in standard-actions v1.5. Added
  a reference link in the spec.

### [6] GHCR package visibility for new prod packages
- **Category:** omissions
- **Severity:** moderate
- **Issue:** Migration step 4 covered write permissions but not
  visibility. Auto-created packages in user namespaces default to
  private. Consuming repos would fail to pull `prod-` images without
  authentication.
- **Resolution:** Expanded step 4 to include setting visibility to
  public alongside the write permission grant.

### [7] Cross-repo coordination not specified
- **Category:** ambiguity
- **Severity:** minor
- **Issue:** Steps 5-6 reference changes in other repos without
  specifying coordination approach.
- **Resolution:** Fleet-wide sweep of all managed repos happens
  immediately after implementation. Step 5 is backward-compatible
  (prod and dev images are identical at first publish). Updated spec
  to document this.

### [8] Hadolint duplication between CI and CD workflows
- **Category:** scope imbalance
- **Severity:** minor
- **Issue:** Both ci.yml and cd-docker-publish.yml run hadolint. Every
  main push runs it twice.
- **Resolution:** Keep the duplication. The nightly rebuild path in
  ops.yml skips CI entirely, so cd-docker-publish.yml should be
  self-contained.

## Unresolved Issues

None — all issues addressed.

## Summary

- **Issues found:** 8
- **Issues resolved:** 8
- **Unresolved:** 0
- **Spec status:** ready for implementation
