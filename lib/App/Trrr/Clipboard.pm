package App::Trrr::Clipboard;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( clipboard );
our $VERSION = '0.05';

use strict;

my %tool = (
    linux => {
        read  => [ 'xclip -o', 'xsel -o' ],
        write => [ 'xclip -i', 'xsel -i' ]
    },
    ios => {
        read  => ['pbpaste'],
        write => ['pbcopy']
    },
    darwin => {
        read  => ['pbpaste'],
        write => ['pbcopy']
    },
    msys => {    # could be also 'MSWin32' ? <---
        read  => ['/dev/clipboard'],
        write => ['/dev/clipboard']
    }
);

my $os = $^O;
open( my $os_ph, '-|', 'uname', '-a' );
while (<$os_ph>) {
    $os = 'ios' if /iPhone/;
}
close $os_ph;

sub dep {
    my $dep = shift;
    $dep =~ s/^(.+?) .+/$1/;

    open( my $depph, "-|", 'which', $dep );
    while (<$depph>) {
        chomp;
        return $_ if /\/$dep$/;
    }
}

sub clipboard {
    my $in = shift;

    if ( $os eq 'ios' ) {
        my $pb_dir = '/private/var/mobile/Library/Caches/com.apple.Pasteboard';
        if ( -e $pb_dir ) {
            opendir( my $pb_dir_dh, $pb_dir ) || die "Can't opendir $pb_dir: $!";
            my ($pb_dir_dir) = grep { !/^\./ && !/^\.\.$/ && -d "$pb_dir/$_" } readdir($pb_dir_dh);
            closedir $pb_dir_dh;

            opendir( my $pb_dir_dir_dh, "$pb_dir/$pb_dir_dir" ) || die "Can't opendir $pb_dir/$pb_dir_dir: $!";
            my @pb_dir_dir_file = grep { -f "$pb_dir/$pb_dir_dir/$_" } readdir($pb_dir_dir_dh);
            closedir $pb_dir_dir_dh;

            for my $file (@pb_dir_dir_file) {
                next if -s "$pb_dir/$pb_dir_dir/$file" == 38;
                open( my $ph, '-|', 'file', "$pb_dir/$pb_dir_dir/$file" ) || die "Can't open 'file' pipe to file $pb_dir/$pb_dir_dir/$file: $!";
                while (<$ph>) {
                    next unless /text, with no line terminators$/;

                    if ($in) {
                        open( my $fh, '>', "$pb_dir/$pb_dir_dir/$file" ) || die "Can't open file for writing $pb_dir/$pb_dir_dir/$file: $!";
                        print $fh $in;
                        close $fh;
                        return "'" . $in . "' has been placed into pasteboard";
                    }
                    else {
                        open( my $fh, '<', "$pb_dir/$pb_dir_dir/$file" ) || die "Can't open file for reading $pb_dir/$pb_dir_dir/$file: $!";
                        while (<$fh>) {
                            return $_;
                        }
                        close $fh;
                    }
                }
                close $ph;
            }
        }
        else { $in = "$in   " if $os eq 'ios' } # if it's iOS and com.apple.Pasteboard dir doesn't exist prepare $in for iOS pbcopy and continue below
    }

    if ($in) {
        my @tool = @{ $tool{$os}->{write} };
        for (@tool) {
            if ( dep($_) ) {
                system("echo '$in' | $_");
                return $in;
            }
            else {
                if ( $tool[$#tool] eq $_ ){    # if not even last one of tools is installed
                    for ( @{ $tool{$os}->{write} } ) { s/^(.+?) .+/$1/ }
                    print "For magnet link to be placed into clipboard install " . join( ' or ', @{ $tool{$os}->{write} } ) . ". ";
                    print "It can be found in com.ericasadun.utilities packege." if $os eq 'ios';
                }
            }
        }
    }
    else {
        my @tool = @{ $tool{$os}->{read} };
        for my $tool (@tool) {
            if ( dep($tool) ) {
                my $content = '';
                open( my $ph, '-|', $tool );
                while (<$ph>) {
                    chomp;
                    $content = $content . ' ' . $_;
                }
                close $ph;
                $content =~ s/\n/ /g;
                $content =~ s/^ //;

                return $content;
            }
            else {
                if ( $tool[$#tool] eq $tool ) {
                    for ( @{ $tool{$os}->{read} } ) { s/^(.+?) .+/$1/ }
                    print "To use clipboard content as search keywords install " . join( ' or ', @{ $tool{$os}->{read} } ) . ". ";
                    print "It can be found in com.ericasadun.utilities packege." if $os eq 'ios';
                }
            }
        }
    }
}

use v5.10;
say clipboard( $ARGV[0] );

1;
