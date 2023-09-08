package App::Trrr::YTS;

=head1 NAME

App::Trrr::YTS

=cut

@ISA       = qw(Exporter);
@EXPORT_OK = qw( yts );
our $VERSION = '0.02';

use strict;
use warnings;
use JSON::PP;

sub yts {
    my $keywords = shift;

    if ( $keywords =~ /^https:\/\// ) {
        my $response = '';
        open( my $ph, '-|', 'curl', '-s', "$keywords" )
          || die "Can't open 'curl $keywords' pipe: $!";
        while (<$ph>) {
            $response = $response . $_;
        }
        close $ph;

        return magnet($response);
    }

    my $site_string = '"message":"';
    my @domain      = ( 'yts.mx', 'yts.pm' );

    for my $domain (@domain) {
        my $url =
            'https://'
          . $domain
          . '/ajax/search?query='
          . join( '%20', @$keywords );

        my $response = '';
        open( my $ph, '-|', 'curl', '-s', "$url" )
          || die "Can't open 'curl $url' pipe: $!";
        while (<$ph>) {
            $response = $response . $_;
        }
        close $ph;

        unless ( $response =~ /$site_string/ ) {
            die "Could not connect to any of following domains:\n"
              . join( "\n", @domain )
              if $domain eq $domain[$#domain];
            next;
        }
        return results( $response, $domain );
    }
}

sub results {
    my ( $content, $domain ) = @_;

    $content = decode_json($content);

    my ( @item, %t ) = ();
    for ( @{ $content->{data} } ) {
        $t{api}      = 'yts';
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
