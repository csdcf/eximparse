#!/usr/bin/env perl
#
# 2014 - Al Biheiri

use strict;
use warnings;
use Data::Dumper;
use POSIX qw/strftime/;

#below can be used to protect myself
#if a file has a name like "!rm -rf ~" it WILL delete your home directory
#currently turned off because it requires a seperate package
#use ARGV::readonly


#my $filename = "/Users/abiheiri/Downloads/tmp.abiheiri/maillog.1";
#open my $fh, "<", $filename or die "could not open $filename: $!";

unless (@ARGV) 
{
	die "USAGE: $0 /pathto/exim.log /pathto/exim.log2\n";
}

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
my %count;
my %message_ids;
my %spam_hostname;
my %hash_raddr;
my %hash_daddr;
my %hash_rejects;


#creating the date variable
my $date= strftime '%D %T', localtime;



print "Generating a report, hold your horses... (aprx 120sec/per 800M) \n";

#get file sizes to tell user
print map { "Size of $_: " . -s , "\n" } @ARGV;

print "Hostnames are displayed for your convience but they can be spoofed, EXIM suggest you rely on IP instead. \n";


# Collecting data
#
my $old_file_name = "";
my $last_date;
while (<>)
{
        #variable for log start and end date
        #without the paranthesis for the variable, it will return scalar value.
        # scalar, 1 or undefs is returned (depending on whether it matched or not)
        my ($date) = /([A-Z][a-z]{2} +[0-9]+)/;
        
        # run this everytime the file changes
        unless ($old_file_name eq $ARGV)
	{
            # don't run this for the first file
            unless ($old_file_name eq "")
		{
			print "$ARGV ends on $last_date\n";
		}
            print "$ARGV starts on $date\n";
        }
        $old_file_name = $ARGV;
        $last_date = $date;

        #string match, some of the strings have spaces because I want to match it in log with spaces
	for my $match (/( rejected|spamhaus|unsolicited|rate limited|=>|<=|[fF]rozen| delayed )/g)
        {
		#lower case all matches for consistency
                $match = lc $match;
		#add to our hash the result
		#the hash keys are same name as the string match
                $count{$match}++;
		
		#if we recieved from someone
                if ($match eq "<=")
                {
			#capture the ipaddress
		    if (my ($host, $ip) = / H= \( ([^)]*) \) [ ] \[ ($ip_adder) \] /x)
                    #if (my ($received_address) = /<=.*?($ip_adder)/)
                    {
			#if no ipaddr, its prob local so injecting local variable
			$host ||= "local";
			#lets add to our hash the info we got
                        $hash_raddr{"$host ($ip)"}++;

			#print Dumper \%hash_raddr, "\n";
                    }
                }

                if ($match eq "=>")
                {
		    if (my ($host, $ip) = / H= \( ([^)]*) \) [ ] \[ ($ip_adder) \] /x)
                    #if (my ($deliver_address) = /=>.*?($ip_adder)/)
                    {
			#$deliver_address ||= "local";
                        #$hash_daddr{$deliver_address}++;
			$host ||= "local";
                        $hash_daddr{"$host ($ip)"}++;
                    }
                }
	
		#each message has an ID associated with it, capture uniq data and determine how many are frozen messages
		if ($match =~ /[fF]rozen/)
		{
			if (my ($id) = /(.{6}\-.{6}\-.{2})/)
			{
				$message_ids{$id}++;
		
			}
		}
		
		#who are the top spamhaus hosts?
		if ($match eq "spamhaus")
		{
			if (my ($spamgroup) = /($ip_adder)/)
			{
				$spam_hostname{$spamgroup}++;
			#	print Dumper \%spam_hostname, "\n";
			}
		}

		#who are the top rejected ips?
		if ($match eq " rejected")
		{
			if (my ($host, $ip) = / H= \( ([^)]*) \) [ ] \[ ($ip_adder) \] /x)
			{
				$hash_rejects{"$host ($ip)"}++;
				#print Dumper \%hash_rejects, "\n";
			}
		}

        }
}

#sum the message_ids
my $unique_message_id_count = keys %message_ids;

#sum the spamhaus
my $unique_spamhaus_count = keys %spam_hostname;

#part of reading the log file and determining what the last date of the log is
#its placed here so that it is printed on screen after the whole log is parsed first (the while statement above).
print "$ARGV ends on $last_date\n";

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
|mail sent                	|$count{"=>"}
|-------------------------------|-----------------------|
|mail recieved            	|$count{"<="}
|-------------------------------|-----------------------|
|frozen mail messages    	|$unique_message_id_count
|-------------------------------|-----------------------|
|unsolicited mail       	|$count{unsolicited}
|-------------------------------|-----------------------|
|mail rejected		        |$count{" rejected"}
|-------------------------------|-----------------------|
|Number of mail rejected        |$unique_spamhaus_count
|because it was in spamhaus.org |                       |
|-------------------------------|-----------------------|
|Number of times Google         |$count{"rate limited"}
|rate limited us                |                       |
|-------------------------------|-----------------------|
|mail delayed		        |$count{" delayed "}
|=======================================================|
|							|
|							|
|=======================================================|
|        Top 20 received from hosts (message count)  	|
|=======================================================|
|Number of Times => IP Address				|
EOF

#sorting and organizing the exim top recieved ips
#Putting b first will cause out to be sorted highest to lowest
my @received_addr = sort { $hash_raddr{$b} <=> $hash_raddr{$a} } keys %hash_raddr;
#the print portion has a preceding "|" so it lines ip with the EOF chart 
my $i; for my $item (@received_addr) { print  "|$hash_raddr{$item} => $item\n"; last if ++$i == 20; }

print <<EOF;
|							|
|=======================================================|
|        Top 20 host destinations (message count)       |
|=======================================================|
|Number of Times => IP Address				|
EOF
my @deliver_addr = sort { $hash_daddr{$b} <=> $hash_daddr{$a} } keys %hash_daddr;
my $d; for my $item (@deliver_addr) { print  "|$hash_daddr{$item} => $item\n"; last if ++$d == 20; }


print <<EOF;
|							|
|=======================================================|
|   Top 20 received from hosts blocked by spamhaus.org	|
|=======================================================|
|Number of Times => hostname or IP			|
EOF
my @spam_host = sort { $spam_hostname{$b} <=> $spam_hostname{$a} } keys %spam_hostname;
my $s; for my $item (@spam_host) { print  "|$spam_hostname{$item} => $item\n"; last if ++$s == 20; }


print <<EOF;
|							|
|=======================================================|
|        Top 20 rejected IPs (message count)
|=======================================================|
|Number of Times => hostname IP				|
EOF
my @reject_host = sort { $hash_rejects{$b} <=> $hash_rejects{$a} } keys %hash_rejects;
my $r; for my $item (@reject_host) { print  "|$hash_rejects{$item} => $item\n"; last if ++$r == 20; }


#return total time it took to run this script
my ($user,$system,$cuser,$csystem) = times;
print <<EOF;
|							|
|=======================================================|
| Total processing time in seconds: $user
|=======================================================|
EOF


