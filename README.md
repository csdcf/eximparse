eximparse

=========

*Generate statistics based on exim logs*



SHOULD HAVE:

-----------

-Size of each log file
-Start and end time of each log file
-Total mail sent

	we want to capture => + ipaddress + hostname (H=)

-Total mail recieved

	we want to capture <= + ipaddress + hostname (H=)

-Total frozen mail messages

	capture [Ff]rozen

-Total unsolicited mail

	google count: #

-Total mail rejected

	unroutable: #
	spamhaus.org: #
	relay not permitted: #
	other: #


-Number of mail messages delayed          

	<= + delayed

-Messages received per hour

	##:00 + <=

-Deliveries per hour
	##:00 + =>


NICE TO HAVE:

------------

-Time spent on the queue: all messages
-Time spent on the queue: messages with at least one remote delivery
-Top XX sending hosts by message count (capture IP and hostname b/c according to exim manpage (i think) hostname can be manipulated so IP is more certain)
-Top XX host destinations by message count (capture IP and hostname)
-Top XX rejected ips by message count  (capture IP and hostname)
-Top XX temporarily rejected ips by message count (capture IP and hostname)
-optimize runtime of the code

