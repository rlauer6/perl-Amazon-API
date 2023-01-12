# README

This directory contains a `Makefile` that will help you create Perl
classes for Amazon APIs and package them as a CPAN distribution.

# Requirements

Along with a standard set of Linux utilities you will also need to
have installed the following tools:

* `make`
* [`make-cpan-dist`](https://github.com/rlauer6/make-cpan-dist.git)

You must have access to the internet in order to clone the Botocore
repository. If you have this checked out somewhere, set the
`BOTOCORE_PATH` environment variable to the root of that project. If
you do not have it checked out, the `Makefile` will clone that
repository in the current working directory.

# Instructions

The instructions assume you have cloned the `perl-Amazon-API` project
and installed the Perl modules and other artifacts in your working
environment. For details on installing the project see
[README-BUILD.md](README-BUILD.md) in the root
of this project.

To create a CPAN tarball then, follow these steps:

```
cd cpan-dist
make SERVICE=sts
```

You provide the AWS API service name and possibly the module name to
be created as environment variables to the `Makefile`. The service
name should correspond to an existing AWS service. The service names
correspond to the services listed in the Botocore project. You can get
a listing of the services like this:

```
cd cpan-dist
make list-services
```

For example, to create a class for the SQS API named
`Amazon::API::SQS`:

```
make SERVICE=sqs
```

This will create a distribtion for the module `Amazon::API::SQS`. If
you don't like that name, you can provide a module name when you
create the distribution.

```
make SERVICE=sqs MODULE_NAME=SimpleQueueService
```

To make things just a bit more flexible, we can derive the service
name from the module name too (if the service actually exists).

```
make MODULE_NAME=EC2
```

...which will create an API module for the `ec2` service.
