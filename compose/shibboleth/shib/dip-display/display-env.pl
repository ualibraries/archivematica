#!/usr/bin/perl -wT
use strict;
use CGI::Fast qw(:standard);

while ( new CGI::Fast ) {
   print header;
   print start_html("Environment");
   
   foreach my $key (sort(keys(%ENV))) {
       print "$key = $ENV{$key}<br>\n";
   }
   
   my ($guid) =($ENV{REQUEST_URI} =~ m|^/([[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-([[:xdigit:]]){12}).*$|ga);
   my ($ftype) =($ENV{REQUEST_URI} =~ m/\.(\S+)$/ga);
   my $file = `find $ENV{DOCUMENT_ROOT}/DIPsStore -type f -name *$guid* | grep -v thumbnails/$guid`;
   #my $file = `find $docroot/thumbnails -type f -name *$guid*`;
   chomp( $file );

   print "$guid $ftype $file\n";
   
   print end_html;
}
