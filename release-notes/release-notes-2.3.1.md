# Amazon::API 2.3.1 Release Notes

## Summary

Prep release for the Amazon::API factory service.  The primary changes
are a rewritten multi-stage `Dockerfile`, a switch from `JSON` to
`JSON::XS` for faster serialization, and a refactored `build-github`
script.  No API behaviour changes.

---

## Changes

### `docker/Dockerfile` (replaces `Dockerfile.create-service`)

The old `Dockerfile.create-service` (Amazon Linux 2 / `cpanm`-based)
is removed and replaced with a modern multi-stage Debian Trixie image:

- **Builder stage** - installs build tools, clones `botocore` and
  `perl-Amazon-API` with `--depth=1`, installs Perl dependencies via
  `cpm` into a Docker layer cache at `/cache/local-debian`, builds
  and installs `Amazon::API` from source.
- **Runtime stage** - copies only the installed modules, `cpan-dist`
  toolchain, and `botocore` checkout; no build tools, no source tree,
  no git history.
- `SERVICE` and `MODULE_NAME` are passed at container run time via the
  `ENTRYPOINT`.

### `JSON` → `JSON::XS`

`JSON::XS` replaces `JSON` in both `cpan/requires` and `build-requires`.
`JSON::XS` is materially faster for the volume of Botocore metadata
serialized by `build-boto-services.pl` and for service API file
generation.  Both `Amazon/API.pm.in` and `build-boto-services.pl.in`
now import `decode_json`/`encode_json` explicitly.

### `build-requires` / `cpanfile`

- `Amazon::Signature4::Lite` pinned to `1.0.1`.
- `CLI::Simple` pinned to `2.0.4`.
- `File::ShareDir` and `File::ShareDir::Install` added.
- `cpanfile` is now generated from `build-requires` via a new
  `Makefile.am` target.

### `build-github`

Refactored to be runnable locally without pushing to GitHub:

- Accepts `REPO` and `BRANCH` as either positional arguments or
  environment variables.
- Switches from `cpanm` to `cpm --use-install-command`.
- Uses `--depth=1` clones for both the project and `botocore`.
- `TARGET` variable selects the `make` target; defaults to `cpan` when
  a `cpan:` target exists in the `Makefile`.

### `.github/workflows/build.yml`

- CI job renamed from `test-module` to `perl-Amazon-API`.
- `dev` branch added to the push trigger.

### `build-boto-services.pl.in`

- Pod typo fixed: `determin` → `determine`.
