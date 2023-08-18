package App::Trrr::EXT;

=head1 NAME

App::Trrr::EXT

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( ext );
our $VERSION = '0.01';

use strict;
use warnings;
use HTTP::Tiny;

sub ext {
    my $keywords = shift;
    my @domain = (
	'extratorrents.it',
	'extratorrent.st'
    );

    my $url;
    for( @domain ){
	if(/extratorrents\.it/){
	    $url = 'https://' . $_ . '/search/' . '?search=' . join('%20', @$keywords) . '&s_cat=&pp=&srt=seeds&order=desc';
        } elsif(/extratorrent\.st/){
	    $url = 'https://' . $_ . '/search/' . '?srt=seeds&order=desc&search=' . join('%20', @$keywords) . '&new=1&x=0&y=0';
	}

	my $response = HTTP::Tiny->new->get($url);
	if( !($response->{success}) and ($_ eq $domain[$#domain]) ){ die "non of the domains works:\n" . join("\n", @domain) }
	next unless $response->{success};
	return results($response->{content}, $_) if $response->{success};
    }
}


sub results {
    my( $content, $domain ) = @_;

    my( @item, %t ) = ();
    
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    
    my %in = ( table => 0, uploader => 0 );
    while(<$fh>){
	$in{table} = 1 if /^<tr class="tl[rz]">$/;
	$in{table} = 0 if /^<\/tr>$/;

	if(/<a href="(magnet:.+?)" title/ and $in{table}){
	    $t{magnet} = $1;
	}

	if(/^<img src="\/.+?\.html" title="view (.+?) torrent"/){
	    $t{title} = $1;
	    $t{api} = 'ext';
	}

	if(/^<a href="\/category.+?title="Browse (.+?)"><img/ and $in{table}){
	    $t{category} = $1;
	    $t{category} =~ s/\// > /g;
	}

	if(/^<div id class="usrm"><\/div>$/){ $in{uploader} = 1 }
	if(/^<a href="javascript:;" style="color:#615434;">(.+?)<\/a>$/ and $in{table} and $in{uploader}){
	    $t{uploader} = $1;
	    $in{uploader} = 0;
	}

	if(/^<td>([a-z0-9\ ]+?)<\/td>$/ and $in{table}){
	    $t{added} = $1;
	    $t{added} =~ s/ mo$/ months/;
	}

	if(/^<td>([A-Z0-9\ \.]+?)<\/td>$/ and $in{table}){
	    $t{size} = $1;
	    $t{size} =~ s/B/b/;
	}


	if(/^<td class="s[yn]">(.+?)<\/td>$/ and $in{table}){
	    $t{seeds} = $1;
	    $t{seeds} =~ s/---/0/;
	}

	if(/^<td class="l[yn]">(.+?)<\/td>$/ and $in{table}){
	    $t{leechs} = $1;
	    $t{leechs} =~ s/^---$/0/;
	    push @item, {%t};
	}

    }
    close $fh;
    return \@item;
}


1;
