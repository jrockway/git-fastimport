package Git::FastImport;
use Moose;
use MooseX::Types::Path::Class qw(File Dir);
use IPC::Cmd;

has 'git' => (
    is       => 'ro',
    isa      => File,
    coerce   => 1,
    required => 1,
    default  => sub {
        IPC::Cmd::can_run('git');
    },
);

has 'repository' => (
    is       => 'ro',
    isa      => Dir,
    required => 1,
    coerce   => 1,
);

has 'fast_import' => (
    is      => 'ro',
    isa     => 'GlobRef',
    lazy    => 1,
    default => sub {
        my ($self) = @_;

        # TODO, open bidirectional pipe so we can return status. I
        # think this will require a real event loop, which I don't
        # feel like dealing with today.

        local $ENV{GIT_DIR} = $self->repository->stringify;
        open my $git_fh, '|-',
          $self->git,
            '--git-dir', $self->repository->subdir('.git')->stringify,
            '--work-tree', $self->repository->stringify,
            qw/fast-import --date-format=raw/,
            or confess "failed to open git process: $!";

        return $git_fh;
    },
);

sub create_repository {
    my ($self) = @_;
    $self->repository->mkpath();
    return system($self->git, '--git-dir', $self->repository->subdir('.git'), 'init');
}

sub run_command {
    my ($self, $command) = @_;
    my $git = $self->fast_import;

    confess "$command must implement Git::FastImport::Command"
      unless $command->does('Git::FastImport::Command');

    my $cmd = $command->format($self);
    print $cmd;
    print {$git} $cmd;
    return 1;
}

1;

__END__

=head1 NAME

Git::FastImport - communicate with an inferior C<git fast-import> process

=head1 SYNOPSIS

   my $git = Git::FastImport->new( repository => '/path/to/a/repository' );

=head1 AUTHOR

Jonathan Rockway C<< <jrockway@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008 Jonathan Rockway

This module is free software.  You may redistribute it under the same
terms as perl itself.
