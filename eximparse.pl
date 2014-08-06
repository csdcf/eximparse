#!//usr/bin/env perl

use strict;
use warnings;
use Data::Dumper; 

#this is to protect myself
#if a file has a name like "!rm -rf ~" it WILL delete your home directory
#use ARGV::readonly


#my $filename = "/Users/abiheiri/Downloads/tmp.abiheiri/maillog.1";
#open my $fh, "<", $filename or die "could not open $filename: $!";

my %count_reject;
my %count_spamhaus;

my %counts;

while (<>)
{
        for my $match (/( rejected|spamhaus)/g) {
		$counts{$match}++
	}
}

print
        "-" x 20, "+", "-" x 40, "\n",
	"Total rejected mail | Total rejected ala spamhaus.org\n",
        "-" x 20, "+", "-" x 40, "\n",
	sprintf "%19d | %39d\n", $counts{" rejected"}, $counts{spamhaus};	
