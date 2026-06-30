# Release Notes — Amazon::API v2.4.1

**Release Date:** 2026-06-30
**Distribution:** `Amazon-API`
**Previous Version:** 2.4.0

---

## Overview

This is a maintenance release focused on fixing the CI build pipeline
introduced in v2.4.0. No functional changes have been made to the Perl
modules themselves.

---

## Changes

### Bug Fixes

- **Fixed variable name typo in `project.mk`** — Corrected
  `BOTO_CORE_PATH` to `BOTOCORE_PATH`, which prevented the botocore
  state target from resolving its prerequisite correctly.

### CI / Build Infrastructure

- **Replaced `build-github` with `builder`** — The old `build-github`
  script has been removed and replaced with a new, more capable
  `builder` script. The new script:
  - Supports both `cpm` and `cpanm` as Perl module installers
    (configurable via the `INSTALLER` environment variable).
  - Supports DarkPAN/custom CPAN mirrors via a `build-mirrors` file.
  - Supports additional system package dependencies via a `build-apt-deps` file.
  - Automatically enables `Perl::Critic` and `Perl::Tidy` checks when
    corresponding configuration files are present in the repository.
  - Regenerates `cpanfile` at build time to include `build-requires`
    and `test-requires` in addition to runtime dependencies (the
    committed `cpanfile` retains only runtime dependencies for
    end-user installs).
  - Can be run locally using Docker without pushing to GitHub.

- **Updated GitHub Actions workflow (`.github/workflows/build.yml`)**
  — Updated the workflow job name from `perl-Amazon-API` to
  `Amazon-API` and updated the build step to invoke `./builder`
  instead of the removed `./build-github` script.

- **Added `bin/build-boto-services.in`** — New shell wrapper script
  that invokes `Amazon::API::Botocore::Services` as a modulino,
  resolving the installed module path dynamically at runtime.

- **Updated `.gitignore`** — Removed the blanket `bin/` directory
  exclusion to allow tracked scripts under `bin/` to be properly
  versioned.

---

## Upgrade Notes

This release contains no changes to the public Perl API. Upgrading
from v2.4.0 is safe and recommended for users running CI builds from
source.

---

## Files Changed

| File | Change |
|---|---|
| `.github/workflows/build.yml` | Updated job name and build command |
| `.gitignore` | Removed `bin/` directory exclusion |
| `VERSION` | Bumped to `2.4.1` |
| `bin/build-boto-services.in` | New modulino wrapper script |
| `build-github` | **Removed** |
| `builder` | New CI build script (replaces `build-github`) |
| `project.mk` | Fixed `BOTO_CORE_PATH` → `BOTOCORE_PATH` |
