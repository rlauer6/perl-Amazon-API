# Amazon::API 2.3.3 Release Notes

## Summary

Build system fix: `create-modulino` is now located via `autoconf`
rather than called by bare name, ensuring the correct installed version
is used when generating the `build-boto-services` modulino link.

---

## Changes

### `configure.ac`

`AC_PATH_PROG([CREATE_MODULINO], [create-modulino])` added, with a
hard error if `create-modulino` is not found on `PATH`.  This makes
the dependency explicit and surfaced at `configure` time rather than
silently at build time.

### `src/main/bash/bin/Makefile.am`

`CREATE_MODULINO = @CREATE_MODULINO@` substitution variable added.
The `build-boto-services` target now invokes `$(CREATE_MODULINO)`
instead of the hardcoded `create-modulino.pl`, picking up the
installed `CLI::Simple` 2.0.6 modulino wrapper.
