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


my $ip_octect = qr{
    [0-9]       |  #match 0 - 9
    [1-9][0-9] |   # match 10 - 99
    1[0-9][0-9] | # match 100 - 999
    2[0-4][0-9] | # match 200 - 249
    25[0-5]     | # match 250 - 255
}x;

my $ip_adder  = qr{
    \b  # word boundary
    $ip_octect
    (?:
        [.]
        $ip_octect
    ){3}
    \b  # another word boundary
}x;

my %c;
my %recieved_addresses;

my $date= strftime '%D %T', localtime;

print "Generating a report, hold your horses...\n";

while (<>)
{
        for my $match (/( rejected|spamhaus|unsolicited|rate limited|=>|<=|[fF]rozen)/g)
        {
                $match = lc $match;
                $c{$match}++;
                if ($match eq "<=") 
		{
                    my $recieved_address = /<=.*?($ip_adder)/;
                    $recieved_adresses{$recieved_address}++;
                }
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
