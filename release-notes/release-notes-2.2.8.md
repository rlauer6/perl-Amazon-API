# Amazon::API 2.2.8 Release Notes

## Overview

2.2.8 fixes a follow-on issue from 2.2.7's `init_botocore_request` repair:
the payload member name was being read from the wrong place, so the XML
namespace attribute was never actually attached to the payload element, and
every REST-XML/REST-JSON call with a namespace emitted an uninitialized-value
warning.

---

## Bug Fixes

### init_botocore_request - payload member read from the wrong shape

2.2.7 fixed the empty-body regression but left the payload-member lookup
reading from the operation's `$input` metadata:

```perl
if ( $input->{payload} && $parameters{$request_shape_name}->{ $input->{payload} } ) {
    ...
}
elsif ( $self->get_namespace ) {
    my $locationName = $input->{locationName};
    $parameters{$locationName}->{_attr} = { xmlns => $self->get_namespace };
}
```

`$input` (`$botocore_operations->{$action}{input}`) only ever carries
`{ shape => ... }` - it never carries `payload` or `locationName`. Those are
declared on the **shape definition** itself
(`get_botocore_shapes->{$request_shape_name}`). As a result:

- `$input->{payload}` was always `undef`, so the `if` branch never ran and
  the namespace `xmlns` attribute was never attached to the payload element
  for any call.
- Every call fell through to the `elsif`, where `$input->{locationName}` was
  also always `undef`, producing `Use of uninitialized value $locationName
  in hash element` on every REST-XML/REST-JSON request with a namespace.

This was silent and mostly harmless for calls AWS doesn't strictly enforce a
namespace declaration on (e.g. CloudFront's `CreateInvalidation` succeeded
in 2.2.7 despite it), but it left the namespace handling non-functional and
produced log noise on every call.

Fixed by reading `payload` from the shape definition, and using
`$request_shape_name` directly (rather than the always-empty
`locationName`) when there is no distinct payload member:

```perl
my $request_shape_def = $self->get_botocore_shapes->{$request_shape_name} // {};
my $payload_member    = $request_shape_def->{payload};

if ( $payload_member && $parameters{$request_shape_name}->{$payload_member} ) {
    if ( $self->get_namespace ) {
        $parameters{$request_shape_name}->{$payload_member}->{_attr} = { xmlns => $self->get_namespace };
    }
}
elsif ( $self->get_namespace ) {
    $parameters{$request_shape_name}->{_attr} = { xmlns => $self->get_namespace };
}
```

---

## Upgrade Notes

No behavior change for callers whose requests don't require the `xmlns`
namespace attribute to be present (most REST-XML services tolerate its
absence, which is why 2.2.7 worked in practice). Services that validate the
namespace attribute strictly should now serialize correctly; the
uninitialized-value warning is also gone from every REST-XML/REST-JSON call.
