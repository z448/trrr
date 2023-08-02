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

sub tpb {
    my $keywords = shift;
    my @domain = (
	'pirateproxy.live', # 'https://' . 'pirateproxy.live' . '/search/' . join('%20', @$keywords) . '/1/99/0' 
	'apibay.org', # 'https://' . 'apibay.org' . '/q.php?q=' . join('%20', @$keywords) . '&cat=0'
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
    for( @domain ){
	    if(/^apibay\.org$/){
		    $response = HTTP::Tiny->new->get( 'https://' . $_ . '/q.php?q=' . join('%20', @$keywords) . '&cat=0' );
		    return apibay($response->{content}) if $response->{success};
	    } else {
		    $response = HTTP::Tiny->new->get( 'https://' . $_ . '/search/' . join('%20', @$keywords) . '/1/99/0' ) ;
		    return mirror($response->{content}) if $response->{success};
    	    }
    }


} 


sub apibay {
    my $content = shift;
     
    my $json = JSON::PP->new->ascii->pretty->allow_nonref;
    $content = $json->decode($content);

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

    
    for(@$content){
        $t{title} = $_->{name};
	$t{magnet} = "magnet:?xt=urn:btih:" . $_->{info_hash} . "&dn=" . $t{title};
	$t{size} = size($_->{size});
	$t{seeds} = $_->{seeders};
	$t{leechs} = $_->{leechers};
	$t{category} = $category{"$_->{category}"};
	
	push @item, {%t};
    }
    return \@item;
}


sub mirror {
    my $content = shift;

    my $category = 0;
    my( @item, %t, $leechs, ) = ();
    open(my $fh,"<",\$content) || die "cant open \$content: $!";
    while(<$fh>){
            $t{title} = $_ and $t{title} =~ s/(.*?title\=\"Details for )(.*?)(\".*)/$2/ if /detName/;
            $t{magnet} = $_ and $t{magnet} =~ s/(\<a href\=\")(magnet.*?)(\".*)/$2/  if /\<a href\=\"magnet/;
            $t{size} = $_ and $t{size} =~ s/(.*?)(Size.*?\ )(.*?)(\&nbsp\;)(.)i(.)(.*)/$3$5b/ if /Size.*?\ /;

	if(/<td align="right">/){  
	    unless($leechs){
	        $t{seeds} = $_; $t{seeds} =~ s/(.*?<td align="right">)([0-9]+)(<.*)/$2/; $leechs = 1;
	    } else { $t{leechs} = $_; $t{leechs} =~ s/(.*?<td align="right">)([0-9]+)(<.*)/$2/; $leechs = 0 }
	}
        if(/More from this category/){
            if($category == 0){
                $t{cate} = $_ and $t{cate} =~ s/(.*category\"\>)(.*?)(\<.*)/$2/;
		#$t{category} = $_ and $t{category} =~ s/(.*category\"\>)(.*?)(\<.*)/$2/;
                chomp($t{magnet}, $t{title}, $t{size}, $t{cate}, $t{seeds}, $t{leechs});
		#chomp($t{magnet}, $t{title}, $t{size}, $t{category}, $t{seeds}, $t{leechs});
                push @item, {%t};
                $category = 1;
	    #} else { $category = 0 }
            } else {  # <-----from here
                    $t{gory} = $_ and $t{gory} =~ s/(.*category\"\>)(.*?)(\<.*)/$2/;
		    chomp($t{gory});
		    #$t{category} = $_ and $t{category} =~ s/(.*category\"\>)(.*?)(\<.*)/$2/;
		    $t{category} = $t{cate} . ' > ' . $t{gory}; 
		    $category = 0;
	    } # <----- to here
        }
    }
    close $fh;
    return \@item;
}


1;
