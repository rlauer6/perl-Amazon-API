package Amazon::EC2;

use strict;
use warnings;

use Data::Dumper;

use Amazon::API qw{ param_n };

use parent qw/ Amazon::API::EC2 APIExample /;

our $DESCRIPTIONS = {
                     DescribeInstances => "Executes the EC2 API 'DescribeInstances': run DescribeInstances",
                     DescribeVpcs => "Executes the EC2 API 'DescribeVpcs': run DescribeVpcs",
                     DescribeSubnets => "Executes the EC2 API 'DescribeSubnets': run DescribeSubnets"
                    };

caller or __PACKAGE__->main;

sub _DescribeInstances {
  my ($package, $options, @args) = @_;
  
  my $ec2 = $package->new(url => $options->{'endpoint-url'});
  print Dumper $ec2->DescribeInstances;
}

sub _DescribeVpcs {
  my ($package, $options, @args) = @_;
  
  my $ec2 = $package->new(url => $options->{'endpoint-url'});
  print Dumper $ec2->DescribeVpcs;
}

sub _DescribeSubnets {
  my ($package, $options, @args) = @_;
  
  my $ec2 = $package->new(url => $options->{'endpoint-url'});
  my @filter = param_n({ Filter => [{ Name => 'vpc-id', Value => [$args[0]] }]});
  
  print Dumper $ec2->DescribeSubnets(\@filter);
}

1;
