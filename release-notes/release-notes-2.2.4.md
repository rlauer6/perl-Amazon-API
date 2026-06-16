# Amazon::API 2.2.4 Release Notes

## Overview

2.2.4 fixes a bug in `create_urlencoded_content` where the API `Version`
parameter was incorrectly suppressed for query-protocol APIs whose input
includes a parameter value containing the string "Version" — most notably
IAM's `CreateRole`, where the `AssumeRolePolicyDocument` JSON body contains
a `"Version"` key. This caused `CreateRole` to be submitted without the
required `Version=2010-05-08` query parameter, resulting in an AWS 400 error:
"Could not find operation CreateRole for version NO_VERSION_SPECIFIED".

---

## Bug Fixes

### create_urlencoded_content — Version parameter clobbered by parameter values

`create_urlencoded_content` builds the query string from a flat `@args` list
of alternating key/value pairs, then checks whether to append the API version
with:

```perl
if ( $version && !any {/Version/xsm} @args ) {
    push @args, 'Version', $version;
}
```

The regex match ran against all elements of `@args` — including values, not
just keys. For `CreateRole`, the value of `AssumeRolePolicyDocument` is a
JSON string containing `"Version":"2012-10-17"`, which matched the regex,
incorrectly suppressing the `Version=2010-05-08` API version parameter.

Fixed by converting `@args` to a hash and checking key existence instead:

```perl
my %arg_hash = @args;

if ( $version && !exists $arg_hash{Version} ) {
    push @args, 'Version', $version;
}
```

This correctly checks only top-level parameter keys, leaving parameter values
unexamined.

---

## Upgrade Notes

Any query-protocol API call whose input contains a parameter with "Version"
in its value was affected. IAM `CreateRole` is the confirmed case. No other
behavioral changes; upgrade is recommended for all users of IAM or other
query-protocol APIs with structured document parameters.
