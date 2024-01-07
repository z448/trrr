package App::Trrr::TPB;

=head1 NAME

App::Trrr::TPB - TPB API

=cut

@ISA       = qw(Exporter);
@EXPORT_OK = qw( tpb );
our $VERSION = '0.06';

use strict;
use warnings;
use JSON::PP;
use List::Util qw(first);


sub size {
    my $bytes = shift;

    my $round = sub {
        my $size = shift;
        my @size = split( //, $size );
        
        my $dotIdx = first { $size[$_] eq '.' } 0 .. $#size;
        unless( $dotIdx ){ return $size };
        unless( defined $size[ $dotIdx + 2 ]){ return $size };
        unless( defined $size[ $dotIdx + 3 ]){ return $size };
        
        if ( $size[ $dotIdx + 3 ] >= 5 ) {
            my $size = join( '', @size[ 0 .. $dotIdx + 2 ] );
            $size = $size + 0.01;
            return $size;
        }
        else {
            splice @size, $dotIdx + 3;
            my $size = join( '', @size[ 0 .. $dotIdx + 2 ] );
            return $size;
        }
    };

    if ( length $bytes > 9 ) {
        my $size = $round->( $bytes / 1024 / 1024 / 1024 );
        return $size . 'Gb';
    }
    elsif ( length $bytes > 6 ) {
        my $size = $round->( $bytes / 1024 / 1024 );
        return $size . 'Mb';
    }
    elsif ( length $bytes > 3 ) {
        my $size = $round->( $bytes / 1024 );
        return $size . 'kb';
    }
    else {
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
    205 => "TV-Shows",
    206 => "Handheld",
    207 => "HD Movies",
    208 => "HD TV-Shows",
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
    my ( $content, $domain ) = @_;

    my ( @item, %t ) = ();
    if ( $domain eq 'apibay.org' ) {
        $content = decode_json($content);

        open( my $fh, "<", \$content ) || die "Can't open \$content: $!";
        while (<$fh>) {
            for (@$content) {
                $t{title} = $_->{name};
                $t{title} =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
                return 0 if $t{title} =~ /No results returned/;

                $t{api}   = 'tpb';
                $t{source} = 'piratebay';

                $t{magnet} =
                  "magnet:?xt=urn:btih:" . $_->{info_hash} . "&dn=" . $t{title};
                $t{magnet} =~ s/ /%20/g;
                $t{magnet} =~ s/"/%22/g;

                $t{size}     = size( $_->{size} );
                $t{seeds}    = $_->{seeders};
                $t{leechs}   = $_->{leechers};
                $t{category} = $category{"$_->{category}"} || '?';

                push @item, {%t};
            }
            return \@item;
        }
        close $fh;
    }
    else {
        my %in = ( table => 0, seeds => 1 );
        open( my $fh, "<", \$content ) || die "Can't open \$content: $!";
        while (<$fh>) {
            $in{table} = 1 if /\(<a href="/;
            $in{table} = 0 if /\t<\/tr>\r$/;

            if ( /\(<a href=".+?>(.+?)</ and $in{table} ) {
                $t{category} = $1;
                $t{category} =~ s/ - / > /;
            }

            if ( /^<div class="detName">.+>(.+?)<\/a>\r/ and $in{table} ) {
                $t{title} = $1;
                $t{api}   = 'tpb';
                $t{source} = 'piratebay';
            }

            if (
/^<a href="(magnet:.+?)".+Uploaded (.+?), Size (.+?),(.+)(\/|>)(.+?)<\/(i>|a> )<\/font>\r/
                and $in{table} )
            {
                $t{magnet} = $1;
                $t{added}  = $2;
                $t{size}   = $3;
                $t{user}   = $6;
                $t{added} =~ s/&nbsp;/-/;
                $t{size}  =~ s/&nbsp;/\ /;
                $t{size}  =~ s/iB/b/;
            }

            if ( /<td align="right">(\d+?)<\/td>\r/ and $in{table} ) {
                if ( $in{seeds} % 2 ) {
                    $t{seeds} = $1;
                    $in{seeds}++;
                }
                else {
                    $t{leechs} = $1;
                    $in{seeds}++;
                }
            }

            if (/\t<\/tr>\r/) {
                push @item, {%t};
            }
        }
        close $fh;
        return \@item;
    }
}

sub tpb {
    my $keywords = shift;
    my $cacert = "$ENV{HOME}/cacert.pem" if -f "$ENV{HOME}/cacert.pem";
    my $debug = 0;
    my $site_string = 'eeders"';
    my $ua = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1";
    my @domain      = (
        'apibay.org',              'pirateproxy.live',
        'thepiratebay.zone',       'pirate-proxy.ink',
        'www.pirateproxy-bay.com', 'www.tpbproxypirate.com',
        'proxifiedpiratebay.org',  'ukpirate.co',
        'mirrorbay.top',           'tpb.skynetcloud.site',
        'tpb25.ukpass.co'
    );

    my $url;
    for my $domain (@domain) {
        if ( $domain =~ /^apibay\.org$/ ) {
            $url =
                'https://'
              . $domain
              . '/q.php?q='
              . $keywords
              . '&cat=0';
        }
        else {
            $url =
                'https://'
              . $domain
              . '/search/'
              . $keywords
              . '/1/99/0';
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


1;
