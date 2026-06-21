# Amazon::API 2.2.7 Release Notes

## Overview

2.2.7 fixes `init_botocore_request`'s construction of the request body for
REST-XML and REST-JSON operations that declare a `payload` member (for
example, CloudFront's `CreateInvalidation`, whose body is the
`InvalidationBatch` member while `DistributionId` is a URI parameter).
Affected calls sent an **empty request body**, which AWS rejected with a
validation error on the payload member.

---

## Bug Fixes

### init_botocore_request — empty body for payload-bearing REST operations

After resolving which request-shape member is the `uri`-located parameter
versus the `payload`-located body, the code reassigned `%parameters` to the
unwrapped payload contents:

```perl
if ( $request->{payload} && $parameters{$request_shape_name}->{ $request->{payload} } ) {
    %parameters = %{ $parameters{$request_shape_name} };
    ...
}
```

A few lines later, the function that resolves the actual request content
looked the payload back up by the *original*, now-overwritten key:

```perl
my $inner = $parameters{$request_shape_name};
$content = ( $inner && keys %{$inner} ) ? $inner : undef;
```

Once `%parameters` had been reassigned, `$request_shape_name` no longer
existed as a key — `$inner` was always `undef`, and the request body was
silently empty. (A second, related issue: `$request->{payload}` read the
payload member name from `$request`, which by this point has been
reassigned to a blessed Botocore shape object and does not carry a
`payload` key; the correct source is the operation's `$input` metadata.)

Fixed by leaving `%parameters` in its `$request_shape_name`-keyed shape
intact — mutating the payload member in place only when a namespace
attribute needs to be attached — and reading the payload member name from
`$input->{payload}`:

```perl
if ( $input->{payload} && $parameters{$request_shape_name}->{ $input->{payload} } ) {
    if ( $self->get_namespace ) {
        $parameters{$request_shape_name}->{ $input->{payload} }->{_attr} = { xmlns => $self->get_namespace };
    }
}
```

---

## Tests

A new regression test, `t/04-rest-xml-payload.t`, drives
`init_botocore_request` against a minimal hand-authored botocore model
shaped like CloudFront's `CreateInvalidation` (one `uri`-located member,
one `payload`-located structure) and asserts: the URI member is extracted
and absent from the body, the payload member's contents survive into the
returned parameters, and `serialize_content` produces non-empty XML
containing the expected elements.

---

## Upgrade Notes

Any REST-XML or REST-JSON operation with a declared `payload` member was
affected — for example, CloudFront's `CreateInvalidation`. Operations
without a distinct payload member (where the whole request body maps
directly to the request shape) were not affected. Upgrade is recommended
for any caller of a `payload`-bearing REST-XML/REST-JSON operation.
