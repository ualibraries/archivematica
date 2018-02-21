#!/usr/bin/perl -w
###!/usr/bin/perl -wT
use strict;
use CGI::Fast qw(:standard);

#my $docroot="/var/archivematica/sharedDirectory/www";

while ( new CGI::Fast ) {

   my ( $guid ) =($ENV{REQUEST_URI} =~ m|^/([[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-([[:xdigit:]]){12}).*$|ga);
   my ( $ftype ) =($ENV{REQUEST_URI} =~ m/\.(\S+)$/ga);
   my $file = `find $ENV{DOCUMENT_ROOT}/DIPsStore -type f -name *$guid* | grep -v thumbnails/$guid`;
   #my $file = `find $docroot/thumbnails -type f -name *$guid*`;
   chomp( $file );

   #print "$guid $ftype $file\n";
   my ( $image, $buff, $FH );
   if ( open( $FH, '<', $file ) ) {
   
      while( read( $FH, $buff, 4096 ) ) {
          $image .= $buff;
      }
      close( $FH );
      
      my $content_length=length($image);
      
      if ( $ftype eq "jpg" ) {
        print "Content-type: image/jpeg\n"; 
      }
      else {
        print "Content-type: application/$ftype\n"; 
      }
      print "Transfer-Encoding: identity\n"; 
      print "Content-length: $content_length\n\n"; 
      
      print $image;
   }
   else {
      print header;
      print start_html( "DIP not found" );
      print "DIP: ".substr( $ENV{REQUEST_URI}, 1)." is unavailable.";
      print end_html;
   }
}
