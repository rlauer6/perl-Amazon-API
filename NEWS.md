# NEWS

This is the `NEWS` file for the `perl-Amazon-API` project. This file
contains information on changes since the last release of the package,
as well as a running list of changes from previous versions.  If
critical bugs are found in any of the software, notice of such bugs
and the versions in which they were fixed will be noted here, as well.

# perl-Amazon-API 2.0.9 (2023-05-21)

Version 2.0.9 fixes a bug for API rest-json API services that also use
query parameters

* fixes to Amazon::API::invoke_api (see ChangeLog)
  
## Enhancements

* None

## Fixes

* use a value of 80 columns when formatting documentation if no screen
  width can be detected.

This version replaces the use of the `DateTime` module for formatting
timestamps with `POSIX::strftime`.  `DateTime` introduces too many
more dependencies than justified for simply formatting a timestamp.

# perl-Amazon-API 2.0.8 (2023-05-14)

Version 2.0.8 contains Docker build files for creating Docker
containers that can:

* create an RPM for the `Amazon::API` distribution
* run the `create-service` utility for creating single AWS API CPAN
  distributions
  
## Enhancements

* RPM builder
* `create-service` Docker container. See [README.md](docker/README.md)

## Fixes

* use a value of 80 columns when formatting documentation if no screen
  width can be detected.

This version replaces the use of the `DateTime` module for formatting
timestamps with `POSIX::strftime`.  `DateTime` introduces too many
more dependencies than justified for simply formatting a timestamp.

## Enhancements

* remove `DateTime` dependency

## Fixes

* `create-service`
  * pass BOTOCORE_PATH to amazon-api if set on command line
  * export BOTOCORE_PATH for `create_cpan_distribution`
  * exit if error creating stubs

# perl-Amazon-API 2.0.7 (2023-05-07)

This version replaces the use of the `DateTime` module for formatting
timestamps with `POSIX::strftime`.  `DateTime` introduces too many
more dependencies than justified for simply formatting a timestamp.

## Enhancements

* remove `DateTime` dependency

## Fixes

* `create-service`
  * pass BOTOCORE_PATH to amazon-api if set on command line
  * export BOTOCORE_PATH for `create_cpan_distribution`
  * exit if error creating stubs

# perl-Amazon-API 2.0.6 (2023-04-20)

This version corrects a bug in the `_create_stealth_logger()` method
when a logger is passed.

## Enhancements

* None

## Fixes

* when passing a logger to the API, the `create_stealth_logger()`
  method was incorrectly trying to detect whether the logging methods
  (DEBUG, e.g.) existed in the namespace. It also failed to uppercase
  the log level when creating the method name.

# perl-Amazon-API 2.0.5 (2023-03-26)

This version corrects a bug in the `create-service` script

## Enhancements

* None

## Fixes

* missing @ in automake variable prevented scandeps from working
  properly
* don't remove temp directory if DEBUG mode

# perl-Amazon-API 2.0.4 (2023-03-17)

This version instroduces the `create-service` utility for creating a
CPAN distribution file for a specific AWS API.

To use the utility you must have the Botocore project somewhere in
an accessible path and a few additional required programs.

```
usage: ./create-service options

Utility to create a CPAN distribution for an AWS API

Options
-------
-h               help
-b path          path to Botocore project
-o path          path for for files (a CPAN distribution will not be create)
-m module name   override of Perl module suffix
-s service name  name of the AWS API service (lower case)
-t               create a regular tarball

Note: To use this utilty to create a CPAN distribution you must have
'make-cpan-dist' which can be found here:

 https://github.com/rlauer6/make-cpan-dist.git

This utility is part of the Amazon::API distribtion (v2.0.4).
```

## Enhancements

* new `create-service` utility

## Fixes

* `configure.ac` updated with correction to `scandeps-static.pl` test.

# perl-Amazon-API 2.0.3 (2023-03-10)

This version fixes a few bugs described below and adds more logging features.

## Enhancements

* log_file, log_layout options added to constructor for logging to
  files and for customizing the log layout

## Fixes

* _set_default_logger() called by the constructor will add stealth
  loggers for Amazon::API and its sub-classes (unless they already exist).
* Readonly for scalars, changed to Readonly::Scalar

# perl-Amazon-API 2.0.2 (2023-02-25)

This version adds `Log::Log4perl` as a dependency. There are no code
changes in this version, only the `requires` file that is used to
create the CPAN distribution has been changed.

## Enhancements

* None - _essentially the same version as 2.0.0_

## Fixes

* None

# perl-Amazon-API 2.0.1 (2023-02-25)

This version adds `Pod::Parser` as a dependency since it may not exist
on some systems. There are no code changes in this version, only the
`requires` files that is used to create the CPAN distribution has been
changed.

## Enhancements

* None - _essentially the same version as 2.0.0_

## Fixes

* None

# perl-Amazon-API 2.0.0 (2023-02-18)

This is the first official release of the experimental version that
employs botocore metadata to create classes for accessing AWS API services.

## Enhancements

* None - _essentially the same version as 1.4.9_

## Fixes

* None

# perl-Amazon-API 1.4.9 (2023-02-18)

This is a minor release which includes edits to documentation

## Enhancements

* None - _essentially the same version as 1.4.8_

## Fixes

# perl-Amazon-API 1.4.8 (2023-01-25)

This version removes improves support for creating stubs and shapes
and fixes the serializer when shapes are of type `blob`

## Enhancements

* None

## Fixes

* serialize `blob` types
* fix for `amazon-api` when service name is mixed case (e.g. SecretsManager)

# perl-Amazon-API 1.4.7 (2023-01-25)

This version removes fixes problem setting log levels and bug when
paginators exist but `use_paginator` is false

## Enhancements

* None

## Fixes

* properly import log levels and initialize %LOG4PERL_LOG_LEVELS hash
* return raw results when either there are no paginators or `use_paginator` is false

# perl-Amazon-API 1.4.6 (2023-01-25)

This version removes the default logger and uses Log::Log4perl
or a logger passed in by caller.

## Enhancements

* use Log::Log4perl Stealth loggers or custom logger supplied by caller

## Fixes

* update module requirements

# perl-Amazon-API 1.4.5 (2023-01-20)

This version introduces automatic pagination for APIs that require the
use of paginators.

## Enhancements

* add support for automatic pagination (use_paginator)
* return raw content if serialization exceptions occur

## Fixes

* serialization of some shapes was busted (ListQueuesResult, e.g.)

# perl-Amazon-API 1.4.4 (2023-01-15)

This version introduces a `paginator()` helper method that will return an
array from an API request that paginates (e.g. Route53's
`ListHostedZones`):

```
my $rt53 = Amazon::API::Route53->new;
my $results = paginator($rt53, 'ListHostedZones', {MaxItems => 10});
```

...I hope to incorporate embed this automagically into `Amazon::API`
so that requests that contain paginators use this method (or
technique) by default. For now, this seems to be a working version of
a useful paginator.

## Enhancements

* add exportable `pagintor()` method to `Amazon::API::Botocore`

## Fixes

* `amazon-api` help function can use the canoncial service name (upper
or CamelCased) provided to serve up documentation on service methods.
   ```
   amazon-api -s SecretsManager help ListSecrets
   ```

# perl-Amazon-API 1.4.3 (2023-01-14)

This version introduces fixes a bug in the way `Amazon::API` treats
null content.

## Enhancements

None

## Fixes

* `Amazon::API::init_boto_request` - when there is no content for
  POST methods, the APIs usualy expect a payload anyway (like
  {}). GET methods on the other hand will not have any content.

# perl-Amazon-API 1.4.2 (2023-01-12)

This version introduces a way to create CPAN distributions for
individual AWS APIs.

## Enhancements

* `cpan-dist/Makefile` for creating CPAN distributions - See
  [cpan-dist/README.md](cpan-dist/README.md)
* `Makefile.requirements` for creating Perl dependencies - See
  [README-BUILD.md](README-BUILD.md)

## Fixes

* `Amazon::API::Botcore` - follow symlinks to find boto data

# perl-Amazon-API 1.4.1 (2023-01-11)

None

## Enhancements

None

## Fixes

* method stubs were being created in the current directory instead of
  using the --output-path option
* croak if service name provide unknown

# perl-Amazon-API 1.4.0 (2023-01-11)

This version most notablly presents some improvements for the
experimental Botocore support. `Amazon::API` can now make use of
the shapes metadata from Botocore the project when making requests and
decoding responses. This version removes generated example APIs
(`Amazon::API::EC2`, etc) and instead includes a utility for creating
service API.  See `ChangeLog` for a detailed inventory of
changes.

## Enhancements

* Updated documenation (pod) for `Amazon::API`
* Improvements in the use of Botocore metadata for autogeneration of API classes
* API documentation using Botocore metadata for services and shapes
* Amazon API shape support via `Amazon::API::Shape`
* `amazon-api` utility for generating classes as well showing API and shape documentation
* Pod, pod, and more pod

## Fixes

* Generated documentation for APIs and shapes has been updated to fix
  several pod errors.
* Serialization of responses into shapes is more reliable.
* Removed accessors for passed credentials to avoid storing
* No longer passes debug flag to `Amazon::Credentials` 

# perl-Amazon-API 1.3.0 (2022-04-28)

## Enhancements

* experimental use of Botocore for autogeneration of API classes
* more unit tests

## Fixes

* remove accessors for passed credentials to avoid storing
* do not pass debug flags to Amazon::Credentials 

# perl-Amazon-API 1.2.7 (2022-04-06)

## Enhancements

* new stub Amazon::API::STS

## Fixes

* unless region was passed, service URL may be set incorrectly, set
  service URL after region
* incorrect content header was sent for 
  application/x-www-form-urlencode content
* XML error reponses with new lines caused spurious error message
  regarding stat'ing a file

# perl-Amazon-API 1.2.6 (2022-03-31)

This version does not provide any fixes or significant
improvements. It contains slighly better documentation. 

## Enhancements

* added `Amazon::API::ECR` stub to distribution
* minor pod updates
* refactoring of `invoke_api()` method to reduce complexity

## Fixes

_None_

# perl-Amazon-API 1.1.2 (2018-03-14)

## Enhancements

* added option 'protocol'
* `$VERSION`

## Fixes

* spurious "%s" fabricating GET url

# perl-Amazon-API 1.1.0 (2018-02-24)

## Enhancements

* snake case and camel case method stubs are now created
automatically if the `api_methods` attribute contains the AWS
service method names.
* documentation contains more information about the API and how to
use it to construct interfaces to AWS services.
* `Amazon::API::Error` tries to decode the error messages based on
the Content-Type of the response
* constructor will attempt to instantiate an `Amazon::Credentials`
object if there was no other credential attributes passed
* constructor will fabricate the service URL if only the
`service_url_base` attribute is based
* constructor will now accept a `content_type` attribute that will
be used as the default when a reference is passed to the
`invoke_api` method

## Fixes

* smokes tests now work (make check)
