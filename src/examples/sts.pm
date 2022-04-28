#!/usr/bin/env perl

package Amazon::STS;

use strict;
use warnings;

use parent qw{ Amazon::API::STS };

use Carp;
use English qw{ -no_match_vars };
use JSON::PP;

caller or __PACKAGE__->main();

sub get_credentials_from_role {
  my ( $self, $role_arn ) = @_;

  my ( undef, $role_session_name ) = split /\//, $role_arn;

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
} ## end sub get_credentials_from_role

sub main {
  my $sts = Amazon::STS->new(
    debug => $ENV{DEBUG},
    url   => $ENV{ENDPOINT_URL}
  );

  my $credentials = $sts->get_credentials_from_role( shift @ARGV );

  if ($credentials) {
    print JSON::PP->new->pretty->encode($credentials);
  }
} ## end sub main

1;
