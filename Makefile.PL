use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::Trrr',
    AUTHOR              => 'Zdenek Bohunek <zed448@icloud.com>',
    VERSION_FROM        => 'lib/App/Trrr.pm',
    ABSTRACT_FROM       => 'lib/App/Trrr.pm',
    PL_FILES            => {},
    'EXE_FILES'         => ['trrr'],
    PREREQ_PM => {
        'HTTP::Tiny'    =>  0,
        'POSIX'         =>  0,
        'Term::ANSIColor'    =>  0,
        'Encode'        => 0,
        'URI::Encode'        =>0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App::Trrr-*' },
);
