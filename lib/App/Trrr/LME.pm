package App::Trrr::LME;

=head1 NAME

App::Trrr::LME

=cut

@ISA       = qw(Exporter);
@EXPORT_OK = qw( lme );
our $VERSION = '0.03';

use strict;
use warnings;

sub lme {
    my $keywords = shift;
    if ( $keywords =~ /\.html$/ ) {
        my $response = '';
        open( my $ph, '-|', 'curl', '-s', "$keywords" )
          || die "Can't open 'curl $keywords' pipe: $!";
        while (<$ph>) {
            $response = $response . $_;
        }
        close $ph;

        return magnet($response);
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
          . join( '-', @$keywords )
          . '/seeds/1/';

        my $response = '';
        open( my $ph, '-|', 'curl', '-s', "$url" )
          || die "Can't open 'curl $url' pipe: $!";
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
