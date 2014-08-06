#!//usr/bin/env perl -w
#

use strict;
use Data::Dumper; 

#this is to protect myself
#if a file has a name like "!rm -rf ~" it WILL delete your home directory
#use ARGV::readonly


#my $filename = "/Users/abiheiri/Downloads/tmp.abiheiri/maillog.1";
#open my $fh, "<", $filename or die "could not open $filename: $!";

my %count_reject;
my %count_spamhaus;

while (<>)
{
	my ($k_reject) = / rejected/;
	my ($k_spamhaus) = /spamhaus/;

	if (defined $k_reject) 
	{
		$count_reject{$k_reject}++;
	}

	if (defined $k_spamhaus) 
	{
		$count_spamhaus{$k_spamhaus}++;
	}
}

for my $k_reject (keys %count_reject)
{
	    print "Total Rejected Mail: $count_reject{$k_reject}\n";
}

for my $k_spamhaus (keys %count_spamhaus)
{
	    print "Total rejected because of spamhaus.org $count_spamhaus{$k_spamhaus}\n";
}
