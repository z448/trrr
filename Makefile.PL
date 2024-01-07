use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::trrr',
    AUTHOR              => 'Zdenek Bohunek <zdenek@cpan.org>',
    VERSION_FROM        => 'trrr',
    ABSTRACT            => 'search torrents',
    PL_FILES            => {},
    'EXE_FILES'         => ['trrr'],
    PREREQ_PM => {
        'POSIX'         =>  0,
        'Term::ANSIColor'    =>  0,
        'Encode'        => 0,
        'URL::Encode'   => 0,
        'JSON::PP'      => 0,
        'Time::HiRes'   => 0,
        'List::Util'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App::trrr-*' },
);
