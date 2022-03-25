# REAMDE.md for Amazon::API Examples

This directory contains examples demonstrating how you can create a
Perl module for various flavors of the Amazon APIs.

In order to exercise these examples:

* you must have an Amazon account and credentials with sufficient
  privileges to invoke the various APIs. You can also exercise these
  examples using API compatible services like [LocalStack](https://localstack.cloud/).
  
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
  perl service-name.pm--help
  ```
# Example Scripts

The example scripts will execute a subset of the API methods for
various services. The intent is to show how you can create your own
classes or just use the `Amazon::API` class directly to call a
service.

All of the examples are exercised in the same way:

```
perl service-name.pm run API arguments
```

# Using LocalStack to Run Examples

If you're interested in exercising some of these examples in a local
environment checkout [LocalStack](https://localstack.cloud/).  You can
use the `docker-compose.yml` file below to bring up the service.

```
version: "3.8"

services:
  localstack:
    container_name: "${LOCALSTACK_DOCKER_NAME-localstack_main}"
    image: localstack/localstack
    network_mode: bridge
    ports:
      - "127.0.0.1:4510-4530:4510-4530"
      - "127.0.0.1:4566:4566"
      - "127.0.0.1:4571:4571"
    environment:
      - SERVICES=s3,ssm,secretsmanager,kms,sqs,ec2,events
      - DEBUG=${DEBUG-}
      - DATA_DIR=${DATA_DIR-}
      - LAMBDA_EXECUTOR=${LAMBDA_EXECUTOR-}
      - HOST_TMP_FOLDER=${TMPDIR:-/tmp/}localstack
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - "${TMPDIR:-/tmp}/localstack:/tmp/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"

```

To use LocalStack when exercising an example, use the `--endpoint-url`
option.

```
perl sqs.pm --endpoint-usr=http://localhost:4566 run ListQueues
```
