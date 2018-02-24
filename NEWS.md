This is the 'NEWS' file for the 'perl-Amazon-API' project. This file contains
information on changes since the last release of the package, as well as a
running list of changes from previous versions.  If critical bugs are found in
any of the software, notice of such bugs and the versions in which they were
fixed will be noted here, as well.

-----------------------------------------------------------------------

perl-Amazon-API 1.0.0 (2017-12-24)

    Enhancements:

    (None)

    Fixes:

    (None)
-----------------------------------------------------------------------

perl-Amazon-API 1.1.0 (2018-0-24)

    Enhancements:

    - snake case and camel case method stubs are now created
      automatically if the `api_methods` attribute contains the AWS
      service method names.

    - documentation contains more information about the API and how to
      use it to construct interfaces to AWS services.

    - Amazon::API::Error tries to decode the error messages based on
      the Content-Type of the response

    - constructor will attempt to instantiate an `Amazon::Credentials`
      object if there was no other credential attributes passed

    - constructor will fabricate the service URL if only the
      `service_url_base` attribute is based

    - constructor will now accept a `content_type` attribute that will
      be used as the default when a reference is passed to the
      `invoke_api` method

    Fixes:

    - smokes tests now work (make check)
