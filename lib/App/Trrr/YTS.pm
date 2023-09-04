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

        print "\$keywords is:$keywords\n";

    if( $keywords =~ /^https:\/\// ){
        print "in if() \$keywords is:$keywords\n";
        my $response = HTTP::Tiny->new->get($keywords);
        die "Failed to get $keywords\n" unless $response->{success};

        print "magnet(\$response->{content}) is:" . magnet($response->{content}) . "\n";
        return magnet($response->{content}) if $response->{success};
    }
    
    my $site_string = 'year":';
    my @domain = (
        'yts.mx',
        #'yts.pm'
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
        print '$t{link} is:' . "$t{link}\n";
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
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    while(<$fh>){
	    if(/href="(magnet.+?720p.+?)"/){ $magnet{'720p'} = $1; print "\$1 is:$1\n" }
	    if(/href="(magnet.+?1080p.+?)"/){ $magnet{'1080p'} = $1; print "\$1 is:$1\n" }
	    if(/href="(magnet.+?2160p.+?)"/){ $magnet{'2160p'} = $1; print "\$1 is:$1\n" }
    }
    return $magnet{'2160p'} if exists $magnet{'2160p'};
    return $magnet{'1080p'} if exists $magnet{'1080p'};
    return $magnet{'720p'} if exists $magnet{'720p'};
}


1;
