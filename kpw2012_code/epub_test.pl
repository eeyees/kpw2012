use strict;
use warnings;
use EBook::EPUB;
use Path::Class;
use Image::Info qw(image_info dim);
use Data::Section::Simple;
use File::Temp;
use Image::Size;

my $title = 'Girls';
my $author = '@eeyees';
my $epub = EBook::EPUB->new;
$epub->add_title($title);
$epub->add_author($author);
$epub->add_language('ko');
$epub->add_identifier('9999999999', 'ISBN');

my $dir = Path::Class::Dir->new('.');
my $idx = 0;
while(my $elm = $dir->next) {
  next unless $elm =~ /(jpg|png)$/;
  print $elm."\n";
  #my $img_info = image_info($elm);
  #my($w, $h) = dim($img_info);
  my($w, $h) = dim($elm);
  my $image_path = 'image/'.$elm->basename;
  my $id = $epub->copy_image($elm, $image_path, 'image/jpg');
  my $html = generate_html({
    title => $title,
    author => $author,
    fileid => $id,
    img => $image_path,
    img_width => $w,
    img_height => $h,
  });
  my ($fh, $tmpfile) = File::Temp::tempfile();
  print $fh $html;
  close $fh;
  $epub->copy_xhtml($tmpfile, (sprintf 'page%04d.html', ++$idx));
}

$epub->pack_zip('myebook.epub');

sub generate_html {
  my $obj = shift;

  my $html = Data::Section::Simple::get_data_section('page.html');
  for my $key (keys %{ $obj }) {
    $html =~ s!<% $key %>!$obj->{$key}!g;
  }
  $html;
}

__DATA__

@@ page.html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
 <html xmlns="http://www.w3.org/1999/xhtml">
 <head>
 <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
 <meta name="title" content="<% title %>"/>
 <meta name="creator" content="<% author %>"/>
 <title><% fileid %></title>
 </head>
 <body style="margin: 0">
 <table summary="" border="0" style="width: 100%" cellspacing="0" cellpadding="0">
 <tbody>
 <tr>
 <td align="center"><img src="<% img %>" width="<% img_width %>" height="<% img_height %>" alt="<% fileid %>"/></td>
 </tr>
 </tbody>
 </table>
 </body>
 </html>
