package App::Trrr::KAT;

=head1 NAME

App::Trrr::KAT - KickAss API

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( kat );
our $VERSION = '0.01';

use warnings;
use strict;
use URI::Encode qw(uri_decode);
use Carp;
use HTTP::Tiny;

sub kat {
    my $keywords = shift;
    my $url = 'http://kickasstorrents.to/usearch/' . join('%20', @$keywords) . '/';

    my $response;
    if(`which curl`){ 
        $response->{content} = `curl -skL '$url'`;
    } else {
        $response = HTTP::Tiny->new->get( $url );
        croak "Failed to get $url\n" unless $response->{success};
    }
     
    my( @item, %t ) = ();
    open(my $fh,"<",\$response->{content}) || die "cant open response $!";
    while(<$fh>){
        s/(.*\{ 'name': ')(.*?)(\'.*)(magnet\:.*?)('.*)/$2$4/ and $t{title} = uri_decode($2) and $t{magnet} = $4 if /data-sc-params="\{ 'name'\:/;
        $t{size} = $_ and $t{size} =~ s/(<td class="nobr center">)(.*?)( <span>)(.)(.*)/$2$4/ if /<td class="nobr center">/;
        $t{category} = $_ and $t{category} =~ s/(.*?span id="cat_.*?href=".*?">)(.*?)(<\/a.*)/$2/ if /^Posted/;
        $t{seeds} = $_ and $t{seeds} =~ s/(<td class="green center">)(.*?)(\<.*)/$2/ if /<td class="green center">/;

        if(/<td class="red lasttd center">/){
            $t{leechs} = $_; $t{leechs} =~ s/(<td class="red lasttd center">)(.*?)(\<.*)/$2/;
            chomp($t{magnet}, $t{title}, $t{size}, $t{category}, $t{seeds}, $t{leechs});
            push @item, {%t};
        }
    }
    return \@item;
}

1;
