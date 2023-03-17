# README

![badge](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiSU52WEFWelBPWXIyeE8wYnY3NXZ1WWRJV1hTQW02aEpUOTlnQVkyMzFqVVduKzFOUkRMM3NRZVJMdnpiR1YyamFUMTI3Nlk1cyt5NFBVV2tJVlJqa0FFPSIsIml2UGFyYW1ldGVyU3BlYyI6ImFPN3hMQ2lLVTZOT2RzbFkiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)

This is the `README-BUILD` file for the `perl-Amazon-API` project. This
page is for maintainers and those wanting to hack on the project. If
all you want to do is install the Perl module you can download the
[`Amazon::API`](https://metacpan.org/pod/Amazon::API) module
from CPAN.

# Requirements for Building

This project is [_autoconfiscated_](https://foldoc.org/autoconfiscate)
so you'll need the _autoconf/automake/libtools_ utilities. 

## Autotools

* `autoconf`
* `automake`
* `make`

## Perl Modules

When you run `configure`, a check will be made for the Perl modules
required for this project.  The requirement for Perl modules includes
the versions that I currently have in my working enviroment, however
lower versions _may_ work as well. If you want to experiment with lower
versions of these modules, you can either edit the `requirements.json`
file or the
[`autotools/ax_requirements_check.m4`](autotools/ax_requirements_check.m4)
macro.

To disable version checking for all modules, regenerate the M4 macro that
checks for Perl modules.

```
rm autotools/ax_requirements_check.m4
make -f Makefile.requirements NO_VERSION=1
```

Alternatively, you can prevent `configure` from aborting during 
dependency checking. A check will still be done, but
`configure` will just report the missing or out of date modules.

```
./configure --disable-perldeps
...
checking for for HTTP::Request 6.37... (6.37) /home/rclauer/lib/perl5/HTTP/Request.pm
checking for for IO::Pager 2.10... no (ok)
```

Perl module requirements for the project may change over time. You
can generate a new list of dependencies as shown below. Since the M4
macro that checks for Perl modules is required a separate `Makefile`
was created to determine Perl module dependencies.

```
make -f Makefile.requirements clean
make -f Makefile.requirements
```

* See [`requirements.json`](requirements.json)

## RPM Building

* `rpmbuild` (only if you want to build RPMs)

## Miscellaneous Utilities Also Required

* (`make-cpan-dist`)[https://github.com/rlauer6/make-cpan-dist.git]
  (only if you want to create a CPAN distribution)
* (`scandeps-static.pl`)[https://github.com/rlauer6/Module-Scandeps-Static.git]

# Installation

```
git clone https://github.com/rlauer6/perl-Amazon-API.git
cd perl-Amazon-API
./bootstrap
./configure --with-perl5libdir
make
make check
sudo make install
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
You'll find the distribution in the `cpan` directory.

# Examples

You can find some examples of how to use this API in the
`src/examples` directory.  See the [README.md](src/examples/README.md)
in that directory.

# Author

Rob Lauer  <rlauer6@comcast.net>
