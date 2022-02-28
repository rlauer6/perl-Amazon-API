#!/usr/bin/env perl

package APIExample;

use Data::Dumper;

sub get_descriptions {
  my ($package) = @_;
  
  return eval '${' . $package . '::DESCRIPTIONS}';
}

sub help {
  my ($package, $example) = @_;

  my $descriptions = $package->get_descriptions;
  
  if ( $example ) {
    $descriptions = { $example, $descriptions->{$example} };
  }
  
  foreach my $example (keys %{$descriptions}) {
    print "$package : $example => " . $descriptions->{$example} . "\n";
  }
  
  exit;
}

sub create_api {
  my ($package, $options) = @_;

  return $package->new( { url => $options->{'endpoint-url'} });
}

sub get_options {
  my ($package, @opt_list) = @_;
  
  use Getopt::Long;

  my %options;
  
  GetOptions( \%options, "help|h", "endpoint-url|e=s", @opt_list );

  $package->help(shift @ARGV)
    if $options{help};

  return \%options;
}

sub run {
  my ($package, $example, $options, @args) = @_;

  my $descriptions = $package->get_descriptions;

  if ( $descriptions->{$example} && $package->can('_' . $example) ) {
    $package->can('_' . $example)->($package, $options, @args);
  }
  
}

sub main {
  my $package = shift;
  use Carp::Always;
  
  my $options = $package->get_options;

  my $command = shift @ARGV;
  my $example = shift @ARGV;
    
  if ( $command eq 'run' ) {
    $package->run($example, $options, @ARGV);
  }
  
  exit;
}

1;
