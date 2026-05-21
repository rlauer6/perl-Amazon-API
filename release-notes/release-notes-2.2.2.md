# Amazon::API Release Notes

## 2.2.2

### Bug Fix

**`Serializer::serialize` - malformed ISO 8601 timestamps with sub-second precision.**

Two bugs in the nanosecond timestamp formatting path:

1. `'%Y-%m-%dT%H:%M:%S.%%d%z'` - `%%d` in a strftime format string
   produces the literal two characters `%d`, not a formatted value.
   The resulting timestamp contained a literal `%d` substring.

2. `$data .= sprintf '.%03d', $nanoseconds` was appended after `%z`
   (the timezone offset), producing `2026-03-25T15:23:05+0000.891`
   instead of the correct `2026-03-25T15:23:05.891+0000`.

Fixed by splitting the strftime call so fractional seconds are
inserted before the timezone:

```perl
$data  = strftime( '%Y-%m-%dT%H:%M:%S', localtime $epoch );
$data .= sprintf '.%03d', $nanoseconds;
$data .= strftime( '%z', localtime $epoch );
```

This affected any AWS API response that includes a `timestamp` shape
with sub-second precision - notably ECR `imagePushedAt`, Lambda
`LastModified`, and CloudWatch event timestamps.

---

### Other Changes

**Release notes for 2.2.1 added retroactively** to
`release-notes/release-notes-2.2.1.md`. Previous release notes
files relocated from project root into `release-notes/` subdirectory.
`release-notes.md` symlink added pointing to current release.

---

## 2.2.1

See `release-notes/release-notes-2.2.1.md`.
