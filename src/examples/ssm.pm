package Amazon::SSM;

# example of 'rolling your own' API

use strict;
use warnings;

use parent qw(APIExample Amazon::API);

use JSON::PP;
use Data::Dumper;
use English qw(-no_match_vars);

our $DESCRIPTIONS = {
  PutParameter =>
    q{Executes the SSM API 'PutParameter': run PutParameter name value},
  GetParameter =>
    q{Executes the SSM API 'GetParameter': run GetParamter name},
  DescribeParameters => q{Executes the SSM API 'DescribeParameters'.},
};

our @API_METHODS = qw{
  DescribeParameters
  GetParameter
  PutParameter
};

caller or __PACKAGE__->main();

########################################################################
sub new {
########################################################################
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
}

########################################################################
sub _PutParameter {
########################################################################
  my ( $package, $options, $name, $value ) = @_;

  my $ssm = $package->new( url => $options->{'endpoint-url'} );

  if ( $name && $value ) {

    print {*STDOUT} Dumper(
      $ssm->PutParameter(
        { Name      => $name,
          Value     => $value,
          Type      => 'SecureString',
          Overwrite => JSON::PP::true
        }
      )
    );
  }
  else {
    print {*STDOUT} "usage: $PROGRAM_NAME run PutParameter name value\n";
  }

  return;
}

########################################################################
sub _DescribeParameters {
########################################################################
  my ( $package, $options ) = @_;

  my $ssm = $package->new( url => $options->{'endpoint-url'} );

  return print {*STDOUT} Dumper( $ssm->DescribeParameters( {} ) );
}

########################################################################
sub _GetParameter {
########################################################################
  my ( $package, $options, $name ) = @_;

  my $ssm = $package->new( url => $options->{'endpoint-url'} );

  if ( !$name ) {
    print {*STDOUT} "usage: $0 run GetParameter name\n";
  }
  else {
    print {*STDOUT} Dumper(
      $ssm->GetParameter(
        { Name => $name, WithDecryption => JSON::PP::true }
      )
    );
  }

  return;
}

1;
