﻿package App::Trrr::HotKey;

# this module is taken from StackOverflow post by brian d foy
# HotKey.pm read user input immediately after first character w/o waiting for enter ( POSIX )
# http://stackoverflow.com/questions/2685148/how-can-i-get-user-input-without-waiting-for-enter-in-perl/2685210

@ISA = qw(Exporter);
@EXPORT = qw(cbreak cooked readkey);
use strict;

my $load = eval {
    require POSIX;
    POSIX->import(':termios_h');
    1;
};
unless($load){ return 1 } else {
    no strict;
    my ($term, $oterm, $echo, $noecho, $fd_stdin);

    $fd_stdin = fileno(STDIN);
    $term     = POSIX::Termios->new();
    $term->getattr($fd_stdin);
    $oterm     = $term->getlflag();

    $echo     = ECHO | ECHOK | ICANON;
    $noecho   = $oterm & ~$echo;

    sub cbreak {
        $term->setlflag($noecho);
        $term->setcc(VTIME, 1);
        $term->setattr($fd_stdin, TCSANOW);
    }

    sub cooked {
        $term->setlflag($oterm);
        $term->setcc(VTIME, 0);
        $term->setattr($fd_stdin, TCSANOW);
    }

    sub readkey {
        my $key = '';
        cbreak();
        sysread(STDIN, $key, 1);
        cooked();
        return $key;
    }

    END { cooked() }
}
1;
