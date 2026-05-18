# Amazon::API Release Notes

## 2.2.1

### Bug Fixes

**`init_botocore_request` - undef dereference on operations with no URI parameters.**

For REST-JSON and REST-XML protocol operations whose `parsed_request_uri` has
no `parameters` key, the expression:

```perl
my @args = @{ $http->{parsed_request_uri}->{parameters} };
```

died with `Not an ARRAY reference` because the key was `undef` rather than
an empty arrayref. Fixed with a `// []` fallback:

```perl
my @args = @{ $http->{parsed_request_uri}->{parameters} // [] };
```

This affected any operation whose URI template contains no substitution
parameters (e.g. simple `GET /resource` endpoints), causing the call to
fail before the request was even constructed.

**`Serializer::serialize` - incorrect load and import of `strftime`.**

The timestamp serialization path used:

```perl
load 'POSIX::strftime';
POSIX::strftime->import('strftime');
```

`POSIX::strftime` is not a module - it is a function exported by the `POSIX`
module. `Module::Load::load` would fail to find it, and the subsequent
`->import` call on a non-existent package would silently produce incorrect
behaviour or a runtime error when serializing timestamp values. Fixed to:

```perl
require POSIX;
POSIX->import('strftime');
```

This affected any API call that serializes a `timestamp` shape, including
services that accept date/time parameters.

---

### Other Changes

**`buildspec.yml` key renames.** Underscored keys renamed to hyphenated
form for consistency with the convention adopted across the distribution
family: `pm_module` => `pm-module`, `test_requires` => `test-requires`,
`exe_files` => `exe-files`. Applies to both `cpan/buildspec.yml` and the
per-service `cpan-dist/buildspec.yml.in` template.

**`CPAN::Maker` added as recommended dependency.** `cpan/recommends` file
introduced with `CPAN::Maker 1.9.1` as the recommended build
toolchain. This is only needed when building tarballs for specific services.

**Release notes reorganized** into `release-notes/` subdirectory.
`release-notes.md` is now a symlink to the current release.

