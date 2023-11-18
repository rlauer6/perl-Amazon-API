package Amazon::Route53;

## no critic ( Capitalization)

use strict;
use warnings;

use Carp;
use Data::Dumper;

use English    qw( -no_match_vars );
use APIExample qw(dump_json);

use parent qw( APIExample Amazon::API::Route53  );

our $VERSION = '0.01';

our $DESCRIPTIONS = {
  ListHostedZones        => 'List hosted zones',
  ListResourceRecordSets => 'List record sets [zone-id]'
};

caller or __PACKAGE__->main();

########################################################################
sub _ListHostedZones {
########################################################################
  my ( $package, $options ) = @_;

  my $rt53 = $package->service($options);

  my $hosted_zones = $rt53->ListHostedZones();

  print {*STDOUT} dump_json($hosted_zones);

  return $hosted_zones;
}

########################################################################
sub _ListResourceRecordSets {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $rt53 = $package->service($options);

  my $record_sets
    = $rt53->ListResourceRecordSets( { HostedZoneId => $args[0] } );

  print {*STDOUT} dump_json($record_sets);

  return $record_sets;
}

1;

__END__
