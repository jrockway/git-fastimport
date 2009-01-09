package Git::FastImport::Util;
use strict;
use warnings;

# this is unlikely to occur in normal commits, but we'll escape it anyway
my $END = 'END_OF_MESSAGE';
sub format_message {
    my $msg = shift;
    $msg =~ s/^($END)$/ $1/mg;
    return "data <<$END\n$msg\n$END\n\n";
}

1;
