# NAME

Dist::Zilla::PluginBundle::NIGELM - Build your distributions like I do

# VERSION

version 0.28

# SYNOPSIS

In your `dist.ini`:

    [@NIGELM]
    dist = Distribution-Name
    repository_at = github

# DESCRIPTION

This is the [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) configuration I use to build my distributions. It
was originally based on the @FLORA bundle but additionally pulls in ideas from
@MARCEL bundle.

It is roughly equivalent to:

    [Git::NextVersion]
        first_version  = 0.01,
        version_regexp = release/(\d+.\d+)
    [Git::Check]
    [Git::CheckFor::CorrectBranch]
        release_branch = master
    # [Git::CheckFor::Fixups]
    [Git::CheckFor::MergeConflicts]
    [GatherDir]
    [Test::Compile]
    [Test::Perl::Critic]
    [MetaTests]
    [PodCoverageTests]
    [PodSyntaxTests]
    [Test::PodSpelling]
    [Test::Kwalitee]
    [Test::Portability]
    [Test::Synopsis]
    [Test::MinimumVersion]
    [HasVersionTests]
    [Test::DistManifest]
    [Test::UnusedVars]
    [Test::NoTabs]
    [Test::EOL]
    [Test::ReportPrereqs]
    [InlineFiles]
    [PruneCruft]
    [PruneFiles]
        filenames = dist.ini
    [ManifestSkip]
    [AutoPrereqs]
    [MetaConfig]
    [MetaProvides::Class]
    [MetaProvides::Package]
    [MetaResources]
    [Authority]
        authority   = cpan:NIGELM
        do_metadata = 1
        locate_comment = 1
    [ExtraTests]
    [NextRelease]
    [OurPkgVersion]
    [PodWeaver]
        config_plugin = @DAGOLDEN
    [License]
    [MakeMaker]
    [MetaYAML]
    [MetaJSON]
    [ReadmeAnyFromPod]
        type = markdown
        filename = README.md
        location = root
    [InstallGuide]
    [Manifest]
    [Git::Commit]
        allow_dirty                 = dist.ini
        allow_dirty                 = Changes
        allow_dirty                 = README.md
    [Git::Tag]
    [Git::CommitBuild]
        branch =
        release_branch = cpan
    [Git::Push]
    [CheckChangeLog]
    [UploadToCPAN] or [FakeRelease]
    [GitHubREADME::Badge]
        badges                      = travis
    ;   badges                      = coveralls
    ;   badges                      = gitter
        badges                      = cpants
        badges                      = issues
        badges                      = github_tag
        badges                      = license
        badges                      = version
    ;   badges                      = codecov
    ;   badges                      = gitlab_ci
    ;   badges                      = gitlab_cover

## Required Parameters

### dist

The distribution name, as given in the main Dist::Zilla configuration section
(the `name` parameter). Unfortunately this cannot be extracted from the main
config.

## Tweakables - Major Configuration

### build\_process

Overrides build process system - basically this causes the standard Module
Build generation to be suppressed and replaced by a call to a module in the
local inc directory specified by this parameter instead.

### no\_cpan

If `no_cpan` or the environment variable `NO_CPAN` is set, then the upload to
CPAN is suppressed. This basically swaps [Dist::Zilla::Plugin::FakeRelease](https://metacpan.org/pod/Dist::Zilla::Plugin::FakeRelease) in
place of [Dist::Zilla::Plugin::UploadToCPAN](https://metacpan.org/pod/Dist::Zilla::Plugin::UploadToCPAN)

## Tweakables

### authority

The authority for this distribution - defaults to `cpan:NIGELM`

### auto\_prereqs

Determine Prerequisites automatically - defaults to1 (set).

### skip\_prereqs

Prerequisites to skip if `auto_prereqs` is set -- a string of module names.

### is\_task

Is this a Task rather than a Module. Determines whether
[Dist::Zilla::Plugin::TaskWeaver](https://metacpan.org/pod/Dist::Zilla::Plugin::TaskWeaver) or [Dist::Zilla::Plugin::PodWeaver](https://metacpan.org/pod/Dist::Zilla::Plugin::PodWeaver) are
used. Defaults to 1 if the dist name starts with `Task`, 0 otherwise.

### weaver\_config\_plugin

This option is passed to the `config_plugin` option of
[Dist::Zilla::Plugin::PodWeaver](https://metacpan.org/pod/Dist::Zilla::Plugin::PodWeaver). It defaults to `@DAGOLDEN`, which loads in
[Pod::Weaver::PluginBundle::DAGOLDEN](https://metacpan.org/pod/Pod::Weaver::PluginBundle::DAGOLDEN).

## Bug Tracker Information

### bugtracker\_url

The URL of the bug tracker. Defaults to the CPAN RT queue for the distribution
name.

### bugtracker\_email

The email address of the bug tracker. Defaults to the CPAN RT email for the
distribution name.

## Tweaks - Modifying Tests Generated

### disable\_pod\_coverage\_tests

If set, disables the Pod Coverage Release Tests
[Dist::Zilla::Plugin::PodCoverageTests](https://metacpan.org/pod/Dist::Zilla::Plugin::PodCoverageTests). Defaults to unset (tests enabled).

### disable\_pod\_spelling\_tests

If set, disables the Pod Spelling Release Tests
[Dist::Zilla::Plugin::Test::PodSpelling](https://metacpan.org/pod/Dist::Zilla::Plugin::Test::PodSpelling). Defaults to unset (tests enabled).

### disable\_trailing\_whitespace\_tests

If set, disables the Trailing Whitespace Release Tests
[Dist::Zilla::Plugin::Test::EOL](https://metacpan.org/pod/Dist::Zilla::Plugin::Test::EOL). Defaults to unset (tests enabled).

### disable\_unused\_vars\_tests

If set, disables the Unused Variables Release Tests
[Dist::Zilla::Plugin::Test::UnusedVars](https://metacpan.org/pod/Dist::Zilla::Plugin::Test::UnusedVars). Defaults to unset (tests enabled).

### disable\_no\_tabs\_tests

If set, disables the Release Test that checks for hard tabs
[Dist::Zilla::Plugin::Test::NoTabs](https://metacpan.org/pod/Dist::Zilla::Plugin::Test::NoTabs). Defaults to unset (tests enabled).

### fake\_home

If set, this sets the `fake_home` option to.
[Dist::Zilla::Plugin::Test::Compile](https://metacpan.org/pod/Dist::Zilla::Plugin::Test::Compile). Defaults to unset.

## Repository, Source Control and Similar

### homepage\_url

The module homepage URL. Defaults to the URL of the module page on
`metacpan.org`. In previous versions this defaulted to the page on
`search.cpan.org`.

### repository\_at

Sets all of the following repository options based on a standard repository
type. This is one of:-

- **github** - a github repository, with a lower cased module name.
- **GitHub** - a github repository, with an unmodified module name.
- **gitmo** - a git repository on `git.moose.perl.org`
- **catsvn** - a svn repository on `dev.catalyst.perl.org`
- **catagits** - a git repository on `git.shadowcat.co.uk` in the Catalyst section
- **p5sagit** - a git repository on `git.shadowcat.co.uk` in the P5s section
- **dbsrgits** - a git repository on `git.shadowcat.co.uk` in the DBIx::Class section

### repository

The repository URL.  Normally set from [repository\_at](https://metacpan.org/pod/repository_at).

### repository\_web

The repository web view URL.  Normally set from [repository\_at](https://metacpan.org/pod/repository_at).

### repository\_type

The repository type - either `svn` or `git`.  Normally set from
[repository\_at](https://metacpan.org/pod/repository_at).

### github\_user

The username on github. Defaults to `nigelm` which is unlikely to be useful
for anyone else. Sorry!

### tag\_format / tag\_message / version\_regexp / git\_autoversion

Overrides the [Dist::Zilla::Plugin::Git](https://metacpan.org/pod/Dist::Zilla::Plugin::Git) bundle defaults for these. By default
I use an unusual tag format of `release/%v` for historical reasons. If
git\_autoversion is true (the default) then the version number is taken from
git.

### git\_allow\_dirty

A list of files that are allowed to be dirty by the Git plugins. Defaults to
`dist.ini`, the Change log file, `README` and `README.md`.

### git\_release\_branch

The correct git release branch for this distribution.  Defaults to master.  If
a release is attempted from another branch the release will fail.

### changelog

The Change Log file name.  Defaults to `Changes`.

### prune\_directories

Directories to ignore - currently defaults to `local` and `vendor` (the
directories used by carton to store required modules).

# BUGS

It appears this module, in particular the `ReadmeAnyFromPod` plugin, exposes a
bug with text wrapping in [Pod::Simple::Text](https://metacpan.org/pod/Pod::Simple::Text) which can cause modules with
long words (especially long names) to die during packaging.

1;

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at [http://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-PluginBundle-NIGELM](http://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-PluginBundle-NIGELM).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software.  The code repository is available for
public review and contribution under the terms of the license.

[https://github.com/nigelm/dist-zilla-pluginbundle-nigelm](https://github.com/nigelm/dist-zilla-pluginbundle-nigelm)

    git clone https://github.com/nigelm/dist-zilla-pluginbundle-nigelm.git

# AUTHOR

Nigel Metheringham <nigelm@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Nigel Metheringham.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
