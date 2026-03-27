# Amazon::API 2.1.11 Release Notes

**Release Date:** 2026-03-27

## Overview

Replaces `LWP::UserAgent` with `HTTP::Tiny` via a lightweight adapter layer.
`HTTP::Tiny` is a core Perl module (since 5.14) with no XS dependencies,
reducing the dependency footprint and improving startup time in mod_perl
environments. The change is transparent to all existing code — the adapter
presents the same interface that `submit` expects.

Also adds `version.mk`, a small Makefile include providing `make release`,
`make minor`, and `make major` targets for version bumping.

---

## New Modules

### `Amazon::API::HTTP::UserAgent`

Thin adapter wrapping `HTTP::Tiny`. Accepts an `HTTP::Request` object (as
built and signed by `submit`), extracts method, URI, headers, and content,
and delegates to `HTTP::Tiny->request`. The `Host` header is filtered before
passing to HTTP::Tiny, which manages that header itself and rejects it if
supplied. Returns an `Amazon::API::HTTP::Response` object.

### `Amazon::API::HTTP::Response`

Adapter wrapping HTTP::Tiny's response hashref in an object presenting the
`LWP::HTTP::Response` interface. Implements `content`, `content_type`,
`is_success`, `code`, and `message` so all existing response-handling code
in `API.pm` is unchanged.

---

## Changes

### `Amazon::API` (`API.pm`)

`_set_defaults` now constructs `Amazon::API::HTTP::UserAgent` instead of
`LWP::UserAgent`. One line change. `submit` is completely unchanged — it
still builds, populates, and signs an `HTTP::Request` object and passes it
to `$ua->request`.

### Build / Packaging

- `autotools/ax_requirements_check.m4` — removed `LWP::UserAgent` and
  `ReadonlyX`; added `HTTP::Headers`, `IO::Socket::SSL`, `Net::SSLeay`,
  `URI`, and `Readonly`
- `cpan/requires` — same dependency changes reflected for CPAN packaging
- `cpan/buildspec.yml` — `Amazon::API::HTTP::Response` and
  `Amazon::API::HTTP::UserAgent` added to `provides`
- `src/main/perl/lib/Makefile.am`, `modules.inc`, `directories.inc` —
  new `Amazon/API/HTTP` directory and modules wired into the build

### New: `version.mk`

Makefile include providing version bump targets driven by the `VERSION` file:

```
make release   # bump patch version  (2.1.10 -> 2.1.11)
make minor     # bump minor version  (2.1.11 -> 2.2.0)
make major     # bump major version  (2.2.0  -> 3.0.0)
```

---

## Upgrade Notes

`LWP::UserAgent` is no longer a dependency. SSL support now requires
`IO::Socket::SSL` and `Net::SSLeay` to be installed explicitly — these
were previously pulled in transitively via LWP.

`HTTP::Request` and `HTTP::Headers` remain dependencies as they are used
by `submit` for request construction and by `Amazon::API::Signature4` for
signing. They do not bring in `LWP::UserAgent` or the broader LWP stack.

If you supply a custom user agent via the `user_agent` constructor option
it must accept a single `HTTP::Request` argument to `request` and return
an object implementing `content`, `content_type`, `is_success`, `code`,
and `message`.
