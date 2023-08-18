package App::Trrr::KAT;

=head1 NAME

App::Trrr::KAT

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( kat );
our $VERSION = '0.01';

use strict;
use warnings;
use HTTP::Tiny;
use URL::Encode q(url_decode_utf8);

sub kat {
    my $keywords = shift;
    if( $keywords =~ /\.html$/ ){
        my $response = HTTP::Tiny->new->get($keywords);
        die "Failed to get $keywords\n" unless $response->{success};
        return magnet($response->{content}) if $response->{success};
    }

    my @domain = (
	'katcr.to',
	'kickasstorrents.to',
	'kickasstorrent.cr',
	'kat.am',
	'thekat.info', 
	'kick4ss.com',
	'kat.rip'
    );

    my $url;
    for( @domain ){
	if(/katcr\.to/ || /kickasstorrents\.to/ || /kickasstorrent\.cr/ || /kat\.am/){
	    $url = 'https://' . $_ . '/usearch/' . join('%20', @$keywords) . '/?sortby=seeders&sort=desc';
	} else {
	    $url = 'https://' . $_ . '/usearch/' . join('%20', @$keywords) . '/?field=seeders&sorder=desc';
        }

	my $response = HTTP::Tiny->new->get($url);
	if( !($response->{success}) and ($_ eq $domain[$#domain]) ){ die "none of the domains works:\n" . join("\n", @domain) }
	next unless $response->{success};
	return results($response->{content}, $_) if $response->{success};
    }
}


sub results {
    my( $content, $domain ) = @_;

    my $in_table = 0;
    my $in_seeds = 0;
    my $in_leechs= 0;
    my $in_uploader = 0;
    my( @item, %t ) = ();
    
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    
    if($domain =~ /katcr\.to|kickasstorrents\.to|kickasstorrent\.cr|kat\.am/){
        while(<$fh>){
	    $in_table = 1 if /table.+data frontPageWidget/;
	    $in_table = 0 if /<\/table>/;

	    if(/<a href="(\/.+?)".+filmType">/ and $in_table){
	        $t{api} = 'kat';
	        $t{domain} = $domain;
	        $t{link} = $1; $t{link} = 'https://' . $domain . $t{link};
            } 

	    if(/<strong class="red">(.+) <\/a>$/ and $in_table){
	        $t{title} = $1; 
	        $t{title} =~ s/<strong class="red">//g;
	        $t{title} =~ s/<\/strong>//g;
	        $t{title} =~ s/<\/a>//g;
	    }

	    if(/href="\/user\/(.+)\/">$/ and $in_table){
	        $t{uploader} = $1;
            }

	    if(/^<a href="\/(.+?)\/(.+?)\/">$/ and $in_table){
	        $t{category} = $1 . ' > ' . $2;
	    }

	    if(/^(\d.+?B) <\/td>$/){
	        $t{size} = $1; $t{size} =~ s/B/b/;
	    }

	    if(/^<td class="center" title="(\d+?)<br\/>(day.*|week.*|month.*|year.*)">$/){   
	        $t{added} = $1 . ' ' . $2;
	    }
	
	    if(/^<td class="green center">$/ and $in_table){ $in_seeds = 1}
	    if(/^(\d+?) <\/td>$/ and $in_seeds){
	        $t{seeds} = $1;
	        $in_seeds = 0;
	    }

	    if(/^<td class="red lasttd center">$/ and $in_table){ $in_leechs = 1 }
	    if(/^(\d+?) <\/td>$/ and $in_leechs){
	        $t{leechs} = $1;
	        $in_leechs = 0;
                push @item, {%t};
            }
        }
    } elsif($domain =~ /thekat\.info|kick4ss\.com|kat\.rip/){
        while(<$fh>){	    
	    if(/torrent_latest_torrents/){ $in_table = 1 }
	    if(/<\/tr>/){ $in_table = 0 }

	    if(/magnet link" href="(.+?)"/ and $in_table){
	        $t{magnet} = $1;
	        $t{magnet} =~ s/https.+magnet/magnet/;
		$t{magnet} = url_decode_utf8($t{magnet});
	    }

	    if(/class="cellMainLink">(.+?)<\/a>$/ and $in_table){
	        $t{api} = 'kat';
	        $t{title} = $1;
		$t{uploader} = '?';
	    }

	    if(/cat_12975568"><strong><a href="\/(.+?)"/ and $in_table){
	        $t{category} = $1;
	    }

	    if(/Posted by$/){ $in_uploader = 1 }
            if(/        ([a-zA-Z0-9_\.]+)$/ and $in_table and $in_uploader){
		#HERE
		$t{uploader} = $1;
		$in_uploader = 0;
	    }

	    if(/<td class="nobr center">(.+?)<\/span><\/td>$/ and $in_table){
	        $t{size} = $1;
		$t{size} =~ s/B/b/;
		$t{size} =~ s/ //;
	    }

	    if(/<td class="nobr center" title=".+?">(\d+ \w+|just now) ago<\/td>$/ and $in_table){
		$t{added} = $1;
	    
	    }

	    if(/<td class="green center">(\d+)<\/td>/ and $in_table){
	        $t{seeds} = $1;
	    }

	    if(/<td class="red lasttd center">(\d+)<\/td>/ and $in_table){
	        $t{leechs} = $1;
            	push @item, {%t};
	    }

        }
    }
    close $fh;
    return \@item;
}


sub magnet {
    my $content = shift;
    
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    while(<$fh>){
	if(/href="(magnet:.+?)"/){
	    my $magnet = $1;
	    return $magnet;
	}
    }
}


1;
