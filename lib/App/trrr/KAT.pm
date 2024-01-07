package App::trrr::KAT;

=head1 NAME

App::trrr::KAT

=cut

@ISA       = qw(Exporter);
@EXPORT_OK = qw( kat );
our $VERSION = '0.07';

use strict;
use warnings;
use URL::Encode q(url_decode_utf8);

sub kat {
    my $keywords = shift;
    my $cacert = "$ENV{HOME}/cacert.pem" if -f "$ENV{HOME}/cacert.pem";
    my $ua = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1";

    if ( $keywords =~ /\.html$/ ) {
        my $response = '';
        my $ph;
        if($cacert){
            open( $ph, '-|', 'curl', "--cacert", "$cacert", "--user-agent", "$ua", '-s', "$keywords" ) || die "Cant't open 'curl $keywords' pipe: $!";
        } else {
            open( $ph, '-|', 'curl', "--user-agent", "$ua", '-s', "$keywords" ) || die "Cant't open 'curl $keywords' pipe: $!";
        }   
        while (<$ph>) {
            $response = $response . $_;
        }
        close $ph;

        return magnet($response);
    }

    my $debug = 0;
    my $site_string = 'data-download title="Download';
    my @domain      = (
        'kat.rip',
        'kick4ss.com',        
        'thekat.info',        
        'katcr.to',
        'kickasstorrents.to',
        'kickasstorrent.cr',
        'kat.am',
    );

    my $url;
    for my $domain (@domain) {
        if ( $domain =~
            /^(katcr\.to|kickasstorrents\.to|kickasstorrent\.cr|kat\.am)$/ )
        {
            $url =
                'https://'
              . $domain
              . '/usearch/'
              . $keywords
              . '/?sortby=seeders&sort=desc';
        }
        else {
            $url =
                'https://'
              . $domain
              . '/usearch/'
              . $keywords
              . '/?field=seeders&sorder=desc';
        }

        my $response = '';
        my $ph;
        if($cacert){
            open( $ph, '-|', 'curl', "--cacert", "$cacert", "--user-agent", "$ua", '-s', "$url" ) || die "Cant't open 'curl $url' pipe: $!";
        } else {
            open( $ph, '-|', 'curl', "--user-agent", "$ua", '-s', "$url" ) || die "Cant't open 'curl $url' pipe: $!";
        }   
        while (<$ph>) {
            $response = $response . $_;
        }
        close $ph;

        unless ( $response =~ /$site_string/ ) {
            print "$domain has no \$site_string\n" if $debug; 
            print "Could not find \$site_string or could not connect to any of following domains:\n" . join( "\n", @domain ) . "\n" if $domain eq $domain[$#domain] and $debug;
            next;
        }
        return results( $response, $domain );

    }
}

sub results {
    my ( $content, $domain ) = @_;

    my $in_table    = 0;
    my $in_seeds    = 0;
    my $in_leechs   = 0;
    my $in_uploader = 0;
    my ( @item, %t ) = ();

    open( my $fh, '<', \$content )
      || die "Can't open \$content: $!";

    if ( $domain =~ /^(katcr\.to|kickasstorrents\.to|kickasstorrent\.cr|kat\.am)$/ )
    {
        while (<$fh>) {
            $in_table = 1 if /table.+data frontPageWidget/;
            $in_table = 0 if /<\/table>/;

            if ( /<a href="(\/.+?)".+filmType">/ and $in_table ) {
                $t{api}    = 'kat';
                $t{source}    = 'kickasstorrents';
                $t{domain} = $domain;
                $t{link}   = $1;
                $t{link}   = 'https://' . $domain . $t{link};
            }

            if ( /<strong class="red">(.+) <\/a>$/ and $in_table ) {
                $t{title} = $1;
                $t{title} =~ s/<strong class="red">//g;
                $t{title} =~ s/<\/strong>//g;
                $t{title} =~ s/<\/a>//g;
            }

            if ( /href="\/user\/(.+)\/">$/ and $in_table ) {
                $t{uploader} = $1;
            }

            if ( /^<a href="\/(.+?)\/(.+?)\/">$/ and $in_table ) {
                $t{category} = $1 . ' > ' . $2;
            }

            if (/^(\d.+?B) <\/td>$/) {
                $t{size} = $1;
                $t{size} =~ s/B/b/;
            }

            if (
/^<td class="center" title="(\d+?)<br\/>(day.*|week.*|month.*|year.*)">$/
              )
            {
                $t{added} = $1 . ' ' . $2;
            }

            if ( /^<td class="green center">$/ and $in_table ) { $in_seeds = 1 }
            if ( /^(\d+?) <\/td>$/             and $in_seeds ) {
                $t{seeds} = $1;
                $in_seeds = 0;
            }

            if ( /^<td class="red lasttd center">$/ and $in_table ) {
                $in_leechs = 1;
            }
            if ( /^(\d+?) <\/td>$/ and $in_leechs ) {
                $t{leechs} = $1;
                $in_leechs = 0;
                push @item, {%t};
            }
        }
    }
    else {
        while (<$fh>) {
            if (/torrent_latest_torrents/) { $in_table = 1 }
            if (/<\/tr>/)                  { $in_table = 0 }

            if ( /magnet link" href="(.+?)"/ and $in_table ) {
                $t{magnet} = $1;
                $t{magnet} =~ s/https.+magnet/magnet/;
                #print "\$t{magnet} before decode is:$t{magnet}\n";###
                $t{magnet} = url_decode_utf8( $t{magnet} );
                #print "\$t{magnet} after decode is:$t{magnet}\n";###
            }

            if ( /class="cellMainLink">(.+?)<\/a>$/ and $in_table ) {
                $t{api}      = 'kat';
                $t{source}    = 'kickasstorrents';
                $t{title}    = $1;
                $t{uploader} = '?';
            }

            if ( /cat_12975568"><strong><a href="\/(.+?)"/ and $in_table ) {
                $t{category} = $1;
            }

            if (/Posted by$/) { $in_uploader = 1 }
            if ( /        ([a-zA-Z0-9_\.]+)$/ and $in_table and $in_uploader ) {
                $t{uploader} = $1;
                $in_uploader = 0;
            }

            if ( /<td class="nobr center">(.+?)<\/span><\/td>$/ and $in_table )
            {
                $t{size} = $1;
                $t{size} =~ s/B/b/;
                $t{size} =~ s/ //;
            }

            if (
/<td class="nobr center" title=".+?">(\d+ \w+|just now) ago<\/td>$/
                and $in_table )
            {
                $t{added} = $1;

            }

            if ( /<td class="green center">(\d+)<\/td>/ and $in_table ) {
                $t{seeds} = $1;
            }

            if ( /<td class="red lasttd center">(\d+)<\/td>/ and $in_table ) {
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

    open( my $fh, '<', \$content ) || die "Can't open \$content: $!";
    while (<$fh>) {
        if (/href="(magnet:.+?)"/) {
            my $magnet = $1;
            return $magnet;
        }
    }
}

1;
