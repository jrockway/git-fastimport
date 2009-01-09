package Git::FastImport::Command::AddFile;
use Moose;
use Moose::Util::TypeConstraints;
use File::Slurp;

with 'Git::FastImport::Command';

subtype Permissions
  => as Str
  => where {
      /^1[0-7]{5}$/;
  };

# this doesn't work, it coerces strings also :P
#coerce Permissions
#  => from Int
#  => via { sprintf('%o', $_) };

has 'filename' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

# maybe split this into a ton of bools
# is_link
# can_user_read, can_user_write, can_user_execute, ...
has 'permissions' => (
    is       => 'ro',
    isa      => 'Permissions',
    required => 1,
    default  => sub { '100644' },
);

has 'content' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'debug_comment' => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_debug_comment',
    required  => 0,
);

sub new_from_disk_file {
    my ($class, $path, $name) = @_;

    confess "$path does not exist" unless -e $path;
    confess "git cannot track directories" if -d $path;

    my $content = read_file(qq{$path});
    my $permissions =
      -l $path ? '120000' :
      -x $path ? '100755' :
                 '100644' ;

    return $class->new(
        filename    => $name,
        permissions => $permissions,
        content     => $content,
    );
}

sub content_length { length shift->content }

sub format {
    my ($self) = @_;
    my $buf;
    $buf .= "# ". $self->debug_comment. "\n" if $self->has_debug_comment;
    $buf .= "M ". $self->permissions. " inline ". $self->filename. "\n";
    $buf .= "data ". $self->content_length. "\n";
    $buf .= $self->content. "\n";
    return $buf;
}

1;
