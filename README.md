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

# Stubs

This distribution also includes stubs that you can use as base
classes to create more robust API classes. These stubs create the base
class for several Amazon APIs that contain methods for all of the
current API actions for that service.  The methods invoke the API with
parameters you must provide in the correct format.  See the
`Amazon::API` documentation for details on passing parameters to AWS
services.  See the Amazon API documentation for the service you are
using for a complete description of the parameters for each service.

## Using the Stubs

Typically you use the base classes to higher level methods that
provide more useful by utilizing one or more of the API methods
calls. For example, you might want to fetch all of the subnets for a
given VPC.

```
package Amazon::EC2;

use strict;
use warnings;

# start with the stub
use parent qw{ Amazon::API::EC2 };

use Amazon::API qw{ param_n };
use Carp;
use Scalar::Util qw{ reftype };

caller or __PACKAGE__->main();

sub get_subnets_by_vpc {
  my ( $self, $vpc_id ) = @_;

  croak "usage: get_subnets_by_vpc(vpc-id)\n"
    if !$vpc_id;

  my $filter = {
    Filter => [
      { Name  => 'vpc-id',
        Value => [$vpc_id]
      }
    ]
  };

  return $self->DescribeSubnets( [ param_n($filter) ] );
}

sub get_vpc_by_tag {
  my ( $self, $key, $value ) = @_;

  my $vpcs = $self->DescribeVpcs->{vpcSet}->{item};

  foreach my $vpc ( @{$vpcs} ) {
    my $tag_set = $vpc->{tagSet}->{item};

    if ( ref($tag_set) && reftype($tag_set) eq 'HASH' ) {
      if ( $tag_set->{$key} && $tag_set->{$key}->{value} eq $value ) {
        return $vpc;
      }
    }
  }

  return;
}

sub main {
    use Data::Dumper;

    my $vpc_name = shift @ARGV || 'dev';

    my $ec2 = Amazon::EC2->new;
    
    my $vpc = $ec2->get_vpc_by_tag('Name', $vpc_name);
    
    croak "no vpc named $vpc_name\n"
      if !defined $vpc;

    print Dumper [ $ec2->get_subnets_by_vpc($vpc->{vpcId}) ];
}

1;
```


# Author

Rob Lauer  <rlauer6@comcast.net>
