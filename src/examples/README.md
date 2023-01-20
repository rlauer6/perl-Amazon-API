# REAMDE.md for Amazon::API Examples

This directory contains examples demonstrating how you can create a
simple Perl module for various flavors of the Amazon APIs using the
`Amazon::API` module as a base class.

In order to exercise these examples:

* you must have an Amazon account and credentials with sufficient
  privileges to invoke the various APIs. You can also exercise _some_
  of these examples using API compatible services like
  [LocalStack](https://localstack.cloud/).
  
* Your credentials should be accessible in one of:

  * the environment
  * the role assumed by the EC2 or container your are running in
  * your credentials files configured with the AWS CLI commmand `aws
    configure`
    
* AWS APIs are (generally speaking) not free, especially if they
  create resources. Most of these examples do not create resources,
  however you should be aware of what each of these examples does
  before invoking them.  For a short description of each of these
  examples try:
  
  ```
  perl service-name.pm --help
  ```

# Example Scripts

Most of these scripts will show you how to use `Amazon::API` as a base
class. Where noted however, the example service may require the use of
a class constructed using the experimental Botocore class constructor
(`amazon-api`). To create the classes for those services use the
commands below:

```
for a in ec2 sts; do
  amazon-api -s $a create-stub
  amazon-api -s $a create-shapes
done
```

| Name | Service | Notes |
| ---- | ------- | ----- |
| cloud-watch-events.pm | CloudWatch Events | - |
| ec2.pm | Elastic Compute Cloud | requires `Amazon::API::EC2` |
| ecr.pm | Elastic Container Registry | - |
| secrets-manager.pm | Secrets Manager | - |
| ssm.pm | Systems Manager | - |
| sts.pm | Security Token Service | requires `Amazon::API::STS` |
| sqs.pm | Simple Queue Service | - |

The example scripts will execute a subset of the API methods for
various services. The intent is to show how you can create your own
classes or just use the `Amazon::API` class directly to call a
service.

All of the examples are exercised in the same way:

```
perl -I . service-name.pm run API arguments
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
option and anything for the credentials environment variables.

```
export AWS_ACCESS_KEY_ID=foo
export AWS_SECRET_ACCESS_KEY=foo
perl -I . sqs.pm --endpoint-url http://localhost:4566 run ListQueues
```

## Known Limitations of LocalStack

* `aws sqs --list-queue-tags` returns an empty response


