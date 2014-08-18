#!/usr/bin/env perl
#
# 2014 - Al Biheiri

use strict;
use warnings;
use Data::Dumper;
use POSIX qw/strftime/;

#below can be used to protect myself
#if a file has a name like "!rm -rf ~" it WILL delete your home directory
#use ARGV::readonly


#my $filename = "/Users/abiheiri/Downloads/tmp.abiheiri/maillog.1";
#open my $fh, "<", $filename or die "could not open $filename: $!";

unless (@ARGV) 
{
	die "USAGE: $0 /pathto/exim.log /pathto/exim.log2\n";
}

#get file sizes to tell user
print map { "Size of $_: " . -s . "\n" } @ARGV;

#submodule logic for capturing ip address
my $ip_octect = qr{
    [0-9]       |  #match 0 - 9
    [1-9][0-9] |   # match 10 - 99
    1[0-9][0-9] | # match 100 - 999
    2[0-4][0-9] | # match 200 - 249
    25[0-5]     | # match 250 - 255
}x;

#submodile for creating a word boundry so that I capture only the ip address
#octet.octet.octect.octet 
#but .octect occurs three times
#qr// makes compiled regexes
#(?:) is a way to group multiple atoms as one
#perldoc perlre
my $ip_adder  = qr{
    \b  # word boundary
    $ip_octect
    (?:
        [.]
        $ip_octect
    ){3}
    \b  # word boundary
}x;


#variables use for the data collection
my %c;
my %received_addresses;
my %deliver_addresses;

#creating the date variable
my $date= strftime '%D %T', localtime;

print "Generating a report, hold your horses...\n";


# Collecting data
#
while (<>)
{
	#string match
        for my $match (/( rejected|spamhaus|unsolicited|rate limited|=>|<=|[fF]rozen)/g)
        {
		#lower case all matches for consistency
                $match = lc $match;
		#add to our hash the result
		#the hash keys are same name as the string match
                $c{$match}++;
		
		#if we recieved from someone
                if ($match eq "<=")
                {
			#capture the ipaddress
                    if (my ($received_address) = /<=.*?($ip_adder)/)
                    {
			#if no ipaddr, its prob local so injecting local variable
			$received_address ||= "local";
			#lets add to our hash the info we got
                        $received_addresses{$received_address}++;
                    }
                }

                if ($match eq "=>")
                {
                    if (my ($deliver_address) = /=>.*?($ip_adder)/)
                    {
			$deliver_address ||= "local";
                        $deliver_addresses{$deliver_address}++;
                    }
                }

        }
}


#
#this was too much effort and not flexible
#
#print
#        "-" x 20, "+", "-" x 40,"\n",
#       "Total rejected mail | Total rejected thanks to spamhaus.org\n",
#        "-" x 20, "+", "-" x 40,"\n",
#       sprintf "%19d | %39d \n", $counts{" rejected"}, $counts{spamhaus};      


print <<EOF;

|=======================================================|
|                       EXIM REPORT                     |
|                       $date
|=======================================================|
|Total mail sent                |$c{"=>"}
|-------------------------------|-----------------------|
|Total mail recieved            |$c{"<="}
|-------------------------------|-----------------------|
|Total frozen mail messages     |$c{"frozen"}
|-------------------------------|-----------------------|
|Total unsolicited mail         |$c{unsolicited}
|-------------------------------|-----------------------|
|Total mail rejected            |$c{" rejected"}
|-------------------------------|-----------------------|
|Number of mail rejected        |$c{spamhaus}
|because it was in spamhaus.org |                       |
|-------------------------------|-----------------------|
|Number of times Google         |$c{"rate limited"}
|rate limited us                |                       |
|=======================================================|
|							|
|							|
|=======================================================|
|        Top 20 RECEIVED mail FROM ip addresses         |
|=======================================================|
|Number of Times => IP Address				|
EOF

#sorting and organizing the exim top recieved ips
#Putting b first will cause out to be sorted highest to lowest
my @received_addr = sort { $received_addresses{$b} <=> $received_addresses{$a} } keys %received_addresses;
#the print portion has a preceding "|" so it lines ip with the EOF chart 
my $i; for my $item (@received_addr) { print  "|$received_addresses{$item} => $item\n"; last if ++$i == 20; }

print <<EOF;
|							|
|=======================================================|
|        Top 20 DELIVERED mail TO ip addresses 	        |
|=======================================================|
|Number of Times => IP Address				|
EOF
my @deliver_addr = sort { $deliver_addresses{$b} <=> $deliver_addresses{$a} } keys %deliver_addresses;
my $d; for my $item (@deliver_addr) { print  "|$deliver_addresses{$item} => $item\n"; last if ++$d == 20; }

#return total time it took to run this script
my ($user,$system,$cuser,$csystem) = times;
print <<EOF;
|							|
|=======================================================|
| Total processing time in seconds: $user
|=======================================================|
EOF


