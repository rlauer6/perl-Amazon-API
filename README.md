# NAME

Amazon::API - A generic base class for AWS Services

# SYNOPSIS

    package Amazon::CloudWatchEvents;

    use parent qw{ Amazon::API };

    our @API_METHODS = qw{
     DeleteRule
     DescribeEventBus
     DescribeRule
     DisableRule
     EnableRule
     ListRuleNamesByTarget
     ListRules
     ListTargetsByRule
     PutEvents
     PutPermission
     PutRule
     PutTargets
     RemovePermission
     RemoveTargets
     TestEventPattern
    };

    sub new {
      my $class = shift;

      $class->SUPER::new(
        service       => 'events',
        api           => 'AWSEvents',
        api_methods   => \@API_METHODS,
        decode_always => 1
      );
    }

    1;

Then...

    my $rules = Amazon::CloudWatchEvents->new->ListRules({});

# DESCRIPTION

Generic class for constructing AWS API interfaces. Typically used as
the parent class, but can be used directly.

- See ["IMPLEMENTATION NOTES"](#implementation-notes) for using `Amazon::API`
directly to call AWS services.
- See [Amazon::CloudWatchEvents](https://metacpan.org/pod/Amazon%3A%3ACloudWatchEvents) for an example of how to use
this module as a parent class.

# BACKGROUND AND MOTIVATION

A comprehensive Perl interface to AWS services similar to the _boto_
library for Python has been a long time in coming. The PAWS project
has been attempting to create an always up-to-date AWS interface with
community support.  Some however may find that project a little heavy
in the dependency department. If you are looking for an extensible
(albeit spartan) method of invoking a subset of services with a lower
dependency count, you might want to consider `Amazon::API`.

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
for most if not all of those nuances of invoking AWS services and
provide a fairly generic way of invoking these APIs in the most
lightweight way possible.

As a generic, lightweight module, it naturally does not provide
support for individual AWS services. To use this class for invoking
the AWS APIs, you need to be very familiar with the specific API
requirements and responses and be willng to invest time reading the
documentation on Amazon's website.  The payoff is that you can
probably use this class to call _any_ AWS API without installing a large
number of dependencies.

Think of this class as a DIY kit to invoke **only** the methods you
need for your AWS project. A good example of creating a quick and
dirty interface to CloudWatch Events can be found here:

[Amazon::CloudWatchEvents](https://metacpan.org/pod/Amazon%3A%3ACloudWatchEvents)

And invoking some of the APIs is as easy as:

    Amazon::API->new(
      service     => 'sqs',
      http_method => 'GET'
    }
    )->invoke_api('ListQueues');

# ERRORS

When an error is encountered an exception class (`Amazon::API::Error`)
will be raised if `raise_error` has been set to a true
value. Additionally, a detailed error message will be displayed if
`print_error` is set to true.

See [Amazon::API::Error](https://metacpan.org/pod/Amazon%3A%3AAPI%3A%3AError) for more details.

# METHODS AND SUBROUTINES

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
    constructor will create methods for each of the method names listed in
    the array.

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

    Default content for parameters passed to the `invoke_api()` method.
    The default is `application/x-amz-json-1.1`.

    If you are calling an API that does not expect parameters (or all of
    them are optional and you do not pass a parameter) the default is to
    pass an empty hash.

        $cwe->ListRules();

    would be equivalent to...

        $cwe->ListRules({});

    _CAUTION! This may not be what the API expects! Always consult
    the AWS API for the service you are are calling._

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
    environment variable DEBUG to enable debugging output.

    _NOTE: By default this value will not be passed to
    `Amazon::Credentials` to prevent accidental output of credentials in
    logs. If you want to explicitly pass this value, set the debug option
    to 2 or 'insecure'._

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

- print\_error

    Setting this value to true enables a detailed error message containing
    the error code and any messages returned by the API when errors occur.

    default: true

- protocol

    One of 'http' or 'https'.  Some Amazon services do not support https
    (yet).

    default: https

- raise\_error

    Setting this value to true will raise an exception when errors
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

Attempts to decode the most recent response from an invoked API based
on the _Content-Type_ header returned.  If there is no
_Content-Type_ header, then the method will try to decode it first as
a JSON string and then as an XML string. If both of those fail, the
raw content is returned.

You can enable decoded responses globally by setting the
`decode_always` attribute when you call the `new`
constructor. Legacy behavior of this API was to always decode GET
responses. You can explicitly disable this behavior by setting
`decode_always` to 0.

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

# IMPLEMENTATION NOTES

## X-Amz-Target

Most of the newer AWS APIs are invoked as HTTP POST operations and
accept a header `X-Amz-Target` in lieu of the CGI parameter `Action`
to specify the specific API action. Some APIs also want the version in
the target, some don't. There is sparse documentation about the
nuances of using the REST interface directly to call AWS APIs.

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
a lot of inconsisitency (and sometimes flexibility) in the APIs.
DynamoDB uses DynamoDB\_YYYYMMDD.Action while KMS does not require the
version that way and prefers TrentService.Action (with no version).
There is no explanation in any of the documentations I have been able
to find as to what "TrentService" might actually mean.  Again, your
best approach is to read Amazon's documentation and look at their
sample requests for guidance.

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
and examine the payloads sent by the boto library.

## Rolling a New API

The class will stub out methods for the API if you pass an array of
API method names.  The stub is equivalent to:

    sub some_api {
      my $self = shift;

      $self->invoke_api('SomeApi', @_);
    }

Some will also be happy to know that the class will create an
equivalent _CamelCase_ version of the method.

As an example, here is a possible implementation of
`Amazon::CloudWatchEvents` that implements one of the API calls.

    package Amazon::CloudWatchEvents;

    use parent qw/Amazon::API/;

    sub new {
      my ($class, $options) = @_;

      my $self = $class->SUPER::new(
        { %{$options},
          api         => 'AWSEvents',
          service     => 'events',
          api_methods => [qw{ ListRules }],
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

## Overriding Methods

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
input parameters you passed. It guesses using the following decision tree:

- If the Content-Type parameter is passed as the third argument,
that is used.  Full stop.
- If the `parameters` value to `invoke_api()` is a reference,
then the Content-Type is either the value of `get_content_type` or
`application/x-amzn-json-1.1`.
- If the `parameters` value to `invoke_api()` is a scalar,
then the Content-Type is `application/x-www-form-urlencoded`.

You can set the default Content-Type used for the calling service when
a reference is passed to the `invoke_api()` method by passing the
`content_type` option to the constructor. The default is
'application/x-amz-json-1.1'.

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

This documentation refers to version 1.3.5 of `Amazon::API`.

# DIAGNOSTICS

To enable diagnostic output set `debug` to a true value when calling
the constructor. You can also set the `DEBUG` environment variable to a
true value to enable diagnostics.

# CONFIGURATION AND ENVIRONMENT

# DEPENDENCIES

- [Amazon::Signature4](https://metacpan.org/pod/Amazon%3A%3ASignature4)
- [Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials)
- [Class::Accessor::Fast](https://metacpan.org/pod/Class%3A%3AAccessor%3A%3AFast)
- [Date::Format](https://metacpan.org/pod/Date%3A%3AFormat)
- [HTTP::Request](https://metacpan.org/pod/HTTP%3A%3ARequest)
- [JSON::PP](https://metacpan.org/pod/JSON%3A%3APP)
- [LWP::UserAgent](https://metacpan.org/pod/LWP%3A%3AUserAgent)
- [List::Util](https://metacpan.org/pod/List%3A%3AUtil)
- [ReadonlyX](https://metacpan.org/pod/ReadonlyX)
- [Scalar::Util](https://metacpan.org/pod/Scalar%3A%3AUtil)
- [Time::Local](https://metacpan.org/pod/Time%3A%3ALocal)
- [XML::LibXML::Simple](https://metacpan.org/pod/XML%3A%3ALibXML%3A%3ASimple)

...and possibly others.

# INCOMPATIBILITIES

# BUGS AND LIMITATIONS

This module has not been tested on Windows OS.

# LICENSE AND COPYRIGHT

This module is free software. It may be used, redistributed and/or
modified under the same terms as Perl itself.

# SEE OTHER

`Amazon::Credentials`, `Amazon::API::Error`, `AWS::Signature4`

# AUTHOR

Rob Lauer - <rlauer6@comcast.net>
