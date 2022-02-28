# REAMDE.md for Amazon::API Examples

This directory contains examples demonstrating how you can create a
Perl module for various flavors of the Amazon APIs.

In order to exercise these examples:

* you must have an Amazon account and credentials with sufficient
  privileges to invoke the various APIs. You can also exercise these
  examples using API compatible services like LocalStack
  
* Your credentials should be accessible in one of:

  * the environment
  * the role assumed by the EC2 or container your are running in
  * your credentials files configured with the AWS CLI commmand `aws
    configure`
    
* AWS APIs are (generally speaking) not free, especially if they
  create resources. Most of these examples do not create resources,
  however you should be aware of what each of these examples does
  before invoking theme  For a short description of each of these
  examples try:
  
  ```
  perl service-name.pl --help
  ```
# Example Scripts

The example scripts will execute a subset of the API methods for
various services. The intent is to show how you can create your own
classes or just use the `Amazon::API` class directly to call a
service.

All of the examples are exercised in the same way:

```
perl service-name.pl run API arguments
```

* [x] cloudwatch-events.pl
* [x] ec2.pl
* [x] secrets-manager.pl
* [x] sqs.pl
* [x] ssm.pl
