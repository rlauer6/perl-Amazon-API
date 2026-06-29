# Release Notes — Amazon::API v2.3.5

**Released:** Mon Jun 29 2026
**Author:** Rob Lauer \<rclauer@gmail.com\>

---

## Overview

Version 2.3.5 is a bug-fix release addressing a correctness issue in
the `_init_map` method of `Amazon::API::Botocore::Shape`. This fix
ensures that **all** key-value pairs within a map element are
processed, rather than silently dropping all but the first entry. This
bug particularly affected multi-key maps such as the Lambda
`EnvironmentMap`.

---

## Bug Fixes

### `Amazon::API::Botocore::Shape` — `_init_map` processes all key-value pairs

**File:** `src/main/perl/lib/Amazon/API/Botocore/Shape.pm.in`

Previously, `_init_map` extracted key-value pairs from each map
element using `my @kv = %{$elem}` and then only referenced `$kv[0]`
and `$kv[1]`, which silently discarded every key-value pair beyond the
first in any multi-key map element.

This release replaces the single-pair access with a `pairs`-based loop
(from `List::Util`) that correctly iterates over **all** key-value
pairs within each element:

```perl
for my $pair ( pairs @kv ) {
    my ( $k, $v ) = @{$pair};
    push @list, { $k => $value_class->new($v) };
}
```

The existing behaviour of using the plain key string (rather than a
blessed shape object) as the hash key is preserved, avoiding the
stringification bug introduced in earlier versions that caused
query/ec2 protocol key corruption.

**Impact:** Any API call that passes a map shape with more than one
key-value pair per element (e.g. Lambda `EnvironmentMap`) will now be
serialized correctly.

---

## Build / Housekeeping

### `Makefile.am` — `clean-local` target added

A `clean-local` target has been added to remove build artefacts left
behind during development and distribution builds:

```makefile
clean-local:
    rm -rf *.diffs *.lst *.tar.gz
```

---

## Files Changed

| File | Change |
|---|---|
| `VERSION` | Bumped to `2.3.5` |
| `README.md` | Regenerated from POD |
| `src/main/perl/lib/README.md` | Regenerated from POD |
| `src/main/perl/lib/Amazon/API/Botocore/Shape.pm.in` | Bug fix in `_init_map` |
| `Makefile.am` | Added `clean-local` target |
| `release-notes.md` | Updated |
| `release-notes/release-notes-2.3.5.md` | New file |
| `cpan/Makefile.am` | remove -s option ($SCANDEPS) |

---

## Upgrade Notes

This is a drop-in replacement for v2.3.4. No API changes have been
made and no new dependencies have been introduced. Users passing
multi-key maps to Botocore-backed API calls (most notably Lambda
environment variable maps) should upgrade to avoid silent data loss
during request serialization.
