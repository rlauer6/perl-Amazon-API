# Amazon::API 2.2.5 Release Notes

## Overview

2.2.5 fixes a bug where boolean request parameters caused query-protocol
(and EC2-protocol) API calls to crash with `Not an ARRAY reference`. The
request serializer unconditionally represented boolean values as blessed
`JSON::PP::Boolean` scalar references - correct for JSON-protocol services,
but fatal for query-protocol services, whose parameter flattener
(`Botocore::Shape::Utils::param_n`/`query_param_n`) only understands plain
scalars, hashrefs, and arrayrefs. Discovered via SNS's `Subscribe` operation
(`ReturnSubscriptionArn`, a `boolean`-shaped parameter), but the bug affected
any boolean parameter passed to any query- or EC2-protocol service.

---

## Bug Fixes

### finalize / serialize - boolean parameters broke query-protocol requests

Both `Amazon::API::Botocore::Shape::finalize` (the primary code path for
request finalization) and `Amazon::API::Botocore::Shape::Serializer::serialize`
mapped boolean values to `JSON::PP::true`/`JSON::PP::false` unconditionally:

```perl
elsif ( $type eq 'boolean' ) {
    return $val ? JSON::PP::true : JSON::PP::false;
}
```

`JSON::PP::true`/`JSON::PP::false` are blessed scalar references. For
query-protocol services (SNS, SQS, EC2, and others using the older
AWS query-string protocol), the finalized request is flattened into
`key=value` pairs by `param_n`/`query_param_n`, which dispatch on
`reftype`: hashrefs recurse into keys, anything else is assumed to be an
arrayref and dereferenced with `@{$message}`. A blessed scalar ref has
`reftype` `SCALAR`, so it fell into the array branch and crashed:

```
Not an ARRAY reference at .../Botocore/Shape/Utils.pm line 426.
```

Fixed by checking the active protocol before deciding how to represent the
boolean. Query and EC2 protocols now get a plain `1`/`0`; JSON-style
protocols keep the blessed `JSON::PP::true`/`JSON::PP::false` sentinel
(needed so the eventual `encode_json` call emits `true`/`false` rather than
`"1"`/`"0"`):

```perl
elsif ( $type eq 'boolean' ) {
    my $bool_value = $val ? 1 : 0;

    return $bool_value
        if $PROTOCOL && $PROTOCOL =~ /^(?:query|ec2)$/xsm;

    return $bool_value ? JSON::PP::true : JSON::PP::false;
}
```

The same protocol-conditional fix was applied to `Serializer::serialize`'s
`boolean` handler, which contains equivalent (if currently less-exercised)
logic.

---

## Upgrade Notes

Any query- or EC2-protocol API call that includes a `boolean`-shaped
parameter was affected - for example, SNS's `Subscribe`
(`ReturnSubscriptionArn`), SQS, and others. JSON-protocol services
(Lambda, IAM, ECR, etc.) are unaffected; their boolean handling is
unchanged. Upgrade is recommended for all users of query-protocol
services with boolean parameters.
