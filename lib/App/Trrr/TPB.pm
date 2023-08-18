package App::Trrr::TPB;

=head1 NAME

App::Trrr::TPB - TPB API

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( tpb );
our $VERSION = '0.01';

use v5.10;
use strict;
use warnings;
use JSON;
use Carp;
use HTTP::Tiny;
use JSON;
use List::Util qw(first);
use Data::Dumper;

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
    211 => "Video > UHD/4k Movies",
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


sub results {
    my( $content, $domain ) = @_;

    my( @item, %t ) = ();
    if( $domain eq 'apibay.org' ){
	$content = decode_json($content);

    	open(my $fh,"<",\$content) || die "cant open \$content: $!";
    	while(<$fh>){
            for(@$content){
                $t{title} = $_->{name};
	    
                $t{magnet} = "magnet:?xt=urn:btih:" . $_->{info_hash} . "&dn=" . $t{title};
        	$t{magnet} =~ s/ /%20/g;
        	$t{magnet} =~ s/"/%22/g;
	    
        	$t{size} = size($_->{size});
	        $t{seeds} = $_->{seeders};
	        $t{leechs} = $_->{leechers};
	        $t{category} = $category{"$_->{category}"};
	
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
	    #$in{table} = 1 if /^<tr>\r/;    
	    #$in{table} = 1 if /^<div class="detName">/;    
	    $in{table} = 0 if /\t<\/tr>\r$/;    

	    if(/\(<a href=".+?>(.+?)</ and $in{table}){
	        $t{category} = $1;
		$t{category} =~ s/ - / > /;
	    }

	    if(/^<div class="detName">.+>(.+?)<\/a>\r/ and $in{table}){
	        $t{title} = $1;
	    }

	    if(/^<a href="(magnet:.+?)".+<a href=".+\/user\/(.+?)\/.+Uploaded (.+?), Size (.+?),/ and $in{table}){
	        $t{magnet} = $1;
	        $t{user} = $2; 
		$t{added} = $3;
		$t{size} = $4; 
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
	'apibay.org', # 'https://' . 'apibay.org' . '/q.php?q=' . join('%20', @$keywords) . '&cat=0'
	'pirateproxy.live', # 'https://' . 'pirateproxy.live' . '/search/' . join('%20', @$keywords) . '/1/99/0' 
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
 	    if( !($response->{success}) and ($_ eq $domain[$#domain]) ){ die "non of the domains works:\n" . join("\n", @domain) }
	    next unless $response->{success};
	    return results($response->{content}, $_) if $response->{success};
    }
} 


1;
