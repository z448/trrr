package App::Trrr::X137;

=head1 NAME

App::Trrr::X137

=cut

@ISA = qw(Exporter);
@EXPORT_OK = qw( x137 );
our $VERSION = '0.01';

use strict;
use warnings;
use HTTP::Tiny;
use Time::HiRes qw(gettimeofday);
use Data::Dumper;

sub x137 {
    my $keywords = shift;
    if( $keywords =~ /\/$/ ){
        # it's comming from get_torrent() and you need to return magnet link
        my $response = HTTP::Tiny->new->get($keywords);
        die "Failed to get $keywords\n" unless $response->{success};
        return magnet($response->{content}) if $response->{success};
    }

    my @domain = ( '1337x.to','1337x.april1424.workers.dev','1337x.resourcekey.workers.dev','1337x.chatgpts1.workers.dev','1337x.sharingpurposes.workers.dev','1337x.cloudflare-stream.workers.dev','1337x.b-f.workers.dev','1337x.b-h.workers.dev','1337x.b-i.workers.dev','1337x.b-j.workers.dev','1337x.b-l.workers.dev','1337x.b-m.workers.dev','1337x.b-n.workers.dev','1337x.b-o.workers.dev','1337x.b-p.workers.dev','1337x.a-s.workers.dev','1337x.b-q.workers.dev','1337x.b-w.workers.dev','1337x.b-v.workers.dev','1337x.b-s.workers.dev','1337x.b-r.workers.dev','1337x.chennaicdn.workers.dev','1337x.northkorea.workers.dev','1337x.southkoreacdn.workers.dev','1337x.jammu.workers.dev','1337x.a-t.workers.dev','1337x.kashmircdn.workers.dev','1337x.amazingspiderman.workers.dev','1337x.louislitt.workers.dev','1337x.harveyspector.workers.dev','1337x.mikeross.workers.dev','1337x.donnapaulson.workers.dev','1337x.a-u.workers.dev','1337x.a-v.workers.dev','1337x.a-w.workers.dev','1337x.a-y.workers.dev','1337x.b-a.workers.dev','1337x.b-c.workers.dev','1337x.antarctica.workers.dev','1337x.bhadoo786.workers.dev','1337x.cdn-8.workers.dev','1337x.europecdn.workers.dev','1337x.indiacdn.workers.dev','1337x.pakistancdn.workers.dev','1337x.spstream1.workers.dev','1337x.cdn-7.workers.dev','1337x.indiadownloadserver3.workers.dev','1337x.piya.workers.dev','1337x.megha.workers.dev','1337x.patrickjane.workers.dev','1337x.i7cpu.workers.dev','1337x.lordshiva.workers.dev','1337x.hashamsterdam.workers.dev','1337x.hashantonio.workers.dev','1337x.hashatlanta.workers.dev','1337x.hashaustin.workers.dev','1337x.hashberlin.workers.dev','1337x.hashbollywood.workers.dev','1337x.hashboston.workers.dev','1337x.hashbradpitt.workers.dev','1337x.hashbrooklyn.workers.dev','1337x.hashcaitlynjenner.workers.dev','1337x.hashchicago.workers.dev','1337x.hashchristophernolan.workers.dev','1337x.hashdavegrohl.workers.dev','1337x.hashdisney.workers.dev','1337x.hashelonmusk.workers.dev','1337x.hashemmawatson.workers.dev','1337x.hashfrance.workers.dev','1337x.hashfranksinatr.workers.dev','1337x.hashgabrielgarciamarquez.workers.dev','1337x.hashhawaii.workers.dev','1337x.hashhollywood.workers.dev','1337x.hashindia.workers.dev','1337x.hashistanbul.workers.dev','1337x.hashjasonstatham.workers.dev','1337x.hashjenniferlawrence.workers.dev','1337x.hashlondon.workers.dev','1337x.hashlosangeles.workers.dev','1337x.hashmumbai.workers.dev','1337x.hashnewyork.workers.dev','1337x.hashparis.workers.dev','1337x.hashqueenelizabeth.workers.dev','1337x.hashrome.workers.dev','1337x.hashsanfrancisco.workers.dev','1337x.hashseattle.workers.dev','1337x.hashsydney.workers.dev','1337x.hashtaylorswift.workers.dev','1337x.hashtokyo.workers.dev','1337x.hashtoronto.workers.dev','1337x.hashwashingtondc.workers.dev','1337x.hashwillsmith.workers.dev','1337x.hashaaliyah.workers.dev','1337x.hashabrahamlincoln.workers.dev','1337x.hashadele.workers.dev','1337x.hashadrienbrody.workers.dev','1337x.hashaishwaryarai.workers.dev','1337x.hashalberteinstein.workers.dev','1337x.hashalfredhitchcock.workers.dev','1337x.hashangelababy.workers.dev','1337x.hashangelinajolie.workers.dev','1337x.hashanniehall.workers.dev','1337x.hasharnoldschwarzenegger.workers.dev','1337x.hasharthurmiller.workers.dev','1337x.hashashleytisdale.workers.dev','1337x.hashavamax.workers.dev','1337x.hashbenaffleck.workers.dev','1337x.hashbeyonce.workers.dev','1337x.hashbillclinton.workers.dev','1337x.hashblakelively.workers.dev','1337x.hashbollywoods.workers.dev','1337x.hashbradpitts.workers.dev','1337x.hashbryancranston.workers.dev','1337x.hashbrunomars.workers.dev','1337x.hashcaitlynjenners.workers.dev','1337x.hashcamerondiaz.workers.dev','1337x.hashcarrieunderwood.workers.dev','1337x.hashcatherinezetajones.workers.dev','1337x.hashcharliechaplin.workers.dev','1337x.hashcher.workers.dev','1337x.hashchristianbale.workers.dev','1337x.hashcristianoronaldo.workers.dev','1337x.hashdavegrohls.workers.dev','1337x.hashdemilovato.workers.dev','1337x.hashdwaynejohnson.workers.dev','1337x.hashelonmusks.workers.dev','1337x.hashemmawatsons.workers.dev','1337x.hasheminem.workers.dev','1337x.hasheltonjohn.workers.dev','1337x.hashelizabethtaylor.workers.dev','1337x.hashemilyblunt.workers.dev','1337x.hashfranksinatrs.workers.dev','1337x.hashfreddiemercury.workers.dev','1337x.hashgeorgeclooney.workers.dev','1337x.hashgeorgewashington.workers.dev','1337x.hashgigihadidbhadoo.workers.dev','1337x.hashgretathumberg.workers.dev','1337x.hashhalleberry.workers.dev','1337x.hashharrystyles.workers.dev','1337x.hashheathledger.workers.dev','1337x.hashhillaryclinton.workers.dev','1337x.hashhindubhadoo.workers.dev','1337x.hashhollywoods.workers.dev','1337x.hashhowiemandel.workers.dev','1337x.hashireneadler.workers.dev','1337x.hashjadensmith.workers.dev','1337x.hashjasonstathams.workers.dev','1337x.hashjenniferlopez.workers.dev','1337x.hashjennyslate.workers.dev','1337x.hashjenniferlawrences.workers.dev','1337x.hashjimcarey.workers.dev','1337x.hashjustinbieber.workers.dev','1337x.hashkeanureeves.workers.dev','1337x.hashkendalljenner.workers.dev','1337x.hashkimkardashian.workers.dev','1337x.hashkyliejenner.workers.dev','1337x.hashladygaga.workers.dev','1337x.hashleonardodicaprio.workers.dev','1337x.hashliamhemsworth.workers.dev','1337x.hashlindsaylohan.workers.dev','1337x.hashmerylstreep.workers.dev','1337x.hashmichaeljackson.workers.dev','1337x.hashmichelleobama.workers.dev','1337x.hashmileycyrus.workers.dev','1337x.hashmonicabellucci.workers.dev','1337x.hashmorganfreeman.workers.dev','1337x.hashneilarmstrong.workers.dev','1337x.hashoprahwinfrey.workers.dev','1337x.hashorlandobloom.workers.dev','1337x.hashpamelaanderson.workers.dev','1337x.hashparishilton.workers.dev','1337x.hashprince.workers.dev','1337x.hashqueenelizabethii.workers.dev','1337x.hashrachelmcadams.workers.dev','1337x.hashrobertdowneyjr.workers.dev','1337x.hashrobinwilliams.workers.dev','1337x.hashryanreynolds.workers.dev','1337x.hashsalmahayek.workers.dev','1337x.hashscarlettjohansson.workers.dev','1337x.hashserenawilliams.workers.dev','1337x.hashstevejobs.workers.dev','1337x.hashstevenspielberg.workers.dev','1337x.hashtaylorswifts.workers.dev','1337x.hashtomcruise.workers.dev','1337x.hashtomhanks.workers.dev','1337x.hashtravisbarker.workers.dev','1337x.hashvladimirputin.workers.dev','1337x.hashwaynerooney.workers.dev','1337x.hashwillsmiths.workers.dev','1337x.hashwizkhalifa.workers.dev','1337x.hashyahyaabdulmateeniibbhadoo.workers.dev','1337x.hashzaynmalik.workers.dev','1337x.hashaaron.workers.dev','1337x.hasharthur.workers.dev','1337x.hashashley.workers.dev','1337x.hashava.workers.dev','1337x.hashblake.workers.dev','1337x.hashbrandon.workers.dev','1337x.hashbryan.workers.dev','1337x.hashcaitlin.workers.dev','1337x.hashcameron.workers.dev','1337x.hashcarrie.workers.dev' );

    my $url;
    my $time = join('', gettimeofday);
    $time = substr($time, 0, -3);

    for( @domain ){
	if(/1337x\.to/){
	    $url = 'https://' . $_ . '/sort-search/' . join('%20', @$keywords) . '/seeders/desc/1/';
	} elsif(/^1337x\..+workers\.dev$/) {
	   #https://1337x.hashheathledger.workers.dev/1691817304364/srch?search=pulp+fiction
	    $url = 'https://' . $_ . "/$time/" . 'srch?search=' . join('%20', @$keywords);
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
    my %in = ( table => 0 );
    $t{api} = 'x137';
    $t{domain} = $domain;
    $t{category} = '?';
    open(my $fh,'<', \$content) || die "cant open \$content: $!";
    while(<$fh>){
	    $in{table} = 1 if /^<table class="table-list table table-responsive table-striped">$/;
	    $in{table} = 0 if /<\/table>/;

	    #$in{row} = 1 if /^<td class="coll-1 name"><a href/ and $in{table};
	    #$in{row} = 0 if /^<\/tr>$/;

	    if( $t{domain} eq '1337x.to' ){
	        if(/<td class="coll-1 name"><a href.+ href="(.+?)">(.+?)<\/a><\/td>$/){
		    $t{link} = 'https://' . $t{domain} . $1;
		    $t{title} = $2;
	        }
    	    } else { 
		if(/^<td class="coll-1 name"><a href=".+?<\/i><\/a><a href="\/\/(.+?)">(.+?)<\/a><\/td>$/){
		    $t{link} = 'https://' . $1;
		    $t{title} = $2;
		}
	    }

	    if(/^<td class="coll-2 seeds">(\d+?)<\/td>$/){
	        $t{seeds} = $1;
	    }

	    if(/^<td class="coll-3 leeches">(\d+?)<\/td>$/){
	        $t{leechs} = $1;
	    }

	    if(/^<td class="coll-date">(.+?)<\/td>$/){
	        $t{added} = $1;
	        $t{added} =~ s/'//g;
	    }

	    if(/^<td class="coll-4 size mob-uploader">(.+?)<span/){
	        $t{size} = $1;
	    }

	    if(/^<td class="coll-5 uploader"><a href="\/.+?">(.+?)<\/a><\/td>$/){
	        $t{uploader} = $1;
	    }
	    
	    if(/^<\/tr>$/){
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
	if(/href="(magnet:.+?)"/){
	    my $magnet = $1;
	    return $magnet;
	}
    }
}


1;
