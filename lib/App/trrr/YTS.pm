package App::trrr::YTS;

=head1 NAME

App::trrr::YTS

=cut

@ISA       = qw(Exporter);
@EXPORT_OK = qw( yts );
our $VERSION = '0.05';

use strict;
use warnings;
use JSON::PP;
use App::trrr qw< get_content >;

sub yts {
    my $keywords = shift;
    my $cacert = "$ENV{HOME}/cacert.pem" if -f "$ENV{HOME}/cacert.pem";
    my $ua = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1";

    if ( $keywords =~ /^https:\/\// ) {
        my $content = '';
        my $ph;

        $content = get_content($keywords);
        return magnet($content);
    }

    my $debug = 0;
    my $site_string = '"message":"';
    my @domain      = ( 'yts.mx', 'yts.pm' );

    for my $domain (@domain) {
        my $url =
            'https://'
          . $domain
          . '/ajax/search?query='
          . $keywords;

        my $content = '';
        my $ph;

        $content = get_content($url);
        unless ( $content =~ /$site_string/ ) {
            print "$domain has no \$site_string\n" if $debug; 
            print "Could not find \$site_string or could not connect to any of following domains:\n" . join( "\n", @domain ) . "\n" if $domain eq $domain[$#domain] and $debug;
            next;
        }
        return results( $content, $domain );
    }
}

sub results {
    my ( $content, $domain ) = @_;

    $content = decode_json($content);

    my ( @item, %t ) = ();
    for ( @{ $content->{data} } ) {
        $t{api}      = 'yts';
        $t{source}      = 'yts';
        $t{domain}   = $domain;
        $t{link}     = $_->{url};
        $t{link}     = 'https:' . $t{link} if $domain eq 'yts.pm';
        $t{title}    = $_->{title};
        $t{category} = 'Movies';
        $t{year}     = $_->{year};
        $t{size}     = '?';
        $t{seeds}    = 1;
        $t{leechs}   = '?';
        $t{uploader} = '?';
        push @item, {%t};
    }
    return \@item;
}

sub magnet {
    my $content = shift;

    my %magnet = ();
    my %in     = ( '720p' => 0, '1080p' => 0, '2160p' => 0 );
    open( my $fh, '<', \$content ) || die "Can't open \$content: $!";
    while (<$fh>) {
        if (/<div class="modal-quality" id="modal-quality-720p/) {
            $in{'720p'} = 1;
        }
        if (/<div class="modal-quality" id="modal-quality-1080p/) {
            $in{'1080p'} = 1;
        }
        if (/<div class="modal-quality" id="modal-quality-2160p/) {
            $in{'2160p'} = 1;
        }

        if ( /href="(magnet:\?.+?)"/ and $in{'720p'} ) {
            $magnet{'720p'} = $1;
            $in{'720p'}     = 0;
        }

        if ( /href="(magnet:\?.+?)"/ and $in{'1080p'} ) {
            $magnet{'1080p'} = $1;
            $in{'1080p'}     = 0;
        }

        if ( /href="(magnet:\?.+?)"/ and $in{'2160p'} ) {
            $magnet{'2160p'} = $1;
            $in{'2160p'}     = 0;
        }
    }
    return $magnet{'2160p'} if exists $magnet{'2160p'};
    return $magnet{'1080p'} if exists $magnet{'1080p'};
    return $magnet{'720p'}  if exists $magnet{'720p'};
}

1;
