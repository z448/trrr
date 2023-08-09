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
	$response = HTTP::Tiny->new->get($url);
	if( !($response->{success}) and ($_ eq $domain[$#domain]) ){ die "non of the domains works:\n" . join("\n", @domain) }
	
	next unless $response->{success};

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
	$t{year} = $_->{year};
	$t{size} = '?';
	$t{seeds} = 1;
	$t{leechs} = '?';
	$t{uploader} = '?';
	push @item, {%t};
    }
    return \@item;
}

sub magnet {
    my $content = shift;    
    
    my %magnet = ();
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    while(<$fh>){
	if(/href="(magnet.+?720p.+?)"/){ $magnet{'720p'} = $1 }
	if(/href="(magnet.+?1080p.+?)"/){ $magnet{'1080p'} = $1 }
	if(/href="(magnet.+?2160p.+?)"/){ $magnet{'2160p'} = $1 }
    }
    #return \%magnet;
    return $magnet{'2160p'} if exists $magnet{'2160p'};
    return $magnet{'1080p'} if exists $magnet{'1080p'};
    return $magnet{'720p'} if exists $magnet{'720p'};
}


1;
