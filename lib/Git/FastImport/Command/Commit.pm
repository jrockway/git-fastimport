package Git::FastImport::Command::Commit;
use Moose;
use DateTime;
use DateTime::Format::Epoch;
with 'Git::FastImport::Command';

has 'head' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { 'refs/heads/master' },
);

has 'author_name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { 'Unknown Author' },
);

has 'author_email' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { 'unknown@example.com' },
);

has 'committer_name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { 'Git::FastImport' },
);

has 'committer_email' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { 'bug-git-fastimport@rt.cpan.org' },
);

has 'date' => (
    is       => 'ro',
    isa      => 'DateTime',
    required => 1,
    default  => sub { DateTime->now },
);

has 'commit_date' => (
    is      => 'ro',
    isa     => 'DateTime',
    lazy    => 1,
    default => sub { DateTime->now },
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

sub _quote { my $_ = shift; s/"/\\"/g; $_ }

sub _quote_mail { my $_ = shift; s/[<>]//g; $_ }

# this is unlikely to occur in normal commits, but we'll escape it anyway
sub _quote_msg { my $_ = shift; s/^(END_OF_COMMIT_MESSAGE)$/ $1/mg; $_ }

sub _fmt_date {
    my $_ = shift;
    my $formatter = DateTime::Format::Epoch->new(
        # congratulations on the worst API ever.
        epoch => DateTime->from_epoch( epoch => 0 ),
    );
    return $formatter->format_datetime($_). " +0000";
}

sub _author {
    my ($type, $name, $email, $date) = @_;

    return qq{$type "}. _quote($name).
      '" <'. _quote_mail($email). '> '.
        _fmt_date($date). "\n";
}

sub format {
    my $self = shift;
    my $buf = 'commit '. $self->head. "\n";
    $buf .= _author('author', $self->author_name, $self->author_email, $self->date);
    $buf .= _author('committer', $self->committer_name, $self->committer_email,
                    $self->commit_date);

    $buf .= "data <<END_OF_COMMIT_MESSAGE\n";
    $buf .= $self->message;
    $buf .= "\nEND_OF_COMMIT_MESSAGE\n\n";

    if($self->clear_tree){
        $buf .= "deleteall\n";
    }

    return $buf;
}

1;
