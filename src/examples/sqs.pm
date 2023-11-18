package Amazon::SQS;

use strict;
use warnings;

use Data::Dumper;
use JSON::PP     qw(encode_json);
use Scalar::Util qw( reftype );
use APIExample   qw(dump_json);

use parent qw(APIExample Amazon::API::SQS);

our $DESCRIPTIONS = {
  ListQueues  => 'Executes the SQS API "ListQueues".',
  DeleteQueue =>
    'Executes the SQS API "DeleteQueue", deletes a queue named "foo" if it exists.',
  CreateQueue =>
    'Executes the SQS API "CreateQueue", creates a queue named "foo".',
  SendMessage    => 'Executes the SQS API "SendMessage".',
  ReceiveMessage => 'Executes the SQS API "ReceiveMessage".',
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
sub queue_url {
########################################################################
  my ( $sqs, $queue ) = @_;

  my $queues = $sqs->ListQueues;

  my ($queue_url) = grep {/$queue/xsm} @{ $queues || [] };

  return $queue_url;
}

########################################################################
sub _DeleteQueue {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $sqs = $package->service($options);

  my $queue_url = queue_url( $sqs, $args[0] );

  my $rsp;

  if ($queue_url) {
    $rsp = $sqs->DeleteQueue( [ { QueueUrl => $queue_url } ] );

    print {*STDOUT} dump_json($rsp);
  }
  else {
    print {*STDERR} "ERROR: No queue named $args[0] to delete.\n";
  }

  return $rsp;
}

########################################################################
sub _CreateQueue {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $queue_name = $args[0];

  my $sqs = $package->service($options);

  my $attributes = [ { Name => 'VisibilityTimeout', Value => '100' } ];
  my $tags       = [ { Key  => 'Name',              Value => $queue_name } ];

  my @sqs_attributes = Amazon::API::param_n( { Attribute => $attributes } );
  my @sqs_tags       = Amazon::API::param_n( { Tag       => $tags } );

  print {*STDOUT} dump_json( [ @sqs_attributes, @sqs_tags ] );

  my $rsp
    = $sqs->CreateQueue(
    [ "QueueName=$queue_name", @sqs_attributes, @sqs_tags ] );

  print {*STDOUT} dump_json($rsp);

  return $rsp;
}

########################################################################
sub _SendMessage {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $sqs = $package->service($options);

  my ( $queue, $message ) = @args;

  $queue   //= 'foo';
  $message //= 'Test Message';

  my $queue_url = queue_url( $sqs, $queue );

  my $rsp = $sqs->SendMessage(
    [ { QueueUrl    => $queue_url },
      { MessageBody => encode_json( { Message => $message } ) }
    ]
  );

  print {*STDOUT} dump_json($rsp);

  return $rsp;
}

########################################################################
sub _ReceiveMessage {
########################################################################
  my ( $package, $options ) = @_;

  my $sqs = $package->service($options);

  my $queue_url = queue_url( $sqs, 'foo' );

  my $message;

  if ($queue_url) {
    $message = $sqs->ReceiveMessage("QueueUrl=$queue_url");

    dump_json($message);
  }

  return $message;
}

1;
