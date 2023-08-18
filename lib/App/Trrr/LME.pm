package App::Trrr::LME;

=head1 NAME

App::Trrr::LME

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( lme );
our $VERSION = '0.01';

use strict;
use warnings;
use HTTP::Tiny;

sub lme {
    my $keywords = shift;
    if( $keywords =~ /\.html$/ ){
        my $response = HTTP::Tiny->new->get($keywords);
        die "Failed to get $keywords\n" unless $response->{success};
        return magnet($response->{content}) if $response->{success};
    }

    my @domain = ( 
	    'www.limetorrents.to'
    );

    my $url;
    for( @domain ){
	my $url = 'https://' . $_ . '/search/all/' . join('-', @$keywords) . '/seeds/1/';
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
    while(<$fh>){
	if(/^<\/tr><tr bgcolor="#F4F4F4"><td class="tdleft">(.+)/){
	    my $line = $1;
  	    $line =~ s/<tr bgcolor=("#FFFFFF"|"#F4F4F4")><td class="/\n/g;
	    open(my $onefh, '<', \$line) || die "can't open \$1: $!";
	    while(<$onefh>){
	        if(/csprite_dl14"><\/a><a href="(\/.+?)">(.+?)<\/a><\/div><div class="tt-options"><\/div><\/td><td class="tdnormal">(.+) - in (.+?)<\/a><\/td><td class="tdnormal">(.+?)<\/td><td class="tdseed">(.+?)<\/td><td class="tdleech">(.+?)<.+/){
		    $t{api} = 'lme';
		    $t{domain} = $domain;
		    $t{link} = 'https://' . $t{domain} . $1;
		    $t{title} = $2;
		    $t{added} = $3;
		    $t{category} = $4;
		    $t{size} = $5;
		    $t{seeds} = $6;
		    $t{leechs} = $7;
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
    
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    while(<$fh>){
	if(/href="(magnet:.+?)"/){
	    my $magnet = $1;
	    return $magnet;
	}
    }
}


1;
