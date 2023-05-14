# README

This is the README file for the `docker` directory.  In this directory
you will find a Docker build file for building an rpm version of the
`Amazon::API` Perl module and a build file for creating a container
that can execute the `create-service` utility allowing you to create
CPAN distributions for individual AWS services.

# Requirements

* `docker`

# Building the Containers

Two containers are built using the Makefile in this directory. Simply
type `make -f Makefile.docker` and the `amazon-api` and `rpmbuilder`
containers will be built.

# Building an RPM use `rpmbuilder`

Follow the instructions below to create an rpm package for the
`Amazon::API` module.

Mount some directory to `/scratch` and run the `rpm-build` utility in
the container. The result will be an rpm you can use to install
`Amazon::API`

```
mkdir scratch
docker run --rm -v $(pwd):scratch:/scratch rpmbuilder \
   /usr/bin/rpm-build https://github.com/rlauer6/perl-Amazon-API

ls -alrt scratch
```

# Creating a CPAN Distribution for an AWS Service

The `Amazon::API` project includes a utility `create-service` which
can be uses to create a CPAN distribution of a single AWS service
(e.g. EC2 or SQS). Some may find it difficult to install all of the
dependencies necessary to run `create-service`. An easier way to
create a single CPAN distribution of an AWS service is use the service
from a container.

The `Makefile` in this directory will create such a Docker container.
You can then run a local utility called `create-cpan-dist`
located in this directory to create the service.

Assuming you have Docker installed, this makes creating a service as
simple as:

```
git clone https://github.com/rlauer6/perl-Amazon-API
cd perl-Amazon-API/docker
make
```

Once the container is built, you can create a CPAN distribution as
shown below:

```
create-cpan-dist -s sqs -m SQS
```

```
usage: ./create-cpan-dist options

Utility to create a CPAN distribution for an AWS API

Creates a CPAN distribution (tarball) containing the specified AWS API
class. The Perl class create will be named Amazon::AWS::{ModuleName}
where {ModuleName} is the argument you pass to using the -m option. If
you do not pass a module name, the suffix for the calls will be
generated based on these rules:

 - if the service is a TLA (ec2, efs, sqs, etc), the suffix will be
   the uppper case representation of the TLA.

 - if the service name is greater than 3 characters, the suffix will
   be the service name with the first letter upper cased (Example:
   Route53).

Options
-------
-h               help
-m module name   suffix name for the module
-s service name  name of the AWS API service (lower case)

This utility is part of the Amazon::API distribtion.

Examples:

 ./create-cpan-dist -s sqs -m SQS

 ./create-cpan-dist -s route53 -m Route53
```
