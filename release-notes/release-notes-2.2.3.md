## Amazon::API 2.2.3 Release Notes

**New Features**
- Added `--localstack` option/accessor to `Amazon::API` - when set,
  automatically points the service URL to `http://localhost:4566` for
  local testing against LocalStack.

**Bug Fixes**
- **Response wrapper detection**: `Shape::Serializer::serialize` now
  only searches for an EC2-style "*Response" wrapper key when the
  protocol is `query` or `ec2`, preventing incorrect unwrapping for
  `rest-json`/`rest-xml` protocols.
- **Request body unwrapping**: `init_botocore_request` now correctly
  unwraps the request shape's inner members for `rest-json`/`rest-xml`
  protocols, sending only the inner hash as the body content
  (previously the wrapper-named hash was sent as-is).
- **Type coercion**: `Shape::finalize` now properly coerces scalar
  values according to their botocore type - `integer`/`long` become
  numeric, `float`/`double` become numeric, and `boolean` becomes
  `JSON::PP::true`/`false` rather than passing through raw values.

**Internal/Other**
- `decode_response` now passes the response `protocol` to the
  serializer via `set_protocol` so serialization behavior can be
  protocol-aware.
- Added debug logging in `Shape::finalize` (including a guard message
  when called on a non-blessed object).
- README regenerated for version 2.2.3.
