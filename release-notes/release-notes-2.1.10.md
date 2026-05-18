# Amazon::API 2.1.10 Release Notes

**Release Date:** 2026-03-27

## Overview

This release is a significant bug-fix release addressing protocol correctness,
serializer robustness, and type system integrity across the botocore shape
framework. Several bugs had been silently dormant due to insufficient test
coverage across protocol edge cases. All fixes were validated against live AWS
APIs including STS `GetCallerIdentity` and IAM `SimulatePrincipalPolicy`.

---

## Bug Fixes

### `Amazon::API` (`API.pm`)

**Logging never worked when setting log level in constructor**

Two bugs conspired to make debug logging non-functional:

- `_set_default_logger` called `$logger->additivity(0)` on an instance logger
  with no appender of its own. With additivity disabled and no local appender,
  all log output was silently discarded regardless of the level set. The
  `additivity(0)` call has been removed.

- `_set_defaults` was receiving `%options` after `log_level` had been removed
  via `delete`, causing it to unconditionally reset the log level to `'info'`.
  `log_level` is now passed explicitly to `_set_defaults`.

**`query` protocol responses returned empty hashrefs**

`XMLin` was called with `KeepRoot => 1`, producing a top-level
`{OperationName}Response` wrapper key. The subsequent `resultWrapper` lookup
operated on this wrapped structure and found nothing, yielding `undef` to the
serializer which returned `{}`. The fix strips the outer `Response` wrapper
for `query` protocol responses before the `resultWrapper` lookup.

**`Action` parameter silently omitted from query protocol requests**

`create_urlencoded_content` used `/Action/xsm` as a regex match against all
args to detect whether `Action` was already present. This matched
`ActionNames.member.1` and similar parameter names, causing the actual
`Action=OperationName` parameter to be omitted. AWS responded with a 302
redirect. Fixed to use exact string equality: `$_ eq 'Action'`.

**`query` protocol list parameters serialized without `.member.N` notation**

The `init_botocore_request` dispatch only handled `ec2` protocol with
`param_n` expansion. `query` protocol fell through with the raw finalized
hash, causing list parameters like `ActionNames` to be serialized as
`ActionNames=HASH(0x...)` on the wire. A new `query_param_n` function
inserts `.member.` between the parameter name and index
(`ActionNames.member.1=...`) as required by the query protocol specification.
`query` protocol now has its own dispatch branch using `query_param_n`.

**`finalize` not passing protocol to shape objects**

`$request->finalize` was called without protocol context, forcing
`finalize_list` to use a class name regex (`ref($self) !~ /ec2/ixsm`) to
detect ec2 protocol. Protocol is now passed as an argument to `finalize` and
propagated through recursive calls via a `local $PROTOCOL` package variable,
eliminating the class name sniff.

**`query` protocol lists incorrectly wrapped in locationName hash**

`finalize_list` wrapped list output in `{ locationName => $list }` for any
non-ec2 service with a `locationName` on the list member. This produced a
hash instead of a bare array for `query` protocol services (e.g. RDS,
AutoScaling), which `query_param_n` then could not correctly serialize.
Both `ec2` and `query` now produce bare arrays from `finalize_list`.

---

### `Amazon::API::Botocore::Shape::Serializer` (`Serializer.pm`)

**False/zero/empty member values caused wrong data to be passed to child serializer**

`_serialize_structure` used `$member_data || $data` to select the data
argument for recursive serialization. For members with false, zero, or empty
string values (including empty XML elements like `<MissingContextValues/>`),
`||` short-circuited to `$data` — the entire parent structure — causing the
wrong data to be serialized into child shapes. The condition now uses
`exists $data->{$location_name}` as the discriminator, which correctly
handles all falsy values including empty strings from XMLin.

**Empty XML list elements serialized as `['']` instead of `[]`**

When an XML element representing a list was empty (`<Foo/>`), XMLin produced
`''`. `_serialize_list` passed this to the list iterator which wrapped it as
`['']` and attempted to serialize a single empty-string element. A guard
now returns `[]` immediately for any defined non-reference empty string list.

**Timestamp fractional seconds formatted incorrectly**

The nanoseconds formatting used `".$nanoseconds" * 1_000_000` which
coerced a string like `".123"` to a number, producing nonsensical output.
Fixed to `sprintf '.%03d', $nanoseconds` which correctly zero-pads the
fractional seconds.

---

### `Amazon::API::Botocore::Shape` (`Shape.pm`)

**`_init_map` operator precedence error on element type check**

`!ref $elem eq 'HASH'` evaluated as `(!ref $elem) eq 'HASH'` — comparing a
boolean to the string `'HASH'` — so the guard never caught non-HASH elements.
Fixed to `ref($elem) ne 'HASH'`.

**`_init_map` called `get_member` on a map shape**

Map shapes have `key` and `value` sub-shapes, not `member`. `get_member`
returns `undef` for map shapes, causing a fatal "Can't call method 'shape' on
undef" for any non-flattened map input. Fixed to use `get_key` and
`get_value` to instantiate the appropriate shape classes for both key and
value elements. Note: the `is_flattened` early return means this code path
was unreachable for all previously tested services; the fix makes the path
correct rather than fatal.

---

### `Amazon::API::Botocore::Shape::Utils` (`Utils.pm`)

**`check_pattern` never validated anything**

`my ( $value, $pattern );` declared locals without unpacking `@_`, leaving
both always `undef`. Pattern validation was silently a no-op for all string
shapes. Fixed to `my ( $value, $pattern ) = @_`.

**`check_type` tested truthiness rather than equality**

`any {$type} @{$required_type}` evaluated `$type` as a boolean for each
element rather than comparing it to each element. Any non-empty `$type`
string passed validation unconditionally. Fixed to
`any { $type eq $_ } @{$required_type}`.

**`param_n` crashed on HASH structures containing scalar leaf values**

The first-call sentinel `!defined $idx` was passed through unchanged
(`undef`) in HASH recursion, so the croak guard fired on any scalar leaf
value reached via a HASH key. Fixed by passing `$idx // 0` in the HASH
branch, preserving `undef` as the first-call indicator while allowing scalar
leaves to be reached through hash recursion.

**New: `query_param_n`**

New exported function implementing the `query` protocol list serialization
convention. Identical to `param_n` except the array branch uses
`$prefix.member.$idx` notation rather than `$prefix.$idx`, producing the
`ActionNames.member.1` format required by IAM, STS, SQS, SNS, and other
query protocol services.

---

## Upgrade Notes

All fixes are backwards compatible. No API changes. Services that were
working before will continue to work. The fixes correct silent failures and
crashes in previously untested code paths.

If you have previously worked around the log level issue by initialising
`Log::Log4perl` externally before constructing an `Amazon::API` subclass,
that approach continues to work — `_set_default_logger` only initialises
Log4perl if it has not already been initialised.
