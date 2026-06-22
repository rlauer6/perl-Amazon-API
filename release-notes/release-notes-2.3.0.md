# Amazon::API 2.3.0 Release Notes

## Overview

2.3.0 replaces `AWS::Signature4` with `Amazon::Signature4::Lite` as the
signing dependency, eliminating `LWP` (`libwww-perl`) and its transitive
dependencies from the `Amazon::API` footprint. For Lambda deployments this
is a significant win: `AWS::Signature4` pulls in `LWP`, `HTML::Parser`,
`WWW::RobotRules`, `HTTP::Negotiate`, and the full `libwww-perl` stack -
none of which `Amazon::API` uses at runtime. Replacing it with the
lightweight `Amazon::Signature4::Lite` (pure Perl, no C compilation, no LWP
dependency) reduces image size and eliminates a dependency that was never
needed for anything beyond signing.

The change is transparent to callers - `Amazon::API`'s interface is
unchanged, and the new `Amazon::API::Signature4` adapter preserves full
backward compatibility with the `AWS::Signature4`-compatible calling
convention (`-access_key`/`-secret_key` dash-prefix constructor, in-place
`sign($http_request, $region)` method).

---

## Changes

### Amazon::API::Signature4 - rewritten as an adapter over Amazon::Signature4::Lite

Previously a thin subclass of `AWS::Signature4` that inherited its signing
algorithm and worked directly on `HTTP::Request` objects. Now an adapter
that translates between `Amazon::API`'s existing `AWS::Signature4`-compatible
interface and `Amazon::Signature4::Lite`'s plain-hashref/scalar interface:

- **`new(%args)`** - translates dash-prefix constructor keys
  (`-access_key`, `-secret_key`, `-security_token`, as used by `Amazon::API.pm`)
  to `Amazon::Signature4::Lite`'s plain-key convention
  (`access_key`, `secret_key`, `session_token`). Both forms accepted.

- **`sign($http_request, $region)`** - extracts `method`, `url`, `headers`,
  and `payload` from the `HTTP::Request` object, delegates to
  `Amazon::Signature4::Lite->sign(...)`, and applies the returned signed
  headers back onto the request in place - preserving the in-place mutation
  behaviour that `Amazon::API.pm` expects.

- **`parse_service_url(%args)`** - kept as an explicit exportable sub (not
  just an inherited method) so callers using
  `use Amazon::API::Signature4 qw(parse_service_url)` continue to work.
  Carries a full S3 endpoint regex set covering FIPS, dual-stack, S3 control
  plane, and account-id-prefixed endpoints.

### Dependencies

- `AWS::Signature4` removed from `cpan/requires` and `autotools`
- `Amazon::Signature4::Lite` added

### Tests

- `t/06-signature4-adapter.t` - new regression test confirming the adapter
  correctly signs requests, applies headers to the `HTTP::Request` object,
  handles session tokens, and resolves service/region from AWS endpoint URLs
  across all three calling conventions (plain function, class method, instance
  method).

---

## Upgrade Notes

- Remove `AWS::Signature4` from any explicitly declared dependencies in your
  own projects if it was only there transitively via `Amazon::API`.
- Add `Amazon::Signature4::Lite` if you use `Amazon::API::Signature4`
  directly (rare - most callers go through `Amazon::API`).
- `LWP`/`libwww-perl` is no longer required by `Amazon::API` itself. If you
  depend on it for other reasons, declare it explicitly in your own
  `cpanfile`/`requires`.
- For Lambda images: remove any `cpanm LWP` or `cpanm AWS::Signature4` steps
  from your `Dockerfile` that were present solely to satisfy this dependency.
  `cpm install Amazon::API` will no longer pull in the LWP stack.
