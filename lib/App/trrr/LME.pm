package App::trrr::LME;

=head1 NAME

App::trrr::LME

=cut

@ISA       = qw(Exporter);
@EXPORT_OK = qw( lme );
our $VERSION = '0.07';

use strict;
use warnings;
use App::trrr qw< get_content >;

sub lme {
    my $keywords = shift;
    my $cacert = "$ENV{HOME}/cacert.pem" if -f "$ENV{HOME}/cacert.pem";
    my $ua = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1";

    if ( $keywords =~ /\.html$/ ) {
        my $content = '';
        my $ph;

        $content = get_content($keywords);
        return magnet($content);
    }

    my $debug = 0;
    my $site_string = 'type="text" class="searchfield" name="q"';
    my @domain = (  
                    'www.limetorrents.to',
                    'limetorrents.unblockit.esq',
                    'www.limetorrents.lol',
                    'www.limetorrentx.cc',
                    'limetorrents.proxybit.pics',
    );

    my $url;
    for my $domain (@domain) {
        my $url =
            'https://'
          . $domain
          . '/search/all/'
          . $keywords
          . '/seeds/1/';

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

    my ( @item, %t ) = ();
    open( my $fh, '<', \$content ) || die "Can't open \$content: $!";
    while (<$fh>) {
        if (/^<\/tr><tr bgcolor="#F4F4F4"><td class="tdleft">(.+)/) {
            my $line = $1;
            $line =~ s/<tr bgcolor=("#FFFFFF"|"#F4F4F4")><td class="/\n/g;

            open( my $onefh, '<', \$line ) || die "Can't open \$line: $!";
            while (<$onefh>) {
                if (
/csprite_dl14"><\/a><a href="(\/.+?)">(.+?)<\/a><\/div><div class="tt-options"><\/div><\/td><td class="tdnormal">(.+) - in (.+?)<\/a><\/td><td class="tdnormal">(.+?)<\/td><td class="tdseed">(.+?)<\/td><td class="tdleech">(.+?)</
                  )
                {
                    $t{api}      = 'lme';
                    $t{source}      = 'limetorrents';
                    $t{domain}   = $domain;
                    $t{link}     = 'https://' . $t{domain} . $1;
                    $t{title}    = $2;
                    $t{added}    = $3;
                    $t{category} = $4;
                    $t{size}     = $5;
                    $t{seeds}    = $6;
                    $t{leechs}   = $7;

                    $t{seeds}  =~ s/,//;
                    $t{leechs} =~ s/,//;

                    push @item, {%t};
                }
            }
            close $onefh;
            last;
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
