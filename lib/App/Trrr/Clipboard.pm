package App::Trrr::Clipboard;

@ISA = qw(Exporter);
@EXPORT_OK = qw( clipboard );
our $VERSION = '0.04';

use v5.10;
use strict;
use warnings;
use autodie;

my %tool = (
    linux   =>  {
        read    =>  [ 'xclip -o', 'xsel -o' ],
        write   =>  [ 'xclip -i', 'xsel -i' ]
    },
    ios     =>  {
        read    =>  [ 'pbpaste' ],
        write   =>  [ 'pbcopy']
    },
    darwin  =>  {
        read    =>  [ 'pbpaste' ],
        write   =>  [ 'pbcopy' ]
    },
        msys =>  {  # could be  also 'MSWin32' ? <---
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

    if( $os eq 'ios' ){
	my $pb_dir = '/private/var/mobile/Library/Caches/com.apple.Pasteboard';
    	if( -e $pb_dir ){
	    opendir(my $pb_dir_dh, $pb_dir) || die "Can't opendir $pb_dir: $!";
	    my( $pb_dir_dir ) = grep { !/^\./ && !/^\.\.$/ && -d "$pb_dir/$_" } readdir($pb_dir_dh);
	    closedir $pb_dir_dh;

	    opendir(my $pb_dir_dir_dh, "$pb_dir/$pb_dir_dir") || die "Can't opendir $pb_dir/$pb_dir_dir: $!";
	    my @pb_dir_dir_file = grep { -f "$pb_dir/$pb_dir_dir/$_" } readdir($pb_dir_dir_dh);
	    closedir $pb_dir_dir_dh;

	    for my $file( @pb_dir_dir_file ){
		next if -s "$pb_dir/$pb_dir_dir/$file" == 38 ;
	        open(my $ph, '-|', 'file', "$pb_dir/$pb_dir_dir/$file") || die "Can't open 'file' pipe to file $pb_dir/$pb_dir_dir/$file: $!";
		while(<$ph>){
		    next unless /text, with no line terminators$/;

		    if($in){
			open(my $fh, '>', "$pb_dir/$pb_dir_dir/$file") || die "Can't open file for writing $pb_dir/$pb_dir_dir/$file: $!";
			print $fh $in;
			close $fh;
			return $in;
		    } else {
		        open(my $fh, '<', "$pb_dir/$pb_dir_dir/$file") || die "Can't open file for reading $pb_dir/$pb_dir_dir/$file: $!";
		        while(<$fh>){
			    return $_;
		        }
		    	close $fh;
		    } 
		}
		close $ph;
	    }
	} else { $in = "$in   " if $os eq 'ios' }
    }

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

say clipboard();

1;
