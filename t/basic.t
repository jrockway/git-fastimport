use strict;
use warnings;
use Test::More tests => 5;
use IPC::Cmd;

use Git::FastImport;
use Git::FastImport::Command::Commit;
use Git::FastImport::Command::AddFile;
use Directory::Scratch;
use Test::Exception;

my $tmp = Directory::Scratch->new;

my $fi = Git::FastImport->new(
    repository => qq{$tmp},
);
isa_ok $fi, 'Git::FastImport';

$fi->create_repository;
ok $tmp->exists('.git'), 'created git repo';
ok $fi->fast_import, 'have a fast-import process';

lives_ok {
    $fi->run_command(Git::FastImport::Command::Commit->new(
        message    => 'OH HAI',
        clear_tree => 1,
    ));

    $fi->run_command(Git::FastImport::Command::AddFile->new(
        filename => 'foo/bar.txt',
        content  => "Hello, world!\n",
    ));
};

close $fi->fast_import;
