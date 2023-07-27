package App::Trrr::TPB;

=head1 NAME

App::Trrr::TPB - TPB API

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( tpb );
our $VERSION = '0.01';

use strict;
use Carp;
use HTTP::Tiny;
use JSON::PP;
use Data::Dumper;

sub tpb {
    my $keywords = shift;
    my $url = 'https://apibay.org/q.php?q=' . join('%20', @$keywords) . '&cat=0';

    my $response = HTTP::Tiny->new->get( $url );
    croak "Failed to get $url\n" unless $response->{success};
     
    my $json = JSON::PP->new->ascii->pretty->allow_nonref;
    my $content = $json->decode($response->{content});

    my( @item, %t ) = ();
    my %category = (
	    101 => "Audio > Music",
	    102 => "Audio > Books",
	    103 => "Audio > Sound Clips",
	    104 => "Audio > FLAC",
	    199 => "Audio > Other",
	    201 => "Video > Movies",
	    202 => "Video > Movies DRDR",
	    203 => "Video > Music Videos",
	    204 => "Video > Movie Clips",
	    205	=> "Video > TV-Shows",
	    206 => "Video > Handheld",
	    207 => "Video > HD Movies",
	    208	=> "Video > HD TV-Shows",
	    209 => "Video > 3D",
	    299 => "Video > Other",
	    301 => "Applications > Windows",
	    302 => "Applications > Mac/Apple",
	    303 => "Applications > Unix",
	    304 => "Applications > Handheld",
	    305 => "Applications > IOS(iPad/iPhone)",
	    306 => "Applications > Andriod",
	    399 => "Applications > Other OS",
	    401 => "Games > PC",
	    402 => "Games > Mac/Apple",
	    403 => "Games > PSx",
	    404 => "Games > XBOX360",
	    405 => "Games > Wii",
	    406 => "Games > Handheld",
	    407 => "Games > IOS(iPad/iPhone)",
	    408 => "Games > Android",
	    499 => "Games > Other OS",
	    501 => "Porn > Movies",
	    502 => "Porn > Movies DVDR",
	    503 => "Porn > Pictures",
	    504 => "Porn > Games",
	    505 => "Porn > HD-Movies",
	    506 => "Porn > Movie Clips",
	    599 => "Porn > Other",
	    601 => "Other > E-books",
	    602 => "Other > Comics",
	    603 => "Other > Pictures",
	    604 => "Other > Covers",
	    605 => "Other > Physibles",
	    699 => "Other > Other"
    );

    
    for(@$content){
        $t{title} = $_->{name};
	$t{magnet} = "magnet:?xt=urn:btih:" . $_->{info_hash} . "&dn=" . $t{title};
	$t{size} = $_->{size};
	$t{seeds} = $_->{seeders};
	$t{leechs} = $_->{leechers};
	$t{category} = $category{"$_->{category}"};
	
	push @item, {%t};
    }
    return \@item;
}

1;
