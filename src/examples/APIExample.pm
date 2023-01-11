package APIExample;

use strict;
use warnings;

use Carp;
use Data::Dumper;
use ReadonlyX;

our $VERSION = '0.01';

Readonly our $TRUE  => 1;
Readonly our $FALSE => 0;

use parent qw(Exporter);

our @EXPORT_OK   = qw($TRUE $FALSE);
our %EXPORT_TAGS = ( booleans => [qw($TRUE $FALSE)] );

########################################################################
sub get_descriptions {
########################################################################
  my ($package) = @_;

  ## no critic (ProhibitStringyEval, RequireInterpolationOfMetachars)
  return eval '${' . $package . '::DESCRIPTIONS}';
}

########################################################################
sub help {
########################################################################
  my ( $package, $example, %options ) = @_;

  my $descriptions = $package->get_descriptions;

  if ($example) {
    $descriptions = { $example, $descriptions->{$example} };
  }

  my $token;

  if ( $options{pager} ) {
    $token = eval {
      require IO::Pager;

      IO::Pager::open( *STDOUT, '|-:utf8', 'Unbuffered' );
    };
  }
  print {*STDOUT} <<'HELP';
usage: perl service-name.pm options run command arguments

Options
-------
-h, --help              this
-u, --endpoint-url      alternate endpoint for AWS services
-p, --pager, --no-pager use, do not use a pager, default: use pager

Commands
--------
See below

HELP

  foreach my $example ( keys %{$descriptions} ) {
    print {*STDOUT} sprintf "%s : %s => %s\n", $package, $example,
      $descriptions->{$example};
  }

  exit;
}

########################################################################
sub create_api {
########################################################################
  my ( $package, $options ) = @_;

  return $package->new( { url => $options->{'endpoint-url'} } );
}

########################################################################
sub get_options {
########################################################################
  my ( $package, @opt_list ) = @_;

  use Getopt::Long qw(:config no_ignore_case);

  my %options = ( pager => 1 );

  GetOptions( \%options, 'help|h', 'pager|p!', 'endpoint-url|u=s',
    @opt_list );

  if ( $options{help} ) {
    my $example = @ARGV;

    $package->help( $example, %options );
  }

  return \%options;
}

########################################################################
sub run {
########################################################################
  my ( $package, $example, $options, @args ) = @_;

  my $descriptions = $package->get_descriptions;

  my $func = sprintf '_%s', $example;

  croak 'no such command ' . $example
    if !$descriptions->{$example} || !$package->can($func);

  return $package->can($func)->( $package, $options, @args );
}

########################################################################
sub main {
########################################################################
  my ($package) = @_;

  use Carp::Always;

  my $options = $package->get_options;

  my $command = shift @ARGV;
  my $example = shift @ARGV;

  if ( $command eq 'run' ) {
    $package->run( $example, $options, @ARGV );
  }

  exit;
}

1;
