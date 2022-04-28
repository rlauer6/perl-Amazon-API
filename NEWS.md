# NEWS

This is the `NEWS` file for the `perl-Amazon-API` project. This file contains
information on changes since the last release of the package, as well as a
running list of changes from previous versions.  If critical bugs are found in
any of the software, notice of such bugs and the versions in which they were
fixed will be noted here, as well.

# perl-Amazon-API 1.3.0 (2022-04-??)

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
