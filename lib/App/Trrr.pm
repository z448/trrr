package App::Trrr;

=head1 NAME

App::Trrr - search torrents

=cut

@ISA = qw(Exporter);
@EXPORT = qw( open_app );
our $VERSION = '0.08';

use strict;

# check if xdg-open utility is installed to use on linux
my $check_xdg = sub {
    my $xdg = shift;
    $xdg = `which $xdg` and chomp $xdg;
    if( $xdg =~ /\/xdg-open/ ){
        return $xdg
        } else { return "echo 'xdg-open command not found, cant open '" }
};

sub open_app {
    my $url = shift;
    my $os = {  osx     => 'open',
                ios     => 'echo',
                ubuntu  => 'xdg-open',
                linux   => 'xdg-open',
    };
    if($^O eq 'MSWin32' or $^O eq 'msys'){ system("$url"); return }
    open my $pipe,"-|",'uname -a';
    while(<$pipe>){
        if(/iPhone/){ system("$os->{ios} '$url   ' | pbcopy") }
        elsif(/Darwin/){ system("$os->{osx} $url") }
        elsif(/Ubuntu/){ system("$os->{ubuntu} $url") }
        elsif(/Linux/){ my $open = $check_xdg->($os->{linux}); system("$open $url") }
    }
};

1;

=head1 DESCRIPTION
    
CLI tool to search torrents. Results are sorted by number of seeders and each is mapped to key. Pressing the key with assigned letter will open magnet link in your default client. On iOS, magnet link is placed into clipboard.

=head1 USAGE
    
Search with as many parameters as needed. Uses KAT by default, C<-P> will switch to TPB.

=over 10

C<trrr keyword1 keyword2 keywordN>

C<trrr keyword1 keyword2 keywordN -P>

=back

_

On Linux, start it without any parameter and it'll use clipboard content as keywords. ( needs 'xclip' or 'xsel' to be installed )

=over 10

C<trrr>

=back

_

Limit results which have at least 100 seeders.

=over 10

C<trrr keyword1 keyword2 keywordN -100>

=back

_

To get another torrent from previous search add key as parameter. This is mandatory on Windows running 'Git/Bash for Windows' where you have to specify key on CLI upfront.

=over 10

C<trrr keyword1 keyword2 keywordN -b>

=back

_

See this perdoc.

=over 10

C<trrr -h>

=back

=head1 AUTHOR

Zdenek Bohunek. <zdenek@cpan.org>

App::Trr::HotKey is taken from StackOverflow post by brian d foy

=head1 COPYRIGHT AND LICENSE

Copyright 2016 by Zdenek Bohunek

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
