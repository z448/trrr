package App::Trrr::YTS;

=head1 NAME

App::Trrr::YTS

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( yts );
our $VERSION = '0.01';

use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;


sub yts {
    my $keywords = shift;

    if( $keywords =~ /^https:\/\// ){
        my $response = HTTP::Tiny->new->get($keywords);
        die "Failed to get $keywords\n" unless $response->{success};
        return magnet($response->{content}) if $response->{success};
    }
    
    my $site_string = 'year":';
    my @domain = (
        'yts.mx',
        'yts.pm'
    );

    for( @domain ){
	my $url = 'https://' . $_ . '/ajax/search?query=' . join('%20', @$keywords);
	my $response = HTTP::Tiny->new->get($url);

    unless($response->{content} =~ /$site_string/){
        die "could not connect to any of following domains:\n" . join("\n", @domain) if $_ eq $domain[$#domain];
        next;
    }
	return results($response->{content}, $_) if $response->{success};
    }
}


sub results {
    my( $content, $domain ) = @_;
     
    $content = decode_json($content);

    my( @item, %t ) = ();
    for(@{$content->{data}}){
	    $t{api} = 'yts';
	    $t{domain} = $domain;
	    $t{link} = $_->{url};
        $t{link} = 'https:' . $t{link} if $domain eq 'yts.pm';
        $t{title} = $_->{title};
	    $t{category} = 'Movies';
	    $t{year} = $_->{year};
	    $t{size} = '?';
	    $t{seeds} = 1;
	    $t{leechs} = '?';
	    $t{uploader} = '?';
	    push @item, {%t};
    }
    return \@item;
}

sub magnet {
    my $content = shift;    
    
    my %magnet = ();
    my %in = ( '720p' => 0, '1080p' => 0, '2160p' => 0);
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    while(<$fh>){
        if(/<div class="modal-quality" id="modal-quality-720p/){ $in{'720p'} = 1 }
        if(/<div class="modal-quality" id="modal-quality-1080p/){ $in{'1080p'} = 1 }
        if(/<div class="modal-quality" id="modal-quality-2160p/){ $in{'2160p'} = 1 }

	    if(/href="(magnet:\?.+?)"/ and $in{'720p'}){
            $magnet{'720p'} = $1;
            $in{'720p'} = 0;
        }

	    if(/href="(magnet:\?.+?)"/ and $in{'1080p'}){
            $magnet{'1080p'} = $1;
            $in{'1080p'} = 0;
        }
	    
        if(/href="(magnet:\?.+?)"/ and $in{'2160p'}){
            $magnet{'2160p'} = $1;
            $in{'2160p'} = 0;
        }
    }
    return $magnet{'2160p'} if exists $magnet{'2160p'};
    return $magnet{'1080p'} if exists $magnet{'1080p'};
    return $magnet{'720p'} if exists $magnet{'720p'};
}


1;
