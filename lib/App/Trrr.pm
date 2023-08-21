package App::Trrr;

=head1 NAME

App::Trrr - search torrents

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( open_magnet );
our $VERSION = '0.15';

use strict;
use warnings;


sub dep{
    my $dep = shift;

    open( my $depph, "-|", 'which', $dep );
    while(<$depph>){
        chomp;
        return $_ if /\/$dep$/;
    }
}


sub os{
    my $os = $^O;

    open(my $os_ph, '-|', 'uname', '-a');
    while(<$os_ph>){
        $os = 'iOS' if /iPhone/;
    }
    close $os_ph;

    return $os;
}


sub open_magnet{
    my $magnet = shift;

    if(os() eq 'MSWin32' or os() eq 'msys'){
        system("$magnet") and exit;
    } elsif( os() =~ /iOS/){
        print "Can't read pasteboard content, 'pbcopy' tool not installed.\n" and exit unless dep('pbcopy');
        system("echo '$magnet   ' | pbcopy") and print "Magnet link has been placed into pasteboard\n";
    } elsif( os() =~ /(linux|darwin)/ ){
        print "Can't open magnet link, 'open' tool not installed.\n" and exit unless dep('open');
        system("open '$magnet'");  
    }
}

1;
