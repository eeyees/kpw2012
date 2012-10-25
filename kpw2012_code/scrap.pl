use strict;
use warnings;

use URI;
use LWP::UserAgent;
use LWP::UserAgent::ProgressBar;
use Web::Scraper;

use Data::Dumper;

my $userAgent = LWP::UserAgent->new( agent => 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2b1) Gecko/20091014 Firefox/3.6b1 GTB5' );

#Setting for page Scrap
my $file_num = 0;             # image file number

# URL
my $categotyPage = 'http://www.bongjashop.com/shop/shopbrand.html?xcode=012&mcode=001&type=X';

my $scpLink = scraper {
	process "a", 
	'link[]' => '@href';
};

my $dc2 = scraper {
    process 'img', 
    'imglink[]' => '@src';
};

sub get_image_links {
    my $url = shift;

    my @links;  
    my $response;
    eval { $response = $scpLink->scrape( URI->new( $url ) ); };
    warn $@ if $@;

    for my $link ( @{ $response->{link} } ) {
       #http://gall.dcinside.com/list.php?id=racinggirl&no=221934&page=1&bbs=
       if ( $link =~ /cur_code=/ ) {
       	  #print $link . "\n";
          push @links, $link;
       } else {
          next;
       }
   }
   [ @links ];
}

sub download {
    my ($links) = shift;

    for my $article_link ( @{ $links } ) {
      my $response1;
      eval { $response1 = $dc2->scrape(URI->new($article_link)); };
      warn $@ if $@;

      for my $img_link ( @{$response1->{imglink}} ) {
        if ( $img_link =~ /page/ ) {
          print $img_link . "\n";

        my $file = sprintf 'img_%s.jpg', $file_num;
        open my $fh1, ">", $file or die $!;
        my $ua = LWP::UserAgent::ProgressBar->new();
        my $res;
        eval { $res = $ua->get_with_progress($img_link); };
        warn $@ if $@;
        binmode $fh1;
        print $fh1 $res->content;
        close $fh1;
        $file_num++;
      }
    }
  }
}

my $links = get_image_links($categotyPage);

download($links);

print 'End Image download!';