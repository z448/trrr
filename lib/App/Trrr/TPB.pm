package App::Trrr::TPB;

=head1 NAME

App::Trrr::TPB - PirateBay API

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( tpb );
our $VERSION = '0.01';

use strict;
use Carp;
use HTTP::Tiny;

sub tpb {
    my $keywords = shift;
    my $url = 'https://thepiratebay.org/search/' . join('%20', @$keywords) . '/0/99/0';

    my $response = HTTP::Tiny->new->get( $url );
    croak "Failed to get $url\n" unless $response->{success};
     
    my $category = 0;
    my( @item, %t, $leechs, ) = ();
    open(my $fh,"<",\$response->{content}) || die "cant open response $!";
    while(<$fh>){
            $t{title} = $_ and $t{title} =~ s/(.*?title\=\"Details for )(.*?)(\".*)/$2/ if /detName/;
            $t{magnet} = $_ and $t{magnet} =~ s/(\<a href\=\")(magnet.*?)(\".*)/$2/  if /\<a href\=\"magnet/;
            $t{size} = $_ and $t{size} =~ s/(.*?)(Size.*?\ )(.*?)(\&nbsp\;)(.)(.*)/$3$5/ if /Size.*?\ /;

        if(/<td align="right">/){  
            unless($leechs){
                $t{seeds} = $_; $t{seeds} =~ s/(.*?<td align="right">)([0-9]+)(<.*)/$2/; $leechs = 1;
            } else { $t{leechs} = $_; $t{leechs} =~ s/(.*?<td align="right">)([0-9]+)(<.*)/$2/; $leechs = 0 }
        }
        if(/More from this category/){
            if($category == 0){
                $t{category} = $_ and $t{category} =~ s/(.*category\"\>)(.*?)(\<.*)/$2/;
                chomp($t{magnet}, $t{title}, $t{size}, $t{category}, $t{seeds}, $t{leechs});
                push @item, {%t};
                $category = 1;
            } else { $category = 0 }
        }
    }
    return \@item;
}

1;
