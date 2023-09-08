package App::Trrr::Clipboard;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( clipboard );
our $VERSION = '0.06';

use strict;
use warnings;

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
    msys => {
        read  => ['/dev/clipboard'],
        write => ['/dev/clipboard']
    },
    MSWin32 => {
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


            my $file38_count = 0;
            my @file38       = ();
            my $file38       = '';
            for my $file (@pb_dir_dir_file) {
                if ( -s "$pb_dir/$pb_dir_dir/$file" == 38 ) {
                    $file38_count++;
                    push @file38, $file;
                }
            }

            if ( $file38_count > 1 ) {
                for my $file (@file38) {
                    open( my $fh, '<', "$pb_dir/$pb_dir_dir/$file" ) || die "Can't open file for reading $pb_dir/$pb_dir_dir/$file: $!";
                    while (<$fh>) {
                        $file38 = $file if /^iOS rich content paste pasteboard type$/;
                    }
                    close $fh;
                }
            }
            elsif ( $file38_count == 1 ) {
                $file38 = $file38[0];
            }

            my $i = 0;
            for my $file (@pb_dir_dir_file) {
                delete $pb_dir_dir_file[$i] if $file eq $file38;
                $i++;
            }
            @pb_dir_dir_file = grep { defined } @pb_dir_dir_file;


            for my $file (@pb_dir_dir_file) {
                open( my $ph, '-|', 'file', "$pb_dir/$pb_dir_dir/$file" ) || die "Can't open 'file' pipe to file $pb_dir/$pb_dir_dir/$file: $!";
                while (<$ph>) {
                    next unless /: (ASCII|UTF-8 Unicode) text, with no line terminators$/ || /: (ASCII|UTF-8 Unicode) text$/;

                    if ($in) {
                        open( my $fh, '>', "$pb_dir/$pb_dir_dir/$file" ) || die "Can't open file for writing $pb_dir/$pb_dir_dir/$file: $!";
                        print $fh $in;
                        close $fh;
                        return $in;
                    }
                    else {
                        my $content = '';
                        open( my $fh, '<', "$pb_dir/$pb_dir_dir/$file" ) || die "Can't open file for reading $pb_dir/$pb_dir_dir/$file: $!";
                        while (<$fh>) {
                            $content = $content . $_;
                        }
                        close $fh;
                        return $content;
                    }
                }
                close $ph;
            }
        }
        else {
            $in = "$in   " if defined $in;
        } 
    }

    if ($in) {
        my @tool = @{ $tool{$os}->{write} };
        for my $tool(@tool) {
            if ( dep($tool) ) {
                if ( system("echo '$in' | $tool") ) {
                    return 0;
                }
                else { return $in }
            }
            else {
                if ( $tool[$#tool] eq $tool ) { 
                    for ( @{ $tool{$os}->{write} } ) { s/^(.+?) .+/$1/ }
                    print "Can't write content into clipboard. To do that install " . join( ' or ', @{ $tool{$os}->{write} } ) . ". ";
                    print "It can be found in com.ericasadun.utilities packege." if $os eq 'ios';
                    print "\n";
                    return 0;
                }
            }
        }
    }
    else {
        my @tool = @{ $tool{$os}->{read} };
        for my $tool (@tool) {
            if ( dep($tool) ) {
                my $content = '';
                open( my $ph, '-|', $tool ) || die "Can't open pipe to $tool: $!";
                while (<$ph>) {
                    $content = $content . ' ' . $_;
                }
                close $ph;
                return $content;
            }
            else {
                if ( $tool[$#tool] eq $tool ) {
                    for ( @{ $tool{$os}->{read} } ) { s/^(.+?) .+/$1/ }
                    print "Can't read clipboard content. To do that install " . join( ' or ', @{ $tool{$os}->{read} } ) . ". ";
                    print "It can be found in com.ericasadun.utilities packege." if $os eq 'ios';
                    print "\n";
                    return 0;
                }
            }
        }
    }
}


1;
