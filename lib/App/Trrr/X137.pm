package App::Trrr::X137;

=head1 NAME

App::Trrr::X137

=cut

@ISA       = qw(Exporter);
@EXPORT_OK = qw( x137 );
our $VERSION = '0.02';

use strict;
use warnings;
use Time::HiRes qw(gettimeofday);

sub x137 {
    my $keywords = shift;
    if ( $keywords =~ /^https:.+\/$/ ) {
        my $response = '';
        open( my $ph, '-|', 'curl', '-s', "$keywords" )
          || die "Can't open 'curl $keywords' pipe: $!";
        while (<$ph>) {
            $response = $response . $_;
        }
        close $ph;

        return magnet($response);
    }

    my $site_string = 'seeds"';
    my @domain      = (
        '1337x.to',
        '1337x.april1424.workers.dev',
        '1337x.resourcekey.workers.dev',
        '1337x.chatgpts1.workers.dev',
        '1337x.sharingpurposes.workers.dev',
        '1337x.cloudflare-stream.workers.dev',
        '1337x.b-f.workers.dev',
        '1337x.b-h.workers.dev',
        '1337x.b-i.workers.dev',
        '1337x.b-j.workers.dev',
        '1337x.b-l.workers.dev',
        '1337x.b-m.workers.dev',
        '1337x.b-n.workers.dev',
        '1337x.b-o.workers.dev',
        '1337x.b-p.workers.dev',
        '1337x.a-s.workers.dev',
        '1337x.b-q.workers.dev',
        '1337x.b-w.workers.dev',
        '1337x.b-v.workers.dev',
        '1337x.b-s.workers.dev',
        '1337x.b-r.workers.dev',
        '1337x.chennaicdn.workers.dev',
        '1337x.northkorea.workers.dev',
        '1337x.southkoreacdn.workers.dev',
        '1337x.jammu.workers.dev',
        '1337x.a-t.workers.dev',
        '1337x.kashmircdn.workers.dev',
        '1337x.amazingspiderman.workers.dev',
        '1337x.louislitt.workers.dev',
        '1337x.harveyspector.workers.dev',
        '1337x.mikeross.workers.dev',
        '1337x.donnapaulson.workers.dev',
        '1337x.a-u.workers.dev',
        '1337x.a-v.workers.dev',
        '1337x.a-w.workers.dev',
        '1337x.a-y.workers.dev',
        '1337x.b-a.workers.dev',
        '1337x.b-c.workers.dev',
        '1337x.antarctica.workers.dev',
        '1337x.bhadoo786.workers.dev',
        '1337x.cdn-8.workers.dev',
        '1337x.europecdn.workers.dev',
        '1337x.indiacdn.workers.dev',
        '1337x.pakistancdn.workers.dev',
        '1337x.spstream1.workers.dev',
        '1337x.cdn-7.workers.dev',
        '1337x.indiadownloadserver3.workers.dev',
        '1337x.piya.workers.dev',
        '1337x.megha.workers.dev',
        '1337x.patrickjane.workers.dev',
        '1337x.i7cpu.workers.dev',
        '1337x.lordshiva.workers.dev',
        '1337x.hashamsterdam.workers.dev',
        '1337x.hashantonio.workers.dev',
        '1337x.hashatlanta.workers.dev',
        '1337x.hashaustin.workers.dev',
        '1337x.hashberlin.workers.dev',
        '1337x.hashbollywood.workers.dev',
        '1337x.hashboston.workers.dev',
        '1337x.hashbradpitt.workers.dev',
        '1337x.hashbrooklyn.workers.dev',
        '1337x.hashcaitlynjenner.workers.dev',
        '1337x.hashchicago.workers.dev',
        '1337x.hashchristophernolan.workers.dev',
        '1337x.hashdavegrohl.workers.dev',
        '1337x.hashdisney.workers.dev',
        '1337x.hashelonmusk.workers.dev',
        '1337x.hashemmawatson.workers.dev',
        '1337x.hashfrance.workers.dev',
        '1337x.hashfranksinatr.workers.dev',
        '1337x.hashgabrielgarciamarquez.workers.dev',
        '1337x.hashhawaii.workers.dev',
        '1337x.hashhollywood.workers.dev',
        '1337x.hashindia.workers.dev',
        '1337x.hashistanbul.workers.dev',
        '1337x.hashjasonstatham.workers.dev',
        '1337x.hashjenniferlawrence.workers.dev',
        '1337x.hashlondon.workers.dev',
        '1337x.hashlosangeles.workers.dev',
        '1337x.hashmumbai.workers.dev',
        '1337x.hashnewyork.workers.dev',
        '1337x.hashparis.workers.dev',
        '1337x.hashqueenelizabeth.workers.dev',
        '1337x.hashrome.workers.dev',
        '1337x.hashsanfrancisco.workers.dev',
        '1337x.hashseattle.workers.dev',
        '1337x.hashsydney.workers.dev',
        '1337x.hashtaylorswift.workers.dev',
        '1337x.hashtokyo.workers.dev',
        '1337x.hashtoronto.workers.dev',
        '1337x.hashwashingtondc.workers.dev',
        '1337x.hashwillsmith.workers.dev',
        '1337x.hashaaliyah.workers.dev',
        '1337x.hashabrahamlincoln.workers.dev',
        '1337x.hashadele.workers.dev',
        '1337x.hashadrienbrody.workers.dev',
        '1337x.hashaishwaryarai.workers.dev',
        '1337x.hashalberteinstein.workers.dev',
        '1337x.hashalfredhitchcock.workers.dev',
        '1337x.hashangelababy.workers.dev',
        '1337x.hashangelinajolie.workers.dev',
        '1337x.hashanniehall.workers.dev',
        '1337x.hasharnoldschwarzenegger.workers.dev',
        '1337x.hasharthurmiller.workers.dev',
        '1337x.hashashleytisdale.workers.dev',
        '1337x.hashavamax.workers.dev',
        '1337x.hashbenaffleck.workers.dev',
        '1337x.hashbeyonce.workers.dev',
        '1337x.hashbillclinton.workers.dev',
        '1337x.hashblakelively.workers.dev',
        '1337x.hashbollywoods.workers.dev',
        '1337x.hashbradpitts.workers.dev',
        '1337x.hashbryancranston.workers.dev',
        '1337x.hashbrunomars.workers.dev',
        '1337x.hashcaitlynjenners.workers.dev',
        '1337x.hashcamerondiaz.workers.dev',
        '1337x.hashcarrieunderwood.workers.dev',
        '1337x.hashcatherinezetajones.workers.dev',
        '1337x.hashcharliechaplin.workers.dev',
        '1337x.hashcher.workers.dev',
        '1337x.hashchristianbale.workers.dev',
        '1337x.hashcristianoronaldo.workers.dev',
        '1337x.hashdavegrohls.workers.dev',
        '1337x.hashdemilovato.workers.dev',
        '1337x.hashdwaynejohnson.workers.dev',
        '1337x.hashelonmusks.workers.dev',
        '1337x.hashemmawatsons.workers.dev',
        '1337x.hasheminem.workers.dev',
        '1337x.hasheltonjohn.workers.dev',
        '1337x.hashelizabethtaylor.workers.dev',
        '1337x.hashemilyblunt.workers.dev',
        '1337x.hashfranksinatrs.workers.dev',
        '1337x.hashfreddiemercury.workers.dev',
        '1337x.hashgeorgeclooney.workers.dev',
        '1337x.hashgeorgewashington.workers.dev',
        '1337x.hashgigihadidbhadoo.workers.dev',
        '1337x.hashgretathumberg.workers.dev',
        '1337x.hashhalleberry.workers.dev',
        '1337x.hashharrystyles.workers.dev',
        '1337x.hashheathledger.workers.dev',
        '1337x.hashhillaryclinton.workers.dev',
        '1337x.hashhindubhadoo.workers.dev',
        '1337x.hashhollywoods.workers.dev',
        '1337x.hashhowiemandel.workers.dev',
        '1337x.hashireneadler.workers.dev',
        '1337x.hashjadensmith.workers.dev',
        '1337x.hashjasonstathams.workers.dev',
        '1337x.hashjenniferlopez.workers.dev',
        '1337x.hashjennyslate.workers.dev',
        '1337x.hashjenniferlawrences.workers.dev',
        '1337x.hashjimcarey.workers.dev',
        '1337x.hashjustinbieber.workers.dev',
        '1337x.hashkeanureeves.workers.dev',
        '1337x.hashkendalljenner.workers.dev',
        '1337x.hashkimkardashian.workers.dev',
        '1337x.hashkyliejenner.workers.dev',
        '1337x.hashladygaga.workers.dev',
        '1337x.hashleonardodicaprio.workers.dev',
        '1337x.hashliamhemsworth.workers.dev',
        '1337x.hashlindsaylohan.workers.dev',
        '1337x.hashmerylstreep.workers.dev',
        '1337x.hashmichaeljackson.workers.dev',
        '1337x.hashmichelleobama.workers.dev',
        '1337x.hashmileycyrus.workers.dev',
        '1337x.hashmonicabellucci.workers.dev',
        '1337x.hashmorganfreeman.workers.dev',
        '1337x.hashneilarmstrong.workers.dev',
        '1337x.hashoprahwinfrey.workers.dev',
        '1337x.hashorlandobloom.workers.dev',
        '1337x.hashpamelaanderson.workers.dev',
        '1337x.hashparishilton.workers.dev',
        '1337x.hashprince.workers.dev',
        '1337x.hashqueenelizabethii.workers.dev',
        '1337x.hashrachelmcadams.workers.dev',
        '1337x.hashrobertdowneyjr.workers.dev',
        '1337x.hashrobinwilliams.workers.dev',
        '1337x.hashryanreynolds.workers.dev',
        '1337x.hashsalmahayek.workers.dev',
        '1337x.hashscarlettjohansson.workers.dev',
        '1337x.hashserenawilliams.workers.dev',
        '1337x.hashstevejobs.workers.dev',
        '1337x.hashstevenspielberg.workers.dev',
        '1337x.hashtaylorswifts.workers.dev',
        '1337x.hashtomcruise.workers.dev',
        '1337x.hashtomhanks.workers.dev',
        '1337x.hashtravisbarker.workers.dev',
        '1337x.hashvladimirputin.workers.dev',
        '1337x.hashwaynerooney.workers.dev',
        '1337x.hashwillsmiths.workers.dev',
        '1337x.hashwizkhalifa.workers.dev',
        '1337x.hashyahyaabdulmateeniibbhadoo.workers.dev',
        '1337x.hashzaynmalik.workers.dev',
        '1337x.hashaaron.workers.dev',
        '1337x.hasharthur.workers.dev',
        '1337x.hashashley.workers.dev',
        '1337x.hashava.workers.dev',
        '1337x.hashblake.workers.dev',
        '1337x.hashbrandon.workers.dev',
        '1337x.hashbryan.workers.dev',
        '1337x.hashcaitlin.workers.dev',
        '1337x.hashcameron.workers.dev',
        '1337x.hashcarrie.workers.dev'
    );

    my $url;
    my $time = join( '', gettimeofday );
    $time = substr( $time, 0, -3 );

    for my $domain (@domain) {
        if ( $domain =~ /^1337x\.to$/ ) {
            $url =
                'https://'
              . $domain
              . '/sort-search/'
              . join( '%20', @$keywords )
              . '/seeders/desc/1/';
        }
        else {
            $url =
                'https://'
              . $domain
              . "/$time/"
              . 'srch?search='
              . join( '%20', @$keywords );
        }

        my $response = '';
        open( my $ph, '-|', 'curl', '-s', "$url" )
          || die "Can't open 'curl $url' pipe: $!";
        while (<$ph>) {
            $response = $response . $_;
        }
        close $ph;

        unless ( $response =~ /$site_string/ ) {
            die "Could not connect to any of following domains:\n"
              . join( "\n", @domain )
              if $domain eq $domain[$#domain];
            next;
        }
        return results( $response, $domain );
    }
}

sub results {
    my ( $content, $domain ) = @_;

    my ( @item, %t ) = ();
    my %in       = ( table => 0 );
    my %category = (
        '/sub/1/0/'  => 'Video > Erotic',
        '/sub/2/0/'  => 'Video > Movie',
        '/sub/3/0/'  => 'Video > Misc',
        '/sub/4/0/'  => 'Video > Dubs/Dual Audio',
        '/sub/5/0/'  => '?',
        '/sub/6/0/'  => 'Video > TV Series',
        '/sub/7/0/'  => 'Video > Misc',
        '/sub/8/0/'  => '?',
        '/sub/9/0/'  => 'Video > Documentary',
        '/sub/10/0/' => 'Games > PC',
        '/sub/11/0/' => 'Games > PS2',
        '/sub/12/0/' => 'Games > PSP',
        '/sub/13/0/' => 'Games > Xbox',
        '/sub/14/0/' => 'Games > Xbox360',
        '/sub/15/0/' => 'Games > PS1',
        '/sub/16/0/' => 'Games > Dreamcast',
        '/sub/17/0/' => 'Games > Misc',
        '/sub/18/0/' => 'Software > PC',
        '/sub/19/0/' => 'Software > Mac',
        '/sub/20/0/' => 'Software > Linux',
        '/sub/21/0/' => 'Software > Misc',
        '/sub/22/0/' => 'Music > MP3',
        '/sub/23/0/' => 'Music > Lossless',
        '/sub/24/0/' => 'Music > DVD',
        '/sub/25/0/' => 'Music > Video',
        '/sub/26/0/' => 'Music > Radio',
        '/sub/27/0/' => 'Music > Misc',
        '/sub/28/0/' => 'Video > Anime',
        '/sub/29/0/' => '?',
        '/sub/30/0/' => '?',
        '/sub/31/0/' => '?',
        '/sub/32/0/' => '?',
        '/sub/33/0/' => 'Emulation',
        '/sub/34/0/' => 'Tutorials',
        '/sub/35/0/' => 'Sounds',
        '/sub/36/0/' => 'E-Books',
        '/sub/37/0/' => 'Images',
        '/sub/38/0/' => 'Mobile',
        '/sub/39/0/' => 'Comics',
        '/sub/40/0/' => 'Other',
        '/sub/41/0/' => 'HD',
        '/sub/42/0/' => 'HD',
        '/sub/43/0/' => 'Games > PS3',
        '/sub/44/0/' => 'Games > Wii',
        '/sub/45/0/' => 'Games > DS',
        '/sub/46/0/' => 'Games > GameCube',
        '/sub/47/0/' => 'Software > Theme/Plugin',
        '/sub/48/0/' => 'Video > Porn',
        '/sub/49/0/' => 'Picture > Nude',
        '/sub/50/0/' => 'Magazine > Erotic',
        '/sub/51/0/' => 'Hentai',
        '/sub/52/0/' => 'Audiobook',
        '/sub/53/0/' => 'Music > MP3',
        '/sub/54/0/' => 'Video > Movie',
        '/sub/55/0/' => 'Video > MP4',
        '/sub/56/0/' => 'Software > Android',
        '/sub/57/0/' => 'Software > iOS',
        '/sub/58/0/' => 'Music > Box Set',
        '/sub/59/0/' => 'Music > Discography',
        '/sub/60/0/' => 'Music > Single',
        '/sub/61/0/' => '?',
        '/sub/62/0/' => '?',
        '/sub/63/0/' => '?',
        '/sub/64/0/' => '?',
        '/sub/65/0/' => '?',
        '/sub/66/0/' => 'Video > 3D',
        '/sub/67/0/' => 'Games > XXX',
        '/sub/68/0/' => 'Music > Concerts',
        '/sub/69/0/' => 'Music > AAC',
        '/sub/70/0/' => 'Video > HEVC/x265',
        '/sub/71/0/' => 'Video > HEVC/x265',
        '/sub/72/0/' => 'Games > 3DS',
        '/sub/73/0/' => 'Video > Bollywood',
        '/sub/74/0/' => 'Video > Cartoon',
        '/sub/75/0/' => 'Video > TV Series',
        '/sub/76/0/' => 'Video > Movies UHD',
        '/sub/77/0/' => 'Games > PS4',
        '/sub/78/0/' => 'Video > Anime',
        '/sub/79/0/' => 'Video > Anime Dubbed',
        '/sub/80/0/' => 'Video > Anime Subbed',
        '/sub/81/0/' => 'Video > Anime',
        '/sub/82/0/' => 'Games > Switch',
    );

    open( my $fh, '<', \$content ) || die "Can't open \$content: $!";
    while (<$fh>) {

        $in{table} = 1 if /^<tbody>$/;
        $in{table} = 0 if /^<\/tbody>$/;

        if ( $domain =~ /^1337x\.to$/ ) {
            if (
/^<td class="coll-1 name"><a href="(.+?)".+href="(.+?)">(.+?)<\/a>.*<\/td>$/
                and $in{table} )
            {
                $t{api}      = 'x137';
                $t{domain}   = $domain;
                $t{category} = $category{"$1"};
                $t{link}     = 'https://' . $t{domain} . $2;
                $t{title}    = $3;
            }
        }
        else {
            if (
/^<td class="coll-1 name"><a href=".+(\/sub\/\d+\/\d\/?)".+<\/i><\/a><a href="\/\/(.+?)">(.+?)<\/a><\/td>$/
                and $in{table} )
            {
                $t{api}      = 'x137';
                $t{domain}   = $domain;
                $t{category} = $category{"$1"};
                $t{link}     = 'https://' . $2;
                $t{title}    = $3;
            }
        }

        if ( /^<td class="coll-2 seeds">(\d+?)<\/td>$/ and $in{table} ) {
            $t{seeds} = $1;
        }

        if ( /^<td class="coll-3 leeches">(\d+?)<\/td>$/ and $in{table} ) {
            $t{leechs} = $1;
        }

        if ( /^<td class="coll-date">(.+?)<\/td>$/ and $in{table} ) {
            $t{added} = $1;
            $t{added} =~ s/'//g;
        }

        if ( /^<td class="coll-4 size mob.+?">(.+?)<span/ and $in{table} ) {
            $t{size} = $1;
        }

        if ( /^<td class="coll-5 .+?"><a href="\/.+?">(.+?)<\/a><\/td>$/
            and $in{table} )
        {
            $t{uploader} = $1;
        }

        if ( /^<\/tr>$/ and $in{table} ) {
            push @item, {%t};
        }
    }
    close $fh;
    return \@item;
}

sub magnet {
    my $content = shift;

    open( my $fh, '<', \$content ) || die "Can't open \$content: $!";
    while (<$fh>) {
        if (/href="(magnet:.+?)"/) {
            my $magnet = $1;
            return $magnet;
        }
    }
}

1;
