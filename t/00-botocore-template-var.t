use strict;
use warnings;

use Data::Dumper;

use Test::More tests => 3;

use_ok('Amazon::API::Template');

Amazon::API::Template->import('to_template_var');

my $foo = to_template_var('foo');

is( $foo, '@foo@', 'scalar' )
  or diag( Dumper [$foo] );

my @vars          = qw{ foo bar };
my @expected_vars = qw{ @foo@ @bar@ };

my @got_vars = to_template_var(@vars);

is_deeply( \@got_vars, \@expected_vars )
  or diag( Dumper [@got_vars] );
