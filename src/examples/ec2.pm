package Amazon::EC2;

use strict;
use warnings;

use Data::Dumper;
use Amazon::API qw( param_n);
use APIExample  qw(dump_json);

use parent qw( APIExample Amazon::API::EC2);

BEGIN {
  our $VERSION = $Amazon::API::EC2::VERSION;
}

our $DESCRIPTIONS = {
  DescribeInstances =>
    'Executes the EC2 API "DescribeInstances": run DescribeInstances',
  DescribeVpcs    => 'Executes the EC2 API "DescribeVpcs": run DescribeVpcs',
  DescribeSubnets =>
    'Executes the EC2 API "DescribeSubnets": run DescribeSubnets [vpc-id]',
  DescribeSecurityGroups =>
    'Executes the EC2 API "DescribeSecurityGroups": run DescribeSecurityGroups [group-name]',
};

caller or __PACKAGE__->main;

########################################################################
sub _DescribeSecurityGroups {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $ec2 = $package->service($options);

  my $security_groups
    = $ec2->DescribeSecurityGroups( get_filter( 'group-name', @args ) );

  return print {*STDOUT} Dumper($security_groups);
}

########################################################################
sub _DescribeInstances {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $ec2 = $package->service($options);

  my $ec2_instances = $ec2->DescribeInstances;

  return print {*STDOUT} dump_json($ec2_instances);
}

########################################################################
sub _DescribeVpcs {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $ec2 = $package->service($options);

  my $vpc_list = $ec2->DescribeVpcs;

  return print {*STDOUT} dump_json($vpc_list);
}

########################################################################
sub _DescribeSubnets {
########################################################################
  my ( $package, $options, @args ) = @_;

  my $ec2 = $package->service($options);

  $ec2->set_debug(1);

  $ec2->set_action('DescribeSubnets');

  #  my $subnets = $ec2->DescribeSubnets( get_filter( 'vpc-id', @args ) );
  my $subnets = $ec2->DescribeSubnets(
    { Filters => [
        { 'Name'   => 'vpc-id',
          'Values' => [ $args[0] ]
        },
      ],
    }
  );

  return print {*STDOUT} dump_json($subnets);
}

########################################################################
sub get_filter {
########################################################################
  my ( $name, @filter ) = @_;

  return ()
    if !@filter;

  return [
    param_n(
      { Filter => [
          { Name  => $name,
            Value => \@filter,
          }
        ]
      }
    )
  ];
}
1;

__END__

=pod

=head1  NAME

=head1  SYNOPSIS

=head1  DESCRIPTION

=head1  METHODS AND SUBROUTINES

=head1  AUTHOR

=head1 SEE OTHER

=cut
