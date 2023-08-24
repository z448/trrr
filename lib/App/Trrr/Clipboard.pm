package App::Trrr::Clipboard;

@ISA = qw(Exporter);
@EXPORT_OK = qw( clipboard );
our $VERSION = '0.04';

use strict;
use warnings;
use autodie;

my %tool = (
    linux   =>  {
        read    =>  [ 'xclip -o', 'xsel -o' ],
        write   =>  [ 'xclip -i', 'xsel -i' ]
    },
    ios     =>  {
        read    =>  [ 'pbcopy' ],
        write   =>  [ 'pbpaste']
    },
    macos   =>  {
        read    =>  [ 'pbcopy' ],
        write   =>  [ 'pbpaste' ]
    },
    win     =>  {
        read    =>  [ '/dev/clipboard' ],
        write   =>  [ '/dev/clipboard' ]
    }
);


my $os = $^O;
open(my $os_ph, '-|', 'uname', '-a');
while(<$os_ph>){
    $os = 'ios' if /iPhone/;
}
close $os_ph;


sub dep{
    my $dep = shift;
    $dep =~ s/^(.+?) .+/$1/;

    open( my $depph, "-|", 'which', $dep );
    while(<$depph>){
        chomp;
        return $_ if /\/$dep$/;
    }
}


sub clipboard{
    my $in = shift;
    $in = "$in   " if $os eq 'ios';

    if($in){
        for( @{$tool{$os}->{write}} ){
            if( dep($_) ){ system("echo '$in' | $_") }
        }
    } else {
        for my $tool( @{$tool{$os}->{read}} ){
            if( dep($tool) ){ 
                my $content = '';
                open(my $ph, '-|', $tool );
                while(<$ph>){
                    chomp;
                    $content = $content . ' ' . $_;
                }
                close $ph;
                $content =~ s/\n/ /g;
                $content =~ s/^ //;

                return $content;
            }
        }
    }
}


1;
