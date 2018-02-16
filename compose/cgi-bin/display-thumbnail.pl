#!/usr/bin/perl -w

#use strict;
#use File::Copy;

# Do something with $ENV{REQUEST_URI}
#`cat ./fa86249f-00ef-4a10-85cd-05e996a356eb/de7da20b-dc73-494e-8781-b0a268414c3a.jpg`;
my ($guid) =($ENV{REQUEST_URI} =~ m/([[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-([[:xdigit:]]){12}).*$/ga);
my ($ftype) =($ENV{REQUEST_URI} =~ m/\.(\S+)$/ga);
#my $file = `find ./DIPsStore -type f -path  thumbnails -prune -o -name *$guid*`;
my $file = `find ./thumbnails -type f -name *$guid*`;
chomp( $file );

#print "$guid $ftype $file\n";
open IMAGE, "$file";

#assume is a jpeg...
my ($image, $buff);
while(read IMAGE, $buff, 4096) {
    $image .= $buff;
}
close IMAGE;

print "Content-type: image/$ftype\n\n";
print $image;

