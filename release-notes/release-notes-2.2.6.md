# Amazon::API 2.2.6 Release Notes

## Overview

2.2.6 fixes serialization of map-typed parameters (for example, SNS
`Publish`'s `MessageAttributes`, a `map<String, MessageAttributeValue>`) for
the query and EC2 protocols. Map keys were being destroyed during shape
construction and maps were emitted with the wrong list wrapper, producing a
malformed request that AWS rejected. The bug affected any query- or
EC2-protocol service called with a non-empty map parameter; it did not
affect JSON-protocol services, which serialize maps through a JSON encoder
rather than the query-string flattener.

---

## Bug Fixes

### _init_map - map key destroyed during construction

When building a map shape from a native hashref, `_init_map` used the
constructed key *shape object* as a Perl hash key:

```perl
push @list, { $key_class->new( $kv[0] ) => $value_class->new( $kv[1] ) };
```

Perl stringifies hash keys, so `$key_class->new('Foo')` became
`"Amazon::API::Botocore::Shape::SNS::String=HASH(0x...)"` - the real key
value (`Foo`) was lost before serialization ever ran. Because that
stringified ref contains `=`, the query-string flattener then desynchronized
every subsequent field, so a published message attribute corrupted the
entire request (AWS returned an empty-body 404).

The key is now stored as its plain string value; its botocore shape
(`key.locationName`, e.g. `Name`) is applied later in `finalize_map`, where
it belongs:

```perl
push @list, { $kv[0] => $value_class->new( $kv[1] ) };
```

### finalize_map - wrong wrapper for query/ec2 maps

Non-flattened maps were serialized with the generic `member.N` list wrapper
that `query_param_n` applies to all arrays, producing
`MessageAttributes.member.1.Name=...`. AWS's query protocol expects the
`entry.N` wrapper for maps: `MessageAttributes.entry.1.Name=...`.

`finalize_map` - the only stage that knows it is serializing a map - now
pre-indexes entries into an `entry.N`-keyed structure for the query and EC2
protocols, so the generic walker emits the correct keys. Flattened maps,
unkeyed maps, and JSON-protocol services are unaffected.

The resulting serialized output now matches AWS's own tooling:

```
MessageAttributes.entry.1.Name=Foo
MessageAttributes.entry.1.Value.DataType=String
MessageAttributes.entry.1.Value.StringValue=Bar
```

---

## Tests

A new regression test, `t/03-query-map-shape.t`, drives the real
shape-construction, finalize, and query-string flattening path with a
minimal hand-authored botocore model (no live AWS call) and asserts the
serialized output for a `map<String, structure>` parameter. It guards
against all three failure modes: the stringified-key corruption, the
resulting query-string desync, and the `member`-vs-`entry` wrapper.

---

## Upgrade Notes

Any query- or EC2-protocol API call with a non-empty map parameter was
affected - most notably SNS `Publish` with `MessageAttributes`. JSON-protocol
services (Lambda, IAM, ECR, SQS, etc.) are unaffected. Upgrade is recommended
for any caller publishing SNS messages with attributes or otherwise passing
map-typed parameters to query/ec2-protocol services.
