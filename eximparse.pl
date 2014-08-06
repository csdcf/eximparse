#!//usr/bin/env perl -w
#

use strict;
use Data::Dumper; 


my $filename = "/Users/abiheiri/Downloads/tmp.abiheiri/maillog.1";
open my $fh, "<", $filename or die "could not open $filename: $!";

my %count_reject;

while (<$fh>)
{
	my ($k) = / rejected/;
	if (defined $k) 
	{
		$count_reject{$k}++;
	}
}

for my $k (keys %count_reject)
{
	    print "We have rejected mail  $count_reject{$k} times\n";
}
