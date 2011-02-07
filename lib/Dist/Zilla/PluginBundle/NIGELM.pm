package Dist::Zilla::PluginBundle::NIGELM;

# ABSTRACT: Build your distributions like FLORA does with NIGELM tweaks

use Moose 1.00;
use Method::Signatures::Simple;
use Moose::Util::TypeConstraints;
use MooseX::Types::URI qw(Uri);
use MooseX::Types::Email qw(EmailAddress);
use MooseX::Types::Moose qw(Bool Str CodeRef);
use MooseX::Types::Structured 0.20 qw(Map Dict Optional);
use namespace::autoclean -also => 'lower';

extends 'Dist::Zilla::PluginBundle::FLORA';

=head1 SYNOPSIS

In dist.ini:

  [@NIGELM]
  dist = Distribution-Name
  repository_at = github

=head1 DESCRIPTION

This is the L<Dist::Zilla> configuration I use to build my
distributions. It is strongly based on the @FLORA bundle, and
extends that bundle (so if that bundle is changed incompatibly I
get to keep both pieces)

It is roughly equivalent to:

  [@Filter]
  bundle = @Basic
  remove = Readme

  [MetaConfig]
  [MetaJSON]
  [PkgVersion]
  [PodSyntaxTests]
  [NoTabsTests]
  [EOLTests]
  [ReadmeFromPod]
  [PodCoverageTests]

  [MetaResources]
  repository.type   = git
  repository.url    = git://github.com/nigelm/${lowercase_dist}
  repository.web    = http://github.com/nigelm/${lowercase_dist}
  bugtracker.web    = http://rt.cpan.org/Public/Dist/Display.html?Name=${dist}
  bugtracker.mailto = bug-${dist}@rt.cpan.org
  homepage          = http://search.cpan.org/dist/${dist}

  [Authority]
  authority   = cpan:NIGELM
  do_metadata = 1

  [@Git]

  [PodWeaver]
  config_plugin = @FLORA

  [AutoPrereqs]

=head2 Tweakables

=head3 authority

The authority for this distro - defaults to C<cpan:NIGELM>

=head3 no_cpan

If C<no_cpan> or the environment variable C<NO_CPAN> is set, then
the upload to CPAN is suppressed.

=head3 tag_format / tag_message / version_regexp / git_autoversion

Overrides the Git bundle defaults for these. By default I use an
unusual tag format of C<release/%v> for historical reasons. If
git_autoversion is true (the default) then versioning is taken from
git.

=cut

has authority => (
    is      => 'ro',
    isa     => Str,
    default => 'cpan:NIGELM',
);

has github_user => (
    is      => 'ro',
    isa     => Str,
    default => 'nigelm',
);

has tag_format => (
    is      => 'ro',
    isa     => Str,
    default => 'release/%v',
);

has tag_message => (
    is      => 'ro',
    isa     => Str,
    default => 'Release of %v',
);

has version_regexp => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    builder => '_build_version_regexp',
);

method _build_version_regexp {
    my $version_regexp = $self->tag_format;
    $version_regexp =~ s/\%v/\(\.\+\)/;
    return sprintf( '^%s$', $version_regexp );
}

has git_autoversion => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1,
);

# if set, trigger FakeRelease instead of UploadToCPAN
has no_cpan => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { $ENV{NO_CPAN} || $_[0]->payload->{no_cpan} || 0 }
);

method configure {
    my %basic_opts = (
        '-bundle' => '@Basic',
        '-remove' => ['Readme'],
    );

    if ( $self->no_cpan ) {
        $basic_opts{'-remove'} = [ 'Readme', 'UploadToCPAN' ];
        $self->add_plugins('FakeRelease');
    }

    $self->add_bundle( '@Filter' => \%basic_opts );

    $self->add_plugins(
        qw(
          MetaConfig
          MetaJSON
          PkgVersion
          PodSyntaxTests
          NoTabsTests
          ReadmeFromPod
          NextRelease
          )
    );

    $self->add_plugins('PodCoverageTests')
      unless $self->disable_pod_coverage_tests;

    $self->add_plugins(
        [
            MetaResources => {
                'repository.type'   => $self->repository_type,
                'repository.url'    => $self->repository_url,
                'repository.web'    => $self->repository_web,
                'bugtracker.web'    => $self->bugtracker_url,
                'bugtracker.mailto' => $self->bugtracker_email,
                'homepage'          => $self->homepage_url,
            }
        ],
        [
            Authority => {
                authority   => $self->authority,
                do_metadata => 1,
            }
        ],
        [ EOLTests => { trailing_whitespace => !$self->disable_trailing_whitespace_tests, } ],
    );

    $self->add_bundle(
        '@Git' => {
            tag_format  => $self->tag_format,
            tag_message => $self->tag_message,
        }
    );

    $self->add_plugins(
        [
            'Git::NextVersion' => {
                first_version  => '0.01',
                version_regexp => $self->version_regexp,
            }
        ]
    ) if ( $self->git_autoversion );

    $self->is_task
      ? $self->add_plugins('TaskWeaver')
      : $self->add_plugins( [ PodWeaver => { config_plugin => $self->weaver_config_plugin, } ], );

    $self->add_plugins('AutoPrereqs') if $self->auto_prereq;
}

__PACKAGE__->meta->make_immutable;

1;
