#!//usr/bin/env perl -w
#

use strict;


open ( FILE, '/Users/abiheiri/Downloads/tmp.abiheiri/maillog.1');

my $data = <FILE>;
my %values = split(/ /,$data);

#print $data, "\n";

while ((my $month, my $day, my $time) = each(%values))
{
	print $month.", ".$day, "\n";
}
