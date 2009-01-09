package Git::FastImport::Command::Tag;
use Moose;
use Git::FastImport::Action;

with 'Git::FastImport::Command';

has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'message' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { shift->name },
);

has 'from' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'tagger' => (
    is       => 'ro',
    isa      => 'Git::FastImport::Action',
    required => 1,
    coerce   => 1,
    default  => sub { +{} },
);

sub format {
    my ($self) = @_;

    my $buf = "tag ". $self->name. "\n";
    $buf .= "from ". $self->from. "\n";
    $buf .= "tagger ". $self->tagger->format. "\n";
    $buf .= Git::FastImport::Util::format_mesage($self->message);
    return $buf;
}

1;
