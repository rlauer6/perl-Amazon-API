package Amazon::ECR;

use strict;
use warnings;

use Data::Dumper;
use JSON;

our $DESCRIPTIONS = { GetAuthorizationToken =>
    q{Retrieves an authorization token: run GetAuthorizationToken}, };

use parent qw( Amazon::API APIExample );

our @API_METHODS = qw{
  BatchCheckLayerAvailability
  BatchDeleteImage
  BatchGetImage
  BatchGetRepositoryScanningConfiguration
  CompleteLayerUpload
  CreatePullThroughCacheRule
  CreateRepository
  DeleteLifecyclePolicy
  DeletePullThroughCacheRule
  DeleteRegistryPolicy
  DeleteRepository
  DeleteRepositoryPolicy
  DescribeImageReplicationStatus
  DescribeImages
  DescribeImageScanFindings
  DescribePullThroughCacheRules
  DescribeRegistry
  DescribeRepositories
  GetAuthorizationToken
  GetDownloadUrlForLayer
  GetLifecyclePolicy
  GetLifecyclePolicyPreview
  GetRegistryPolicy
  GetRegistryScanningConfiguration
  GetRepositoryPolicy
  InitiateLayerUpload
  ListImages
  ListTagsForResource
  PutImage
  PutImageScanningConfiguration
  PutImageTagMutability
  PutLifecyclePolicy
  PutRegistryPolicy
  PutRegistryScanningConfiguration
  PutReplicationConfiguration
  SetRepositoryPolicy
  StartImageScan
  StartLifecyclePolicyPreview
  TagResource
  UntagResource
  UploadLayerPart
};

caller or __PACKAGE__->main;

########################################################################
sub new {
########################################################################
  my ( $class, @options ) = @_;

  $class = ref($class) || $class;

  my %options = ref( $options[0] ) ? %{ $options[0] } : @options;

  my $self = $class->SUPER::new(
    { service      => 'ecr',
      api          => 'AmazonEC2ContainerRegistry_V20150921',
      api_methods  => \@API_METHODS,
      content_type => 'application/x-amz-json-1.1',
      debug        => $ENV{DEBUG} // 0,
      %options
    }
  );

  return $self;
}

########################################################################
sub _GetAuthorizationToken {
########################################################################
  my ( $package, $options ) = @_;

  my $ecr = $package->service($options);

  my $rsp = $ecr->GetAuthorizationToken();

  return print {*STDOUT} JSON->new->pretty->encode($rsp);
}

1;
