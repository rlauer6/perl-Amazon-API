# README

![badge](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiSU52WEFWelBPWXIyeE8wYnY3NXZ1WWRJV1hTQW02aEpUOTlnQVkyMzFqVVduKzFOUkRMM3NRZVJMdnpiR1YyamFUMTI3Nlk1cyt5NFBVV2tJVlJqa0FFPSIsIml2UGFyYW1ldGVyU3BlYyI6ImFPN3hMQ2lLVTZOT2RzbFkiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)

This is the README file for the `perl-Amazon-API` project...

# Description

Base class for Amazon APIs.  See `perldoc Amazon::API`

# Requirements for Building

* `autoconf`, `automake`
* `make`

# Installation

```
git clone https://github.com/rlauer6/perl-Amazon-API.git
cd perl-Amazon-API
./bootstrap
./configure --with-perl5libdir
sudo make && sudo install
```

# Build an RPM

```
git clone https://github.com/rlauer6/perl-Amazon-API.git
cd perl-Amazon-API
./bootstrap
./configure --with-perl5libdir
make dist && rpmbuild -tb $(ls -t perl-Amazon-API*.gz|head -1)
```

# Build a CPAN Distribution

```
git clone https://github.com/rlauer6/perl-Amazon-API.git
cd perl-Amazon-API
./bootstrap
./configure --with-perl5libdir
make cpan
```

# Examples

You can find some examples of how to use this API in the
`src/examples` directory.  See the [README.md](src/examples/README.md)
in that directory.

# Author

Rob Lauer  <rlauer6@comcast.net>
