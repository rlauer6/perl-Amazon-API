package Amazon::SSM;

use strict;
use warnings;

use parent qw/Amazon::API APIExample/;

use JSON::PP;
use Data::Dumper;

our $DESCRIPTIONS = {
  PutParameter =>
    "Executes the SSM API 'PutParameter': run PutParameter name value",
  GetParameter => "Executes the SSM API 'GetParameter': run GetParamter name",
  DescribeParameters => "Executes the SSM API 'DescribeParameters'.",
};

our @API_METHODS = qw{
  DescribeParameters
  GetParameter
  PutParameter
};

caller or __PACKAGE__->main();

sub new {
  my ( $class, @options ) = @_;
  $class = ref($class) || $class;

  my %options = ref( $options[0] ) ? %{ $options[0] } : @options;

  my $self = $class->SUPER::new(
    { service      => 'ssm',
      api          => 'AmazonSSM',
      api_methods  => \@API_METHODS,
      content_type => 'application/x-amz-json-1.1',
      debug        => $ENV{DEBUG},
      %options
    }
  );

  return $self;
} ## end sub new

sub _PutParameter {
  my ( $package, $options, $name, $value ) = @_;

  my $ssm = $package->new( url => $options->{'endpoint-url'} );

  if ( $name && $value ) {

    print Dumper $ssm->PutParameter(
      { Name      => $name,
        Value     => $value,
        Type      => 'SecureString',
        Overwrite => JSON::PP::true
      }
    );
  } ## end if ( $name && $value )
  else {
    print "usage: $0 run PutParameter name value\n";
  }

} ## end sub _PutParameter

sub _DescribeParameters {
  my ( $package, $options ) = @_;

  my $ssm = $package->new( url => $options->{'endpoint-url'} );
  
  print Dumper $ssm->DescribeParameters( {} );
} ## end sub _DescribeParameters

sub _GetParameter {
  my ( $package, $options, $name ) = @_;

  my $ssm = $package->new( url => $options->{'endpoint-url'} );

  if ( !$name ) {
    print "usage: $0 run GetParameter name\n";
  }
  else {
    print Dumper $ssm->GetParameter(
      { Name => $name, WithDecryption => JSON::PP::true } );
  }
} ## end sub _GetParameter

1;
