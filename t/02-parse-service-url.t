use strict;    ## no critic (Modules::RequireVersionVar)
use warnings;

use Test::More;

use Data::Dumper;
use charnames qw{ :full };
use Amazon::API::Signature4 qw{ parse_service_url };

my %sample_urls = (
  's3.us-east-2.amazonaws.com'                    => [qw{ s3 us-east-2 }],
  's3-fips.us-east-2.amazonaws.com'               => [qw{ s3 us-east-2 }],
  's3.dualstack.us-east-2.amazonaws.com'          => [qw{ s3 us-east-2}],
  's3-fips.dualstack.us-east-2.amazonaws.com'     => [qw{ s3 us-east-2}],
  'account-id.s3-control.us-east-2.amazonaws.com' => [qw{ s3 us-east-2}],
  'account-id.s3-control-fips.us-east-2.amazonaws.com' => [qw{ s3 us-east-2}],
  'account-id.s3-control.dualstack.us-east-2.amazonaws.com' =>
    [qw{ s3 us-east-2 }],
  'account-id.s3-control-fips.dualstack.us-east-2.amazonaws.com' =>
    [qw{ s3 us-east-2 }],
  's3.us-east-2.amazonaws.com'                    => [qw{ s3 us-east-2 }],
  's3-fips.us-east-2.amazonaws.com'               => [qw{ s3 us-east-2 }],
  's3.dualstack.us-east-2.amazonaws.com'          => [qw{ s3 us-east-2}],
  's3-fips.dualstack.us-east-2.amazonaws.com'     => [qw{ s3 us-east-2 }],
  'account-id.s3-control.us-east-2.amazonaws.com' => [qw{ s3 us-east-2 }],
  'account-id.s3-control-fips.us-east-2.amazonaws.com' =>
    [qw{ s3 us-east-2 }],
  'account-id.s3-control.dualstack.us-east-2.amazonaws.com' =>
    [qw{ s3 us-east-2}],
  'account-id.s3-control-fips.dualstack.us-east-2.amazonaws.com' =>
    [qw{ s3 us-east-2 }],
  'bucket-name.s3.us-east-2.amazonaws.com'     => [qw{ s3 us-east-2 }],
  'bucket-name.net.s3.us-east-2.amazonaws.com' => [qw{ s3 us-east-2 }],
  's3.amazonaws.com'                           => [qw{ s3 us-east-1 }],
  'cognito-identity.us-east-2.amazonaws.com'   =>
    [qw{ cognito-identity us-east-2 }],
  'cognito-identity.amazonaws.com' => [qw{ cognito-identity us-east-1 }],
  'es.eu-west-1.amazonaws.com'     => [qw{ es eu-west-1 }],
);

plan tests => 2 * keys %sample_urls;

foreach my $host ( keys %sample_urls ) {
  my ( $h, $s, $r ) = parse_service_url(
    host           => $host,
    default_region => 'us-east-1'
  );

  is( $s, $sample_urls{$host}->[0], 'service: ' . $host )
    or diag( $h, $s, $r );

  is( $r, $sample_urls{$host}->[1], 'region: ' . $host )
    or diag( $h, $s, $r );
} ## end foreach my $host ( keys %sample_urls)

1;
