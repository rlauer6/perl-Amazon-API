# README

This directory contains a `Makefile` that will help you create Perl
classes for Amazon APIs and package them as a CPAN distribution.

# Requirements

Along with a standard set of Linux utilities you will also need to
have installed the following tools:

* `make`
* [`make-cpan-dist`](https://github.com/rlauer6/make-cpan-dist.git)

You must have access to the internet in order to clone the Botocore
repository. If you have the Botocore repo checked out somewhere, set the
`BOTOCORE_PATH` environment variable to the root of that project. If
you do not have it checked out, the `Makefile` will clone that
repository in the current working directory.

# Quickstart

1. Install the `Amazon::API` project from CPAN or build and install from source
1. Run `make` to create a CPAN distribution for the desired service or
   to list available services.
   
| `make` Target | Argument | Description |
| ------------- | -------- | ----------- |
|               | SERVICE=service  | Create a CPAN distribution for service |
| list-services |          | List all available services |

# Instructions

The instructions assume you have cloned and built the
`perl-Amazon-API` project and installed the required Perl modules and other
artifacts in your working environment. For details on installing the
project see [README-BUILD.md](README-BUILD.md) in the root of this
project.

To create a CPAN tarball for the Security Token Service, for example
follow these steps:

```
cd cpan-dist
make SERVICE=sts
```

You provide the AWS API service name and possibly the module name to
be created as environment variables to the `Makefile`. The service
name should correspond to an existing AWS service. The service names
supported correspond to the services listed in the Botocore
project. You can get a listing of the services like this:

```
cd cpan-dist
make list-services
```

For example, to create a class for the SQS API named
`Amazon::API::SQS`:

```
make SERVICE=sqs
```

This will create a distribtion tarball for the module `Amazon::API::SQS`. If
you don't like that name, you can provide a module name when you
create the distribution.

```
make SERVICE=sqs MODULE_NAME=SimpleQueueService
```

To make things just a bit more flexible, we can derive the service
name from the module name too (if the service is the same as the
module name and the service actually exists).

```
make MODULE_NAME=EC2
make MODULE_NAME=Route53
```

...which will create API moduled for the `ec2` and `route53`
services.

# Help

After installing the module using `cpanm` you can display help for the
service or for any of the service methods.

```
cpanm -l $HOME -v Amazon-API-SQS-2.0.12.tar.gz
amazon-api -s sqs help
amazon-api -s sqs help ListQueues
```
