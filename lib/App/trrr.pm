package App::trrr;

=head1 NAME

App::trrr;

=cut

@ISA       = qw(Exporter);
@EXPORT_OK = qw( get_content );
our $VERSION = '0.01';

use strict;
use warnings;


sub dep{
    my $dep = shift;
    my $bin;
    my @path = split(':', $ENV{PATH});
    for(@path){
        $bin = "$_/$dep" if -f "$_/$dep";
    }
    return unless $bin;

    open( my $fileph, "-|", 'file', $bin );
    while(<$fileph>){
        chomp;
        $bin = "perl $bin" if /Perl/;
    }
    return $bin;
}

sub get_content {
    my $url = shift;
    #my $content = '';
    my $content = '';
    my $ph;
    my $cacert = "$ENV{HOME}/cacert.pem" if -f "$ENV{HOME}/cacert.pem";
    my $ua = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1";
    
    if( dep('curl') ){
        if($cacert){
            open( $ph, '-|', 'curl', "--cacert", "$cacert", "--user-agent", "$ua", '-s', "$url" ) || die "Cant't open 'curl $url' pipe: $!";
        } else {
            open( $ph, '-|', 'curl', "--user-agent", "$ua", '-s', "$url" ) || die "Cant't open 'curl $url' pipe: $!";
        }   
        while (<$ph>) {
            $content = $content . $_;
        }
        close $ph;
    } elsif( dep('wget') ){
        if($cacert){
            open( $ph, '-|', 'wget', "-q", "-O", "-", "--ca-certificate=$cacert", '-U', "$ua", "$url" ) || die "Cant't open 'curl $url' pipe: $!";
        } else {
            open( $ph, '-|', 'wget', "-q", "-O", "-", '-U', "$ua", "$url" ) || die "Cant't open 'curl $url' pipe: $!";
        }   
        while (<$ph>) {
            $content = $content . $_;
        }
        close $ph;
    } else {
        eval {
            #require HTTP::Tiny;
            #HTTP::Tiny->import();
            #1;
            use HTTP::Tiny;
        };
        my $response = '';
        if($cacert){
            $response = HTTP::Tiny->new( SSL_options => { SSL_ca_file => $cacert, agent => $ua } )->get($url);
            die "no \$content" unless $content;
        } else {
            $response = HTTP::Tiny->new( SSL_options => { agent => $ua } )->get($url);
            die "no \$content" unless $content;
        }
        $content = $response->{content};
    }

    return $content;
} 


1;
