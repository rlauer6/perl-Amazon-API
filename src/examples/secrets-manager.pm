package Amazon::SecretsManager;

use strict;
use warnings;

use APIExample qw(:booleans);

use parent qw(Amazon::API APIExample);

use Data::Dumper;
use JSON::PP;
use Data::UUID;
use List::Util qw(any none);

local $Data::Dumper::Pair  = q{:};
local $Data::Dumper::Terse = $TRUE;

our $DESCRIPTIONS = {
  CreateSecret =>
    q{Executes the SecretsManager API 'CreateSecret': run CreateSecret secret value},
  DeleteSecret =>
    q{Executes the SecretsManager API 'DeleteSecret': run DeleteSecret secret},
  GetSecretValue =>
    q{Executes the SecretsManager API 'GetSecretValue': run GetSecretValue secret},
  ListSecrets =>
    q{Executes the SecretsManager API 'ListSecrets': run ListSecrets},
  UpdateSecret =>
    q{Executes the SecretsManager API 'UpdateSecret': run UpdateSecret secret value},
};

our @API_METHODS = qw{
  CreateSecret
  DeleteSecret
  GetSecretValue
  ListSecrets
  UpdateSecret
};

caller or __PACKAGE__->main();

########################################################################
sub new {
########################################################################
  my ( $class, @options ) = @_;

  $class = ref($class) || $class;

  my %options = ref( $options[0] ) ? %{ $options[0] } : @options;

  my $self = $class->SUPER::new(
    { decode_always => $TRUE,
      service       => 'secretsmanager',
      api           => 'secretsmanager',
      api_methods   => \@API_METHODS,
      debug         => $ENV{DEBUG},
      %options
    },
  );

  return $self;
}

########################################################################
sub _ListSecrets {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $secrets_mgr
    = Amazon::SecretsManager->new( url => $options->{'endpoint-url'} );

  return print {*STDOUT} Dumper $secrets_mgr->ListSecrets( {} );
}

########################################################################
sub _DeleteSecret {
########################################################################
  my ( $package, $options, $secret ) = @_;

  my $secrets_mgr
    = Amazon::SecretsManager->new( url => $options->{'endpoint-url'} );

  my $secret_list = $secrets_mgr->ListSecrets( {} );
  $secret_list = $secret_list->{SecretList};

  return
    if !$secret_list;

  my @names = map { $_->{Name} } @{$secret_list};

  return
    if none { $secret eq $_ } @names;

  return print {*STDOUT} Dumper(
    $secrets_mgr->DeleteSecret(
      { SecretId                   => $secret,
        ForceDeleteWithoutRecovery => JSON::PP::true
      }
    )
  );

}

########################################################################
sub _CreateSecret {
########################################################################
  my ( $package, $options, $secret, $value ) = @_;

  my $secrets_mgr
    = Amazon::SecretsManager->new( url => $options->{'endpoint-url'} );

  return print {*STDOUT} Dumper $secrets_mgr->CreateSecret(
    { Name               => $secret,
      SecretString       => $value,
      ClientRequestToken => Data::UUID->new->create_str
    },
  );
}

########################################################################
sub _UpdateSecret {
########################################################################
  my ( $package, $options, $secret, $value ) = @_;

  my $secrets_mgr
    = Amazon::SecretsManager->new( url => $options->{'endpoint-url'} );

  return print {*STDOUT} Dumper $secrets_mgr->UpdateSecret(
    { SecretId           => $secret,
      SecretString       => $value,
      ClientRequestToken => Data::UUID->new->create_str
    },
  );
}

########################################################################
sub _GetSecretValue {
########################################################################
  my ( $package, $options, $secret, $value ) = @_;

  my $secrets_mgr
    = Amazon::SecretsManager->new( url => $options->{'endpoint-url'} );

  return
    print {*STDOUT}
    Dumper $secrets_mgr->GetSecretValue( { SecretId => $secret } );
}

1;
