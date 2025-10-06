# NAME

Amazon::API - A generic base class for AWS Services

# SYNOPSIS

    use Amazon::API;

    my $service = Amazon::API->new( service => 'events', api => 'AWSEvents');
    my $rules = $service->invoke_api('ListRules');

# DESCRIPTION

https://github.com/rlauer6/perl-Amazon-API/actions/workflows/build.yml/badge.svg

[![amazon-api](https://github.com/rlauer6/perl-Amazon-API/actions/workflows/build.yml/badge.svg)](https://github.com/rlauer6/perl-Amazon-API/actions/workflows/build.yml)

Generic class for constructing AWS API interfaces. Typically used as a
parent class, but can be used directly. This package can also
generates stubs for Amazon APIs using the Botocore project
metadata. (See ["BOTOCORE SUPPORT"](#botocore-support)).

_The typical use of this is API is through the classes you build with
the included tool (`amazon-api`). The tool leverages the Botocore
project's metadata to build classes that are specific to each API (and
are documented in the perlish way). Using `Amazon::API` directly may
not work in all circumstances unless you are very familiar with the
API you are calling. If you decide to take the [Luddite approaches](#take-the-luddite-approach), read the documentation carefully before using `Amazon::API`._

- See ["IMPLEMENTATION NOTES"](#implementation-notes) for using `Amazon::API`
directly to call AWS services.
- See
[Amazon::CloudWatchEvents](https://github.com/rlauer6/perl-Amazon-CloudWatchEvents/blob/master/src/main/perl/lib/Amazon/CloudWatchEvents.pm.in)
for an example of how to use this module as a parent class.
- See `amazon-api -h` for information regarding
how to automatically create Perl classes for AWS services using
Botocore metadata.

# BACKGROUND AND MOTIVATION

A comprehensive Perl interface to AWS services similar to the
_Botocore_ library for Python has been a long time in coming. The
Paws project has been creating an always up-to-date AWS interface with
community support. If you are looking for an extensible method of
installing and invoking a subset of services you might want to
consider `Amazon::API`.

Think of this class as a DIY kit for installing **only** the APIs and methods you
need for your AWS project.  Using the included `amazon-api` utility
you can also roll your own complete Amazon API classes that
include support for serializing requests and responses based on
metadata provided by the Botocore project. The classes you create with
`amazon-api` include full documentation as pod. (See ["BOTOCORE
SUPPORT"](#botocore-support) for more details).

> _NOTE:_ The original [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) was written in 2017 as a _very_
> lightweight way to call a handfull of APIs. The evolution of the
> module was based on discovering, without much documentation or help,
> the nature of Amazon APIs. In retrospect, even back then, it would
> have been easier to consult the Botocore project and decipher how that
> project managed to create a library from the metadata. Fast forward
> to 2022 and [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) began using the Botocore
> metadata in order to, in most cases, correctly call any AWS service.
> The [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) module can still be used without the assistance of
> Botocore metadata, but it works a heckuva lot better with it.

You can use [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) in 3 different ways:

## Take the Luddite approach

    my $queues = Amazon::API->new(
     {
      service     => 'sqs',
      http_method => 'GET'
     })->invoke_api('ListQueues');

## Build your own API classes with just what you need

    package Amazon::API::SQS;
    
    use strict;
    use warnings;
    
    use parent qw( Amazon::API );
    
    our @API_METHODS = qw(
      ListQueues
      PurgeQueue
      ReceiveMessage
      SendMessage
    );
    
    sub new {
      my ( $class, @options ) = @_;
      $class = ref($class) || $class;
    
      my %options = ref( $options[0] ) ? %{ $options[0] } : @options;
    
      return $class->SUPER::new(
        { service       => 'sqs',
          http_method   => 'GET',
          api_methods   => \@API_METHODS,
          decode_always => 1,
          %options
        }
      );
    }
    
    1;

    use Amazon::API::SQS;
    use Data::Dumper;

    my $sqs = Amazon::API::SQS->new;

    print {*STDERR} Dumper($sqs->ListQueues);

## Use the Botocore metadata to build classes for you

    amazon-api -s sqs create-stubs
    amazon-api -s sqs create-shapes

    perl -I . -MData::Dumper -MAmazon::API:SQS -e 'print Dumper(Amazon::API::SQS->new->ListQueues);'

> _NOTE:_ In order to use Botocore metadata you must clone the Botocore
> repository and point the utility to the repo.
>
> Clone the Botocore project from GitHub:
>
>     mkdir ~/git
>     cd git
>     git clone https://github.com/boto/botocore.git
>
> Generate stub classes for the API and shapes:
>
>     amazon-api -b ~/git/botocore -s sqs -o ~/lib/perl5 create-stubs
>     amazon-api -b ~/git/botocore -s sqs -o ~/lib/perl5 create-shapes
>
>     perldoc Amazon::API::SQS
>
> See [Amazon::API::Botocore::Pod](https://metacpan.org/pod/Amazon%3A%3AAPI%3A%3ABotocore%3A%3APod) for more details regarding building
> stubs and shapes.

# THE APPROACH

Essentially, most AWS APIs are RESTful services that adhere to a
common protocol, but differences in services make a single solution
difficult. All services more or less adhere to this framework:

- 1. Set HTTP headers (or query string) to indicate the API and
method to be invoked
- 2. Set credentials in the header
- 3. Set API specific headers
- 4. Sign the request and set the signature in the header
- 5. Optionally send a payload of parameters for the method being invoked

Specific details of the more recent AWS services are well documented,
however early services were usually implemented as simple HTTP
services that accepted a query string. This module attempts to account
for most of the nuances involved in invoking AWS services and
provide a fairly generic way of invoking these APIs in the most
lightweight way possible.

Using [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) as a generic, lightweight module, naturally does
not provide nuanced support for individual AWS services. To use this
class in that manner for invoking the AWS APIs, you need to be very
familiar with the specific API requirements and responses and be
willng to invest time reading the documentation on Amazon's website.
The payoff is that you can probably use this class to call _any_ AWS
API without installing a large number of dependencies.

If you don't mind a few extra dependencies and overhead, you should
generate the stub APIs and support classes using the `amazon-api`
utility. The stubs and shapes produced by the utility will serialize
and deserialize requests and responses correctly by using the Botocore
metadata. Botocore metadata provides the necessary information to
create classes that can successfully invoke all of the Amazon APIs.

A good example of creating a quick and dirty interface to CloudWatch
Events can be found here:

[Amazon::CloudWatchEvents](https://github.com/rlauer6/perl-Amazon-CloudWatchEvents/blob/master/src/main/perl/lib/Amazon/CloudWatchEvents.pm.in)

And invoking some of the APIs can be as easy as:

    Amazon::API->new(
      service     => 'sqs',
      http_method => 'GET'
    }
    )->invoke_api('ListQueues');

# BOTOCORE SUPPORT

Using Botocore metadata and the utilities in this project, you can
create Perl classes that simplify calling AWS services.  After
creating service classes and shape objects from the Botocore metadata
calling AWS APIs will look something like this:

    use Amazon::API::SQS;

    my $sqs = Amazon::API::SQS->new;
    my $rsp = $sqs->ListQueues();

The [Amazon::API::Botocore](https://metacpan.org/pod/Amazon%3A%3AAPI%3A%3ABotocore) module augments [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) by using
Botocore metadata for determining how to call individual services and
serialize parameters passed to its API methods. A utility (`amazon-api`)
is provided that can generate Perl classes for all AWS services using
the Botocore metadata.

Perl classes that represent AWS data structures (aka shapes) that are
passed to or returned from services can also be generated. These
classes allow you to call all of the API methods for a given service
using simple Perl objects that are serialized correctly for a specific
method.

Service classes are subclassed from `Amazon::API` so their `new()`
constructor takes the same arguments as `Amazon::API::new()`.

    my $credentials = Amazon::Credential->new();

    my $sqs = Amazon::API::SQS->new( credentials => $credentials );

If you are going to use the Botocore support and automatically
generate API classes you _must also_ create the data structure classes
that are used by each service. The Botocore based APIs will use these
classes to serialize requests and responses.

For more information on generating API classes, see
[Amazon::API::Botocore::Pod](https://metacpan.org/pod/Amazon%3A%3AAPI%3A%3ABotocore%3A%3APod).

## Response Serialization

With little documentation to go on, interpretting the Botocore
metadata and deducing how to serialize Botocore shapes (using a single
serializer) from Perl objects has been a difficult task. It's likely
that there are still some edge cases and bugs lurking in the
serialization methods. Accordingly, starting with version 1.4.5,
serialization exceptions or exceptions that occur while attempting to
decode a response, will result in the raw response being returned to
the caller. The idea being that getting something back that allows you
figure out what to do with the response might be better than receiving
an error.

OTOH, you might want to see the error, report it, or possibly
contribute to its resolution.  You can prevent errors from being
surpressed by setting the `raise_serializtion_errors` to a true
value. The default is _false_.

_Throughout the rest of this documentation a request made using one
of the classes created by the Botocore support scripts will be
referred to as a **Botocore request** or **Botocore API**._

Starting with version 2.0.12 serialization has become **much more reliable**,
but there are still some differences in the way the Python Botocore
library serialize responses. For example, some serializers may include
or exclude members that are not present in the response payload. If
you are testing a response element, the best approach is to first test
the truthiness and then test the presence of content.

    if ( $result->{$key} && @{$result->{$key}} ) 

    if ( $result->{$key} && %{result->{$key}} ) 

# ERRORS

When an error is returned from an API request, an exception class
(`Amazon::API::Error`) will be raised if `raise_error` has been set
to a true value (the default). If you set `print_error` to true AND
`raise_error` is false, then errors will be printed to STDERR.

See [Amazon::API::Error](https://metacpan.org/pod/Amazon%3A%3AAPI%3A%3AError) for more details.

# METHODS AND SUBROUTINES

_Reminder: You can mostly ignore this part of the documentation when
you are leveraging Botocore to generate your API classes._

## new

    new(options)

All options are described below. `options` can be a list of
key/values or hash reference.

- action

    The API method. Normally, you would not set `action` when you
    construct your object. It is set when you call the `invoke_api`
    method or automatically set when you call one of the API stubs created
    for you.

    Example: 'PutEvents'

- api

    The name of the AWS service. See ["IMPLEMENTATION NOTES"](#implementation-notes) for a
    detailed explanation of when to set this value.

    Example: 'AWSEvents'

- api\_methods

    A reference to an array of method names for the API.  The new
    constructor will automatically create methods for each of the method
    names listed in the array.

    The methods that are created for you are nothing more than stubs that
    call `invoke_api`. The stub is a convenience for calling the
    `invoke_api` method as shown below.

        my $api = Amazon::CloudWatch->new;

        $api->PutEvents($events);

    ...is equivalent to:

        $api->invoke_api->('PutEvents', $events);

    Consult the Amazon API documentation for the service to determine what
    parameters each action requires.

- aws\_access\_key\_id

    Your AWS access key. Both the access key and secret access key are
    required if either is passed. If no credentials are passed, an attempt
    will be made to find credentials using [Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials). Note
    that you may need to pass `token` as well if you are using temporary
    credentials.

- aws\_secret\_access\_key

    Your AWS secret access key.

- content\_type

    Default content for parameters passed to the `invoke_api()`
    method. If you do not provide this value, a default content type will
    be selected based on the service's protocol.

        query     => application/x-www-form-urlencoded
        rest-json => application/x-amz-json-1.1
        json      => application/json
        rest-xml  => application/xml

- credentials (optional)

    Accessing AWS services requires credentials with sufficient privileges
    to make programmatic calls to the APIs that support a service.  This
    module supports three ways that you can provide those credentials.

    - 1. Pass the credentials directly.

        Pass the values for the credentials (`aws_access_key_id`,
        `aws_secaret_access_key`, `token`) when you call the `new` method.
        A session token is typically required when you have assumed
        a role, you are using the EC2's instance role or a container's role.

    - 2. Pass a class that will provide the credential keys.

        Pass a reference to a class that has _getters_ for the credential
        keys. The class should supply _getters_ for all three credential keys.

        Pass the reference to the class as `credentials` in the constructor
        as shown here:

            my $api = Amazon::API->new(credentials => $credentials_class, ... );

    - 3. Use the default `Amazon::Credentials` class.

        If you do not explicitly pass credentials or do not pass a class that
        will supply credentials, the module will use the
        `Amazon::Credentials` class that attempts to find credentials in the
        _environment_, your _credentials file(s)_, or the _container or
        instance role_.  See [Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials) for more details.

        _NOTE: The latter method of obtaining credentials is probably the
        easiest to use and provides the most succinct and secure way of
        obtaining credentials._

- debug

    Set debug to a true value to enable debug messages. Debug mode will
    dump the request and response from all API calls. You can also set the
    environment variable DEBUG to enable debugging output. Set the debug
    value to '2' to increase the logging level.

    default: false

- decode\_always

    Set `decode_always` to a true value to return Perl objects from API
    method calls. The default is to return the raw output from the call.
    Typically, API calls will return either XML or JSON encoded objects.
    Setting `decode_always` will attempt to decode the content based on
    the returned content type.

    default: false

- error

    The most recent result of an API call. `undef` indicates no error was
    encountered the last time `invoke_api` was called.

- http\_method

    Sets the HTTP method used to invoke the API. Consult the AWS
    documentation for each service to determine the method utilized. Most
    of the more recent services utilize the POST method, however older
    services like SQS or S3 utilize GET or a combination of methods
    depending on the specific method being invoked.

    default: POST

- last\_action

    The last method call invoked.

- no\_passkey\_warning

    Prevent passkey warning. This is an option to `Amazon::Credentials`.

- print\_error

    Setting this value to a true value will print a detailed error message
    containing the error code and any messages returned by the API to
    STDERR when an error occurs. Errors will NOT be printed if
    `raise_error` is also true.

    default: true

- protocol

    One of 'http' or 'https'.  Some Amazon services do not support https
    (yet).

    default: https

- raise\_error

    Setting this value to a true value will raise an exception when errors
    occur. If you set this value to false you can inspect the `error`
    attribute to determine the success or failure of the last method call.

        $api->invoke_api('ListQueues');

        if ( $api->get_error ) {
          ...
        }

    default: true

- region

    The AWS region. Pass an empty string if the service is a global
    service that does not require or want a region.

    default: $ENV{'AWS\_REGION'}, $ENV{'AWS\_DEFAULT\_REGION'}, 'us-east-1'

- response

    The HTTP response from the last API call.

- service

    The AWS service name. Example: `sqs`. This value is used as a prefix
    when constructing the the service URL (if not `url` attribute is set).

- service\_url\_base

    Deprecated, use `service`

- token

    Session token for assumed roles.

- url

    The service url.  Example: https://events.us-east-1.amazonaws.com

    Typically this will be constructed for you based on the region and the
    service being invoked. However, you may want to set this manually if
    for example you are using a service like
    <LocalStack|https://localstack.cloud/> that mocks AWS API calls.

        my $api = Amazon::API->new(service => 's3', url => 'http://localhost:4566/');

- user\_agent

    Your own user agent object.  Using
    `Furl`, if you have it avaiable may result in faster response.

    default: `LWP::UserAgent`

- version

    Sets the API version.  Some APIs require a version. Consult the
    documentation for individual services.

## invoke\_api

    invoke_api(action, [parameters], [content-type], [headers]);

or using named parameters...

    invoke_api({ action => args, ... } )

Invokes the API with the provided parameters.

- action

    API name.

- parameters

    Parameters to send to the API. `parameters` can be a scalar, a hash
    reference or an array reference. See the discussion below regarding
    `content-type` and how `invoke_api()` formats parameters before
    sending them as a payload to the API.

    You can use the `param_n()` method to format query string arguments
    that are required to be in the _param.n_ notation. This is about the
    best documentation I have seen for that format. From the AWS
    documentation...

    >     Some actions take lists of parameters. These lists are specified using
    >     the _param.n_ notation. Values of n are integers starting from 1. For
    >     example, a parameter list with two elements looks like this:
    >
    >     &AttributeName.1=first
    >
    >     &AttributeName.2=second

    An example of using this notation is to set queue attributes when
    creating an SQS queue.

        my $attributes = { Attributes => [ { Name => 'VisibilityTimeout', Value => '100' } ] };
        my @sqs_attributes= Amazon::API::param_n($attributes);

        eval {
          $sqs->CreateQueue([ 'QueueName=foo', @sqs_attributes ]);
        };

    See ["param\_n"](#param_n) for more details.

- content-type

    If you pass the `content-type` parameter, it is assumed that the parameters are
    the actual payload to be sent in the request (unless the parameter is a reference).

    The `parameters` will be converted to a JSON string if the
    `parameters` value is a hash reference.  If the `parameters` value
    is an array reference it will be converted to a query string (Name=Value&...).

    To pass a query string, you should send an array of key/value
    pairs, or an array of scalars of the form `Name=Value`.

        [ { Action => 'DescribeInstances' } ]
        [ 'Action=DescribeInstances' ]

- headers

    Array reference of key/value pairs representing additional headers to
    send with the request.

## decode\_response

Boolean that indicates whether or not to deserialize the most recent
response from an invoked API based on the _Content-Type_ header
returned.  If there is no _Content-Type_ header, then the method will
try to decode it first as a JSON string and then as an XML string. If
both of those fail, the raw content is returned.

You can enable or disable deserializing responses globally by setting
the `decode_always` attribute when you call the `new` constructor.

default: true

By default, \`Amazon::API\` will retrieve all results for Botocore based
API calls that require pagination. To turn this behavior off, set
`use_paginator` to a false value when you instantiate the API
service.

    my $ec2 = Amazon::API->new(use_paginator => 0);

You can also use the ["paginator"](#paginator) method to retrieve all results from Botocore requests that implement pagination.

## print\_error

Prints a formatted version of the last error encountered to STDERR.

## submit

    submit(options)

_This method is used internally by `invoke_api` and normally should
not be called by your applications._

`options` is a reference to a hash of options:

- content

    Payload to send.

- content\_type

    Content types we have seen used to send values to AWS APIs:

        application/json
        application/x-amz-json-1.0
        application/x-amz-json-1.1
        application/x-www-form-urlencoded

    Check the documentation for the individual APIs for the correct
    content type.

- headers

    Array reference of key/value pairs that represent additional headers
    to send with the request.

# EXPORTED METHODS

## generate\_xml

    generate_xml(object)

Generates XML from a Perl object (uses [XML::LibXML](https://metacpan.org/pod/XML%3A%3ALibXML)). This seems to
do a much better job than XMLout() in allowing a mix of attributes and
nested objects. With `XMLout()` you need to choose between allowing
attributes (which we need to add the namespace for certain requests)
and nested elements (NoAttr => 1).

## get\_api\_service

    get_api_service(api, options)

Convenience routine that will return an API instance.

    my $sqs = get_api_service 'sqs';

Equivalent to:

    require Amazon::API::SQS;

    my $sqs = Amazon::API::SQS->new(%options);

- api

    The service name. Example: route53, sqs, sns

- options

    list of key/value pairs passed to the new constructor as options

## create\_url\_encoded\_content

    create_urlencoded_content(parameters, action, version)

Returns a URL encoded query string. `parameters` can be any of SCALAR, ARRAY, or HASH. See below.

- parameters
    - SCALAR

        Query string to encode (x=y&w=z..)

    - ARRAY

        Can be one of:

        - Array of hashes where the keys are the query string variable and the value is the value of that variable
        - Array of strings of the form "x=y"
        - An array of key/value pairs - qw( x y w z )

    - HASH

        Key/value pairs. If value is an array it is assumed to be a list of hashes
- action

    The method being called. For some query type APIs an Action query variable is required.

- version

    The WSDL version for the API. Some query type APIs require a Version query variable.

## paginator

    paginator(service, api, request)

Returns an array containing the results of an API call that requires
pagination,

    my $result = paginator($ec2, 'DescribeInstances', { MaxResults => 10 });

## param\_n

    param_n(parameters)

Format parameters in the "param.n" notation.

`parameters` should be a hash or array reference.

A good example of a service that uses this notation is the
_SendMessageBatch_ SQS API call.

The sample request can be found here:

[SendMessageBatch](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SendMessageBatch.html)

    https://sqs.us-east-2.amazonaws.com/123456789012/MyQueue/
    ?Action=SendMessageBatch
    &SendMessageBatchRequestEntry.1.Id=test_msg_001
    &SendMessageBatchRequestEntry.1.MessageBody=test%20message%20body%201
    &SendMessageBatchRequestEntry.2.Id=test_msg_002
    &SendMessageBatchRequestEntry.2.MessageBody=test%20message%20body%202
    &SendMessageBatchRequestEntry.2.DelaySeconds=60
    &SendMessageBatchRequestEntry.2.MessageAttribute.1.Name=test_attribute_name_1
    &SendMessageBatchRequestEntry.2.MessageAttribute.1.Value.StringValue=test_attribute_value_1
    &SendMessageBatchRequestEntry.2.MessageAttribute.1.Value.DataType=String
    &Expires=2020-05-05T22%3A52%3A43PST
    &Version=2012-11-05
    &AUTHPARAMS

To produce this message you would pass the Perl object below to `param_n()`:

    my $message = {
      SendMessageBatchRequestEntry => [
        { Id          => 'test_msg_001',
          MessageBody => 'test message body 1'
        },
        { Id               => 'test_msg_002',
          MessageBody      => 'test message body 2',
          DelaySeconds     => 60,
          MessageAttribute => [
            { Name  => 'test_attribute_name_1',
              Value =>
                { StringValue => 'test_attribute_value_1', DataType => 'String' }
            }
          ]
        }
      ]
    };

# CAVEATS

- If you are calling an API that does not expect parameters (or all of
them are optional and you do not pass a parameter) the default is to
pass an empty hash..

        $cwe->ListRules();

    would be equivalent to...

        $cwe->ListRules({});

    _CAUTION! This may not be what the API expects! Always consult
    the AWS API for the service you are are calling._

# IMPLEMENTATION NOTES

If you have taken the advice above and created classes using the
`amazon-api` script you can probably ignore this section. This
section is intended to help those trying to create the lightest weight
possible AWS API class.

Just a reminder for those wanting to go lite...

- Read the documentation AWS provides for the API. You need to understand the request parameters and headers required.
- Examine the Botocore data for the API. That might help you understand that structures required for the calling parameters.
- Use the `aws` CLI script in debug mode to see the actual payloads and how they are formatted.

## Headers

### X-Amz-Target

Most of the newer AWS APIs are invoked as HTTP POST operations and
accept a header `X-Amz-Target` in lieu of the CGI parameter `Action`
to specify the specific API action. Some APIs also want the version in
the target, some don't. There is sparse documentation about the
nuances of using the REST interface _directly_ to call AWS APIs, but
you kinda sorta figure it out by parsing the Botocore data for a
particular API.

When invoking an API, the class uses the `api` value to indicate
that the action should be set in the `X-Amz-Target` header.  We also
check to see if the version needs to be attached to the action value
as required by some APIs.

    if ( $self->get_api ) {
      if ( $self->get_version) {
        $self->set_target(sprintf('%s_%s.%s', $self->get_api, $self->get_version, $self->get_action));
      }
      else {
        $self->set_target(sprintf('%s.%s', $self->get_api, $self->get_action));
      }

      $request->header('X-Amz-Target', $self->get_target());
    }

DynamoDB and KMS seem to be able to use this in lieu of query
variables `Action` and `Version`, although again, there seems to be
a lot of inconsistency (and sometimes flexibility) in the APIs.
DynamoDB uses DynamoDB\_YYYYMMDD.Action while KMS does not require the
version that way and prefers TrentService.Action (with no version).
There is no explanation in any of the documentations I have been able
to find as to what "TrentService" might actually mean.  Again, your
best approach is to read Amazon's documentation and look at their
sample requests for guidance.  You can also look to the [Botocore
project](https://github.com/boto/botocore) for information regarding
the service.  Checkout the `service-2.json` file within the
sub-directory `botocore/botocore/data/{api-version}/{service-name}`
which contains details for each service.

In general, the AWS API ecosystem is very organic. Each service seems
to have its own rules and protocol regarding what the content of the
headers should be.

As noted, this generic API interface tries to make it possible to use
one class `Amazon::API` as a sort of gateway to the APIs. The most
generic interface is simply sending query variables and not much else
in the header.  Services like EC2 conform to that protocol and can be
invoked with relatively little fanfare.

    use Amazon::API;
    use Data::Dumper;

    print Dumper(
      Amazon::API->new(
        service => 'ec2',
        version => '2016-11-15'
      )->invoke_api('DescribeInstances')
    );

Note that invoking the API in this fashion, `version` is
required.

For more hints regarding how to call a particular service, you can use
the AWS CLI with the --debug option.  Invoke the service using the CLI
and examine the payloads sent by the Botocore library.

### Rolling a New API

Once again, your best bet is to use the `amazon-api` script to roll a
class from the Botocore metadata, but if you really want to create your own
class the lite way read on.

The [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) class will stub out methods for the API if you pass
an array of API method names.  The stub is equivalent to:

    sub some_api {
      my $self = shift;

      $self->invoke_api('SomeApi', @_);
    }

Some will also be happy to know that the class will create an
equivalent _CamelCase_ version of the method.

As an example, here is a possible implementation of
`Amazon::CloudWatchEvents` that implements one of the API calls.

    package Amazon::CloudWatchEvents;

    use strict;
    use warnings;

    use parent qw(Amazon::API);

    sub new {
      my ($class, $options) = @_;

      my $self = $class->SUPER::new(
        { %{$options},
          api         => 'AWSEvents',
          service     => 'events',
          api_methods => [qw( ListRules )],
        }
      );

      return $self;
    }

Then...

    use Data::Dumper;

    print Dumper(Amazon::CloudWatchEvents->new->ListRules({}));

Of course, creating a class for the service is optional. It may be
desirable however to create higher level and more convenient methods
that aid the developer in utilizing a particular API.

### Overriding Methods

Because the class does some symbol table munging, you cannot easily
override the methods in the usual way.

    sub ListRules {
      my $self = shift;
      ...
      $self->SUPER::ListRules(@_)
    }

Instead, you should re-implement the method as implemented by this
class.

    sub ListRules {
      my $self = shift;
      ...
      $self->invoke_api('ListRules', @_);
    }

## Content-Type

Yet another piece of evidence that suggests the _organic_ nature of
the Amazon API ecosystem is their use of different `Content-Type`
headers.  Some of the variations include:

    application/json
    application/x-amz-json-1.0
    application/x-amz-json-1.1
    application/x-www-form-urlencoded

Accordingly, the `invoke_api()` method can be passed the
`Content-Type` or will try to make its _best guess_ based on the
service protocol or the type of object being passed as
parameters. There is a hash of service names and service types that
this module uses to determine the content type required by the
service. If services are added that hash needs to be updated.

You can also set the default content type used for the calling service
by passing the `content_type` option to the constructor.

    $class->SUPER::new(
      content_type => 'application/x-amz-json-1.1',
      api          => 'AWSEvents',
      service      => 'events'
    );

## ADDITIONAL HINTS

- Bad Request

    If you send the wrong headers or payload you're liable to get a 400
    Bad Request. You may also get other errors that can be misleading when
    you send incorrect parameters. When in doubt compare your requests to
    requests from the AWS CLI using the `--debug` option.

    - 1. Set the `debug` option to true to see the request object and
    the response object from `Amazon::API`.
    - 2. Excecute the AWS CLI with the --debug option and compare the
    request and response with that of your calls.

- Payloads

    Pay attention to the payloads that are required by each service.  **Do
    not** assume that sending nothing when you have no parameters to pass
    is correct. For example, the `ListSecrets` API of SecretsManager
    requires at least an empty JSON object.

        $api->invoke_api('ListSecrets', {});

    Failure to send at least an empty JSON object will result in a 400
    response. 

# VERSION

This documentation refers to version 2.1.5  of `Amazon::API`.

# DIAGNOSTICS

To enable diagnostic output, set `debug` to a true value when calling
the constructor. You can also set the `DEBUG` environment variable to a
true value to enable diagnostics.

## Logging

By default [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) uses [Log::Log4perl](https://metacpan.org/pod/Log%3A%3ALog4perl)'s stealth loggers to
log at the DEBUG and TRACE levels. Setting the environment variable
DEBUG to some value or passing a true value for `debug` in the
constructor will trigger extremely verbose logging. This is to help
debug edge cases especially around serialiazation which is
particularly prone to exceptions and API specific scenarios.

If you pass a logger to the constructor, `Amazon::API` will attempt
to use that if it has the appropriate logging level methods (error,
warn, info, debug, trace). If [Log::Log4perl](https://metacpan.org/pod/Log%3A%3ALog4perl) is unavailable and you
do not pass a logger, logging is essentially disabled at any level.

If, for some reason you set the enviroment variable DEBUG to a true
value or have your own Log4perl logger set at the debug level but do
not want `Amazon::API` to log messages at that level you can turn off
logging as shown below:

    my $ec2 = Amazon::API::EC2->new(log_level => 'info');

In other words, do not send a logger but send a log level. The
constructor will recognize that you have a Log4perl logger initialized
and just set its log level to your desired level.

# BUGS AND LIMITATIONS

This module has not been tested on Windows OS. Please report any
issues found by opening an issue here:

[https://github.com/rlauer6/perl-Amazon-API/issues](https://github.com/rlauer6/perl-Amazon-API/issues)

# FAQs

## Why should I use this module instead of Paws?

Maybe you shouldn't. Paws is a community supported project and may be
a better choice for most people. The programmers who created Paws are
luminaries in the pantheon of Perl programming (alliteration
intended). If you don't want to install of the AWS services but only
need to use a single service, [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) may be the right choice
for you.  Paws may also have some edge cases for some of the seldom
used services and you might find this module easier to use and debug.

## Does it perform better than Paws?

Probably not. But individual API calls to Amazon services have their
own performance characteristics and idiosyncracies.  The overhead
introduced by this module and Paws may be insignificant compared to
the API performance itself, however Paws is implemented using Moose
and the startup time for a Moose script can longer than the startup
script when using this module. YMMV.

## Does this work for all APIs?

I don't know. Probably not? Feedback is appreciated. [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI)
has been developed based on my needs and used accordingly.  Although I
have tested it on many APIs, there may still be some cases that are
not handled properly and I am still deciphering the nuances of
flattening, boxing and serializing objects to send to Amazon APIs. The
newer versions of this module using Botocore metadata have become
increasingly reliable over time and I'm somewhat confident that my
interpretation of the Botocore data produces working classes.

However, keep in mind that Amazon APIs are not created equal,
homogenous or invoked in the the same way for all services. Some
accept parameters as a query strings, some parameters are embedded in
the URI, some are sent as JSON payloads and others as XML. Content
types for payloads are all over the map.  Likewise with return values.

Luckily, the Botocore metadata describes the protocols, parameters and
return values for all APIs. The Botocore metadata is quite amazing
actually. It is used to provide information to the Botocore library
for calling any of the AWS services and even for creating
documentation!

[Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) can use that information for creating the Perl classes
that invoke each API but may not interpret the metadata correctly in
all circumstances, so it is likely bugs may still exist.

If you want to use this to invoke S3 APIs, don't. I haven't tried it
and I'm pretty sure it would not work anyway. There are modules
designed specifically for S3; [Amazon::S3](https://metacpan.org/pod/Amazon%3A%3AS3), [Net::Amazon::S3](https://metacpan.org/pod/Net%3A%3AAmazon%3A%3AS3). Use
them instead.

## Do I have to create the shape classes when I generate stubs for a service?

Probably. If you create stubs manually, then you do not need the shape
classes. If you use the scripts provided to create the API stubs using
Botocore metadata, then yes, you must create the shapes so that the
Botocore API methods know how to serialize requests. Note that you can
create the shape stubs using the Botocore metadata while not creating
the API services. You might want to do that if you want a lean stub
but want the benefits of using the shape stubs for serialization of
the parameters (or you want the pod that comes with those classes).

If you produce your stubs manually and do not create the shape stubs,
then you must pass parameters to your API methods that are ready to be
serialized by [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI).  Creating data structures that will be
serialized correctly however is done for you _if you use the shape
classes_.  For example, to create an SQS queue using the shape stubs,
you can call the `CreateQueue` API method as describe in the Botocore
documentation.

    $sqs->CreateQueue(
      { QueueName => $queue_name,
        tags      => { Name => 'my-new-queue' },
        { Env => 'dev' },
        Attributes => { VisibilityTimeout => 40 },
        { DelaySeconds => 60 }
      }
    );

If you do not use the shape classes, then you must pass the arguments
in the form that will eventually be serialized in the correct manner
as a query string.

    $sqs->CreateQueue([
     'QueueName=foo',
     'Attributes.1.Value=100',
     'Attributes.1.Name=VisibilityTimeout',
     'Tag.1.Key=Name',
     'Tag.1.Value=foo',
     'Tag.2.Key=Env',
     'Tag.2.Value=dev'
    ]);

## This code does not use "Modern Perl". Why?

This code has evolved over the years from being _ONLY_ a way to make
RESTful calls to a few Amazon APIs, to incorporating the use of the
Botocore metadata. It _was_ one person's effort to create a somewhat
lightweight interface to selected AWS APIs.

The code did not start out as well designed attempt to interpret the
Botocore data by creating a monolithic framework to call ANY AWS
API. Perhaps if it were designed today it might use more of Modern
Perl, like Moose as does Paws. The code does however embrace Perl Best
Practices.  Running `perlcritic` with the Perl Best Practices theme
should show no or very few findings.

## How do I pass AWS credentials to the API?

There is a bit of magic here as [Amazon::API](https://metacpan.org/pod/Amazon%3A%3AAPI) will use
[Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials) transparently if you do not explicitly pass the
credentials object. I've taken great pains to try to make the
aforementioned module somewhat useful and _secure_.

See [Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials).

## Can I use more than one set of credentials to invoke different APIs?

Yes. See [Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials).

## How stable is the interface?

As of version 2.1.0 the interface is quite stable.  I'm not aware of
any current bugs and now consider this project "production ready".

## Why are you using XML::Simple when it clearly says "DO NOT"?

It's simple. And it seems easier to build than other modules that
almost do the same thing.

## I tried to use this with XYZ service and it didn't work. What should do I do?

There are several reasons why your call might not have worked. The
most likely place for API calls to fail is when serializing requests
or serializing results. Enable debugging and see how far the API gets.
Report whether the serialization on the request or response failed.
If the serialization of the results failed, you can set
`decode_always` to false which will prevent serialization of the
result and return the raw content sent from the API.  Other reasons
your call may have failed include:

- You passed bad data

    Take a look at the data you passed, how was it serialized and
    ultimately passed to the API?  Setting the `debug` flag is usually
    helpful in understanding how requests and responses are serialized.

- You didn't read the docs and passed bad data

        amazon-api -s sqs CreateQueue

- The serialization of Amazon::API::Botocore::Shape isn't working

    Serialization output for every class for every API has not been fully
    tested and my never be given the breadth of objects and services. You
    may find that some API methods return `Bad Request` or do not
    serialize the results (or more likely requests) in the manner
    expected. Requests are serialized based _solely_ on the metadata
    found in the Botocore project. There lie the clues for each API
    (protocol, end points, etc) and the models (shapes) for requests and
    response elements.

    Some requests require a query string, some an XML or JSON payload. The
    Botocore based API classes use the metadata to determine how to send a
    request and how to interpret the results. This module uses
    [XML::Simple](https://metacpan.org/pod/XML%3A%3ASimple) or [JSON](https://metacpan.org/pod/JSON) to parse the results. It then uses the
    [Amazon::API::Botocore::Serializer](https://metacpan.org/pod/Amazon%3A%3AAPI%3A%3ABotocore%3A%3ASerializer) to turn the parsed results into a
    Perl object that respresents the response shape.

    It's likely that there are exceptions that are handled as special
    cases in the Python or Java libraries that also use the Botocore
    metadata. In that case use the `aws` CLI command in `--debug` mode
    to examine the request and response.

    You can find information about each API's request and response from
    the documentation created for each service.

        perldoc Amazon::API::Botocore::Shape::EC2:DescribeInstancesRequest

    or more succinctly:

        amazon-api -s ec2 help DescribeInstancesRequest

    Make sure you understand what the API request should look
    like. `amazon_api` will help illuminate the structure of requests you
    should be sending to APIs.

        amazon-api -s sqs help CreateQueue

    You can also dump the Botocore metadata from the generated classes using
    `amazon-api`.

        amazon-api -s sqs describe

    - Additional Details

        Some APIs, most notably query protocol APIs like EC2 seem to require
        special serializers. Looking at the Python implementation of the
        Botocore library reveals a separate EC2 serializer.  This API has no
        such "hook" for APIs that require a unique intepretation of the
        Botocore metadata. 

        You can however create the correct payloads expected by an API and
        pass those when you make a request. For example, the EC2
        DescribeSecurityGroups API accepts a Filter object to filter the
        results. The Python Botocore signature looks like this:

            response = client.describe_security_groups(
                Filters=[
                    {
                        'Name': 'string',
                        'Values': [
                            'string',
                        ]
                    },
                ],
                GroupIds=[
                    'string',
                ],
                GroupNames=[
                    'string',
                ],
                DryRun=True|False,
                NextToken='string',
                MaxResults=123
            )

        That signature provides a convenient way to pass the required
        parameters to the API. However, when actually passed to the API the
        payload is serialized into a query string parameter that might look
        something like:

            Filter.1.Name=group-name&Filter.1.Value.1=some-value&Action=DescribeSecurityGroups&Version=2016-11-15

        The Filters object you passed gets serialized into _param.n_ notation
        as described earlier in this documentation. Knowing that fact (by
        looking at the AWS API for DescribeSecurityGroups) and experiencing a
        failure when sending what should be the correct request to the API
        using this class, you could send correctly formatted payloads to query
        protocol APIs like this one.

            my @filter = param_n(
               { Filter => [
                   { Name  => 'group-name',
                     Value => ['tbc-ssh-only']
                   }
                 ]
               }
             );

            print Dumper([filter => \@filter]);

        Would result in:

            $VAR1 = [
                      'filter',
                      [
                        'Filter.1.Name=group-name',
                        'Filter.1.Value.1=tbc-ssh-only'
                      ]
                    ];

        Arrays passed to query protocol requests are assumed to be lists of
        query variables and values and are added to the URL when the request
        is made.

        _Hopefully, as more is learned about serializing those kinds of API
        requests this class will be able to successfully make those API
        calls._

        _UPDATE: Try using the Botocore protocol for APIs by passing a hash
        reference of expected variables first. Recent updates have been made
        to create special serializers for these older query protocol APIs._

    If you find this project's serializer deficient, please log an issue
    and I will attempt to address it.

# LICENSE AND COPYRIGHT

This module is free software. It may be used, redistributed and/or
modified under the same terms as Perl itself.

# TBD

Over the last few years as the classes in this project have evolved,
the number of dependencies has increased to the point where it is no
longer a "lightweight" distribution. In fact, the start up time for
`Amazon::API` is to be honest, now a bit disappointing.  Accordingly,
the biggest "to do" on the list is to see if the load time can be
reduced. Having said that, the cost of invoking some Amazon APIs and
the fact that you may be using these classes in a manner where initial
load time is not important, may not make this a high priority for
some.

- decrease load time of `Amazon::API`
- reduce dependencies
- reduce generated class modules sizes by separating out pod
- investigate a different way to load Botocore metadata rather than embedding it in each module

# SEE OTHER

[Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials), [Amazon::API::Error](https://metacpan.org/pod/Amazon%3A%3AAPI%3A%3AError), [AWS::Signature4](https://metacpan.org/pod/AWS%3A%3ASignature4), [Amazon::API::Botocore](https://metacpan.org/pod/Amazon%3A%3AAPI%3A%3ABotocore), [Paws](https://metacpan.org/pod/Paws)

# AUTHOR

Rob Lauer - <rlauer6@comcast.net>
