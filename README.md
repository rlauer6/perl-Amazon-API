# README

This is the README file for the `perl-Amazon-API` project...

# Description

Base class for Amazon APIs.  See `perldoc Amazon::API`

```
# Installation

```
git clone https://github.com/rlauer6/perl-Amazon-API.git
cd perl-Amazon-API
./configure --with-perl5libdir
sudo make && sudo install
```

# Build an RPM

```
git clone https://github.com/rlauer6/perl-Amazon-API.git
cd perl-Amazon-API
./configure --with-perl5libdir
make dist && rpmbuild -tb $(ls -t perl-Amazon-API*.gz|head -1)
```

# Author

Rob Lauer  <rlauer6@comcast.net>
