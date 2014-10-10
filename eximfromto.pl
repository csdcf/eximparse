#!/usr/bin/perl





$input_file = "/Users/abiheiri/Downloads/transactions";
open $input, "<", $input_file or die "could not open $input_file: $!";

my %msgid;

while(<$input>) {
    ($month, $day, $time, $server, $proc, $id, $action, $rcpt) = split(/\s+/);

    next unless $action eq '**';
    next if $rcpt eq '<>';


    $msgid{$id}->{'email'} = $rcpt;

}

seek $input, 0, 0;


while(<$input>) {

    for my $subject (/(\sT=".+")/g){

        ($month, $day, $time, $server, $proc, $id, $action, $sender) = split(/\s+/);

        next if $sender eq '<>';
        next unless $action eq "<=";
	print "$month $day $time - $id [FROM]: $sender [TO]: ", $msgid{$id}->{'email'}, " [SUBJECT]: $subject\n";
        $msgid{$id}->{'subject'} = $subject;
        $msgid{$id}->{'sender'} = $sender;
    }

}

#while ( my ($key, $value) = each(%msgid) ) {
#    print "$key ", $value->{'email'},"\n";
#}

