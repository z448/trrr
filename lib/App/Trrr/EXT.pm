package App::Trrr::EXT;

=head1 NAME

App::Trrr::EXT

=cut

@ISA       = qw(Exporter);
@EXPORT_OK = qw( ext );
our $VERSION = '0.02';

use strict;
use warnings;

sub ext {
    my $keywords = shift;
    my @domain   = ( 'extratorrents.it', 'extratorrent.st' );

    my $url;
    my $site_string = 'seeds">S';
    for my $domain (@domain) {
        if ( $domain =~ /^extratorrents\.it$/ ) {
            $url =
                'https://'
              . $domain
              . '/search/'
              . '?search='
              . join( '%20', @$keywords )
              . '&s_cat=&pp=&srt=seeds&order=desc';
        }
        elsif ( $domain =~ /^extratorrent\.st$/ ) {
            $url =
                'https://'
              . $domain
              . '/search/'
              . '?srt=seeds&order=desc&search='
              . join( '%20', @$keywords )
              . '&new=1&x=0&y=0';
        }

        my $response = '';
        open( my $ph, '-|', 'curl', '-s', "$url" )
          || die "Cant't open 'curl $url' pipe: $!";
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

    my ( @item, %t ) = ();

    open( my $fh, '<', \$content ) || die "Can't open \$content: $!";
    my %in = ( table => 0, uploader => 0 );
    while (<$fh>) {
        $in{table} = 1 if /^<tr class="tl[rz]">$/;
        $in{table} = 0 if /^<\/tr>$/;

        if ( /<a href="(magnet:.+?)" title/ and $in{table} ) {
            $t{magnet} = $1;
        }

        if (/^<img src="\/.+?\.html" title="view (.+?) torrent"/) {
            $t{title} = $1;
            $t{api}   = 'ext';
        }

        if ( /^<a href="\/category.+?title="Browse (.+?)"><img/ and $in{table} )
        {
            $t{category} = $1;
            $t{category} =~ s/\// > /g;
        }

        if (/^<div id class="usrm"><\/div>$/) { $in{uploader} = 1 }
        if (    /^<a href="javascript:;" style="color:#615434;">(.+?)<\/a>$/
            and $in{table}
            and $in{uploader} )
        {
            $t{uploader}  = $1;
            $in{uploader} = 0;
        }

        if ( /^<td>([a-z0-9\ ]+?)<\/td>$/ and $in{table} ) {
            $t{added} = $1;
            $t{added} =~ s/ mo$/ months/;
        }

        if ( /^<td>([A-Z0-9\ \.]+?)<\/td>$/ and $in{table} ) {
            $t{size} = $1;
            $t{size} =~ s/B/b/;
        }

        if ( /^<td class="s[yn]">(.+?)<\/td>$/ and $in{table} ) {
            $t{seeds} = $1;
            $t{seeds} =~ s/---/0/;
        }

        if ( /^<td class="l[yn]">(.+?)<\/td>$/ and $in{table} ) {
            $t{leechs} = $1;
            $t{leechs} =~ s/^---$/0/;
            push @item, {%t};
        }

    }
    close $fh;
    return \@item;
}

1;
