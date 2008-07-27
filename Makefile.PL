use inc::Module::Install;

name 'Git-FastImport';
all_from 'lib/Git/FastImport.pm';

build_requires 'Test::More';
build_requires 'ok';

WriteAll();
