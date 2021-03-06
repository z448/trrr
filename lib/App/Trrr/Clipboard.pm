package App::Trrr::Clipboard;

@ISA = qw(Exporter);
@EXPORT_OK = qw( clip );
our $VERSION = '0.03';

use warnings;
use strict;
use feature 'say';;

sub os {
    open my $pipe,"-|",'uname -a';
    while(<$pipe>){
        if(/iPhone/){ return 'iPhone' }
        else { return $^O }
    }
}

my $os = os();

sub tool {
    my $tool = {
        linux   => [ 'xsel', 'xclip' ],
        iPhone	=> [ '. ;which perldoc -l Mac::PropertyList' ],
        darwin  => [ 'pbpaste', 'pbcopy' ],
        msys    => [ '/dev/clipboard' ],
    };
    for( @{$tool->{$os}} ){ return $_ if `which $_` }
}

sub clip {
    my $tool = tool();
    if( $tool =~/PropertyList/ ){
        my $clip = ios_clip();
        return $clip 
    }
    my $string = shift || undef;
    unless( $string ){ 
        $tool = "$tool -o" if $tool eq 'xclip';
        chomp(my $clip = `$tool`);
        return $clip;
    } else { return system("echo $string | $tool") }
};

# On iOS the clipboard functionality needs Mac::PropertyList and 'pbpaste' utillity
sub ios_clip {
       my( $data )= ();
       my $c = '/private/var/mobile/Library/Caches/com.apple.UIKit.pboard/pasteboardDB';
       {
           local $/;
           open(my $fh,"<",$c) || die "cant open $c: $!";
           $data = <$fh>; close $fh;
       }
       my $load = eval {
          require Mac::PropertyList;
          Mac::PropertyList->import();
          1;
      };

       unless($load){ die "cant load MacPropertylist" }
       else {
           my $plist = Mac::PropertyList::parse_plist( $data );
           for(@{$plist}){
               my $s = $_->as_perl;
               unless($s eq 1){          
                   if($s->{bundle} eq 'com.apple.UIKit.pboard'){
                       for(@{$s->{items}->{mobile}}){
                          my %hash = %{$_};
                          for my $h(keys %hash){
                               return $hash{$h} if $h eq 'public.text';
                               return $hash{$h} if $h eq 'public.utf8-plain-text';
                           }
                       }
                   }
               }
           }
       }
}

1;








=head1 create clipboard

my $c = clip();

=head1 read from clipboard

print $c->();

=head1 write to clipboard

#print $c->('text')

=cut
