package Git::FastImport::Action;
use Moose;
use DateTime;
use DateTime::Format::Epoch;
use Moose::Util::TypeConstraints;

class_type 'Git::FastImport::Action';

coerce 'Git::FastImport::Action'
  => from 'HashRef'
  => via {
      Git::FastImport::Action->new($_),
  };

has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { 'Unknown Name' },
);

has 'email' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { 'invalid@invalid.invalid' },
);

has 'date' => (
    is       => 'ro',
    isa      => 'DateTime',
    required => 1,
    lazy     => 1,
    default  => sub { DateTime->now },
);

sub _quote_name { my $_ = shift; s/(["])/\\$1/g; $_ }

sub _quote_mail { my $_ = shift; s/[<>]//g; $_ }

sub _fmt_date {
    my $_ = shift;
    my $formatter = DateTime::Format::Epoch->new(
        # congratulations on the worst API ever.
        epoch => DateTime->from_epoch( epoch => 0 ),
    );
    return $formatter->format_datetime($_). " +0000";
}

sub format {
    my $self = shift;
    my ($name, $email, $date) = map { $self->$_ } qw/name email date/;

    return sprintf(
        "%s <%s> %s",
        _quote_name($name),
        _quote_mail($email),
        _fmt_date($date),
    );
}

1;
