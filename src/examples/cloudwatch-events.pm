package Amazon::CloudWatchEvents;

use strict;
use warnings;

use parent qw/Amazon::API APIExample/;

use Data::Dumper;

our @API_METHODS = qw { DescribeRule ListRules ListTargetsByRule };

our $DESCRIPTIONS = {
  ListRules    => "Executes the Events API 'ListRules': run ListRules",
  DescribeRule =>
    "Executes the Events API 'DescribeRule': run DescribeRule rule-name",
  ListTargetsByRule =>
    "Executes the Events API 'ListTargetsByRule': run ListTargetsByRule rule-name",
};

caller or __PACKAGE__->main;

sub new {
  my ( $class, @options ) = @_;
  $class = ref($class) || $class;

  my %options = ref( $options[0] ) ? %{ $options[0] } : @options;

  my $self = $class->SUPER::new(
    { api         => 'AWSEvents',
      service     => 'events',
      api_methods => \@API_METHODS,
      %options
    }
  );

  return $self;
} ## end sub new

sub _ListRules {
  my ( $package, $options, @args ) = @_;

  my $cwe = $package->new( url => $options->{'endpoint-url'} );

  print Dumper $cwe->ListRules( {} );
} ## end sub _ListRules

sub _DescribeRule {
  my ( $package, $options, $name ) = @_;

  my $cwe = $package->new( url => $options->{'endpoint-url'} );

  print Dumper $cwe->DescribeRule( { Name => $name } );
} ## end sub _DescribeRule

sub _ListTargetsByRule {
  my ( $package, $options, $rule ) = @_;

  my $cwe = $package->new( url => $options->{'endpoint-url'} );

  print Dumper $cwe->ListTargetsByRule( { Rule => $rule } );
} ## end sub _ListTargetsByRule

1;
