package Amazon::EC2;

use strict;
use warnings;

use Data::Dumper;

use parent qw/ Amazon::API APIExample /;

our $DESCRIPTIONS = {
                     DescribeInstances => "Executes the EC2 API 'DescribeInstances': run DescribeInstances"
                    };

our @API_METHODS = qw{ DescribeInstances };

caller or __PACKAGE__->main;

sub new {
  my ($class, @options) = @_;
  $class = ref($class) || $class;
  
  my %options = ref($options[0]) ? %{$options[0]} : @options;
  
  
  $class->SUPER::new({
		      service          => 'ec2',
		      version          => '2016-11-15',
		      api_methods      => \@API_METHODS,
                      debug            => $ENV{DEBUG} // 0,
                      %options
		     });
}

sub _DescribeInstances {
  my ($package, $options, @args) = @_;
  
  my $ec2 = $package->new(url => $options->{'endpoint-url'});
  print Dumper $ec2->DescribeInstances;
}

1;
