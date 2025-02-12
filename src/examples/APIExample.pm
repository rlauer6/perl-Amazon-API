package APIExample;

use strict;
use warnings;

use Carp;
use English qw(-no_match_vars);
use Data::Dumper;
use JSON::PP;
use Readonly;

our $VERSION = '0.02';

Readonly::Scalar our $TRUE  => 1;
Readonly::Scalar our $FALSE => 0;

use parent qw(Exporter);

our @EXPORT = qw(dump_json normalize_options slurp slurp_json);

our @EXPORT_OK   = qw($TRUE $FALSE);
our %EXPORT_TAGS = ( booleans => [qw($TRUE $FALSE)] );

########################################################################
sub slurp_json {
########################################################################
  my ($file) = @_;

  my $json = eval { return JSON::PP->new->decode( slurp($file) ) };

  croak "ERROR: could not decode JSON string:\n$EVAL_ERROR\n"
    if !$json || $EVAL_ERROR;

  return $json;
}

########################################################################
sub slurp {
########################################################################
  my ($file) = @_;

  local $RS = undef;

  open my $fh, '<', $file
    or croak "ERROR: could not open $file\n";

  my $content = <$fh>;

  close $fh
    or carp "ERROR: could not close $file\n";

  return $content;
}

########################################################################
sub normalize_options {
########################################################################
  my ($options) = @_;

  foreach my $k ( keys %{$options} ) {
    next if $k !~ /\-/xsm;
    my $val = delete $options->{$k};

    $k =~ s/\-/_/gxsm;

    $options->{$k} = $val;
  }

  return %{$options};
}

########################################################################
sub dump_json {
########################################################################
  my ($obj) = @_;

  return JSON::PP->new->pretty->encode($obj);
}

########################################################################
sub get_descriptions {
########################################################################
  my ($package) = @_;

  ## no critic (ProhibitStringyEval, RequireInterpolationOfMetachars)
  return eval '${' . $package . '::DESCRIPTIONS}';
}

########################################################################
sub version {
########################################################################
  my ($package) = @_;

  return eval "\$${package}::VERSION"; ## no critic (ProhibitStringyEval)
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
sub service { goto &create_api }
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

  my %options      = ( pager => 1 );
  my @option_specs = qw(
    help|h
    pager|p!
    endpoint-url|u=s
    version
  );

  GetOptions( \%options, @option_specs, @opt_list );

  if ( $options{help} ) {
    my $example = @ARGV;

    $package->help( $example, %options );
  }

  if ( $options{version} ) {
    print {*STDOUT} sprintf "%s\n", $package->version();
    exit 0;
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
  my $method  = shift @ARGV;

  if ( $command eq 'run' ) {
    $package->run( $method, $options, @ARGV );
  }

  exit 0;
}

1;

__END__

=pod

=head1 NAME

APIExample - Class for exercising various AWS APIs

=head1 SYNOPSIS

 package Amazon::EC2;

 use parent qw( Amazon::API::EC2 APIExample );

 our $DESCRIPTIONS = {
   DescribeSecurityGroups =>
     'Executes the EC2 API "DescribeSubnets": run DescribeSubnets',
 };
 
 caller or __PACKAGE__->main;
 
 ########################################################################
 sub _DescribeSecurityGroups {
 ########################################################################
   my ( $package, $options, @args ) = @_;
 
   my $ec2 = $package->new( url => $options->{'endpoint-url'} );
 
   my @filter = param_n(
     { Filter => [
         { Name  => 'group-name',
           Value => ['tb*']
         }
       ]
     }
   );
 
   return print {*STDOUT} Dumper( $ec2->DescribeSecurityGroups( \@filter ) );
 }

 ...

=head1 DESCRIPTION

This class acts as a wrapper for various classes that exercise a
subset of AWS API calls using the Amazon::API framework.

The API class are usually named for the service (e.g. C<ec2.pm>). Each
of those classes will use this class a parent class and provide
wrapper methods that correspond to the actual API method called by the
Amazon::API::{service} class. These wrapper classes should begin with
an underscore ('_') and essentially provide (or pass along the command
line arguments) the parameters to the method being tested.

The wrapper class usually looks something like:

 sub _SomeMethod {
   my ($package, $options, @args) = @_;
   
   my $service = $package->new;

   my $parameters =  { SomeParmeter => 'some value' };

   return print {*STDOUT} Dumper($service->SomeMethod($parameters));
}

=head1 METHODS AND SUBROUTINES

=head1 AUTHOR

Rob Lauer - <rlauer6@comcast.net>

=head1 SEE ALSO

L<Amazon::API>

=cut
