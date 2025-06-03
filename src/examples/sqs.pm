package Amazon::SQS;

use strict;
use warnings;

use Carp;
use Data::Dumper;
use JSON qw(encode_json);
use Scalar::Util qw( reftype );
use APIExample qw(dump_json);

use parent qw(APIExample Amazon::API::SQS);

our $DESCRIPTIONS = {
  ListQueues     => 'Executes the SQS API "ListQueues".',
  DeleteQueue    => 'Executes the SQS API "DeleteQueue", deletes a queue named "foo" if it exists.',
  CreateQueue    => 'Executes the SQS API "CreateQueue", creates a queue named "foo".',
  SendMessage    => 'Executes the SQS API "SendMessage".',
  ReceiveMessage => 'Executes the SQS API "ReceiveMessage".',
  DeleteMessage  => 'Executes the SQS API "DeleteMessage".',
};

caller or __PACKAGE__->main;

BEGIN {
  our $VERSION = $Amazon::API::SQS::VERSION;
}

########################################################################
sub _ListQueues {
########################################################################
  my ( $package, $options ) = @_;

  my $sqs = $package->service($options);

  my $rsp = $sqs->ListQueues();

  print {*STDOUT} dump_json($rsp);

  return $rsp;
}

########################################################################
sub _DeleteMessage {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $sqs = $package->service($options);

  my ( $queue_url, $receipt_handle ) = @args;

  die "QueuUrl and ReceiptHandle are required\n"
    if !$queue_url || !$receipt_handle;

  my $rsp = $sqs->DeleteMessage(
    { QueueUrl      => $queue_url,
      ReceiptHandle => $receipt_handle
    }
  );

  print {*STDOUT} dump_json($rsp);

  return $rsp;
}

########################################################################
sub queue_url {
########################################################################
  my ( $sqs, $queue ) = @_;

  my $queues = $sqs->ListQueues;

  if ( $queues && ref $queues ) {
    $queues = $queues->{QueueUrls};
  }

  $queues //= [];

  my ($queue_url) = grep {/$queue/xsm} @{ $queues || [] };

  croak "no such queue - [$queue]\n"
    if !$queue_url;

  return $queue_url;
}

########################################################################
sub _DeleteQueue {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $sqs = $package->service($options);

  my $queue_url = queue_url( $sqs, $args[0] );

  my $rsp = $sqs->DeleteQueue( { QueueUrl => $queue_url } );

  print {*STDOUT} dump_json($rsp);

  return $rsp;
}

########################################################################
sub _CreateQueue {
########################################################################
  my ( $package, $options, @args ) = @_;

  # the query mode for SQS should not be used anymore...there is at
  # least one bug when message attributes are returned in an XML
  # payload - the Botocore data specifies MessageAttributes as a
  # member, but the XML returns MessageAttribute
  my $query_type = $options->{query_type} // 1;

  my $queue_name = $args[0];

  my $sqs = $package->service($options);

  my $rsp = eval {
    if ($query_type) {
      my $attributes = [ { Name => 'VisibilityTimeout', Value => '100' } ];
      my $tags       = [ { Key  => 'Name',              Value => $queue_name } ];

      my @sqs_attributes = Amazon::API::param_n( { Attribute => $attributes } );
      my @sqs_tags       = Amazon::API::param_n( { Tag       => $tags } );

      print {*STDOUT} dump_json( [ @sqs_attributes, @sqs_tags ] );

      return $sqs->CreateQueue( [ "QueueName=$queue_name", @sqs_attributes, @sqs_tags ] );
    }
    else {

      return $sqs->CreateQueue(
        { QueueName  => $queue_name,
          tags       => [ { Name              => $queue_name }, { Environment  => 'dev' } ],
          Attributes => [ { VisibilityTimeout => 40 },          { DelaySeconds => 60 } ]
        }
      );
    }
  };

  print {*STDOUT} dump_json($rsp);

  return $rsp;
}

########################################################################
sub _SendMessage {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $sqs = $package->service($options);

  my ( $queue, $message ) = @args;
  croak "SendMessage queue-name message\n"
    if !$queue || !$message;

  my $queue_url = queue_url( $sqs, $queue );

  my $message_attributes = {
    foo => {
      DataType    => 'String',
      StringValue => 'bar',
    },
    bar => {
      DataType      => 'String',
      'StringValue' => 'foo'
    },
  };

  my $rsp = $sqs->SendMessage(
    { QueueUrl          => $queue_url,
      MessageBody       => $message,
      MessageAttributes => $message_attributes,
    }
  );

  print {*STDOUT} dump_json($rsp);

  return $rsp;
}

########################################################################
sub _ReceiveMessage {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $sqs = $package->service($options);

  my $queue_name = $args[0];

  my $queue_url = queue_url( $sqs, $queue_name );

  my $rsp = $sqs->ReceiveMessage(
    { QueueUrl              => $queue_url,
      MessageAttributeNames => ['All'],
    }
  );

  print {*STDERR} Dumper($rsp);

  return $rsp;
}

1;
