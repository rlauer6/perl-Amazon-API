# Amazon::API 2.3.2 Release Notes

## Summary

Continued factory prep.  The headline change is the promotion of
`build-boto-services` from a plain Perl script to a
`CLI::Simple`-based modulino (`Amazon::API::Botocore::Services`),
exposed as a bash modulino link.  The `cpan-dist/Makefile` receives
several robustness improvements, and the `Dockerfile` gains
build-argument flexibility for branch and repo overrides.

---

## Changes

### `Amazon::API::Botocore::Services` (new module)

`build-boto-services.pl` is retired as a standalone Perl script.  Its
functionality is rewritten as `Amazon::API::Botocore::Services`, a
`CLI::Simple` modulino that exposes two commands:

- `build-services` - builds the `services.api` binary (default).
- `list-services` - outputs a JSON description of Botocore services;
  accepts an optional service name to filter output.

The modulino is installed as a bash modulino link (`build-boto-services`)
via `create-modulino.pl` in `src/main/bash/bin/Makefile.am`.
`cpan/Makefile.am` is updated to reference the bash link rather than
the Perl script, and `PERL5LIB` is now set correctly when invoking it.

`Amazon::API::Botocore::Services` is added to `cpan/buildspec.yml` and
`src/main/perl/lib/Makefile.am`.

### `Amazon::API::Botocore.pm.in`

The stub version placeholder is changed from `@PACKAGE_VERSION@` to
`@SERVICE_VERSION@`.  The `api` target in `cpan-dist/Makefile` now
extracts the Botocore service date and substitutes it as the module
version, so generated service modules carry a date-based version (e.g.
`2024.11.15`) rather than the `Amazon::API` package version.

### `cpan-dist/Makefile`

- `SHELL := /bin/bash` and `.SHELLFLAGS := -ec` set throughout for
  consistent behaviour.
- `NO_ECHO ?= @` introduced; all recipe lines prefixed with
  `$(NO_ECHO)` for suppressible verbosity.
- `service` target no longer depends on `service-listing.json`;
  service-directory lookup uses `-mindepth 1 -maxdepth 1` for
  precision.  Switched to `[[ ]]` conditionals throughout.
- `buildspec.yml` target falls back to hardcoded defaults
  (`aws-api-autobuilder` / `rclauer@gmail.com`) when `git` is not
  present in the container.
- `service-listing.json` target uses `JSON::XS` instead of `JSON` for
  encoding; `find` uses `-mindepth 1 -maxdepth 1` removing the
  `data`-directory guard.
- `list-services` target no longer passes `-M` flags; `JSON` is
  imported inside the inline scriptlet.
- `clean` target uses `$(NO_ECHO)` prefix.

### `docker/Dockerfile`

- `BRANCH` and `REPO` added as `ARG`s, defaulting to `master` and the
  upstream GitHub URL respectively.
- `CACHE_BUST` arg added to allow invalidating the clone layer without
  rebuilding everything.
- The `perl-Amazon-API` clone is moved into its own layer (after
  `botocore`) so that dependency installation can be cached
  independently of source changes.
- Repo directory in subsequent `RUN` steps derived from
  `$(basename ${REPO} .git)` rather than hardcoded.
- `FULLNAME` corrected to `aws-api-autobuilder`; `EMAIL` env var added
  to the runtime stage.

### `CLI::Simple` dependency

Pinned to `2.0.6` in `build-requires`, `cpan/requires`, and
`cpanfile`.
