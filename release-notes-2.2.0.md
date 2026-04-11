# Amazon::API 2.2.0 Release Notes

**Release Date:** 2026-04-08

## Overview

This is a significant architectural release focused on startup performance and
dependency reduction. The primary changes are lazy loading of heavyweight
modules, elimination of embedded JSON shape data from generated `.pm` files,
and a new botocore service metadata pipeline that stores shape definitions as
binary Storable files rather than inlining them as Perl data structures. The
result is faster module load times, smaller generated files, and reduced memory
footprint — all particularly beneficial in Lambda cold-start environments.

---

## New Features

### Service Metadata Pipeline

A new script `build-boto-services.pl` scans the Botocore repository and
produces a binary `services.api` file (via `Storable::nstore`) containing
service protocol and content-type mappings for all AWS services. This file is
distributed with the `Amazon::API` CPAN package and replaces the large
hardcoded `%API_TYPES` hash and the inline metadata previously embedded in
generated stubs.

### Shape Registry (`register_service_shapes`)

New exported function in `Amazon::API::Botocore::Shape::Utils`. Called once
per service at startup, it populates a package-level `%SERVICE_SHAPES` cache
keyed by service name. `require_shape` now consults this cache and
synthesizes shape classes on the fly via `_create_shape_class` rather than
requiring pre-generated `.pm` files on disk. This eliminates hundreds of
file-open and `decode_json` operations at request time.

### `_create_shape_class`

New private function that fabricates a shape class at runtime by injecting
`@ISA` and a `new` constructor into the target package's symbol table. Shape
definitions come from the registry rather than from embedded JSON heredocs.
The `__DATA__` shape class template in `Utils.pm` has been removed entirely.

### `paginator` Shim (`API.pm`)

`Amazon::API::Botocore` is now loaded lazily. A new `paginator` wrapper in
`API.pm` loads `Amazon::API::Botocore` on first use via `Module::Load` rather
than at compile time, avoiding the full Botocore load for callers that don't
use pagination.

### `find_content_type` Updated

Now handles the `protocols` array introduced in newer Botocore metadata
(services can declare multiple supported protocols). Also sets
`$self->set_protocol` as a side effect, ensuring the protocol is always
available downstream without a separate lookup.

---

## Changes

### `Amazon::API` (`API.pm`)

**Lazy loading** — `XML::Simple`, `XML::LibXML`, `Log::Log4perl`, and
`Amazon::API::Botocore` are now loaded on demand via `Module::Load`. Removed
from compile-time `use` statements: `LWP::UserAgent`, `Date::Format`,
`Time::Local`, `Time::HiRes`, `XML::LibXML`, `XML::Simple`, `Log::Log4perl`.

**Logging initialization simplified** — `init_log_level` removed. `new`
now sets `log_level` from `debug`/`$ENV{DEBUG}` before `_set_defaults` runs,
so the level is consistent throughout construction. `_set_defaults` sets
`no_logger => true` when the log level is not `debug` or `trace`, avoiding
Log4perl initialization entirely for production use.

**`set_log_level` guarded** — returns early if no logger is set, and only
calls `Log::Log4perl->get_logger` when the logger is actually a Log4perl
instance.

**`_init_structure`** — defaults `required` to `[]` if undefined, preventing
crashes on shapes that omit the `required` key.

**Dead code removed** — `$START_TIME`, `$LAST_LOG_TIME`, `stringify` sub,
`$STRINGIFY` constant.

### `Amazon::API::Botocore` (`Botocore.pm`)

Shape files now written as `.pod` not `.pm` — generated shape documentation
is POD only, not executable Perl. `create_service_shapes` writes `.pod`
files; `render_stub` writes method POD to `.pod` files.

`render_stub` no longer embeds `operations`, `shapes`, or `paginators` as
stringified Perl data structures in the generated stub. These are now loaded
from the `.api` binary at runtime.

`create_stub` now writes a binary `.api` file (via `Storable::nstore`)
alongside the generated stub when an output path is provided, containing
`metadata`, `operations`, `shapes`, and `paginators`.

`stringify` sub removed.

### `Amazon::API::Botocore::Shape` (`Shape.pm`)

`Log::Log4perl` dependency removed. Logger initialization in `new` now
falls back directly to `Amazon::API::NullLogger` when no `$LOGGER_SOURCE`
is configured, rather than checking `Log::Log4perl->initialized`.

### `Amazon::API::Botocore::Shape::Serializer` (`Serializer.pm`)

`POSIX::strftime` now loaded lazily (only when a timestamp with fractional
seconds is encountered).

### `Amazon::API::Botocore::Shape::Utils` (`Utils.pm`)

`Amazon::API::Template` now loaded lazily via shim functions
(`to_template_var`, `fetch_template`, `render_template`, `html2pod`). This
avoids loading the template machinery for callers that only use shape
serialization.

`register_service_shapes` and `_create_shape_class` added (see above).

`require_shape` updated to check the shape registry before attempting
`require_class`, and to synthesize classes via `_create_shape_class` when
neither an on-disk `.pm` nor a cached class exists.

`__DATA__` shape class template removed.

### `Amazon::API::Error` (`Error.pm`)

`XML::Simple` now loaded lazily via `Module::Load`.

### Build / Packaging

- `src/main/perl/bin/` — new directory containing `build-boto-services.pl.in`
- `cpan/Makefile.am` — now clones and pulls botocore repo, runs
  `build-boto-services.pl` to produce `services.api`, checks remote HEAD hash
  to avoid unnecessary rebuilds
- `cpan/buildspec.yml` — `services.api` added to distribution as a share file;
  `src/examples` removed
- `cpan-dist/Makefile` — major refactor; POD extraction via `podextract`,
  service listing targets added (`xml.services`, `json.services`, etc.)
- `cpan-dist/buildspec.yml.in` — per-service `.api` file added to share
- `src/examples/` — all example files removed (`APIExample.pm`, `ec2.pm`,
  `sts.pm`, `sqs.pm`, `ssm.pm`, `ecr.pm`, `rt53.pm`, `secrets-manager.pm`,
  `cloudwatch-events.pm`, `docker-compose.yml`, `README.md`)

---

## Dependency Changes

Added: `Module::Load`, `Storable`, `File::ShareDir`, `Pod::Extract`,
`Pod::Find`, `IO::Pager`, `CPAN::Maker`

Removed from compile-time (now lazy): `XML::Simple`, `XML::LibXML`,
`Log::Log4perl`, `Date::Format`, `Time::Local`, `Time::HiRes`

Updated minimum versions: `AWS::Signature4` 1.02, `Amazon::Credentials` 1.2.1,
`HTTP::Request` 7.00, `Readonly` 2.05, `List::MoreUtils` 0.430

---

## Upgrade Notes

Service distributions generated with 2.2.0's `amazon-api` tooling use the
new `File::ShareDir` + `.api` binary approach for botocore metadata rather
than embedding it as Perl data structures. Regenerate and redeploy any
service distributions you intend to update alongside this release.

Previously generated service distributions continue to work against the
2.2.0 runtime without modification.
