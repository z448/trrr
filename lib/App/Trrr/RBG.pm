package App::Trrr::RBG;

=head1 NAME

App::Trrr::RBG

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( rbg );
our $VERSION = '0.01';

use strict;
use warnings;
use HTTP::Tiny;

sub rbg {
    my $keywords = shift;
    if( $keywords =~ /\.html$/ ){
        my $response = HTTP::Tiny->new->get($keywords);
        die "Failed to get $keywords\n" unless $response->{success};
        return magnet($response->{content}) if $response->{success};
    }

    my @domain = (
	    'rargb.to',
	    'www.rarbgproxy.to',
	    'www2.rarbggo.to',
	    'rarbg.unblockninja.com'
    );

    for( @domain ){
        my $url = 'https://' . $_ . '/search/?search=' . join('%20', @$keywords) . '&order=seeders&by=DESC';
	my $response = HTTP::Tiny->new->get($url);
	if( !($response->{success}) and ($_ eq $domain[$#domain]) ){ die "non of the domains works:\n" . join("\n", @domain) }
	next unless $response->{success};
	return results($response->{content}, $_) if $response->{success};
    }
}


sub results {
    my( $content, $domain ) = @_;

    my $in_table = 0;
    my( @item, %t ) = ();
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    while(<$fh>){
	$in_table = 1 if /table.+lista2t/;
	$in_table = 0 if /<\/table>/;

	if(/ href="(.+)?" title="(.+)?"/ and $in_table == 1){
	    $t{api} = 'rbg';
	    $t{domain} = $domain;
	    $t{link} = $1; $t{link} = 'https://' . $domain . $t{link};
	    $t{title} = $2;
    	} 

	if(/a><a href="\/(.+)\/(.+)\/"/ and $in_table == 1){
	    $t{category} = $1 . ' > ' . $2;
	}

	if(/100px.+>(.+)</){
	    $t{size} = $1; $t{size} =~ s/ //; $t{size} =~ s/B/b/;
	}

	if(/150px.+?>(\d\d\d\d.+)?</){
	    $t{added} = $1;
	}

	if(/"50px.+color.+?>(\d+)</){
	    $t{seeds} = $1;
        }   

	if(/"50px.+lista">(\d+)</){
	    $t{leechs} = $1;
	}

	if(/<td align="center" class="lista">(.*)<\/td>\r/){
	    $t{uploader} = $1;
            push @item, {%t};
        }
    }
    close $fh;
    return \@item;
}


sub magnet {
    my $content = shift;
    
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    while(<$fh>){
	if(/href="(magnet.+)"/){
	    my $magnet = $1;
            $magnet =~ s/ /%20/g;
            $magnet =~ s/"/%22/g;
	    return $magnet;
	}
    }
}


1;
