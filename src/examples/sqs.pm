package Amazon::SQS;

use strict;
use warnings;

use parent qw/Amazon::API APIExample/;
use Data::Dumper;
use Scalar::Util qw{ reftype };
use JSON::PP qw{encode_json};

our $DESCRIPTIONS = {
  ListQueues  => "Executes the SQS API 'ListQueues'.",
  DeleteQueue =>
    "Executes the SQS API 'DeleteQueue', deletes a queue named 'foo' if it exists.",
  CreateQueue =>
    "Executes the SQS API 'CreateQueue', creates a queue named 'foo'.",
  SendMessage    => "Executes the SQS API 'SendMessage'.",
  ReceiveMessage => "Executes the SQS API 'ReceiveMessage'.",
};

our @API_METHODS = qw{
  ListQueues
  CreateQueue
  DeleteQueue
  ReceiveMessage
  SendMessage
};

caller() || __PACKAGE__->main;

sub new {
  my ($class, @options) = @_;
  $class = ref($class) || $class;
  
  my %options = ref($options[0]) ? %{$options[0]} : @options;
  
  return $class->SUPER::new(
    { service     => 'sqs',
      http_method => 'GET',
      api_methods => \@API_METHODS,
      decode_always => 1,
      debug         => $ENV{DEBUG},
      %options
    }
  );
}

sub _ListQueues {
  my ($package, $options) = @_;

  my $sqs = $package->new(url => $options->{'endpoint-url'});
  
  print Dumper $sqs->ListQueues;
}

sub get_queue_url {
  my ($package, $queue) = @_;

  my $queues = $package->ListQueues;

  my $queue_url;

  if ( $queues ) {
    
    $queues = $queues->{ListQueuesResult}->{QueueUrl};
    
    if ($queues) {
      if (ref($queues) && reftype($queues) eq 'ARRAY') {
        ($queue_url) = grep { /$queue/ } @{$queues};
      }
      else {
        $queue_url = $queues;
      }
    }
  }
  else {
    print "No queues!\n";
  }

  return $queue_url;
}

sub _DeleteQueue {
  my ($package, $options) = @_;
  
  my $sqs = $package->new(url => $options->{'endpoint-url'});
  my $queue_url = $sqs->get_queue_url('foo');
  
  if ($queue_url) {
    print Dumper $sqs->DeleteQueue( [ { QueueUrl => $queue_url } ] );
  }
  else {
    print "No queue named 'foo' to delete.\n";
  }
}

sub _CreateQueue {
  my ($package, $options) = @_;

  my $sqs = $package->new(url => $options->{'endpoint-url'});
  
  my $attributes = [ { Name => 'VisibilityTimeout', Value => '100' } ];
  my @sqs_attributes = Amazon::API->param_n(Attribute => $attributes);
  
  print Dumper $sqs->CreateQueue([ "QueueName=foo", @sqs_attributes ]);
}

sub _SendMessage {
  my ($package, $options) = @_;

  my $sqs = $package->new(url => $options->{'endpoint-url'});

  my $queue_url = $sqs->get_queue_url('foo');
  
  if ($queue_url) {
    print Dumper $sqs->SendMessage(
      [ { QueueUrl    => $queue_url },
        { MessageBody => encode_json( { Message => "Test Message" } ) }
      ]
    );
  } ## end if ($queue_url)
}

sub _ReceiveMessage {
  my ($package, $options) = @_;

  my $sqs = $package->new(url => $options->{'endpoint-url'});
  
  my $queue_url = $sqs->get_queue_url('foo');
  
  if ( $queue_url ) {
    print Dumper $sqs->ReceiveMessage("QueueUrl=$queue_url");
  }
}

1;
