# Amazon::API 2.2.9 Release Notes

## Overview

2.2.9 delivers two independent improvements: a fail-fast guard for
undefined URI parameters that previously produced opaque AWS errors far
removed from their actual cause, and a replacement of `XML::LibXML` with
`XML::Twig` for REST-XML request body generation — eliminating a heavy C
compilation dependency and reducing Lambda image build times significantly.

---

## Bug Fixes

### init_botocore_request — die with a clear message when a URI parameter is undef

REST operations that take URI-located parameters (e.g. CloudFront's
`DistributionId` in `CreateInvalidation`, which substitutes into
`.../distribution/{DistributionId}/invalidation`) previously silently
substituted nothing when the parameter value was `undef` — either leaving
the literal `{DistributionId}` placeholder in the URL, or producing an
empty path segment. AWS's resulting error (`InvalidAction`, `NoSuchResource`,
or similar) had no obvious connection to the actual cause.

The root issue: `exists $hash{key}` is true even when `$hash{key}` is
`undef`, so the standard "required field present" validation passes for a
key that exists but carries no value. The URI-substitution loop never
independently validated definedness before splicing the value into the
request URL.

Now fails immediately with a clear message before any network call:

```
CreateInvalidation: required uri parameter 'DistributionId' is undef
```

---

## Improvements

### XML::LibXML replaced with XML::Twig for request XML generation

`generate_xml` and `_to_xml` (used to serialize REST-XML request bodies,
e.g. CloudFront `CreateInvalidation`'s `InvalidationBatch`) previously
depended on `XML::LibXML`, which in turn pulls in `Alien::Build` and
`Alien::Libxml2` — compiling C code as part of the install. This added
significant build time and image size to Lambda deployments.

`XML::Twig` (pure Perl, backed by `expat` which is already present in
the deployment environment via `XML::SAX`) produces structurally
equivalent output across all tested data shapes:

- Simple scalar values
- Nested structures (multiple levels of `HashRef`)
- XML attributes via the `_attr` convention
- Repeated sibling elements from array values
- Special characters in text content (`&`, `<`, `>`)

Equivalence was verified by a new regression test
(`t/05-generate-xml.t`) that generates XML from both implementations,
round-trips each through `XML::Simple::XMLin`, and asserts deep
structural equality. End-to-end equivalence was confirmed by successful
`CreateInvalidation` calls against live CloudFront.

`XML::LibXML` has been removed from the dependency list. `XML::Twig`
has been added.

**Note for Lambda users:** remove `XML::LibXML` from your `cpanfile` (if
explicitly listed) and add `XML::Twig`. The Dockerfile build step that
previously compiled `Alien::Libxml2` is no longer needed and can be
removed — `XML::Twig` installs as a pure Perl module with no compile step.

---

## Upgrade Notes

- `XML::LibXML` is no longer required. Remove it from any explicitly
  declared dependencies.
- `XML::Twig` is now required. It is available on CPAN and installs
  without a C compiler.
- The new `undef` URI parameter check is a hard `croak` — callers that
  previously silently sent malformed requests will now see an exception.
  This is the correct behavior, but any code catching generic `eval`
  errors around API calls should be aware the error message has changed
  from an AWS-side response to a Perl-side exception.
