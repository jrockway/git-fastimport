use inc::Module::Install;

name 'Git-FastImport';
all_from 'lib/Git/FastImport.pm';

requires 'DateTime';
requires 'DateTime::Format::Epoch';
requires 'IPC::Cmd';
requires 'MooseX::Types::Path::Class';
build_requires 'Directory::Scratch';
build_requires 'Test::Exception';
build_requires 'Test::More';
build_requires 'ok';

requires_external_bin 'git';

WriteAll();
