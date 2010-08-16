package Dist::Zilla::PluginBundle::NIGELM;

# ABSTRACT: Build your distributions like FLORA does with NIGELM tweaks

use Moose 1.00;
use namespace::autoclean -also => 'lower';

extends 'Dist::Zilla::PluginBundle::FLORA';
with 'Dist::Zilla::Role::PluginBundle::Easy';

# update FLORA's defaults to suit my modules...
has '+repository_at' => default => github );

has '+authority' => ( default => 'cpan:NIGELM', );

has '+github_user' => ( default => 'nigelm', );

has 'tag_format' => (
      is      => 'ro',
      isa     => Str,
      default => 'release/%v',
  );

has 'tag_message' => (
      is      => 'ro',
      isa     => Str,
      default => 'Release of %v',
  );

# change the configure method to add more bundles...
after configure => sub {
      my $self = shift;

      $self->add_plugins('ReadmeFromPod');
      $self->add_bundle(
          '@Git' => {
              tag_format  => $self->tag_format,
              tag_message => $self->tag_message,
          }
      );

  };

__PACKAGE__->meta->make_immutable;

1;
