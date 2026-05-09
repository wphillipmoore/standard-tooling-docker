# Release Workflow, Image Naming Convention, and Nightly Rebuilds

**Date:** 2026-05-09
**Status:** Draft
**Combines:** #152, #139, #65

## Overview

This repo is the last in the ecosystem without a staged release process.
All images are published under the `dev-` prefix with mutable tags that
update on every develop merge. There is no distinction between staging
and production images, no changelog generation, and no scheduled rebuilds
to catch upstream CVEs between merges.

This design combines three issues into a single coordinated effort:

- **#152** — dev/prod image naming convention
- **#139** — release workflow (changelog, versioning, release notes)
- **#65** — scheduled nightly rebuilds for CVE freshness

## Decision Record

Key decisions made during brainstorming:

- Nightly rebuilds target `dev-` images only. `prod-` images are built
  exclusively by the CD release workflow on main merges.
- No ephemeral cleanup workflow. Nightly rebuilds overwrite the same
  mutable tags, so there is no tag accumulation to clean up. Stale
  candidate/cache tag cleanup is handled by #125.
- `dev-base` gets the same dev/prod treatment as language images. All
  consuming repos switch to `prod-` images as the default.
- Failure notification for nightly rebuilds uses built-in GitHub Actions
  email notifications. No custom issue-creation or Slack integration.
- Consumer-side changes (`st-docker-run`, `standard-tooling.toml`) are
  in scope. This covers the entire tooling suite, not just this repo.

## Scope

### In scope

| Area | Repository |
|------|-----------|
| Workflow restructuring (cd.yml, cd-docker-publish.yml, ops.yml) | standard-tooling-docker |
| Delete docker-publish.yml | standard-tooling-docker |
| Wire up cd-release.yml reusable workflow | standard-tooling-docker |
| Nightly rebuild schedule in ops.yml | standard-tooling-docker |
| Documentation updates | standard-tooling-docker |
| `st-docker-run` prefix-aware image resolution | standard-tooling |
| `standard-tooling.toml` schema: `[docker] image-prefix` field | standard-tooling |
| Reusable CI workflow image references | standard-tooling (standard-actions) |
| Consuming repo image reference updates | all managed repos |

### Out of scope

- Versioned immutable tags (#60) — layers on top of `prod-` tags
- Stale cache/candidate tag cleanup (#125) — independent effort
- Custom failure-handling beyond email (issue auto-creation, Slack)

## Image Naming Convention

| Prefix | Source branch | Built by | Purpose |
|--------|-------------|----------|---------|
| `dev-{lang}:{ver}` | develop | cd.yml (develop push) + ops.yml (nightly) | Staging and validation of image changes |
| `prod-{lang}:{ver}` | main | cd.yml (main push, after release) | Production use by all consumers |

All images follow this convention, including `dev-base`/`prod-base`.

`prod-` images are the default everywhere. `dev-` images are used
temporarily to validate changes to the images themselves, typically by
pointing a single consumer at `dev-` while debugging a broken workflow.

## Workflow Structure

### Files

| File | Action | Purpose |
|------|--------|---------|
| `docker-publish.yml` | Delete | Replaced by cd-docker-publish.yml |
| `cd-docker-publish.yml` | Create | Reusable `workflow_call` with `image-prefix` input. Contains the full build matrix, Trivy scanning, attestation, and promotion logic. |
| `cd.yml` | Rewrite | Thin shim orchestrating cd-docs, cd-release, and cd-docker-publish |
| `ops.yml` | Create/extend | Scheduled operations: github-config audit + nightly dev image rebuild |

### cd-docker-publish.yml

Reusable workflow extracted from the current `docker-publish.yml`. Accepts
a single required input:

```yaml
on:
  workflow_call:
    inputs:
      image-prefix:
        description: "Image name prefix (dev or prod)"
        type: string
        required: true
```

The `IMAGE` env var becomes:
```
ghcr.io/wphillipmoore/${{ inputs.image-prefix }}-${{ matrix.language }}:${{ matrix.version }}
```

All other build logic (QEMU, Buildx, Trivy scan, attestation, candidate
promotion, digest verification) remains unchanged.

The workflow is structured as `workflow_call` to be reusable-ready, even
though it is currently only called locally.

### cd.yml

Thin orchestration shim:

```yaml
on:
  push:
    branches: [develop, main]
  workflow_dispatch:
```

Jobs:

- **docs** — calls `cd-docs.yml@v1.5` (all pushes)
- **release** — calls `cd-release.yml@v1.5` (main push only), with
  `language: shell`, `container-tag: latest`, `container-suffix: base`.
  Passes `secrets: inherit`.
- **docker-publish** — calls `cd-docker-publish.yml`. Depends on
  `release` with `if: always()` gated on success or skipped. Passes
  `image-prefix: ${{ github.ref == 'refs/heads/main' && 'prod' || 'dev' }}`

On develop push: release is skipped, docker-publish runs with `dev`.
On main push: release runs first, then docker-publish runs with `prod`.

### ops.yml

```yaml
on:
  schedule:
    - cron: '15 6 * * *'
  workflow_dispatch:
```

Jobs:

- **github-config** — calls `ops-github-config.yml@v1.5`
- **nightly-rebuild** — calls `cd-docker-publish.yml` with
  `image-prefix: dev`

Failure notification relies on built-in GitHub Actions email
notifications for workflow failures.

## Consumer-Side Changes (standard-tooling repo)

### standard-tooling.toml schema

New optional field under `[docker]`:

```toml
[docker]
image-prefix = "dev"   # default: "prod"
```

Consumers default to `prod-` images. A repo can temporarily opt into
`dev-` images for validation of in-progress image changes.

### st-docker-run

Currently hardcodes the `dev-` prefix when constructing image names.
Changes to:

1. Read `image-prefix` from `standard-tooling.toml` (default: `prod`)
2. Construct image name as
   `ghcr.io/wphillipmoore/{prefix}-{language}:{version}`

### Reusable CI workflows

CI workflows in standard-actions (`ci-quality.yml`, `ci-test.yml`, etc.)
that reference container images need to use `prod-` prefixed images by
default, consistent with the consumer-side default.

## Migration Sequence

The order is load-bearing — consumers cannot reference `prod-` images
before they exist.

1. **Land cd-docker-publish.yml and updated cd.yml on develop.** Dev
   images continue to build as `dev-` on every develop merge. No
   consumer impact.

2. **Land ops.yml with nightly rebuild job.** Nightly schedule starts
   rebuilding `dev-` images. No consumer impact.

3. **Merge develop to main — first release.** The release workflow fires
   (changelog, tag, version-bump PR), then docker-publish runs with
   `prod-` prefix. This creates the first set of `prod-` images.

4. **GHCR package permissions.** Each new `prod-` package needs the
   one-time "Add Repository -> standard-tooling-docker -> Write" setup
   in GHCR package settings. Applies to: `prod-base`, `prod-python`,
   `prod-java`, `prod-go`, `prod-ruby`, `prod-rust`.

5. **Land consumer-side changes in standard-tooling.** `st-docker-run`
   defaults to `prod-` prefix. Reusable CI workflows reference `prod-`
   images.

6. **Update consuming repos.** Any repo with hardcoded `dev-` image
   references (including this repo's own `ci.yml` hadolint job) gets
   updated to `prod-`.

Until step 3 completes, `dev-` images remain the only images available,
so consumers are unaffected during the transition.

## Documentation Updates

- **Architecture docs** (`docs/site/docs/architecture/index.md`) —
  update the Publishing section to describe the dev/prod split, nightly
  rebuild schedule, and the release workflow.
- **CLAUDE.md** — update image naming references (currently describes
  `dev-` prefix throughout).
- **Consumer docs in standard-tooling** — document the
  `[docker] image-prefix` field and the default behavior.

## Issue Housekeeping

- Close #152, #139, #65 as completed by the combined work.
- Close #61 (document that repo doesn't use publish/release) — it now
  does.
- #60 (versioned immutable tags) remains open — layers on top.
- #125 (stale cache tag audit) remains open — out of scope.
- Create a single tracking issue referencing all three source issues.
