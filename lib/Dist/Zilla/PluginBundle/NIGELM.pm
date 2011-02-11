package Dist::Zilla::PluginBundle::NIGELM;
BEGIN {
  $Dist::Zilla::PluginBundle::NIGELM::VERSION = '0.07';
}
BEGIN {
  $Dist::Zilla::PluginBundle::NIGELM::AUTHORITY = 'cpan:NIGELM';
}

# ABSTRACT: Build your distributions like I do

use Moose 1.00;
use Method::Signatures::Simple;
use Moose::Util::TypeConstraints;
use MooseX::Types::URI qw(Uri);
use MooseX::Types::Email qw(EmailAddress);
use MooseX::Types::Moose qw(Bool Str CodeRef);
use MooseX::Types::Structured 0.20 qw(Map Dict Optional);
use MooseX::Types::Moose qw{ ArrayRef Str };
use namespace::autoclean -also => 'lower';

# these are all the modules used, listed purely for the dep generator
use Dist::Zilla::Plugin::Authority;
use Dist::Zilla::Plugin::AutoPrereqs;
use Dist::Zilla::Plugin::CheckChangeLog;
use Dist::Zilla::Plugin::CompileTests;
use Dist::Zilla::Plugin::CopyReadmeFromBuild;
use Dist::Zilla::Plugin::CriticTests;
use Dist::Zilla::Plugin::DistManifestTests;
use Dist::Zilla::Plugin::EOLTests;
use Dist::Zilla::Plugin::ExecDir;
use Dist::Zilla::Plugin::ExtraTests;
use Dist::Zilla::Plugin::FakeRelease;
use Dist::Zilla::Plugin::GatherDir;
use Dist::Zilla::Plugin::Git::Check;
use Dist::Zilla::Plugin::Git::Commit;
use Dist::Zilla::Plugin::Git::CommitBuild;
use Dist::Zilla::Plugin::Git::NextVersion;
use Dist::Zilla::Plugin::Git::Push;
use Dist::Zilla::Plugin::Git::Tag;
use Dist::Zilla::Plugin::HasVersionTests;
use Dist::Zilla::Plugin::InlineFiles;
use Dist::Zilla::Plugin::InstallGuide;
use Dist::Zilla::Plugin::KwaliteeTests;
use Dist::Zilla::Plugin::License;
use Dist::Zilla::Plugin::MakeMaker;
use Dist::Zilla::Plugin::Manifest;
use Dist::Zilla::Plugin::ManifestSkip;
use Dist::Zilla::Plugin::MetaConfig;
use Dist::Zilla::Plugin::MetaJSON;
use Dist::Zilla::Plugin::MetaResources;
use Dist::Zilla::Plugin::MetaTests;
use Dist::Zilla::Plugin::MetaYAML;
use Dist::Zilla::Plugin::MinimumVersionTests;
use Dist::Zilla::Plugin::NextRelease;
use Dist::Zilla::Plugin::NoTabsTests;
use Dist::Zilla::Plugin::PkgVersion;
use Dist::Zilla::Plugin::PodCoverageTests;
use Dist::Zilla::Plugin::PodSpellingTests;
use Dist::Zilla::Plugin::PodSyntaxTests;
use Dist::Zilla::Plugin::PodWeaver;
use Dist::Zilla::Plugin::PortabilityTests;
use Dist::Zilla::Plugin::PruneCruft;
use Dist::Zilla::Plugin::PruneFiles;
use Dist::Zilla::Plugin::ReadmeFromPod;
use Dist::Zilla::Plugin::ReportVersions;
use Dist::Zilla::Plugin::ShareDir;
use Dist::Zilla::Plugin::SynopsisTests;
use Dist::Zilla::Plugin::TaskWeaver;
use Dist::Zilla::Plugin::UnusedVarsTests;
use Dist::Zilla::Plugin::UploadToCPAN;
use Pod::Weaver::PluginBundle::MARCEL;


has dist => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has fake_home => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has authority => (
    is      => 'ro',
    isa     => Str,
    default => 'cpan:NIGELM',
);

has auto_prereqs => (
    is      => 'ro',
    isa     => Bool,
    default => 1,
);

has skip_prereqs => (
    is  => 'ro',
    isa => Str,
);

has is_task => (
    is      => 'ro',
    isa     => Bool,
    lazy    => 1,
    builder => '_build_is_task',
);

method _build_is_task () {
    return $self->dist =~ /^Task-/ ? 1 : 0;
}

has weaver_config_plugin => (
    is      => 'ro',
    isa     => Str,
    default => '@MARCEL',
);

has disable_pod_coverage_tests => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has disable_trailing_whitespace_tests => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has disable_no_tabs_tests => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has bugtracker_url => (
    isa     => Uri,
    coerce  => 1,
    lazy    => 1,
    builder => '_build_bugtracker_url',
    handles => { bugtracker_url => 'as_string', },
);

method _build_bugtracker_url () {
    return sprintf $self->_rt_uri_pattern, $self->dist;
}

has bugtracker_email => (
    is      => 'ro',
    isa     => EmailAddress,
    lazy    => 1,
    builder => '_build_bugtracker_email',
);

method _build_bugtracker_email () {
    return sprintf 'bug-%s@rt.cpan.org', $self->dist;
}

has _rt_uri_pattern => (
    is      => 'ro',
    isa     => Str,
    default => 'http://rt.cpan.org/Public/Dist/Display.html?Name=%s',
);

has homepage_url => (
    isa     => Uri,
    coerce  => 1,
    lazy    => 1,
    builder => '_build_homepage_url',
    handles => { homepage_url => 'as_string', },
);

method _build_homepage_url () {
    return sprintf $self->_cpansearch_pattern, $self->dist;
}

has _cpansearch_pattern => (
    is      => 'ro',
    isa     => Str,
    default => 'http://search.cpan.org/dist/%s',
);

has repository => (
    isa     => Uri,
    coerce  => 1,
    lazy    => 1,
    builder => '_build_repository_url',
    handles => {
        repository_url    => 'as_string',
        repository_scheme => 'scheme',
    },
);

has repository_at => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_repository_at',
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

method _build_version_regexp () {
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

# git allow dirty references
has git_allow_dirty => (
    is      => 'ro',
    lazy    => 1,
    isa     => ArrayRef [Str],
    builder => '_build_git_allow_dirty',
);

has changelog => ( is => 'ro', isa => Str, default => 'Changes' );

sub mvp_multivalue_args { return ('git_allow_dirty'); }

sub _build_git_allow_dirty { [ 'dist.ini', shift->changelog, 'README' ] }

my $map_tc = Map [
    Str,
    Dict [
        pattern     => CodeRef,
        web_pattern => CodeRef,
        type        => Optional [Str],
        mangle      => Optional [CodeRef],
    ]
];

coerce $map_tc, from Map [
    Str,
    Dict [
        pattern     => Str | CodeRef,
        web_pattern => Str | CodeRef,
        type        => Optional [Str],
        mangle      => Optional [CodeRef],
    ]
  ],
  via {
    my %in = %{$_};
    return {
        map {
            my $k = $_;
            (
                $k => {
                    %{ $in{$k} },
                    (
                        map {
                            my $v = $_;
                            (
                                ref $in{$k}->{$v} ne 'CODE'
                                ? ( $v => sub { $in{$k}->{$v} } )
                                : ()
                              ),
                          } qw(pattern web_pattern)
                    ),
                }
              )
          } keys %in
    };
  };

has _repository_host_map => (
    traits  => [qw(Hash)],
    isa     => $map_tc,
    coerce  => 1,
    lazy    => 1,
    builder => '_build__repository_host_map',
    handles => { _repository_data_for => 'get', },
);

sub lower { lc shift }

method _build__repository_host_map () {
    my $github_pattern     = sub { sprintf 'git://github.com/%s/%%s.git', $self->github_user };
    my $github_web_pattern = sub { sprintf 'http://github.com/%s/%%s',    $self->github_user };
    my $scsys_web_pattern_proto = sub {
        return sprintf 'http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=%s/%%s.git;a=summary', $_[0];
    };

    return {
        github => {
            pattern     => $github_pattern,
            web_pattern => $github_web_pattern,
            mangle      => \&lower,
        },
        GitHub => {
            pattern     => $github_pattern,
            web_pattern => $github_web_pattern,
        },
        gitmo => {
            pattern     => 'git://git.moose.perl.org/%s.git',
            web_pattern => $scsys_web_pattern_proto->('gitmo'),
        },
        catsvn => {
            type        => 'svn',
            pattern     => 'http://dev.catalyst.perl.org/repos/Catalyst/%s/',
            web_pattern => 'http://dev.catalystframework.org/svnweb/Catalyst/browse/%s',
        },
        (
            map { ( $_ => { pattern => "git://git.shadowcat.co.uk/${_}/%s.git", web_pattern => $scsys_web_pattern_proto->($_), } ) }
              qw(catagits p5sagit dbsrgits)
        ),
    };
}

method _build_repository_url () {
    return $self->_resolve_repository_with( $self->repository_at, 'pattern' )
      if $self->has_repository_at;
    confess "Cannot determine repository url without repository_at. " . "Please provide either repository_at or repository.";
}

has repository_web => (
    isa     => Uri,
    coerce  => 1,
    lazy    => 1,
    builder => '_build_repository_web',
    handles => { repository_web => 'as_string', },
);

method _build_repository_web () {
    return $self->_resolve_repository_with( $self->repository_at, 'web_pattern' )
      if $self->has_repository_at;
    confess "Cannot determine repository web url without repository_at. "
      . "Please provide either repository_at or repository_web.";
}

method _resolve_repository_with ( $service, $thing ) {
    my $dist = $self->dist;
    my $data = $self->_repository_data_for($service);
    confess "unknown repository service $service" unless $data;
    return sprintf $data->{$thing}->(),
      (
        exists $data->{mangle}
        ? $data->{mangle}->($dist)
        : $dist
      );
}

has repository_type => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    builder => '_build_repository_type',
);

method _build_repository_type () {
    my $data = $self->_repository_data_for( $self->repository_at );
    return $data->{type} if exists $data->{type};

    for my $vcs (qw(git svn)) {
        return $vcs if $self->repository_scheme eq $vcs;
    }

    confess "Unable to guess repository type based on the repository url. " . "Please provide repository_type.";
}

override BUILDARGS => sub {
    my $class = shift;

    my $args = $class->SUPER::BUILDARGS(@_);
    return { %{ $args->{payload} }, %{$args} };
};

method configure () {

    # Build a list of all the plugins we want...
    my @wanted = (

        # -- Git versioning
        (
            $self->git_autoversion
            ? [
                'Git::NextVersion' => {
                    first_version  => '0.01',
                    version_regexp => $self->version_regexp,
                }
              ]
            : ()
        ),
        [ 'Git::Check' => { allow_dirty => $self->git_allow_dirty } ],

        # -- fetch & generate files
        [ GatherDir    => {} ],
        [ CompileTests => { fake_home => $self->fake_home } ],
        [ CriticTests  => {} ],
        [ MetaTests    => {} ],
        ( $self->disable_pod_coverage_tests ? () : [ PodCoverageTests => {} ] ),
        [ PodSyntaxTests   => {} ],
        [ PodSpellingTests => {} ],
        (    # Disabling pod coverage scores you a fail on Kwalitee too!
            $self->disable_pod_coverage_tests ? () : [ KwaliteeTests => {} ]
        ),
        [ PortabilityTests    => {} ],
        [ SynopsisTests       => {} ],
        [ MinimumVersionTests => {} ],
        [ HasVersionTests     => {} ],
        [ DistManifestTests   => {} ],
        [ UnusedVarsTests     => {} ],
        (
            $self->disable_no_tabs_tests
            ? [ NoTabsTests => {} ]
            : ()
        ),
        [ EOLTests       => { trailing_whitespace => !$self->disable_trailing_whitespace_tests, } ],
        [ InlineFiles    => {} ],
        [ ReportVersions => {} ],

        # -- remove some files
        [ PruneCruft   => {} ],
        [ PruneFiles   => { filenames => [qw(dist.ini)] } ],
        [ ManifestSkip => {} ],

        # -- get prereqs
        (
            $self->auto_prereqs
            ? [ AutoPrereqs => $self->skip_prereqs ? { skip => $self->skip_prereqs } : {} ]
            : ()
        ),

        # -- gather metadata
        [ MetaConfig => {} ],
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

        # -- munge files
        [ ExtraTests  => {} ],
        [ NextRelease => {} ],
        [ PkgVersion  => {} ],

        (
            $self->is_task
            ? [ 'TaskWeaver' => {} ]
            : [ 'PodWeaver' => { config_plugin => $self->weaver_config_plugin } ]
        ),
        ## -- not sure about these - leaving out for now.
        ## # -- dynamic meta-information
        ## [ ExecDir                 => {} ],
        ## [ ShareDir                => {} ],
        ## [ 'MetaProvides::Package' => {} ],

        # -- generate meta files
        [ License       => {} ],
        [ MakeMaker     => {} ],
        [ MetaYAML      => {} ],
        [ MetaJSON      => {} ],
        [ ReadmeFromPod => {} ],
        [ InstallGuide  => {} ],
        [ Manifest      => {} ],    # should come last

        # -- Git release process
        ## [ CopyReadmeFromBuild => {} ], # -- unable to get this to work right
        [ 'Git::Commit' => { allow_dirty => $self->git_allow_dirty } ],
        [
            'Git::Tag' => {
                tag_format  => $self->tag_format,
                tag_message => $self->tag_message,
            }
        ],
        [ 'Git::CommitBuild' => { release_branch => 'cpan' } ],
        [ 'Git::Push'        => {} ],

        # -- release
        [ CheckChangeLog => {} ],
        (
            $self->no_cpan
            ? [ FakeRelease => {} ]
            : [ UploadToCPAN => {} ]
        ),
    );

    $self->add_plugins(@wanted);
}

with 'Dist::Zilla::Role::PluginBundle::Easy';

__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=for test_synopsis 1;
__END__

=for stopwords NIGELM Tweakables

=for Pod::Coverage mvp_multivalue_args

=head1 NAME

Dist::Zilla::PluginBundle::NIGELM - Build your distributions like I do

=head1 VERSION

version 0.07

=head1 SYNOPSIS

In your F<dist.ini>:

  [@NIGELM]
  dist = Distribution-Name
  repository_at = github

=head1 DESCRIPTION

This is the L<Dist::Zilla> configuration I use to build my
distributions. It was originally based on the @FLORA bundle but
additionally pulls in ideas from @MARCEL bundle.

It is roughly equivalent to:

    [Git::NextVersion]
        first_version  = 0.01,
        version_regexp = release/(\d+.\d+)
    [Git::Check]
    [GatherDir]
    [CompileTests]
    [CriticTests]
    [MetaTests]
    [PodCoverageTests]
    [PodSyntaxTests]
    [PodSpellingTests]
    [KwaliteeTests]
    [PortabilityTests]
    [SynopsisTests]
    [MinimumVersionTests]
    [HasVersionTests]
    [DistManifestTests]
    [UnusedVarsTests]
    [NoTabsTests]
    [EOLTests]
    [InlineFiles]
    [ReportVersions]
    [PruneCruft]
    [PruneFiles]
        filenames = dist.ini
    [ManifestSkip]
    [AutoPrereqs]
    [MetaConfig]
    [MetaResources]
    [Authority]
        authority   => cpan:NIGELM
        do_metadata => 1,
    [ExtraTests]
    [NextRelease]
    [PkgVersion]
    [PodWeaver]
        config_plugin = @MARCEL
    [License]
    [MakeMaker]
    [MetaYAML]
    [MetaJSON]
    [ReadmeFromPod]
    [InstallGuide]
    [Manifest]
    [Git::Commit]
    [Git::Tag]
    [Git::Push]
    [CheckChangeLog]
    [UploadToCPAN] or [FakeRelease]

=head2 Tweakables

=head3 authority

The authority for this distribution - defaults to C<cpan:NIGELM>

=head3 no_cpan

If C<no_cpan> or the environment variable C<NO_CPAN> is set, then
the upload to CPAN is suppressed.

=head3 tag_format / tag_message / version_regexp / git_autoversion

Overrides the Git bundle defaults for these. By default I use an
unusual tag format of C<release/%v> for historical reasons. If
git_autoversion is true (the default) then the version number is
taken from git.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-PluginBundle-NIGELM>.

=head1 AVAILABILITY

The project homepage is L<http://search.cpan.org/dist/Dist-Zilla-PluginBundle-NIGELM>.

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<http://search.cpan.org/dist/Dist-Zilla-PluginBundle-NIGELM/>.

The development version lives at L<http://github.com/nigelm/Dist-Zilla-PluginBundle-NIGELM>
and may be cloned from L<git://github.com/nigelm/Dist-Zilla-PluginBundle-NIGELM.git>.
Instead of sending patches, please fork this project using the standard
git and github infrastructure.

=head1 AUTHOR

Nigel Metheringham <nigelm@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Nigel Metheringham.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

