package Amazon::SecretsManager;

use strict;
use warnings;

use parent qw/Amazon::API APIExample/;

use Data::Dumper;
use JSON::PP;
use Data::UUID;

local $Data::Dumper::Pair  = q{:};
local $Data::Dumper::Terse = 1;

our $DESCRIPTIONS = {
  CreateSecret =>
    "Executes the SecretsManager API 'CreateSecret': run CreateSecret secret value",
  DeleteSecret =>
    "Executes the SecretsManager API 'DeleteSecret': run DeleteSecret secret",
  GetSecretValue =>
    "Executes the SecretsManager API 'GetSecretValue': run GetSecretValue secret",
  ListSecrets =>
    "Executes the SecretsManager API 'ListSecrets': run ListSecrets",
  UpdateSecret =>
    "Executes the SecretsManager API 'UpdateSecret': run UpdateSecret secret value",
};

our @API_METHODS = qw{
  CreateSecret
  DeleteSecret
  GetSecretValue
  ListSecrets
  UpdateSecret
};

caller or __PACKAGE__->main();

sub new {
  my ( $class, @options ) = @_;
  $class = ref($class) || $class;

  my %options = ref( $options[0] ) ? %{ $options[0] } : @options;

  my $self = $class->SUPER::new(
    { decode_always => 1,
      service       => 'secretsmanager',
      api           => 'secretsmanager',
      api_methods   => \@API_METHODS,
      debug         => $ENV{DEBUG},
      %options
    },
  );

  return $self;
} ## end sub new

sub _ListSecrets {
  my ( $package, $options, @args ) = @_;

  my $secrets_mgr
    = Amazon::SecretsManager->new( url => $options->{'endpoint-url'} );

  print Dumper $secrets_mgr->ListSecrets( {} );
} ## end sub _ListSecrets

sub _DeleteSecret {
  my ( $package, $options, $secret ) = @_;

  my $secrets_mgr
    = Amazon::SecretsManager->new( url => $options->{'endpoint-url'} );

  my $secret_list = $secrets_mgr->ListSecrets( {} );
  $secret_list = $secret_list->{SecretList};

  if ($secret_list) {
    my @names = map { $_->{Name} } @{$secret_list};

    if ( grep {/$secret/xsm} @names ) {
      print Dumper $secrets_mgr->DeleteSecret(
        { SecretId => $secret, ForceDeleteWithoutRecovery => JSON::PP::true }
      );
    }
  } ## end if ($secret_list)
} ## end sub _DeleteSecret

sub _CreateSecret {
  my ( $package, $options, $secret, $value ) = @_;

  my $secrets_mgr
    = Amazon::SecretsManager->new( url => $options->{'endpoint-url'} );

  print Dumper $secrets_mgr->CreateSecret(
    { Name               => $secret,
      SecretString       => $value,
      ClientRequestToken => Data::UUID->new->create_str
    },
  );
} ## end sub _CreateSecret

sub _UpdateSecret {
  my ( $package, $options, $secret, $value ) = @_;

  my $secrets_mgr
    = Amazon::SecretsManager->new( url => $options->{'endpoint-url'} );

  print Dumper $secrets_mgr->UpdateSecret(
    { SecretId           => $secret,
      SecretString       => $value,
      ClientRequestToken => Data::UUID->new->create_str
    },
  );
} ## end sub _UpdateSecret

sub _GetSecretValue {
  my ( $package, $options, $secret, $value ) = @_;

  my $secrets_mgr
    = Amazon::SecretsManager->new( url => $options->{'endpoint-url'} );

  print Dumper $secrets_mgr->GetSecretValue( { SecretId => $secret } );
} ## end sub _GetSecretValue

1;
