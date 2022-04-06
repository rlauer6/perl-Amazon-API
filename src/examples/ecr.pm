package Amazon::ECR;

use strict;
use warnings;

use parent qw{ Amazon::API };

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

sub new {
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
} ## end sub new

sub main {
  use Data::Dumper;
  
  print Dumper [Amazon::ECR->new->GetAuthorizationToken];
}
