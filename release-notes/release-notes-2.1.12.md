# Amazon::API 2.1.11 Release Notes

**Release Date:** 2026-04-02

## Overview

This is a minor update that simplies `Amazon::API::HTTP::Response` and
updates the same class to maintain compatibility with Perl 5.10.

---

## Changes

### `Amazon::API::HTTP::Response`

This class exists purely to wrap an `HTTP::Tiny` response hashref in an
object with five fixed, read-only methods. It will never need
subclassing, never need additional generated accessors, and has no
caller-facing interface beyond those five methods. The
parent/mk_accessors machinery adds a dependency and generates dead
code.

The `content_type` method has been updated to maintain compatibility
with Perl 5.10.  Perl 5.14 (Released 2011): Added the /r
modifier. Without it, Perl tries to perform the substitution on the
result of the // operation (which is a temporary value/rvalue),
leading to a "Modification of a read-only value attempted" or a
general syntax error depending on the exact context.

---
