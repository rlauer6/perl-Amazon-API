package Amazon::STS;

## no critic ( Capitalization)

use strict;
use warnings;

use parent qw( APIExample Amazon::API::STS );

use Carp;
use Data::Dumper;

use English qw( -no_match_vars );
use JSON::PP;

our $VERSION = '0.01';

our $DESCRIPTIONS = { AssumeRole => 'Executes the AssumeRole API' };

caller or __PACKAGE__->main();

########################################################################
sub get_credentials_from_role {
########################################################################
  my ( $self, $role_arn ) = @_;

  my ( undef, $role_session_name ) = split /\//xsm, $role_arn;

  my $args = {
    RoleArn         => $role_arn,
    RoleSessionName => $role_session_name,
  };

  my $rsp = eval { return $self->AssumeRole($args); };

  my $credentials;

  if ( !$EVAL_ERROR ) {
    $credentials = $rsp->{AssumeRoleResult}->{Credentials};
    $credentials->{Version} = '1';
  }

  return $credentials;
}

########################################################################
sub _AssumeRole {
########################################################################
  my ( $package, $options ) = @_;

  my $sts = $package->service($options);

  my $credentials = $sts->get_credentials_from_role( shift @ARGV );

  if ($credentials) {
    print {*STDOUT} JSON::PP->new->pretty->encode($credentials);
  }

  return $credentials;
}

1;
