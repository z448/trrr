package App::Trrr::RBG;

=head1 NAME

App::Trrr::RBG

=cut

@ISA       = qw(Exporter);
@EXPORT_OK = qw( rbg );
our $VERSION = '0.05';

use strict;
use warnings;

sub rbg {
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
    my $site_string = '<table width="100%" class="lista2t">';
    my @domain      = (
        'rargb.to',          'rarbgget.org',
        'www.rarbgproxy.to', 'www2.rarbggo.to',
        'rarbg.unblockninja.com'
    );

    for my $domain (@domain) {
        my $url =
            'https://'
          . $domain
          . '/search/?search='
          . join( '%20', @$keywords )
          . '&order=seeders&by=DESC';

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

    my $in_table = 0;
    my ( @item, %t ) = ();
    open( my $fh, '<', \$content ) || die "Can't open \$content: $!";
    while (<$fh>) {
        $in_table = 1 if /table.+lista2t/;
        $in_table = 0 if /<\/table>/;

        if ( / href="(.+)?" title="(.+)?"/ and $in_table == 1 ) {
            $t{api}    = 'rbg';
            $t{source}    = 'rarbg';
            $t{domain} = $domain;
            $t{link}   = $1;
            $t{link}   = 'https://' . $domain . $t{link};
            $t{title}  = $2;
        }

        if ( /a><a href="\/(.+)\/(.+)\/"/ and $in_table == 1 ) {
            $t{category} = $1 . ' > ' . $2;
        }

        if (/100px.+>(.+)</) {
            $t{size} = $1;
            $t{size} =~ s/ //;
            $t{size} =~ s/B/b/;
        }

        if (/150px.+?>(\d\d\d\d.+)?</) {
            $t{added} = $1;
        }

        if (/"50px.+color.+?>(\d+)</) {
            $t{seeds} = $1;
        }

        if (/"50px.+lista">(\d+)</) {
            $t{leechs} = $1;
        }

        if (/<td align="center" class="lista">(.*)<\/td>\r/) {
            $t{uploader} = $1;
            push @item, {%t};
        }
    }
    close $fh;
    return \@item;
}

sub magnet {
    my $content = shift;

    open( my $fh, '<', \$content ) || die "Can't open \$content: $!";
    while (<$fh>) {
        if (/href="(magnet.+)"/) {
            my $magnet = $1;
            $magnet =~ s/ /%20/g;
            $magnet =~ s/"/%22/g;
            return $magnet;
        }
    }
}

1;
