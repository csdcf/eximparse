#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper; 
use POSIX qw/strftime/;

#this is to protect myself
#if a file has a name like "!rm -rf ~" it WILL delete your home directory
#use ARGV::readonly


#my $filename = "/Users/abiheiri/Downloads/tmp.abiheiri/maillog.1";
#open my $fh, "<", $filename or die "could not open $filename: $!";

my %c;
my %ip;

my $date=(strftime('%D %T',localtime));

print "Generating a report, hold your horses...\n";

while (<>)
{
        for my $match (/( rejected|spamhaus|unsolicited|rate limited|=>|<=|frozen)/g)
       	{
		$c{lc $match}++
	}

	for my $recieved_address (/<=.*[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/g)
	{
		$ip{$recieved_address}++
	}
}

#print
#        "-" x 20, "+", "-" x 40,"\n",
#	"Total rejected mail | Total rejected thanks to spamhaus.org\n",
#        "-" x 20, "+", "-" x 40,"\n",
#	sprintf "%19d | %39d \n", $counts{" rejected"}, $counts{spamhaus};	


print <<EOF

|=======================================================|
|			EXIM REPORT			|
|			$date
|=======================================================|
|Total mail sent 		|$c{"=>"}
|-------------------------------|-----------------------|
|Total mail recieved 		|$c{"<="}
|-------------------------------|-----------------------|
|Total frozen mail 		|$c{"frozen"}
|-------------------------------|-----------------------|
|Total unsolicited mail		|$c{unsolicited}
|-------------------------------|-----------------------|
|Total mail rejected		|$c{" rejected"}
|-------------------------------|-----------------------|
|Number of mail rejected	|$c{spamhaus}
|because it was in spamhaus.org	|			|
|-------------------------------|-----------------------|
|Number of times Google		|$c{"rate limited"}
|rate limited us		|		   	|
|===============================|=======================|

EOF
