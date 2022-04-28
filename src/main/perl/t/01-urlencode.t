use strict;
use warnings;

use Test::More tests => 6;

use_ok('Amazon::API');

Amazon::API->import('create_urlencoded_content');

my $version = '2022-04-10';
my $action  = 'TestAPI';

my $expected = "Action=$action&Foo=2&This=1&Version=$version";

my %tests = (
  'simple list'    => [ 'This',        '1', 'Foo', '2' ],
  'formatted list' => [ 'This=1',      'Foo=2' ],
  'hash list'      => [ { This => 1 }, { Foo => 2 } ],
  'hash'           => { This => 1, Foo => 2 },
  'scalar'         => $expected,
);

foreach my $t ( keys %tests ) {
  my $got_str = create_urlencoded_content( $tests{$t}, $action, $version );

  my $query_string = join '&', sort split /&/, $got_str;

  is( $query_string, $expected, $t ) or diag($got_str);
} ## end foreach my $t ( keys %tests)
