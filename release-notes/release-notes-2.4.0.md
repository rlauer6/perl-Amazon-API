# Release Notes — Amazon::API v2.4.0

## Overview

Version 2.4.0 is a **major build-system overhaul** release. The Perl
module code itself is unchanged from 2.3.5; the entire focus of this
release is migrating the project from GNU Autotools (`configure.ac`,
`Makefile.am`, `autotools/`) to the modern
`CPAN::Maker::Bootstrapper`-based build system. The new layout is
simpler, more portable, and better aligned with standard CPAN
distribution conventions.

---

## Breaking Changes (Build Infrastructure Only)

- **GNU Autotools removed.** The `bootstrap`, `configure.ac`,
  `Makefile.am`, and all `autotools/*.m4` files have been deleted. You
  no longer need `autoconf`, `automake`, or `aclocal` to work with
  this project.
- **Removed legacy directory structure.** Source files formerly under
  `src/main/perl/`, `src/main/bash/`, `cpan/`, `cpan-dist/`, and
  `docker-rpm/` have been relocated or deleted. See the migration
  table below.

---

## New Features

### New Build System (`CPAN::Maker::Bootstrapper`)

The project now uses
[`CPAN::Maker::Bootstrapper`](https://metacpan.org/pod/CPAN::Maker::Bootstrapper)
to manage the build. A new top-level `Makefile` replaces the old
Autotools-generated one.

Key new `make` targets:

| Target | Description |
|---|---|
| `make` | Build the CPAN tarball |
| `make help` | List all available targets and variables |
| `make test` | Run the test suite (`prove`) |
| `make check` | Syntax-check and build from `.pm.in` source |
| `make quick` | Fast build with scanning, tidy, and critic disabled |
| `make tidy` | Run `perltidy` on all sources |
| `make critic` | Run `perlcritic` on all sources |
| `make lint` | Run both `tidy` and `critic` |
| `make release` | Bump patch version |
| `make minor` | Bump minor version |
| `make major` | Bump major version |
| `make release-notes` | Generate release diff/listing/tarball artifacts |
| `make update` | Update managed files from installed bootstrapper |
| `make upgrade` | Upgrade `CPAN::Maker::Bootstrapper` itself |
| `make check-upgrade` | Check MetaCPAN for a newer bootstrapper version |
| `make build-ci` | Run a CI build inside Docker |
| `make git` | Initialise a git repository with recommended artifacts |

### New Managed Include Files

The following Makefile fragments are now managed under `.includes/`:

- `.includes/git.mk` — git repository initialisation helpers
- `.includes/help.mk` — self-documenting `make help` target
- `.includes/perl.mk` — Perl build rules (syntax checking, `perltidy`, `perlcritic`, `.pm.in` → `.pm` pattern rules)
- `.includes/release-notes.mk` — release artifact generation *(moved from `release-notes.mk`)*
- `.includes/update.mk` — bootstrapper update machinery
- `.includes/upgrade.mk` — bootstrapper upgrade machinery
- `.includes/version.mk` — version bumping targets *(moved from `version.mk`)*

### New `project.mk`

A `project.mk` file (included by the main `Makefile`) contains
project-specific rules for building Botocore service metadata:

- Clones the Botocore repo with `--depth=1` on first use
- Adds a `services.api` target tracked via `.botocore.state`
- Introduces a `workdir/` staging area for CPAN service distribution builds
- Renames `MODULE_NAME` → `MODULE_ALIAS` for service API distribution
  builds to avoid conflict with the main `Makefile` variable

### New Test

- `t/00-amazon-api.t` — basic `use_ok` smoke test for `Amazon::API`

---

## Changes

### File Relocations

| Old Path | New Path |
|---|---|
| `src/main/perl/lib/Amazon/API*.pm.in` | `lib/Amazon/API*.pm.in` |
| `src/main/bash/bin/amazon-api.sh.in` | `bin/amazon-api.in` |
| `src/main/perl/bin/build-boto-services.pl.in` | `bin/build-boto-services.pl.in` |
| `src/main/perl/t/*.t` | `t/*.t` |
| `cpan/requires` | `requires` |
| `cpan/test-requires` | `test-requires` |
| `cpan/recommends` | `recommends` |
| `cpan-dist/requires` | `requires.cpan-dist` |
| `cpan-dist/buildspec.yml.in` | `buildspec-api.yml.in` |
| `release-notes.mk` | `.includes/release-notes.mk` |
| `version.mk` | `.includes/version.mk` |

### `buildspec.yml` Rewritten

The `buildspec.yml` has been completely rewritten from an AWS
CodeBuild specification to a `make-cpan-dist` project specification:

```yaml
pm-module: Amazon::API
min-perl-version: 5.010
dependencies:
  requires: requires
  test-requires: test-requires
path:
  pm-module: lib
  exe-files: bin
  tests: t
```

Resources now point to `https://github.com/rlauer6/Amazon-API`.

### `release-notes.mk` — Minor Fix

`curr_ver` is now read from the `$(VERSION)` make variable instead of
`cat VERSION`, ensuring consistency with the rest of the build.

### `version.mk` — Documentation

`release`, `minor`, and `major` targets now include `##` help strings
visible via `make help`.

### `.gitignore` Refreshed

- Removed: Autotools artefacts (`*.tag`, `perltidy.err`, `*.api`,
  `*.services`, `configure`, `aclocal.m4`, `*.spec`, `*.rpm`, etc.)
- Added: bootstrapper artefacts (`module.pm.tmpl`,
  `buildspec.yml.tmpl`, `test.t.tmpl`, `botocore/`, `bin/amazon-api`,
  `bin/`, `services.api`, `buildspec.yml.current`, `**/*.crit`,
  `**/*.tdy`)

---

## Removed

The following files and directories have been **deleted**:

- All GNU Autotools files: `bootstrap`, `configure.ac`, `Makefile.am`,
  `Makefile.requirements`, `autotools/`
- All `src/` Makefiles and build includes (`Makefile.am`,
  `perl-build.inc`, `directories.inc`, `modules.inc`)
- Legacy `cpan/` and `cpan-dist/` directories (contents migrated or removed)
- `docker-rpm/` Docker RPM build infrastructure
- `perl-Amazon-API.spec.in` RPM spec template
- `requirements.json` (replaced by scanned `requires` file)
- `target-repo` configuration file

---

## Upgrade Notes

This release contains **no changes to the `Amazon::API` Perl module
code**. Upgrading from 2.3.5 requires no code changes in consuming
applications.

Building the distribution from this tarball does not require
`CPAN::Maker::Bootstrapper` — all generated build artifacts
(buildspec.yml, requires, test-requires, etc.) are
included. CPAN::Maker::Bootstrapper is only needed if you want to
regenerate these artifacts, scaffold a new module, or use targets like
make workflow.

[`CPAN::Maker::Bootstrapper`](https://metacpan.org/pod/CPAN::Maker::Bootstrapper)

---

## Repository

- **Homepage:** https://github.com/rlauer6/Amazon-API
- **Bug Tracker:** https://github.com/rlauer6/Amazon-API/issues
