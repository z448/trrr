package App::Trrr::YTS;

=head1 NAME

App::Trrr::YTS

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( yts );
our $VERSION = '0.01';

use strict;
use warnings;
use Carp;
use HTTP::Tiny;
use JSON::PP;
use Data::Dumper;


sub yts {
    my $keywords = shift;

    if( $keywords =~ /^https:\/\// ){
        my $response = HTTP::Tiny->new->get($keywords);
        croak "Failed to get $keywords\n" unless $response->{success};
        return magnet($response->{content}) if $response->{success};
    }
    
    my @domain = (
	'yts.mx',
	'yts.pm'
    );

    my $response = {};
    for( @domain ){
	    my $url = 'https://' . $_ . '/ajax/search?query=' . join('%20', @$keywords);
	# https://yts.pm/ajax/search?query=happy%20end
	$response = HTTP::Tiny->new->get($url);
	croak "Failed to get $url\n" unless $response->{success};
	return results($response->{content}, $_) if $response->{success};
    }
}


sub results {
    my( $content, $domain ) = @_;
     
    my $json = JSON::PP->new->ascii->pretty->allow_nonref;
    $content = $json->decode($content);

    my( @item, %t ) = ();
    for(@{$content->{data}}){
	$t{api} = 'yts';
	$t{domain} = $domain;
	$t{link} = $_->{url};
        $t{title} = $_->{title};
	$t{category} = 'Movies';
	$t{size} = '';
	$t{seeds} = 1;
	$t{leechs} = '?';
	$t{uploader} = '?';
	push @item, {%t};
    }
    return \@item;
}

sub magnet {
    my $content = shift;    
    
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    while(<$fh>){
	if(/href="(magnet.+)"/){
	    my $magnet = $1;
            $magnet =~ s/ /%20/g;
            $magnet =~ s/"/%22/g;
	    return $magnet;
	}
    }
}


#my @query = qw( pulp fiction );
#print Dumper( yts(\@query) );

1;
