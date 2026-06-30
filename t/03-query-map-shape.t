#!/usr/bin/env perl

## Regression test for query-protocol serialization of map-typed
## parameters (e.g. SNS Publish's MessageAttributes, a
## map<String, MessageAttributeValue>).
##
## Drives the real shape-construction + finalize + query-string
## flattening path with a minimal hand-authored botocore model, with
## NO live AWS call. Asserts the serialized output matches what AWS's
## own tooling produces for SNS Publish:
##
##   MessageAttributes.entry.1.Name=Foo
##   MessageAttributes.entry.1.Value.DataType=String
##   MessageAttributes.entry.1.Value.StringValue=Bar
##
## Three things this guards against:
##   1. the map key being stringified to a blessed-object ref instead
##      of its actual value ('Foo')
##   2. the resulting '=HASH(0x...)' garbage desyncing the whole query
##      string
##   3. 'member' vs 'entry' wrapper for maps in query protocol

use strict;
use warnings;

use Test::More;

use English qw(-no_match_vars);

use_ok('Amazon::API::Botocore::Shape');
use_ok('Amazon::API::Botocore::Shape::Utils');

## Minimal SNS model: just the shapes MessageAttributes needs.
my %sns_shapes = (
  String => {
    type => 'string',
  },
  MessageAttributeValue => {
    type     => 'structure',
    required => ['DataType'],
    members  => {
      DataType    => { shape => 'String' },
      StringValue => { shape => 'String' },
    },
  },
  MessageAttributeMap => {
    type => 'map',
    key   => { shape => 'String', locationName => 'Name' },
    value => { shape => 'MessageAttributeValue', locationName => 'Value' },
  },
);

Amazon::API::Botocore::Shape::Utils::register_service_shapes( 'SNS', \%sns_shapes );

my $map_class = Amazon::API::Botocore::Shape::Utils::require_shape( 'MessageAttributeMap', 'SNS' );

ok( $map_class, 'require_shape returned a class' )
  or BAIL_OUT('cannot build MessageAttributeMap shape class');

my $input = {
  Foo => {
    DataType    => 'String',
    StringValue => 'Bar',
  },
};

my $shape = eval { $map_class->new($input) };

ok( $shape && !$EVAL_ERROR, 'constructed map shape from native hashref' )
  or diag("construction error: $EVAL_ERROR");

## finalize for the query protocol, then flatten to query-string pairs.
my $finalized = eval { $shape->finalize('query') };

ok( !$EVAL_ERROR, 'finalize(query) did not die' )
  or diag("finalize error: $EVAL_ERROR");

my @pairs = eval {
  Amazon::API::Botocore::Shape::Utils::query_param_n( $finalized, 'MessageAttributes' );
};

ok( !$EVAL_ERROR, 'query_param_n did not die' )
  or diag("query_param_n error: $EVAL_ERROR");

my %got = map { my ( $k, $v ) = split /=/xsm, $_, 2; ( $k => $v ) } @pairs;

## --- the actual assertions ---

is(
  $got{'MessageAttributes.entry.1.Name'},
  'Foo',
  'map key serialized as the attribute name, not a stringified shape object'
);

is(
  $got{'MessageAttributes.entry.1.Value.DataType'},
  'String',
  'nested structure value DataType serialized correctly'
);

is(
  $got{'MessageAttributes.entry.1.Value.StringValue'},
  'Bar',
  'nested structure value StringValue serialized correctly'
);

## no stray key containing a blessed-object stringification
ok(
  !( grep { /HASH\(0x/xsm || /Amazon::API::Botocore::Shape/xsm } keys %got ),
  'no query-string key contains a stringified shape object'
);

## uses 'entry' wrapper (map), not 'member' (list)
ok(
  !( grep {/[.]member[.]/xsm} keys %got ),
  q{map uses 'entry' wrapper, not 'member'}
);

done_testing;
