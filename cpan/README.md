# README

This the README for building a CPAN distribution for this project. It
is mainly for use by the maintainer(s) of `Amazon::API`.

# Requirements

In order to use the Makefile in this directory to create a CPAN
distribution you should have the `make-cpan-dist` utility installed.
You can find that here:

[`make-cpan-dist`](https://github.com/rlauer6/make-cpan-dist)

# Building a CPAN Distribution

Before building and uploading a tarball, make sure that"

1. `ChangeLog` has been updated
1. `VERSION` has been bumped
1. The build is valid
1. All changes have been committed

To verify that the build is valid...

```
./bootstrap
./confgure
make clean
make distcheck
rpmbuild -tb $(ls -1t Amazon-API*.tar.gz | tail -1)
```

You can now build a CPAN tarball from the `cpan` or root directory of the
project.

```
make cpan
```

# Uploading the Distribution to CPAN

Use the `upload2cpan` utility to upload the tarball.
