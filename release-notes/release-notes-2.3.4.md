# Amazon::API 2.3.4 Release Notes

## Summary

Two bug fixes found during live ELBv2 testing: query-protocol
detection now uses botocore metadata directly rather than a hardcoded
service name list, and `finalize_map` correctly handles non-flattened
maps with no key/value location names (e.g. Lambda `EnvironmentMap`).
Minor export additions to `Amazon::API::Botocore` and a clearer error
message in `Amazon::API::Botocore::Services`.

---

## Changes

### `Amazon::API` — `serialize_content`

**Protocol detection from botocore metadata**

The query-protocol branch previously checked `lc $self->get_service`
against `@API_TYPES{query}` — a hardcoded list of service names. This
failed for services where `service_url_base` (the endpoint hostname
prefix) differs from the botocore service name, e.g. `ELBv2` sets
`service_url_base` to `elasticloadbalancing` which is not in the list.

The check now reads `$self->get_botocore_metadata->{protocol}` first:

```perl
my $protocol = eval { $self->get_botocore_metadata->{protocol} } // $EMPTY;
if ( $protocol eq 'query' || any { $_ eq lc $self->get_service } @{ $API_TYPES{query} } ) {
```

The `eval` guard and `$EMPTY` fallback preserve backward compatibility
for non-botocore callers, which continue to use the `@API_TYPES` list.

### `Amazon::API::Botocore::Shape` — `finalize_map`

**Non-flattened maps with no key/value location names**

`finalize_map` now handles a third case alongside the existing
flattened-map and query/ec2 indexed-map paths:

> Non-flattened maps with no `key`/`value` `locationName` (e.g. Lambda
> `EnvironmentMap`) — return a plain hashref with shape values
> finalized.

Previously these maps fell through to the final `return $list` which
returned an arrayref of single-key hashrefs containing blessed shape
objects. `JSON::XS` could not encode the blessed objects, causing a
serialization error when calling `UpdateFunctionConfiguration` or any
other API that accepts a string-value map.

The fix iterates `@elem_list` using `pairs` (avoiding `each`'s
iterator side-effects) and finalizes each value:

```perl
if ( !$key && $PROTOCOL && !( any { $PROTOCOL eq $_ } qw( query ec2 ) ) ) {
  my %plain;
  for my $item (@elem_list) {
    for my $pair ( pairs %{$item} ) {
      my ( $k, $v ) = @{$pair};
      $plain{$k} = blessed $v ? $v->finalize : $v;
    }
  }
  return $location_name ? { $location_name => \%plain } : \%plain;
}
```

### `Amazon::API::Botocore` — export additions

`create_stub`, `create_module_name`, and `paginator` added to
`@EXPORT_OK` and the `:all` export tag. These were already importable
by name but not included in the tag — required by
`Amazon::API::Factory::Event` which imports them directly.

### `Amazon::API::Botocore::Services` — `cmd_list_services`

Clearer error message when `--boto-path` is not set:

```
ERROR: usage: build-boto-services -p botocore-path list-services [service]
```

Previously the missing path was passed to `_check_path` which produced
a less informative error.
