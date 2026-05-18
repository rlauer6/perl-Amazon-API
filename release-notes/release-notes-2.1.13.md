# Amazon::API 2.1.13 Release Notes

**Release Date:** 2026-04-07

## Overview

A significant refactoring of `invoke_api` and the Botocore shape
serialization pipeline, plus a new `Amazon::API::NullLogger` class
that prevents re-entrant logging when `Amazon::API` is used inside a
`Log::Log4perl` appender or other logging-aware context.

---

## New Features

### `Amazon::API::NullLogger`

A new no-op logger class that satisfies the `Amazon::API` logger
interface without producing any output. Activated via the new
`no_logger` constructor option:

```perl
my $cwl = Amazon::API::CloudWatchLogs->new(
    no_logger => 1,
    url       => 'https://...',
);
```

This is essential when using `Amazon::API` inside a
`Log::Log4perl` appender such as
`Log::Log4perl::Appender::CloudWatch` where internal API logging
would trigger re-entrant calls through the appender itself.

### `$LOGGER_SOURCE` — dynamic logger injection for Shape classes

A new package-level variable `$Amazon::API::Botocore::Shape::LOGGER_SOURCE`
can be set to a coderef that returns a logger for a given shape class.
It is set with `local` in `create_botocore_request` and
`Serializer::serialize` to propagate the correct logger through the
entire shape instantiation chain without passing it through constructor
arguments.

---

## Changes

### `Amazon::API`

#### `invoke_api` — major refactoring

The pagination loop has been significantly simplified:

- Replaced `goto PAGINATE` with a clean `while ($TRUE)` loop
- Removed the broad `eval {}` block that was masking serialization
  errors
- Pagination now preserves the original request parameters
  (`$original_content`) and merges them into subsequent page requests,
  fixing cases where APIs like `DescribeLogStreams` require parameters
  such as `orderBy` and `descending` on every page request
- Removed dead code paths that were unreachable after the `goto`
- `$use_paginator` replaced by `$paginator` as the loop sentinel —
  if there is no paginator the early return path exits cleanly

Three new private methods extract functionality from `invoke_api`:

- **`_unpack_args`** — handles both positional and named-parameter
  calling conventions
- **`_check_response`** — centralizes HTTP error handling, setting
  `error`, printing to STDERR, or dying based on `raise_error` and
  `print_error` settings
- **`_init_paginator`** — initializes the paginator hashref,
  enforcing the requirement that `use_botocore` and `decode_always`
  are both true

#### `create_botocore_request`

Sets `local $Amazon::API::Botocore::Shape::LOGGER_SOURCE` before
instantiating the request shape, ensuring all child shapes created
during request building use the API's own logger rather than
calling `Log::Log4perl->get_logger` directly.

#### `_set_default_logger`

Returns a `NullLogger` immediately when `no_logger` is set, skipping
all Log4perl initialization.

#### `_set_defaults`

- Simplified with `//=`-style defaults throughout
- Region resolution unified — no longer set in two separate places
- Removed dead `force_array` defaulting logic
- `decode_always` now correctly defaults to `$TRUE`

#### `choose` subroutine

Moved earlier in the file (before `new`) to ensure it is defined
before use given its prototype signature.

### `Amazon::API::Botocore::Shape`

- **`$LOGGER_SOURCE`** — new package global; when set, `new` calls
  it to obtain a logger rather than calling `Log::Log4perl->get_logger`
  directly. Falls back to `Log::Log4perl->get_logger` if initialized,
  or `NullLogger` if not.
- **`new`** — logger is now set after `SUPER::new` rather than being
  passed in `$args`, preventing the logger from contaminating `_value`
  when shapes are instantiated for deserialization.
- **`_init_structure`** — copies the input hashref before mutating it
  (`my %result = %{$value}`) to prevent the caller's parameter hash
  from being replaced with shape objects. Blessed scalar refs
  (e.g. `JSON::PP::Boolean`) are now skipped rather than passed to
  `$class->new`.
- **`_init_value`** — allows blessed scalar refs through the type
  check (`reftype($value) ne 'SCALAR'`), and correctly treats plain
  scalars as type `SCALAR` rather than empty string.
- **`finalize_structure`** — guards `finalize` calls with
  `$value->can('finalize')`, allowing `JSON::PP::Boolean` and other
  non-Shape blessed values to pass through as-is.

### `Amazon::API::Botocore::Shape::Serializer`

- **`serialize`** — sets `local $LOGGER_SOURCE` before creating
  shape objects so all shapes instantiated during serialization
  inherit the Serializer's logger. Logger is also set explicitly
  via `set_logger` after shape construction.

### `Amazon::API::HTTP::Response`

- **`new`** — now uses `bless` directly rather than `SUPER::new`,
  removing the dependency on a parent class constructor.

### `Amazon::API::NullLogger` (new)

Provides no-op implementations of `trace`, `debug`, `info`, `warn`,
`error`, `fatal`, and `level`.

---

## Bug Fixes

- **Re-entrant logging** — using `Amazon::API` inside a Log4perl
  appender no longer causes infinite recursion or incorrect Log4perl
  initialization. The `no_logger` option and `LOGGER_SOURCE` mechanism
  together prevent all internal shape logging from routing back through
  user-configured appenders.
- **`JSON::PP::Boolean` in request parameters** — passing
  `JSON::PP::true` or `JSON::PP::false` as API parameters no longer
  causes a `ref type of value should be one of SCALAR, ARRAY or HASH`
  error. The value is preserved as-is through serialization and
  correctly rendered in the JSON payload.
- **Pagination parameter loss** — subsequent pages of paginated
  requests now include all original request parameters, not just the
  pagination token and limit. This fixes `DescribeLogStreams` and
  other APIs that require filtering or ordering parameters on every
  page.
- **Input mutation in `_init_structure`** — shape construction no
  longer modifies the caller's parameter hashref in place.
- **`decode_always` default** — was documented and tested as `false`
  but defaulted to `true` in code. Documentation and behavior are
  now aligned: default is `true`.

---

## POD

- `decode_always` — corrected default (`true`), clarified description,
  added pagination note
- `debug` — removed incorrect claim that `debug => 2` increases log
  level
- `no_logger` — new option documented
- `user_agent` — updated to reflect `HTTP::Tiny`-based default;
  interface requirements documented
- `url` — fixed broken `<LocalStack|...>` link to `L<LocalStack|...>`
- Logging section — updated to reflect real Log4perl logger creation
  rather than stealth loggers; fixed "serialiazation" typo
- `submit` — added note on `raise_error`/`print_error` interaction
- `BETTER TOGETHER` — new section documenting companion distributions:
  `Amazon::Credentials`, `Amazon::S3::Lite`, `Amazon::Lambda::Runtime`,
  `Log::Log4perl::Appender::CloudWatch`
- `TBD` — simplified; removed outdated load-time commentary
- Various whitespace and formatting fixes throughout
