use strict;
use warnings;
use Test::More tests => 4;

use Git::FastImport;
use Git::FastImport::Command::Commit;
use Git::FastImport::Command::AddFile;
use Git::FastImport::Command::Tag;

use Directory::Scratch;
use Test::Exception;

my $tmp = Directory::Scratch->new;
$tmp->mkdir('repo');

my $fi = Git::FastImport->new(
    repository => $tmp->exists('repo'),
);
isa_ok $fi, 'Git::FastImport';

$fi->create_repository;
ok $tmp->exists('repo/.git'), 'created git repo';
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

    $tmp->touch('baz', 'this is the baz file');

    $fi->run_command(Git::FastImport::Command::AddFile->new_from_disk_file(
        $tmp->exists('baz') => 'baz.txt',
    ));

    $f->run_command(Git::FastImport::Command::Tag->new(
        message => 'tagging the test repository',
        name    => 'test iteration 1',
        from    => 'refs/head/master',
        tagger  => {
            name  => 'Jonathan Rockway',
            email => 'jon@jrock.us',
        },
    );
};

warn $tmp;
sleep 1234;

$fi->fast_import->close;
