package App::Trrr::TPB;

=head1 NAME

App::Trrr::TPB - TPB API

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( tpb );
our $VERSION = '0.01';

use strict;
use warnings;
use JSON;
use HTTP::Tiny;
use List::Util qw(first);

sub size {
    my $bytes = shift;
    
    my $round = sub {
    	my $size = shift;
        my @size = split(//, $size);

	my $dotIdx = first { $size[$_] eq '.' } 0..$#size;
	
	if( $size[$dotIdx + 3] >= 5 ){
		my $size = join('', @size[0..$dotIdx + 2]);
		$size = $size + 0.01;
		return $size;
	} else {
		splice @size, $dotIdx + 3;
		my $size = join('', @size[0..$dotIdx + 2]);
		return $size;
	}
    };

    if( length $bytes > 9 ){ 
	my $size = $round->($bytes / 1024 / 1024 / 1024);
	return $size . 'Gb';
    } elsif( length $bytes > 6 ){
	my $size = $round->($bytes / 1024 / 1024);
	return $size . 'Mb';
    } elsif( length $bytes > 3 ){
	my $size = $round->($bytes / 1024);
	return $size . 'kb';
    } else {
	    return $bytes . 'bytes';
    }
}


my %category = (
    101 => "Music",
    102 => "Audio Books",
    103 => "Sound Clips",
    104 => "Audio FLAC",
    199 => "Audio Other",
    201 => "Movies",
    202 => "Movies",
    203 => "Music Videos",
    204 => "Movie Clips",
    205	=> "TV-Shows",
    206 => "Handheld",
    207 => "HD Movies",
    208	=> "HD TV-Shows",
    209 => "3D",
    211 => "UHD/4k Movies",
    299 => "Other Videos",
    301 => "Windows",
    302 => "Mac",
    303 => "Unix",
    304 => "Handheld",
    305 => "iOS",
    306 => "Andriod",
    399 => "Other OS",
    401 => "PC",
    402 => "Mac",
    403 => "PSX",
    404 => "XBOX360",
    405 => "Wii",
    406 => "Handheld",
    407 => "iOS",
    408 => "Android",
    499 => "Games",
    501 => "Porn Movies",
    502 => "Porn Movies",
    503 => "Porn Pictures",
    504 => "Porn Games",
    505 => "Porn HD",
    506 => "Porn Clips",
    599 => "Porn",
    601 => "E-books",
    602 => "Comics",
    603 => "Pictures",
    604 => "Covers",
    605 => "Physibles",
    699 => "Other"
);


sub results {
    my( $content, $domain ) = @_;

    my( @item, %t ) = ();
    if( $domain eq 'apibay.org' ){
	$content = decode_json($content);

    	open(my $fh,"<",\$content) || die "cant open \$content: $!";
    	while(<$fh>){
            for(@$content){
                $t{title} = $_->{name};
		$t{api} = 'tpb';
	    
                $t{magnet} = "magnet:?xt=urn:btih:" . $_->{info_hash} . "&dn=" . $t{title};
        	$t{magnet} =~ s/ /%20/g;
        	$t{magnet} =~ s/"/%22/g;
	    
        	$t{size} = size($_->{size});
	        $t{seeds} = $_->{seeders};
	        $t{leechs} = $_->{leechers};
	        $t{category} = $category{"$_->{category}"} || '?';
	
	    	push @item, {%t};
    	    }
    	    return \@item;
	}
    	close $fh;
    } else {
	my %in = ( table => 0, seeds => 1 );
    	open(my $fh,"<",\$content) || die "cant open \$content: $!";
    	while(<$fh>){
	    $in{table} = 1 if /\(<a href="/;    
	    $in{table} = 0 if /\t<\/tr>\r$/;    

	    if(/\(<a href=".+?>(.+?)</ and $in{table}){
	        $t{category} = $1;
		$t{category} =~ s/ - / > /;
	    }

	    if(/^<div class="detName">.+>(.+?)<\/a>\r/ and $in{table}){
	        $t{title} = $1;
		$t{api} = 'tpb';
	    }

	    if(/^<a href="(magnet:.+?)".+Uploaded (.+?), Size (.+?),(.+)(\/|>)(.+?)<\/(i>|a> )<\/font>\r/ and $in{table}){ 
	        $t{magnet} = $1;
		$t{added} = $2;
		$t{size} = $3; 
	        $t{user} = $6; 
		$t{added} =~ s/&nbsp;/-/;
		$t{size} =~ s/&nbsp;/\ /; $t{size} =~ s/iB/b/;
	    }
	    
	    if(/<td align="right">(\d+?)<\/td>\r/ and $in{table}){
  	        if( $in{seeds} % 2 ){
		    $t{seeds} = $1;
		    $in{seeds}++; 
	        } else {
	              $t{leechs} = $1;
		      $in{seeds}++;  
		  }
	    }

	    if(/\t<\/tr>\r/){
		push @item, {%t};
	    }
	}
	close $fh;
	return \@item;
    }
}


sub tpb {
    my $keywords = shift;
    my @domain = (
	'apibay.org',
	'pirateproxy.live',
	'thepiratebay.zone',
	'pirate-proxy.ink',
	'www.pirateproxy-bay.com',
	'www.tpbproxypirate.com',
	'proxifiedpiratebay.org',
	'ukpirate.co',
	'mirrorbay.top',
	'tpb.skynetcloud.site',
	'tpb25.ukpass.co'
    );

    my $response = {};
    my $url;
    for( @domain ){
	    if(/^apibay\.org$/){
		    $url = 'https://' . $_ . '/q.php?q=' . join('%20', @$keywords) . '&cat=0';
	    } else {
		    $url = 'https://' . $_ . '/search/' . join('%20', @$keywords) . '/1/99/0';
    	    }
	    
	    $response = HTTP::Tiny->new->get($url) ;
 	    if( !($response->{success}) and ($_ eq $domain[$#domain]) ){ die "none of the domains works:\n" . join("\n", @domain) }
	    next unless $response->{success};
	    return results($response->{content}, $_) if $response->{success};
    }
} 


1;
