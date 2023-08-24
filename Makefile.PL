use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::Trrr',
    AUTHOR              => 'Zdenek Bohunek <zed448@icloud.com>',
    VERSION_FROM        => 'trrr',
    ABSTRACT            => 'search torrents',
    PL_FILES            => {},
    'EXE_FILES'         => ['trrr'],
    PREREQ_PM => {
        'HTTP::Tiny'    =>  0,
        'POSIX'         =>  0,
        'Term::ANSIColor'    =>  0,
        'Encode'        => 0,
        'URL::Encode'   => 0,
        'JSON::PP'      => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App::Trrr-*' },
);
