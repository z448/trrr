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

    my( @item, %t, $leechs ) = ();
    for(@$content){
        $t{title} = $_->{name};
	$t{magnet} = "magnet:?xt=urn:btih:" . $_->{info_hash} . "&dn=" . $t{title};
	$t{size} = $_->{size};
	$t{seeds} = $_->{seeders};
	$t{leechs} = $_->{leechers};
	$t{category} = $_->{category};
	push @item, {%t};
    }
    return \@item;
}

1;
