package Git::FastImport::Command::Commit;
use Moose;
use Git::FastImport::Action;

with 'Git::FastImport::Command';

has 'head' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { 'refs/heads/master' },
);

has 'author' => (
    is       => 'ro',
    isa      => 'Git::FastImport::Action',
    required => 1,
    coerce   => 1,
    default  => sub { +{} },
);

has 'committer' => (
    is       => 'ro',
    isa      => 'Git::FastImport::Action',
    required => 1,
    coerce   => 1,
    default  => sub { +{
        name  => 'Git::FastImport',
        # this is probably a great way to get useless bug reports
        email => 'bug-git-fastimport@rt.cpan.org',
    } },
);

has 'message' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'clear_tree' => (
    is      => 'ro',
    isa     => 'Bool',
    default => sub { undef },
);

sub format {
    my $self = shift;
    my $buf = 'commit '. $self->head. "\n";
    $buf .= 'author '. $self->author->format. "\n";
    $buf .= 'committer '. $self->committer->format. "\n";
    $buf .= _fmt_msg($self->message);
    if($self->clear_tree){
        $buf .= "deleteall\n";
    }

    return $buf;
}

1;
