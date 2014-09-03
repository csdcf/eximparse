eximparse

=========

Generate statistics based on exim logs



SHOULD HAVE:

-----------

Size of each log file

Start and end time of each log file

Total mail sent

Total mail recieved

Total frozen mail messages

Total unsolicited mail

Total mail rejected

Number of mail rejected because it was in spamhaus.org

Number of times Google rate limited us

Number of mail messages delayed          

Messages received per hour

Deliveries per hour



NICE TO HAVE:

------------

Time spent on the queue: all messages

Time spent on the queue: messages with at least one remote delivery

Top XX sending hosts by message count (capture IP and hostname b/c according to exim manpage (i think) hostname can be manipulated so IP is more certain)

Top XX host destinations by message count (capture IP and hostname)

Top XX rejected ips by message count  (capture IP and hostname)

Top XX temporarily rejected ips by message count (capture IP and hostname)

optimize runtime of the code

