package Amazon::CloudWatchEvents;

# this is an example of using the Amazon::API class without using the
# Botocore metadata

use strict;
use warnings;

use Data::Dumper;
use JSON::PP;

our @API_METHODS = qw ( DescribeRule ListRules ListTargetsByRule );

use parent qw(Amazon::API APIExample);

our $DESCRIPTIONS = {
  ListRules    => q{Executes the Events API 'ListRules': run ListRules},
  DescribeRule =>
    q{Executes the Events API 'DescribeRule': run DescribeRule rule-name},
  ListTargetsByRule =>
    q{Executes the Events API 'ListTargetsByRule': run ListTargetsByRule rule-name},
};

caller or __PACKAGE__->main;

########################################################################
sub new {
########################################################################
  my ( $class, @options ) = @_;
  $class = ref($class) || $class;

  my %options = ref( $options[0] ) ? %{ $options[0] } : @options;

  my $self = $class->SUPER::new(
    { api         => 'AWSEvents',
      service     => 'events',
      api_methods => \@API_METHODS,
      %options,
    }
  );

  return $self;
}

########################################################################
sub _ListRules {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $cwe = $package->service($options);

  return print {*STDOUT} JSON::PP->new->pretty->encode( $cwe->ListRules() );
}

########################################################################
sub _DescribeRule {
########################################################################
  my ( $package, $options, $name ) = @_;

  my $cwe = $package->service($options);

  return print {*STDOUT} Dumper( $cwe->DescribeRule( { Name => $name } ) );
}

########################################################################
sub _ListTargetsByRule {
########################################################################
  my ( $package, $options, $rule ) = @_;

  my $cwe = $package->service($options);

  return
    print {*STDOUT} Dumper( $cwe->ListTargetsByRule( { Rule => $rule } ) );
}

1;
